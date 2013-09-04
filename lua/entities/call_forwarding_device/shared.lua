if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_gmodentity" --gmodentity
ENT.PrintName = "CFD"
ENT.Author = "Llapp"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Call Forwarding Device"

list.Set("CAP.Entity", ENT.PrintName, ENT);