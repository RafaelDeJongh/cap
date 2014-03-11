--[[
        BC-304 "Daedalus"
        Copyright (C) 2010 Madman07

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
include('shared.lua');
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_daedalus");
end

--require("datastream")

-- ENT.RenderGroup = RENDERGROUP_BOTH;

local BreachWarning = surface.GetTextureID("VGUI/HUD/BC304_HUD/breachwarning");
local MainHud_left = surface.GetTextureID("VGUI/HUD/BC304_HUD/mainhud_left");
local MainHud_right = surface.GetTextureID("VGUI/HUD/BC304_HUD/mainhud_right");
local WeaponsHud_middle = surface.GetTextureID("VGUI/HUD/BC304_HUD/weaponshud_middle");
local WeaponsHud_left = surface.GetTextureID("VGUI/HUD/BC304_HUD/weaponshud_left");
local WeaponsHud_right = surface.GetTextureID("VGUI/HUD/BC304_HUD/weaponshud_right");
local OnOff = surface.GetTextureID("VGUI/HUD/BC304_HUD/on_off_button");
local PHSBar = surface.GetTextureID("VGUI/HUD/BC304_HUD/power_hull_shield_bar");
local SubBar = surface.GetTextureID("VGUI/HUD/BC304_HUD/sublightengine_bar");
local WepBar = surface.GetTextureID("VGUI/HUD/BC304_HUD/weapons_bar");

local Pressed = false;

function ENT:Initialize( )
        --self:SetShouldDrawInViewMode( true );
        self.FXEmitter = ParticleEmitter( self:GetPos());
        LocalPlayer().ViewMode = 0;
        LocalPlayer().RailgunEnable = 0;
        LocalPlayer().HUDEnable = true;
        self.EngineSound = CreateSound(self.Entity,Sound("ships/cargo_ship_interor_idle.wav"));

			-- FIRE_RING.PCF

    -- fire_ring_01
    -- smoke_oily_01

-- FIREFLOW.PCF

    -- bonfire

-- FLAMETHROWERTEST.PCF

    -- flame
-- PrecacheParticleSystem("fire_ring_01")

	self.AttLastPos = {
		Vector(0,0,0),
		Vector(0,0,0),
		Vector(0,0,0),
		Vector(0,0,0),
		Vector(0,0,0),
		Vector(0,0,0),
		Vector(0,0,0),
		Vector(0,0,0),
		Vector(0,0,0),
		Vector(0,0,0)
	}

end

local function KeyPress()
	local key = "";
	if input.IsKeyDown(KEY_1) then key = "1";
	elseif input.IsKeyDown(KEY_2) then key = "2";
	elseif input.IsKeyDown(KEY_3) then key = "3";
	elseif input.IsKeyDown(KEY_4) then key = "4";
	elseif input.IsKeyDown(KEY_5) then key = "5";
	elseif input.IsKeyDown(KEY_6) then key = "6";
	elseif input.IsKeyDown(KEY_7) then key = "7";
	elseif input.IsKeyDown(KEY_8) then key = "8";
	end

	local p = LocalPlayer();
	local daedalus = p:GetNetworkedEntity("Daedalus");
	if (IsValid(daedalus) and key != "") then
		p:ConCommand("Daedalus_FireRocket "..daedalus:EntIndex().." "..key);
	end
end
hook.Add("Think","Daedalus_Rockets",KeyPress)

function ENT:Think()

	-- local att = {
			-- "ELB",
			-- "ERB",
			-- "ELM1",
			-- "ELM2",
			-- "ERM1",
			-- "ERM2",
			-- "ELS1",
			-- "ELS2",
			-- "ERS1",
			-- "ERS2"
	-- }

	-- for i=1,10 do
		-- ParticleEffectAttach("fire_ring_01", PATTACH_POINT_FOLLOW, self.Entity, self:LookupAttachment(att[i]))
	-- end


        LocalPlayer().ViewMode = self.Entity:GetNetworkedInt("ViewMode");
        LocalPlayer().Sublight = self.Entity:GetNetworkedInt("Sublight");
        LocalPlayer().Hull = self.Entity:GetNetworkedInt("Hull");
        LocalPlayer().Shield = self.Entity:GetNetworkedInt("Shield");
        LocalPlayer().Power = self.Entity:GetNetworkedInt("Power");
        LocalPlayer().Hangar = self.Entity:GetNetworkedInt("Hangar");
        LocalPlayer().PowerSource = self.Entity:GetNetworkedInt("PowerSource");
        LocalPlayer().ShieldStatus = self.Entity:GetNetworkedInt("ShieldStatus");
        LocalPlayer().Hyperdrive = self.Entity:GetNetworkedInt("Hyperdrive");
        LocalPlayer().Warning = 0;

        -- if  (input.IsKeyDown(KEY_0) and Pressed == false) then
                -- Pressed = true;
                -- RunConsoleCommand("Daedalus_shields");
        -- end
        -- if  (input.IsKeyDown(KEY_1) and Pressed == false) then
                -- Pressed = true;
                -- RunConsoleCommand("Daedalus_asgard");
        -- end
        -- if  (input.IsKeyDown(KEY_2) and Pressed == false) then
                -- Pressed = true;
                -- RunConsoleCommand("Daedalus_railguns");
        -- end
        -- if  (input.IsKeyDown(KEY_3) and Pressed == false) then
                -- Pressed = true;
                -- RunConsoleCommand("Daedalus_rockets");
        -- end
        -- if  (input.IsKeyDown(KEY_9) and Pressed == false) then
                -- Pressed = true;
                -- RunConsoleCommand("Daedalus_beam");
        -- end
        -- if  (input.IsKeyDown(KEY_H) and Pressed == false) then
                -- Pressed = true;
                -- LocalPlayer().HUDEnable = not LocalPlayer().HUDEnable;
        -- end
        -- if  (input.IsKeyDown(KEY_X) and Pressed == false) then
                -- Pressed = true;
                -- RunConsoleCommand("Daedalus_resetpitch");
        -- end

        if (Pressed == true) then timer.Simple( 1, function() Pressed = false end) end

        self:StartSound();
        self.EngineSound:ChangePitch(100+LocalPlayer().Sublight/10,0);

end

function ENT:StartSound()
        if (not self.EngineSoundActive) then
                self.EngineSound:PlayEx(1,100);
                --self.EngineSound:SetSoundLevel(100);
                --self.EngineSound:ChangePitch(0);
                self.EngineSoundActive = true;
        end
end

function ENT:OnRemove()
	if (self.EngineSound) then
		self.EngineSound:Stop();
	end
end

function ENT:Draw()
        self:DrawModel() ;
        self:Effects(true);
end

local font = {
	font = "Default",
	size = ScreenScale(6),
	weight = 1000,
	antialias = true,
	additive = false,
}
surface.CreateFont("DaedalusFont", font);

function DaedalusHUD()

        local ply = LocalPlayer();
        local self = ply:GetNetworkedEntity("ScriptedVehicle", NULL)
        local vehicle = ply:GetNWEntity("Daedalus");

        if (self and self:IsValid() and vehicle and vehicle:IsValid() and LocalPlayer().HUDEnable) then

                surface.SetTexture(MainHud_left);
                surface.SetDrawColor(255,255,255,255);
                surface.DrawTexturedRect(0,ScrH()-512,256,512);

                surface.SetTexture(MainHud_right);
                surface.SetDrawColor(255,255,255,255);
                surface.DrawTexturedRect(ScrW()-256,ScrH()-512,256,512);

                if (LocalPlayer().ViewMode > 0) then
                        surface.SetTexture(WeaponsHud_middle);
                        surface.SetDrawColor(255,255,255,255);
                        surface.DrawTexturedRect(ScrW()/2-256,0,512,64);

                        surface.SetTexture(WeaponsHud_left);
                        surface.SetDrawColor(255,255,255,255);
                        surface.DrawTexturedRect(0,0,256,64);

                        surface.SetTexture(WeaponsHud_right);
                        surface.SetDrawColor(255,255,255,255);
                        surface.DrawTexturedRect(ScrW()-256,0,256,64);

                        local yy = 55
                        surface.SetTexture(WepBar);
                        surface.SetDrawColor(255,255,255,255);

                        surface.DrawTexturedRect(20,yy,8,8);
                        surface.DrawTexturedRect(70,yy,8,8);
                        surface.DrawTexturedRect(100,yy,8,8);
                        surface.DrawTexturedRect(150,yy,8,8);
                        surface.DrawTexturedRect(180,yy,8,8);
                        surface.DrawTexturedRect(220,yy,8,8);

                        surface.DrawTexturedRect(ScrW()/2+70,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2+60,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2+50,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2+40,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2+30,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2+20,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2-20,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2-30,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2-40,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2-50,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2-60,yy,8,8);
                        surface.DrawTexturedRect(ScrW()/2-70,yy,8,8);

                        surface.DrawTexturedRect(ScrW()-20,yy,8,8);
                        surface.DrawTexturedRect(ScrW()-70,yy,8,8);
                        surface.DrawTexturedRect(ScrW()-100,yy,8,8);
                        surface.DrawTexturedRect(ScrW()-150,yy,8,8);
                        surface.DrawTexturedRect(ScrW()-180,yy,8,8);
                        surface.DrawTexturedRect(ScrW()-220,yy,8,8);

                end

                if (LocalPlayer().Hull < 20) then
                        if (LocalPlayer().Warning == 0) then
                                LocalPlayer().Warning = 1;
                                timer.Simple( 0.5, function() LocalPlayer().Warning = 2 end)
                        elseif (LocalPlayer().Warning == 2) then
                                LocalPlayer().Warning = 1;
                                timer.Simple( 0.5, function() LocalPlayer().Warning = 0 end)
                                surface.SetTexture(BreachWarning);
                                surface.SetDrawColor(255,255,255,255);
                                surface.DrawTexturedRect((ScrW()-512)/2,(ScrH()-128)/2,512,128);
                        end
                end

                if (LocalPlayer().ShieldStatus == 1) then
                        surface.SetTexture(OnOff);
                        surface.SetDrawColor(255,255,255,255);
                        surface.DrawTexturedRect(ScrW()-70,ScrH()-90,8,8);
                else
                        surface.SetTexture(OnOff);
                        surface.SetDrawColor(255,255,255,255);
                        surface.DrawTexturedRect(ScrW()-40,ScrH()-90,8,8);
                end

                if (LocalPlayer().PowerSource == 1) then
                        draw.DrawText("ZPM", "DaedalusFont", 120,ScrH()-90, Color(255,255,255,255),1);
                else
                        draw.DrawText("Naquadah", "DaedalusFont", 120,ScrH()-90, Color(255,255,255,255),1);
                end

                for i=1,10 do
                        if (LocalPlayer().Sublight > (i * 10)) then
                                surface.SetTexture(SubBar);
                                surface.SetDrawColor(255,255,255,255);
                                surface.DrawTexturedRect(ScrW()-93,ScrH()-145-i*12,45,7);
                        end
                end
                if (LocalPlayer().Sublight == -10) then
                        surface.SetTexture(SubBar);
                        surface.SetDrawColor(255,255,255,255);
                        surface.DrawTexturedRect(ScrW()-93,ScrH()-135,45,7);
                end

                for i=1,15 do
                        if (LocalPlayer().Hull > (i * 6.5)) then
                                surface.SetTexture(PHSBar);
                                surface.SetDrawColor(255,255,255,255);
                                surface.DrawTexturedRect(141-i*8,ScrH()-158,5,20);
                        end
                end
                for i=1,18 do
                        if (LocalPlayer().Power > (i * 5.5)) then
                                surface.SetTexture(PHSBar);
                                surface.SetDrawColor(255,255,255,255);
                                surface.DrawTexturedRect(15+i*8,ScrH()-48,5,26);
                        end
                        if (LocalPlayer().Shield > (i * 5.5)) then
                                surface.SetTexture(PHSBar);
                                surface.SetDrawColor(255,255,255,255);
                                surface.DrawTexturedRect(ScrW()-195+i*9.25,ScrH()-48,6,26);
                        end
                end


        end
end
hook.Add("HUDPaint","DaedalusHUD",DaedalusHUD);

function ENT:Effects()

        -- local pos = {};
        local size = {};

        -- Big Engines
        -- pos[1] = self.Entity:GetPos() + self.Entity:GetForward() * 530 + self.Entity:GetRight() * 2420 + self.Entity:GetUp() * -95;
        -- pos[2] = self.Entity:GetPos() + self.Entity:GetForward() * -530 + self.Entity:GetRight() * 2420 + self.Entity:GetUp() * -95;
        -- Medium Engines
        -- pos[3] = self.Entity:GetPos() + self.Entity:GetForward() * -1760 + self.Entity:GetRight() * 2360 + self.Entity:GetUp() * -130;
        -- pos[4] = self.Entity:GetPos() + self.Entity:GetForward() * -1460 + self.Entity:GetRight() * 2360 + self.Entity:GetUp() * -130;
        -- pos[5] = self.Entity:GetPos() + self.Entity:GetForward() * 1450 + self.Entity:GetRight() * 2360 + self.Entity:GetUp() * -130;
        -- pos[6] = self.Entity:GetPos() + self.Entity:GetForward() * 1700 + self.Entity:GetRight() * 2360 + self.Entity:GetUp() * -130;
        -- Small Engines
        -- pos[7] = self.Entity:GetPos() + self.Entity:GetForward() * -1970 + self.Entity:GetRight() * 2280 + self.Entity:GetUp() * -220;
        -- pos[8] = self.Entity:GetPos() + self.Entity:GetForward() * -1275 + self.Entity:GetRight() * 2280 + self.Entity:GetUp() * -80;
        -- pos[9] = self.Entity:GetPos() + self.Entity:GetForward() * 1235 + self.Entity:GetRight() * 2280 + self.Entity:GetUp() * -80;
        -- pos[10] = self.Entity:GetPos() + self.Entity:GetForward() * 1920 + self.Entity:GetRight() * 2280 + self.Entity:GetUp() * -220;

        -- Big Engines
        size[1] = 120;
        size[2] = 120;
        -- Medium Engines
        size[3] = 80;
        size[4] = 80;
        size[5] = 80;
        size[6] = 80;
        -- Small Engines
        size[7] = 40;
        size[8] = 40;
        size[9] = 40;
        size[10] = 40;


		local att = {
			"ELB",
			"ERB",
			"ELM1",
			"ELM2",
			"ERM1",
			"ERM2",
			"ELS1",
			"ELS2",
			"ERS1",
			"ERS2"
		}

        local roll = math.Rand(-90,90);
        local normal = (self.Entity:GetForward() * -1):GetNormalized();
        local velocity = self.Entity:GetVelocity();
        local FWD = self.Entity:GetForward();

        for i=1,10 do

				local data = self:GetAttachment(self:LookupAttachment(att[i]));
				if not (data and data.Pos) then return end

				local velo = (data.Pos-self.AttLastPos[i])*75
				self.AttLastPos[i] = data.Pos;

                -- local dynlight = DynamicLight(i*5);
                -- dynlight.Pos = data.Pos;
                -- dynlight.Brightness = 5;
                -- dynlight.Size = size[i];
                -- dynlight.Decay = 1024;
                -- dynlight.R = math.Rand(220,255);
                -- dynlight.G = math.Rand(220,255);
                -- dynlight.B = 155;
                -- dynlight.DieTime = CurTime()+0.5;

                -- local left = self.FXEmitter:Add("sprites/orangecore1",data.Pos);
                -- left:SetVelocity(velocity - 100*FWD);
                -- left:SetDieTime(0.2);
                -- left:SetStartAlpha(255);
                -- left:SetEndAlpha(0);
                -- left:SetStartSize(size[i]);
                -- left:SetEndSize(size[i]*1.5);
                -- left:SetColor(math.Rand(220,255),math.Rand(220,255),155);
                -- left:SetRoll(roll);

			-- if(StarGate.Visuals("cl_F302_sprites")) then
					local aftbrn = self.FXEmitter:Add("effects/fire_cloud1",data.Pos);
					aftbrn:SetVelocity(velo - 300*FWD);
					aftbrn:SetDieTime(0.1);
					aftbrn:SetStartAlpha(255);
					aftbrn:SetEndAlpha(100);
					aftbrn:SetStartSize(size[i]/2);
					aftbrn:SetEndSize(size[i]);
					aftbrn:SetColor(math.Rand(220,255),math.Rand(220,255),185);
					aftbrn:SetRoll(roll);

					local aftbrn2 = self.FXEmitter:Add("sprites/orangecore1",data.Pos);
					aftbrn2:SetVelocity(velo - 300*FWD);
					aftbrn2:SetDieTime(0.1);
					aftbrn2:SetStartAlpha(255);
					aftbrn2:SetEndAlpha(100);
					aftbrn2:SetStartSize(size[i]/2);
					aftbrn2:SetEndSize(size[i]);
					aftbrn2:SetColor(math.Rand(220,255),math.Rand(220,255),185);
					aftbrn2:SetRoll(roll);
				-- end

				-- if(StarGate.Visuals("cl_F302_heatwave")) then
					-- local heatwv = self.FXEmitter:Add("sprites/heatwave",data.Pos);
					-- heatwv:SetVelocity(- 300*FWD);
					-- heatwv:SetDieTime(0.2);
					-- heatwv:SetStartAlpha(255);
					-- heatwv:SetEndAlpha(255);
					-- heatwv:SetStartSize(size[i]);
					-- heatwv:SetEndSize(size[i]*2);
					-- heatwv:SetColor(255,255,255);
					-- heatwv:SetRoll(roll);
				-- end
        end

        self.FXEmitter:Finish();

        -- local pos2 = {};

        -- pos2[1] = self.Entity:GetPos() + self.Entity:GetRight() * 470 + self.Entity:GetForward() * -800 + self.Entity:GetUp() * -200;
        -- pos2[2] = self.Entity:GetPos() + self.Entity:GetRight() * -470 + self.Entity:GetForward() * -800 + self.Entity:GetUp() * -200;
        -- pos2[3] = self.Entity:GetPos() + self.Entity:GetRight() * 800 + self.Entity:GetForward() * -1300 + self.Entity:GetUp() * -200;
        -- pos2[4] = self.Entity:GetPos() + self.Entity:GetRight() * -800 + self.Entity:GetForward() * -1300 + self.Entity:GetUp() * -200;

        -- for i=1,4 do
                -- local dynlight = DynamicLight(i*5+100);
                -- dynlight.Pos = pos2[i];
                -- dynlight.Brightness = 10;
                -- dynlight.Size = 200;
                -- dynlight.Decay = 1024;
                -- dynlight.R = 255;
                -- dynlight.G = 255;
                -- dynlight.B = 255;
                -- dynlight.DieTime = CurTime()+1;
        -- end

end

function SGDaedalusCalcView(Player, Origin, Angles, FieldOfView)

        local view={};
        local pos = Vector(0,0,0);
        local face = Angle(0,0,0);
        local self = LocalPlayer():GetNetworkedEntity("ScriptedVehicle", NULL)

        if(IsValid(self) and self:GetClass()=="sg_vehicle_daedalus") then
	        if (LocalPlayer().ViewMode == 0) then
	                pos = self:GetPos()+self:GetUp()*600+Player:GetAimVector():GetNormal()*-5000;
	                face = ( ( self:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle();
	        elseif (LocalPlayer().ViewMode == 1) then
	                pos = self:GetPos()-self:GetUp()*500;
	                face = (Player:GetAimVector()):Angle();
	        else
	                pos = self:GetPos()+self:GetUp()*1000;
	                face = (Player:GetAimVector()):Angle();
	        end

	                view.origin = pos;
	                view.angles = face;

	        return view;
        end
end
hook.Add("CalcView", "SGDaedalusCalcView", SGDaedalusCalcView)
