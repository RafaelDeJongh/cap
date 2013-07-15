--[[
	Cap Console
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("extra")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
end

function ENT:Think()
	local ply = StarGate.FindPlayer(self.Entity:GetPos(), 400);

	if (ply and not self.Light) then
		self.Light = true;
		self.Entity:SetSkin(1);
	elseif (not ply and self.Light) then
		self.Light = false;
		self.Entity:SetSkin(0);
	end

	self.Entity:NextThink(CurTime()+0.5);
	return true
end