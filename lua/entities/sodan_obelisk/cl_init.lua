include("shared.lua")
ENT.Category = Language.GetMessage("entity_main_cat");
ENT.PrintName = Language.GetMessage("entity_sodan_obelisk");

ENT.ButtonPos = {
	[1] = Vector(22.53, -3.98, 94.35),
	[2] = Vector(22.53, 4.63, 94.35),
	[3] = Vector(22.53, -3.98, 81.5),
	[4] = Vector(22.53, 4.63, 81.5),
	[5] = Vector(22.53, -3.98, 69.45),
	[6] = Vector(22.53, 4.63, 69.45),
	[7] = Vector(22.53, 4.63, 43.4),
}

function ENT:Draw()
	self.Entity:DrawModel();

	local address = self.Entity:GetNetworkedString("ADDRESS"):TrimExplode(",");
	local eye = self.Entity:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos)
	local len = (eye - Vector(22.53, -3.98, 69.45)):Length()

	if (len <= 50 or table.GetFirstValue(address) != "") then

		local restalpha = 0;
		if (len <= 50) then restalpha = 100; end

		local ang = self.Entity:GetAngles();
		ang:RotateAroundAxis(ang:Up(), -90);
		ang:RotateAroundAxis(ang:Up(), 180);
		ang:RotateAroundAxis(ang:Forward(), 90);

		local button = 0;
		button = self:GetAimingButton(LocalPlayer())

		for i=1, 7  do

			local pos = self.Entity:LocalToWorld(self.ButtonPos[i]);

			local alpha = restalpha;
			if(table.HasValue(address,tostring(i)) or button == i) then
				alpha = 200;
			end
			local a = Color(255,255,255,alpha)

			local txt = i;
			if (i == 7) then txt = "PASS" end

			cam.Start3D2D(pos,ang,0.1);
				draw.SimpleText(txt,"DHD_font",0,0,a,1,1);
			cam.End3D2D();

		end

	end

end

local PANEL = {}

function PANEL:DoClick()
	local panel2=self:GetParent()
	LocalPlayer():ConCommand("setobeliskpass "..panel2.TextEntry:GetValue())
	panel2:Remove()
end
vgui.Register( "ObeliskPassButton", PANEL, "Button" )

local PANEL = {}
function PANEL:Init()
	self:SetSize(500,80)
	self:SetName( "Password" )
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
		local letters = TextEntry:GetValue():gsub("[^1-6]",""):TrimExplode("");
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
 	self.L1:SetText(Language.GetMessage("sodan_obelisk_menu"))
 	self.L1:SetFont("OldDefaultSmall")

 	self.Button = vgui.Create( "ObeliskPassButton", self)
	self.Button:SetText("OK")

	self.Button:SetPos(425,39)
 	self.TextEntry:SetSize( 405, self.TextEntry:GetTall() )
 	self.TextEntry:SetPos( 10, 40 )
 	self.L1:SetPos( 30, 3 )
 	self.L1:SetSize( 500, 30 )
end

function PANEL:Paint(w,h)
	draw.RoundedBox( 10, 0, 0, w, h, Color(16,16,16,160) )
	return true
end

vgui.Register( "ObeliskPassEntry", PANEL, "DFrame" )

function ObeliskShowPassWindow(um)
	local Window = vgui.Create( "ObeliskPassEntry" )
	Window:SetKeyBoardInputEnabled( true )
	Window:SetMouseInputEnabled( true )
	Window:SetPos( (ScrW()/2 - 350) / 2, ScrH()/2 - 75 )
	Window:SetVisible( true )
	local e = um:ReadEntity();
	if(not IsValid(e)) then return end;
	Window.TextEntry:SetText(e:GetNWString("pass"));
end
usermessage.Hook("ObeliskShowPassWindow", ObeliskShowPassWindow)