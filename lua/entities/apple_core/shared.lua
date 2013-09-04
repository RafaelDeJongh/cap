if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Apple Core"
ENT.Author = "assassin21, Boba Fett, Madman07"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Apple Core"

list.Set("CAP.Entity", ENT.PrintName, ENT);

if (Environments) then
	ENT.IsNode = false
else
	ENT.IsNode = true
end