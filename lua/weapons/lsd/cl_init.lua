/*
	Life Sign Detector
	Copyright (C) 2010 Madman07
*/

if (not StarGate.CheckModule("extra")) then return end
include("shared.lua");
include('cl_viewscreen.lua')

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/LSD_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/LSD_inventory");
end

SWEP.DrawAmmo	= false;
SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/LSD_inventory")

function SWEP:GetViewModelPosition(p,a)
	p = p - 10*a:Up() - 6*a:Forward() + 1*a:Right();
	a:RotateAroundAxis(a:Right(),30);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end