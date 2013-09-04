if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Stargate Iris Computer"
ENT.Purpose	= "Open/Close Iris"
ENT.Author = "Rothon, AlexALX"
ENT.Contact	= "steven@facklerfamily.org"
ENT.Instructions= "Touch gate or Iris, press USE to change settings"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Stargate Iris Computer"

list.Set("CAP.Entity", ENT.PrintName, ENT);