--[[
	Kino Dispenser
	Copyright (C) 2010 Madman07
]]--

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Kino Dispenser"
ENT.WireDebugName = "Kino Dispenser"
ENT.Author = "Madman07, Rafael De Jongh"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile()

ENT.Sounds = {
	Tick = Sound("kino/kino_mode1.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/Iziraider/kinodispenser/kinodispenser.mdl");

	self.Entity:SetName("Kino Dispenser");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.CanSpawn = true;
	util.PrecacheModel("models/Boba_Fett/kino/kino.mdl");

	self.MaxKino = StarGate.CFG:Get("kino_dispenser","max_kino",4);
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_dispenser_max"):GetInt()
	if(ply:GetCount("CAP_dispenser")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_kino_dis\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("kino_dispenser");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAP_dispenser", ent)
	return ent
end

-----------------------------------USE----------------------------------

function ENT:Use(ply,caller,ent)

	if (self.CanSpawn == true) then
		if (self.Entity:FindKino(ply)) then return end
		self.CanSpawn = false;

		local kino = ents.Create("kino_ball");
		kino:SetModel("models/Boba_Fett/kino/kino.mdl");
		kino:SetPos(self.Entity:GetPos()+self.Entity:GetUp()*52);
		kino:SetAngles(self.Entity:GetAngles());
		kino:Spawn();
		kino:Activate();
		if (IsValid(ply)) then
			ply:AddCount("CAP_kino", kino)
		end

		--kino:EmitSound(self.Sounds.Tick,100,100);

		kino.Owner = ply;
		kino.Acc = self.Entity:GetForward()*5 + self.Entity:GetUp()*2 + VectorRand();

		ply:Give("kinoremote");
		ply:SelectWeapon("kinoremote");

		timer.Simple( 5, function() self.CanSpawn = true end);
	end
end

-----------------------------------FIND STUFF----------------------------------

function ENT:FindKino(ply)
	local number = 0;

	for _,v in pairs(ents.FindByClass("kino_ball*")) do
		if (v.Owner == ply) then
			number = number + 1;
		end
	end

	if (number < self.MaxKino) then return false
	else return true end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	duplicator.StoreEntityModifier(self, "DispDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "DispDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_dispenser_max"):GetInt();
		if(ply:GetCount("CAP_dispenser")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_kino_dis\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
	end

	local dupeInfo = Ent.EntityMods.DispDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.CanSpawn = true;

	if (IsValid(ply)) then
		self.Owner = ply;
		ply:AddCount("CAP_dispenser", self.Entity)
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "kino_dispenser", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_kino_dis");
end

end