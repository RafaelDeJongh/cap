StarGate.LifeSupportAndWire(ENT); -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Drone Launcher"
ENT.Author = "Zup, Madman07"
ENT.Category = "Stargate Carter Addon Pack: Weapons"
ENT.WireDebugName = "Drone Launcher"

list.Set("CAP.Entity", ENT.PrintName, ENT);