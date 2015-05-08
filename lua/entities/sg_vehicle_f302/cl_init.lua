include("shared.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_f302");
end
ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.ViewOverride = true;

if (StarGate==nil or StarGate.KeyBoard==nil or StarGate.KeyBoard.New==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("F302");
--Navigation
KBD:SetDefaultKey("FWD",StarGate.KeyBoard.BINDS["+forward"] or "W"); -- Forward
KBD:SetDefaultKey("SPD",StarGate.KeyBoard.BINDS["+speed"] or "SHIFT"); --  Boost
--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN"); -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP"); -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3"); -- Reset Roll
--Attack
KBD:SetDefaultKey("FIRE",StarGate.KeyBoard.BINDS["+attack"] or "MOUSE1"); -- Fire missiles
KBD:SetDefaultKey("TRACK",StarGate.KeyBoard.BINDS["+attack2"] or "MOUSE2"); -- Track missiles
--Special Actions
KBD:SetDefaultKey("CHGATK","R"); --  Toggle Bullets and Missiles
KBD:SetDefaultKey("WHEELS",StarGate.KeyBoard.BINDS["+duck"] or "CTRL");
KBD:SetDefaultKey("FLARES","ALT");
KBD:SetDefaultKey("EJECT","2");
KBD:SetDefaultKey("BRAKE",StarGate.KeyBoard.BINDS["+jump"] or "SPACE");
KBD:SetDefaultKey("BOOST","B");
KBD:SetDefaultKey("COCKPIT","3");
--View
KBD:SetDefaultKey("Z+","UPARROW");
KBD:SetDefaultKey("Z-","DOWNARROW");
KBD:SetDefaultKey("A+","LEFTARROW");
KBD:SetDefaultKey("A-","RIGHTARROW");
KBD:SetDefaultKey("FPV","1");
KBD:SetDefaultKey("HIDE","H");

KBD:SetDefaultKey("BOOM","BACKSPACE")
KBD:SetDefaultKey("EXIT",StarGate.KeyBoard.BINDS["+use"] or "E")

ENT.Sounds={
	Engine=Sound("f302/f302_Engine.wav"),
}

local w = ScrW()*0.99;
local font = {
	font = "Default",
	size = (w/1024)*60,
	weight = 400,
	antialias = true,
	additive = false,
}
surface.CreateFont("F302Font", font);
local font = {
	font = "Default",
	size = (w/1024)*50,
	weight = 150,
	antialias = true,
	additive = false,
}
surface.CreateFont("MainF302Font", font);

function ENT:Initialize()
	self.BaseClass.Initialize(self);
	LocalPlayer().Missiles = 0;
	self.Dist = -850;
	self.UDist = 250;
	self.NextPress = CurTime();
	self.KBD = self.KBD or KBD:CreateInstance(self);
	self.Vehicle = "F302";
end


