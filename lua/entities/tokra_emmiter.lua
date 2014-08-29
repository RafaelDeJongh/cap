--[[
	Tokra Shield Emmiter
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Tokra Shield Emmiter"
ENT.WireDebugName = "Tokra Shield"
ENT.Author = "Madman07"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile()

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Link = NULL;
	self.KeyLink = NULL;
	self.Enabled = false;
end

function ENT:Touch(ent)
	if (IsValid(self.Link)) then return end
	if (IsValid(ent)) then
		if (ent:GetClass()=="tokra_emmiter") then
			self.Link = ent;
			ent.Link = self;
			if (IsValid(self.KeyLink)) then ent.KeyLink = self.KeyLink;
			elseif (IsValid(ent.KeyLink)) then self.KeyLink = ent.KeyLink end
			local ed = EffectData()
			ed:SetEntity( self )
			util.Effect( "propspawn", ed, true, true )
			local ed = EffectData()
			ed:SetEntity( ent )
			util.Effect( "propspawn", ed, true, true )
		end
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {};

	if (IsValid(self.Link)) then
		dupeInfo.Link = self.Link:EntIndex();
	end

	if (IsValid(self.KeyLink)) then
		dupeInfo.KeyLink = self.KeyLink:EntIndex();
	end

    duplicator.StoreEntityModifier(self, "TokraEmmiter", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self);
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	local dupeInfo = Ent.EntityMods.TokraEmmiter
	if (dupeInfo and dupeInfo.Link and CreatedEntities[dupeInfo.Link]) then
		self.Link = CreatedEntities[dupeInfo.Link];
	end

	if (dupeInfo and dupeInfo.KeyLink and CreatedEntities[dupeInfo.KeyLink]) then
		self.KeyLink = CreatedEntities[dupeInfo.KeyLink];
	end

	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

end