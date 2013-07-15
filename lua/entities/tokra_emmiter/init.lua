--[[
	Tokra Shield Emmiter
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
end
