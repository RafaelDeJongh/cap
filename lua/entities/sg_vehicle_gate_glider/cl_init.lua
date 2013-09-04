include('shared.lua')
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_gate_glider");
end
ENT.RenderGroup = RENDERGROUP_BOTH

if (StarGate==nil or StarGate.KeyBoard==nil) then return end

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("GateGlider")
--Navigation
KBD:SetDefaultKey("FWD","W") -- Forward
KBD:SetDefaultKey("LEFT","A")
KBD:SetDefaultKey("RIGHT","D")
KBD:SetDefaultKey("BACK","S")
KBD:SetDefaultKey("UP","SPACE")
KBD:SetDefaultKey("DOWN","CTRL")
KBD:SetDefaultKey("SPD","SHIFT")
--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN") -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP") -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3") -- Reset Roll
--Attack
KBD:SetDefaultKey("FIRE","MOUSE1")
KBD:SetDefaultKey("TRACK","MOUSE2")
--Special Actions
KBD:SetDefaultKey("DHD","R")
KBD:SetDefaultKey("BOOM","BACKSPACE")
--View
KBD:SetDefaultKey("VIEW","1")
KBD:SetDefaultKey("Z+","UPARROW")
KBD:SetDefaultKey("Z-","DOWNARROW")
KBD:SetDefaultKey("A+","LEFTARROW")
KBD:SetDefaultKey("A-","RIGHTARROW")

KBD:SetDefaultKey("EXIT","E")

ENT.Sounds={
	Engine=Sound("glider/deathglideridleoutside.wav"),
}

function ENT:Initialize( )
	self.BaseClass.Initialize(self)
	self.Dist=-750
	self.UDist=120
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.FirstPerson=false
	self.Vehicle = "GateGlider"
end

--[[

function SGGGCalcView(Player, Origin, Angles, FieldOfView)
	local view = {}
	--self.BaseClass.CalcView(self,Player, Origin, Angles, FieldOfView)
	local p = LocalPlayer()
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if(IsValid(self) and self:GetClass()=="sg_vehicle_gate_glider") then
		if(self.FirstPerson) then
			local pos = self:GetPos()+self:GetUp()*20+self:GetForward()*70;
			local angle = self:GetAngles( );
				view.origin = pos		;
				view.angles = angle;
				view.fov = FieldOfView + 20;
			return view;
		else
			local pos = self:GetPos()+self:GetUp()*self.Udist+Player:GetAimVector():GetNormal()*-self.Dist;
			local face = ( ( self.Entity:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle() + Angle(0,180,0);
				view.origin = pos;
				view.angles = face;
			return view;
		end
	end
end
hook.Add("CalcView", "SGGGCalcView", SGGGCalcView)
]]--

--######## Mainly Keyboard stuff @RononDex
function ENT:Think()

	self.BaseClass.Think(self)

	local p = LocalPlayer()
	local GateGlider = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((GateGlider)and((GateGlider)==self)and(GateGlider:IsValid())) then
		self.KBD:SetActive(true)
	else
		self.KBD:SetActive(false)
	end

	if((GateGlider)and((GateGlider)==self)and(GateGlider:IsValid())) then
		if(p:KeyDown("GateGlider","Z+")) then
			self.Dist = self.Dist-5
		elseif(p:KeyDown("GateGlider","Z-")) then
			self.Dist = self.Dist+5
		end

		if(p:KeyDown("GateGlider","VIEW")) then
			if(self.FirstPerson) then
				self.FirstPerson=false
			else
				self.FirstPerson=true
			end
		end

		if(p:KeyDown("GateGlider","A+")) then
			self.UDist=self.UDist+5
		elseif(p:KeyDown("GateGlider","A-")) then
			self.UDist=self.UDist-5
		end
	end
end