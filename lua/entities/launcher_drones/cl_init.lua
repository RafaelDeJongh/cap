include("shared.lua");
ENT.RenderGroup = RENDERGROUP_OPAQUE; -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_weapon_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_drone");
end
-- Kill Icon
if(file.Exists("materials/weapons/drone_killicon.vmt","GAME")) then
	killicon.Add("launcher_drones","weapons/drone_killicon",Color(255,255,255));
	killicon.Add("drone","weapons/drone_killicon",Color(255,255,255));
end
