if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Catdaemon"
ENT.WireDebugName = "Wraith Harvester"
ENT.PrintName = "Wraith Harvester"

ENT.Spawnable = false
ENT.AdminSpawnable = false

--################# Gets the beam normal @aVoN
function ENT:GetBeamNormal()
	if(self.Entity:GetNetworkedBool("always_down",false)) then
		return Vector(0,0,-1000);
	end
	return self.Entity:GetUp()*1000;
end
