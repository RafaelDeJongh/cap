/*
	KINO Remote for Garry's Mod 11
	Scripted by Sutich & Madman07
	Sources from aVoN's Stargate Mod
	Kino Remote Model by Iziraider
	Textures by Boba Fett
	Copyright (C) 2010
*/

include("shared.lua");
-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/kino_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/kino_inventory");
end
-- Kill Icon
if(file.Exists("materials/VGUI/weapons/kino_inventory.vmt","GAME")) then
	killicon.Add("KRD","VGUI/weapons/kino_inventory",Color(255,255,255));
end

SWEP.DrawAmmo	= false;
SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/kino_inventory")

local NV_Status = false

local Color_Brightness		= 0.8
local Color_Contrast 		= 1.1
local Color_AddGreen		= -0.35
local Color_MultiplyGreen 	= 0.028

local AlphaAdd_Alpha 			= 1
local AlphaAdd_Passes			= 1

local matNightVision = Material("effects/nightvision")
matNightVision:SetFloat( "$alpha", AlphaAdd_Alpha )

local Color_Tab =
{
	[ "$pp_colour_addr" ] 		= -1,
	[ "$pp_colour_addg" ] 		= Color_AddGreen,
	[ "$pp_colour_addb" ] 		= -1,
	[ "$pp_colour_brightness" ] = Color_Brightness,
	[ "$pp_colour_contrast" ]	= Color_Contrast,
	[ "$pp_colour_colour" ] 	= 0,
	[ "$pp_colour_mulr" ] 		= 0 ,
	[ "$pp_colour_mulg" ] 		= Color_MultiplyGreen,
	[ "$pp_colour_mulb" ] 		= 0
}
local CurScale = 0.2

local Pressed = false;

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - 10*a:Up() - 6*a:Forward() + 1*a:Right();
	a:RotateAroundAxis(a:Right(),30);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end

--################### Tell a player how to use this @aVoN
function SWEP:DrawHUD()

	local ply = LocalPlayer();
	local active = ply:GetNetworkedBool("KActive")
	local kino = ply:GetNWEntity("Kino", ply);

	if (active == false) then -- Draw mode hud only, if we not flying with kino

		local mode = "KINO Point Control";
		local int = self.Weapon:GetNWInt("Mode",1);

		if(int == 1) then
			mode = "KINO Control";
		elseif(int == 2) then
			mode = "Stargate Dial Control";
		elseif(int == 3) then
			mode = "Ring Dial Control";
		end

		draw.WordBox(8,ScrW()-228,ScrH()-120,"Primary: "..mode,"Default",Color(0,0,0,80),Color(255,220,0,220));

	else

		surface.SetTexture(surface.GetTextureID("VGUI/HUD/kino/kino_back"));
		surface.SetDrawColor(255,255,255,255);
		surface.DrawTexturedRect(0,0,ScrW(),ScrH());

		if NV_Status == true then

			if CurScale < 0.995 then
				CurScale = CurScale + math.Clamp(0.09, 0.01, 1) * (1 - CurScale)
			end

			Color_Tab[ "$pp_colour_brightness" ] = CurScale * Color_Brightness
			Color_Tab[ "$pp_colour_contrast" ] = CurScale * Color_Contrast
			DrawColorModify( Color_Tab )
			DrawMotionBlur( 0.05, 0.2, 0.023)
			DrawMaterialOverlay("models/shadertest/shader3.vmt", 0.0001)

			for i=1,AlphaAdd_Passes do
				render.UpdateScreenEffectTexture()
				render.SetMaterial( matNightVision )
				render.DrawScreenQuad()
			end

		end

	end

end

function SWEP:Think()

	if  (input.IsKeyDown(KEY_N) and Pressed == false) then
		Pressed = true;
		NV_Status = not NV_Status;
		if (Pressed == true) then timer.Simple( 1, function() Pressed = false end) end
	end

	if NV_Status == true then

		local ply = LocalPlayer();
		local kino = ply:GetNWEntity("Kino", ply);

		local dlight = DynamicLight( LocalPlayer():EntIndex() )
		if  (dlight and IsValid(kino) and kino != ply) then
			local r, g, b, a = 255, 255, 255, 255
			dlight.Pos = kino:GetPos()
			dlight.r = r
			dlight.g = g
			dlight.b = b
			dlight.Brightness = 1
			dlight.Size = 512 * CurScale
			dlight.Decay = 512 * CurScale
			dlight.DieTime = CurTime() + 0.1
		end
	end
end
