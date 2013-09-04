if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

ENT.PrintName	= "Asgard Transporter"
ENT.Author = "PiX06, aVoN, Boba Fett"
ENT.Contact = "pix06@hotmail.co.uk"
ENT.Category = "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);