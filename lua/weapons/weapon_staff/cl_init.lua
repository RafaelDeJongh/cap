include("shared.lua");
-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/staff_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/staff_inventory");
end
-- Kill Icon
if(file.Exists("materials/VGUI/weapons/staff_killicon.vmt","GAME")) then
	killicon.Add("weapon_staff","VGUI/weapons/staff_killicon",Color(255,255,255));
	killicon.Add("staff_pulse","VGUI/weapons/staff_killicon",Color(255,255,255));
end
language.Add("CombineCannon_ammo",Language.GetMessage("liquid_naquadah"));
language.Add("weapon_staff",Language.GetMessage("weapon_staff"));

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - 70*a:Up() - 13*a:Forward() + 2*a:Right();
	a:RotateAroundAxis(a:Right(),5);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end
