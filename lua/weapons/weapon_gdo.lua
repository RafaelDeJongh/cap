if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end

if SERVER then

AddCSLuaFile()

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

end

------------------------------------------------
--Author Info
------------------------------------------------
SWEP.Author             = "Rothon"
SWEP.Contact            = "steven@facklerfamily.org"
SWEP.Purpose            = "Sends IDC through stargates"
SWEP.Instructions       = "Right click to set, Left click to send"
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_gdo");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end
------------------------------------------------

list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);
-- First person Model
SWEP.ViewModel = "models/Madman07/GDO/GDO_v.mdl"
SWEP.ViewModelFOV = 80
-- Third Person Model
SWEP.WorldModel = "models/Madman07/GDO/GDO_w.mdl"
-- Weapon Details
SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 3
SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.timeClicked = 0

SWEP.gate = nil

local function SendCode(EntTable)
	if (CLIENT) then return end
	if(not IsValid(EntTable.Owner)) then return end
	local code = EntTable.Owner:GetInfo("cl_weapon_gdo_iriscode"):gsub("[^1-9]","")
	if (not IsValid(EntTable.gate) or not IsValid(EntTable.gate.Target)) then return end
	local gate_pos = EntTable.gate.Target:GetPos()
	local iris_comp = EntTable:FindEnt(gate_pos, true)
	if IsValid(iris_comp) then
		local answer = iris_comp:RecieveIrisCode(code)
		local answ = iris_comp.GDOText;
		if answer == 1 then
			if (answ and answ!="") then
				EntTable:SetNetworkedString("gdo_textdisplay", answ);
			else
				EntTable:SetNetworkedString("gdo_textdisplay", "OPEN");
			end
		elseif answer == 0 then
			if (answ and answ!="") then
				EntTable:SetNetworkedString("gdo_textdisplay", answ);
			else
				EntTable:SetNWString("gdo_textdisplay", "WRONG");
			end
		elseif answer == -1 then
			EntTable:SetNWString("gdo_textdisplay", "BUSY");
		else
			if (answ and answ!="") then
				EntTable:SetNetworkedString("gdo_textdisplay", answ);
			else
				EntTable:SetNWString("gdo_textdisplay", "STAND-BY");
			end
			EntTable.Stand = true;
			local id = EntTable:EntIndex();
			timer.Create("GDOTimer"..id,0.5,0,function()
				if (not IsValid(EntTable)) then timer.Remove("GDOTimer"); return end
				local ent = EntTable;
				if (IsValid(iris_comp)) then
					local cod = iris_comp.GDOStatus;
					if (cod==-1) then
						if (iris_comp.GDOText and iris_comp.GDOText!="") then
							EntTable:SetNWString("gdo_textdisplay", iris_comp.GDOText);
						else
							EntTable:SetNWString("gdo_textdisplay", "WRONG");
						end
						timer.Remove("GDOTimer"..id);
						timer.Simple(5, function() if (IsValid(ent)) then ent.Stand = false; ent:SetNWString("gdo_textdisplay", "GDO") end end);
					end
				else
					ent:SetNWString("gdo_textdisplay", "GDO");
					ent.Stand = false;
					timer.Remove("GDOTimer"..id);
				end
				if (IsValid(ent) and IsValid(ent.Owner) and ent.Stand and IsValid(ent.gate) and IsValid(ent.gate.Target) and ent.gate.IsOpen) then
					if (not ent.gate.Target:IsBlocked(1,1)) then
						if (IsValid(iris_comp) and iris_comp.GDOText and iris_comp.GDOText!="") then
							ent:SetNWString("gdo_textdisplay", iris_comp.GDOText);
						else
							ent:SetNWString("gdo_textdisplay", "OPEN");
						end
						timer.Remove("GDOTimer"..id);
						timer.Simple(5, function() if (IsValid(ent)) then ent:SetNWString("gdo_textdisplay", "GDO"); ent.Stand = false; end end);
					end
				else
					ent:SetNWString("gdo_textdisplay", "GDO");
					ent.Stand = false;
					timer.Remove("GDOTimer"..id);
				end
			end)
		end
	end
end

function SWEP:Reload()
end

function SWEP:Initialize()
	self:SetNWString("gdo_textdisplay", "GDO")
	self.Stand = false
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()
	if(CLIENT || not IsValid(self.Owner) || self:GetNetworkedString("gdo_textdisplay","GDO")!="GDO") then return end
	local pos = self.Owner:GetPos()
	self.gate = self:FindEnt(pos, false)
	if(self.gate and self.gate.IsOpen) then
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay + 1 )
		self.Owner:SetAnimation(ACT_VM_PRIMARYATTACK);
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		timer.Simple(self.Primary.Delay+1, function() if IsValid(self) then SendCode(self) end end)
		timer.Simple(2, function() if IsValid(self) then self:SetNWString("gdo_textdisplay",self.Owner:GetInfo("cl_weapon_gdo_iriscode"):gsub("[^1-9]","")) end end);
		timer.Simple(self.Primary.Delay+5, function() if (IsValid(self) and not self.Stand) then self:SetNWString("gdo_textdisplay", "GDO") end end);
	end
end

function SWEP:SecondaryAttack()
	if(CLIENT) then return end
	umsg.Start("gdo_openpanel", self.Owner)
	umsg.End()
end

function SWEP:FindEnt(pos, find_pc) -- modified from avon's dhd function
	local nearest
	local entDist = 2000 -- max distance to ent
	local foundEnts = {}
	if find_pc then
		for _,v in pairs(ents.FindByClass("iris_computer")) do
			table.insert(foundEnts,v)
		end
	else
		for _,v in pairs(ents.FindByClass("stargate_*")) do
			if (v.IsStargate) then table.insert(foundEnts,v) end
		end
	end

	for _,v in pairs(foundEnts) do
		local foundEnt_dist = (pos - v:GetPos()):Length()
		if entDist >= foundEnt_dist then
			entDist = foundEnt_dist
			nearest = v
		end
	end
	return nearest
end

if CLIENT then

local matScreen = Material("Madman07/GDO/screen");
local RTTexture = GetRenderTarget("GDO_Screen", 256, 128);

local bg = surface.GetTextureID("Madman07/GDO/screen_bg");
local font = {
	font = "Quiver",
	size = 70,
	weight = 1000,
	antialias = true,
	additive = false,
}
surface.CreateFont("Quiver", font);

function SWEP:RenderScreen()

    local NewRT = RTTexture;
    local oldW = ScrW();
    local oldH = ScrH();
	local ply = LocalPlayer();
	local col = self.ColorDisplay;

	matScreen:SetTexture( "$basetexture", NewRT);

    local OldRT = render.GetRenderTarget();
    render.SetRenderTarget(NewRT);
    render.SetViewPort( 0, 0, 256, 128);

    cam.Start2D();

		render.Clear( 50, 50, 100, 0 );

	    surface.SetDrawColor( 255, 255, 255, 255 );
        surface.SetTexture( bg );
        surface.DrawTexturedRect( 0, 0, 256, 128);

		surface.SetFont( "Quiver" )

		local gdo_answer = self:GetNetworkedString("gdo_textdisplay", "")

		local w, h = surface.GetTextSize(gdo_answer)
		local x = (256-w)/2;
		local y = (128-h)/2;

		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos(x+3, y+3)
		surface.DrawText(gdo_answer)

		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos(x, y)
		surface.DrawText(gdo_answer)

    cam.End2D();

    render.SetRenderTarget(OldRT);
    render.SetViewPort( 0, 0, oldW, oldH )

end

-- cl_init.lua

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

end