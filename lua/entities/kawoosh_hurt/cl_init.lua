include("shared.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.PrintName = SGLanguage.GetMessage("kawoosh_hurt");
language.Add("kawoosh_hurt",SGLanguage.GetMessage("kawoosh_hurt"))
end