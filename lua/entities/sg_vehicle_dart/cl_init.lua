include('shared.lua')
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_dart");
end

if (StarGate==nil or StarGate.KeyBoard==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("Dart")
--Navigation
KBD:SetDefaultKey("FWD",StarGate.KeyBoard.BINDS["+forward"] or "W") -- Forward
KBD:SetDefaultKey("SPD",StarGate.KeyBoard.BINDS["+speed"] or "SHIFT") --  Boost
KBD:SetDefaultKey("UP",StarGate.KeyBoard.BINDS["+jump"] or "SPACE")
KBD:SetDefaultKey("DOWN",StarGate.KeyBoard.BINDS["+duck"] or "CTRL")
KBD:SetDefaultKey("LEFT",StarGate.KeyBoard.BINDS["+moveleft"] or "A")
KBD:SetDefaultKey("RIGHT",StarGate.KeyBoard.BINDS["+moveright"] or "D")
--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN") -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP") -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset Roll
--Attack
KBD:SetDefaultKey("FIRE",StarGate.KeyBoard.BINDS["+attack"] or "MOUSE1") -- Fire
--Special Actions
KBD:SetDefaultKey("SUCK","C") --  Cull
KBD:SetDefaultKey("SPIT","ALT") -- UnCull
KBD:SetDefaultKey("DHD","R") -- DHD
--View
KBD:SetDefaultKey("Z+","UPARROW")
KBD:SetDefaultKey("Z-","DOWNARROW")
KBD:SetDefaultKey("A+","LEFTARROW")
KBD:SetDefaultKey("A-","RIGHTARROW")

KBD:SetDefaultKey("BOOM","BACKSPACE")
KBD:SetDefaultKey("EXIT",StarGate.KeyBoard.BINDS["+use"] or "E")

ENT.Sounds={
	Engine=Sound("vehicles/DartEngine.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	LocalPlayer().Missiles=0
	self.Dist=-850
	self.UDist=250
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.Vehicle="Dart"
end

function ENT:Effects()

	local pos = self:GetPos()+self:GetForward()*-100+self:GetUp()*25
	local data = self:GetAttachment(self:LookupAttachment("Engine")) --@Madman07
	if(not (data and data.Pos)) then return end

	local p = LocalPlayer()
	local dart = p:GetNetworkedEntity("ScriptedVehicle", NULL)
	local roll = math.Rand(-90,90)
	local normal = (self.Entity:GetForward() * -1):GetNormalized()

	if((dart)and(dart:IsValid()and(dart==self))) then

		if(StarGate.VisualsShips("cl_dart_heatwave")) then
			local heatwv = self.FXEmitter:Add("sprites/heatwave",data.Pos)
			heatwv:SetVelocity(normal*2)
			heatwv:SetDieTime(0.2)
			heatwv:SetStartAlpha(255)
			heatwv:SetEndAlpha(255)
			heatwv:SetStartSize(50)
			heatwv:SetEndSize(18)
			heatwv:SetColor(0,95,155)
			heatwv:SetRoll(roll)
		end
	end
	self.FXEmitter:Finish()
end

function ENT:Draw()

	local p = LocalPlayer()
	local dart = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	self.BaseClass.Draw(self)

	if((dart)and(dart:IsValid())) then
		if(p:KeyDown("Dart","FWD")) then
			self:Effects(true)
		else
			self:Effects(false)
		end
	end
end

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local dart = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((dart)and((dart)==self)and(dart:IsValid())) then
		self.KBD:SetActive(true)
	else
		self.KBD:SetActive(false)
	end

	if((dart)and((dart)==self)and(dart:IsValid())) then

		if(p:KeyDown("Dart","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("Dart","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("Dart","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("Dart","A-")) then
			self.UDist=self.UDist-5
		end
	end

end