/*
	Ronon Dex's Gun for GarrysMod10
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
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
SWEP.Sounds = {Shot={Sound("pulse_weapon/dexgun1.mp3"),Sound("pulse_weapon/dexgun2.mp3")},Deploy=Sound("pulse_weapon/dexgun_engage.mp3")};

--################### Init the SWEP @aVoN
function SWEP:Initialize()
	-- Sets how fast and how much shots an NPC shall do
	self:SetNPCFireRate(0.6);
	self:SetNPCMinBurst(0);
	self:SetNPCMaxBurst(0);
	self:SetWeaponHoldType("pistol");
	self.NextUse = CurTime()

end

--################### Initialize the shot @aVoN
function SWEP:SVPrimaryAttack()
	local p = self.Owner;
	local multiply = 3; -- Default inaccuracy multiplier
	local aimvector = p:GetAimVector();
	local shootpos = p:GetShootPos();
	local vel = p:GetVelocity();
	local filter = {self.Owner,self.Weapon};
	-- Add inaccuracy for players!
	if(p:IsPlayer()) then
		local right = aimvector:Angle():Right();
		local up = aimvector:Angle():Up();
		-- Check, how far we can go to right (avoids exploding shots on the wall right next to you)
		local max = util.QuickTrace(shootpos,right*100,filter).Fraction*100 - 10;
		local trans = right:DotProduct(vel)*right/25
		if(p:Crouching()) then
			multiply = 0.3; -- We are in crouch - Make it really accurate!
			-- We need to adjust shootpos or it will look strange
			shootpos = shootpos + math.Clamp(15,-10,max)*right - 4*up + trans;
		else
			-- He stands
			shootpos = shootpos + math.Clamp(23,-10,max)*right - 15*up + trans;
		end
		multiply = multiply*math.Clamp(vel:Length()/500,0.3,3); -- We are moving - Make it inaccurate depending on the velocity
	else -- It's an NPC
		multiply = 0;
	end
	-- Now, we need to correct the velocity depending on the changed shootpos above.
	local trace = util.QuickTrace(p:GetShootPos(),16*1024*aimvector,filter);
	if(trace.Hit) then
		aimvector = (trace.HitPos-shootpos):GetNormalized();
	end
	-- Add some randomness to the velocity
	if not self.Stun then
		local e = ents.Create("energy_pulse");
		e:PrepareBullet(aimvector, multiply, 8000, 1);
		e:SetPos(shootpos);
		e:SetOwner(p);
		e.Owner = p;
		e:Spawn();
		e:Activate();
		e:SetColor(Color(255,50,50,255));
		p:EmitSound(self.Sounds.Shot[math.random(1,#self.Sounds.Shot)],90,math.random(97,103));
		if(self.Owner:IsPlayer()) then self:TakePrimaryAmmo(1) end; -- Take one Ammo
	else
		local e = ents.Create("energy_pulse_stun");
		e:PrepareBullet(aimvector, multiply, 8000, 1);
		e:SetPos(shootpos);
		e:SetOwner(p);
		e.Owner = p;
		e:Spawn();
		e:Activate();
		e:SetColor(Color(255,50,50,255));
		p:EmitSound(self.Sounds.Shot[math.random(1,#self.Sounds.Shot)],90,math.random(97,103));
		if(self.Owner:IsPlayer()) then self:TakePrimaryAmmo(1) end; -- Take one Ammo
	end
end

function SWEP:Reload()

	if self.NextUse < CurTime() then
		if not self.Stun then
			self.Stun = true;
			self:EmitSound(self.Sounds.Deploy,100,115);
			self:SetNetworkedInt("Mode",1);
		else
			self.Stun = false;
			self:EmitSound(self.Sounds.Deploy,100,105);
			self:SetNWInt("Mode",2);
		end
		self.NextUse = CurTime() + 1;
	end
end