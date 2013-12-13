--[[
	SG Turret Base
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Stargate Turret Base"
ENT.Author = ""
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack: Weapons"
ENT.WireDebugName = "Stargate Turret Base"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.AutomaticFrameAdvance = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile()

-----------------------------------INITIALIZE----------------------------------

function ENT:Initialize()

	self.Entity:SetName(self.PrintName);
	self.Entity:SetModel(self.BaseModel);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:StartMotionController();

	if (WireAddon) then
		self.Inputs = WireLib.CreateInputs( self.Entity, {"Fire [NORMAL]", "Active [NORMAL]", "Vector [VECTOR]", "Entity [ENTITY]"});
	end

	self.Yaw = 0;
	self.Pitch = -25;

	self.APC = NULL;
	self.APCply = NULL;
	self.WireActive = nil;
	self.WireShoot = nil;
	self.WireEnt = nil;
	self.Target = Vector();

	self:AddResource("energy",self.energy_setup);

	self.ShootingCann = 1;
	self.CanFire = true;
	self.SoundTime = CurTime()+self.SoundDur;

	self.Stand = self.Entity;
	local phys = self.Stand:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableMotion(false);
	end

	self.Duped = false;

	--self:SpawnRest();
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnRest()
	local ang = self.Entity:GetAngles();

	local pos1 = self.Stand:LocalToWorld(self.TurnPos);

	local ent = ents.Create("sg_turret_part");
	ent:SetModel(self.TurnModel);
	ent:SetPos(pos1);
	ent:SetAngles(ang);
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	local turnaxis = constraint.Axis(ent, self.Stand, 0, 0,  Vector(0,0,0), Vector(0,0,10), 0, 0, 1000, 1)
	turnaxis:SetParent(self.Stand)
	self.Turn = ent;

	local pos2 = self.Turn:LocalToWorld(self.BarrelPos);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModel);
	ent:SetPos(pos2);
	ent:SetAngles(ang);
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	local cannaxis = constraint.Axis(ent, self.Turn, 0, 0,  ent:GetRight(), ent:GetRight(), 0, 0, 1000, 1)
	cannaxis:SetParent(self.Stand)
	self.Cann = ent;
	constraint.NoCollide(self.Turn,self.Stand,0,0)
	constraint.NoCollide(self.Stand,self.Cann,0,0)
	constraint.NoCollide(self.Turn,self.Cann,0,0)

end

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex();
	end

	if IsValid(self.Turn) then
		dupeInfo.Turn = self.Turn:EntIndex();
	end

	if IsValid(self.Cann) then
		dupeInfo.Cann = self.Cann:EntIndex();
	end

	duplicator.StoreEntityModifier(self, "SGTurrBaseDupe", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self)
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods["SGTurrBaseDupe"] or {}

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if dupeInfo.Turn then
		self.Turn = CreatedEntities[ dupeInfo.Turn ]
		self.Turn.Parent = self.Entity;
	end

	if dupeInfo.Cann then
		self.Cann = CreatedEntities[ dupeInfo.Cann ]
		self.Cann.Parent = self.Entity;
	end

	self.Stand = self.Entity;
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

-----------------------------------DIFFERENT CRAP----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Vector") then self.WireVec = value;
	elseif (variable == "Entity") then self.WireEnt = value;
	elseif (variable == "Fire") then self.WireShoot = value;
	elseif (variable == "Active") then self.WireActive = value;	end
end

function ENT:StartTouch( ent )
	if IsValid(ent) and ent:IsVehicle() then
		if (self.APC != ent) then
			local ed = EffectData()
				ed:SetEntity( ent )
			util.Effect( "old_propspawn", ed, true, true )
		end
		self.APC = ent;
	end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	if (not self.Duped) then return end

	// abort, if no valid parts!
	if not (IsValid(self.Stand) and IsValid(self.Turn) and IsValid(self.Cann)) then
		self.Entity:OnRemove();
		return
	end

	self.StandPhys = self.Stand:GetPhysicsObject();
	self.TurnPhys = self.Turn:GetPhysicsObject();
	self.CannPhys = self.Cann:GetPhysicsObject();

	if not (IsValid(self.StandPhys) and IsValid(self.TurnPhys) and IsValid(self.TurnPhys)) then return end

	//physics can be frozen but cannot sleep!!
	self.TurnPhys:Wake();
	self.StandPhys:Wake();
	self.CannPhys:Wake();

	// get player in the chair

	if IsValid(self.APC) then
		self.APCply = self.APC:GetPassenger(0)
		if IsValid(self.APCply) then
			self.APCply:CrosshairEnable();
		end
	else
		self.APC = NULL;
		self.APCply = NULL;
	end

end

------------------------------PHYSIC----------------------------------

function ENT:PhysicsUpdate( phys, deltatime )

	if (not self.Duped) then return end

	// abort, if no valid parts!
	if not (IsValid(self.Stand) and IsValid(self.Turn) and IsValid(self.Cann)) then
		self.Entity:OnRemove();
		return
	end
	if not (IsValid(self.StandPhys) and IsValid(self.TurnPhys) and IsValid(self.CannPhys)) then return end

	// calculate new angles for parts
	local newpitch = math.Clamp(self.Pitch, self.DownClamp, self.UpClamp);
	local CannAng = self.Stand:LocalToWorldAngles(Angle(newpitch ,self.Yaw,0));
	local TurnAng = self.Stand:LocalToWorldAngles(Angle(0,self.Yaw,0));

	self.Turn:SetAngles(TurnAng);
	self.Cann:SetAngles(CannAng);

	// find a target
	local TargetPos = nil;

	if IsValid(self.APCply) then
		TargetPos = self.APCply:GetEyeTrace().HitPos;

		if self.APCply:KeyDown( IN_ATTACK ) then
			if self.CanFire then self.Entity:Shoot() end
		end
	elseif (self.WireActive == 1) then
		if (self.WireShoot == 1) then
			if self.CanFire then self.Entity:Shoot() end
		end

		if (self.WireEnt and self.WireEnt:IsValid()) then
			TargetPos = self.WireEnt:LocalToWorld(self.WireEnt:OBBCenter())
		elseif (self.WireVec) then
			TargetPos = self.WireVec;
		end
	end

	// calculate local angles for target
	if TargetPos then
		local world_oob = self.Cann:LocalToWorld(self.Cann:OBBCenter());
		local ShootAngle = (TargetPos - world_oob):Angle();
		ShootAngle = self.Stand:WorldToLocalAngles(ShootAngle);

		local new_p = math.NormalizeAngle(ShootAngle.Pitch);
		local new_y = math.NormalizeAngle(ShootAngle.Yaw);

		if (self.Pitch != new_p or self.Yaw != new_y) then
			 if CurTime() > self.SoundTime then
				self.SoundTime = CurTime()+self.SoundDur;
				--self.Entity:EmitSound(Sound(self.Sounds.Move),100,100); missed file
			end
		end

		self.Pitch = math.ApproachAngle(self.Pitch, new_p, self.Speed);
		self.Yaw = math.ApproachAngle(self.Yaw, new_y, self.Speed);
	end

end

end