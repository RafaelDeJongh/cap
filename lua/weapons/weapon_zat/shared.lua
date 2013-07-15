/*
	Zat'nik'tel for GarrysMod10
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
if (not StarGate.CheckModule("weapon")) then return end
SWEP.PrintName = Language.GetMessage("weapon_zat");
SWEP.Category = Language.GetMessage("weapon_cat");
SWEP.Author = "aVoN"
SWEP.Contact = "http://forums.facepunchstudios.com/aVoN"
SWEP.Purpose = "Paralyze,Kill and let things disappear"
SWEP.Instructions = "Aim,fire,then ask questions"
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 4;
SWEP.DrawAmmo	= true;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/v_zat_tauri.mdl";
SWEP.WorldModel = "models/w_zat.mdl";

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 50;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo	= "GaussEnergy";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);
list.Add("NPCUsableWeapons", {class = "weapon_zat", title = SWEP.PrintName});

-- Add weapon for NPCs
list.Set("NPCWeapons","weapon_zat",Language.GetMessage("weapon_zat"));

--################### Deploy @aVoN
function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW); -- Animation
	if SERVER and IsValid(self.Owner) then
       self.Owner:EmitSound(self.Sounds.Deploy,90)
    end
end

--################### Holster @aVoN
function SWEP:Holster()
	self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER); -- Animation
	-- This fixes a gay bug, where the Zat's animation fades out and the new selected weapon too fast in so the new selected weapon has the Zat's model!
	local p = self.Owner;
	if(p:IsPlayer()) then
		timer.Simple(0.5,
			function()
				if(p and p:IsValid() and p:Alive()) then
					local w = p:GetActiveWeapon();
					if(w and w:IsValid()) then
						w:SendWeaponAnim(ACT_VM_DRAW);
					end
				end
			end
		);
	end
	if SERVER then self.Owner:EmitSound(self.Sounds.Holster,90) end
	return true;
end

--################### Shoot @aVoN
function SWEP:PrimaryAttack()
	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;
	-- Shot
	local add = 0.25;
	if((self.LastShot or 0)+1 > CurTime()) then
		add = 0;
		self.LastShot = CurTime()-0.3;
	else
		self.LastShot = CurTime();
	end
	if SERVER then self:SVPrimaryAttack(add == 0) end;
	local e = self.Weapon;
	-- Sync the animation with the show
	timer.Simple(add,
		function()
			if(e and e:IsValid()) then
				e:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
			end
		end
	);
	self.Weapon:SetNextPrimaryFire(CurTime()+0.4 + add);
end

--################### We don't have secondary @aVoN
function SWEP:SecondaryAttack() return false end
