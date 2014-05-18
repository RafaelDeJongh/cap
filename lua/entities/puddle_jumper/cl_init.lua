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

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_jumper") or "Puddle Jumper";
end

if (StarGate==nil or StarGate.KeyBoard==nil or StarGate.KeyBoard.New==nil) then return end

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
KBD:SetDefaultKey("HIDELSD","L") -- Hide the pilot's HUD
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
	HideLSD = false,
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
	self.JData.Inflight = JData.Inflight;
end

function ENT:CreateHUD()
	if(not (self.HUD and self.HUD.Activate and self.HUD.Deactivate)) then
		if(self.HUD) then self.HUD:Remove() end; -- Delete invalid but existant previous HUD
		self.HUD = vgui.Create("JumperHUD",self); -- Player/Passenger indicator
		--self.HUD:SetParent(self);
	end
	if(not (self.LSD and self.LSD.Activate and self.LSD.Deactivate)) then
		if(self.LSD) then self.LSD:Remove() end;
		self.LSD = vgui.Create("JumperLSD",self);
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
	local passJumper = p:GetNetworkedEntity("JumperSeat",NULL);
	local Passenger = p:GetNetworkedBool("JumperPassenger",false);
    if (IsValid(jumper) and p:GetNetworkedBool("isFlyingjumper",false)) then
    	local self = jumper;
		if(not View.FirstPerson)  then
			local pos = self:GetPos() + View.Angle*self:GetUp() - View.Distance*p:GetAimVector()
			local face = ((self:GetPos() + Vector(0,0,100))- pos):Angle()
			view.origin = pos
			view.angles = face
			view.fov = nil
		else
			local pos = self:GetPos()+self:GetForward()*75+self:GetUp()*25
			local angle = self:GetAngles()
			view.origin = pos
			view.angles = angle
			view.fov = FieldOfView + 20
		end
		return view;
	elseif(Passenger) then
		if(IsValid(passJumper)) then
			if(passJumper:GetThirdPersonMode()) then
				local pos = passJumper:GetPos() + View.Angle*passJumper:GetUp() - View.Distance*p:GetAimVector()
				local face = ((passJumper:GetPos() + Vector(0,0,100))- pos):Angle()
				view.origin = pos
				view.angles = face
				view.fov = nil
				return view;
			end
		end
	end
end
hook.Add("CalcView", "JumperCalcView", JumperCalcView)

function ENT:OnRemove()
	self.EngineSound:Stop();
	self.HoverSound:Stop();
	self.HUD:Remove();
	self.LSD:Remove();
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
	JData.Inflight = um:ReadBool();
end
usermessage.Hook("jumperData", SetData)

local invisible = Color(255,255,255,1);
local visible = Color(255,255,255,255);
function ENT:Draw()
	self.BaseClass.Draw(self);
	if(game.SinglePlayer()) then
		local p = LocalPlayer();
		local Jumper = p:GetNWEntity("jumper");
		local IsInJumper = (Jumper == self.Entity); -- Is this "LocalPlayer" in/out jumper?
		local IsDriver = p:GetNWBool("isFlyingjumper",false) and IsInJumper;
		local Inflight = self:GetNetworkedBool("JumperInflight",false);
		local Cloaked = self:GetNetworkedBool("Cloaked",false);


		if(IsValid(self)) then
			if(Cloaked) then
				if(Inflight and IsInJumper) then
					if(View.FirstPerson) then
						self:SetColor(visible);
						self.RenderGroup = RENDERGROUP_OPAQUE;
					else
						self:SetColor(invisible);
						self.RenderGroup = RENDERGROUP_BOTH;
					end
				elseif(Inflight and not p:GetNWBool("isFlyingjumper")) then
					self:SetColor(invisible);
					self.RenderGroup = RENDERGROUP_BOTH;
				else
					for a,p in pairs(ents.GetAll()) do
						if(p:IsPlayer()) then
							if(self:InJumper(p)) then
								self:SetColor(visible);
								self.RenderGroup = RENDERGROUP_OPAQUE;
							else
								self:SetColor(invisible);
								self.RenderGroup = RENDERGROUP_BOTH;
							end
						end
					end
				end
			else
				self:SetColor(visible);
				self.RenderGroup = RENDERGROUP_OPAQUE;
			end
		end
	end
end

