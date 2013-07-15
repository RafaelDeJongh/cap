/*
	Dron Key
	Copyright (C) 2010
*/

include("shared.lua");
-- Inventory Icon
-- if(file.Exists("materials/VGUI/weapons/kino_inventory.vmt"),"GAME") then
	-- SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/kino_inventory");
-- end
-- Kill Icon
-- if(file.Exists("materials/VGUI/weapons/kino_inventory.vmt"),"GAME") then
	-- killicon.Add("KRD","VGUI/weapons/kino_inventory",Color(255,255,255));
-- end

local default = Material("madman07/minidrone_platform/key");
local noglow = Material("madman07/minidrone_platform/key_off");
local glow = Material("madman07/minidrone_platform/key_on");

function SWEP:Think()
	local p = self.Owner;
	local platform = p:GetNetworkedEntity("DronePlatform", NULL);
	if IsValid(platform) then
		local len = (p:GetPos() - platform:GetPos()):Length();
		if (len < 500) then
			default:SetTexture( "$basetexture", glow:GetTexture("$basetexture"));
			default:SetInt( "$selfillum", 1);
		else
			default:SetTexture( "$basetexture", noglow:GetTexture("$basetexture"));
			default:SetInt( "$selfillum", 0);
		end
	else
		default:SetTexture( "$basetexture", noglow:GetTexture("$basetexture"));
		default:SetInt( "$selfillum", 0);
	end
end