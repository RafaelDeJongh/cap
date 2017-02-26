--[[
	Destiny Middle Turret
	Copyright (C) 2010 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Medium Turret"
ENT.Author = "Madman07, Rafael De Jongh"
ENT.Instructions= "Kill the blue Aliens!"
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack: Weapons"
ENT.WireDebugName = ENT.PrintName

list.Set("CAP.Entity", ENT.PrintName, ENT);

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile()

ENT.Sounds={
	Shoot=Sound("weapons/dest_single.wav"),
	Move=Sound("weapons/turret_move_loop.wav"),
}
ENT.SoundDur = 0.2;

ENT.BaseModel = "models/Madman07/middle_cannon/middle_stand.mdl";
ENT.TurnModel = "models/Madman07/middle_cannon/middle_turn.mdl";
ENT.TurnPos = Vector(0,0,4.75);

ENT.BarrelModel = "models/Madman07/middle_cannon/middle_cann.mdl";

ENT.BarrelPos = {
	Vector(0,20,20),
	Vector(0,0,32),
	Vector(0,-20,20)
}

ENT.DownClamp = -35;
ENT.UpClamp = -10;
ENT.Speed = 0.5;

ENT.energy_drain = 400;
ENT.energy_setup = 800;

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
	self.Target = Vector(1,1,1);
	self.ShootingCann = 1;

	self:AddResource("energy",self.energy_setup);

	self.ShootingCann = 1;
	self.CanFire = true;
	self.SoundTime = CurTime()+self.SoundDur;

	self.Stand = self.Entity;
	local phys = self.Stand:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableMotion(false);
	end

	--self:SpawnRest();
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_destmedium_max"):GetInt()
		if(ply:GetCount("CAP_destmedium")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_dest_med\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return
		end
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = ang.y % 360

	local ent = ents.Create("sg_turret_destmed");
	ent:SetPos(tr.HitPos);
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();

	if (IsValid(ply)) then
		ply:AddCount("CAP_destmedium", ent)
	end
	ent:SpawnRest(ply);
	ent.Duped = true;
	return ent
end

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex();
	end

	if IsValid(self.Turn) then
		dupeInfo.Turn = self.Turn:EntIndex();
	end

	if IsValid(self.Cann1) then
		dupeInfo.Cann1 = self.Cann1:EntIndex();
	end

	if IsValid(self.Cann2) then
		dupeInfo.Cann2 = self.Cann2:EntIndex();
	end

	if IsValid(self.Cann3) then
		dupeInfo.Cann3 = self.Cann3:EntIndex();
	end

	duplicator.StoreEntityModifier(self, "SGTurrBaseDupe", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self)
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	local dupeInfo = Ent.EntityMods["SGTurrBaseDupe"] or {}

	if dupeInfo.Turn then
		self.Turn = CreatedEntities[ dupeInfo.Turn ]
		self.Turn.Parent = self.Entity;
	end

	if dupeInfo.Cann1 then
		self.Cann1 = CreatedEntities[ dupeInfo.Cann1 ]
		self.Cann1.Parent = self.Entity;
	end

	if dupeInfo.Cann2 then
		self.Cann2 = CreatedEntities[ dupeInfo.Cann2 ]
		self.Cann2.Parent = self.Entity;
	end

	if dupeInfo.Cann3 then
		self.Cann3 = CreatedEntities[ dupeInfo.Cann3 ]
		self.Cann3.Parent = self.Entity;
	end

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.Stand = self.Entity;
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_destmedium_max"):GetInt()
		if(ply:GetCount("CAP_destmedium_max")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_dest_med\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("CAP_destmedium", self.Entity)
	end
	self.Duped = true;
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_turret_destmed", StarGate.CAP_GmodDuplicator, "Data" )
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnRest(p)
	local ang = self.Entity:GetAngles();

	local pos = self.Stand:LocalToWorld(self.TurnPos);
	local ent = ents.Create("sg_turret_part");
	ent:SetModel(self.TurnModel);
	ent:SetPos(pos);
	ent:SetAngles(ang);
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	local turnaxis = constraint.Axis(ent, self.Stand, 0, 0,  Vector(0,0,0), Vector(0,0,10), 0, 0, 1000, 1)
	turnaxis:SetParent(self.Stand)
	self.Turn = ent;

	pos = self.Turn:LocalToWorld(self.BarrelPos[1]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModel);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	local cann1axis = constraint.Axis(ent, self.Turn, 0, 0,  Vector(-10,70,0), Vector(10,70,0), 0, 0, 1000, 1)
	cann1axis:SetParent(self.Stand)
	self.Cann1 = ent;

	pos = self.Turn:LocalToWorld(self.BarrelPos[2]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModel);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	local cann2axis = constraint.Axis(ent, self.Turn, 0, 0,  Vector(-10,60,0), Vector(10,60,0), 0, 0, 1000, 1)
	cann2axis:SetParent(self.Stand)
	self.Cann2 = ent;

	pos = self.Turn:LocalToWorld(self.BarrelPos[3]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModel);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	local cann3axis = constraint.Axis(ent, self.Turn, 0, 0,  Vector(-10,70,0), Vector(10,70,0), 0, 0, 1000, 1)
	cann3axis:SetParent(self.Stand)
	self.Cann3 = ent;
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


function ENT:OnRemove()
	if IsValid(self.Stand) then self.Stand:Remove(); end
	if IsValid(self.Turn) then self.Turn:Remove(); end
	if IsValid(self.Cann1) then self.Cann1:Remove(); end
	if IsValid(self.Cann2) then self.Cann2:Remove(); end
	if IsValid(self.Cann3) then self.Cann3:Remove(); end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	if (not self.Duped) then return end

	// abort, if no valid parts!
	if not (IsValid(self.Stand) and IsValid(self.Turn) and IsValid(self.Cann1) and IsValid(self.Cann2) and IsValid(self.Cann3)) then
		self.Entity:OnRemove();
		return
	end

	self.StandPhys = self.Stand:GetPhysicsObject();
	self.TurnPhys = self.Turn:GetPhysicsObject();
	self.CannPhys1 = self.Cann1:GetPhysicsObject();
	self.CannPhys2 = self.Cann2:GetPhysicsObject();
	self.CannPhys3 = self.Cann3:GetPhysicsObject();

	if not (IsValid(self.StandPhys) and IsValid(self.TurnPhys) and IsValid(self.CannPhys1) and IsValid(self.CannPhys2) and IsValid(self.CannPhys3)) then return end

	//physics can be frozen but cannot sleep!!
	self.TurnPhys:Wake();
	self.StandPhys:Wake();
	self.CannPhys1:Wake();
	self.CannPhys2:Wake();
	self.CannPhys3:Wake();

	// get player in the chair
	if IsValid(self.APC) then
		self.APCply = self.APC:GetPassenger(0)
		if IsValid(self.APCply) then
			self.APCply:CrosshairEnable();
		end
	end

end

------------------------------PHYSIC----------------------------------

function ENT:PhysicsUpdate( phys, deltatime )

	if (not self.Duped) then return end

	// abort, if no valid parts!
	if not (IsValid(self.Stand) and IsValid(self.Turn) and IsValid(self.Cann1) and IsValid(self.Cann2) and IsValid(self.Cann3)) then
		self.Entity:OnRemove();
		return
	end
	if not (IsValid(self.StandPhys) and IsValid(self.TurnPhys) and IsValid(self.CannPhys1) and IsValid(self.CannPhys2) and IsValid(self.CannPhys3)) then return end

	// calculate new angles for parts
	local newpitch = math.Clamp(self.Pitch, self.DownClamp, self.UpClamp);
	local CannAng = self.Stand:LocalToWorldAngles(Angle(-newpitch, 180+self.Yaw,0));
	local TurnAng = self.Stand:LocalToWorldAngles(Angle(0,self.Yaw,0));

	self.Turn:SetAngles(TurnAng);
	self.Cann1:SetAngles(CannAng);
	self.Cann2:SetAngles(CannAng);
	self.Cann3:SetAngles(CannAng);

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
		local world_oob = self.Cann2:LocalToWorld(self.Cann2:OBBCenter());
		local ShootAngle = (TargetPos - world_oob):Angle();
		ShootAngle = self.Stand:WorldToLocalAngles(ShootAngle);

		local new_p = math.NormalizeAngle(ShootAngle.Pitch);
		local new_y = math.NormalizeAngle(ShootAngle.Yaw);

		if (self.Pitch != new_p or self.Yaw != new_y) then
			 if CurTime() > self.SoundTime then
				self.SoundTime = CurTime()+self.SoundDur;
				--self.Entity:EmitSound(Sound(self.Sounds.Move),100,100);
			end
		end

		self.Pitch = math.ApproachAngle(self.Pitch, new_p, self.Speed);
		self.Yaw = math.ApproachAngle(self.Yaw, new_y, self.Speed);
	end

end

-----------------------------------SHOOT----------------------------------

function ENT:Shoot()

	local energy = self:GetResource("energy",self.energy_drain);

	if(energy > self.energy_drain or !self.HasResourceDistribution) then

		self:ConsumeResource("energy",self.energy_drain);

		local cannons = {self.Cann1, self.Cann2, self.Cann3};
		local cann = cannons[self.ShootingCann];

		if not IsValid(cann) then return end
		self.CanFire = false;
		cann:DoAnim(1, "fire");

		local data = cann:GetAttachment(cann:LookupAttachment("FIRE"))
		if(not (data and data.Pos)) then return end

		local fx = EffectData();
		fx:SetAngles(Angle(255,255,math.random(75,125)));
		fx:SetNormal(-1*cann:GetForward());
		fx:SetOrigin(data.Pos);
		util.Effect("Destiny_launch",fx);

		local e = ents.Create("energy_pulse");
		e:PrepareBullet(-1*cann:GetForward(), 10, 12000, 15, {self.Cann1, self.Cann2, self.Cann3, self.Turn, self.Stand});
		e:SetPos(data.Pos);
		e:SetOwner(self);
		e.Owner = self;
		e:Spawn();
		e:Activate();
		e:SetColor(Color(255,255,math.random(75,125),255));

		cann:EmitSound(self.Sounds.Shoot,100,math.random(95,105));
		util.ScreenShake(data.Pos,2,2.5,1,1000);

		self.ShootingCann = self.ShootingCann + 1;
		if (self.ShootingCann == 4) then self.ShootingCann = 1; end

		timer.Simple( math.random(10,16)/10, function() self.CanFire = true end);

	end

end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_weapon_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_dest_med");
end

end