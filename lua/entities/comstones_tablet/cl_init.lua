include("shared.lua");
ENT.Category = Language.GetMessage("entity_main_cat");
ENT.PrintName = Language.GetMessage("entity_stone_tablet");

ENT.Device_hud = surface.GetTextureID("VGUI/resources_hud/MCD");

function ENT:Draw()
    self.Entity:DrawModel();
	hook.Remove("HUDPaint",tostring(self.Entity).."StonDev");
    if(LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 1024)then
		hook.Add("HUDPaint",tostring(self.Entity).."StonDev",function()
		    surface.SetTexture(self.Device_hud);
	        surface.SetDrawColor(Color( 255, 255, 255, 155 ));
	        surface.DrawTexturedRect(ScrW()/2-3, ScrH()/2-112, 100, 100);

			local chann = 1;
			if IsValid(self.Entity) then chann = self.Entity:GetNetworkedInt("Chann", 1); end
			local act = 0;
			if IsValid(self.Entity) then act = self.Entity:GetNWInt("Active", 0); end

            draw.DrawText("Com. Device", "header", ScrW()/2+27, ScrH()/2-103, Color(0,255,255,255), 0)
            draw.DrawText("Channel: "..chann, "center2", ScrW()/2+10, ScrH()/2-77, Color(209,238,238,255),0);
			draw.DrawText("Active: "..act, "center2", ScrW()/2+10, ScrH()/2-57, Color(209,238,238,255),0);

		end);
	end
end

function ENT:OnRemove()
    hook.Remove("HUDPaint",tostring(self.Entity).."StonDev");
end

local VGUI = {}
function VGUI:Init()

	local DermaPanel = vgui.Create( "DFrame" )
   	DermaPanel:SetPos(ScrW()/2-115, ScrH()/2-60)
   	DermaPanel:SetSize(230, 120)
	DermaPanel:SetTitle( "Communication Device" )
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
	timlab:SetText('Operating channel:')
	timlab:SizeToContents()

	local chn = vgui.Create('DNumberWang')
	chn:SetParent( DermaPanel )
	chn:SetPos(145, 38)
	chn:SetDecimals(0)
	chn:SetFloatValue(0)
	chn:SetFraction(0)
	chn:SetValue('1')
	chn:SetMinMax(1, 10)

	local cancel = vgui.Create('DButton')
	cancel:SetParent( DermaPanel )
	cancel:SetSize(70, 25)
	cancel:SetPos(130, 80)
	cancel:SetText('Cancel')
	cancel.DoClick = function()
		DermaPanel:Remove();
	end

	local OK = vgui.Create('DButton')
	OK:SetParent( DermaPanel )
	OK:SetSize(70, 25)
	OK:SetPos(30, 80)
	OK:SetText('OK')
	OK.DoClick = function()
		LocalPlayer():ConCommand("Chan"..e:EntIndex().." "..chn:GetValue());
		DermaPanel:Remove();
	end

end
vgui.Register( "ComDeviceSetEntry", VGUI )

function ComDeviceSet(um)
	local Window = vgui.Create( "ComDeviceSetEntry" )
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	e = um:ReadEntity();
	if(not IsValid(e)) then return end;
end
usermessage.Hook("ComDeviceSet", ComDeviceSet)