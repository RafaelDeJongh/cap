--[[
	Tollan Ion Cannon
	Copyright (C) 2010 Madman07
]]--

if (not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds={
	Shoot=Sound("weapons/tollana_fire.wav"),
	Move=Sound("weapons/turret_move_loop.wav"),
}
ENT.SoundDur = 0.2;

ENT.BaseModel = "models/Iziraider/ioncannon/ioncannon_stand.mdl";
ENT.TurnModel = "models/Iziraider/ioncannon/ioncannon_turn.mdl";
ENT.BarrelModel = "models/Iziraider/ioncannon/ioncannon_cann.mdl";
ENT.BarrelPos = Vector(0,0,125);
ENT.TurnPos = Vector(0,0,22.5);

ENT.DownClamp = -60;
ENT.UpClamp = 0;
ENT.Speed = 0.25;

ENT.energy_drain = 4000;
ENT.energy_setup = 8000;

ENT.Pitch = 0;

-----------------------------------SPAWN----------------------------------

function ENT:Initialize()

	self.Entity:SetName(self.PrintName);
	self.Entity:SetModel(self.BaseModel);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:StartMotionController();

	self.Inputs = WireLib.CreateInputs( self.Entity, {"Fire [NORMAL]", "Active [NORMAL]", "Vector [VECTOR]", "Entity [ENTITY]"});

	self.Yaw = 0;
	self.Pitch = -25;

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
		phys:SetMass(5000);
	end

	--self:SpawnRest();
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_ioncannon_max"):GetInt()
	if(ply:GetCount("CAP_ioncannon")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Tollana Ion Cannons limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = ang.y % 360

	local ent = ents.Create("sg_turret_tollan");
	ent:SetPos(tr.HitPos);
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();

	ply:AddCount("CAP_ioncannon", ent)
	ent:SpawnRest();
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

	if IsValid(self.Cann) then
		dupeInfo.Cann = self.Cann:EntIndex();
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

	if dupeInfo.Cann then
		self.Cann = CreatedEntities[ dupeInfo.Cann ]
		self.Cann.Parent = self.Entity;
	end

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.Stand = self.Entity;
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("CAP_ioncannon_max"):GetInt()
	if(ply:GetCount("CAP_ioncannon")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Tollana Ion Cannons limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end
	self.Duped = true;
	ply:AddCount("CAP_ioncannon", self.Entity)
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

function ENT:OnRemove()
	if IsValid(self.Stand) then self.Stand:Remove(); end
	if IsValid(self.Turn) then self.Turn:Remove(); end
	if IsValid(self.Cann) then self.Cann:Remove() end
end

-----------------------------------SHOOT----------------------------------

function ENT:Shoot()

	local energy = self:GetResource("energy",self.energy_drain);

	if(energy > self.energy_drain or !self.HasResourceDistribution) then

		self:ConsumeResource("energy",self.energy_drain);

		self.CanFire = false;
		self.Cann:DoAnim(1, "Fire");
		self.Cann:EmitSound(self.Sounds.Shoot,100,math.random(90,110));

		local attach = {"Fire1", "Fire2", "Fire3", "Fire4"}

		for i = 1, 4 do
			local data = self.Cann:GetAttachment(self.Cann:LookupAttachment(attach[i]))
			if(not (data and data.Pos)) then return end

			local fx = EffectData();
			fx:SetAngles(Angle(math.random(40,60),math.random(80,100),math.random(250,255)));
			fx:SetStart(data.Pos - self.Cann:GetForward()*10);
			fx:SetOrigin(data.Pos - self.Cann:GetForward()*10);
			fx:SetScale(1);
			util.Effect("Energy_glow",fx);
		end


		timer.Simple( 0.3, function()
			for i = 1, 4 do
				local data = self.Cann:GetAttachment(self.Cann:LookupAttachment(attach[i]))
				if(not (data and data.Pos)) then return end

				local e = ents.Create("energy_pulse");
				e:PrepareBullet(self.Cann:GetForward(), 10, 12000, 30, {self.Cann, self.Turn, self.Stand});
				e:SetPos(data.Pos);
				e:SetOwner(self);
				e.Owner = self;
				e:Spawn();
				e:Activate();
				e:SetColor(Color(math.random(40,60),math.random(80,100),math.random(250,255),255));
			end

		end)

		timer.Simple( math.random(2,4), function() self.CanFire = true end);
	end

end
