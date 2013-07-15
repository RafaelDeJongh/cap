include('shared.lua')
ENT.Category = Language.GetMessage("entity_ships_cat");
ENT.PrintName = Language.GetMessage("entity_teltak");
ENT.ViewOverride = true;
ENT.Sounds = {
	Engine=Sound("vehicles/AlkeshEngine.wav"),
}

--########## Keybinder stuff
local KBD = StarGate.KeyBoard:New("Teltac")
--Navigation
KBD:SetDefaultKey("FWD","W"); -- Forward
KBD:SetDefaultKey("LEFT","A"); -- Forward
KBD:SetDefaultKey("RIGHT","D"); -- Forward
KBD:SetDefaultKey("BACK","S"); -- Forward
KBD:SetDefaultKey("UP","SPACE"); -- Forward
KBD:SetDefaultKey("DOWN","CTRL"); -- Forward
KBD:SetDefaultKey("SPD","SHIFT");
KBD:SetDefaultKey("LAND","ENTER");
--Roll
KBD:SetDefaultKey("RL","MWHEELDOWN"); -- Roll left
KBD:SetDefaultKey("RR","MWHEELUP"); -- Roll right
KBD:SetDefaultKey("RROLL","MOUSE3"); -- Reset Roll
--Attack
KBD:SetDefaultKey("FIRE","MOUSE1"); -- Fire blasts
--Special Actions
KBD:SetDefaultKey("RROLL","MOUSE3"); -- Reset roll
KBD:SetDefaultKey("BOOM","BACKSPACE");
KBD:SetDefaultKey("CLOAK","ALT");
KBD:SetDefaultKey("DOOR","2");
KBD:SetDefaultKey("HYPERSPACE","R");

--View
KBD:SetDefaultKey("Z+","UPARROW");
KBD:SetDefaultKey("Z-","DOWNARROW");
KBD:SetDefaultKey("A+","LEFTARROW");
KBD:SetDefaultKey("A-","RIGHTARROW");
KBD:SetDefaultKey("FPV","1");

KBD:SetDefaultKey("EXIT","E");


function ENT:Initialize()
	self.Dist=-1160
	self.UDist=450
	self.KBD = self.KBD or KBD:CreateInstance(self)
	self.BaseClass.Initialize(self)
	self.Vehicle = "Teltac";
	self.NextPress = CurTime();
	self.FPV = 0;
end


function SGTeltacCalcView(Player,Origin, Angles, FieldOfView)
	local view = {};

	local p = LocalPlayer();
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL);

	if(IsValid(self) and self:GetClass()=="sg_vehicle_teltac") then
		if(self.FPV==0) then
			local pos = self:GetPos()+self:GetUp()*self.UDist+LocalPlayer():GetAimVector():GetNormal()*self.Dist;
			local face = ( ( self:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle();
			view.origin = pos;
			view.angles = face;
		elseif(self.FPV==1) then
			local pos = self.Entity:GetPos()+self.Entity:GetForward()*500+self.Entity:GetUp()*130+self:GetRight()*30;
			local angle = self.Entity:GetAngles();
			view.origin = pos;
			view.angles = angle;
		elseif(self.FPV==2) then
			local pos = self:LocalToWorld(Vector(0,0,10));
			local angle = self.Entity:GetAngles()+Angle(90,0,0);
			view.origin = pos;
			view.angles = angle;
		end
		return view;
	end
end
hook.Add("CalcView", "SGTeltacCalcView", SGTeltacCalcView)

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

		if(p:KeyDown(self.Vehicle,"FPV") and self.NextPress < CurTime()) then
			if(self.FPV == 2) then self.FPV = 0
		else
			self.FPV = self.FPV + 1
		end
		self.NextPress = CurTime() + 1;
		end
	end
end

