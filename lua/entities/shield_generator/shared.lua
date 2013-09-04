if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Shield Generator"
ENT.Author = "aVoN"
ENT.WireDebugName = "Shield Generator"

ENT.Spawnable = false
ENT.AdminSpawnable = false
