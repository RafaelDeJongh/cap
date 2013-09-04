include("shared.lua");
ENT.ChevronColor = Color(30,135,180);
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("stargate_atlantis");
end