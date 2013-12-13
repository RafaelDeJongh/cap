/*
	Control Panel
	Copyright (C) 2012 by AlexALX
*/

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.PrintName = "Control Panel"
ENT.Author	= "AlexALX"
ENT.Contact	= ""
ENT.Purpose	= ""
ENT.Instructions = "Use this with wiremod."
ENT.Category = "Stargate"
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.ButtonPosGoauld = {
	[1] = Vector(2.55, -3.3, 12.1),
	[2] = Vector(2.55, 3.3, 12.1),
	[3] = Vector(2.55, -3.3, 9.1),
	[4] = Vector(2.55, 3.3, 9.1),
	[5] = Vector(2.55, -3.3, 6.1),
	[6] = Vector(2.55, 3.3, 6.1),
}

ENT.ButtonPosOri = {
	[1] = Vector(1.40, -9.97, 3.31),
	[2] = Vector(1.36, -8.98, 5.82),
	[3] = Vector(1.38, -7.46, 7.76),
	[4] = Vector(1.42, -5.17, 9.24),
	[5] = Vector(1.46, -2.95, 10.12),
	[0] = Vector(2.15, 0.09, 2.25),
}

ENT.ButtonPosAncient = {
	[1] = Vector(1.53, -1.5, 19.38),
	[2] = Vector(1.53, 1.5, 19.38),
	[3] = Vector(1.53, 0, 15.68),
	[4] = Vector(1.53, -1.5, 11.98),
	[5] = Vector(1.53, 1.5, 11.98),
	[7] = Vector(1.53, -2.5, 4.57),
	[8] = Vector(1.53, 0, 4.57),
	[9] = Vector(1.53, 2.5, 4.57),
	[6] = Vector(1.53, 0, 8.28),
}

function ENT:ButtonPos(butt)
	if (self.ButtonPosVal) then
		if (butt!=nil) then
			return self.ButtonPosVal[butt];
		else
			return self.ButtonPosVal;
		end
	end
	if (self.Entity:GetModel()=="models/zsdaniel/ori-ringpanel/panel.mdl") then
		self.ButtonPosVal = self.ButtonPosOri;
		if (butt!=nil) then
			return self.ButtonPosVal[butt];
		else
			return self.ButtonPosVal;
		end
	elseif (self.Entity:GetModel()=="models/madman07/ring_panel/ancient_panel.mdl") then
		self.ButtonPosVal = self.ButtonPosAncient;
		if (butt!=nil) then
			return self.ButtonPosVal[butt];
		else
			return self.ButtonPosVal;
		end
	end
	self.ButtonPosVal = self.ButtonPosGoauld;
	if (butt!=nil) then
		return self.ButtonPosVal[butt];
	else
		return self.ButtonPosVal;
	end
end

function ENT:GetAimingButton(p)
	local e = self.Entity;
	local c = e:ButtonPos();
	local t = p:GetEyeTrace();
	local cv = self.Entity:WorldToLocal(t.HitPos)
	local btn = nil;
	local lastd = 5;
	for k,v in pairs(c) do
		da = (cv - c[k]):Length()
		if(da < 1.5) then
			if(da < lastd) then
				lastd = da;
				btn = k;
			end
		end
	end
	return btn;
end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.MiddleGoauld = Vector(2.55, 0, 12.1);
ENT.MiddleOri = Vector(2.15, 0.09, 2.25);
ENT.MiddleAncient = Vector(1.53, 0, 11.98);

function ENT:Middle()
	if (self.MiddleVal) then return self.MiddleVal; end
	if (self.Entity:GetModel()=="models/zsdaniel/ori-ringpanel/panel.mdl") then
		self.MiddleVal = self.MiddleOri;
		return self.MiddleVal;
	elseif (self.Entity:GetModel()=="models/madman07/ring_panel/ancient_panel.mdl") then
		self.MiddleVal = self.MiddleAncient;
		return self.MiddleVal;
	end
	self.MiddleVal = self.MiddleGoauld;
	return self.MiddleVal;
end

