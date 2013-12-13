--[[
	Destiny Turret
	Copyright (C) 2010 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "sg_turret_base"
ENT.PrintName = "Small Turret"
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
	Shoot=Sound("weapons/dest_single.wav"),
	Move=Sound("weapons/turret_move_loop.wav"),
}
ENT.SoundDur = 0.2;

ENT.BaseModel = "models/Madman07/small_cannon/small_stand.mdl";
ENT.TurnModel = "models/Madman07/small_cannon/small_turn.mdl";
ENT.BarrelModel = "models/Madman07/small_cannon/small_cann.mdl";
ENT.TurnPos = Vector(0,0,6.5);
ENT.BarrelPos = Vector(0,0,16.5);

ENT.DownClamp = -35;
ENT.UpClamp = 0;
ENT.Speed = 0.5;

ENT.energy_drain = 400;
ENT.energy_setup = 800;

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_destsmall_max"):GetInt()
		if(ply:GetCount("CAP_destsmall")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Destiny Turrets limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return
		end
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = ang.y % 360

	local ent = ents.Create("sg_turret_destsmall");
	ent:SetPos(tr.HitPos);
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();

	if (IsValid(ply)) then
		ply:AddCount("CAP_destsmall", ent)
	end
	ent:SpawnRest();
	ent.Duped = true;
	return ent
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

		local anim = {"FireTop", "FireBottom"};
		local attach = {"FireTop", "FireBottom"}

		self.CanFire = false;

		self.Cann:DoAnim(1, anim[self.ShootingCann]);

		local data = self.Cann:GetAttachment(self.Cann:LookupAttachment(attach[self.ShootingCann]))
		if(not (data and data.Pos)) then return end

		local fx = EffectData();
		fx:SetAngles(Angle(255,255,math.random(75,125)));
		fx:SetNormal(self.Cann:GetForward());
		fx:SetOrigin(data.Pos);
		util.Effect("Destiny_launch",fx);

		local e = ents.Create("energy_pulse");
		e:PrepareBullet(self.Cann:GetForward(), 10, 12000, 10, {self.Cann, self.Turn, self.Stand});
		e:SetPos(data.Pos);
		e:SetOwner(self);
		e.Owner = self;
		e:Spawn();
		e:Activate();
		e:SetColor(Color(255,255,math.random(75,125),255));

		self.Cann:EmitSound(self.Sounds.Shoot,100,math.random(95,105));
		util.ScreenShake(data.Pos,2,2.5,1,700);

		self.ShootingCann = self.ShootingCann + 1;
		if (self.ShootingCann == 3) then self.ShootingCann = 1; end

		timer.Simple( math.random(8,12)/10, function() self.CanFire = true end);

	end

end

      /*
function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex();
	end

	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Console )
	end

	duplicator.StoreEntityModifier(self, "DestSmallDupeInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self)
end
duplicator.RegisterEntityModifier( "DestSmallDupeInfo" , function() end)*/

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
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_destsmall_max"):GetInt()
		if(ply:GetCount("CAP_destsmall")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Destiny Turrets limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("CAP_destsmall", self.Entity)
	end

	local dupeInfo = Ent.EntityMods.DestSmallDupeInfo
             /*
	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.DestSmallDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.DestSmallDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end      */

	self.Owner = ply;
	self.Duped = true;
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_turret_destsmall", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_weapon_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_dest_small");
end

end