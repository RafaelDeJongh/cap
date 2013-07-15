--[[
	Stationary Staff Weapon
	Copyright (C) 2010 Madman07
]]--

if (not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds = {
	Shoot = Sound("pulse_weapon/staff_weapon.mp3"),
	Open = Sound("pulse_weapon/staff_cannon_open.wav"),
	Close = Sound("pulse_weapon/staff_cannon_close.wav"),
}

-----------------------------------INITIALISE----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/Iziraider/staffweapon/stand.mdl");

	self.Entity:SetName("Stationary Staff Weapon")
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:StartMotionController();
	self.Entity:SetUseType(SIMPLE_USE)

	self.Driver = NULL;
	self.Active = false;

	self.Pitch = 15;
	self.Yaw = 0;

	self.Anim = false;
	self.Open = false;

	self.NextFire = CurTime()+2;
	self.Delay = 0.4;
	self.Color = self.Color or Color(math.random(230,255),200,120,255);

	self.Pressed = false;

	self.Stand = self.Entity;

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_staffstat_max"):GetInt()
	if(ply:GetCount("CAP_staffstat")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Staff Stationary limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = ang.y % 360

	local ent = ents.Create("staff_stationary");
	ent:SetPos(tr.HitPos);
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false); phys:SetMass(50) end

	ent.Turn, ent.Cann = ent:SpawnRest();

	ply:AddCount("CAP_staffstat", ent)
	return ent
end

function ENT:SpawnRest()

	local pos = self.Entity:GetPos();
	local ang = self.Entity:GetAngles(); ang.r = 0;

	local ent1 = ents.Create("staff_stationary_part");
	ent1:SetModel("models/Iziraider/staffweapon/socket.mdl");
	ent1:SetPos(pos);
	ent1:SetAngles(ang);
	ent1.Base = self.Entity;
	ent1:Spawn();
	ent1:Activate();

	local ent2 = ents.Create("staff_stationary_part");
	ent2:SetModel("models/Iziraider/staffweapon/weapon.mdl")
	ent2:SetPos(pos);
	ent2:SetAngles(ang);
	ent2.Base = self.Entity;
	ent2:Spawn();
	ent2:Activate();

	constraint.NoCollide( self.Entity, ent1, 0, 0 );
	constraint.NoCollide( ent1, ent2, 0, 0 );
	constraint.NoCollide( self.Entity, ent2, 0, 0 );

	constraint.Ballsocket( ent1, self.Entity, 0, 0, Vector(-14, 0, 45), 0, 0, 1);
	constraint.Ballsocket( ent1, self.Entity, 0, 0, Vector(-24, 0, 65), 0, 0, 1);
	constraint.Ballsocket( ent2, ent1, 0, 0, Vector(-16, -20, 49), 0, 0, 1);
	constraint.Ballsocket( ent2, ent1, 0, 0, Vector(-16, 20, 49), 0, 0, 1);

	return ent1, ent2;
end

-----------------------------------DIFFERENT CRAP----------------------------------

function ENT:OnRemove()
	if self.Active and IsValid(self.Driver) then self.Entity:Exit() end
	if IsValid(self.Stand) then self.Stand:Remove(); end
	if IsValid(self.Turn) then self.Turn:Remove(); end
	if IsValid(self.Cann) then self.Cann:Remove(); end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	if (not IsValid(self.Turn) or not IsValid(self.Cann)) then
		self.Entity:OnRemove();
		return
	end

	if self.Active and IsValid(self.Driver) then

		if (math.abs(self.Driver:GetPos().x - self.Stand:GetPos().x) > 100) then self.Entity:Exit(); return
		elseif (math.abs(self.Driver:GetPos().y - self.Stand:GetPos().y) > 100) then self.Entity:Exit(); return end

		if (self.Driver:KeyDown( IN_ATTACK ) and self.Open and self.NextFire <= CurTime()) then self.Entity:FireWeapon(); end
		if (self.Driver:KeyDown( IN_ATTACK2 ) and not self.Pressed) then

			self.Pressed = true;

			if (self.Open) then
				self.Open = false;
				local seq = self.Cann:LookupSequence("close")
				self.Cann:ResetSequence(seq)
				self.Cann:EmitSound(self.Sounds.Close,90,math.random(90,110));
			else
				self.Open = true;
				local seq = self.Cann:LookupSequence("open")
				self.Cann:ResetSequence(seq)
				self.Cann:EmitSound(self.Sounds.Open,90,math.random(90,110));

				local data = self.Cann:GetAttachment(self.Cann:LookupAttachment("Fire"))
				if(not (data and data.Pos)) then return end

				local fx = EffectData();
					fx:SetStart(data.Pos);
					fx:SetAngles(Angle(255,200,120));
					fx:SetRadius(80);
				util.Effect("avon_energy_muzzle",fx,true);

			end

			self.Anim = true;
			timer.Simple( 0.5, function() self.Anim = false; self.Pressed = false; end)

		end

	end

	if self.Anim then
		self:NextThink(CurTime());
		return true
	else
		self:NextThink(CurTime()+0.1);
		return true
	end

end

-----------------------------------PHYSIC----------------------------------

function ENT:PhysicsUpdate( phys, deltatime )

	local StandPitch = self.Stand:GetAngles().Pitch;
	local StandYaw = self.Stand:GetAngles().Yaw;
	local StandRoll = self.Stand:GetAngles().Roll;

	if self.Active and IsValid(self.Driver) then

		traceres = util.GetPlayerTrace(self.Driver)
		traceres.filter = {self.Driver, self.Cann, self.Turn, self.Stand, self.Entity}
		local trace = util.TraceLine(traceres)
		local shootpos = self.Stand:LocalToWorld(Vector(-16, 0, 49));

		local ShootAngle = (trace.HitPos - shootpos):Angle() - self.Stand:GetAngles();
		self.Pitch = math.Clamp(math.NormalizeAngle(ShootAngle.Pitch), -45, 10);
		self.Yaw  = math.Clamp(math.NormalizeAngle(ShootAngle.Yaw), -60, 60);

	else
			self.Pitch = 15;
	end

	local Cannon = self.Cann:GetPhysicsObject();
	Cannon:Wake();

	self.CannPhys = {
		secondstoarrive = 0.01;
		angle 			= Angle(self.Pitch-StandPitch, self.Yaw+StandYaw, StandRoll);
		maxangular 		= 1000000;
		maxangulardamp 	= 100000000;
		dampfactor 		= 0.8;
		deltatime 		= deltatime;
	}
	Cannon:ComputeShadowControl(self.CannPhys);

end

function ENT:Use(ply,caller)
	if not self.Active then
		self.Driver = ply;
		ply:DrawWorldModel(false);
		ply:DrawViewModel(false);
		self.weps = {}
		for k,v in pairs(ply:GetWeapons()) do
			table.insert(self.weps, v:GetClass());
		end
		ply:StripWeapons();
		self.Cann:SetOwner(ply);
		self.Active = true;
	end
end

function ENT:Exit()
	for k,v in pairs(self.weps) do
		self.Driver:Give(tostring(v));
	end
	self.Driver:DrawViewModel(true);
	self.Driver:DrawWorldModel(true);
	self.Driver = NULL;
	self.Cann:SetOwner();
	self.Active = false;
end

function ENT:FireWeapon()

	if (not self.Cann.Shots) then self.Cann.Shots = {} end
	self.NextFire = CurTime()+self.Delay;

	self.Cann:EmitSound(self.Sounds.Shoot,90,math.random(90,110));

	local vel = self.Cann:GetVelocity();
	local dir = 15000*self.Cann:GetForward()+VectorRand()*0.005;

	local data = self.Cann:GetAttachment(self.Cann:LookupAttachment("Fire"))
	if(not (data and data.Pos)) then return end

	local fx = EffectData();
	fx:SetScale(1);
	fx:SetOrigin(data.Pos);
	fx:SetEntity(self.Cann);
	fx:SetAngles(Angle(self.Color.r,self.Color.g,self.Color.b));
	util.Effect("energy_muzzle",fx,true,true);

	util.ScreenShake(data.Pos,2,2.5,1,700);

	local e = ents.Create("energy_pulse");
	e:PrepareBullet(self.Cann:GetForward(), 1, 12000, 10, {self.Cann, self.Turn, self.Stand});
	e:SetPos(data.Pos);
	e:SetOwner(self);
	e.Owner = self;
	e:Spawn();
	e:Activate();
	e:SetColor(Color(self.Color.r,self.Color.g,self.Color.b,255));

	self.Cann.Shots[e] = true;

end

function ENT:ExplodeShots()
	for k,_ in pairs(self.Cann.Shots) do
		if(IsValid(k)) then
			k:Touch();
		end
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Stand) then
		dupeInfo.StandID = self.Stand:EntIndex()
	end
	if IsValid(self.Turn) then
		dupeInfo.TurnID = self.Turn:EntIndex()
	end
	if IsValid(self.Cann) then
		dupeInfo.CannID = self.Cann:EntIndex()
	end
	duplicator.StoreEntityModifier(self, "StaffDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "StaffDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.StaffDupeInfo

	if dupeInfo.StandID then
		self.Stand = CreatedEntities[ dupeInfo.StandID ]
	end
	if dupeInfo.TurnID then
		self.Turn = CreatedEntities[ dupeInfo.TurnID ]
	end
	if dupeInfo.CannID then
		self.Cann = CreatedEntities[ dupeInfo.CannID ]
	end

	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:OnRemove(); return end

	local PropLimit = GetConVar("CAP_staffstat_max"):GetInt()
	if(ply:GetCount("CAP_staffstat")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Staff Stationary limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:OnRemove();
		return
	end


	self.Driver = NULL;
	self.weps = {}
	self.Active = false;
	self.Pitch = 15;
	self.Yaw = 0;
	self.Anim = false;
	self.Open = false;
	self.NextFire = CurTime()+2;
	self.Pressed = false;

	ply:AddCount("CAP_staffstat", self.Entity)
end