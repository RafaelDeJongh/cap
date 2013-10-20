/*
	KINO Remote for Garry's Mod 11
	Scripted by Sutich and Madman07; Sources from aVoN's Stargate Mod
	Kino Remote Model by Iziraider
	Textures by Boba Fett
	Copyright (C) 2010

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

AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");
include("shared.lua");

SWEP.Sounds = {
	TurnOn = Sound("kino/kino_turn_on.wav"),
	Zoom = Sound("kino/kinozoom.wav"),
	SwitchMode1 = Sound("kino/kino_mode1.wav"),
	SwitchMode2 = Sound("kino/kino_mode2.wav"),
}

SWEP.AttackMode = 1;
SWEP.Delay = 5;

--################### Init the SWEP
function SWEP:Initialize()
	self:SetWeaponHoldType("slam");
	self.Range = StarGate.CFG:Get("mobile_dhd","range",3000);

	self.KinoActive = false;
	self.StartPos = self:GetPos();
	self.KinoNumber = 1;
	self.KinoEnt = {}
	self.CanZoom = true;
	self.FOV = 75;
end

--################### Initialize
function SWEP:PrimaryAttack(fast)
	local delay = 0;
	self.Weapon:SetNextPrimaryFire(CurTime()+0.5);
	local e = self.Weapon;
	timer.Simple(delay,
		function()
			if(IsValid(e) and IsValid(e.Owner)) then
				e:DoShoot();
				self:EmitSound(self.Sounds.SwitchMode1, 150);
			end
		end
	);
	return true;
end

--################### Secondary Attack @ aVoN
function SWEP:SecondaryAttack()

	if (self.KinoActive == false) then --Change our Mode only if not flying with kino
		self:EmitSound(self.Sounds.SwitchMode2, 150);
		local modes = 3;
		self.AttackMode = math.Clamp((self.AttackMode+1) % (modes + 1),1,modes);
		self.Weapon:SetNetworkedBool("Mode",self.AttackMode); -- Tell client, what mode we are in
		self.Owner._KinoRemoteMode = self.AttackMode; -- So modes are saved accross "session" (if he died it's the last mode he used it before)
	else -- if we using kino, switch control to other kino
		self.KinoNumber = self.KinoNumber + 1;

		local number = self:FindKino();
		if (self.KinoNumber > number) then self.KinoNumber = 1; end
		local e = self.KinoEnt[self.KinoNumber];
		if IsValid(e) then
			self.KinoEntActive.IsControlled = false;
			self.KinoEntActive = e;
			self.KinoEntActive.IsControlled = true;
			self.KinoEntActive:SwitchedKino(self.Owner);
			self.Owner:SetViewEntity(self.KinoEntActive)
			self.Owner:SetNWEntity("Kino", self.KinoEntActive);
		end

	end
end

--################### Reset Mode @ aVoN
function SWEP:OwnerChanged()
	self.AttackMode = self.Owner._KinoRemoteMode or 1;
	self.Weapon:SetNWBool("Mode",self.AttackMode);
end

--################### Do the shot
function SWEP:DoShoot()
	local p = self.Owner;
	if(not IsValid(p)) then return end;
	local pos = p:GetShootPos();
	if(self.AttackMode == 1) then
		if (self.KinoActive == false) then self:EnterKinoMode();
		else
			self.KinoActive = false;
			self:ExitKino();
		end
	elseif(self.AttackMode == 2) then
		self:OpenMenu(p);
	elseif(self.AttackMode == 3) then
		local ring = self:FindClosestRings();
		if(IsValid(ring) and not ring.Busy) then
			self.Owner.RingDialEnt = ring;
			umsg.Start("RingTransporterShowWindowCap",self.Owner);
			umsg.End();
		end
	end
end

function SWEP:Think()

	local nextthink = CurTime()+0.2;

	if (self.KinoActive == true) then
		if IsValid(self.KinoEntActive) then

			self.KinoEntActive:MoveKino();
			self.KinoEntActive:Keys();

			if (self.Owner:GetMoveType() == MOVETYPE_NOCLIP) then
				self.KinoEntActive:PrepareRemove();
				self:ExitKino(self.Owner);
				self.KinoActive = false;
			end

		else
			self.KinoActive = false
			self:ExitKino();
		end

	end

	self:NextThink(nextthink);
	return true
end

function SWEP:UpdateTransmitState() return TRANSMIT_ALWAYS; end

function SWEP:FindKino()
	local number = 0;
	self.KinoEnt = nil
	self.KinoEnt = {}
	for _,v in pairs(ents.FindByClass("kino_ball*")) do
		if (v.Owner == self.Owner) then
			table.insert(self.KinoEnt, v)
			number = number + 1;
		end
	end
	return number
end

function SWEP:EnterKinoMode()

	local number = self:FindKino();
	if(number == 0) then return end;

	self.FOV = self.Owner:GetFOV()

	if (self.KinoNumber > number) then self.KinoNumber = 1; end
	self.KinoEntActive = self.KinoEnt[self.KinoNumber]

	self.KinoActive = true;
	self:EnterKino();
end

function SWEP:EnterKino()
	self.FOV = self.Owner:GetFOV()
	self.StartPos = self.Owner:GetPos();
	self:EmitSound(self.Sounds.TurnOn, 150);
	--self.Owner:Spectate( OBS_MODE_FIXED );
	self.Owner:SetObserverMode( OBS_MODE_FIXED )
	self.Owner:SetMoveType(MOVETYPE_OBSERVER);
	--self.Owner:SetPos(self.Owner:GetPos()-Vector(0,0,65));
	self.Owner:SetEyeAngles(self.KinoEntActive:GetAngles());
	self.Owner:SetViewEntity(self.KinoEntActive)
	self.Owner:SetNWEntity("Kino", self.KinoEntActive);
	self.KinoEntActive:SwitchedKino(self.Owner);
	self.KinoEntActive.IsControlled = true;
	self.Owner:SetNWBool("KActive", true);
end

function SWEP:ExitKino()
	--self.Owner:UnSpectate();
	self.Owner:SetMoveType(MOVETYPE_VPHYSICS);
	self.Owner:Spawn();
	self.Owner:SetFOV(self.FOV,0.3);
	self.Owner:SetPos(self.StartPos + Vector(0,0,5)); -- whoa it repaired everythin
	self.Owner:Give("KinoRemote"); -- We get back our wep
	self.Owner:SelectWeapon("KinoRemote"); -- Finaly, we can hold our wep :)
	self.Owner:SetViewEntity(self.Owner);
	self.Owner:SetNWBool("KActive", false);
	self.Owner:SetNWEntity("Kino", NULL);
	if IsValid(self.KinoEntActive) then
		self.KinoEntActive:MoveKino(Vector(0,0,0));
		self.KinoEntActive.IsControlled = false;
	end
	self.KinoEntActive = NULL;
end

--################### Dialing Computer @Suitch
function SWEP:FindGate()
	local gate;
	local dist = self.Range;
	local pos = self.Owner:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate) then
			local sg_dist = (pos - v:GetPos()):Length();
			if(dist >= sg_dist) then
				dist = sg_dist;
				gate = v;
			end
		end
	end
	return gate;
end

--################# Open the menu @aVoN&Suitch
function SWEP:OpenMenu(p)
	if(not IsValid(p)) then return end;
	local e = self:FindGate();
	if(not IsValid(e)) then return end;
	if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,e) == false) then return end;
	umsg.Start("StarGate.OpenDialMenuDHD",p);
	umsg.Entity(e);
	umsg.End();
end

--################# Wire input - Relay to the gate @aVoN
function SWEP:TriggerInput(k,v)
	local gate = self:FindGate();
	if(IsValid(gate)) then
		gate:TriggerInput(k,v);
	end
end

--################### Find Closest Rings @aVoN
function SWEP:FindClosestRings()
	local ring;
	local pos = self.Owner:GetPos();
	local trace = util.TraceLine(util.GetPlayerTrace(self.Owner));
	local dist = 100;
	-- First check if we are aiming at a ring to call
	for _,v in pairs(ents.FindInSphere(trace.HitPos,100)) do
		if(v:GetClass() == "ring_base_ancient" and not v.Busy) then
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
		for _,v in pairs(ents.FindByClass("ring_base_ancient")) do
			local len = (pos-v:GetPos()):Length();
			if(len < dist) then
				dist = len;
				ring = v;
			end
		end
	end
	return ring;
end