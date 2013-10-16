--[[
	Puddle Jumper V4 for GarrysMod10
	Copyright (C) 2009-2012 RononDex,aVoN

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
]]--

--############# Header #################--
include("shared.lua");
include("client/cl_effects.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_jumper") or "Puddle Jumper";
end

if (StarGate==nil or StarGate.KeyBoard==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("PuddleJumper")

--Navigation
KBD:SetDefaultKey("FWD",StarGate.KeyBoard.BINDS["+forward"] or "W") -- Forward
KBD:SetDefaultKey("LEFT",StarGate.KeyBoard.BINDS["+moveleft"] or "A") -- Strafe Left
KBD:SetDefaultKey("RIGHT",StarGate.KeyBoard.BINDS["+moveright"] or "D") -- Strafe Right
KBD:SetDefaultKey("BACK",StarGate.KeyBoard.BINDS["+back"] or "S") -- Go backwards
KBD:SetDefaultKey("UP",StarGate.KeyBoard.BINDS["+jump"] or "SPACE") -- Strafe Up
KBD:SetDefaultKey("DOWN",StarGate.KeyBoard.BINDS["+duck"] or "CTRL") -- Strafe Down
KBD:SetDefaultKey("SPD",StarGate.KeyBoard.BINDS["+speed"] or "SHIFT") --  Drive Pods

--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN") -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP") -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset Roll

--Attack
KBD:SetDefaultKey("FIRE",StarGate.KeyBoard.BINDS["+attack"] or "MOUSE1") -- Fire Drones
KBD:SetDefaultKey("TRACK",StarGate.KeyBoard.BINDS["+attack2"] or "MOUSE2") -- Lock target on drones

--Special Actions
KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset roll
KBD:SetDefaultKey("CLOAK","ALT") -- Toggle Cloaking
KBD:SetDefaultKey("DHD","R") -- DHD
KBD:SetDefaultKey("HIDEHUD","H") -- Hide the pilot's HUD
KBD:SetDefaultKey("BOOM","BACKSPACE") -- Selfdestruct
KBD:SetDefaultKey("DOOR","2") -- Rear Door
KBD:SetDefaultKey("WEPPODS","Q") -- Weapon Pods
KBD:SetDefaultKey("LIGHT","F") -- Flashlight
KBD:SetDefaultKey("SHIELD","G") -- Shields
KBD:SetDefaultKey("HOVER","T") -- Hover

--View
KBD:SetDefaultKey("VIEW","1") -- Toggle FirstPerson View
KBD:SetDefaultKey("Z+","UPARROW") -- Change the zoom in
KBD:SetDefaultKey("Z-","DOWNARROW") -- Change the zoom out
KBD:SetDefaultKey("A+","LEFTARROW") -- View Go up
KBD:SetDefaultKey("A-","RIGHTARROW") -- View go down

KBD:SetDefaultKey("EXIT",StarGate.KeyBoard.BINDS["+use"] or "E")

ENT.Sounds={
	Engine=Sound("jumper/JumperEngineLoop.wav"),
	Hover=Sound("jumper/JumperHoverLoop.wav"),
}



local View = {
	Distance = 700,
	Angle = 200,
	HideHud = false,
	FirstPerson = false,
};

local JData = {};

--############# Sent Code ################--

function ENT:Initialize()

	self.Emitter = ParticleEmitter(self:GetPos());
	--self:SetShouldDrawInViewMode(true);
	self.Vehicle = "PuddleJumper";
	self:CreateHUD();
	self:UpdateHUD();


	self.KBD = self.KBD or KBD:CreateInstance(self);
	self.EngineSound = self.EngineSound or CreateSound(self.Entity,self.Sounds.Engine);
	self.HoverSound = self.HoverSound or CreateSound(self.Entity,self.Sounds.Hover);
	self.SoundsOn = {}; -- Stores whether the Hover or Engine sound is on or off

	self.NextUse = CurTime();
	self.JData = {};

end

function ENT:UpdateJData()
	if (JData.Entity!=self) then return end
	self.JData.Drones = JData.Drones;
	self.JData.Pods = JData.Pods;
	self.JData.CantCloak = JData.CantCloak;
	self.JData.Cloaked = JData.Cloaked;
	self.JData.CanShield = JData.CanShield;
	self.JData.CanShoot = JData.CanShoot;
	self.JData.Health = JData.Health;
	self.JData.Engine = JData.Engine;