function ENT:Draw()
	self.Entity:DrawModel();
	if (not self.Entity:GetNetworkedBool("Draw",true)) then return end
	local address = self.Entity:GetNWString("ADDRESS","");
	local eye = self.Entity:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos)
	local len = (eye - self.Entity:Middle()):Length()

	if (len <= 20 or address != "") then

		local restalpha = 0;
		if (len <= 20) then restalpha = 50; end

		local ang = self.Entity:GetAngles();
		ang:RotateAroundAxis(ang:Up(), -90);
		ang:RotateAroundAxis(ang:Up(), 180);
		ang:RotateAroundAxis(ang:Forward(), 90);

		local button = 0;
		button = self:GetAimingButton(LocalPlayer())
		local btns = self.Entity:ButtonPos();
		for k,v in pairs(btns) do

			local pos = self.Entity:LocalToWorld(v);

			local alpha = restalpha;
			if(address==tostring(k) or button == k) then
				alpha = 200;
			end
			local a = Color(255,255,255,alpha)

			local txt = tostring(k);

			cam.Start3D2D(pos,ang,0.1);
				draw.SimpleText(txt,"OldDefaultSmall",0,0,a,1,1);
			cam.End3D2D();

		end

	end

end

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile()

ENT.SoundsGoauld={
	[1] = Sound("button/ring_button1.mp3"),
	[2] = Sound("button/ring_button2.mp3"),
}

ENT.SoundsAncient={
	[1] = Sound("button/ancient_button1.wav"),
	[2] = Sound("button/ancient_button2.wav"),
}

function ENT:Initialize()

	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
	self.Entity:SetNetworkedString("ADDRESS","");
	self.Entity:SetNetworkedBool("Draw",true);

	self.CantDial = false;
	self.Snd = false;
	self:CreateWireInputs("Press Button","Valid","NoDraw");
	if (self.Entity:GetModel()=="models/zsdaniel/ori-ringpanel/panel.mdl") then
		self.Sounds = self.SoundsAncient;
		self.Buttons = {1,2,3,4,5,0};
		self.SkinOff = 8;
		self:CreateWireOutputs("1", "2", "3", "4", "5", "0", "Button Pressed");
	elseif (self.Entity:GetModel()=="models/madman07/ring_panel/ancient_panel.mdl") then
		self.Sounds = self.SoundsAncient;
		self.Buttons = {1,2,3,4,5,6,7,8,9};
		self.SkinOff = 10;
		self:CreateWireOutputs("1", "2", "3", "4", "5", "6", "7", "8", "9", "Button Pressed");
	else
		self.Sounds = self.SoundsGoauld;
		self.Buttons = {1,2,3,4,5,6};
		self.SkinOff = 7;
		self:CreateWireOutputs("1", "2", "3", "4", "5", "6", "Button Pressed");
	end
	self:SetWire("Button Pressed",-1);
end

function ENT:Use(ply)
	if (IsValid(ply) and ply:IsPlayer()) then
		if (not self.CantDial) then
			local button = self:GetAimingButton(ply);
			if (button) then self:PressButton(button, ply) end
		end
	end
end

function ENT:PressButton(button)
	if (not table.HasValue(self.Buttons,button) or self.CantDial) then return end

	self.CantDial = true;
	self.Entity:SetNetworkedString("ADDRESS",tostring(button));

	self:SetWire(tostring(button),1);
	self:SetWire("Button Pressed",button);
	local delay = 0.25
	if (self.Entity:GetWire("Valid") > 0) then
		self.Snd = true;
		delay = 0.5
	else
		self.Snd = false;
	end
	if (self.SkinOff==8 and self.Snd) then
		self.Entity:Fire("skin",7);
	else
		if (button==0) then
			self.Entity:Fire("skin",6);
		else
			self.Entity:Fire("skin",button);
		end
	end
	timer.Create( self.Entity:EntIndex().."Skin", delay, 1, function()
		if (IsValid(self.Entity)) then
			self.Entity:Fire("skin",self.SkinOff);
			self.CantDial = false;
			self.Entity:SetNetworkedString("ADDRESS","");
			self:SetWire(tostring(button),0);
			self:SetWire("Button Pressed",-1);
		end
	end )
	if (self.Snd) then
		self.Entity:EmitSound(self.Sounds[1]);
	else
		self.Entity:EmitSound(self.Sounds[2]);
	end
end

function ENT:TriggerInput(name,value)
	if (name == "Press Button") then
		if (value > 0) then
			self:PressButton(value)
        elseif (value < 0) then
			self:PressButton(0)
        end
	elseif (name == "NoDraw") then
		if (value > 0) then
            self.Entity:SetNetworkedBool("Draw", false)
        else
            self.Entity:SetNWBool("Draw", true)
        end
	end
end

end