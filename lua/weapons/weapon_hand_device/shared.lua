/*
	Hand Device for GarrysMod10
	Copyright (C) 2007

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
SWEP.Category = SGLanguage.GetMessage("weapon_cat");
SWEP.PrintName = SGLanguage.GetMessage("weapon_hand_device");
end
SWEP.Author = "JDM12989 & aVoN";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Left Click = Push/Kill/Rings\nRight Click = Change Mode";
SWEP.Base = "weapon_base";
SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= true;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/weapons/v_models/v_hdevice.mdl";
SWEP.WorldModel = "models/w_hdevice.mdl";

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 100;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "Battery";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);
--################### Dummys for the client @ aVoN
function SWEP:PrimaryAttack() return false end;
function SWEP:SecondaryAttack() return false end;

-- to cancel out default reload function
function SWEP:Reload() return end;