-- The shared lua has all the things which are needed clientside and serverside. Don't put unimportant stuff in here when it's only needed serverside or clientside but not on both sides
ENT.Type = "anim"
ENT.Base = "stargate_base" -- This is the most important part. This tells this gate to derive from the "stargate_base" SENT
ENT.PrintName = "Stargate Example"
ENT.Author = "aVoN"

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.WireDebugName = "Stargate Example"