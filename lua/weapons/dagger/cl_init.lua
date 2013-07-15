include("shared.lua");
-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/dagger_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/dagger_inventory");
end
-- Kill Icon
if(file.Exists("materials/weapons/knife_kill.vmt","GAME")) then
	killicon.Add("KRD","/weapons/knife_kill",Color(255,255,255));
end