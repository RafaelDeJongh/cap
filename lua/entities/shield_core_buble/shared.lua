StarGate.LifeSupportAndWire(ENT);
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Shield Core Buble"
ENT.WireDebugName = "Shield Core Buble"
ENT.Author = "Madman07"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:GetTraceSize()
	return self.Entity:GetNetworkedVector("TraceSize",Vector(1,1,1));
end