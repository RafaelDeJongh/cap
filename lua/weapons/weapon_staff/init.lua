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

if (not StarGate.CheckModule("weapon")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
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
			if(not (self and self.SetWeaponHoldType)) then return end;
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
