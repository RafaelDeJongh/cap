/*
	molecular construction device for GarrysMod10
	Copyright (C) 2010  Llapp
*/

include("shared.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_mcd");
language.Add("molecular_construction_device",SGLanguage.GetMessage("entity_mcd_full"));
end

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.MCD_hud = surface.GetTextureID("VGUI/resources_hud/MCD");

ENT.Sounds = {
	Idle=Sound("tech/mcd_idle.wav"),
}

function ENT:Initialize()
    self.Emitter = ParticleEmitter(Vector(0,0,0))
	self.Emitter2 = ParticleEmitter(Vector(0,0,0))
	self.IdleSound = self.IdleSound or CreateSound(self.Entity,self.Sounds.Idle);
	self.Entity:SetNetworkedInt("Advance",0);
	self.KillTime = 0;
	self.RefractSize = 80;
	self.KillTime = CurTime() + 1.35;
	self.Aplha = 0;
	self.AlTr = true;
end

function ENT:Draw()
    self.Entity:DrawModel();
	hook.Remove("HUDPaint",tostring(self.Entity).."MCD");
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."MCD",function()
		    local w = -30;
            local h = 72;
		    surface.SetTexture(self.MCD_hud);
	        surface.SetDrawColor(Color( 255, 255, 255, 155 ));
	        surface.DrawTexturedRect(ScrW() / 2 + 6 + w +21, ScrH() / 2 - 40 - h, 84, 100);

	        surface.SetFont("center2")
	        surface.SetFont("header")

            draw.DrawText("MCD", "header", ScrW() / 2 + 57 + w, ScrH() / 2 +43 - h - 74, Color(0,255,255,255), 0)
            draw.DrawText("Progress", "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +65 - h - 70, Color(209,238,238,255),0);

            surface.SetFont("center")
			local percent = 0;
			if(IsValid(self.Entity))then
	            percent = self.Entity:GetNetworkedInt("Advance",0);
			end
			if(percent>0)then
                percent = string.format("%G",percent);
	        end
            draw.SimpleText(percent.."%", "center", ScrW() / 2 + 40 + w, ScrH() / 2 +85 - h - 70, Color(209,238,238,255),0)
		end);
	end
end

function ENT:OnRemove()
    hook.Remove("HUDPaint",tostring(self.Entity).."MCD");
    self.IdleSound:Stop()
end

function ENT:Think()
    self:MolecularParticle();
	if(self.Entity:GetNWBool("IdleSound"))then
		self.IdleSound:ChangePitch(130,140,100);
		self.IdleSound:SetSoundLevel(60);
		self.IdleSound:PlayEx(0.8,97);
	else
		self.IdleSound:Stop()
	end
	if(CurTime() > self.KillTime)then return false end
	if(not self.Entity:IsValid())then return false end
    self.Entity:NextThink(CurTime()+0.0001);
	return true;
end

function ENT:MolecularParticle()
    if(self.Entity:GetNWBool("StartEffects"))then
	    self.Timer = self.Timer or 0
	    if ( self.Timer > CurTime() ) then return end
	    self.Timer = CurTime() + 0.00002
		local mathe1 = math.random(-60,60)
		local mathe2 = math.random(-60,60)
		local mathe3 = math.random(-60,60)
        self.Ent = self.Entity:GetNWEntity("CreatingEntity");
        if (IsValid(self.Ent)) then
			local pos = self.Ent:GetPos() + self.Ent:GetUp()*mathe1 + self.Ent:GetRight()*mathe2 + self.Ent:GetForward()*mathe3;
	        local angle = (self.Ent:GetPos() - pos):GetNormalized()*((math.abs(mathe1) + math.abs(mathe2) + math.abs(mathe3)*5))
		    local pt = self.Emitter:Add("sprites/gmdm_pickups/light",pos);
		    pt:SetVelocity(angle);
		    pt:SetDieTime(1);
		    pt:SetAirResistance(250)
		    pt:SetStartAlpha(85);
		    pt:SetEndAlpha(255);
		    pt:SetStartSize(3);
		    pt:SetEndSize(0.4);
		    pt:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)));
		    pt:VelocityDecay(false);
		    --self.Emitter:Finish();

			local size = math.random(0.5,0.7);
			local pt2 = self.Emitter2:Add("sprites/gmdm_pickups/light",self.Ent:GetPos());
		    pt2:SetDieTime(0.2);
		    pt2:SetAirResistance(150)
		    pt2:SetStartAlpha(0);
		    pt2:SetEndAlpha(255);
		    pt2:SetStartSize(size);
		    pt2:SetEndSize(size);
		    pt2:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)));
		    pt2:VelocityDecay(false);
			--self.Emitter2:Finish();

			local dynlight2 = DynamicLight(0);
			dynlight2.Pos = self.Ent:GetPos() - self.Ent:GetUp()*10;
			dynlight2.Size = 200;
			dynlight2.Decay = 300;
			dynlight2.R = 155;
			dynlight2.G = 35;
			dynlight2.B = 0;
			dynlight2.DieTime = CurTime()+3;
		 end
    end
