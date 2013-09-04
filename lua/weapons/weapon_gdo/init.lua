if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile ("cl_init.lua")
AddCSLuaFile ("cl_viewscreen.lua")
AddCSLuaFile ("shared.lua")

include ("shared.lua")

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false