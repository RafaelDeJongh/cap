include("shared.lua")
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("shuttle_turret", SGLanguage.GetMessage("entity_dest_shuttle"))
end