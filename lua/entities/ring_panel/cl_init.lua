include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.ButtCount = 6;

function ENT:Draw()
	if (not IsValid(self.Entity)) then return end
	self.Entity:DrawModel();

	local address = self.Entity:GetNetworkedString("ADDRESS"):TrimExplode(",");
	local eye = self.Entity:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos)
	local len = (eye - self.Middle):Length()

	if (len <= 20 or table.GetFirstValue(address) != "") then

		local restalpha = 0;
		if (len <= 20) then restalpha = 50; end

		local ang = self.Entity:GetAngles();
		ang:RotateAroundAxis(ang:Up(), -90);
		ang:RotateAroundAxis(ang:Up(), 180);
		ang:RotateAroundAxis(ang:Forward(), 90);

		local button = 0;
		button = self:GetAimingButton(LocalPlayer())

		for i=1, self.ButtCount do

			local pos = self.Entity:LocalToWorld(self.ButtonPos[i]);

			local alpha = restalpha;
			if(table.HasValue(address,tostring(i)) or button == i) then
				alpha = 200;
			end
			local a = Color(255,255,255,alpha)

			local txt = tostring(i);
			if (i == self.ButtCount) then txt = "DIAL" end

			cam.Start3D2D(pos,ang,0.025);
				draw.SimpleText(txt,"DHD_font",0,0,a,1,1);
			cam.End3D2D();

		end

	end

end

local PANEL = {}

function PANEL:DoClick()
	local panel2=self:GetParent()
	LocalPlayer():ConCommand("doringsdial "..panel2.TextEntry:GetValue())
	panel2:Remove();
end

vgui.Register( "RingDialButtonCap", PANEL, "Button" )
local PANEL = {}

function PANEL:Init()
	self:SetSize(400,80)
	self:SetName( "Dial" )
	self:MakePopup();
	self:SetSizable(false)
	self:SetDraggable(false)
	self:SetTitle("")
	self.Logo = vgui.Create("DImage",self);
	self.Logo:SetPos(8,10);
	self.Logo:SetImage("gui/cap_logo");
	self.Logo:SetSize(16,16);
 	self.TextEntry = vgui.Create( "DTextEntry", self )
 	self.TextEntry:SetText("")
   	self.TextEntry.OnTextChanged = function(TextEntry)
 		local pos = TextEntry:GetCaretPos();
 		local len = TextEntry:GetValue():len();
		local letters = TextEntry:GetValue():gsub("[^0-9]",""):TrimExplode("");
		local text = ""; -- Wipe
		for _,v in pairs(letters) do
			if(not text:find(v)) then
				text = text..v;
			end
		end
		TextEntry:SetText(text);
		TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
	end

 	self.L1 = vgui.Create( "DLabel", self )
 	self.L1:SetText(SGLanguage.GetMessage("ring_dial"))
 	self.L1:SetFont("OldDefaultSmall")

 	self.Button = vgui.Create( "RingDialButtonCap", self)
	self.Button:SetText(SGLanguage.GetMessage("ring_dialb"))

	self.Button:SetPos(325,39)
 	self.TextEntry:SetSize( 305, self.TextEntry:GetTall() )
 	self.TextEntry:SetPos( 10, 40 )
 	self.L1:SetPos( 30, 3 )
 	self.L1:SetSize( 400, 30 )
end

function PANEL:Paint(w,h)
	draw.RoundedBox( 10, 0, 0, w, h , Color(16,16,16,160) )
	return true
end

vgui.Register( "RingDestinationEntryCap", PANEL, "DFrame" )
local Window
function RingTransporterShowWindow(um)
	Window = vgui.Create( "RingDestinationEntryCap" )
	Window:SetKeyBoardInputEnabled( true )
	Window:SetMouseInputEnabled( true )
	Window:SetPos( (ScrW()/2 - 250) / 2, ScrH()/2 - 75 )
	Window:SetVisible( true )
end
usermessage.Hook("RingTransporterShowWindowCap", RingTransporterShowWindow)