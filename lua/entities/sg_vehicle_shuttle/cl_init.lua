include('shared.lua')
ENT.Category = Language.GetMessage("entity_ships_cat");
ENT.PrintName = Language.GetMessage("entity_dest_shuttle");
ENT.RenderGroup = RENDERGROUP_BOTH

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("Shuttle")
--Navigation
KBD:SetDefaultKey("FWD","W") -- Forward
KBD:SetDefaultKey("SPD","SHIFT") --  Boost
KBD:SetDefaultKey("UP","SPACE")
KBD:SetDefaultKey("DOWN","CTRL")
KBD:SetDefaultKey("LEFT","A")
KBD:SetDefaultKey("RIGHT","D")
--Attack
KBD:SetDefaultKey("FIRE","MOUSE1")
--View
KBD:SetDefaultKey("Z+","UPARROW")
KBD:SetDefaultKey("Z-","DOWNARROW")
KBD:SetDefaultKey("A+","LEFTARROW")
KBD:SetDefaultKey("A-","RIGHTARROW")
--Special Actions
KBD:SetDefaultKey("SHIELD","ALT")

KBD:SetDefaultKey("BOOM","BACKSPACE")
KBD:SetDefaultKey("EXIT","E")

ENT.Sounds={
	Engine=Sound("f302/f302_Engine.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-1150
	self.UDist=400
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.Vehicle = "Shuttle"
end

function ENT:Effects()

	local pos = {}
	pos[1] = self:GetPos() + self:GetForward() * -390 + self:GetUp()*40 + self:GetRight()*270
	pos[2] = self:GetPos() + self:GetForward() * -390 + self:GetUp()*67.5 + self:GetRight()*190
	pos[3] = self:GetPos() + self:GetForward() * -390 + self:GetUp()*40 + self:GetRight()*-270
	pos[4] = self:GetPos() + self:GetForward() * -390 + self:GetUp()*67.5 + self:GetRight()*-190

	local p = LocalPlayer()
	local Shuttle = p:GetNetworkedEntity("ScriptedVehicle", NULL)
	local roll = math.Rand(-90,90)
	local normal = (self.Entity:GetForward() * -1):GetNormalized()

	if((Shuttle)and(Shuttle:IsValid()and(Shuttle==self))) then
		for i=1,4 do
			if((p:KeyDown("Shuttle","FWD"))) then
				if(StarGate.VisualsShips("cl_shuttle_heatwave")) then
					local fx = self.FXEmitter:Add("sprites/heatwave",pos[i])
					fx:SetVelocity(normal*2)
					fx:SetDieTime(0.2)
					fx:SetStartAlpha(255)
					fx:SetEndAlpha(255)
					fx:SetStartSize(90)
					fx:SetEndSize(50)
					fx:SetColor(255,255,255)
					fx:SetRoll(roll)
				end

				if(StarGate.VisualsShips("cl_shuttle_sprites")) then
					local fx2 = self.FXEmitter:Add("sprites/orangecore1",pos[i])
					fx2:SetVelocity(normal*2)
					fx2:SetDieTime(0.02)
					fx2:SetStartAlpha(255)
					fx2:SetEndAlpha(255)
					fx2:SetStartSize(60)
					fx2:SetEndSize(35)
					fx2:SetColor(math.Rand(200,255),math.Rand(200,255),165)
					fx2:SetRoll(roll)
				end
			end
		end
	end
	self.FXEmitter:Finish()
end

function ENT:BoostFX()

	local pos = {}
	pos[1] = self:GetPos() + self:GetRight() * 365 + self:GetForward() * -390 + self:GetUp() * 20
	pos[2] = self:GetPos() + self:GetRight() * -365 + self:GetForward() * -390 + self:GetUp() * 20
	pos[3] = self:GetPos() + self:GetRight() * 430 + self:GetForward() * -390
	pos[4] = self:GetPos() + self:GetRight() * -430 + self:GetForward() * -390

	local normal = (self.Entity:GetForward() * -1):GetNormalized()
	local roll = math.Rand(-90,90)
	local p = LocalPlayer()
	local Shuttle = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((p:KeyDown("Shuttle","SPD"))and(p:KeyDown("Shuttle","FWD"))and((Shuttle)and(Shuttle:IsValid())and(Shuttle==self))) then

		local vel = Shuttle:GetVelocity()
		for i=1,4 do

			if(StarGate.VisualsShips("cl_shuttle_sprites")) then
				local aftbrn = self.FXEmitter:Add("sprites/orangecore1",pos[i])
				aftbrn:SetVelocity(normal*2)
				aftbrn:SetDieTime(0.05)
				aftbrn:SetStartAlpha(255)
				aftbrn:SetEndAlpha(100)
				aftbrn:SetStartSize(40)
				aftbrn:SetEndSize(13.5)
				aftbrn:SetColor(math.Rand(220,255),math.Rand(220,255),155)
				aftbrn:SetRoll(roll)
			end

			if(StarGate.VisualsShips("cl_shuttle_heatwave")) then
				local heatwv = self.FXEmitter:Add("sprites/heatwave",pos[i])
				heatwv:SetVelocity(normal*2)
				heatwv:SetDieTime(0.2)
				heatwv:SetStartAlpha(255)
				heatwv:SetEndAlpha(255)
				heatwv:SetStartSize(50)
				heatwv:SetEndSize(18)
				heatwv:SetColor(255,255,255)
				heatwv:SetRoll(roll)
			end
		end
	end
end


function ENT:Draw()

	local p = LocalPlayer()

	self.BaseClass.Draw(self)

	if(p:KeyDown("Shuttle","FWD")) then
		self:Effects()
	end

	if(p:KeyDown("Shuttle","SPD")) then
		self:BoostFX()
	end
end

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local Shuttle = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((Shuttle)and((Shuttle)==self)and(Shuttle:IsValid())) then
		self.KBD:SetActive(true)
	else
		self.KBD:SetActive(false)
	end

	if((Shuttle)and((Shuttle)==self)and(Shuttle:IsValid())) then
		if(p:KeyDown("Shuttle","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("Shuttle","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("Shuttle","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("Shuttle","A-")) then
			self.UDist=self.UDist-5
		end
	end
end

local function SetData(um) --############# Recieve data from init@RononDex
	LocalPlayer().Shield = um:ReadShort();
end
usermessage.Hook("ShuttleData", SetData)

--########### All HUD Related stuff is below @ RononDex
local hudpos = {
	healthw = (ScrW()/10*1.5),
	healthh = (ScrH()/10*2),
	shieldw = (ScrW()/10*1.5),
	shieldh = (ScrH()/10*3),
}
function PrintHUD()

	local p = LocalPlayer()
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)
	local shuttle = p:GetNetworkedEntity("Shuttle")
	local health = math.Round(shuttle:GetNWInt("health")/5)

	if(IsValid(self)) then
		if((IsValid(shuttle))and(shuttle==self)) then
			draw.WordBox(8,hudpos.healthw,hudpos.healthh, "Hull: "..health.."%","ScoreboardText",Color(50,50,75,100), Color(255,255,255,255))
			draw.WordBox( 8, hudpos.shieldw, hudpos.shieldh, "Shield: "..self:GetNWInt("shield",100).."%", "ScoreboardText", Color(50,50,75,100), Color(255,255,255,255))
		end
	end
end
hook.Add("HUDPaint","ShuttleHUD",PrintHUD)