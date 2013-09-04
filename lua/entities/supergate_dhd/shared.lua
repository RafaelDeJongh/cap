if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "DHD (Supergate)"
ENT.Author = "aVoN"
ENT.WireDebugName = "Supergate DHD"

ENT.Spawnable = false
ENT.AdminSpawnable = false
