-- Use the Stargate addon to add LS, RD and Wire support to this entity
if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type 		= "anim"
ENT.Base 		= "base_anim"

ENT.PrintName	= "Naquadah Bomb"
ENT.Author		= "PyroSpirit and Madman1991 and Madman07"
ENT.Contact		= "forums.facepunchstudios.com"

ENT.Spawnable        = false
ENT.AdminSpawnable   = false

ENT.detonationCode = 1
ENT.chargeTime = 4
ENT.yield = 100
