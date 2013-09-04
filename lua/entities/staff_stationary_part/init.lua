--[[
	Stationary Staff Weapon
	Copyright (C) 2010 Madman07, AlexALX
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-----------------------------------INITIALISE----------------------------------

function ENT:Initialize()

	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE)
	self.Base = self.Base or NULL;

	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then phys:EnableGravity(false); phys:SetMass(20) end

end


function ENT:Use(...)
	self.Base:Use(...);
end