function SGF302CalcView(Player, Origin, Angles, FieldOfView)
	local view = {}

	local p = LocalPlayer()
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)
	local pass302 = p:GetNetworkedEntity("302Seat",NULL);
	local Passenger = p:GetNetworkedBool("302Passenger",false);

	if(IsValid(self) and self:GetClass()=="sg_vehicle_f302") then
		if(not self.FPV) then
			local pos = self:GetPos()+self:GetUp()*self.UDist+LocalPlayer():GetAimVector():GetNormal()*self.Dist
			local face = ( ( self:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle()
			view.origin = pos
			view.angles = face
		else
			local pos = self.Entity:GetPos()+self.Entity:GetForward()*130+self.Entity:GetUp()*40
			local angle = self.Entity:GetAngles()
			view.origin = pos
			view.angles = angle
		end
		return view;
	elseif(Passenger) then
		if(IsValid(pass302)) then
			if(pass302:GetThirdPersonMode()) then
				local pos = pass302:GetPos()+pass302:GetUp()*250+LocalPlayer():GetAimVector():GetNormal()*-850
				local face = ( ( pass302:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle()
				view.origin = pos
				view.angles = face
				view.fov = nil
				return view;
			end
		end
	end
end
hook.Add("CalcView", "SGF302CalcView", SGF302CalcView)

local ATTACHMENTS = {"EngineR","EngineL"};
--######## Thruster effect @ RononDex
function ENT:Effects(b)

	local p = LocalPlayer();
	if(not b) then return end;
	local f302 = p:GetNetworkedEntity("ScriptedVehicle", NULL);
	local roll = math.Rand(-90,90);
	local normal = (self.Entity:GetForward() * -1):GetNormalized();
	local Boost = self:GetNetworkedBool("Boost");
	local drawfx;

	if Boost then return end;

	for k,v in pairs(ATTACHMENTS) do
		local attach = self:GetAttachment(self:LookupAttachment(v));
		local pos = attach.Pos;

		if((f302)and(f302:IsValid()and(f302==self))) then
			if(v=="EngineR" and p.MissilesDisabled) then
				drawfx = false;
			else
				drawfx = true;
			end
			if((p:KeyDown("F302","FWD")) and drawfx) then


				if(StarGate.VisualsShips("cl_F302_sprites")) then
					local aftbrn = self.FXEmitter:Add("effects/fire_cloud1",pos);
					aftbrn:SetVelocity(normal*2);
					aftbrn:SetDieTime(0.1);
					aftbrn:SetStartAlpha(255);
					aftbrn:SetEndAlpha(100);
					aftbrn:SetStartSize(30);
					aftbrn:SetEndSize(9);
					aftbrn:SetColor(math.Rand(220,255),math.Rand(220,255),185);
					aftbrn:SetRoll(roll);

					local aftbrn2 = self.FXEmitter:Add("sprites/orangecore1",pos);
					aftbrn2:SetVelocity(normal*2);
					aftbrn2:SetDieTime(0.1);
					aftbrn2:SetStartAlpha(255);
					aftbrn2:SetEndAlpha(100);
					aftbrn2:SetStartSize(30);
					aftbrn2:SetEndSize(9);
					aftbrn2:SetColor(math.Rand(220,255),math.Rand(220,255),185);
					aftbrn2:SetRoll(roll);
				end

				if(StarGate.VisualsShips("cl_F302_heatwave")) then
					local heatwv = self.FXEmitter:Add("sprites/heatwave",pos);
					heatwv:SetVelocity(normal*2);
					heatwv:SetDieTime(0.2);
					heatwv:SetStartAlpha(255);
					heatwv:SetEndAlpha(255);
					heatwv:SetStartSize(50);
					heatwv:SetEndSize(18);
					heatwv:SetColor(255,255,255);
					heatwv:SetRoll(roll);
				end
			end
		end
	end
	--self.FXEmitter:Finish();
end
--########### The "Afterburner" effect @RononDex
function ENT:BoostFX()

	local pos = self:GetPos() + self:GetForward() * -230 + self:GetUp()*10;
	local normal = (self.Entity:GetForward() * -1):GetNormalized();
	local roll = math.Rand(-90,90);
	local p = LocalPlayer();
	local f302 = p:GetNetworkedEntity("ScriptedVehicle", NULL);
	local Boost = self:GetNWBool("Boost");

	if Boost then

		local vel = f302:GetVelocity();

		if(StarGate.VisualsShips("cl_F302_heatwave")) then
			local fx = self.FXEmitter:Add("sprites/heatwave",pos);
			fx:SetVelocity(normal*2);
			fx:SetDieTime(0.2);
			fx:SetStartAlpha(255);
			fx:SetEndAlpha(255);
			fx:SetStartSize(60);
			fx:SetEndSize(40);
			fx:SetColor(255,255,255);
			fx:SetRoll(roll);
		end

		if(StarGate.VisualsShips("cl_F302_sprites")) then
			local fx2 = self.FXEmitter:Add("effects/fire_cloud1",pos);
			fx2:SetVelocity(normal*2);
			fx2:SetDieTime(0.3);
			fx2:SetStartAlpha(255);
			fx2:SetEndAlpha(255);
			fx2:SetStartSize(40);
			fx2:SetEndSize(25);
			fx2:SetColor(math.Rand(235,255),math.Rand(235,255),195);
			fx2:SetRoll(roll);
		end
	end
end

local UP = Vector(0,0,50);
function ENT:Smoke(b)

	local FWD = self.Entity:GetForward();
	local data = self.Entity:GetAttachment(self.Entity:LookupAttachment("EngineR"));
	if(not (data and data.Pos)) then return end; -- Old or no valid model - Don't draw!
	local pos = data.Pos;
	local p = LocalPlayer();
	local f302 = p:GetNetworkedEntity("ScriptedVehicle", NULL);

	if(b) then
		if IsValid(f302) and f302 == self then
			local particle = self.FXEmitter:Add("particles/smokey",pos);
			particle:SetVelocity(-100*FWD + UP);
			particle:SetDieTime(1);
			particle:SetStartAlpha(150);
			particle:SetEndAlpha(0);
			particle:SetStartSize(40);
			particle:SetEndSize(20);
			particle:SetColor(40,40,40);
			particle:SetRoll(math.Rand(-90,90));

			--self.FXEmitter:Finish();
		end
	end
end

function ENT:Draw()

	local p = LocalPlayer();
	local f302 = p:GetNetworkedEntity("ScriptedVehicle", NULL);
	local Boost = self:GetNWBool("Boost");

	self.BaseClass.Draw(self);

	if(self:WaterLevel() < 1) then
		if(not(p.EngineDamaged)) then
			if(IsValid(f302) and (f302==self)) then
				self:Effects(true);
			else
				self:Effects(false);
			end

			if((f302)and(f302:IsValid())) then
				if Boost then
					self:BoostFX(true);
				else
					self:BoostFX(false);
				end
			end
		end
	else
		self:Effects(false)
	end

	if(p.MissilesDisabled) then
		self:Smoke(true);
	else
		self:Smoke(false);
	end
end

usermessage.Hook("302Data", function(um)
	local p = LocalPlayer();
	p.Missiles = um:ReadShort();
	p.MissilesDisabled = um:ReadBool();
	p.TurretsDisabled = um:ReadBool();
	p.EngineDamaged = um:ReadBool();
	p.Weapons = um:ReadString();
end);

--############# HUD Stuff @RononDex
local GREEN = Color(0,255,0);
local RED = Color(255,0,0);
local BLUE = Color(0,0,255)
local WHITE = Color(255,255,255,255);
local HUD = surface.GetTextureID("VGUI/HUD/F302_HUD/F302_HUD");
local MISSILE_COLOUR = GREEN;
local TURRET_COLOUR  = GREEN;
local ENGINE_COLOUR = BLUE;

local w,h = ScrW(),ScrH();
local num = 0;
local mnum = h/4*3.5;
local enum = h/4*3.2;
local hnum = h/4*3;
local function F302Hud()

	local p = LocalPlayer();
	local f302 = p:GetNWEntity("F302");
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL);
	if (not IsValid(self)) then return end
	local health = math.Round(((self:GetNWInt("health"))/5));
	if(self.HideHUD) then return end;

	if(p.MissilesDisabled) then
		MISSILE_COLOUR = RED;
	end

	if(not(p.MissilesDisabled)) then
		if(p.Weapons=="Missiles") then
			MISSILE_COLOUR = GREEN;
		else
			MISSILE_COLOUR = WHITE;
		end
	end

	if(not(p.TurretsDisabled)) then
		if(p.Weapons=="Turrets") then
			TURRET_COLOUR = GREEN;
		else
			TURRET_COLOUR = WHITE;
		end
	end

	if(p.TurretsDisabled) then
		TURRET_COLOUR = RED;
	end

	if(p.EngineDamaged) then
		ENGINE_COLOUR = RED;
	end

	if(self.FPV) then
		num = math.Approach(num,h/4*-2.8,10)
		mnum = math.Approach(mnum,h/4*0.75,10)
		enum = math.Approach(enum,h/4*0.4,10)
		hnum = math.Approach(hnum,h/4*0.3,10)
	else
		num = math.Approach(num,0,10)
		mnum = math.Approach(mnum,h/4*3.5,10)
		enum = math.Approach(enum,h/4*3.2,10)
		hnum = math.Approach(hnum,h/4*3,10)
	end


	if(IsValid(f302)) then
		if(f302==self) then
			surface.SetTexture(HUD);
			surface.SetDrawColor(255,255,255,125);
			surface.DrawTexturedRect(0,num,w,h);

			draw.DrawText("Missiles","MainF302Font",w/4*1.5,mnum,MISSILE_COLOUR,1);
			draw.DrawText("Turrets","MainF302Font",w/4*2.5,mnum,TURRET_COLOUR,1);
			draw.DrawText("Engine","MainF302Font",w/4*2,enum,ENGINE_COLOUR,1);
			draw.DrawText("Hull:\n"..tostring(health).."%","F302Font",w/4*0.55,hnum,WHITE,1);
			draw.DrawText(p.Missiles.."/"..(4-p.Missiles),"F302Font",w/4*3.45,enum,WHITE,1);
		end
	end
end
hook.Add("HUDPaint","F302HUD",F302Hud);

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self);

	local p = LocalPlayer();
	local f302 = p:GetNetworkedEntity("ScriptedVehicle", NULL);

	if((IsValid(f302))and((f302)==self)) then
		self.KBD:SetActive(true);
	else
		self.KBD:SetActive(false);
	end

	if((IsValid(f302))and((f302)==self)) then
		if(p:KeyDown("F302","Z+")) then
			self.Dist = self.Dist-5;
		elseif(p:KeyDown("F302","Z-")) then
			self.Dist = self.Dist+5;
		end

		if(p:KeyDown("F302","A+")) then
			self.UDist = self.UDist+5;
		elseif(p:KeyDown("F302","A-")) then
			self.UDist = self.UDist-5;
		end

		if(self.NextPress < CurTime()) then
			if(p:KeyDown(self.Vehicle,"HIDE")) then
				if(self.HideHUD) then
					self.HideHUD = false;
				else
					self.HideHUD = true;
				end
				self.NextPress = CurTime() + 1;
			end

			if(p:KeyDown(self.Vehicle,"FPV")) then
				if(self.FPV) then
					self.FPV = false;
				else
					self.FPV = true;
				end
				self.NextPress = CurTime() + 1;
			end
		end
	end
end
