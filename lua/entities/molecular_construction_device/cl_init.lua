/*
	molecular construction device for GarrysMod10
	Copyright (C) 2010  Llapp, AlexALX
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
	self.ProgressMsg = SGLanguage.GetMessage("mcd_progress");
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
	        surface.DrawTexturedRect(ScrW() / 2 + 6 + w +21, ScrH() / 2 - 40 - h, 104, 100);

	        surface.SetFont("center2")
	        surface.SetFont("header")

            draw.DrawText("MCD", "header", ScrW() / 2 + 70 + w, ScrH() / 2 +43 - h - 74, Color(0,255,255,255), 0)
            draw.DrawText(self.ProgressMsg, "center2", ScrW() / 2 + 40 + w, ScrH() / 2 +65 - h - 70, Color(209,238,238,255),0);

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
		    --pt:VelocityDecay(false);
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
		    --pt2:VelocityDecay(false);
			--self.Emitter2:Finish();
		
			local dynlight2 = DynamicLight(0);
			dynlight2.Pos = self.Ent:GetPos() - self.Ent:GetUp()*10;
			dynlight2.Size = 200;
			dynlight2.Decay = 300;
			local col = self:GetNWVector("EffColor");
			dynlight2.R = col.x*0.5;
			dynlight2.G = col.y*0.5;
			dynlight2.B = col.z*0.5;
			dynlight2.DieTime = CurTime()+3;
		 end
    end
end

local VGUI = {}
function VGUI:Init()
	local DermaPanel = vgui.Create( "DFrame" )
   	--DermaPanel:SetPos( ScrW()/2 - 163.5,ScrH()/2 - 227.5 )
   	DermaPanel:SetSize( 500, 455 )
	DermaPanel:Center()
	DermaPanel:SetTitle( SGLanguage.GetMessage("mcd_title") )
   	DermaPanel:SetVisible( true )
   	DermaPanel:SetDraggable( false )
   	DermaPanel:ShowCloseButton( true )
   	DermaPanel:MakePopup()
	DermaPanel.Paint = function()
        surface.SetDrawColor( 80, 80, 80, 185 )
        surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )
    end
	/*
  	local title = vgui.Create( "DLabel", DermaPanel );
 	title:SetText(SGLanguage.GetMessage("mcd_title"));
  	title:SetPos( 25, 0 );
 	title:SetSize( 400, 25 );
	
 	local image = vgui.Create("DImage" , DermaPanel);
    image:SetSize(16, 16);
    image:SetPos(5, 5);
    image:SetImage("gui/cap_logo");*/
	
	local DermaSettings = vgui.Create( "DPanel", DermaPanel )
	DermaSettings:SetPos(230,30);
	DermaSettings:SetSize( 255, 410 )
	DermaSettings.Paint = function(self)
		local alpha = 100;
		local col = Color( 170, 170, 170, alpha);
		local col2 = Color( 100, 100, 100, alpha);
		local bor = 6;
		local diff = 2;

		draw.RoundedBox( bor, 0, 0, self:GetWide(), self:GetTall(), col);
		draw.RoundedBox( bor, diff, diff, self:GetWide()-2*diff, self:GetTall()-2*diff, col2);
	end
	
	function DermaSettings:UpdateSettings(class)
		self.Label:SetVisible(true)
		self.NumPad:SetVisible(false)
		self.Color:SetVisible(false)
		self.SizeNum:SetVisible(false)
		self.Imm:SetVisible(false)
		self.Phase:SetVisible(false)
		self.Strengh:SetVisible(false)
		self.Buble:SetVisible(false)
		self.Effect:SetVisible(false)
		self.Cont:SetVisible(false)
		self.AntiNC:SetVisible(false)
		
		if (class=="jamming_device" or class=="shield_generator" or class=="cloaking_generator" or class=="tollan_disabler") then
			self.NumPad:SetVisible(true)
			self.SizeNum:SetVisible(true)
			self.Imm:SetVisible(true)
			self.Label:SetVisible(false)
		end
		
		if (class=="shield_generator") then
			self.Color:SetVisible(true)
			self.Strengh:SetVisible(true)
			self.Buble:SetVisible(true)
			self.Effect:SetVisible(true)
			self.Cont:SetVisible(true)
			self.AntiNC:SetVisible(true)
			self.Imm:SetText(SGLanguage.GetMessage("stool_immunity"));
			self.Imm:SetToolTip(SGLanguage.GetMessage("stool_stargate_shield_imm"));
			self.Imm:SizeToContents();
		end
		
		if (class=="cloaking_generator") then
			self.Phase:SetVisible(true)
			self.Imm:SetText(SGLanguage.GetMessage("stool_stargate_cloaking_ow"));
			self.Imm:SetToolTip(SGLanguage.GetMessage("stool_stargate_cloaking_ow_desc"));
			self.Imm:SizeToContents();
		end
		
		if (class=="jamming_device") then
			self.Imm:SetText(SGLanguage.GetMessage("stool_immunity"));
			self.Imm:SetToolTip(SGLanguage.GetMessage("stool_jamming_imm_desc"));
			self.Imm:SizeToContents();
		end
		
		if (class=="tollan_disabler") then
			self.Imm:SetText(SGLanguage.GetMessage("stool_immunity"));
			self.Imm:SetToolTip(SGLanguage.GetMessage("stool_tollan_disabler_imm"));
			self.Imm:SizeToContents();
		end
	end
	
	local DPanel = vgui.Create( "DPanel", DermaSettings )
    DPanel:SetPos( 0, 5 )
	DPanel:SetSize(DermaSettings:GetWide()-10,20)	
	DPanel:CenterHorizontal()
	
	local Label = vgui.Create( "DLabel" , DPanel);
	Label:SetFont("OldDefaultSmall");
	Label:SetPos(15, 0);
	Label:SetText(SGLanguage.GetMessage("mcd_settings"));
	Label:SizeToContents();
	Label:SetColor(Color(0,0,0));
	Label:Center();
	
	local Label = vgui.Create( "DLabel", DermaSettings )
    Label:SetPos( 0, 30 )
	Label:SetText(SGLanguage.GetMessage("mcd_nosettings"));
	Label:SizeToContents()	
	Label:Center()
	DermaSettings.Label = Label;
	
	local NumPad = vgui.Create( "CtrlNumPad", DermaSettings )
    NumPad:SetPos( 0, 30 )
	NumPad:SetSize( 220, 100 )
	NumPad:SetLabel1(SGLanguage.GetMessage("mcd_toggle"))
	NumPad:SetToolTip(SGLanguage.GetMessage("mcd_toggle_desc"))
	NumPad:CenterHorizontal();
	NumPad:SetVisible(false);
	DermaSettings.NumPad = NumPad;
	
    local NumSliderThingy1 = vgui.Create( "DNumSlider" , DermaSettings )
    NumSliderThingy1:SetPos( 15, 90 )
    NumSliderThingy1:SetSize( 235, 50 )
    NumSliderThingy1:SetText( SGLanguage.GetMessage("mcd_size") )
    NumSliderThingy1:SetMin( 0 )
    NumSliderThingy1:SetMax( 1024 )
	NumSliderThingy1:SetValue( 800 );
    NumSliderThingy1:SetDecimals( 2 )
	NumSliderThingy1:SetToolTip(SGLanguage.GetMessage("mcd_size_desc"))
	--NumSliderThingy1:CenterHorizontal();
	NumSliderThingy1:SetVisible(false);
	DermaSettings.SizeNum = NumSliderThingy1;

	local CheckBoxThing1 = vgui.Create( "DCheckBoxLabel", DermaSettings )
    CheckBoxThing1:SetPos( 15, 130 )
    CheckBoxThing1:SetValue( 1 )
	CheckBoxThing1:SetVisible(false);
	DermaSettings.Imm = CheckBoxThing1;
	local immunity = 0
	
	local CheckBoxThing2 = vgui.Create( "DCheckBoxLabel", DermaSettings )
    CheckBoxThing2:SetPos( 15,150 )
    CheckBoxThing2:SetText( SGLanguage.GetMessage("stool_stargate_cloaking_nc") )
    CheckBoxThing2:SetValue( 0 )
    CheckBoxThing2:SizeToContents()
	CheckBoxThing2:SetToolTip(SGLanguage.GetMessage("stool_stargate_cloaking_nc_desc"))
	CheckBoxThing2:SetVisible(false);
	DermaSettings.Phase = CheckBoxThing2;
	local phaseshifting = 0
	
	local NumSliderThingy2 = vgui.Create( "DNumSlider" , DermaSettings )
    NumSliderThingy2:SetPos( 15,150 )
    NumSliderThingy2:SetSize( 235, 20 )
    NumSliderThingy2:SetText( SGLanguage.GetMessage("mcd_strengh") )
    NumSliderThingy2:SetMin( -5 )
    NumSliderThingy2:SetMax( 5 )
	NumSliderThingy2:SetValue( 0 );
    NumSliderThingy2:SetDecimals( 2 )
	NumSliderThingy2:SetToolTip(SGLanguage.GetMessage("stool_stargate_shield_str_desc") )
	NumSliderThingy2:SetVisible(false);
	DermaSettings.Strengh = NumSliderThingy2;

	local CheckBoxThing3 = vgui.Create( "DCheckBoxLabel", DermaSettings )
    CheckBoxThing3:SetPos( 15,175 )
    CheckBoxThing3:SetText( SGLanguage.GetMessage("stool_stargate_shield_db") )
    CheckBoxThing3:SetValue( 1 )
    CheckBoxThing3:SizeToContents()
	CheckBoxThing3:SetToolTip(SGLanguage.GetMessage("stool_stargate_shield_db_desc"))
	CheckBoxThing3:SetVisible(false);
	DermaSettings.Buble = CheckBoxThing3;
	local drawbubble = 0

	local CheckBoxThing4 = vgui.Create( "DCheckBoxLabel", DermaSettings )
    CheckBoxThing4:SetPos( 15,195 )
    CheckBoxThing4:SetText( SGLanguage.GetMessage("stool_stargate_shield_se") )
    CheckBoxThing4:SetValue( 1 )
    CheckBoxThing4:SizeToContents()
	CheckBoxThing4:SetToolTip(SGLanguage.GetMessage("stool_stargate_shield_se_desc"))
	CheckBoxThing4:SetVisible(false);
	DermaSettings.Effect = CheckBoxThing4;
	local passing = 0

	local CheckBoxThing5 = vgui.Create( "DCheckBoxLabel", DermaSettings )
    CheckBoxThing5:SetPos( 15,215 )
    CheckBoxThing5:SetText( SGLanguage.GetMessage("stool_stargate_shield_co") )
    CheckBoxThing5:SetValue( 0 )
    CheckBoxThing5:SizeToContents()
	CheckBoxThing5:SetToolTip(SGLanguage.GetMessage("stool_stargate_shield_co_desc"))
	CheckBoxThing5:SetVisible(false);
	DermaSettings.Cont = CheckBoxThing5;
	local containment = 0
	
	local CheckBoxThing6 = vgui.Create( "DCheckBoxLabel", DermaSettings )
    CheckBoxThing6:SetPos( 15,235 )
    CheckBoxThing6:SetText( SGLanguage.GetMessage("stool_stargate_shield_an") )
    CheckBoxThing6:SetValue( 1 )
    CheckBoxThing6:SizeToContents()
	CheckBoxThing6:SetToolTip(SGLanguage.GetMessage("stool_stargate_shield_an_desc"))
	CheckBoxThing6:SetVisible(false);
	DermaSettings.AntiNC = CheckBoxThing6;
	local antiNC = 0
	
	local color = vgui.Create( "DColorMixer", DermaSettings );
    color:SetSize( 225, 140);
    color:SetPos( 15, 260 );
    color:SetColor(Color(0,0,255,255))
    color:SetToolTip(SGLanguage.GetMessage("mcd_color"))
	--color:SetPalette(false);
	color:SetAlphaBar(false);
	--color:CenterHorizontal();
	color:SetVisible(false);
	DermaSettings.Color = color;
	
	local ComboBox = vgui.Create( "DListView", DermaPanel )
	ComboBox:SetPos( 15, 30 )
	ComboBox:SetSize( 200, 230 )
	ComboBox:SetMultiSelect( false )
	ComboBox.Paint = function()
        surface.SetDrawColor( 155, 155, 155, 125 )
		surface.SetFont( "default" )
		surface.SetTextColor( 255, 255, 255, 255 )
        surface.DrawRect( 0, 0, ComboBox:GetWide(), ComboBox:GetTall() )
    end
	
    ComboBox:AddColumn(SGLanguage.GetMessage("mcd_device"))
    ComboBox.Columns[1].DoClick = function() end
	ComboBox.Setup = function(self,classes)
		if (classes["cloaking_generator"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("stool_cloak"), "cloaking_generator"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","cloaking_generator"));
		end
		if (classes["shield_generator"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("stool_shield"), "shield_generator"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","shield_generator"));
		end
		if (classes["jamming_device"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("stool_jamming"), "jamming_device"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","jamming_device"));
		end
		if (classes["telchak"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("entity_telchak"), "telchak"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","telchak"));
		end
		if (classes["zpm_mk3"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("stool_zpm_mk3"), "zpm_mk3"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","zpm_mk3"));
		end
		if (classes["tollan_disabler"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("stool_tolland"), "tollan_disabler"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","tollan_disabler"));
		end
		--ComboBox:AddLine("Anti Preori Device", "anti_prior")
		if (classes["naquadah_generator"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("naq_gen_mk1"), "naquadah_generator"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","naquadah_generator"));
		end
		if (classes["arthur_mantle"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("entity_arthurs_mantle"), "arthur_mantle"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","arthur_mantle"));
		end
		ComboBox:AddLine(SGLanguage.GetMessage("mcd_replicator"), "replicator"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","replicator"));
		if (classes["fnp90"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("weapon_p90"), "fnp90"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","fnp90"));
		end
		if (classes["weapon_asura"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("weapon_asuran"), "weapon_asura"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","weapon_asura"));
		end
		if (classes["weapon_zat"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("weapon_zat"), "weapon_zat"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","weapon_zat"));
		end
		if (classes["sg_medkit"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("weapon_misc_atl_medkit"), "sg_medkit"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","sg_medkit"));
		end
		if (classes["naquadah_bottle"]) then
			ComboBox:AddLine(SGLanguage.GetMessage("stool_naq_bottle"), "naquadah_bottle"):SetToolTip(SGLanguage.GetMessage("mcd_device_desc").."\n"..SGLanguage.GetMessage("mcd_classname","naquadah_bottle"));
		end
		ComboBox:SortByColumn(1,false)
	end
	ComboBox:SetToolTip(SGLanguage.GetMessage("mcd_device_desc"))
	ComboBox.OnRowSelected = function(self, index, row)
		DermaSettings:UpdateSettings(row:GetValue(2))
	end
	self.ComboBox = ComboBox;
	
	local DPanel = vgui.Create( "DPanel", DermaPanel )
    DPanel:SetPos( 15, 270 )
	DPanel:SetSize(200,100)	
	DPanel.Paint = function(self)
		local alpha = 100;
		local col = Color( 170, 170, 170, alpha);
		local col2 = Color( 100, 100, 100, alpha);
		local bor = 6;
		local diff = 2;

		draw.RoundedBox( bor, 0, 0, self:GetWide(), self:GetTall(), col);
		draw.RoundedBox( bor, diff, diff, self:GetWide()-2*diff, self:GetTall()-2*diff, col2);
	end
	--DPanel:CenterHorizontal()
	
	local Label = vgui.Create( "DLabel" , DPanel);
	Label:SetFont("OldDefaultSmall");
	Label:SetPos(0, 5);
	Label:SetText(SGLanguage.GetMessage("mcd_effcolor"));
	Label:SizeToContents();
	--Label:Center();
	Label:CenterHorizontal();
	
	local ecolor = vgui.Create( "DColorMixer", DPanel );
    ecolor:SetSize( 190, 68);
    ecolor:SetPos( 0, 25 );
    ecolor:SetColor(Color(170,189,255,255))
    ecolor:SetToolTip(SGLanguage.GetMessage("mcd_effcolor_desc"))
	ecolor:SetPalette(false);
	ecolor:SetAlphaBar(false);
	ecolor:CenterHorizontal();
	ecolor:SetColor(Color(247,51,12,0));
	self.EffColor = ecolor;

	local MenuButtonClose = vgui.Create("DButton")
    MenuButtonClose:SetParent( DermaPanel )
    MenuButtonClose:SetText(SGLanguage.GetMessage("mcd_close"))
    MenuButtonClose:SetPos(15, 415)
    MenuButtonClose:SetSize( 200, 25 )
	MenuButtonClose.DoClick = function ( btn )
		DermaPanel:Remove()
    end
	
	local MenuButtonCreate = vgui.Create("DButton")
    MenuButtonCreate:SetParent( DermaPanel )
    MenuButtonCreate:SetText(SGLanguage.GetMessage("mcd_create"))
    MenuButtonCreate:SetPos(15, 380)
    MenuButtonCreate:SetSize( 200, 25 )
	MenuButtonCreate.DoClick = function ( btn )
	    if(ComboBox:GetSelected()[1] and ComboBox:GetSelected())then
	        local class = ComboBox:GetSelected()[1]:GetValue(2);
			if(CheckBoxThing1:GetChecked())then immunity = 1 end
			if(CheckBoxThing2:GetChecked())then phaseshifting = 1 end
			if(CheckBoxThing3:GetChecked())then drawbubble = 1 end
			if(CheckBoxThing4:GetChecked())then passing = 1 end
			if(CheckBoxThing5:GetChecked())then containment = 1 end
			if(CheckBoxThing6:GetChecked())then antiNC = 1 end
			local col = color:GetColor()
			local ecol = ecolor:GetColor()
			local this_ent = string.Explode(" ",tostring(e))
			net.Start("MCD")
			net.WriteEntity(self.Entity)
			net.WriteString(class)
			net.WriteVector(Vector(ecol.r,ecol.g,ecol.b))
			if(class == "tollan_disabler" or class == "cloaking_generator" or class == "shield_generator" or class == "jamming_device")then
				net.WriteInt(NumSliderThingy1:GetValue(),16)
				net.WriteBit(util.tobool(immunity))
				net.WriteBit(util.tobool(phaseshifting))
				net.WriteInt(NumSliderThingy2:GetValue(),16)
				net.WriteBit(util.tobool(drawbubble))
				net.WriteBit(util.tobool(passing))
				net.WriteBit(util.tobool(containment))
				net.WriteBit(util.tobool(antiNC))
				net.WriteInt(NumPad.NumPad1:GetValue(),16)
				net.WriteInt(col.r,8)
				net.WriteInt(col.g,8)
				net.WriteInt(col.b,8)
			end
			net.SendToServer();

			DermaPanel:Remove()
	    end
    end
end

function VGUI:SetEntity(e,classes)
	self.Entity = e;
	if (not IsValid(e)) then return end
	local col = e:GetNWVector("EffColor");
	self.EffColor:SetColor(Color(col.x,col.y,col.z));
	self.ComboBox:Setup(classes);
end

vgui.Register( "MCDEntry", VGUI )

net.Receive("MCD",function(len)
	local e = net.ReadEntity();
	if(not IsValid(e)) then return end;
	
	local Window = vgui.Create( "MCDEntry" )
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	Window:SetEntity(e,net.ReadTable())
end)