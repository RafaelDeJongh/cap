include("shared.lua");
ENT.RenderGroup = RENDERGROUP_OPAQUE; -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
language.Add("drone_launcher",Language.GetMessage("entity_drone")); -- Some idiot got smashed
-- Kill Icon
if(file.Exists("materials/weapons/drone_killicon.vmt","GAME")) then
	killicon.Add("drone_launcher","weapons/drone_killicon",Color(255,255,255));
	killicon.Add("drone","weapons/drone_killicon",Color(255,255,255));
end
