/*
	Sodan Cloaking Device for GarrysMod10
	Copyright (C) 2007  Catdaemon

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

if (not StarGate.CheckModule("extra")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
SWEP.Sounds = {Engage=Sound("tech/sodan_cloak_on.mp3"),Disengage=Sound("tech/sodan_cloak_off.mp3")};

--################### Set Holdtype @aVoN
function SWEP:Initialize()
	self:SetWeaponHoldType("melee");
end

--################### Primary Attack @Catdaemon
function SWEP:PrimaryAttack()
	if(not self.Owner:GetNetworkedBool("pCloaked",false)) then
		self.Owner:SetNetworkedBool("pCloaked",true);
		self.Owner:SetNoTarget(true);
		self.Owner:EmitSound(self.Sounds.Engage,90,math.random(97,103));
		self:DoCloakEffect();
		self.Weapon:SetNextSecondaryFire(CurTime()+0.8);
	end
	return true;
end

--################### Secondary Attack @Catdaemon
function SWEP:SecondaryAttack()
	if(self.Owner:GetNWBool("pCloaked",false)) then
		self.Owner:SetNWBool("pCloaked",false);
		self.Owner:SetNoTarget(false);
		self.Owner:EmitSound(self.Sounds.Disengage,90,math.random(97,103));
		self:DoCloakEffect();
		self.Weapon:SetNextPrimaryFire(CurTime()+0.8);
	end
	return true;
end

--################### Does the cloaking effect @aVoN
function SWEP:DoCloakEffect()
	local fx = EffectData();
	fx:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*10);
	fx:SetEntity(self.Owner);
	util.Effect("sodan_cloak",fx,true);
end

--################### Removes a bit health "due to the radiation" the cloak emits to get away phaseshifted insects,worms etc (which are the EVIL himself) @aVoN
-- No seriously, I added this so a person can't be cloaked infinite - http://mantis.39051.vs.webtropia.com/view.php?id=148
timer.Create("StarGate.SodanCloaking.DamagePlayerOverTime",1,0,
	function()
		for _,v in pairs(player.GetAll()) do
			if(IsValid(v) and v:GetNWBool("pCloaked",false)) then
				v.__Sodan = v.__Sodan or {};
				local t = v.__Sodan; -- Shorter code
				t.RandomHealthLossDelay = t.RandomHealthLossDelay or math.random(7,20);
				t.Activated = t.Activated or CurTime();
				if(t.Activated + t.RandomHealthLossDelay <= CurTime()) then
					v:TakeDamage(math.random(1,5),v,v);
					local hp = v:Health();
					if(hp > 0 and hp < 20) then
						v:SendLua("surface.PlaySound('hl1/fvox/radiation_detected.wav')");
					end
					-- For the next turn
					t.Activated = CurTime();
					t.RandomHealthLossDelay = math.random(7,20);
				end
			end
		end
	end
);

--################### PlayerDeath @aVoN
hook.Add("PlayerDeath","StarGate.SodanCloaking.PlayerDeath",
	function(p)
		if(IsValid(p)) then
			p:SetNWBool("pCloaked",false);
			p:SetNoTarget(false);
		end
	end
);