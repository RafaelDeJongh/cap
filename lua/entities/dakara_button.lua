--[[
	Dakara Button
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Dakara Buttons"
ENT.Author = "Madman07"
ENT.Category = "Stargate Carter Addon Pack: Weapons"
ENT.WireDebugName = "Dakara Weapon"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Untouchable = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile();

function ENT:Initialize()

	self.Entity:SetModel("models/beer/wiremod/numpad.mdl");
	self.Entity:SetName("Dakara Button");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
	self.Entity:SetMaterial("Iziraider/dakara/stone");

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1000) -- make it more solid
	end

end

function ENT:Use(ply)
	if IsValid(self.Parent) then
		if (self.Type == 1) then
			self.Parent.MainDoor:Toggle();
		elseif (self.Type == 2) then
			self.Parent.SecretDoor:Toggle();
		end
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "dakara_building", StarGate.CAP_GmodDuplicator, "Data" )
end

end