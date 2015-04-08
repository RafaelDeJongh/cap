--[[
	Cap Console
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Cap Console"
ENT.Author = "Madman07"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Cap Console"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile();

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);

	self.Pressed = false
	self:CreateWireOutputs("Active");
end

function ENT:Think()
	//local ply = StarGate.FindPlayer(self:GetPos(), 400);

	/*if (ply and not self.Light) then
		self.Light = true;
		self:SetSkin(1);
	elseif (not ply and self.Light) then
		self.Light = false;
		self:SetSkin(0);
	end*/

	//self:NextThink(CurTime()+0.5);
	return true
end

function ENT:Use()
	self:PressConsole();
end

function ENT:PressConsole()
	if(not self.Pressed) then
		self.Pressed = true
		self:SetSkin(1)
		self.Light=true
		self:SetWire("Active",1);
	else
		self.Pressed = false
		self:SetSkin(0)
		self.Light=true
		self:SetWire("Active",0);
	end
end

end