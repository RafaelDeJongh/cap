if (not StarGate.CheckModule("ship")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()

	self:SetModel("models/jaanus/thruster_flat.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	--self:PhysicsInit(SOLID_VPHYSICS)
	--self:SetMoveType(MOVETYPE_VPHYSICS)
	self.NextUse = CurTime();
	self:SetUseType(SIMPLE_USE)

end

function ENT:Use()

	if self.NextUse < CurTime() then
		if self.RearDoor and not self.BulkHead then
			self.Parent:ToggleDoor();
		elseif self.Bulkhead and not self.RearDoor then
			self.Parent:ToggleBulkHead();
		end
		self.NextUse = CurTime() + 1;
	end
end