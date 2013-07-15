/*
	Life Sign Detector
	Copyright (C) 2010 Madman07
*/
--################### Head
if (not StarGate.CheckModule("extra")) then return end
SWEP.PrintName = Language.GetMessage("weapon_misc_lsd");
SWEP.Category = Language.GetMessage("weapon_misc_cat");
SWEP.Author = "Madman07, MarkJaw";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Use to detect life signs";
SWEP.Base = "weapon_base";
SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/MarkJaw/LSD/LSD_v.mdl";
SWEP.WorldModel = "models/MarkJaw/LSD/LSD_w.mdl";
SWEP.ViewModelFOV = 90

-- Lol, without this we can't use this weapon in mp on gmod13...
if SERVER then
	AddCSLuaFile("shared.lua");
	AddCSLuaFile("cl_init.lua");
	AddCSLuaFile("cl_viewscreen.lua");
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
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

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