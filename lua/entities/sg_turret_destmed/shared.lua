if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Medium Turret"
ENT.Author = "Madman07, Boba Fett"
ENT.Instructions= "Kill the blue Aliens!"
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack: Weapons"
ENT.WireDebugName = ENT.PrintName

list.Set("CAP.Entity", ENT.PrintName, ENT);