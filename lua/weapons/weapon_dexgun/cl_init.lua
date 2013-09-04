include("shared.lua");
-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/dexgun_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/dexgun_inventory");
end
-- Kill Icon
if(file.Exists("materials/VGUI/weapons/dexgun_killicon.vmt","GAME")) then
	killicon.Add("weapon_dexgun","VGUI/weapons/dexgun_killicon",Color(255,255,255));
end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("HelicopterGun_ammo",SGLanguage.GetMessage("energy_cell"));
language.Add("weapon_dexgun",SGLanguage.GetMessage("weapon_ronongun"));
end

function SWEP:Initialize()

	self.NextUse = CurTime();

end


function SWEP:DrawHUD()
	local mode = "Kill";
	local int = self:GetNetworkedInt("Mode");
	if int == 1 then
		mode = "Stun";
	elseif int == 2 then
		mode = "Kill";
	end
	draw.WordBox(8,ScrW()-188,ScrH()-120,"Mode: "..mode,"Default",Color(0,0,0,80),Color(255,220,0,220));
end
