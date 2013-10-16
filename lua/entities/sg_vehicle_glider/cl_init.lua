include('shared.lua')
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_death_glider");
end

ENT.Sounds = {
	Engine=Sound("glider/deathglideridleoutside.wav"),
}

if (StarGate==nil or StarGate.KeyBoard==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("DeathGlider")
--Navigation
KBD:SetDefaultKey("FWD",StarGate.KeyBoard.BINDS["+forward"] or "W") -- Forward
KBD:SetDefaultKey("SPD",StarGate.KeyBoard.BINDS["+speed"] or "SHIFT")
--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN") -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP") -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset Roll
--Attack
KBD:SetDefaultKey("FIRE",StarGate.KeyBoard.BINDS["+attack"] or "MOUSE1") -- Fire blasts
--Special Actions
KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset roll
KBD:SetDefaultKey("BOOM","BACKSPACE")

--View
KBD:SetDefaultKey("Z+","UPARROW")
KBD:SetDefaultKey("Z-","DOWNARROW")
KBD:SetDefaultKey("A+","LEFTARROW")
KBD:SetDefaultKey("A-","RIGHTARROW")
KBD:SetDefaultKey("VIEW","1")

KBD:SetDefaultKey("EXIT",StarGate.KeyBoard.BINDS["+use"] or "E")

function ENT:Initialize()
	self.Dist=-850
	self.UDist=250
	self.FirstPerson=false
	self.lastswitch = CurTime();
	self.on1=0;
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.BaseClass.Initialize(self)
	self.Vehicle = "DeathGlider";
end

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local vehicle = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((vehicle)and((vehicle)==self)and(vehicle:IsValid())) then
		self.KBD:SetActive(true)
		self:StartClientsideSound("Normal")
	else
		self.KBD:SetActive(false)
		self:StopClientsideSound("Normal")
	end

	if((vehicle)and((vehicle)==self)and(vehicle:IsValid())) then
		if(p:KeyDown(self.Vehicle,"Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown(self.Vehicle,"Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown(self.Vehicle,"A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown(self.Vehicle,"A-")) then
			self.UDist=self.UDist-5
		end
	end
end

