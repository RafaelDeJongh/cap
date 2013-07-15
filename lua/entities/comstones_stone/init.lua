--[[
	Comunication Device
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/com_device/stone.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Tablet = NULL;
	self.Ply = NULL;
	self.PairedStone = NULL;
	self.Connected = false;
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("comstones_stone");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

function ENT:Use(ply)
	if(IsValid(ply) and ply:IsPlayer()) then
		if (self.Ply == ply) then
			self.Ply = NULL;
			self.Entity:SetNetworkedString("Name", "---");
			if IsValid(self.Tablet) then self.Tablet:Disconnect(self); end
		else
			self.Ply = ply;
			self.Entity:SetNWString("Name", ply:GetName());
			if IsValid(self.Tablet) then self.Tablet:Connect(self); end
		end

	end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	duplicator.StoreEntityModifier(self, "StoneDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "StoneDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.StoneDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end
end