/*
	Staff Weapon for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
--################### Head
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_staff");
SWEP.Category = SGLanguage.GetMessage("weapon_cat");
end
SWEP.Author = "aVoN"
SWEP.Contact = "http://forums.facepunchstudios.com/aVoN"
SWEP.Purpose = "Kill Tau'ri"
SWEP.Instructions = "Ask your local Goa'uld master for instructions"
SWEP.Base = "weapon_base";
SWEP.Slot = 2;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= true;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/zup/staff/v_staff.mdl";
SWEP.WorldModel = "models/zup/staff/w_staff.mdl";

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 100;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "CombineCannon";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);
list.Add("NPCUsableWeapons", {class = "weapon_staff", title = SWEP.PrintName});

-- Add weapon for NPCs
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
list.Set("NPCWeapons","weapon_staff",SGLanguage.GetMessage("weapon_staff"));
end

--################### Deploy @aVoN
function SWEP:Deploy()
	-- Animation
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
	-- Muzzle
	self:Muzzle();
	if SERVER and IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound(self.Sounds.Deploy,math.random(90,110),math.random(90,110)) end;
	return true;
end

--################### Muzzleflash @aVoN
function SWEP:Muzzle()
	if (not IsValid(self.Owner)) then return end
	-- Muzzle
	local fx = EffectData();
	fx:SetScale(0);
	fx:SetOrigin(self.Owner:GetShootPos());
	fx:SetEntity(self.Owner);
	fx:SetAngles(Angle(255,200,120));
	fx:SetRadius(64);
	util.Effect("energy_muzzle",fx,true);
end

--################### Shoot @aVoN
function SWEP:PrimaryAttack()
	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	-- Muzzle
	self:Muzzle();
	-- Shot
	if SERVER then self:SVPrimaryAttack() end;
	self.Weapon:SetNextPrimaryFire(CurTime()+0.4);
	return true;
end

--################### We don't have secondary @aVoN
function SWEP:SecondaryAttack() return false end;
function SWEP:ShootEffects() return false end;
function SWEP:ShootBullet() return false end;