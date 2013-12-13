--[[
	Ancient Console
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ancient Control Panel"
ENT.Author = "Madman07"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Ancient Control Panel"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.AutomaticFrameAdvance = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile();

ENT.Sounds = {
	PressOne=Sound("dakara/dakara_control_panel.wav"),
	PressFew=Sound("dakara/dakara_control_panel2.wav"),
}

ENT.Anims = {
	"push1",
	"push2",
	"push3",
	"push4",
	"push5",
	"random",
	"reset",
	"crystalo",
	"crystalc",
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	util.PrecacheModel("models/Iziraider/dakara/console.mdl")
	self.Entity:SetModel("models/Iziraider/dakara/console.mdl");

	self.Entity:SetName("Ancient Control Console");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.CurrentOption = 0;

	self.OpenCrystal = false;
	self.Busy = false;
	self.AlreadyOpened = false;
	self.AnimRunning = false;

end

-----------------------------------USE----------------------------------

function ENT:Use(ply)
	if(not self.Busy)then
		umsg.Start("AncientPanel",ply)
	    umsg.Entity(self.Entity);
	    umsg.End()
		self.Player = ply;
	end
end

-- function ENT:StartTouch(ent)
	-- if IsValid(ent) then
		-- if (ent:GetModel() == "models/iziraider/artifacts/ancient_pallet.mdl") then
			-- if not self.AlreadyOpened then
				-- self.AlreadyOpened = true;
				-- local dakara = self:FindDakara();
				-- dakara.Inputs = WireLib.CreateInputs( dakara, {"Main", "Secret"});
			-- end
		-- end
	-- end
-- end

-- function ENT:ToggleCrystal()
	-- if self.OpenCrystal then
		-- self.OpenCrystal = false;
		-- self.ModelAnim:Fire("setanimation","crystalc","0")
	-- else
		-- self.OpenCrystal = true;
		-- self.ModelAnim:Fire("setanimation","crystalo","0")
	-- end
-- end

-----------------------------------OTHER CRAP----------------------------------

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS; end

--########## Run the anim that's set in the arguements @RononDex
function ENT:Anim(anim,delay,nosound,sound)
	timer.Create(anim..self:EntIndex(),delay,1,function()
		if IsValid(self) then
			self:NextThink(CurTime());
			if(not(nosound)) then --Set false to allow sound
				self:EmitSound(sound,100,math.random(90,110)); --create sound as a string in the arguements
			end
			self:SetPlaybackRate(1);
			self:ResetSequence(self:LookupSequence(anim)); -- play the sequence
		end
	end);
end

function ENT:Think()
	if self.AnimRunning then --run often only if doors are busy
		self:NextThink(CurTime());
		return true
	end
end

function ENT:Think(ply)

	concommand.Add("AP"..self:EntIndex(),function(ply,cmd,args)

		local power = tonumber(args[1]);

		self.AnimRunning = true;

		self:Anim(self.Anims[1], 0, false, self.Sounds.PressOne);
		self:Anim(self.Anims[2], 1.5, false, self.Sounds.PressOne);
		self:Anim(self.Anims[3], 3, false, self.Sounds.PressOne);
		self:Anim(self.Anims[4], 4.5, false, self.Sounds.PressOne);
		self:Anim(self.Anims[5], 6, false, self.Sounds.PressOne);

		self:Anim(self.Anims[6], 7.5+power/2, false, self.Sounds.PressFew);
		self:Anim(self.Anims[6], 11.5+power/2, false, self.Sounds.PressFew);
		self:Anim(self.Anims[7], 17.5+power/2, false, self.Sounds.PressOne);

		timer.Create("StopAnim"..self:EntIndex(),20+power/2,1,function() self.AnimRunning = false end);

		local dakara = self:FindDakara();
		if (IsValid(dakara)) then
			timer.Create("PrepareDakara"..self:EntIndex(),5+power/2,1,function()
				if (IsValid(dakara)) then dakara:PrepareWeapon(power, tonumber(args[2]), tonumber(args[3]), tonumber(args[4]), tonumber(args[5]), tonumber(args[6])) end
			end);

			timer.Create("DialAllGates"..self:EntIndex(),power/2,1,function()
				if (IsValid(self)) then self:DiallAllGates(dakara); end
			end);
		end

    end);

end

function ENT:DiallAllGates(dakara)
	self.DialGate = dakara:FindGate();
	if IsValid(self.DialGate) then

		self.IncomingGates = dakara:FindAllGate();
		self.DialGate.Target = self.DialGate;

		self.DialGate:AbortDialling();
		for _,v in pairs(self.IncomingGates or {}) do
			v:AbortDialling();
		end

		timer.Create("DialFrom"..self:EntIndex(),2,1,function()
			local action = self.DialGate.Sequence:New();
			action = self.DialGate.Sequence:Dial(false,true,false);
			action = action + self.DialGate.Sequence:OpenGate(true);
			self.DialGate:RunActions(action);
		end);

		timer.Create("DialTo"..self:EntIndex(),2.3,1,function()
			for _,v in pairs(self.IncomingGates or {}) do
				v.Outbound = true; // fix lighting up dhds
				local action = v.Sequence:New();
				action = v.Sequence:Dial(true,true,false);
				action = action + v.Sequence:OpenGate();
				v:RunActions(action);
			end
		end);

		timer.Create("Autoclose"..self:EntIndex(),15,1,function()
			if (IsValid(self.DialGate)) then
				self.DialGate:EmergencyShutdown(); -- different methods or gates wont close, hope it will work
				self.DialGate:AbortDialling();
				self.DialGate:DeactivateStargate(true);
				for _,v in pairs(self.IncomingGates or {}) do
					if IsValid(v) then
						v:EmergencyShutdown();
						v:AbortDialling();
						v:DeactivateStargate(true);
					end
				end
			end
		end);

	end
end

function ENT:FindDakara()
	local gate;
	local dist = 10000000;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("dakara_building")) do
		local sg_dist = (pos - v:GetPos()):Length();
		if(dist >= sg_dist) then
			dist = sg_dist;
			gate = v;
		end
	end
	return gate;
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	language.Add("ancient_control_panel",SGLanguage.GetMessage("ancient_control_panel"));
end

function ENT:Draw()
    self.Entity:DrawModel();
end

local VGUI = {}
function VGUI:Init()
	local DermaPanel = vgui.Create( "DFrame" )
   	DermaPanel:SetPos( ScrW()/2 - 163.5,ScrH()/2 - 227.5 )
   	DermaPanel:SetSize( 400, 250 )
	DermaPanel:SetTitle( SGLanguage.GetMessage("dakara_panel") )
   	DermaPanel:SetVisible( true )
   	DermaPanel:SetDraggable( false )
   	DermaPanel:ShowCloseButton( true )
   	DermaPanel:MakePopup()
	DermaPanel.Paint = function()
        surface.SetDrawColor( 80, 80, 80, 185 )
        surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )
    end

	local NumSliderThingy2 = vgui.Create( "DNumSlider" , DermaPanel )
    NumSliderThingy2:SetPos( 25,120 )
    NumSliderThingy2:SetSize( 360, 50 )
    NumSliderThingy2:SetText( SGLanguage.GetMessage("dakara_power_d") )
    NumSliderThingy2:SetMin( -5 )
    NumSliderThingy2:SetMax( 5 )
	NumSliderThingy2:SetValue( 0 );
    NumSliderThingy2:SetDecimals( 2 )
	NumSliderThingy2:SetToolTip(SGLanguage.GetMessage("dakara_power"))

	local CheckBoxThing1 = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckBoxThing1:SetPos( 25,30 )
    CheckBoxThing1:SetText( SGLanguage.GetMessage("dakara_menu_01") )
    CheckBoxThing1:SetValue( 1 )
    CheckBoxThing1:SizeToContents()
	CheckBoxThing1:SetToolTip(SGLanguage.GetMessage("dakara_menu_02"))
	local immunity = 0

	local CheckBoxThing2 = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckBoxThing2:SetPos( 25,50 )
    CheckBoxThing2:SetText( SGLanguage.GetMessage("dakara_menu_03") )
    CheckBoxThing2:SetValue( 0 )
    CheckBoxThing2:SizeToContents()
	CheckBoxThing2:SetToolTip(SGLanguage.GetMessage("dakara_menu_04"))
	local phaseshifting = 0

	local CheckBoxThing3 = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckBoxThing3:SetPos( 25,70 )
    CheckBoxThing3:SetText( SGLanguage.GetMessage("dakara_menu_05") )
    CheckBoxThing3:SetValue( 0 )
    CheckBoxThing3:SizeToContents()
	CheckBoxThing3:SetToolTip(SGLanguage.GetMessage("dakara_menu_06"))
	local drawbubble = 0

	local CheckBoxThing4 = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckBoxThing4:SetPos( 200,30 )
    CheckBoxThing4:SetText( SGLanguage.GetMessage("dakara_menu_07") )
    CheckBoxThing4:SetValue( 0 )
    CheckBoxThing4:SizeToContents()
	CheckBoxThing4:SetToolTip(SGLanguage.GetMessage("dakara_menu_08"))
	local passing = 0

	local CheckBoxThing5 = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckBoxThing5:SetPos( 200,50 )
    CheckBoxThing5:SetText( SGLanguage.GetMessage("dakara_menu_09") )
    CheckBoxThing5:SetValue( 0 )
    CheckBoxThing5:SizeToContents()
	CheckBoxThing5:SetToolTip(SGLanguage.GetMessage("dakara_menu_10"))
	local containment = 0

	local MenuButtonClose = vgui.Create("DButton")
    MenuButtonClose:SetParent( DermaPanel )
    MenuButtonClose:SetText( SGLanguage.GetMessage("dakara_menu_11") )
    MenuButtonClose:SetPos(25, 180)
    MenuButtonClose:SetSize( 75, 25 )
	MenuButtonClose.DoClick = function ( btn )
		DermaPanel:Remove()
    end

	local MenuButtonCreate = vgui.Create("DButton")
    MenuButtonCreate:SetParent( DermaPanel )
    MenuButtonCreate:SetText( SGLanguage.GetMessage("dakara_menu_12") )
    MenuButtonCreate:SetPos(125, 180)
    MenuButtonCreate:SetSize( 75, 25 )
	MenuButtonCreate.DoClick = function ( btn )

		local d_ply = 0;
		local d_prp = 0;
		local d_veh = 0;
		local d_rep = 0;
		local d_npc = 0;

		local power = NumSliderThingy2:GetValue()+5;
		if(CheckBoxThing1:GetChecked())then d_ply = 1 end
		if(CheckBoxThing2:GetChecked())then d_prp = 1 end
		if(CheckBoxThing3:GetChecked())then d_veh = 1 end
		if(CheckBoxThing4:GetChecked())then d_rep = 1 end
		if(CheckBoxThing5:GetChecked())then d_npc = 1 end

		LocalPlayer():ConCommand("AP"..e:EntIndex().." "..power.." "..d_ply.." "..d_prp.." "..d_veh.." "..d_rep.." "..d_npc)
		DermaPanel:Remove()

    end
end

vgui.Register( "AncientEntry", VGUI )

function AncientPanel(um)
	local Window = vgui.Create( "AncientEntry" )
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	e = um:ReadEntity();
	if(not IsValid(e)) then return end;
end
usermessage.Hook("AncientPanel", AncientPanel)

end