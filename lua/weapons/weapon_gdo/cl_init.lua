include('shared.lua')
include('cl_viewscreen.lua')

SWEP.Slot               = 4
SWEP.Slotpos            = 1
SWEP.Drawammo           = false
SWEP.Drawcrosshair      = false
SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/gdo_inventory")

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/gdo_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/gdo_inventory");
end

CreateClientConVar("cl_weapon_gdo_iriscode", 0, true, true)

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - 5*a:Up() - 6*a:Forward() + 6*a:Right();
	a:RotateAroundAxis(a:Right(),30);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end

local VGUI = {}
function VGUI:Init()

	local DermaPanel = vgui.Create( "DFrame" )
   	DermaPanel:SetPos(ScrW()/2-200, ScrH()/2-50)
   	DermaPanel:SetSize(400, 100)
	DermaPanel:SetTitle( "GDO Menu" )
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

	local code = vgui.Create( "DTextEntry" , DermaPanel )
	code:SetText(GetConVarString("cl_weapon_gdo_iriscode"):gsub("[^1-9]",""))
	code:SetPos( 15, 40)
	code:SetSize(200, 20)
	code:SetTooltip("Type the IDC here (Numbers only!).")
 	code.OnTextChanged = function(TextEntry)
 		local pos = TextEntry:GetCaretPos();
 		local len = TextEntry:GetValue():len();
		local letters = TextEntry:GetValue():gsub("[^1-9]","");
		TextEntry:SetText(letters);
		TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,letters:len())); -- Reset the caretpos!
	end

	local MenuButtonCreate = vgui.Create("DButton")
    MenuButtonCreate:SetParent( DermaPanel )
    MenuButtonCreate:SetText( "Save and Exit" )
    MenuButtonCreate:SetPos(275, 40)
    MenuButtonCreate:SetSize(80, 25)
	MenuButtonCreate.DoClick = function ( btn )
		LocalPlayer():ConCommand("cl_weapon_gdo_iriscode " .. code:GetValue() .. "\n")
	    DermaPanel:Remove()
    end

end
vgui.Register( "ShowIrisMenu", VGUI )

function gdo_menuhook(um)
	local Window = vgui.Create( "ShowIrisMenu" )
	Window:SetMouseInputEnabled( true )
	Window:SetVisible( true )
	e = um:ReadEntity();
	if(not IsValid(e)) then return end;
end
usermessage.Hook("gdo_openpanel", gdo_menuhook)