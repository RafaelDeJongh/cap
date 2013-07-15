if (not StarGate.CheckModule("extra")) then return end

include("shared.lua");

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/pdd_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/pdd_inventory");
end

SWEP.Primary.Sound = "stargate/universe/kinoturnon.wav"
SWEP.Secondary.Sound = "stargate/universe/kinoturnon.wav"
SWEP.DrawAmmo	= false;
SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/pdd_inventory")

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - 10*a:Up() - 6*a:Forward() + 1*a:Right();
	a:RotateAroundAxis(a:Right(),30);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end