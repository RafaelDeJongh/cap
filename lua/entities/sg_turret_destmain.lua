--[[
	Destiny Main Weapon
	Copyright (C) 2010 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Main Weapon"
ENT.Author = "Madman07, Boba Fett"
ENT.Instructions= "Kill the blue Aliens!"
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack: Weapons"
ENT.WireDebugName = ENT.PrintName

list.Set("CAP.Entity", ENT.PrintName, ENT);

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile()

ENT.Sounds={
	Shoot=Sound("weapons/dest_main_cannon.wav"),
	Shoot2=Sound("weapons/dest_main_cannon2.wav"),
	Move=Sound("weapons/turret_move_loop.wav"),
}
ENT.SoundDur = 0.2;

ENT.BaseModel = "models/Madman07/main_weapon/main_stand.mdl";
ENT.TurnModel = "models/Madman07/main_weapon/main_turn.mdl";
ENT.TurnPos = Vector(0,0,17);

ENT.BarrelModel = {
	"models/Madman07/main_weapon/big_barrel.mdl",
	"models/Madman07/main_weapon/small_barrel.mdl",
}

ENT.BarrelModelLight = {
	"models/Madman07/main_weapon/big_barrel_light.mdl",
	"models/Madman07/main_weapon/small_barrel_light.mdl",
}

ENT.BarrelPos = {
	Vector(-20,-60,70),
	Vector(-20,0,70),
	Vector(-20,60,70),
	Vector(-20,0,144)
}

ENT.SpawnLight = true;

ENT.DownClamp = -20;
ENT.UpClamp = -0;
ENT.Speed = 0.2;

ENT.energy_drain = 4000;
ENT.energy_setup = 8000;

-----------------------------------INITIALISE----------------------------------

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
	self.Pitch = 0;
	self.Lights = {};

	self.APC = NULL;
	self.APCply = NULL;
	self.WireActive = nil;
	self.WireShoot = nil;
	self.WireEnt = nil;
	self.Target = Vector(1,1,1);

	self:AddResource("energy",self.energy_setup);

	self.ShootingCann = 1;
	self.CanFire = true;
	self.SoundTime = CurTime()+self.SoundDur;

	self.Stand = self.Entity;
	local phys = self.Stand:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableMotion(false);
		phys:SetMass(50000);
	end

	--self:SpawnRest();

	timer.Create(self.Entity:EntIndex().."Glow", 0, 0, function()
		for _,v in pairs(self.Lights) do
			if IsValid(v) then
				if v.Glow then
					local rel = (CurTime()-v.Time)*2;
					if (rel > 1) then
						rel = 2-rel;
						if (rel < 0) then
							rel = 0;
							v.Glow = false;
						end
					end
					v:SetColor(Color(255,255,255,rel*255));
				end
			end
		end
	end);

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_destmain_max"):GetInt();
	if(ply:GetCount("CAP_destmain")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_dest_main\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = ang.y % 360;

	local ent = ents.Create("sg_turret_destmain");
	ent:SetPos(tr.HitPos);
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply

	ply:AddCount("CAP_destmain", ent)
	ent.Owner = ply
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

	if IsValid(self.Cann4) then
		dupeInfo.Cann4 = self.Cann4:EntIndex();
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

	if dupeInfo.Cann4 then
		self.Cann4 = CreatedEntities[ dupeInfo.Cann4 ]
		self.Cann4.Parent = self.Entity;
	end

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.Stand = self.Entity;
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_destmain_max"):GetInt()
		if(ply:GetCount("CAP_destmain_max")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_dest_main\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:OnRemove();
			return
		end
		ply:AddCount("CAP_destmain_max", self.Entity)
	end
	self.Duped = true;
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_turret_destmain", StarGate.CAP_GmodDuplicator, "Data" )
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnRest(p)
	local ang = self.Entity:GetAngles();

	local pos = self.Stand:LocalToWorld(self.TurnPos);
	local ent = ents.Create("sg_turret_part");
	ent:SetModel(self.TurnModel);
	ent:SetPos(pos);
	ent:SetAngles(ang+Angle(0,180,0));
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	local turnaxis = constraint.Axis(ent, self.Stand, 0, 0,  Vector(0,0,0), Vector(0,0,10), 0, 0, 1000, 1)
	turnaxis:SetParent(self.Stand)
	self.Turn = ent;

	pos = self.Turn:LocalToWorld(self.BarrelPos[1]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModel[1]);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	local turnaxis = constraint.Axis(ent, self.Turn, 0, 0,  ent:GetRight()*10, ent:GetRight()*(-10), 0, 0, 1000, 1)
	turnaxis:SetParent(self.Turn)
	self.Cann1 = ent;

	pos = self.Turn:LocalToWorld(self.BarrelPos[2]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModel[1]);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	local turnaxis = constraint.Axis(ent, self.Turn, 0, 0,  ent:GetRight()*10, ent:GetRight()*(-10), 0, 0, 1000, 1)
	turnaxis:SetParent(self.Turn)
	self.Cann2 = ent;

	pos = self.Turn:LocalToWorld(self.BarrelPos[3]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModel[1]);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	local turnaxis = constraint.Axis(ent, self.Turn, 0, 0,  ent:GetRight()*10, ent:GetRight()*(-10), 0, 0, 1000, 1)
	turnaxis:SetParent(self.Turn)
	self.Cann3 = ent;

	pos = self.Turn:LocalToWorld(self.BarrelPos[4]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModel[2]);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent.Parent = self;
	ent:Spawn();
	ent:Activate();
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	local turnaxis = constraint.Axis(ent, self.Turn, 0, 0,  ent:GetRight()*10, ent:GetRight()*(-10), 0, 0, 1000, 1)
	turnaxis:SetParent(self.Turn)
	self.Cann4 = ent;

	---- lights

	pos = self.Turn:LocalToWorld(self.BarrelPos[1]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModelLight[1]);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent:SetNotSolid(true);
	ent:Spawn();
	ent:Activate();
	ent:SetParent(self.Cann1);
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent.Parent = self;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	self.Lights[1] = ent;
	ent.Glow = false;
	ent:SetColor(Color(255,255,255,0));

	pos = self.Turn:LocalToWorld(self.BarrelPos[2]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModelLight[1]);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent:SetNotSolid(true);
	ent:Spawn();
	ent:Activate();
	ent:SetParent(self.Cann2);
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent.Parent = self;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	self.Lights[2] = ent;
	ent.Glow = false;
	ent:SetColor(Color(255,255,255,0));

	pos = self.Turn:LocalToWorld(self.BarrelPos[3]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModelLight[1]);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent:SetNotSolid(true);
	ent:Spawn();
	ent:Activate();
	ent:SetParent(self.Cann3);
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent.Parent = self;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	self.Lights[3] = ent;
	ent.Glow = false;
	ent:SetColor(Color(255,255,255,0));

	pos = self.Turn:LocalToWorld(self.BarrelPos[4]);
	ent = ents.Create("sg_turret_part");
	ent:SetModel(self.BarrelModelLight[2]);
	ent:SetPos(pos);
	ent:SetAngles(ang-Angle(self.Pitch, 180, 0));
	ent:SetNotSolid(true);
	ent:Spawn();
	ent:Activate();
	ent:SetParent(self.Cann4);
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent.Parent = self;
	if CPPI and IsValid(p) and ent.CPPISetOwner then ent:CPPISetOwner(p) end
	self.Lights[4] = ent;
	ent.Glow = false;
	ent:SetColor(Color(255,255,255,0));
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

	if timer.Exists(self.Entity:EntIndex().."Glow") then timer.Destroy(self.Entity:EntIndex().."Glow") end
	if timer.Exists(self.Entity:EntIndex().."Shoot") then timer.Destroy(self.Entity:EntIndex().."Shoot") end
	if timer.Exists(self.Entity:EntIndex().."Anim") then timer.Destroy(self.Entity:EntIndex().."Anim") end
	if timer.Exists(self.Entity:EntIndex().."CanFire") then timer.Destroy(self.Entity:EntIndex().."CanFire") end

	for _,v in pairs(self.Lights) do
		if IsValid(v) then v:Remove() end
	end
	if IsValid(self.Turn) then self.Turn:Remove(); end
	if IsValid(self.Cann1) then self.Cann1:Remove(); end
	if IsValid(self.Cann2) then self.Cann2:Remove(); end
	if IsValid(self.Cann3) then self.Cann3:Remove(); end
	if IsValid(self.Cann4) then self.Cann4:Remove(); end
	if IsValid(self.Stand) then self.Stand:Remove(); end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	if (not self.Duped) then return end

	// abort, if no valid parts!
	if not (IsValid(self.Stand) and IsValid(self.Turn) and IsValid(self.Cann1) and IsValid(self.Cann2) and IsValid(self.Cann3) and IsValid(self.Cann4)) then
		self.Entity:OnRemove();
		return
	end

	self.StandPhys = self.Stand:GetPhysicsObject();
	self.TurnPhys = self.Turn:GetPhysicsObject();
	self.CannPhys1 = self.Cann1:GetPhysicsObject();
	self.CannPhys2 = self.Cann2:GetPhysicsObject();
	self.CannPhys3 = self.Cann3:GetPhysicsObject();
	self.CannPhys4 = self.Cann3:GetPhysicsObject();

	for _,v in pairs(self.Lights) do
		if not IsValid(v) then
			self.Entity:OnRemove();
			return
		end
	end
	if not (IsValid(self.StandPhys) and IsValid(self.TurnPhys) and IsValid(self.CannPhys1) and IsValid(self.CannPhys2) and IsValid(self.CannPhys3) and IsValid(self.CannPhys4)) then return end

	//physics can be frozen but cannot sleep!!
	self.TurnPhys:Wake();
	self.StandPhys:Wake();
	self.CannPhys1:Wake();
	self.CannPhys2:Wake();
	self.CannPhys3:Wake();
	self.CannPhys4:Wake();

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
	if not (IsValid(self.Stand) and IsValid(self.Turn) and IsValid(self.Cann1) and IsValid(self.Cann2) and IsValid(self.Cann3) and IsValid(self.Cann4)) then
		self.Entity:OnRemove();
		return
	end
	for _,v in pairs(self.Lights) do
		if not IsValid(v) then
			self.Entity:OnRemove();
			return
		end
	end
	if not (IsValid(self.StandPhys) and IsValid(self.TurnPhys) and IsValid(self.CannPhys1) and IsValid(self.CannPhys2) and IsValid(self.CannPhys3) and IsValid(self.CannPhys4)) then return end

	// calculate new angles for parts
	local newpitch = math.Clamp(self.Pitch, self.DownClamp, self.UpClamp);
	local CannAng = self.Stand:LocalToWorldAngles(Angle(-newpitch, self.Yaw+180,0));
	local TurnAng = self.Stand:LocalToWorldAngles(Angle(0,self.Yaw+180,0));

	self.Turn:SetAngles(TurnAng);
	self.Cann1:SetAngles(CannAng);
	self.Cann2:SetAngles(CannAng);
	self.Cann3:SetAngles(CannAng);
	self.Cann4:SetAngles(CannAng);

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

		local cannons = {self.Cann1, self.Cann2, self.Cann3, self.Cann4};
		local cann = cannons[self.ShootingCann];

		if not IsValid(cann) then return end
		local light = self.Lights[self.ShootingCann];
		light.Time = CurTime();
		light.Glow = true;

		self.CanFire = false;

		timer.Create(self.Entity:EntIndex().."Shoot", 0.5, 1, function()

			light:DoAnim(0.5, "fire");
			cann:DoAnim(0.5, "fire");

			local data = cann:GetAttachment(cann:LookupAttachment("Fire"))
			if(not (data and data.Pos)) then return end

			local e = ents.Create("energy_pulse");
			e:PrepareBullet(-1*cann:GetForward(), 10, 12000, 20, {self.Cann, self.Cann2, self.Cann3, self.Cann4, self.Stand, self.Turn, self.Turn});
			e:SetPos(data.Pos);
			e:SetOwner(self);
			e.Owner = self;
			e:Spawn();
			e:Activate();
			e:SetColor(Color(255,255,math.random(75,125),255));

			if (self.ShootingCann == 4) then cann:EmitSound(self.Sounds.Shoot2,100,math.random(95,105));
			else cann:EmitSound(self.Sounds.Shoot,100,math.random(95,105)); end

			util.ScreenShake(data.Pos,2,2.5,1,1500);

			self.ShootingCann = self.ShootingCann + 1;
			if (self.ShootingCann == 5) then self.ShootingCann = 1; end

			timer.Create(self.Entity:EntIndex().."CanFire", math.random(18,24)/10, 1, function() self.CanFire = true end);

		end);

	end

end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_weapon_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_dest_main");
end

end