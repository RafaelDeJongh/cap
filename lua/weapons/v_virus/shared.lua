if (not StarGate.CheckModule("extra")) then return end
SWEP.PrintName = Language.GetMessage("weapon_misc_virus");
SWEP.Category = Language.GetMessage("weapon_misc_cat");
SWEP.Author = "Llapp, Boba Fett, Assassin21";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Left Click = Activate Virus.";
SWEP.Base = "weapon_base";
SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/Assassin21/AGV/v_agv.mdl";
SWEP.WorldModel = "models/Assassin21/AGV/agv.mdl";
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