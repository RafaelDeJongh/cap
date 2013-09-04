include("shared.lua")
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	language.Add("f302", SGLanguage.GetMessage("entity_f302"))
end