if (not StarGate.CheckModule("extra")) then return end
include("shared.lua");

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/virus.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/virus");
end

SWEP.Primary.Sound = "stargate/universe/kinoturnon.wav"
SWEP.Secondary.Sound = "stargate/universe/kinoturnon.wav"
SWEP.DrawAmmo	= false;
SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/virus")

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - 8*a:Up() - 6*a:Forward() + 1*a:Right();
	a:RotateAroundAxis(a:Right(),30);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end