end

local VGUI = {}
function VGUI:Init()
	local DermaPanel = vgui.Create( "DFrame" )
   	DermaPanel:SetPos( ScrW()/2 - 163.5,ScrH()/2 - 227.5 )
   	DermaPanel:SetSize( 327, 455 )
	DermaPanel:SetTitle( "Molecular Construction Device Creationmenu" )
   	DermaPanel:SetVisible( true )
   	DermaPanel:SetDraggable( false )
   	DermaPanel:ShowCloseButton( true )
   	DermaPanel:MakePopup()
	DermaPanel.Paint = function()
        surface.SetDrawColor( 80, 80, 80, 185 )
        surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )
    end
	local image = vgui.Create("TGAImage" , DermaPanel);
    image:SetSize(10, 10);
    image:SetPos(10, 10);
    image:LoadTGAImage("materials/gui/cap_logo.tga", "MOD");

    local NumSliderThingy1 = vgui.Create( "DNumSlider" , DermaPanel )
    NumSliderThingy1:SetPos( 25,270 )
    NumSliderThingy1:SetSize( 280, 50 )
    NumSliderThingy1:SetText( "Size" )
    NumSliderThingy1:SetMin( 0 )
    NumSliderThingy1:SetMax( 1024 )
	NumSliderThingy1:SetValue( 100 );
    NumSliderThingy1:SetDecimals( 2 )
	NumSliderThingy1:SetToolTip("Set the Size for Shield, Tollana Disabler, Cloaking Generator or Jamming Device.")

	local NumSliderThingy2 = vgui.Create( "DNumSlider" , DermaPanel )
    NumSliderThingy2:SetPos( 25,300 )
    NumSliderThingy2:SetSize( 280, 50 )
    NumSliderThingy2:SetText( "Faster - Stronger" )
    NumSliderThingy2:SetMin( -5 )
    NumSliderThingy2:SetMax( 5 )
	NumSliderThingy2:SetValue( 0 );
    NumSliderThingy2:SetDecimals( 2 )
	NumSliderThingy2:SetToolTip("Set the Strengh for the Shield.")

	local CheckBoxThing1 = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckBoxThing1:SetPos( 25,350 )
    CheckBoxThing1:SetText( "Immunity" )
    CheckBoxThing1:SetValue( 1 )
    CheckBoxThing1:SizeToContents()
	CheckBoxThing1:SetToolTip("Set Immunity for Shield, Tollana Disabler, Cloaking Generator or Jamming Device.")
	local immunity = 0

	local CheckBoxThing2 = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckBoxThing2:SetPos( 110,350 )
    CheckBoxThing2:SetText( "Phase Shifting" )
    CheckBoxThing2:SetValue( 0 )
    CheckBoxThing2:SizeToContents()
	CheckBoxThing2:SetToolTip("Set Phase Shifting for Cloaking Generator.")
	local phaseshifting = 0

	local CheckBoxThing3 = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckBoxThing3:SetPos( 220,350 )
    CheckBoxThing3:SetText( "Draw Bubble" )
    CheckBoxThing3:SetValue( 1 )
    CheckBoxThing3:SizeToContents()
	CheckBoxThing3:SetToolTip("Set Draw Bubble for Shield.")
	local drawbubble = 0

	local CheckBoxThing4 = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckBoxThing4:SetPos( 25,380 )
    CheckBoxThing4:SetText( "Show Effect when Passing Shield" )
    CheckBoxThing4:SetValue( 0 )
    CheckBoxThing4:SizeToContents()
	CheckBoxThing4:SetToolTip("Set Passing Effect for Shield.")
	local passing = 0

	local CheckBoxThing5 = vgui.Create( "DCheckBoxLabel", DermaPanel )
    CheckBoxThing5:SetPos( 220,380 )
    CheckBoxThing5:SetText( "Containment" )
    CheckBoxThing5:SetValue( 0 )
    CheckBoxThing5:SizeToContents()
	CheckBoxThing5:SetToolTip("Set Containment for Shield.")
	local containment = 0

	local MenuButtonClose = vgui.Create("DButton")
    MenuButtonClose:SetParent( DermaPanel )
    MenuButtonClose:SetText( "Close" )
    MenuButtonClose:SetPos(25, 410)
    MenuButtonClose:SetSize( 135, 25 )
	MenuButtonClose.DoClick = function ( btn )
		DermaPanel:Remove()
    end

	local NumPad = vgui.Create( "CtrlNumPad", DermaPanel )
    NumPad:SetPos( 150, 30 )
	NumPad:SetSize( 200, 100 )
	NumPad:SetLabel1( "Set the Toogle" )
	NumPad:SetToolTip("Set the Toggle for Shield, Tollana Disabler, Cloaking Generator or Jamming Device.")

	local color = vgui.Create( "DColorMixer", DermaPanel);
    color:SetSize( 132, 175);
    color:SetPos( 190, 110 );
    color:SetColor(Color(170,189,255,255))
    color:SetToolTip("Set the Color for Shield.")

	local ComboBox = vgui.Create( "DListView", DermaPanel )
	ComboBox:SetPos( 25, 30 )
	ComboBox:SetSize( 145, 200 )
	ComboBox:SetMultiSelect( false )
	ComboBox.Paint = function()
        surface.SetDrawColor( 155, 155, 155, 125 )
		surface.SetFont( "default" )
		surface.SetTextColor( 255, 255, 255, 255 )
        surface.DrawRect( 0, 0, ComboBox:GetWide(), ComboBox:GetTall() )
    end
    ComboBox:AddColumn("Select Device")
    ComboBox.Columns[1].DoClick = function() end
	ComboBox:AddLine( "Cloaking Generator" )
	ComboBox:AddLine( "Shield Generator" )
	ComboBox:AddLine( "Jamming Device" )
	ComboBox:AddLine( "Telchak" )
	ComboBox:AddLine( "ZPM MK3" )
	ComboBox:AddLine( "Tollan Disabler" )
	--ComboBox:AddLine( "Anti Preori Device" )
	ComboBox:AddLine( "Naquadah Gen MK1" )
	ComboBox:AddLine( "Arthurs Mantle" )
	ComboBox:SetToolTip("Select your Entity.")
	ComboBox:SortByColumn(1,false)

	local MenuButtonCreate = vgui.Create("DButton")
    MenuButtonCreate:SetParent( DermaPanel )
    MenuButtonCreate:SetText( "Create" )
    MenuButtonCreate:SetPos(170, 410)
    MenuButtonCreate:SetSize( 135, 25 )
	MenuButtonCreate.DoClick = function ( btn )
	    if(ComboBox:GetSelected()[1] and ComboBox:GetSelected())then
	        local value = ComboBox:GetSelected()[1]:GetValue(1);
		    local models = {"models/micropro/shield_gen.mdl",
			                "models/Iziraider/disabler/disabler.mdl",
							"",}
			local entsi = {"Cloaking Generator:cloaking_generator:"..models[1],
                		   "Shield Generator:shield_generator:"..models[1],
						   "Jamming Device:jamming_device:"..models[1],
						   "Telchak:telchak:"..models[3],
						   "ZPM MK3:zpm_mk3:"..models[3],
						   "Tollan Disabler:tollan_disabler:"..models[2],
						   --"Anti Preori Device:anti_prior:"..models[3],
						   "Naquadah Gen MK1:naquadah_generator:"..models[3],
						   "Arthurs Mantle:arthur_mantle:"..models[3],}
			for _,j in pairs(entsi) do
			    entsr = string.Explode(":",j)
    		    if(value == entsr[1])then
	    		    if(CheckBoxThing1:GetChecked())then immunity = 1 end
	    		    if(CheckBoxThing2:GetChecked())then phaseshifting = 1 end
	    		    if(CheckBoxThing3:GetChecked())then drawbubble = 1 end
	    		    if(CheckBoxThing4:GetChecked())then passing = 1 end
	    		    if(CheckBoxThing5:GetChecked())then containment = 1 end
					local col = color:GetColor()
					local this_ent = string.Explode(" ",tostring(e))

					net.Start("MCD")
					net.WriteEntity(self.Entity)
					net.WriteString(entsr[2])
					net.WriteString(entsr[3])
					net.WriteInt(NumSliderThingy1:GetValue(),16)
					net.WriteBit(util.tobool(immunity))
					net.WriteBit(util.tobool(phaseshifting))
					net.WriteInt(NumSliderThingy2:GetValue(),16)
					net.WriteBit(util.tobool(drawbubble))
					net.WriteBit(util.tobool(passing))
					net.WriteBit(util.tobool(containment))
					net.WriteInt(NumPad.NumPad1:GetValue(),16)
					net.WriteInt(col.r,8)
					net.WriteInt(col.g,8)
					net.WriteInt(col.b,8)
					net.SendToServer();

	                DermaPanel:Remove()
			    end
	        end
	    end
    end
end

function VGUI:SetEntity(e)
	self.Entity = e;
end

vgui.Register( "MCDEntry", VGUI )

function MolecularConstructionDevice(um)
	local e = um:ReadEntity();
	if(not IsValid(e)) then return end;
	local Window = vgui.Create( "MCDEntry" )
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	Window:SetEntity(e)
end
usermessage.Hook("MolecularConstructionDevice", MolecularConstructionDevice)