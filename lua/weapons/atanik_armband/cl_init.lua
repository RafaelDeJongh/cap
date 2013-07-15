--[[
	Atanik Armband
	Copyright (C) 2012 Llapp
]]--

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/atanik_inventory.vmt","GAME")) then
   SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/atanik_inventory");
end

include("shared.lua");
function SWEP:GetViewModelPosition(p,a)
	p = p - a:Up() - 10*a:Forward() + 1*a:Right();
	return p,a;
end