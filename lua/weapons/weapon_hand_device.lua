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
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);
--################### Dummys for the client @ aVoN
function SWEP:PrimaryAttack() return false end;
function SWEP:SecondaryAttack() return false end;

-- to cancel out default reload function
function SWEP:Reload() return end;

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
AddCSLuaFile();

SWEP.Sounds = {
	Shot={Sound("weapons/hd_shot1.mp3"),Sound("weapons/hd_shot2.mp3")},
	SwitchMode=Sound("buttons/button5.wav"),
};
SWEP.AttackMode = 1;
SWEP.MaxAmmo = 100;
SWEP.Delay = 5;
SWEP.TimeOut = 0.25; -- Time in seconds, a target will be tracked when hit with the beam

--################### Init the SWEP @ jdm12989
function SWEP:Initialize()
	self:SetWeaponHoldType("melee");
end

--################### Initialize the shot @ jdm12989
function SWEP:PrimaryAttack(fast)
	local ammo = self.Weapon:Clip1();
	local delay = 0;
	if(self.AttackMode == 1 and ammo >= 20 and not fast) then
		self.Owner:EmitSound(self.Sounds.Shot[1],90,math.random(96,102));
		self:PushEffect();
		delay = 0.3;
		self.Weapon:SetNextPrimaryFire(CurTime()+0.8);
	elseif(self.AttackMode == 2 and ammo >= 3) then
		self.Owner:SetNetworkedBool("shooting_hand",true);
		local time = CurTime();
		if((self.LastSound or 0)+0.9 < time) then
			self.LastSound = time;
			self.Owner:EmitSound(self.Sounds.Shot[2],90,math.random(96,102));
		end
		self.Weapon:SetNextPrimaryFire(CurTime()+0.1);
	else
		self.Weapon:SetNextPrimaryFire(CurTime()+0.5);
	end
	local e = self.Weapon;
	timer.Simple(delay,
		function()
			if(IsValid(e) and IsValid(e.Owner)) then
				e:DoShoot();
			end
		end
	);
	return true;
end