end

function ENT:CreateHUD()
	if(not (self.HUD and self.HUD.Activate and self.HUD.Deactivate)) then
		if(self.HUD) then self.HUD:Remove() end; -- Delete invalid but existant previous HUD
		self.HUD = vgui.Create("JumperHUD",self); -- Player/Passenger indicator
		--self.HUD:SetParent(self);
	end
end

function ENT:UpdateHUD()
	--if not self.HUD:GetParent() == self then return end;
	if self.HUD and self.HUD.Active then
		self.HUD.Data.CantCloak = self.JData.CantCloak;
		self.HUD.Data.CanShoot = self.JData.CanShoot;
		self.HUD.Data.CanShield = self.JData.CanShield;
		self.HUD.Data.Cloaked = self.JData.Cloaked;
		self.HUD.Data.Engine = self.JData.Engine;
		self.HUD.Data.Drones = self.JData.Drones;
		self.HUD.Data.Health = self.JData.Health;
	end
end

--################# Calculate the players view @RononDex
local function JumperCalcView(Player,Origin,Angles,FieldOfView)
	local view = {};
	local p = LocalPlayer();
	local jumper = p:GetNetworkedEntity("jumper",NULL);
    if (IsValid(jumper) and p:GetNetworkedBool("isFlyingjumper",false)) then
    	local self = jumper;
		if(not View.FirstPerson)  then
			local pos = self.Entity:GetPos() + View.Angle*self.Entity:GetUp() - View.Distance*p:GetAimVector()
			local face = ((self.Entity:GetPos() + Vector(0,0,100))- pos):Angle()
			view.origin = pos
			view.angles = face
			view.fov = nil
		else
			local pos = self.Entity:GetPos()+self.Entity:GetForward()*75+self.Entity:GetUp()*25
			local angle = self.Entity:GetAngles()
			view.origin = pos
			view.angles = angle
			view.fov = FieldOfView + 20
		end
		return view;
	end
end
hook.Add("CalcView", "JumperCalcView", JumperCalcView)

function ENT:OnRemove()
	self.EngineSound:Stop();
	self.HoverSound:Stop();
	self.HUD:Remove();
end


local function SetData(um) --############# Recieve Data from the Server @RononDex
	JData.Entity = um:ReadEntity();
	JData.Drones = um:ReadShort();
	JData.Pods = um:ReadBool();
	JData.CantCloak = um:ReadBool();
	JData.Cloaked = um:ReadBool();
	JData.CanShield = um:ReadBool();
	JData.CanShoot = um:ReadBool();
	JData.Health = um:ReadShort();
	JData.Engine = um:ReadBool();
end
usermessage.Hook("jumperData", SetData)

function ENT:Draw() self:DrawModel() end