local num = 3.3;
local y = ScrH()/4*num;
function ENT:Think() --#########################  Overly complex think function @ RononDex,LightDemon,aVoN


	local p = LocalPlayer();
	local Jumper = p:GetNWEntity("jumper");
	local IsInJumper = (Jumper == self.Entity); -- Is this "LocalPlayer" in/out jumper?
	local IsDriver = p:GetNWBool("isFlyingjumper",false) and IsInJumper;
	local Inflight = self:GetNetworkedBool("JumperInflight",false);
	local HasDriver = IsDriver or false;
	local Passenger = p:GetNetworkedBool("JumperPassenger",false);
	local passJumper = p:GetNetworkedEntity("JumperPassenger");
	local jumperSeat  = p:GetNetworkedEntity("JumperSeat");

	if(IsDriver and IsInJumper) then
		if self.HUD and IsValid(self.HUD) then
			if self.HUD.Active then
				self:UpdateHUD();
			end
		elseif not self.HUD or not self.LSD then
			self:CreateHUD();
		end
		if(not self.LSD.Active) then
			if(View.FirstPerson) then
				self.LSD:Activate();
			end
		end
	end

	if(game.SinglePlayer()) then
		local min = self:GetPos()+self:GetForward()*100+self:GetUp()*50+self:GetRight()*50;
		local max = self:GetPos()-self:GetForward()*190-self:GetUp()*50-self:GetRight()*50;
		local Cloaked = self:GetNetworkedBool("Cloaked",false);
		if(IsValid(self) and not Inflight) then
			for k,v in pairs(ents.FindInBox(min,max)) do
				local renderm = v:GetRenderMode();
				if(v:IsPlayer() or v:IsNPC()) then
					local wep = v:GetActiveWeapon();
					if(IsValid(wep)) then local wepren = wep:GetRenderMode() end;
					if(self:InJumper(v)) then
						if(Cloaked) then
							v:SetRenderMode( RENDERMODE_TRANSALPHA )
							v:SetColor(invisible);
							if(IsValid(v:GetActiveWeapon())) then
								wep:SetRenderMode(RENDERMODE_TRANSALPHA);
								wep:SetColor(invisible);
							end
						else
							if(renderm != v:GetRenderMode()) then
								v:SetRenderMode(renderm);
							end
							v:SetColor(visible);
							if(IsValid(wep)) then
								if(wepren != wep:GetRenderMode() and IsValid(wepren)) then
									wep:SetRenderMode(wepren);
								end
								wep:SetColor(visible);
							end
						end
					end
				end
			end
		end
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
					self.LSD:Deactivate();
				else
					View.FirstPerson = true;
					if(IsValid(self.LSD)) then
						self.LSD:Activate();
					end
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

		if(p:KeyDown(self.Vehicle,"HIDELSD")) then
			if self.NextUse < CurTime() then
				if View.HideLSD then
					View.HideLSD = false;
				else
					View.HideLSD = true;
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
					num = math.Approach(num,3.3,0.025)
				end
				if(View.FirstPerson) then
					if View.HideLSD then
						self.LSD:Deactivate();
					else
						self.LSD:Activate();
					end
				end
				y = ScrH()/4*num
				self.HUD:SetPos(x,y)
			else
				self.HUD:Deactivate();
				self.LSD:Deactivate();
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


local ATTACHMENTS = {"epodleft","epodright"};
--################ Add smoke effect @ RononDex
local UP = Vector(0,0,50); -- Smoke always moves up
function ENT:Smoke(b)

	local p = LocalPlayer();
	local jumper = p:GetNetworkedEntity("jumper",NULL);

	if(b) and (jumper and jumper:IsValid() and jumper==self) then
		local fwd = self:GetForward()
		local vel = self:GetVelocity()
		local roll = math.Rand(-90,90)

		local data = self:GetAttachment(self:LookupAttachment("epodright"))
		if(not (data and data.Pos)) then return end -- Old or no valid model - Don't draw!
		local pos = data.Pos


		local particle = self.Emitter:Add("effects/blood2",pos)
		particle:SetVelocity(vel - 500*fwd+UP)
		particle:SetDieTime(0.6)
		particle:SetStartAlpha(200)
		particle:SetEndAlpha(0)
		particle:SetStartSize(15)
		particle:SetEndSize(20)
		particle:SetColor(40,40,40)
		particle:SetRoll(roll)

		--self.Emitter:Finish()
	end
end

--############## Add engine pod effects(Lights, sprites etc) @ RononDex
function ENT:JumperEffects(b)

	local p = LocalPlayer();
	local jumper = p:GetNWEntity("jumper",NULL);

	if(b) and (jumper and jumper:IsValid() and jumper==self) then
		local FWD = self:GetForward();
		local vel = self:GetVelocity();
	--	local roll = math.Rand(-90,90);
		local roll = math.Rand(-45,45);
		local id = self:EntIndex();
		local normal = (self.Entity:GetForward() * -1):GetNormalized();

		for k,v in pairs(ATTACHMENTS) do
			local data = self:GetAttachment(self:LookupAttachment(v))
			if(not (data and data.Pos)) then return end -- Old or no valid model - Don't draw!
			local pos = data.Pos

			-- Blue core
			if(StarGate.VisualsShips("cl_jumper_sprites")) then
 				local particle = self.Emitter:Add("sprites/bluecore",pos+FWD*-10);
				particle:SetVelocity(vel - 500*FWD);
				particle:SetDieTime(0.015);
				particle:SetStartAlpha(150);
				particle:SetEndAlpha(150);
				particle:SetStartSize(22.5);
				particle:SetEndSize(22.5);
				particle:SetColor(255,255,255);
				particle:SetRoll(roll);
			end

			-- Heatwave
			if(StarGate.VisualsShips("cl_jumper_heatwave")) then
				local heatwv = self.Emitter:Add("sprites/heatwave",pos+FWD*-15);
				heatwv:SetVelocity(normal*2);
				heatwv:SetDieTime(0.1);
				heatwv:SetStartAlpha(255);
				heatwv:SetEndAlpha(255);
				heatwv:SetStartSize(35);
				heatwv:SetEndSize(20);
				heatwv:SetColor(255,255,255);
				heatwv:SetRoll(roll);
			end

			-- Light from the engine
			if(StarGate.VisualsShips("cl_jumper_dynlights")) then
				local dynlight = DynamicLight(id + 4096*k);
				dynlight.Pos = pos+FWD*-25;
				dynlight.Brightness = 5;
				dynlight.Size = 334;
				dynlight.Decay = 1024;
				dynlight.R = 124;
				dynlight.G = 205;
				dynlight.B = 235;
				dynlight.DieTime = CurTime()+1;
			end
		end
		--self.Emitter:Finish();
	end
end