--################### Secondary Attack @ aVoN
function SWEP:SecondaryAttack()
	--Change our Mode
	local modes = 4; -- When you want to add more modes, jdm...
	self.AttackMode = math.Clamp((self.AttackMode+1) % (modes + 1),1,modes);
	self:EmitSound(self.Sounds.SwitchMode); -- Make some mode-change sounds
	--self.Owner:SetAmmo(self.Secondary.Ammo,self.AttackMode);
	self.Weapon:SetNWBool("Mode",self.AttackMode); -- Tell client, what mode we are in
	self.Owner.__HandDeviceMode = self.AttackMode; -- So modes are saved accross "session" (if he died it's the last mode he used it before)
end

--################### Reset Mode @ aVoN
function SWEP:OwnerChanged()
	self.AttackMode = self.Owner.__HandDeviceMode or 1;
	self.Weapon:SetNWBool("Mode",self.AttackMode);
end

--################### Do the shot @ jdm12989
function SWEP:DoShoot()
	local p = self.Owner;
	if(not IsValid(p)) then return end;
	local pos = p:GetShootPos();
	local normal = p:GetAimVector();
	local ammo = self.Weapon:Clip1();
	-- push attack
	if(self.AttackMode == 1) then
		if(ammo >= 20) then
			self:TakePrimaryAmmo(20);
			local direction = p:GetForward()*10000;
			for _,v in pairs(ents.FindInSphere(pos + (100*normal),75)) do
				if(v ~= self.Owner) then
					local phys = v:GetPhysicsObject();
					if(phys:IsValid()) then
						local allow = hook.Call("StarGate.HandDevice.Push",nil,v,p);
						if (allow==nil or allow) then
							if(v:IsNPC() or v:IsPlayer() and not v:HasGodMode()) then
								if(v:IsPlayer()) then
									v:SetMoveType(MOVETYPE_WALK);
								end
								v:SetVelocity(direction);
							end
							if(v.TakeDamage) then
								v:TakeDamage(70,p);
							end
							phys:ApplyForceOffset(direction,pos);
						end
					end
				end
			end
		end
	elseif(self.AttackMode == 2) then -- Kill-Beam
		if(ammo >= 3) then
			if(p:GetNetworkedBool("handdevice_depleted",false)) then
				p:SetNWBool("handdevice_depleted",false);
			end
			self:TakePrimaryAmmo(1);
			self:KillEffect();
			local time = CurTime();
			if(not self.Target or (self.LastHit or 0)+self.TimeOut < time) then
				self.LastHit = time;
				local trace = util.QuickTrace(pos,normal*200,p); -- Limit this to 200 units
				if(trace.Hit) then -- We hit someone or something
					if(trace.Entity and trace.Entity:IsValid()) then
						if(trace.Entity:IsPlayer() or trace.Entity:IsNPC()) then
							self.Target = trace.Entity;
						end
					end
				else
					self.Target = nil;
				end
			end
			if(IsValid(self.Target)) then
				self:TakePrimaryAmmo(2); -- When we hit someone, take 2 additional ammo!
				self.Target:TakeDamage(8,p);
				if(self.Target:IsPlayer() and not self.Target:HasGodMode()) then
					--################### Slowdown
					-- Garry fucked up SprintDisable/Enable with the latest updates
					--self.Target:SprintDisable();
					--timer.Create("StarGate.UnParalyze",4,1,self.Target.SprintEnable,self.Target);
					-- I hope this is not interfearing with any gamemodes... Blame garry if the handdevices makes you slow down permanently then!
					GAMEMODE:SetPlayerSpeed(self.Target,80,80);
					timer.Destroy("StarGate.UnParalyze"); -- Always start a fresh timer!
					timer.Create("StarGate.UnParalyze",4,1,function() if IsValid(self.Entity) and IsValid(self.Target) then GAMEMODE:SetPlayerSpeed(self.Target,250,500) end end);
				end
			else
				self.Target = nil;
			end
		else
			p:SetNWBool("handdevice_depleted",true);
		end
	elseif(self.AttackMode == 3) then -- Call nearest rings
		local ring = self:FindClosestRings();
		if(IsValid(ring) and not ring.Busy) then
			ring.SetRange=0;
			ring:Dial("");
			self.Weapon:SetNextPrimaryFire(CurTime()+3);
		end
	elseif(self.AttackMode == 4) then
		local ring = self:FindClosestRings();
		if(IsValid(ring) and not ring.Busy) then
			self.Owner.RingDialEnt = ring;
			umsg.Start("RingTransporterShowWindowCap",self.Owner);
			umsg.End();
		end
	end
end

--################### Think @ jdm12989
function SWEP:Think()
	if(self.AttackMode == 2 and self.Owner:GetNWBool("shooting_hand",false) and not self.Owner:KeyDown(IN_ATTACK)) then
		self.Owner:SetNWBool("shooting_hand",false);
	end
	local time = CurTime();
	if((self.LastThink or 0) + 0.1 < time) then
		self.LastThink = time;
		--primary reserve
		local ammo = self.Owner:GetAmmoCount(self.Primary.Ammo);
		if(ammo > self.Delay) then
			self.Owner:RemoveAmmo(ammo-self.Delay,self.Primary.Ammo);
		end
		--primary ammo
		local ammo = self.Weapon:Clip1();
		local set = math.Clamp(ammo+1,0,self.MaxAmmo);
		self.Weapon:SetClip1(set);
	end
end

--################### Do a push @ jdm12989
function SWEP:PushEffect()
	local e = self.Owner;
	-- Timer fixes bug, where you cant see your own effect
	timer.Simple(0.1,
		function()
			if(e and e:IsValid()) then
				local fx = EffectData();
				fx:SetEntity(e);
				fx:SetOrigin(e:GetPos());
				util.Effect("hd_push",fx,true,true);
			end
		end
	);
end

-- FIXME: SERIOUSLY, this needs to put into clientside!!!!!
--################### Do the beam effect@aVoN
function SWEP:KillEffect()
	local spectating = 1;
	if(self.Owner:IsPlayer() and self.Owner:GetViewEntity() == self.Owner) then spectating = 0 end;
	local fx = EffectData();
	fx:SetScale(spectating);
	fx:SetEntity(self.Owner);
	fx:SetOrigin(self.Owner:GetShootPos());
	util.Effect("hd_kill",fx,true,true);
end

--################### Find Closest Rings @aVoN
function SWEP:FindClosestRings()
	local ring;
	local pos = self.Owner:GetPos();
	local trace = util.TraceLine(util.GetPlayerTrace(self.Owner));
	local dist = 100;
	-- First check if we are aiming at a ring to call
	for _,v in pairs(ents.FindInSphere(trace.HitPos,100)) do
		if(v:GetClass():find("ring_base_*") and not v.Busy) then
			local len = (trace.HitPos-v:GetPos()):Length();
			if(len < dist) then
				dist = len;
				ring = v;
			end
		end
	end
	-- Not found a ring? Well, call closest
	if(not ring) then
		local dist = 500;
		for _,v in pairs(ents.FindByClass("ring_base_*")) do
			local len = (pos-v:GetPos()):Length();
			if(len < dist) then
				dist = len;
				ring = v;
			end
		end
	end
	return ring;
end

end

if CLIENT then

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/hand_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/hand_inventory");
end
-- Kill Icon
if(file.Exists("materials/VGUI/weapons/hand_killicon.vmt","GAME")) then
	killicon.Add("weapon_hand_device","VGUI/weapons/hand_killicon",Color(255,255,255));
end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("Battery_ammo",SGLanguage.GetMessage("naquadah"));
language.Add("weapon_hand_device",SGLanguage.GetMessage("weapon_hand_device"));
end

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - 7*a:Up() - 6*a:Forward() + 1*a:Right();
	a:RotateAroundAxis(a:Right(),20);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end

--################### Tell a player how to use this @aVoN
function SWEP:DrawHUD()
	local mode = "Push";
	local int = self.Weapon:GetNetworkedInt("Mode",1);
	if(int == 1) then
		mode = "Push";
	elseif(int == 2) then
		mode = "Cook Brain";
	elseif(int == 3) then
		mode = "Call Nearest Rings";
	elseif(int == 4) then
		mode = "Open Ring Dial Menu";
	end
	draw.WordBox(8,ScrW()-188,ScrH()-120,"Primary: "..mode,"Default",Color(0,0,0,80),Color(255,220,0,220));
end

end