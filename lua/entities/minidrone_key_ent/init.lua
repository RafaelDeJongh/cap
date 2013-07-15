--[[
	Minidrone Platform Key
	Copyright (C) 2010 Madman07
]]--

if (not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Minidrone Platform Key");
	self.Entity:SetModel("models/Madman07/minidrone_platform/key_w.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.CanTouch = false;
	timer.Create(self.Entity:EntIndex().."Touch", 1, 1, function() self.CanTouch  = true; end);

end

-----------------------------------Touch----------------------------------

function ENT:StartTouch(ply)
	if (self.CanTouch and ply:IsPlayer() and not ply:HasWeapon("minidrone_key")) then
		ply.MiniDronePlatform = self.MiniDronePlatform;
		ply:SetNetworkedEntity("DronePlatform", self.MiniDronePlatform);
		ply:Give("minidrone_key");
		self:Remove();
	end
end