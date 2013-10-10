if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_adrenaline");
	SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end

list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

if (SERVER) then
	AddCSLuaFile("shared.lua");
end

SWEP.Author 		= "Gmod4phun, AlexALX"
SWEP.Purpose		= "Heal yourself during a battle."
SWEP.Instructions	= "Left click to heal yourself."

SWEP.AdminSpawnable = false
SWEP.Spawnable 		= false

SWEP.ViewModelFOV 	= 64
SWEP.ViewModel 		= "models/pg_props/pg_weapons/pg_shot_v.mdl"
SWEP.WorldModel 	= "models/pg_props/pg_stargate/pg_shot.mdl"

SWEP.AutoSwitchTo 	= false
SWEP.AutoSwitchFrom = true

SWEP.Slot 			= 1
SWEP.SlotPos = 1

SWEP.HoldType = "normal"

SWEP.FiresUnderwater = true

SWEP.Weight = 5

SWEP.DrawCrosshair = false

SWEP.DrawAmmo = true

SWEP.ReloadSound = ""

SWEP.base = "weapon_base"

SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = ""
SWEP.Primary.DefaultClip = -1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 3
SWEP.Primary.Cone = 0

SWEP.Secondary.NumberofShots = 0
SWEP.Secondary.Force = 0
SWEP.Secondary.Spread = 0
SWEP.Secondary.Sound = ""
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Delay = 2
SWEP.Secondary.TakeAmmo = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Damage = 0
SWEP.DrawWorldModel = true

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end


function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire(CurTime()+0.4)
	self:SetNextSecondaryFire(CurTime()+0.4)

	timer.Simple(0.32, function()
		if (IsValid(self)) then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)

	return true
end


function SWEP:PrimaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:SetNextPrimaryFire(CurTime()+3.4)

	if (SERVER) then
		timer.Simple(3, function()
			if (IsValid(self) and IsValid(self.Owner)) then
				self.Owner:StripWeapon(self:GetClass());
			end
		end)
	end

	timer.Simple(3.32, function()
		if (IsValid(self)) then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)

	timer.Simple(1.6, function()
		if (IsValid(self) and IsValid(self.Owner)) then
			if (self.Owner:Health()<120) then
				self.Owner:SetHealth(120)
			end
		end
	end)

	timer.Simple(0.6, function()
		if (IsValid(self)) then
			self:EmitSound("weapons/p90/p90_clipout.wav", 40, 170)
		end
	end)

	timer.Simple(1.5, function()
		if (IsValid(self)) then
			self:EmitSound("weapons/slam/mine_mode.wav", 100, 100)
		end
	end)

end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end