StarGate.LifeSupportAndWire(ENT);
ENT.Type = "anim"
ENT.Base = "base_anim" --gmodentity
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.PrintName = SGLanguage.GetMessage("entity_atlantist")
ENT.Category = SGLanguage.GetMessage("entity_main_cat")
end
ENT.Author = "AlexALX, Ronon Dex"
ENT.WireDebugName = "Atlantis Transporter"

list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.AutomaticFrameAdvance = true
ENT.IsAtlTP = true;