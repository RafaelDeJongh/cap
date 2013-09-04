--[[
	Ancient Console
	Copyright (C) 2011 Madman07
]]--

include("shared.lua");
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