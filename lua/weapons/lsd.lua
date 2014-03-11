/*
	Life Sign Detector
	Copyright (C) 2010 Madman07
*/
--################### Head
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_lsd");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end
SWEP.Author = "Madman07, MarkJaw";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Use to detect life signs";
SWEP.Base = "weapon_base";
SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = false;
SWEP.ViewModel = "models/MarkJaw/LSD/LSD_v.mdl";
SWEP.WorldModel = "models/MarkJaw/LSD/LSD_w.mdl";
SWEP.ViewModelFOV = 90

-- Lol, without this we can't use this weapon in mp on gmod13...
if SERVER then
	AddCSLuaFile();
end

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "none";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "none";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);

--################### Dummys for the client @ aVoN
function SWEP:PrimaryAttack() return false end
function SWEP:SecondaryAttack() return false end

-- to cancel out default reload function
function SWEP:Reload() return end

if (SERVER) then

	function SWEP:Initialize()
		self.Sound = CreateSound(self,Sound("weapons/atlantis_scanner.wav"));
	end

	function SWEP:Deploy()
		self.Sound:PlayEx(0.9,100);
	end

	function SWEP:OnRemove()
		self.Sound:Stop();
	end

	function SWEP:Holster()
		self.Sound:Stop();
		return true
	end

end

if CLIENT then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

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

local matScreen = Material("Markjaw/LSD/screen");
local RTTexture = GetRenderTarget("LSD_Screen", 512, 1024);

local dot = surface.GetTextureID("Markjaw/LSD/dot");
local bg = surface.GetTextureID("Markjaw/LSD/screen_bg");

function SWEP:RenderScreen()
    local NewRT = RTTexture;
    local oldW = ScrW();
    local oldH = ScrH();
	local ply = LocalPlayer();

	matScreen:SetTexture( "$basetexture", NewRT);

    local OldRT = render.GetRenderTarget();
    render.SetRenderTarget(NewRT);
    render.SetViewPort( 0, 0, 512, 0);

    cam.Start2D();

		render.Clear( 50, 50, 100, 0 );

	    surface.SetDrawColor( 255, 255, 255, 255 );
        surface.SetTexture( bg );
        surface.DrawTexturedRect( 0, 0, 512, 1024);

		surface.SetTexture(dot);

		for k, v in pairs(ents.GetAll()) do
			if v:IsNPC() or v:IsPlayer() then
				local ang = ply:GetAngles();
				local pos = ply:GetPos() - v:GetPos();
				pos:Rotate(Angle(0, -1*ang.Yaw, 0));
				local x1 = 256 + pos.y/5;
				local y1 = 512 + 0.3*pos.x;
				if (math.abs(pos.z)<200) then
					surface.DrawTexturedRect(x1-16, y1-24, 32, 48);
				end
			end
		end

    cam.End2D();

    render.SetRenderTarget(OldRT);
    render.SetViewPort( 0, 0, oldW, oldH )

end

end