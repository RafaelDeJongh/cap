StarGate.LifeSupportAndWire(ENT);
ENT.Type = "anim"
ENT.Base = "base_anim" --gmodentity
ENT.PrintName = "Asuran ZPM Hub Mk2"
ENT.Author = "Llapp, cooldudetb, Boba Fett"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Asuran ZPM Hub Mk2"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if (Environments) then
	ENT.IsNode = false
else
	ENT.IsNode = true
end

ENT.ZPMHub = true