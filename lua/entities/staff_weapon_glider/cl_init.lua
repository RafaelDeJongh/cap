include("shared.lua");
ENT.RenderGroup = RENDERGROUP_OPAQUE; -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("staff_weapon_glider",SGLanguage.GetMessage("glider_staff")); -- Some idiot got smashed
end
-- Kill Icon
if(file.Exists("materials/weapons/staff_stationary_killicon.vmt","GAME")) then
	killicon.Add("staff_weapon_glider","weapons/staff_stationary_killicon",Color(255,255,255));
	killicon.Add("staff_pulse_stationary","weapons/staff_stationary_killicon",Color(255,255,255));
end
