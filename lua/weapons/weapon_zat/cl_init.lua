include("shared.lua");
-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/zat_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/zat_inventory");
end
-- Kill Icon
if(file.Exists("materials/VGUI/weapons/zat_killicon.vmt","GAME")) then
	killicon.Add("weapon_zat","VGUI/weapons/zat_killicon",Color(255,255,255));
end
language.Add("GaussEnergy_ammo",Language.GetMessage("naquadah"));
language.Add("weapon_zat",Language.GetMessage("weapon_zat"));

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p + 1*a:Up() - a:Forward() - 4*a:Right();
	return p,a;
end
