include("shared.lua");
ENT.Category = Language.GetMessage("entity_weapon_cat");
ENT.PrintName = Language.GetMessage("entity_directional_nuke");

local font = {
	font = "quiver",
	size = ScreenScale(20),
	weight = 400,
	antialias = true,
	additive = false,
}
surface.CreateFont("Digital2", font)

function ENT:Initialize()
	self.Started = false;
end

function ENT:Draw()
	self.Entity:DrawModel();

	local shouldcount = self:GetNetworkedBool("ShouldCount",false);
	if (shouldcount and not self.Started) then
		self.Started = true;
		self.TargetTime = CurTime() + self:GetNWInt("Timer",0);
	end
	if not shouldcount then
		self.Started = false;
	end

	local data = self:GetAttachment(self:LookupAttachment("Screen"))
	if not (data and data.Pos and data.Ang) then return end
	local ang = data.Ang;
	ang:RotateAroundAxis(self.Entity:GetForward(),-90);

	local time = 0;
	if shouldcount then
		time = self.TargetTime - CurTime();
		if (time<0) then time = 0; end
	end

	local str = string.FormattedTime(time, "%02i:%02i")

	cam.Start3D2D(data.Pos,ang,0.08);
		surface.SetDrawColor(255,0,0,255)
		local col = Color(255,0,0);
		draw.SimpleText(str,"Digital2",0,0,col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER);
	cam.End3D2D();
end

local VGUI = {}
function VGUI:Init()

	local DermaPanel = vgui.Create( "DFrame" )
   	DermaPanel:SetPos(ScrW()/2-115, ScrH()/2-60)
   	DermaPanel:SetSize(230, 120)
	DermaPanel:SetTitle( Language.GetMessage("directional_nuke_menu_t") )
   	DermaPanel:SetVisible( true )
   	DermaPanel:SetDraggable( false )
   	DermaPanel:ShowCloseButton( false )
   	DermaPanel:MakePopup()
	DermaPanel.Paint = function()
        surface.SetDrawColor( 80, 80, 80, 185 )
        surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )
    end

	local image = vgui.Create("TGAImage" , DermaPanel);
    image:SetSize(10, 10);
    image:SetPos(10, 10);
    image:LoadTGAImage("materials/gui/cap_logo.tga", "MOD");

	local timlab = vgui.Create('DLabel')
	timlab:SetParent( DermaPanel )
	timlab:SetPos(20, 40)
	timlab:SetText(Language.GetMessage("directional_nuke_menu_d"))
	timlab:SizeToContents()

	local timr = vgui.Create('DNumberWang')
	timr:SetParent( DermaPanel )
	timr:SetPos(145, 38)
	timr:SetDecimals(0)
	timr:SetFloatValue(0)
	timr:SetFraction(0)
	timr:SetValue('1')
	timr:SetMinMax(1, 120)

	local cancel = vgui.Create('DButton')
	cancel:SetParent( DermaPanel )
	cancel:SetSize(70, 25)
	cancel:SetPos(130, 80)
	cancel:SetText(Language.GetMessage("directional_nuke_menu_c"))
	cancel.DoClick = function()
		DermaPanel:Remove();
	end

	local OK = vgui.Create('DButton')
	OK:SetParent( DermaPanel )
	OK:SetSize(70, 25)
	OK:SetPos(30, 80)
	OK:SetText('OK')
	OK.DoClick = function()
		LocalPlayer():ConCommand("DN_Set"..e:EntIndex().." "..timr:GetValue());
		DermaPanel:Remove();
	end

end
vgui.Register( "DirectTimerEntry", VGUI )

function DirectTimer(um)
	local Window = vgui.Create( "DirectTimerEntry" )
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	e = um:ReadEntity();
	if(not IsValid(e)) then return end;
end
usermessage.Hook("DirectTimer", DirectTimer)