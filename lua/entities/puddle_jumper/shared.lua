if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "base_anim"
ENT.Type = "vehicle"

ENT.PrintName = "Puddle Jumper"
ENT.Author = "RononDex, Iziraider, Boba Fett"
ENT.Category = "Stargate Carter Addon Pack: Ships"
ENT.AutomaticFrameAdvance = true

list.Set("CAP.Entity", ENT.PrintName, ENT);