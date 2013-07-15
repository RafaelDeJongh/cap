if (not StarGate.CheckModule("extra")) then return end
SWEP.PrintName = Language.GetMessage("weapon_misc_gdhd");
SWEP.Category = Language.GetMessage("weapon_misc_cat");
SWEP.Author = "Madman07, Boba Fett";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Left Click = Open dial menu and plant the DHD.";
SWEP.Base = "weapon_base";
SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/Boba_Fett/portable_dhd/v_portable_dhd.mdl";
SWEP.WorldModel = "models/Boba_Fett/portable_dhd/portable_dhd.mdl";
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
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

--################### Dummys for the client @ aVoN
function SWEP:PrimaryAttack() return false end
function SWEP:SecondaryAttack() return false end

-- to cancel out default reload function
function SWEP:Reload() return end