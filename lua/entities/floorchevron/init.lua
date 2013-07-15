/*   Copyright (C) 2011 by Llapp   */

if (not StarGate.CheckModule("extra")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

Models = {
          "models/the_sniper_9/universe/stargate/floorchevron.mdl",
          "models/boba_Fett/ramps/sgu_ramp/floor_chev.mdl",
         }
Materials = {
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
end

function ENT:FloorChev(skin)
    if(skin)then
	    if(self.Entity:GetModel() == Models[1])then
		    self.Entity:SetMaterial(Materials[1]);
		else
		    self.Entity:Fire("skin",1);
		end
	else
	    if(self.Entity:GetModel() == Models[1])then
		    self.Entity:SetMaterial(Materials[2]);
		else
			self.Entity:Fire("skin",2);
	    end
    end
end
