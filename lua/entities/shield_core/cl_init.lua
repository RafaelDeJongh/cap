--[[
	Shield Core
	Copyright (C) 2011 Madman07
]]--

include('shared.lua');
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_shield_core");
end

ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.SC_hud = surface.GetTextureID("VGUI/resources_hud/MCD");
local matBlurScreen = Material( "pp/blurscreen" )

function ENT:Draw()
	if self:GetNetworkedBool("ShouldClip", false) then self:UpdateClipping();
	else self:SetRenderClipPlaneEnabled(false); end
	self:DrawModel();

	hook.Remove("HUDPaint",tostring(self.Entity).."SC");
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."SC",function()
		    surface.SetTexture(self.SC_hud);
	        surface.SetDrawColor(Color( 255, 255, 255, 155 ));
	        surface.DrawTexturedRect(ScrW()/2-24, ScrH()/2-112, 126, 90);

            draw.DrawText("Shield Core", "header", ScrW()/2+16, ScrH()/2-103, Color(0,255,255,255), 0)

			local enabled = 0;
		 	if IsValid(self) then enabled = self:GetNWInt("HUD_Enable", 0); end
			local text = "Off";
			if (enabled == 1) then text = "On";
			elseif (enabled ==2) then text = "Depleted"; end
			draw.DrawText("Shield: ("..text..")", "center", ScrW()/2+9, ScrH()/2-77, Color(209,238,238,255),0);

			local percent = 0;
			if IsValid(self) then percent = self:GetNWInt("HUD_Percent", 0); end
            percent = string.format("%G",percent);
            draw.SimpleText(percent.."%", "center", ScrW()/2+9, ScrH()/2-62, color,0)
		end);
	end
end

function ENT:UpdateClipping()
	local normal = self:GetUp();
    local distance = normal:Dot(self:GetPos()-normal);

 	self:SetRenderClipPlaneEnabled(true);
    self:SetRenderClipPlane(normal, distance);
end

function ENT:OnRemove()
    hook.Remove("HUDPaint",tostring(self.Entity).."SC");
end

