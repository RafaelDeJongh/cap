/*
	Ringcaller for GarrysMod10
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
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
--################### Head
if SERVER then
	AddCSLuaFile(); -- GNAAA
else
	-- Inventory Icon
	if(file.Exists("materials/VGUI/weapons/ring_inventory.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/ring_inventory");
	end
	-- Kill Icon
	if(file.Exists("materials/VGUI/weapons/ring_killicon.vmt","GAME")) then
		killicon.Add("ring_ring","VGUI/weapons/ring_killicon",Color(255,255,255));
		killicon.Add("ring_base","VGUI/weapons/ring_killicon",Color(255,255,255));
		killicon.Add("ring_panel","VGUI/weapons/ring_killicon",Color(255,255,255));
	end
	--language.Add("ring_ring","Ring Transporter");
	--language.Add("ring_base","Ring Transporter Platform");
	--language.Add("ring_panel","Ring Panel"); -- Haha. how stupid. Killed by a panel
	-- Shit happens aVoN;p Especialy in gmod ;p (Mad)
end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_ring");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end
SWEP.Author = "aVoN"
SWEP.Contact = "http://forums.facepunchstudios.com/aVoN"
SWEP.Purpose = "Ring ring ring ring ring ring ring, banaphone"
SWEP.Instructions = "Aim and bring a ringga-ding-dong"
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 5;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/Iziraider/remote/v_remote.mdl";
SWEP.WorldModel = "models/Iziraider/remote/w_remote.mdl";
SWEP.HoldType = "slam"

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo	= "none";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "none";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

--################### Find near rings @aVoN
function SWEP:FindRing()
	local ring;
	local pos = self.Owner:GetPos();
	local trace = util.TraceLine(util.GetPlayerTrace(self.Owner));
	local dist = 500;
	-- First check if we are aiming at a ring to call
	for _,v in pairs(ents.FindInSphere(trace.HitPos,500)) do
		if(v:GetClass() == "ring_base_ancient" and not v.Busy) then
			local len = (trace.HitPos-v:GetPos()):Length();
			if(len < dist) then
				dist = len;
				ring = v;
			end
		end
		if(v:GetClass() == "ring_base_goauld" and not v.Busy) then
			local len = (trace.HitPos-v:GetPos()):Length();
			if(len < dist) then
				dist = len;
				ring = v;
			end
		end
		if(v:GetClass() == "ring_base_ori" and not v.Busy) then
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

--################### Call closest rings @aVoN
function SWEP:PrimaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	if(CLIENT) then return end;
	local ring = self:FindRing();
	if(IsValid(ring) and not ring.Busy) then
		ring.SetRange=0;
		ring:Dial("");
		self.Weapon:SetNextPrimaryFire(CurTime()+5);
	end
	self.Weapon:SetNextPrimaryFire(CurTime()+0.5);
end

--################### Open ring dial menue @aVoN
function SWEP:SecondaryAttack()
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	if(CLIENT) then return end;
	local ring = self:FindRing();
	if(IsValid(ring) and not ring.Busy) then
		self.Weapon:SetNextSecondaryFire(CurTime()+3);
		self.Owner.RingDialEnt = ring;
		-- Open the menue. For some gay reason, "SWEP:Primary/SecondaryAttack" is not getting called CLIENTSIDE. Atleast not in singleplayer. I don't know why. AND NO, i fucking tested it WITHOUT the if(CLIENT) then return end;, I'm not stupid!
		umsg.Start("RingTransporterShowWindowCap",self.Owner);
		umsg.End();
		return true;
	end
	self.Weapon:SetNextSecondaryFire(CurTime()+0.5);
end

--################### Tell a player how to use this @aVoN
function SWEP:DrawHUD()
	draw.WordBox(8,ScrW()-315,ScrH()-50,"Primary: Call nearest Rings    Secondary: Open Dialmenu","Default",Color(0,0,0,80),Color(255,220,0,220));
end
