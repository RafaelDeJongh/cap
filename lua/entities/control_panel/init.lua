/*
	Control Panel
	Copyright (C) 2012 by AlexALX
*/

if (not StarGate.CheckModule("extra")) then return end

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

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