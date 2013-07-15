--[[
	Dakara Button
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

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
