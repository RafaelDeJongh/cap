/*   Copyright (C) 2011 by Llapp   */

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Gate bearing"
ENT.Author = "Llapp"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Gate bearing"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile()

ENT.Models = {
          "models/the_sniper_9/universe/stargate/floorchevron.mdl",
          "models/boba_Fett/ramps/sgu_ramp/floor_chev.mdl",
         }
ENT.Materials = {
             "The_Sniper_9/Universe/Stargate/UniverseChevronOn.vmt",
             "The_Sniper_9/Universe/Stargate/UniverseChevronOff.vmt",
            }

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	--################# Set physic and entity properties
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid())then
		phys:EnableMotion(false);
		phys:SetMass(20);
	end

	self.BearingMode = false;

	self:CreateWireInputs("Bearing Mode");
	self:CreateWireOutputs("Activated");
end

function ENT:TriggerInput(k,v)
	if (k=="Bearing Mode") then
		if (v>0) then
			self.BearingMode = true;
		else
			self.BearingMode = false;
		end
	end
end

function ENT:FloorChev(skin)
    if(skin)then
	    if(self.Entity:GetModel() == self.Models[1])then
		    self.Entity:SetMaterial(self.Materials[1]);
		else
		    self.Entity:Fire("skin",1);
		end
		self:SetWire("Activated",true);
	else
	    if(self.Entity:GetModel() == self.Models[1])then
		    self.Entity:SetMaterial(self.Materials[2]);
		else
			self.Entity:Fire("skin",2);
	    end
	    self:SetWire("Activated",false);
    end
end

end