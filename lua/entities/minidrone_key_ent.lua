--[[
	Minidrone Platform Key
	Copyright (C) 2010 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Minidrone Platform Key"
ENT.Author = "Madman07, Boba Fett"
ENT.Category = "Stargate Carter Addon Pack: Weapons"
ENT.WireDebugName = "Minidrone Platform Key"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile();

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

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "minidrone_key_ent", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

local default = Material("madman07/minidrone_platform/key");
local noglow = Material("madman07/minidrone_platform/key"):GetTexture("$basetexture");

function ENT:Initialize() //shutdown old effect if needed
	default:SetTexture( "$basetexture", noglow);
	default:SetInt( "$selfillum", 0);
end

function ENT:Draw()
	local mat = Matrix()
	mat:Scale(Vector(2,2,2))
	self.Entity:EnableMatrix( "RenderMultiply", mat )
	self.Entity:DrawModel();
end

end