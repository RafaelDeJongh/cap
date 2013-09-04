/*
	Zat for GarrysMod10
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
SWEP.PrintName = SGLanguage.GetMessage("weapon_ronongun");
SWEP.Category = SGLanguage.GetMessage("weapon_cat");
end
SWEP.Author = "aVoN"
SWEP.Contact = "http://forums.facepunchstudios.com/aVoN"
SWEP.Purpose = "Kill"
SWEP.Instructions = "Aim,fire,then ask questions"
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= true;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/weapons/v_dexgun.mdl";
SWEP.WorldModel = "models/w_dexgun.mdl";

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 100;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo	= "HelicopterGun";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);
list.Add("NPCUsableWeapons", {class = "weapon_dexgun", title = SWEP.PrintName});

-- Add weapon for NPCs
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
list.Set("NPCWeapons","weapon_dexgun",SGLanguage.GetMessage("weapon_ronongun"));
end

--################### Deploy @aVoN
function SWEP:Deploy()
	if (IsValid(self.Weapon)) then
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW); -- Animation
	end
	if SERVER and IsValid(self) and IsValid(self.Owner) then self.Owner:EmitSound(self.Sounds.Deploy,90) end;
end

--################### Shoot @aVoN
function SWEP:PrimaryAttack()
	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	-- Muzzle
	local fx = EffectData();
	fx:SetScale(0);
	fx:SetOrigin(self.Owner:GetShootPos());
	fx:SetEntity(self.Owner);
	fx:SetAngles(Angle(255,50,50));
	fx:SetRadius(64);
	util.Effect("energy_muzzle",fx,true);
	-- Shot
	if SERVER then self:SVPrimaryAttack() end;
	self.Weapon:SetNextPrimaryFire(CurTime()+0.2);
	return true;
end

