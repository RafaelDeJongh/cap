if (not StarGate.CheckModule("extra")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	--################# Set physic and entity properties
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableMotion(false);
		phys:SetMass(400);
	end
end

function ENT:Bearing(skin)
    if(skin)then
        self.Entity:Fire("skin",1);
	else
	    self.Entity:Fire("skin",2);
		self.Entity:SetNetworkedBool("bearing",false); -- Dynamic light of the bearing
    end
end

