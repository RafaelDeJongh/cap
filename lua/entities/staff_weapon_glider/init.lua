/*
	Staff Weapon for GarrysMod10
	Copyright (C) 2007  aVoN

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
--################### Head
if (not StarGate.CheckModule("ship")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--################### Init @aVoN
function ENT:Initialize()
	--self.Entity:SetModel("models/props_combine/combine_binocular01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Shots = {};
	self.NextFire = 0;
	self.fire = false;
	self.ShootDirection = 1; -- Necessary for the Model part because the old model "combine_binocular01.mdl" is turned upside down by 180 degree (needs -1), other models are normal (need 1)
	self.energy_drain = StarGate.CFG:Get("staff_stationary","energy_per_shot",100);
	self.Delay = StarGate.CFG:Get("staff_stationary","delay",0.3);
	self.DirectionVector = Vector(0,0,0);
	self.TargetVector = Vector(0,0,0);
	self.DirectionVectorAngleOffset = 0.5 -- Equals 60°
	self:AddResource("energy",100);
	self:CreateWireInputs("Fire","Distance","Explode","Dir_X","Dir_Y","Dir_Z","X","Y","Z");
	self:CreateWireOutputs("Can Fire","Shots Remaining");
	self.Color = self.Color or Color(math.random(230,255),200,120,255);
	self.Phys = self.Entity:GetPhysicsObject();
	if(self.Phys:IsValid()) then
		self.Phys:Wake();
		self.Phys:SetMass(10);
	end
end

--################### Spawning the SENT in the SENT Tab @aVoN
function ENT:SpawnFunction(p,t)
	if(not t.Hit) then return end
	local SpawnPos = t.HitPos+t.HitNormal*60;
	local e = ents.Create("staff_weapon_glider");
	e:SetVar("Owner",p); -- To get kills
	e:SetPos(SpawnPos);
	e:Spawn();
	e:Activate();
	return e;
end

--################### Adds one of those annoying speechbubbles to the staff-weapon @aVoN
function ENT:UpdateOverlayText()
	local shots = "";
	if(self.HasResourceDistribution) then
		shots = "\nShots: "..math.floor((tonumber(self:GetResource("energy")) or 0)/self.energy_drain);
	end
	local add = "";
	if(self.fire) then add = "(On)" end;
	self:SetOverlayText("Staff Weapon "..add..""..shots);
end

--################### Fire! @aVoN
function ENT:FireWeapon()
	local energy = self:GetResource("energy",self.energy_drain);
	if(energy < self.energy_drain) then return end;
	self:ConsumeResource("energy",self.energy_drain);
	-- ####### Shooting Effects
	self.Entity:EmitSound(Sound("pulse_weapon/staff_weapon.mp3"),90,math.random(90,110));
	local vel = self.Entity:GetVelocity();
	local up = self.Entity:GetUp()*self.ShootDirection;
	-- I know, a bit much, but otherwise the shot can collide with your vehicle and explode which sucks
	local pos = self.Entity:GetPos()+StarGate.VelocityOffset({Velocity=vel,Direction=up,BoundingMax=self.Entity:OBBMaxs().z});
	-- Check, if we have manual direction-vector input
	local wire_dir = self.DirectionVector:GetNormal();
	local override_dir;
	if(wire_dir ~= Vector(0,0,0)) then
		override_dir = wire_dir;
	elseif(self.TargetVector ~= Vector(0,0,0)) then
		override_dir = (self.TargetVector-self.Entity:GetPos()):GetNormalized();
	end
	if(override_dir and up:DotProduct(override_dir) >= self.DirectionVectorAngleOffset) then
		-- Ok, that direction is valid - But when anything is blocking the way (parts of a ship???) it may destroy the contraption- So add an Anti-Dumb-Player-Destroying-Their-Own-Ship code
		local trace = util.QuickTrace(pos,override_dir*150,self.Entity);
		if(not trace.Hit) then
			up = override_dir;
		end
	end
	-- Muzzle
	local fx = EffectData();
	fx:SetScale(1);
	fx:SetOrigin(self.Entity:GetPos());
	fx:SetEntity(self.Entity);
	fx:SetAngles(Angle(self.Color.r,self.Color.g,self.Color.b));
	util.Effect("energy_muzzle",fx,true,true);
	-- ######################## The shot
	local e = ents.Create("energy_pulse");
	e:PrepareBullet(up, 10, 12000, 10, {self.Entity});
	e:SetPos(self.Entity:GetPos());
	e:SetOwner(self);
	e.Owner = self;
	e:Spawn();
	e:Activate();
	e:SetColor(Color(self.Color.r, self.Color.g, self.Color.b,255));
	self.NextFire = CurTime()+self.Delay;
	self.Shots[e] = true;
	self:UpdateOverlayText();
	-- ####### Next shots - And handle wire
	self:SetWire("Can Fire",0);
	self:SetWire("Shots Remaining",math.floor((energy/self.energy_drain)-1));
end

--################### Continous fireing? @aVoN
function ENT:Think()
	local shots_left = math.floor(self:GetResource("energy",self.energy_drain)/self.energy_drain);
	self:SetWire("Shots Remaining",shots_left);
	self:SetWire("Can Fire",util.tobool(shots_left));
	if(self.fire and self.NextFire <= CurTime()) then
		self:FireWeapon();
		self:UpdateOverlayText();
	elseif((self.LastOverlayCheck or 0)+1 <= CurTime()) then
		self.LastOverlayCheck = CurTime();
		self:UpdateOverlayText();
	end
end

--################### Explode shots? @aVoN
function ENT:ExplodeShots()
	for k,_ in pairs(self.Shots) do
		if(IsValid(k)) then
			k:Explode();
		end
	end
end

--################### Wire Input @aVoN
function ENT:TriggerInput(k,v)
	if(k == "Fire") then
		self.fire = false;
		if(v == 1) then
			self.fire = true;
			if(self.NextFire <= CurTime()) then
				self:FireWeapon();
			end
		else
			self:UpdateOverlayText();
		end
	elseif(k == "Distance") then
		self.Distance = tonumber(v);
	elseif(k == "Explode" and v == 1) then
		self:ExplodeShots();
	elseif(k == "Dir_X") then
		self.DirectionVector.x = v;
	elseif(k == "Dir_Y") then
		self.DirectionVector.y = v;
	elseif(k == "Dir_Z") then
		self.DirectionVector.z = v;
	elseif(k == "X") then
		self.TargetVector.x = v;
	elseif(k == "Y") then
		self.TargetVector.y = v;
	elseif(k == "Z") then
		self.TargetVector.z = v;
	end
end

--#################  Shoot like hell! @aVoN
function ENT:Use(p)
	self:TriggerInput("Fire",1);
	local id = "StarGate.StaffWeapon"..self.Entity:EntIndex();
	local e = self.Entity;
	timer.Destroy(id);
	timer.Create(id,0.1,1,
		function()
			if(IsValid(e)) then self:TriggerInput("Fire",0) end;
		end
	);
end
