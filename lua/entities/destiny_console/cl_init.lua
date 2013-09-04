include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.HoloText = surface.GetTextureID("VGUI/resources_hud/sgu_screen");
local font = {
	font = "coolvetica",
	size = 50,
	weight = 400,
	antialias = true,
	additive = false,
}
surface.CreateFont("DestConsole", font);

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_dest_console");
end

function ENT:Initialize()
	self.Wire = 0;

	self.NameA = "";
	self.NameB = "";
	self.NameC = "";
	self.NameD = "";
	self.NameE = "";
	self.NameF = "";
	self.NameG = "";
	self.NameH = "";

	self.ValueA = 0;
	self.ValueB = 0;
	self.ValueC = 0;
	self.ValueD = 0;
	self.ValueE = 0;
	self.ValueF = 0;
	self.ValueG = 0;
	self.ValueH = 0;
end

function ENT:Think()
	if not IsValid(self.Screen) then self.Screen = self:GetNetworkedEntity("Screen"); end

	self.Wire = self.Entity:GetNWInt("Wire",0);

	if (self.Wire == 1) then
		self.NameA = self.Entity:GetNWString("NameA","");
		self.NameB = self.Entity:GetNWString("NameB","");
		self.NameC = self.Entity:GetNWString("NameC","");
		self.NameD = self.Entity:GetNWString("NameD","");

		self.ValueA = self.Entity:GetNWInt("ValueA",0);
		self.ValueB = self.Entity:GetNWInt("ValueB",0);
		self.ValueC = self.Entity:GetNWInt("ValueC",0);
		self.ValueD = self.Entity:GetNWInt("ValueD",0);
	elseif (self.Wire == 2) then
		self.NameE = self.Entity:GetNWString("NameE","");
		self.NameF = self.Entity:GetNWString("NameF","");
		self.NameG = self.Entity:GetNWString("NameG","");
		self.NameH = self.Entity:GetNWString("NameH","");

		self.ValueE = self.Entity:GetNWInt("ValueE",0);
		self.ValueF = self.Entity:GetNWInt("ValueF",0);
		self.ValueG = self.Entity:GetNWInt("ValueG",0);
		self.ValueH = self.Entity:GetNWInt("ValueH",0);
	end
end

