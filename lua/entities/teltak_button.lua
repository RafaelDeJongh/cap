ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Tel'Tak Button"
ENT.Author = "RononDex"
ENT.Category = "Stargate Carter Addon Pack"

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile()

ENT.CAP_NotSave = true;

function ENT:Initialize()

	self:SetModel("models/jaanus/thruster_flat.mdl")
	self:SetMaterial("james/teltac/gold_plain.vtf")
	self:SetSolid(SOLID_VPHYSICS)
	--self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self.NextUse = CurTime();
	self:SetUseType(SIMPLE_USE)

end

function ENT:Use()

	if self.NextUse < CurTime() then
		if self.RearDoor and not self.BulkHead then
			self.Parent:ToggleDoors("ine");
		elseif self.Bulkhead and not self.RearDoor then
			self.Parent:ToggleDoors("inc");
		else
			self.Parent:ToggleDoors("out");
		end
		self.NextUse = CurTime() + 1;
	end
end

end

if CLIENT then

function ENT:Draw() self:DrawModel() end

end