ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Jumper Button"
ENT.Author = "RononDex"
ENT.Category = "Stargate Carter Addon Pack"

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile()

ENT.CAP_NotSave = true;

function ENT:Initialize()

	self:SetModel("models/jaanus/thruster_flat.mdl")

	self:SetSolid(SOLID_VPHYSICS)
	--self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self.NextUse = CurTime();
	self:SetUseType(SIMPLE_USE)
	self:SetNWEntity("Jumper",self.Parent);
	self:SetNWBool("BulkHead",self.Bulkhead)

end

function ENT:Use()

	if self.NextUse < CurTime() then
		if self.RearDoor and not self.BulkHead then
			self.Parent:ToggleDoor();
		elseif self.Bulkhead and not self.RearDoor then
			self.Parent:ToggleBulkHead();
		end
		self:SetNWBool("Use",true);
		self.NextUse = CurTime() + 1;
	end
end

function ENT:Think()
	
	if(self.NextUse < CurTime()) then
		self:SetNWInt("Use",false);
	end	

end

end

if CLIENT then

function ENT:Draw() self:DrawModel() end

function ENT:Think()
	
	local On = self:GetNWBool("Use");
	local e = self:GetParent();
	local b = self:GetNWBool("BulkHead");
	local c = e.CurrentCloak;
	if(On) then
		if(IsValid(c)) then
			if(b) then
				c:ToggleJumperBulkHead(false);
			else
				c:ToggleJumperDoor(false);
			end
		end
	end

end

end