function ENT:Draw()
	self.Entity:DrawModel();

	if IsValid(self.Screen) then
		if (self.Wire > 0 and self.Wire < 3) then
			local nameA = "";
			local nameB = "";
			local nameC = "";
			local nameD = "";

			local valueA = 0;
			local valueB = 0;
			local valueC = 0;
			local valueD = 0;

			if (self.Wire == 1) then
				nameA = self.NameA;
				nameB = self.NameB;
				nameC = self.NameC;
				nameD = self.NameD;

				valueA = self.ValueA;
				valueB = self.ValueB;
				valueC = self.ValueC;
				valueD = self.ValueD;
			else
				nameA = self.NameE;
				nameB = self.NameF;
				nameC = self.NameG;
				nameD = self.NameH;

				valueA = self.ValueE;
				valueB = self.ValueF;
				valueC = self.ValueG;
				valueD = self.ValueH;
			end

			local col = Color(255,255,255);

			local factor = 5;

			local data = self.Screen:GetAttachment(self.Screen:LookupAttachment("ScreenCenter"))
			if not (data and data.Pos and data.Ang) then return end
			local ang = data.Ang;
			ang:RotateAroundAxis(data.Ang:Right(),-90);
			ang:RotateAroundAxis(data.Ang:Up(),90);
			cam.Start3D2D(data.Pos,ang,0.05);
				draw.SimpleText(nameA,"DestConsole",-10*factor,-20*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
				draw.SimpleText(valueA,"DestConsole",25*factor,-20*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
				draw.SimpleText(nameB,"DestConsole",-10*factor,-7*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
				draw.SimpleText(valueB,"DestConsole",25*factor,-7*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);

				draw.SimpleText(nameC,"DestConsole",-10*factor,7*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
				draw.SimpleText(valueC,"DestConsole",25*factor,7*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
				draw.SimpleText(nameD,"DestConsole",-10*factor,20*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
				draw.SimpleText(valueD,"DestConsole",25*factor,20*factor,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
			cam.End3D2D();
		end
	end
end

hook.Add("HUDPaint","Console.Hook.HUDPaint.ShowButtons",
	function()
		local x,y = gui.MousePos();
		if(x == 0 and y == 0) then -- Avoids this popping up, if the dial dialogue is opened
			local p = LocalPlayer();
			if(IsValid(p)) then
				local trace = LocalPlayer():GetEyeTrace();
				if(trace.Hit and IsValid(trace.Entity)) then
					local e = trace.Entity;
					if (e:GetClass()=="destiny_console") then

						i = e:GetAimingButton(LocalPlayer())
						local txt;
						if (i == 1) then txt = "1"
						elseif (i == 2) then txt = "2"
						elseif (i == 3) then txt = "3"
						elseif (i == 4) then txt = "4"
						elseif (i == 5) then txt = "5"
						elseif (i == 6) then txt = "6"
						elseif (i == 7) then txt = "7"
						elseif (i == 8) then txt = "8"
						elseif (i == 9) then txt = "A"
						elseif (i == 10) then txt = "B"
						elseif (i == 11) then txt = "Screen1"
						elseif (i == 12) then txt = "Screen2"
						elseif (i == 13) then txt = "Kino1"
						elseif (i == 14) then txt = "Kino2"
						elseif (i == 15) then txt = "Kino3"
						elseif (i == 16) then txt = "Kino4"
						elseif (i == 17) then
							if e:GetNWBool("Core", false) then
								txt = "Shield Core"
							else
								txt = "DHD"
							end
						end

						if (txt) then
							draw.WordBox(8,ScrW()/2-10,ScrH()/2-60,txt,"Default",Color(50,50,75,100),Color(255,255,255,255));
						end

					end
				end
			end
		end
	end
);

local VGUI = {}
function VGUI:Init()

	local DermaPanel = vgui.Create( "DFrame" );
   	DermaPanel:SetPos(ScrW()/2-235, ScrH()/2-115);
   	DermaPanel:SetSize(470, 230);
	DermaPanel:SetTitle( "Destiny Console Setings" );
   	DermaPanel:SetVisible( true );
   	DermaPanel:SetDraggable( false );
   	DermaPanel:ShowCloseButton( false );
   	DermaPanel:MakePopup();
	DermaPanel.Paint = function()
        surface.SetDrawColor( 80, 80, 80, 185 );
        surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() );
    end

	local image = vgui.Create("TGAImage" , DermaPanel);
    image:SetSize(10, 10);
    image:SetPos(10, 10);
    image:LoadTGAImage("materials/gui/cap_logo.tga", "MOD");

	local label1 = vgui.Create('DLabel', DermaPanel);
	label1:SetParent( DermaPanel );
	label1:SetPos(20, 45);
	label1:SetText('ValueA Description:');
	label1:SizeToContents();

	local label2 = vgui.Create('DLabel', DermaPanel);
	label2:SetParent( DermaPanel );
	label2:SetPos(20, 75);
	label2:SetText('ValueB Description:');
	label2:SizeToContents();

	local label3 = vgui.Create('DLabel', DermaPanel);
	label3:SetParent( DermaPanel );
	label3:SetPos(20, 105);
	label3:SetText('ValueC Description:');
	label3:SizeToContents();

	local label4 = vgui.Create('DLabel', DermaPanel);
	label4:SetParent( DermaPanel );
	label4:SetPos(20, 135);
	label4:SetText('ValueD Description:');
	label4:SizeToContents();

	local label5 = vgui.Create('DLabel', DermaPanel);
	label5:SetParent( DermaPanel );
	label5:SetPos(250, 45);
	label5:SetText('ValueE Description:');
	label5:SizeToContents();

	local label6 = vgui.Create('DLabel', DermaPanel);
	label6:SetParent( DermaPanel );
	label6:SetPos(250, 75);
	label6:SetText('ValueF Description:');
	label6:SizeToContents();

	local label7 = vgui.Create('DLabel', DermaPanel);
	label7:SetParent( DermaPanel );
	label7:SetPos(250, 105);
	label7:SetText('ValueG Description:');
	label7:SizeToContents();

	local label8 = vgui.Create('DLabel', DermaPanel);
	label8:SetParent( DermaPanel );
	label8:SetPos(250, 135);
	label8:SetText('ValueH Description:');
	label8:SizeToContents();



	local textA = vgui.Create('DTextEntry', DermaPanel);
	textA:SetParent( DermaPanel );
	textA:SetSize(80, 20);
	textA:SetPos(140, 40);
	textA:SetText("");
	textA:SetAllowNonAsciiCharacters(true)
	self.textA = textA;

	local textB = vgui.Create('DTextEntry', DermaPanel);
	textB:SetParent( DermaPanel );
	textB:SetSize(80, 20);
	textB:SetPos(140, 70);
	textB:SetText("");
	textB:SetAllowNonAsciiCharacters(true)
	self.textB = textB;

	local textC = vgui.Create('DTextEntry', DermaPanel);
	textC:SetParent( DermaPanel );
	textC:SetSize(80, 20);
	textC:SetPos(140, 100);
	textC:SetText("");
	textC:SetAllowNonAsciiCharacters(true)
	self.textC = textC;

	local textD = vgui.Create('DTextEntry', DermaPanel);
	textD:SetParent( DermaPanel );
	textD:SetSize(80, 20);
	textD:SetPos(140, 130);
	textD:SetText("");
	textD:SetAllowNonAsciiCharacters(true)
	self.textD = textD;

	local textE = vgui.Create('DTextEntry', DermaPanel);
	textE:SetParent( DermaPanel );
	textE:SetSize(80, 20);
	textE:SetPos(370, 40);
	textE:SetText("");
	textE:SetAllowNonAsciiCharacters(true)
	self.textE = textE;

	local textF = vgui.Create('DTextEntry', DermaPanel);
	textF:SetParent( DermaPanel );
	textF:SetSize(80, 20);
	textF:SetPos(370, 70);
	textF:SetText("");
	self.textF = textF;

	local textG = vgui.Create('DTextEntry', DermaPanel);
	textG:SetParent( DermaPanel );
	textG:SetSize(80, 20);
	textG:SetPos(370, 100);
	textG:SetText("");
	textG:SetAllowNonAsciiCharacters(true)
	self.textG = textG;

	local textH = vgui.Create('DTextEntry', DermaPanel);
	textH:SetParent( DermaPanel );
	textH:SetSize(80, 20);
	textH:SetPos(370, 130);
	textH:SetText("");
	textH:SetAllowNonAsciiCharacters(true)
	self.textH = textH;


	local cancel = vgui.Create('DButton', DermaPanel);
	cancel:SetParent( DermaPanel );
	cancel:SetSize(70, 25);
	cancel:SetPos(290, 190);
	cancel:SetText('Cancel');
	cancel.DoClick = function()
		net.Start("destiny_console")
		net.WriteEntity(self.Entity)
		net.WriteBit(false)
		net.SendToServer()
		DermaPanel:Remove();
	end

	local OK = vgui.Create('DButton', DermaPanel);
	OK:SetParent( DermaPanel );
	OK:SetSize(70, 25);
	OK:SetPos(380, 190);
	OK:SetText('OK');
	OK.DoClick = function()
		net.Start("destiny_console")
		net.WriteEntity(self.Entity)
		net.WriteBit(true)
		net.WriteString(textA:GetValue())
		net.WriteString(textB:GetValue())
		net.WriteString(textC:GetValue())
		net.WriteString(textD:GetValue())
		net.WriteString(textE:GetValue())
		net.WriteString(textF:GetValue())
		net.WriteString(textG:GetValue())
		net.WriteString(textH:GetValue())
		net.SendToServer()
		DermaPanel:Remove();
	end

end

function VGUI:SetEntity(ent)
    self.Entity = ent;
end

function VGUI:SetValText(val,text)
	self["text"..val]:SetText(text)
end
vgui.Register( "DestConsoleEntry", VGUI )

function DestConsole(um)
	local e = um:ReadEntity();
	if(not IsValid(e)) then return end;
	local Window = vgui.Create( "DestConsoleEntry" )
	Window:SetEntity(e);
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	local vars = {"A","B","C","D","E","F","G","H"}
	for _,v in pairs(vars) do
		Window:SetValText(v,um:ReadString());
	end
	-- VGUI.TextB = um:ReadString();
	-- VGUI.TextC = um:ReadString();
	-- VGUI.TextD = um:ReadString();
end
usermessage.Hook("DestConsole", DestConsole)