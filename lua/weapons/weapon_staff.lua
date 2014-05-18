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
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);
-- Add weapon for NPCs
list.Add("NPCUsableWeapons", {class = "weapon_staff", title = SWEP.PrintName or ""});

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

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
AddCSLuaFile();
SWEP.Sounds = {Shot=Sound("pulse_weapon/staff_weapon.mp3"),Deploy=Sound("pulse_weapon/staff_engage.mp3"),Holster=Sound("pulse_weapon/staff_holster.mp3")};

--################### Init the SWEP @aVoN
function SWEP:Initialize()
	-- Sets how fast and how much shots an NPC shall do
	self:SetNPCFireRate(0.6);
	self:SetNPCMinBurst(0);
	self:SetNPCMaxBurst(0);
	-- Set holdtype, depending on NPCs, so it doesn't look too strange
	timer.Simple(0.2,
		function()
			if(not (IsValid(self) and self.SetWeaponHoldType)) then return end;
			if(self.Owner and self.Owner:IsValid() and self.Owner:IsNPC()) then
				local class = self.Owner:GetClass();
				if(class ~= "npc_metropolice") then
					self:SetWeaponHoldType("ar2");
				end
			end
		end
	);
	self:SetWeaponHoldType("shotgun");
end

--################### Holster @aVoN
function SWEP:Holster()
	self.Owner:EmitSound(self.Sounds.Holster,90,math.random(90,110));
	return true;
end

--################### Shoot @aVoN
function SWEP:SVPrimaryAttack()

	self.Weapon:SetNextPrimaryFire(CurTime()+0.4);

	local p = self.Owner;
	local multiply = 10; -- Default inaccuracy multiplier
	local aimvector = p:GetAimVector();
	local shootpos = p:GetShootPos();
	local vel = p:GetVelocity();
	local filter = {self.Owner,self.Weapon};
	if(p:IsPlayer()) then -- Player is holding the weapon
		-- Some translation to make the shot look like it always comes out from the weapon's front depending how fast the player moves
		local right = aimvector:Angle():Right();
		local up = aimvector:Angle():Up();
		-- Check, how far we can go to right (avoids exploding shots on the wall right next to you)
		local max = util.QuickTrace(shootpos,right*100,filter).Fraction*100 - 10;
		local trans = right:DotProduct(vel)*right/25
		if(p:Crouching()) then
			multiply = 1; -- We are in crouch - Make it really accurate!
			-- We need to adjust shootpos or it will look strange
			shootpos = shootpos + math.Clamp(15,-10,max)*right - 4*up + trans;
		else
			-- He stands
			shootpos = shootpos + math.Clamp(23,-10,max)*right - 15*up + trans;
		end
		multiply = multiply*math.Clamp(vel:Length()/80,1,10); -- We are moving - Make it inaccurate depending on the velocity
	else -- It's an NPC
		multiply = 0;
	end
	-- Now, we need to correct the velocity depending on the changed shootpos above.
	local t = util.QuickTrace(p:GetShootPos(),16*1024*aimvector,filter);
	if(t.Hit) then
		aimvector = (t.HitPos-shootpos):GetNormalized();
	end
	-- Add some randomness to the velocity
	local e = ents.Create("energy_pulse");
	e:PrepareBullet(aimvector, multiply, 8000, 2);
	e:SetPos(shootpos);
	e:SetOwner(p);
	e.Owner = p;
	e:Spawn();
	e:Activate();
	p:EmitSound(self.Sounds.Shot,90,math.random(90,110));
	if(self.Owner:IsPlayer()) then self:TakePrimaryAmmo(1) end; -- Take one Ammo
end

end

if CLIENT then

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/staff_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/staff_inventory");
end
-- Kill Icon
if(file.Exists("materials/VGUI/weapons/staff_killicon.vmt","GAME")) then
	killicon.Add("weapon_staff","VGUI/weapons/staff_killicon",Color(255,255,255));
	killicon.Add("staff_pulse","VGUI/weapons/staff_killicon",Color(255,255,255));
end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("CombineCannon_ammo",SGLanguage.GetMessage("liquid_naquadah"));
language.Add("weapon_staff",SGLanguage.GetMessage("weapon_staff"));
end

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - 70*a:Up() - 13*a:Forward() + 2*a:Right();
	a:RotateAroundAxis(a:Right(),5);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end

end