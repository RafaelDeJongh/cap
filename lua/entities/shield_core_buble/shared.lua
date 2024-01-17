if StarGate and StarGate.LifeSupportAndWire then
    StarGate.LifeSupportAndWire(ENT)
end

DEFINE_BASECLASS("base_anim")

ENT.Type = "anim"
ENT.PrintName = "Shield Core Bubble"
ENT.WireDebugName = "Shield Core Bubble"
ENT.Author = "Madman07"
ENT.Instructions = ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

function ENT:GetTraceSize()
    return self:GetNWVector("TraceSize", Vector(1, 1, 1))
end
