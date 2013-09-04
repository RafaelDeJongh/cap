--[[
	Hangar Button
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds = {
	Button1=Sound("button/button_hangar1.wav"),
	Button2=Sound("button/button_hangar2.wav"),
}

function ENT:Initialize()

	self.Entity:SetName("Hangar Button");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.NextUse = CurTime();

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(1000) -- make it more solid
	end

end

function ENT:Use(ply)
	if (self.ID == 5) then
		self:EmitSound(self.Sounds.Button2,100,math.random(95,105));
	else
		self:EmitSound(self.Sounds.Button1,100,math.random(95,105));
	end
	if self.NextUse < CurTime() then
		self.Parent:ButtonPressed(self.ID, ply);
		self.NextUse = CurTime() + 1;
	end
end