local num = 3.5
local y = ScrH()/4*num;
function ENT:Think() --#########################  Overly complex think function @ RononDex,LightDemon,aVoN


	local p = LocalPlayer();
	local Jumper = p:GetNWEntity("jumper");
	local IsInJumper = (Jumper == self.Entity); -- Is this "LocalPlayer" in/out jumper?
	local IsDriver = p:GetNWBool("isFlyingjumper",false) and IsInJumper;
	local HasDriver = IsDriver or false;

	if self.HUD and IsValid(self.HUD) then
		if self.HUD.Active then
			self:UpdateHUD();
		end
	elseif not self.HUD then
		self:CreateHUD();
	end

	self:UpdateJData();

	--###################### View Changers @ RononDex
	if(HasDriver) then
		if(p:KeyDown(self.Vehicle,"Z+")) then --In
			View.Distance = math.Clamp(View.Distance - 5,200,2000); --Can only go between 200 and 2000
		elseif(p:KeyDown(self.Vehicle,"Z-")) then --Out
			View.Distance = math.Clamp(View.Distance + 5,200,2000);
		end

		if(p:KeyDown(self.Vehicle,"A-")) then --Down
			View.Angle = math.Clamp(View.Angle - 5,-1000,1000)
		elseif(p:KeyDown(self.Vehicle,"A+")) then --Up
			View.Angle = math.Clamp(View.Angle + 5,-1000,1000)
		end

		if(p:KeyDown(self.Vehicle,"VIEW")) then
			if self.NextUse < CurTime() then
				if View.FirstPerson then
					View.FirstPerson = false;
				else
					View.FirstPerson = true;
				end
				self.NextUse = CurTime() + 1;
			end
		end

		if(p:KeyDown(self.Vehicle,"HIDEHUD")) then
			if self.NextUse < CurTime() then
				if View.HideHud then
					View.HideHud = false;
				else
					View.HideHud = true;
				end
				self.NextUse = CurTime() + 1;
			end
		end
	end

	--######## Draw the effects and activate keyboard
	if(HasDriver) then
		self.KBD:SetActive(true)
		if(self.JData.Pods) then
			if(not(self.JData.Cloaked)) then
				self:JumperEffects(true)
			else
				self:JumperEffects(false)
			end
			if self.JData.CantCloak then
				self:Smoke(true);
			else
				self:Smoke(false);
			end
		end
	else
		self.KBD:SetActive(false)
	end


	--######### Handle engine sound. If we are cloaked, there won't be ANY sound. Also the ability to run this clientside makes it easy to add DopplerEffects
	if(HasDriver) then
		-- Normal behaviour for Pilot or people who stand outside while the jumper is not cloaked
		if(IsInJumper) then
			self:StartClientsideSound("Hover");
			if(self.JData.Pods) then
				self:StartClientsideSound("Engine");
			else
				self:StopClientsideSound("Engine");
			end
		elseif(self.JData.Cloaked) then
			-- Cloak = don't play any sounds to players not in the jumper!
			self:StopClientsideSound("Hover");
			self:StopClientsideSound("Engine");
		end

		--#########  Now add Pitch etc
		local velo = self.Entity:GetVelocity();
		local pitch = self.Entity:GetVelocity():Length();
		local doppler = 0;
		-- For the Doppler-Effect!
		if(not IsInJumper) then
			-- Does the jumper fly to the player or away from him?
			local dir = (p:GetPos() - self.Entity:GetPos());
			doppler = velo:Dot(dir)/(150*dir:Length());
		end
		if(self.SoundsOn.Hover) then
			self.HoverSound:ChangePitch(math.Clamp(80 + pitch/20,100,120) + doppler,0);
		end
		if(self.SoundsOn.Engine) then
			self.EngineSound:ChangePitch(math.Clamp(60 + pitch/25,75,100) + doppler,0);
		end
	else
		self:StopClientsideSound("Hover");
		self:StopClientsideSound("Engine");
	end

	--####### HUD movement and activation
	if self.HUD and self.HUD:IsValid() then
		if Jumper == self then
			if HasDriver then
				if View.HideHud then
					self.HUD:Deactivate()
				else
					self.HUD:Activate()
				end
				if View.FirstPerson then
					num = math.Approach(num,2.65,0.025)
				else
					num = math.Approach(num,3.5,0.025)
				end
				y = ScrH()/4*num
				self.HUD:SetPos(x,y)
			else
				self.HUD:Deactivate()
			end
		end
	end
end

--################# Starts a sound clientside @aVoN
function ENT:StartClientsideSound(mode)
	if(not self.SoundsOn[mode]) then
		if(mode == "Hover") then
			self.HoverSound:Stop();
			self.HoverSound:SetSoundLevel(70);
			self.HoverSound:PlayEx(0.2,100);
		elseif(mode == "Engine") then
			self.EngineSound:SetSoundLevel(40);
			self.EngineSound:PlayEx(0.8,100);
			self.EngineSound:ChangePitch(0,0);
		end
		self.SoundsOn[mode] = true;
	end
end

--################# Stops a sound clientside @aVoN
function ENT:StopClientsideSound(mode)
	if(self.SoundsOn[mode]) then
		if(mode == "Hover") then
			self.HoverSound:FadeOut(2);
		elseif(mode == "Engine") then
			self.EngineSound:FadeOut(2);
		end
		self.SoundsOn[mode] = nil;
	end
end
