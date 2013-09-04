/*
	Staff Weapon for GarrysMod10
	Copyright (C) 2007  aVoN
	Rewrited by Madman07, 2011

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
ENT.Untouchable = true;
ENT.IgnoreTouch = true;
ENT.NoAutoClose = true; -- Will not cause an autoclose event on the stargates!
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

--################# SENT CODE ###############

--################### Init @aVoN, Madman07
function ENT:Initialize()
	-- this cause crash when shoot in water, when i set just same values for all shoots no crashes and everything work fine
	--self.Entity:PhysicsInitSphere(self.Size/10,"metal");
	--self.Entity:SetCollisionBounds(-1*Vector(1,1,1)*self.Size/10,Vector(1,1,1)*self.Size/10);
	self.Entity:PhysicsInitSphere(10,"metal");
	self.Entity:SetCollisionBounds(Vector(1,1,1)*-5,Vector(1,1,1)*5);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self:DrawShadow(false)
	-- Config
	self.Radius = 20+30*self.Size;  --StarGate.CFG:Get("staff","radius",50);
	self.Damage = 30+40*self.Size;  --StarGate.CFG:Get("staff","damage",150);
	self.MaxPasses = 5; --StarGate.CFG:Get("staff","maxpasses",5);
	self.Passes = 1;
	self.Passed = {}; -- Necessary, so you can shoot out of Catdaemons shield
	local color = self.Entity:GetColor();
	local r,g,b = color.r,color.g,color.b;
	if(r == 255 and g == 255 and b == 255) then
		self.Entity:SetColor(Color(math.random(230,255),200,120,255));
	end
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)

	--PhysObject
	self:PhysWake()
	self.Phys = self.Entity:GetPhysicsObject();
	local vel = self.Direction*self.Speed+VectorRand()*self.Random;
	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:SetMass(self.Size*10);
		self.Phys:EnableGravity(false);
		self.Phys:SetVelocity(vel);-- end
	end
	self.Entity:SetLocalVelocity(vel)
	self.Created = CurTime();

	self.CoreNotCollide = self.Owner.CoreNotCollide;
	self.CoreEntity = self.Owner.CoreEntity;
end

--################# Prevent PVS bug/drop of all networkes vars (Let's hope, it works) @aVoN
function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end;

--################# Think for physic @Mad
function ENT:PhysicsUpdate(phys)
	local vel = phys:GetVelocity();
	if (math.abs(vel.x)<500 and math.abs(vel.y)<500 and math.abs(vel.z)<500) then -- faster than length?
		self:Destroy();
	end
end

function ENT:CAPOnShieldTouch(shield)
	self:Blast("energy_impact",self:GetPos(),shield,Vector(1,1,1),false,self.Damage,self.Radius);
	self:Destroy();
end

function ENT:Think(ply)
	local phys = self:GetPhysicsObject();
	if IsValid(phys) then phys:Wake(); end
end

function ENT:Explode()
	self:Blast("energy_explosion",self:GetPos(),self,Vector(1,1,1),false,self.Damage,self.Radius);
	self:Destroy();
end

--################### Make the shot blast @aVoN, Madman07
function ENT:PhysicsCollide( data, physobj )
	local e = data.HitEntity;

	if (e) then
		if e.IgnoreTouch then return end; -- Gloabal for anyone, who want's to make his scripts "staff-passable"
		if self.Passed[e] then return end; -- We already passed this entity. Don't touch it again
		if (self.CoreNotCollide and self.CoreEntity == e) then return end; -- avoid owner shields

		local pos = data.HitPos;
		local world = e:IsWorld()
		local owner = self.Entity:GetOwner();
		if (owner == nil) then owner = self.Entity; end
		local hitnormal = data.HitNormal;
		local class = e:GetClass()

		if world then hitnormal = -1*hitnormal; end

		if (owner == e) then return end
		for _,v in pairs(self.Ignore) do
			if (v == e) then return end
		end

		-- Shield Thing
		if (not world and self.Passed[e] == nil) then
			if not e:GetPhysicsObject():IsValid() then self.Passed[e] = true return end; -- Invalid physics object?
			if (class == "ivisgen_collision") then self.Passed[e] = true return end; -- Catdaemon's cloaking device
			if e.nocollide then -- Catdaemon's and avon shield?
				if(e.nocollide[owner]) then
					e.nocollide[e] = true;
					self.Passed[e] = true;
					return;
				end
				self.Passed[e] = false;
			end
		end

		-- ######################## The blast
		local dir = self.Direction*10;
		local hitsmoke = true;
		if (hitnormal:Length() == 0) then hitsmoke = false end;

		local trace = util.TraceLine({start=pos-dir,endpos=pos+dir,filter={self.Entity,owner}});
		if trace then
			if trace.HitSky then self.Entity:Destroy() return end;
			if (trace.MatType == MAT_FLESH or trace.MatType == MAT_METAL or trace.MatType == MAT_GLASS) then hitsmoke = false end
		end

		hitsmoke = false

		if self.Stunner then
			self.Phys = self.Entity:GetPhysicsObject();
			if(self.Phys and self.Phys:IsValid()) then
				self.Phys:SetMass(1);
			end
			self.Entity:PhysicsInitSphere(1,"metal");
			self.Entity:SetCollisionBounds(-1*Vector(1,1,1),Vector(1,1,1));
			if e:IsPlayer() then
				e:Freeze(true)
				local phys = e:GetPhysicsObject()
				if phys and phys:IsValid() then
					phys:EnableMotion(false) -- Freezes the object in place.
				end
			end
			if e:IsNPC() then
				e:StopMoving()
				local phys = e:GetPhysicsObject()
				if phys and phys:IsValid() then
					phys:EnableMotion(false) -- Freezes the object in place.
				end
			end
			self:Blast("energy_impact",pos,e,hitnormal,hitsmoke,0,0, data.OurOldVelocity);
		else
			self:Blast("energy_impact",pos,e,hitnormal,hitsmoke,self.Damage,self.Radius, data.OurOldVelocity);
		end

		self:Destroy();

	end
end

-- ########################  TELEPORT
function ENT.FixAngles(self,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
	self:PhysWake()
	self.Direction = vel:GetNormalized();
	local vel2 = self.Direction*self.Speed+VectorRand()*self.Random;
	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:SetVelocity(vel2);
	end
	self.Entity:SetLocalVelocity(vel2)
end
StarGate.Teleport:Add("energy_pulse",ENT.FixAngles);

-- ######################## Damage system
function ENT:Blast(effect,pos,ent,norm,smoke,dmg,rad,old_vel)
	local fx = EffectData();
	fx:SetOrigin(pos);
	fx:SetNormal(norm);
	fx:SetEntity(ent);
	if(not smoke) then
		fx:SetScale(-1);
	else
		fx:SetScale(1);
	end
	fx:SetMagnitude(self.Size);
	local c = self.Entity:GetColor();
	fx:SetAngles(Angle(c.r,c.g,c.b));
	util.Effect(effect,fx,true,true);
	local i = 1/math.sqrt(self.Passes); -- Intensity
	if(self.ExplosiveDamage) then
		dmg = math.Clamp(self.ExplosiveDamage*i,0,dmg); -- Necessary, or the powerfull shot won't go throug breakable stuff such good anymore
	end

	local attacker,owner = StarGate.GetAttackerAndOwner(self.Entity);
	StarGate.BlastDamage(attacker,owner,pos,rad,dmg*i);
	util.ScreenShake(pos,2,2.5,1,700);

	if (ent:GetClass() == "shield") then -- aVoN shield!
		ent:HitShield(ent,pos,self:GetPhysicsObject(),self:GetClass(),norm);
	end

	--local dmg;
	--dmg:SetInflictor(attacker)
	--dmg:SetAttacker(owner)
	--dmg:SetDamageType(DMG_BLAST)
	--rad = rad
	--pos = pos - old_vel


	-- for _,v in pairs(ents.FindInSphere(pos,rad)) do
		-- local phys = v:GetPhysicsObject();
		-- if phys:IsValid() then
			----local pos = self.Owner:GetShootPos()
			---local ang = self.Owner:GetAimVector()
			-- local tracedata = {}
			-- tracedata.start = pos
			-- tracedata.endpos = v:LocalToWorld(v:OBBCenter())
			-- tracedata.filter = self.Owner
			-- local trace = util.TraceLine(tracedata)
			-- if (trace.Entity and trace.Entity == v) then
				---dmg:SetDamageForce((pos-tracedata.endpos)*1000)
				---dmg:SetDamage(dmg*i*(1/(pos:Distance(tracedata.endpos)))
				-- local power = dmg*i*(1/(pos:Distance(tracedata.endpos)))*10000


				-- v:TakeDamage(power, owner, attacker)
				---util.BlastDamage(owner, attacker, v:GetPos(), 5, power)
			-- end
		-- end
	-- end

end

--################### Setup @Mad
function ENT:PrepareBullet(dir, rand, spd, size, ignore)
	self.Direction = dir;
	self.Random = rand;
	self.Speed = spd;
	self.Size = size;
	self.Entity:SetNetworkedInt("Size", size);
	self.Ignore = ignore or {};
end

--################### Destroys this entity without fearing to crash! @aVoN
function ENT:Destroy()
	-- May fix crash @ AlexALX
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE);
	self.Entity:SetMoveType(MOVETYPE_NONE);
	self.Entity:SetSolid(SOLID_NONE);
	--
	self.PhysicsCollide = function() end; -- Dummy
	self.Touch = self.PhysicsCollide;
	self.StartTouch = self.Touch;
	self.EndTouch = self.Touch;
	self.Think = self.Touch;
	self.PhysicsUpdate = self.Touch;
	self:SetTrigger(false);
	local e = self.Entity;
	timer.Simple(0,
		function()
			if(IsValid(e)) then e:Remove() end;
		end
	);
end

--################### Earthquake! @aVoN
concommand.Add("_StarGate.StaffBlast.ScreenShake",
	function(p,_,arg)
		if(IsValid(p)) then
			util.ScreenShake(Vector(unpack(arg)),2,2.5,1,700);
		end
	end
);