SWEP.Category = "Stargate Carter Addon Pack: Misc"
SWEP.PrintName = "Minidrone Platform Key";
SWEP.Author = "Madman07";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Left Click = Fire Drones \nRight Click = Track Drones";
SWEP.Base = "weapon_base";
SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/Madman07/minidrone_platform/key_v.mdl";
SWEP.WorldModel = "models/Madman07/minidrone_platform/key_w.mdl";
SWEP.ViewModelFOV = 90  

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
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;

function SWEP:PrimaryAttack() return false end
function SWEP:SecondaryAttack() return false end
function SWEP:Reload() return end