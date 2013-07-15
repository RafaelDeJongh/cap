StarGate.LifeSupportAndWire(ENT);
ENT.Type = "anim"
ENT.Base = "base_anim" --gmodentity
ENT.PrintName = Language.GetMessage("entity_atlantist")
ENT.Author = "AlexALX, Ronon Dex"
ENT.Category = Language.GetMessage("entity_main_cat")
ENT.WireDebugName = "Atlantis Transporter"

list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.AutomaticFrameAdvance = true
ENT.IsAtlTP = true;