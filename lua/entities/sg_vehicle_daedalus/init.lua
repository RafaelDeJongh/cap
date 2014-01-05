--[[
	BC-304 "Daedalus"
	Copyright (C) 2010 Madman07

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

]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/Madman07/daedalus/daedalus.mdl");
	self.Entity:SetName("BC-304 Daedalus");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:StartMotionController();

	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then
		phys:Wake();
		phys:SetMass(50000);
	end

    -- self.AsgardBeam = {};
    self.Railgun = {};
    -- self.Ring = {};
	-- self.RingRing = {};
	-- self.Transporter = NULL;
	-- self.ZPM = NULL;
	-- self.BeamEnt = NULL;

    -- self.AsgardBeamEnable = false;
    -- self.RailgunEnable = false;
    -- self.RocketEnable = false;
    -- self.TransporterEnable = false;

    -- self.Entity:SpawnAsgardBeams();
	self.Entity:SpawnRailguns();
    -- self.Entity:SpawnRings();
    -- self.Entity:SpawnTransporter();
	self.Entity:SpawnRotor();
	--self.Entity:SpawnLight();

	-- if (self.HasRD) then
		-- self.Entity:SpawnPower();
		-- self.Entity:ConnectPower(self.ZPM);
	-- end

	self.MissileMaxVel=10000000
	self.TrackTime = 1000000;
	self.Fired = false;
	self.Rocket = {};
	self.RocketTarget = nil;

	self.FlightPhys = {
		secondstoarrive  = 1;
		maxangular	     = 10000000;
		maxangulardamp   = 100000;
		maxspeed		 = 10000000;
		maxspeeddamp     = 500000;
		dampfactor	     = 1;
		teleportdistance = 5000;
	}

    self.Forw = 0;
    self.Angles = Angle(0,0,0);
    self.LastYaw = self.Entity:GetAngles().Yaw;
    self.Hull = 20000;
    self.KeyRoll = 0;
    self.HoverPos = self.Entity:GetPos();
	self.lastpos = nil;
	self.GoUp = 0;

    self.Active = false;
    self.Pressed = false;

    self.Driver = NULL;
    self.weps = {};

    self.TargetMode = 0;

    self:SetNetworkedInt("ViewMode",0);




	self.Target = self:GetPos();
	self.RailgunTracing = false;
	self.RailgunShoot = false;
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	-- local PropLimit = GetConVar("ships_daedalus_max"):GetInt()
	-- if(ply:GetCount("ships_daedalus")+1 > PropLimit) then
		-- ply:ChatPrint("Daedalus class ships limit reached!")
		-- return
	-- end

	local PropLimit = GetConVar("CAP_ships_max"):GetInt()
	if(ply:GetCount("CAP_ships")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Ships limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	ent = ents.Create("sg_vehicle_daedalus");
	ent:SetPos(ply:GetPos()+Vector(0,50,800));
	ent:Spawn();
	ent:Activate();
	-- ent:SetOwner(self.Entity);
	ent.Owner = ply;
	-- ent.Owner:SetNetworkedEntity("DaedalusOutside",ent);

	-- ply:AddCount("ships_daedalus", ent)
	ply:AddCount("CAP_ships", ent)
	return ent
end

-----------------------------------POWER----------------------------------

-- function ENT:ConnectPower(source)

	-- Dev_Link(self.Transporter, source);
	-- for i=1,6 do
		-- Dev_Link(self.Railgun[i], source);
		-- Dev_Link(self.AsgardBeam[i], source);
	-- end

-- end

-- function ENT:SpawnPower()
	-- local ent = ents.Create("Zero_Point_Module");
	-- ent:SetModel("models/zup/zpm/zpm.mdl");
	-- ent:SetPos(self.Entity:GetPos()+Vector(0,0,80));
	-- ent:Spawn();
	-- ent:Activate();
	-- ent:SetOwner(self.Entity);
	-- ent:SetParent(self.Entity);
	-- constraint.Weld(ent,self.Entity,0,0,0,true);
	-- self.ZPM = ent;
-- end

-----------------------------------SPAWN ROTORWASH----------------------------------

function ENT:SpawnRotor()

	local ent = NULL;
    local SpawnPos = {
		self:LocalToWorld(Vector(2500, 0, -450)),
		self:LocalToWorld(Vector(2000, 0, -450)),
		self:LocalToWorld(Vector(-500, 1250, -450)),
		self:LocalToWorld(Vector(-1000, 1250, -450)),
		self:LocalToWorld(Vector(-1500, 1250, -450)),
		self:LocalToWorld(Vector(-500, -1250, -450)),
		self:LocalToWorld(Vector(-1000, -1250, -450)),
		self:LocalToWorld(Vector(-1500, -1250, -450))
	}

	for i=1,8 do
		ent = ents.Create("env_rotorwash_emitter");
		ent:SetPos(SpawnPos[i]);
		ent:Spawn();
		ent:Activate();
		ent:SetOwner(self.Entity);
		ent:SetParent(self.Entity);
		ent:SetKeyValue("Altitude", "1000");
	end

end

-- function ENT:SpawnLight()

	-- local SpawnPos = {};
	-- local SpawnAng = {};
	-- local Pos = self.Entity:GetPos();
	-- local ent = NULL;

	-- SpawnPos[1] = Pos + Vector(-800, 470, -200);
	-- SpawnPos[2] = Pos + Vector(-800, -470, -200);
	-- SpawnPos[3] = Pos + Vector(-1300, 800, -200);
	-- SpawnPos[4] = Pos + Vector(-1300, -800, -200);

	-- SpawnAng[1] = Angle(-45,0,0);
	-- SpawnAng[2] = Angle(-45,0,0);
	-- SpawnAng[3] = Angle(-135,0,0);
	-- SpawnAng[4] = Angle(-135,0,0);

	-- for i=1,4 do
		-- ent = ents.Create( "env_projectedtexture" )
		-- ent:SetParent( self.Entity )
		-- ent:SetLocalPos( SpawnPos[i] )
		-- ent:SetLocalAngles( SpawnAng[i] )
		-- ent:SetKeyValue( "enableshadows", 1 )
		-- ent:SetKeyValue( "farz", 2048 )
		-- ent:SetKeyValue( "nearz", 8 )
		-- ent:SetKeyValue( "lightfov", 50 )
		-- ent:SetKeyValue( "lightcolor", "255 255 255" )
		-- ent:Spawn()
		----self.flashlight:Input( "SpotlightTexture", NULL, NULL, self:GetFlashlightTexture() )
	-- end

-- end


-----------------------------------SPAWN RAILGUNS----------------------------------

function ENT:SpawnRailguns()
	local att = {
		"TLF",
		"TLM",
		"TLT",
		"TLB",
		"TRF",
		"TRM",
		"TRT",
		"TRB"
	}

	local ent = NULL;
	local ang = self:GetAngles();

	for i=1,8 do
		local data = self:GetAttachment(self:LookupAttachment(att[i]));
		if not (data and data.Pos) then return end

		ent = ents.Create("sg_turret_daedalus");
		ent:SetModel("models/Madman07/daedalus/turret.mdl");
		ent:SetPos(data.Pos);
		ent:SetAngles(ang);
		ent.Parent = self;
		ent:Spawn();
		ent:Activate();
		ent:SetOwner(self.Entity);
		ent:SetParent(self.Entity);
		local phys = ent:GetPhysicsObject();
		if IsValid(phys) then phys:Wake(); end

		table.insert(self.Railgun, ent);
	end
end

-- function ENT:SpawnRailguns()

	-- local SpawnPos = {};
	-- local Pos = self.Entity:GetPos();
	-- local ent = NULL;

	-- SpawnPos[1] = Pos + Vector(1990, 453, 42);
	-- SpawnPos[2] = Pos + Vector(1990, -453, 42);
	-- SpawnPos[3] = Pos + Vector(861, 270, 300);
	-- SpawnPos[4] = Pos + Vector(861, -270, 300);
	-- SpawnPos[5] = Pos + Vector(-276, 558, 389);
	-- SpawnPos[6] = Pos + Vector(-276, -558, 389);

	-- for i=1,6 do
		-- ent = ents.Create("ship_railgun");
		-- ent:SetModel("models/Madman07/ship_railgun/ship_stand.mdl");
		-- ent:SetPos(SpawnPos[i]);
		-- ent:Spawn();
		-- ent:Activate();
		-- ent:SetOwner(self.Entity);
		-- ent:SetParent(self.Entity);
		-- constraint.Weld(ent,self.Entity,0,0,0,true);
		-- ent:TriggerInput("Active",1);
		-- ent:TriggerInput("Fire",0);
		-- self.Railgun[i] = ent;
	-- end

-- end

-----------------------------------SPAWN ASGARD----------------------------------

-- function ENT:SpawnAsgardBeams()

	-- local SpawnPos = {};
	-- local SpawnAng = {};
	-- local Pos = self.Entity:GetPos();
	-- local ent = NULL;

	-- SpawnPos[1] = Pos + Vector(2430, 355, -150);
	-- SpawnPos[2] = Pos + Vector(2430, -355, -150);
	-- SpawnPos[3] = Pos + Vector(430, 490, 120);
	-- SpawnPos[4] = Pos + Vector(430, -490, 120);
	-- SpawnPos[5] = Pos + Vector(-850, -620, -235);
	-- SpawnPos[6] = Pos + Vector(-850, 620, -235);

	-- SpawnAng[1] = Angle(0,0,-90);
	-- SpawnAng[2] = Angle(0,0,90);
	-- SpawnAng[3] = Angle(0,0,-55);
	-- SpawnAng[4] = Angle(0,0,55);
	-- SpawnAng[5] = Angle(90,0,0);
	-- SpawnAng[6] = Angle(90,0,0);

	-- for i=1,6 do
		-- ent = ents.Create("asgard_beam");
		-- ent:SetModel("models/Madman07/asgard_turret/asgard_turret.mdl");
		-- ent:SetAngles(SpawnAng[i]);
		-- ent:SetPos(SpawnPos[i]);
		-- ent:Spawn();
		-- ent:SetOwner(self.Entity);
		-- ent:SetParent(self.Entity);
		-- constraint.Weld(ent,self.Entity,0,0,0,true);
		-- self.AsgardBeam[i] = ent;
		-- ent:TriggerInput("Active",1);
	-- end

-- end

-----------------------------------SPAWN TRANSPORTER----------------------------------

-- function ENT:SpawnTransporter()
	-- local ent = ents.Create("transporter");
	-- ent:SetModel("models/props_combine/combine_light001b.mdl");
	-- ent:SetPos(self.Entity:GetPos());
	-- ent:Spawn();
	-- ent:Activate();
	-- ent:SetOwner(self.Entity);
	-- ent:SetParent(self.Entity);
	-- constraint.Weld(ent,self.Entity,0,0,0,true);
	-- self.Transporter = ent;
-- end

-----------------------------------SPAWN RINGS----------------------------------

-- function ENT:SpawnRings()

	-- local SpawnPos = {};
	-- local SpawnAng = {};
	-- local Pos = self.Entity:GetPos();
	-- local ent = NULL;

	-- SpawnPos[1] = Pos + Vector(-1611, 274, 385);
	-- SpawnPos[2] = Pos + Vector(1520, 0, -200);
	-- SpawnPos[3] = Pos + Vector(-1611, 274, 400);
	-- SpawnPos[4] = Pos + Vector(1520, 0, -200);

	-- SpawnAng[1] = Angle(0,0,0);
	-- SpawnAng[2] = Angle(180,0,0);

	-- for i=1,2 do
		-- ent = ents.Create("ring_base");
		-- ent:SetModel("models/props_junk/sawblade001a.mdl");
		-- ent:SetAngles(SpawnAng[i]);
		-- ent:SetPos(SpawnPos[i]);
		-- ent:Spawn();
		-- ent:Activate();
		-- ent:SetOwner(self.Entity);
		-- ent:SetParent(self.Entity);
		-- constraint.Weld(ent,self.Entity,0,0,0,true);
		-- self.Ring[i] = ent;

		-- ent = ents.Create("prop_physics");
		-- ent:SetModel("models/Zup/sg_rings/ring.mdl");
		-- ent:SetPos(SpawnPos[i+2]);
		-- ent:Spawn();
		-- ent:Activate();
		-- ent:SetOwner(self.Entity);
		-- ent:SetParent(self.Entity);
		-- constraint.Weld(ent,self.Ring[i],0,0,0,true);
		-- self.RingRing[i] = ent;
	-- end

	-- self.Ring[1]:KeyValue("name","BC304UP")
	-- self.Ring[2]:KeyValue("name","BC304DOWN")

-- end

--[[function ENT:OpenLegs()

	local SpawnPos = {};
	local Pos = self.Entity:GetPos();
	local ent = NULL;

	SpawnPos[1] = Pos + Vector(1520, , -250);
	SpawnPos[2] = Pos + Vector(-1520, -500, -250);
	SpawnPos[2] = Pos + Vector(-1520, 500, -250);

	for i=1,3 do
		ent = ents.Create("prop_physics");
		ent:SetModel("models/props_canal/bridge_pillar02.mdl");
		ent:SetAngles(self.Entity:GetAngles());
		ent:SetPos(SpawnPos[i]);
		ent:Spawn();
		ent:Activate();
		ent:SetOwner(self.Entity);
		ent:SetParent(self.Entity);
		--constraint.Weld(ent,self.Entity,0,0,0,true);
		self.Leg[i] = ent;

	end


end]]--

-----------------------------------FIRE RAILGUN----------------------------------

function ENT:AimRailgun(target)
	for _,v in pairs(self.Railgun) do
		if IsValid(v) then v:Aim(target); end
	end
end

function ENT:FireRailgun(target)
	for _,v in pairs(self.Railgun) do
		if IsValid(v) then v:DoShoot(); end
	end
end

-----------------------------------FIRE ASGARD----------------------------------

function ENT:FireAsgard(target)
	local att = {
		"ALB",
		"ALF",
		"ALT",
		"ARB",
		"ARF",
		"ART"
	}

	local data = self:GetAttachment(self:LookupAttachment(att[math.random(1,6)]));
	if not (data and data.Pos) then return end

	local trace = {}
		trace.start = data.Pos+data.Ang:Forward()*50;
		trace.endpos = target;
	local tr = util.TraceLine( trace );

	if (!tr.Entity or tr.Entity != self.Entity) then
		local ShootDir = (target - data.Pos):GetNormal();
		local ent = ents.Create("energy_beam2");
		ent.Owner = self.Entity;
		ent:SetPos(data.Pos);
		ent:Spawn();
		ent:Activate();
		ent:SetOwner(self.Entity);
		ent:Setup(data.Pos, ShootDir, 1200, 1.5, "Asgard");
	end
end

-----------------------------------FIRE ROCKET----------------------------------

function ENT:FireRocket(num)

	local Ratt = {
		"RR1",
		"RR2",
		"RR3",
		"RR4",
		"RR5",
		"RR6",
		"RR7",
		"RR8"
	}

	local Latt = {
		"RL1",
		"RL2",
		"RL3",
		"RL4",
		"RL5",
		"RL6",
		"RL7",
		"RL8"
	}

	local ent = NULL;

	local data = self:GetAttachment(self:LookupAttachment(Ratt[num]));
	if not (data and data.Pos and data.Ang) then return end


		ent = ents.Create("302missile");
		ent.Parent = self;
		ent:SetPos(data.Pos-self:GetUp()*50);
		ent:SetAngles(data.Ang);
		ent:Spawn();
		ent:Activate();
		ent:SetVelocity(Vector(0,0,1)*self.MissileMaxVel);
		--ent.Owner = self.Entity;
		ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
		ent:SetOwner(self.Entity);
		-- self.Rocket[i] = ent;
		-- timer.Simple( 1, function() HitTarget end)



	local data = self:GetAttachment(self:LookupAttachment(Latt[num]));
	if not (data and data.Pos and data.Ang) then return end


		ent = ents.Create("302missile");
		ent.Parent = self;
		ent:SetPos(data.Pos-self:GetUp()*50);
		ent:SetAngles(data.Ang);
		ent:Spawn();
		ent:Activate();
		ent:SetVelocity(Vector(0,0,1)*self.MissileMaxVel);
		--ent.Owner = self.Entity;
		ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
		ent:SetOwner(self.Entity);
		-- self.Rocket[i] = ent;
		-- timer.Simple( 1, function() HitTarget end)


end

-- function HitTarget()
	-- for i=1,2 do
		-- self.Rocket[i]:SetVelocity(self.RocketTarget:GetNormal()*self.MissileMaxVel);
	-- end
-- end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	-- if ((self.Beam == true) and (self.Pressed == false)) then
		-- self.Transporter:Teleport(self.Owner:GetPos(), self.Ring[1]:GetPos()+Vector(0,0,50));
		-- PrintMessage( HUD_PRINTTALK, "Beamed "..tostring(self.Owner:GetName()).." on Daedalus." )
		-- self.Beam = false;
	-- end

	if (self.Active and IsValid(self.Driver)) then

		-- self:SetNWInt("Hull",math.Round(self.Hull/200));
		-- self:SetNWInt("Shield",math.Round(self.Strength));
		-- self:SetNWInt("Power",100);
		-- self:SetNWInt("Hangar",0);
		-- self:SetNWInt("PowerSource",self.ZPMPlugged);
		-- self:SetNWInt("ShieldStatus",self.ShieldsEnable);
		-- self:SetNWInt("Hyperdrive",0);

		if (self.Driver:KeyDown(IN_USE)) then self.Entity:Exit(); return end

		if  (self.Driver:KeyDown(IN_RELOAD) and self.Pressed == false) then
				if (self.TargetMode == 0) then self.TargetMode = 1;
				elseif (self.TargetMode == 1) then self.TargetMode = 2;
				else self.TargetMode = 0; end
				self.Pressed = true;
				self:SetNWInt("ViewMode",self.TargetMode);
		end

		-- for i=1,6 do
			-- self.Railgun[i]:TriggerInput("Fire",0);
			-- self.AsgardBeam[i]:TriggerInput("Fire",0);
		-- end

		if (self.TargetMode == 1) then

			self.Driver:SetPos(self.Entity:GetPos()-self.Entity:GetUp()*500);

			local trace = {}
				trace.start = self.Driver:GetPos();
				trace.endpos = self.Driver:GetAimVector() * 10^14;
				trace.filter = {self.Entity, self.Driver};
			local tr = util.TraceLine( trace );

			if self.Driver:KeyDown(IN_ATTACK2) then self:FireAsgard(tr.HitPos) end
			if (self.Driver:KeyDown(IN_ATTACK)) then self:FireRailgun() end

			self:AimRailgun(tr.HitPos);




			-- self.Entity:FireRailgun(tr.HitPos, left);
	    -- self.Entity:FireAsgard(tr.HitPos, right);
			--[[
			local both = 0;
			if (left == 1 and right == 1) then both = 1; end
			if (self.Fired == false) then
				self.Entity:FireRocket(tr.HitPos, both); self.Fired = true;
				timer.Simple( 5, function() self.Fired = false end)
				self.RocketTarget = tr.HitPos;
			end ]]--

		elseif (self.TargetMode == 2) then

			self.Driver:SetPos(self.Entity:GetPos()+self.Entity:GetUp()*1000);


			local trace = {}
				trace.start = self.Driver:GetPos();
				trace.endpos = self.Driver:GetAimVector() * 10^14;
				trace.filter = {self.Entity, self.Driver};
			local tr = util.TraceLine( trace );

			if self.Driver:KeyDown(IN_ATTACK2) then self:FireAsgard(tr.HitPos) end
			if (self.Driver:KeyDown(IN_ATTACK)) then self:FireRailgun() end

			self:AimRailgun(tr.HitPos);
			-- local trace = {}
				-- trace.start = self.Entity:GetPos()+self.Entity:GetUp()*1000;
				-- trace.endpos = self.Driver:GetAimVector() * 10^14;
				-- trace.filter = {self.Entity, self.Driver};
			-- local tr = util.TraceLine( trace );

			-- local left = 0;
			-- local right = 0;
			-- if (self.Driver:KeyDown(IN_ATTACK)) then left = 1; end
			-- if self.Driver:KeyDown(IN_ATTACK2) then right = 1; end

			-- self.Entity:FireRailgun(tr.HitPos, left);
	    -- self.Entity:FireAsgard(tr.HitPos, right);
	else

			self.Driver:SetPos(self.Entity:GetPos());
		end

		if (self.Pressed == true) then timer.Simple( 1, function() self.Pressed = false end) end

	end

	self.Entity:NextThink( CurTime() + 0.1 )
	return true
end

concommand.Add("Daedalus_FireRocket",function(ply,cmd,args)
	local self = Entity( args[1] );
	if (IsValid(self)) then
		self:FireRocket(tonumber(args[2]));
	end
end);

-----------------------------------PHYSIC----------------------------------

function ENT:PhysicsSimulate( phys, deltatime )

	if (self.Active and IsValid(self.Driver) and (self.TargetMode == 0)) then

		local FWD = self.Entity:GetForward();

		local speed = 0;
		local up = 0;
		local acc = 10;

		if (self.Driver:KeyDown(IN_FORWARD)) then speed = 2000;
		elseif (self.Driver:KeyDown(IN_BACK)) then speed = -500; end
		if (self.Driver:KeyDown(IN_JUMP)) then speed = 3000; acc = 40; end
		self.Forw=math.Approach(self.Forw,speed,acc);

		if (self.Driver:KeyDown(IN_SPEED)) then up = 200;
		elseif (self.Driver:KeyDown(IN_DUCK)) then up = -200; end
		self.GoUp=math.Approach(self.GoUp,up,10);

		if (self.Driver:KeyDown(IN_FORWARD) or self.Driver:KeyDown(IN_BACK) or self.Driver:KeyDown(IN_JUMP)) then
			local aim = self.Driver:GetAimVector();
			local ang = aim:Angle();
			self.Angles.Pitch = math.ApproachAngle(self.Angles.Pitch,ang.Pitch,0.5);
			self.Angles.Yaw = math.ApproachAngle(self.Angles.Yaw,ang.Yaw,0.5);
		elseif (self.Driver:KeyDown(IN_MOVELEFT)) then self.Angles.Yaw = self.Angles.Yaw + 0.5;
		elseif (self.Driver:KeyDown(IN_MOVERIGHT)) then self.Angles.Yaw = self.Angles.Yaw - 0.5; end

		local velocity = self:GetVelocity();
		if (up != 0) then velocity.z = 0; end

		-- local Sublight = math.Round(velocity:Length()/19.3);

		-- if (self.Forw < -5) then self:SetNWInt("Sublight",-10);
		-- else self:SetNWInt("Sublight",Sublight); end


		local AerodynamicRoll = self.Entity:GetAngles().Yaw - self.LastYaw;
		local max = math.Clamp((velocity:Length()/40),0,60);
		local oldRoll = self.Angles.Roll;
		self.Angles.Roll =  -1*AerodynamicRoll*max + self.KeyRoll;
		if (self.Angles.Roll!=self.Angles.Roll) then self.Angles.Roll = oldRoll; end -- fix for nan values what cause despawing/crash.

		self.LastYaw = self.Entity:GetAngles().Yaw;
		self.HoverPos = self.Entity:GetPos();
		self.FlightPhys.pos = self:GetPos()+(FWD*self.Forw) + Vector(0,0,self.GoUp);

	else
		self.FlightPhys.pos = self.HoverPos;
	end

	self.FlightPhys.angle = self.Angles;
	self.FlightPhys.deltatime = deltatime;

	phys:Wake();
	phys:ComputeShadowControl(self.FlightPhys);

end

-----------------------------------OTHER----------------------------------

function ENT:OnRemove()
	if (self.Active) then self.Entity:Exit(); end
	self:Remove();
end

-- function ENT:OnTakeDamage(dmg)
	-- self.Hull = self.Hull - dmg:GetDamage()/5;
	-- if (self.Hull < 0) then self.Entity:Detonate();
	-- elseif (self.Hull < 1000) then self.ShieldsEnable = false;
	-- elseif (self.Hull < 2000) then self.AsgardBeamEnable = false;
	-- elseif (self.Hull < 4000) then self.RailgunEnable = false;
	-- elseif (self.Hull < 4000) then self.RocketEnable = false;
	-- elseif (self.Hull < 5000) then self.TransporterEnable = false; end
-- end


-- function ENT:Detonate()
	-- local ang = Angle(math.Rand(115,255), math.random(0,360), 0)
	-- local fx = EffectData()
		-- fx:SetMagnitude(100)
		-- fx:SetAngles(ang)
		-- fx:SetOrigin(self.Entity:GetPos())
	-- util.Effect( "Gate_Nuke_Explosion", fx)

   -- if (self.Active) then self.Entity:Exit(); end
   -- self.Entity:Remove()
-- end

-----------------------------------USE/ENTER----------------------------------

function ENT:Use(ply,caller)
	self.Entity:SetUseType(SIMPLE_USE);
	if (not self.Active) then
		self.Active = true;
		self.Driver = ply;
		self.Driver:SetPos(self.Entity:GetPos());
		--self.Driver:SetScriptedVehicle(self);
		self.Driver:SetNetworkedEntity("ScriptedVehicle", self)
		self.Driver:SetViewEntity(self)
		-- Garry broke this function
		/*if(not(game.SinglePlayer())) then
			self.Driver:SetClientsideVehicle(self);
		end*/
		self.Driver:SetMoveType(MOVETYPE_OBSERVER);
		self.Driver:DrawViewModel(false);
		self.Driver:DrawWorldModel(false);
		self.Driver:Spectate( OBS_MODE_CHASE );
		for k,v in pairs(self.Driver:GetWeapons()) do
			table.insert(self.weps, v:GetClass());
		end
		self.Driver:StripWeapons();
		--self.Driver:SetParent(self.Entity);
		self.Driver:SetNetworkedEntity("Daedalus",self);
	end
	self.Entity:NextThink( CurTime() + 0.5 );
end

-----------------------------------EXIT----------------------------------

function ENT:Exit()
	self.Active = false;
	if (not IsValid(self.Driver)) then return end
	self.Driver:UnSpectate();
	self.Driver:DrawViewModel(true);
	self.Driver:DrawWorldModel(true);
	self.Driver:SetMoveType(MOVETYPE_VPHYSICS);
	self.Driver:Spawn();
	for k,v in pairs(self.weps) do
		self.Driver:Give(tostring(v));
	end
	-- if (self.Entity and self.Entity:IsValid()) then
		-- self.Driver:SetPos(self.Ring[1]:GetPos()+Vector(0,0,50));
		-- self.Ring[1]:Dial("BC304DOWN");
	-- else
		-- self.Driver:SetPos(self.Driver:GetPos());
	-- end
	self.Driver:SetParent();
	--self.Driver:SetScriptedVehicle(NULL);
	self.Driver:SetNetworkedEntity( "ScriptedVehicle", NULL )
	self.Driver:SetViewEntity( NULL )
	-- Garry broke this function
	/*if(not(game.SinglePlayer())) then
		self.Driver:SetClientsideVehicle(NULL);
	end*/
	self.Driver:SetNetworkedEntity("Daedalus",NULL);
	self.Driver = NULL;

end


-- concommand.Add("Daedalus_shields", function(ply,cmd,n)
	-- local shut = ply:GetNetworkedEntity("Daedalus")
	-- if (shut.Active) then
		---shut.AsgardBeamEnable = !shut.AsgardBeamEnable;
	-- end
-- end)

-- concommand.Add("Daedalus_asgard", function(ply,cmd,n)
	-- local shut = ply:GetNetworkedEntity("Daedalus")
	-- if (shut.Active) then
		-- shut.AsgardBeamEnable = !shut.AsgardBeamEnable;
	-- end
-- end)

-- concommand.Add("Daedalus_railguns", function(ply,cmd,n)
	-- local shut = ply:GetNetworkedEntity("Daedalus")
	-- if (shut.Active) then
		-- shut.RailgunEnable = !shut.RailgunEnable;
	-- end
-- end)

-- concommand.Add("Daedalus_rockets", function(ply,cmd,n)
	-- local shut = ply:GetNetworkedEntity("Daedalus")
	-- if (shut.Active) then
		-- shut.RocketEnable = !shut.RocketEnable;
	-- end
-- end)

-- concommand.Add("Daedalus_beam", function(ply,cmd,n)
	-- local shut = ply:GetNetworkedEntity("DaedalusOutside")
	-- shut.Beam = true;
-- end)

-- concommand.Add("Daedalus_resetpitch", function(ply,cmd,n)
	-- local shut = ply:GetNetworkedEntity("Daedalus")
	-- if (shut.Active) then
		-- shut.Angles.Pitch = 0;
		-- shut.Driver:SetEyeAngles(shut.Angles);
	-- end
-- end)




		--PrintMessage( HUD_PRINTTALK, ""..tostring() )

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_ships_max"):GetInt()
		if(ply:GetCount("CAP_ships")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Ships limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			Ent:Remove();
			return
		end
		ply:AddCount("CAP_ships", Ent);
	end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_vehicle_daedalus", StarGate.CAP_GmodDuplicator, "Data" )
end

--################# After teleporting it, fix the angles of a player @aVoN
function ENT.FixAngles(self,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
	-- Move a players view
	local diff = Angle(0,ang_delta.y+180,0);
	if(IsValid(self.Driver)) then
		self.Driver:SetEyeAngles(self.Driver:GetAimVector():Angle() + diff);
	end
end
StarGate.Teleport:Add("sg_vehicle_daedalus",ENT.FixAngles);