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
SWEP.HoldType = "slam"

SWEP.WElements = {
	["World_weapon_model"] = { type = "Model", model = "models/Madman07/GDO/GDO_w.mdl", bone = "ValveBiped.Bip01_L_Forearm", rel = "", pos = Vector(6, 0, 0), angle = Angle(0, 0, 0), size = Vector(1.799, 1.799, 1.799), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

if SERVER then

function SWEP:OnDrop()
	self:SetNWBool("WorldNoDraw",false);
	return true;
end

function SWEP:Equip()
	self:SetNWBool("WorldNoDraw",true);
	return true;
end

end

SWEP.gate = nil

local function SendCode(EntTable,code)
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
		elseif answer == -2 then
			EntTable:SetNWString("gdo_textdisplay", "ERROR");
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
				local cod = iris_comp.GDOStatus;
				if (IsValid(iris_comp)) then
					if (cod==-1) then
						if (iris_comp.GDOText and iris_comp.GDOText!="") then
							EntTable:SetNWString("gdo_textdisplay", iris_comp.GDOText);
						else
							EntTable:SetNWString("gdo_textdisplay", "WRONG");
						end
						timer.Remove("GDOTimer"..id);
						timer.Simple(5, function() if (IsValid(ent)) then ent.Stand = false; ent:SetNWString("gdo_textdisplay", "GDO") end end);
					elseif (iris_comp.GDOText and iris_comp.GDOText!="") then
						EntTable:SetNWString("gdo_textdisplay", iris_comp.GDOText);
					end
				else
					ent:SetNWString("gdo_textdisplay", "GDO");
					ent.Stand = false;
					timer.Remove("GDOTimer"..id);
				end
				if (IsValid(ent) and IsValid(ent.Owner) and ent.Stand and IsValid(ent.gate) and IsValid(ent.gate.Target) and ent.gate.IsOpen) then
					if (not ent.gate.Target:IsBlocked(1,1) and answer!=3) then
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
		
	else
	
		local self = EntTable;
		
		self.Stand = true;
		self.gate:TriggerInput("Transmit",code)
		
		local id = self:EntIndex()
		
		timer.Create("GDOTimer2"..id,0.5,0,function()
			if (not IsValid(self.gate) or not IsValid(self.gate.Target)) then return end
			Iris = StarGate.GetIris(self.gate.Target) 
			if IsValid(Iris) then
				if Iris:IsBusy() then
					self:SetNWString("gdo_textdisplay", "BUSY")
				elseif Iris.IsActivated then
					self:SetNWString("gdo_textdisplay", "CLOSED")
				elseif not Iris.IsActivated then
					self:SetNWString("gdo_textdisplay", "OPEN")		
				end
			else
				self:SetNWString("gdo_textdisplay", "ERROR")		
			end
		end)
			
		timer.Simple(self.Primary.Delay+8, function() 
			timer.Remove("GDOTimer2"..id)
			self:SetNWString("gdo_textdisplay", "GDO")
			self.Stand = false
			if self.gate then
				self.gate:TriggerInput("Transmit","")
			end
		end)
	
	end
	
end

function SWEP:Reload()
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
		timer.Simple(2, function() if IsValid(self) then self:SetNWString("gdo_textdisplay", SendCode(self)) end end);
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

--[[
********************************************************
	SWEP Construction Kit base code
		Created by Clavus
	Available for public use, thread at:
	   facepunch.com/threads/1032378


	DESCRIPTION:
		This script is meant for experienced scripters
		that KNOW WHAT THEY ARE DOING. Don't come to me
		with basic Lua questions.

		Just copy into your SWEP or SWEP base of choice
		and merge with your own code.

		The SWEP.VElements, SWEP.WElements and
		SWEP.ViewModelBoneMods tables are all optional
		and only have to be visible to the client.
********************************************************/
]]--

function SWEP:Initialize()

	// other initialize code goes here

	self:SetNWString("gdo_textdisplay", "GDO")
	self.Stand = false

	self:SetWeaponHoldType(self.HoldType);

	if CLIENT then

		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels

		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)

				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")
				end
			end
		end

	end

end

function SWEP:Holster()

	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end

	return true
end

function SWEP:OnRemove()
	self:Holster()
	if self.gate then
		self.gate:TriggerInput("Transmit","")
	end
end

if CLIENT then

	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()

		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end

		if (!self.VElements) then return end

		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then

			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end

		end

		for k, name in ipairs( self.vRenderOrder ) do

			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (!v.bone) then continue end

			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )

			if (!pos) then continue end

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()

		if (not self:GetNWBool("WorldNoDraw")) then
			self:DrawModel();
		end

		if (!self.WElements) then return end

		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end

		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end

		for k, name in pairs( self.wRenderOrder ) do

			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end

			local pos, ang

			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end

			if (!pos) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end

			elseif (v.type == "Sprite" and sprite) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

			elseif (v.type == "Quad" and v.draw_func) then

				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end

		end

	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )

		local bone, pos, ang
		if (tab.rel and tab.rel != "") then

			local v = basetab[tab.rel]

			if (!v) then return end

			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )

			if (!pos) then return end

			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		else

			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end

			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if (IsValid(self.Owner) and self.Owner:IsPlayer() and
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end

		end

		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then

				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end

			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite)
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then

				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)

			end
		end

	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)

		if self.ViewModelBoneMods then

			if (!vm:GetBoneCount()) then return end

			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end

				loopthrough = allbones
			end
			// !! ----------- !! //

			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end

				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				s = s * ms
				// !! ----------- !! //

				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end

	end

	function SWEP:ResetBonePositions(vm)

		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end

	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end

		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end

		return res

	end

end
