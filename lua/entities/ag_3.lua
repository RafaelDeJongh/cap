--[[
	AG-3 Satelitte
	Copyright (C) 2010 Madman07
]]--

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "AG-3 Satelitte"
ENT.WireDebugName = "AG-3 Satelitte"
ENT.Author = "Madman07, Boba Fett"
ENT.Instructions= ""
ENT.Contact = ""
ENT.Category = "Stargate Carter Addon Pack: Weapons"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

list.Set("CAP.Entity", ENT.PrintName, ENT);

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	ENT.Category = SGLanguage.GetMessage("entity_weapon_cat");
	ENT.PrintName = SGLanguage.GetMessage("entity_ag3");
end

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile()

ENT.Sounds={
	Shoot=Sound("weapons/ag3_fire.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetName("AG-3 Satelitte");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableGravity(false);
		phys:Wake();
	end
	self.Entity:SetGravity(0);
	self.Entity:StartMotionController();

	self.Time = CurTime()

	self.APC = nil;
	self.APCply = nil;

	self.HealthWep = StarGate.CFG:Get("ag_3","health",500);
	self.Power = 0;

	self.WireActive = nil;
	self.WireShoot = nil;
	self.WireEnt = nil;
	self.WireVec = nil;

	self.SatellitePhys = {}
	self.Angles = Angle(90,0,0);
	self.Position = self.Entity:GetPos();

	self.InfoTar = nil
	self.PlasmaBeam = nil

	self.AimPoint = self.Position - Vector(0,0,250);
	self.OrbitAngle = 0;

	self.FireMainBeam = false;
	self.EndFire = false;
	self.Canfire = false;
	self.Prepared = false;
	self.Firing = false

end

function ENT:FindSatellites(ent)
	local isfirst = true;

	for _,v in pairs(ents.FindByClass("ag_3")) do
		if IsValid(v) and v != ent then
			if (v.Owner == ent.Owner) then
				isfirst = false;
				if v.IsMaster then

				table.insert(v.Satellite, ent);

				if (table.getn(v.Satellite) == 1) then v:SetNetworkedEntity("Sat1", ent);
				elseif (table.getn(v.Satellite) == 2) then v:SetNWEntity("Sat2", ent);
				elseif (table.getn(v.Satellite) == 3) then v:SetNWEntity("Sat3", ent);
				elseif (table.getn(v.Satellite) == 4) then v:SetNWEntity("Sat4", ent);
				elseif (table.getn(v.Satellite) == 5) then v:SetNWEntity("Sat5", ent); end
				end
			end
		end
	end

	return isfirst;
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_ag3_max"):GetInt()
	if(ply:GetCount("CAP_ag3")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"AG-3 Satellites limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	ent = ents.Create("ag_3");
	util.PrecacheModel("models/Madman07/ag_3/ag_3.mdl")
	ent:SetModel("models/Madman07/ag_3/ag_3.mdl");
	ent:SetPos(tr.HitPos+Vector(0,0,500));
	ent:Spawn();
	ent:Activate();

	ent.Owner = ply;
	ent.IsMaster = ent:FindSatellites(ent);

	if ent.IsMaster then
		ent.Satellite = {}
		ent.Inputs = WireLib.CreateInputs( ent, {"Fire", "Active", "Vector [VECTOR]","Entity [ENTITY]"});
		ent.Outputs = WireLib.CreateOutputs( ent, {"Weapon Status", "Health"});
		Wire_TriggerOutput(ent, "Weapon Status", 100);
	else
		ent.Outputs = WireLib.CreateOutputs( ent, {"Health"});
	end


	Wire_TriggerOutput(ent, "Health", 100);

	ply:AddCount("CAP_ag3", ent)
	return ent
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("CAP_ag3_max"):GetInt()
	if (IsValid(ply)) then
		if(ply:GetCount("CAP_ag3")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"AG-3 Satellites limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("CAP_ag3", self.Entity)
	end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

-----------------------------------REMOVE----------------------------------

function ENT:OnRemove()
	if IsValid(self.Entity) then self.Entity:Remove(); end
	if IsValid(self.e) then self.e:Remove(); end
	if IsValid(self.InfoTar) then self.InfoTar:Remove(); end
	if IsValid(self.PlasmaBeam) then self.PlasmaBeam:Remove(); end
end

-----------------------------------DAMAGE----------------------------------

function ENT:OnTakeDamage(dmg)

	self.HealthWep = self.HealthWep - dmg:GetDamage();

	if (self.HealthWep <= 1) then
		local effectdata = EffectData();
			effectdata:SetOrigin( self.Entity:GetPos() );
			effectdata:SetStart(self.Entity:GetUp());
		util.Effect( "dirtyxplo", effectdata );
		self.Entity:Remove();
	end

end

-----------------------------------TOUCH, WIRE----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Vector") then self.WireVec = value;
	elseif (variable == "Entity") then self.WireEnt = value;
	elseif (variable == "Fire") then self.WireShoot = value;
	elseif (variable == "Active") then self.WireActive = value;	end
end

function ENT:StartTouch(ent)
	if IsValid(ent) and ent:IsVehicle() then
		if self.IsMaster and self.APC != ent then
			local ed = EffectData()
				ed:SetEntity( ent )
			util.Effect( "propspawn", ed, true, true )
		end
		self.APC = ent;
	end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	Wire_TriggerOutput(self.Entity, "Weapon Status", self.Power);
	Wire_TriggerOutput(self.Entity, "Health", self.HealthWep);

	if self.IsMaster then self.Entity:Orbit() end

	if (self.Canfire) then
		if not self.Prepared then
			self.Prepared = true;
			self.Firing = true;
			self.Power = 0;
			self.Entity:CreateSmallLasers();
			timer.Simple( 1.7, function() self.FireMainBeam = true; end);
			timer.Simple( 3.2, function() self.EndFire = true; end);
		end

		if self.Firing then self.InfoTar:SetPos(self.AimPoint); end

		if self.FireMainBeam and self.IsMaster then
			self.Entity:FireBeam();
			self.FireMainBeam = false;
		end

		if self.EndFire then
			self.Entity:RemoveSmallLasers();
			self.FireMainBeam = false;
			self.EndFire = false;
			self.Canfire = false;
			self.Prepared = false;
			self.Firing = false
		end

	else
		if self.IsMaster then

			if IsValid(self.APCply) then

				if (self.APCply:KeyDown( IN_ATTACK ) and (self.Firing == false) and (self.Power == 100)) then
					self.Canfire = true;
					for i=1, 5  do
						if (not IsValid(self.Satellite[i])) then return end
						self.Satellite[i].Canfire = true;
					end
				end

			elseif (self.WireActive == 1) then

				if ((self.WireShoot == 1) and (self.Firing == false) and (self.Power == 100)) then
					self.Canfire = true;
					for i=1, 5  do
						if (not IsValid(self.Satellite[i])) then return end
						self.Satellite[i].Canfire = true;
					end
				end

			end

			if (CurTime() - self.Time > 1) then
				local WeaponTime = StarGate.CFG:Get("ag_3","recharge_time",60);
				self.Time = CurTime();
				self.Power = self.Power + 100/WeaponTime;
				self.Power = math.Clamp(self.Power, 0, 100);
			end

		end
	end

	self.Entity:NextThink(CurTime()+0.1);
	return true
end

function ENT:CreateSmallLasers()
	if (!self.InfoTar and !self.PlasmaBeam ) then
		self.InfoTar = self.Entity:SpawnTarget();
		self.PlasmaBeam = self.Entity:SpawnBeam();

		local data = self.Entity:GetAttachment(self.Entity:LookupAttachment("Fire"))
		if (not (data and data.Pos)) then data.Pos = self.Entity:GetPos() + self.Entity:GetForward()*20 end

		util.ScreenShake(self:GetPos(),2,2.5,8,700);

		if self.IsMaster then
			local fx = EffectData();
				fx:SetEntity(self.Entity);
				fx:SetStart(self.AimPoint);
			util.Effect("AG3_beams",fx);
		end
	end
end

function ENT:FireBeam()
	self.Entity:EmitSound(self.Sounds.Shoot,100,math.random(98,102));
	local ent = ents.Create("energy_beam2");
	ent.Owner = self.Entity;
	ent:SetPos(self.AimPoint);
	ent:Spawn();
	ent:Activate();
	ent:SetOwner(self.Entity);
	ent:Setup(self.AimPoint, self.Entity:GetForward(), 400, 1.5, "AG3");
end

function ENT:RemoveSmallLasers()
	if IsValid(self.InfoTar) then self.InfoTar:Remove(); self.InfoTar = nil end
	if IsValid(self.PlasmaBeam) then self.PlasmaBeam:Remove(); self.PlasmaBeam = nil end
end

function ENT:Orbit()

	self.Position = self.Entity:GetPos();

	for i=1, 5  do
		if not IsValid(self.Satellite[i]) then return end
		local z = 275 - self.Satellite[i].Position:Distance(self.Position + self.Entity:GetForward()*250);
		local x = math.sin(math.rad(i*72-144+self.OrbitAngle))*200;
		local y = math.cos(math.rad(i*72-144+self.OrbitAngle))*200;

		self.Satellite[i].Position = self.Position +  Vector(x,y,z);
		self.Satellite[i].AimPoint = self.Position + self.Entity:GetForward()*250;
	end

	self.OrbitAngle = self.OrbitAngle + 0.5;
	if (self.OrbitAngle == 360) then self.OrbitAngle = 0 end

end

-----------------------------------PHYS----------------------------------

function ENT:Position(pos)
	self.Position = pos
end

function ENT:SpawnTarget()
	local ent = ents.Create("info_target");
    ent:SetName("AG3EndPos"..self.Entity:EntIndex());
    ent:Spawn();
    ent:Activate();
	ent:SetPos(self.Entity:GetPos() + self.Entity:GetForward()*50);
	return ent
end

function ENT:SpawnBeam()
	local beam = ents.Create("env_laser");
	beam:SetName("PlasmaBeam"..self.Entity:EntIndex());
	beam:SetPos(self.Entity:GetPos() + self.Entity:GetForward()*50);
	beam:SetAngles(self.Entity:GetAngles())
	beam:SetOwner(self.Entity:GetOwner());
	beam:SetVar("Owner", self.Entity:GetVar("Owner", nil));
	beam:SetKeyValue("width", "15");
	beam:SetKeyValue("damage", 0);
	beam:SetKeyValue("dissolvetype", "2");
	beam:Spawn();
	beam:SetParent(self.Entity);
	beam:SetTrigger(true);
	return beam
end

function ENT:PhysicsUpdate( phys, deltatime )

	local TargetPos = nil;

	if self.IsMaster then
		if IsValid(self.APC) then

			self.APCply = self.APC:GetPassenger(0)
			if IsValid(self.APCply) then
				self.APCply:CrosshairEnable();
				TargetPos = self.APCply:GetEyeTrace().HitPos;
				self.Killpos = TargetPos
			end

		elseif (self.WireActive == 1) then

			if IsValid(self.WireEnt) then
				TargetPos = self.WireEnt:LocalToWorld(self.WireEnt:OBBCenter())
			elseif (self.WireVec) then
				TargetPos = self.WireVec;
			end

		end

	end

	local AimVec = Angle(0,0,0);

	 if (TargetPos == nil) then
		if self.IsMaster then
			AimVec = self.Angles;
		else
			AimVec = (self.AimPoint - self.Entity:GetPos()):Angle();
		end
	else
		AimVec = (TargetPos - self.Entity:GetPos()):Angle();
		self.AimPoint = self.Entity:GetPos() + self.Entity:GetForward()*250
	end

	self.Angles.Pitch = math.ApproachAngle(self.Angles.Pitch, AimVec.Pitch, 1);
	self.Angles.Yaw = math.ApproachAngle(self.Angles.Yaw, AimVec.Yaw, 1);

	local Sat = self.Entity:GetPhysicsObject();
	Sat:Wake();

	self.SatellitePhys = {
			secondstoarrive	 = 1;
			maxangular		 = 100;
			maxangulardamp 	 = 1000;
			maxspeed 		 = 100;
			maxspeeddamp 	 = 1000;
			dampfactor 		 = 1;
			pos 			 = self.Position;
			angle			 = self.Angles;
			deltatime		 = deltatime;
	}
	Sat:ComputeShadowControl(self.SatellitePhys);

end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "ag_3", StarGate.CAP_GmodDuplicator, "Data" )
end

end