local VGUI = {}
function VGUI:Init()

	-- SHIELD CORE MENU

	local DermaPanel = vgui.Create( "DFrame" )
   	DermaPanel:SetPos(ScrW()/10, ScrH()/10)
   	DermaPanel:SetSize( 370, 350 )
	DermaPanel:SetTitle( "Shield Core Control Panel" )
   	DermaPanel:SetVisible( true )
   	DermaPanel:SetDraggable( false )
   	DermaPanel:ShowCloseButton( false )
   	DermaPanel:MakePopup()
	DermaPanel.Paint = function()

		// Thanks Overv, http://www.facepunch.com/threads/1041686-What-are-you-working-on-V4-John-Lua-Edition

		local x, y = self:ScreenToLocal(0, 0)
		// Background
		surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )

		matBlurScreen:SetFloat( "$blur", 5 )
		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect( -ScrH()/10, -ScrH()/10, ScrW(), ScrH() )

		surface.SetDrawColor( 100, 100, 100, 150 )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )

		// Border
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawOutlinedRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )

    end

	local image = vgui.Create("TGAImage" , DermaPanel);
    image:SetSize(10, 10);
    image:SetPos(10, 10);
    image:LoadTGAImage("materials/gui/cap_logo.tga", "MOD");

	local Button_color = vgui.Create("DPanel", DermaPanel);
	Button_color:SetPos(150, 260);
	Button_color:SetSize(195, 75);
	Button_color.Paint = function() draw.RoundedBox( 6, 0, 0, 195, 75, Color( 170, 170, 170, 255)); end

	/////// TABS

	local Sheet = vgui.Create("DPropertySheet", DermaPanel);
	Sheet:SetPos(25, 40);
	Sheet:SetSize(320, 250);

	local sheet_col = Color( 100, 100, 100, 255);
	local sheet_x = 310;
	local sheet_y = 220;

	local Sheet_Size = vgui.Create("DPanel", Sheet);
	Sheet_Size:SetPos(0, 0);
	Sheet_Size:SetSize(Sheet:GetWide(), Sheet:GetTall());
	Sheet_Size.Paint = function() draw.RoundedBox( 6, 0, 0, sheet_x, sheet_y, sheet_col); end

	local Sheet_Ang = vgui.Create("DPanel", Sheet);
	Sheet_Ang:SetPos(0, 0);
	Sheet_Ang:SetSize(Sheet:GetWide(), Sheet:GetTall());
	Sheet_Ang.Paint = function() draw.RoundedBox( 6, 0, 0, sheet_x, sheet_y, sheet_col); end

	local Sheet_Pos = vgui.Create("DPanel", Sheet);
	Sheet_Pos:SetPos(0, 0);
	Sheet_Pos:SetSize(Sheet:GetWide(), Sheet:GetTall());
	Sheet_Pos.Paint = function() draw.RoundedBox( 6, 0, 0, sheet_x, sheet_y, sheet_col); end

	local Sheet_Visual = vgui.Create("DPanel", Sheet);
	Sheet_Visual:SetPos(0, 0);
	Sheet_Visual:SetSize(Sheet:GetWide(), Sheet:GetTall());
	Sheet_Visual.Paint = function() draw.RoundedBox( 6, 0, 0, sheet_x, sheet_y, sheet_col); end

	local Sheet_Other = vgui.Create("DPanel", Sheet);
	Sheet_Other:SetPos(0, 0);
	Sheet_Other:SetSize(Sheet:GetWide(), Sheet:GetTall());
	Sheet_Other.Paint = function() draw.RoundedBox( 6, 0, 0, sheet_x, sheet_y, sheet_col); end

	Sheet:AddSheet("Size", Sheet_Size, "icon16/user.png", false, false, "Size of the buble.");
	Sheet:AddSheet("Angle", Sheet_Ang, "icon16/user.png", false, false, "Angles of the buble.");
	Sheet:AddSheet("Position", Sheet_Pos, "icon16/user.png", false, false, "Position of the buble.");
	Sheet:AddSheet("Visual", Sheet_Visual, "icon16/user.png", false, false, "Model and color of the buble.");
	Sheet:AddSheet("Other", Sheet_Other, "icon16/user.png", false, false, "Other settings.");

	//////// Const

	local Slider_pos_x  = 25;
	local Slider_pos_y1 = 20;
	local Slider_pos_y2 = 60;
	local Slider_pos_y3 = 100;
	local Slider_size_x = 250;
	local Slider_size_y = 50;

	local Button_size_x = 75;
	local Button_size_y = 25;

	//////// SIZE

	local Size_x = vgui.Create( "DNumSlider" , Sheet_Size );
    Size_x:SetPos(Slider_pos_x, Slider_pos_y1);
    Size_x:SetSize(Slider_size_x, Slider_size_y);
    Size_x:SetText( "Size x:" );
    Size_x:SetMin( 100 );
    Size_x:SetMax( 4096 );
	Size_x:SetValue( e:GetNWVector("Size", Vector(100,100,100)).x );
    Size_x:SetDecimals( 0 );
	Size_x.OnValueChanged = function(Size_x, fValue)
		LocalPlayer():ConCommand("SC_Size"..e:EntIndex().." "..VGUI.Size_x:GetValue().." "..VGUI.Size_y:GetValue().." "..VGUI.Size_z:GetValue());
	end

	local Size_y = vgui.Create( "DNumSlider" , Sheet_Size );
    Size_y:SetPos(Slider_pos_x, Slider_pos_y2);
    Size_y:SetSize(Slider_size_x, Slider_size_y);
    Size_y:SetText( "Size y:" );
    Size_y:SetMin( 100 );
    Size_y:SetMax( 4096 );
	Size_y:SetValue( e:GetNWVector("Size", Vector(100,100,100)).y );
    Size_y:SetDecimals( 0 );
	Size_y.OnValueChanged = function(Size_y, fValue)
		LocalPlayer():ConCommand("SC_Size"..e:EntIndex().." "..VGUI.Size_x:GetValue().." "..VGUI.Size_y:GetValue().." "..VGUI.Size_z:GetValue());
	end

	local Size_z = vgui.Create( "DNumSlider" , Sheet_Size );
    Size_z:SetPos(Slider_pos_x, Slider_pos_y3);
    Size_z:SetSize(Slider_size_x, Slider_size_y);
    Size_z:SetText( "Size z:" );
    Size_z:SetMin( 100 );
    Size_z:SetMax( 4096 );
	Size_z:SetValue( e:GetNWVector("Size", Vector(100,100,100)).z );
    Size_z:SetDecimals( 0 );
	Size_z.OnValueChanged = function(Size_z, fValue)
		LocalPlayer():ConCommand("SC_Size"..e:EntIndex().." "..VGUI.Size_x:GetValue().." "..VGUI.Size_y:GetValue().." "..VGUI.Size_z:GetValue());
	end

	local Reset_Size = vgui.Create("DButton");
    Reset_Size:SetParent(Sheet_Size);
    Reset_Size:SetText("Reset");
    Reset_Size:SetPos(200, 160);
    Reset_Size:SetSize(Button_size_x, Button_size_y);
	Reset_Size.DoClick = function (btn0)
			VGUI.Size_x:SetValue(100);
			VGUI.Size_y:SetValue(100);
			VGUI.Size_z:SetValue(100);
			LocalPlayer():ConCommand("SC_Size"..e:EntIndex().." "..VGUI.Size_x:GetValue().." "..VGUI.Size_y:GetValue().." "..VGUI.Size_z:GetValue());
    end

	//////// ANGLE

	local Angle_x = vgui.Create( "DNumSlider" , Sheet_Ang )
    Angle_x:SetPos(Slider_pos_x, Slider_pos_y1)
    Angle_x:SetSize(Slider_size_x, Slider_size_y)
    Angle_x:SetText( "Pitch:" )
    Angle_x:SetMin( -180 )
    Angle_x:SetMax( 180 )
	Angle_x:SetValue( e:GetNWVector("Ang", Vector(100,100,100)).x );
    Angle_x:SetDecimals( 0 )
	Angle_x.OnValueChanged = function(Angle_x, fValue)
		LocalPlayer():ConCommand("SC_Angle"..e:EntIndex().." "..VGUI.Angle_x:GetValue().." "..VGUI.Angle_y:GetValue().." "..VGUI.Angle_z:GetValue());
	end

	local Angle_y = vgui.Create( "DNumSlider" , Sheet_Ang )
    Angle_y:SetPos(Slider_pos_x, Slider_pos_y2)
    Angle_y:SetSize(Slider_size_x, Slider_size_y)
    Angle_y:SetText( "Yaw:" )
    Angle_y:SetMin( -180 )
    Angle_y:SetMax( 180 )
	Angle_y:SetValue( e:GetNWVector("Ang", Vector(100,100,100)).y );
    Angle_y:SetDecimals( 0 )
	Angle_y.OnValueChanged = function(Angle_y, fValue)
		LocalPlayer():ConCommand("SC_Angle"..e:EntIndex().." "..VGUI.Angle_x:GetValue().." "..VGUI.Angle_y:GetValue().." "..VGUI.Angle_z:GetValue());
	end

	local Angle_z = vgui.Create( "DNumSlider" , Sheet_Ang )
    Angle_z:SetPos(Slider_pos_x, Slider_pos_y3)
    Angle_z:SetSize(Slider_size_x, Slider_size_y)
    Angle_z:SetText( "Roll:" )
    Angle_z:SetMin( -180 )
    Angle_z:SetMax( 180 )
	Angle_z:SetValue( e:GetNWVector("Ang", Vector(100,100,100)).z );
    Angle_z:SetDecimals( 0 )
	Angle_z.OnValueChanged = function(Angle_z, fValue)
		LocalPlayer():ConCommand("SC_Angle"..e:EntIndex().." "..VGUI.Angle_x:GetValue().." "..VGUI.Angle_y:GetValue().." "..VGUI.Angle_z:GetValue());
	end

	local Reset_Ang = vgui.Create("DButton")
    Reset_Ang:SetParent(Sheet_Ang)
    Reset_Ang:SetText("Reset")
    Reset_Ang:SetPos(200, 160)
    Reset_Ang:SetSize(Button_size_x, Button_size_y)
	Reset_Ang.DoClick = function (btn1)
			VGUI.Angle_x:SetValue(0);
			VGUI.Angle_y:SetValue(0);
			VGUI.Angle_z:SetValue(0);
			LocalPlayer():ConCommand("SC_Angle"..e:EntIndex().." "..VGUI.Angle_x:GetValue().." "..VGUI.Angle_y:GetValue().." "..VGUI.Angle_z:GetValue());
    end

	//////// POSITION

	local Pos_x = vgui.Create( "DNumSlider" , Sheet_Pos )
    Pos_x:SetPos(Slider_pos_x, Slider_pos_y1)
    Pos_x:SetSize(Slider_size_x, Slider_size_y)
    Pos_x:SetText( "Position x:" )
    Pos_x:SetMin( -512 )
    Pos_x:SetMax( 512 )
	Pos_x:SetValue( e:GetNWVector("Pos", Vector(100,100,100)).x );
    Pos_x:SetDecimals( 0 )
	Pos_x.OnValueChanged = function(Pos_x, fValue)
		LocalPlayer():ConCommand("SC_Pos"..e:EntIndex().." "..VGUI.Pos_x:GetValue().." "..VGUI.Pos_y:GetValue().." "..VGUI.Pos_z:GetValue());
	end

	local Pos_y = vgui.Create( "DNumSlider" , Sheet_Pos )
    Pos_y:SetPos(Slider_pos_x, Slider_pos_y2)
    Pos_y:SetSize(Slider_size_x, Slider_size_y)
    Pos_y:SetText( "Position y:" )
    Pos_y:SetMin( -512 )
    Pos_y:SetMax( 512 )
	Pos_y:SetValue( e:GetNWVector("Pos", Vector(100,100,100)).y );
    Pos_y:SetDecimals( 0 )
	Pos_y.OnValueChanged = function(Pos_y, fValue)
		LocalPlayer():ConCommand("SC_Pos"..e:EntIndex().." "..VGUI.Pos_x:GetValue().." "..VGUI.Pos_y:GetValue().." "..VGUI.Pos_z:GetValue());
	end

	local Pos_z = vgui.Create( "DNumSlider" , Sheet_Pos )
    Pos_z:SetPos(Slider_pos_x, Slider_pos_y3)
    Pos_z:SetSize(Slider_size_x, Slider_size_y)
    Pos_z:SetText( "Position z:" )
    Pos_z:SetMin( -512 )
    Pos_z:SetMax( 512 )
	Pos_z:SetValue( e:GetNWVector("Pos", Vector(100,100,100)).z );
    Pos_z:SetDecimals( 0 )
	Pos_z.OnValueChanged = function(Pos_z, fValue)
		LocalPlayer():ConCommand("SC_Pos"..e:EntIndex().." "..VGUI.Pos_x:GetValue().." "..VGUI.Pos_y:GetValue().." "..VGUI.Pos_z:GetValue());
	end

	local Reset_Pos = vgui.Create("DButton")
    Reset_Pos:SetParent(Sheet_Pos)
    Reset_Pos:SetText("Reset")
    Reset_Pos:SetPos(200, 160)
    Reset_Pos:SetSize(Button_size_x, Button_size_y)
	Reset_Pos.DoClick = function (btn2)
			VGUI.Pos_x:SetValue(0);
			VGUI.Pos_y:SetValue(0);
			VGUI.Pos_z:SetValue(0);
			LocalPlayer():ConCommand("SC_Pos"..e:EntIndex().." "..VGUI.Pos_x:GetValue().." "..VGUI.Pos_y:GetValue().." "..VGUI.Pos_z:GetValue());
    end

	//////// COLOR

	local Col = vgui.Create( "DColorMixer" , Sheet_Visual);
	Col:SetSize( 160, 160);
	Col:SetPos( 25, 20 );

	local r_get = e:GetNWVector("Col", Vector(170,189,255)).x;
	local g_get = e:GetNWVector("Col", Vector(170,189,255)).y;
	local b_get = e:GetNWVector("Col", Vector(170,189,255)).z;

	Col:SetColor(Color(r_get,g_get,b_get,255))
	Col.Think = function(aa)
		Col:ConVarThink()

		local r = Col:GetColor().r;
		local g = Col:GetColor().g;
		local b = Col:GetColor().b;

		/*VGUI.col_r:SetText("R: "..tostring(r));
		VGUI.col_r:SizeToContents();

		VGUI.col_g:SetText("G: "..tostring(g));
		VGUI.col_g:SizeToContents();

		VGUI.col_b:SetText("B: "..tostring(b));
		VGUI.col_b:SizeToContents();   */

		LocalPlayer():ConCommand("SC_Visual_Col"..e:EntIndex().." "..r.." "..g.." "..b);
	end
          /*
	local col_r = vgui.Create("DLabel", Sheet_Visual);
	col_r:SetPos( 25, 130);
	col_r:SetText("R: "..tostring(Col:GetColor().r));
	col_r:SizeToContents();

	local col_g = vgui.Create("DLabel", Sheet_Visual);
	col_g:SetPos( 25, 150);
	col_g:SetText("G: "..tostring(Col:GetColor().g));
	col_g:SizeToContents();

	local col_b = vgui.Create("DLabel", Sheet_Visual);
	col_b:SetPos( 25, 170);
	col_b:SetText("B: "..tostring(Col:GetColor().b));
	col_b:SizeToContents();  */

	/////// MODEL

	local Model_box = vgui.Create( "DComboBox", Sheet_Visual)
	Model_box:SetPos( 200, 20 )
	Model_box:SetSize( 80, 30 )
	--Model_box:SetMultiple( false )
	Model_box.Paint = function()
        surface.SetDrawColor( 155, 155, 155, 125 )
		surface.SetFont( "default" )
		surface.SetTextColor( 255, 255, 255, 255 )
        surface.DrawRect( 0, 0, Model_box:GetWide(), Model_box:GetTall() )
    end

	local sph = Model_box:AddChoice( "Sphere" )
	local box = Model_box:AddChoice( "Box" )
	local atla = Model_box:AddChoice( "Atlantis" )
	Model_box:SetToolTip("Select your shield model.")

	local mod_get = e:GetNWString("Mod", "models/Madman07/shields/sphere.mdl");
	if (mod_get == "models/Madman07/shields/sphere.mdl") then Model_box:ChooseOption("Sphere",1)
	elseif (mod_get == "models/Madman07/shields/box.mdl") then Model_box:ChooseOption("Box",2)
	elseif (mod_get == "models/Madman07/shields/atlantis.mdl") then Model_box:ChooseOption("Atlantis",3) end

	Model_box.OnSelect = function(panel,index,value)
		LocalPlayer():ConCommand("SC_Visual_Model"..e:EntIndex().." "..index);
	end

	///// Variables

	VGUI.col_r=col_r
	VGUI.col_g=col_g
	VGUI.col_b=col_b
	VGUI.Size_x=Size_x
	VGUI.Size_y=Size_y
	VGUI.Size_z=Size_z
	VGUI.Angle_x=Angle_x
	VGUI.Angle_y=Angle_y
	VGUI.Angle_z=Angle_z
	VGUI.Pos_x=Pos_x
	VGUI.Pos_y=Pos_y
	VGUI.Pos_z=Pos_z

	/////// OTHER

	local menudata = string.Explode(" ", e:GetNWString("MenuData", "0 0 0 0 5"));

	local Power = vgui.Create( "DNumSlider" , Sheet_Other )
    Power:SetPos( 25,40 )
    Power:SetSize( 250, 50 )
    Power:SetText( "Faster - Stronger:" )
    Power:SetMin( -5 )
    Power:SetMax( 5 )
	Power:SetValue( tonumber(menudata[1]) );
    Power:SetDecimals( 2 )
	Power:SetToolTip("Increasing the Strength will result into slower Regeneration and more Energy Usage.")
	Power.OnValueChanged = function(Power, fValue) end

	local Immunity = vgui.Create( "DCheckBoxLabel", Sheet_Other  )
    Immunity:SetPos( 25,100 )
    Immunity:SetText( "Immunity" )
    Immunity:SetValue( tobool(menudata[2]) )
    Immunity:SizeToContents()
	Immunity:SetToolTip("When this is enabled, the owner of the shield can always go or shoot through\nno matter if he was inside the shield when it was turned on or not.")

	local Draw_B = vgui.Create( "DCheckBoxLabel", Sheet_Other  )
    Draw_B:SetPos( 25,120 )
    Draw_B:SetText( "Always show Bubble" )
    Draw_B:SetValue( tobool(menudata[3]) )
    Draw_B:SizeToContents()
	Draw_B:SetToolTip("Different bubble effect (looks like Atlantis shield).")

	local Atlantis = vgui.Create( "DCheckBoxLabel", Sheet_Other  )
    Atlantis:SetPos( 25,140 )
    Atlantis:SetText( "Atlantis Type" )
    Atlantis:SetValue( tobool(menudata[4]) )
    Atlantis:SizeToContents()
	Atlantis:SetToolTip("When this is enabled, shield is active as long, as it have enought power. Be carefull, it drains power really fast.")

	local NumPad = vgui.Create( "CtrlNumPad", Sheet_Other )
	NumPad:SetPos( 200, 100)
	NumPad.NumPad1:SetValue(menudata[5]);
	--NumPad:SetConVar1( "shield_core_activate" )
	NumPad:SetLabel1( "Activate shield" )
	NumPad:SetSize(100,50);

	////////// BUTTONS

	local MenuButtonClose = vgui.Create("DButton");
    MenuButtonClose:SetParent( DermaPanel );
    MenuButtonClose:SetText( "Close" );
    MenuButtonClose:SetPos(260, 300);
    MenuButtonClose:SetSize(Button_size_x, Button_size_y);
	MenuButtonClose.DoClick = function ( btn )
		LocalPlayer():ConCommand("SC_Close"..e:EntIndex());
		DermaPanel:Remove();
    end

	local MenuButtonCreate = vgui.Create("DButton");
    MenuButtonCreate:SetParent( DermaPanel );
    MenuButtonCreate:SetText( "OK" );
    MenuButtonCreate:SetPos(160, 300);
    MenuButtonCreate:SetSize(Button_size_x, Button_size_y);
	MenuButtonCreate.DoClick = function ( btn )
		local Imm = 0;
		local Draw = 0;
		local Atl = 0;

		if (Immunity:GetChecked()) then Imm = 1; end
		if (Draw_B:GetChecked()) then Draw = 1; end
		if (Atlantis:GetChecked()) then Atl = 1; end

		LocalPlayer():ConCommand("SC_Size"..e:EntIndex().." "..VGUI.Size_x:GetValue().." "..VGUI.Size_y:GetValue().." "..VGUI.Size_z:GetValue());
		LocalPlayer():ConCommand("SC_Angle"..e:EntIndex().." "..VGUI.Angle_x:GetValue().." "..VGUI.Angle_y:GetValue().." "..VGUI.Angle_z:GetValue());
		LocalPlayer():ConCommand("SC_Pos"..e:EntIndex().." "..VGUI.Pos_x:GetValue().." "..VGUI.Pos_y:GetValue().." "..VGUI.Pos_z:GetValue());
		LocalPlayer():ConCommand("SC_Visual_Model"..e:EntIndex().." ".."models/Madman07/shield/sphere.mdl");
		LocalPlayer():ConCommand("SC_Visual_Col"..e:EntIndex().." "..Col:GetColor().r.." "..Col:GetColor().g.." "..Col:GetColor().b);

		LocalPlayer():ConCommand("SC_Apply"..e:EntIndex().." "..Power:GetValue().." "..Imm.." "..Draw.." "..Atl.." "..NumPad.NumPad1:GetValue());
		DermaPanel:Remove();
		DermaPanelInfo:Remove();
    end

end
vgui.Register( "ShieldCoreEntry", VGUI )

function ShieldCorePanel(um)
	e = um:ReadEntity();
	if(not IsValid(e)) then return end;

	local Window = vgui.Create( "ShieldCoreEntry" )
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
end
usermessage.Hook("ShieldCorePanel", ShieldCorePanel)