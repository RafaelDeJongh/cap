include("shared.lua");
-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/hand_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/hand_inventory");
end
-- Kill Icon
if(file.Exists("materials/VGUI/weapons/hand_killicon.vmt","GAME")) then
	killicon.Add("weapon_hand_device","VGUI/weapons/hand_killicon",Color(255,255,255));
end
language.Add("Battery_ammo",Language.GetMessage("naquadah"));
language.Add("weapon_hand_device",Language.GetMessage("weapon_hand_device"));

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - 7*a:Up() - 6*a:Forward() + 1*a:Right();
	a:RotateAroundAxis(a:Right(),20);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end

--################### Tell a player how to use this @aVoN
function SWEP:DrawHUD()
	local mode = "Push";
	local int = self.Weapon:GetNetworkedInt("Mode",1);
	if(int == 1) then
		mode = "Push";
	elseif(int == 2) then
		mode = "Cook Brain";
	elseif(int == 3) then
		mode = "Call Nearest Rings";
	elseif(int == 4) then
		mode = "Open Ring Dial Menu";
	end
	draw.WordBox(8,ScrW()-188,ScrH()-120,"Primary: "..mode,"Default",Color(0,0,0,80),Color(255,220,0,220));
end
