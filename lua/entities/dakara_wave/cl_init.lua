include("shared.lua")
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("dakara_wave", SGLanguage.GetMessage("dakara_energy_kill"))
end