--[[
	Ring Panel
	Copyright (C) 2010 Madman07
]]--

ENT.Type 			= "anim"

ENT.PrintName	= "Ring Control Panel"
ENT.Author	= "Catdaemon"
ENT.Contact	= ""
ENT.Purpose	= ""
ENT.Instructions= "Touch once to a Ring Transporter Base to pair, USE to begin."
ENT.Category		= "Stargate"

ENT.Spawnable	= false
ENT.AdminSpawnable = false

ENT.IsRingPanel = true;

function ENT:GetAimingButton(p)
	local e = self.Entity;
	local c = self.ButtonPos;
	local t = p:GetEyeTrace();
	local cv = self.Entity:WorldToLocal(t.HitPos)
	local btn = nil;
	local lastd = 5;
	for k,v in pairs(c) do
		da = (cv - c[k]):Length()
		if(da < 1.5) then
			if(da < lastd) then
				lastd = da;
				btn = k;
			end
		end
	end
	return btn;
end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile()

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	self.DialAdress = {};
	self.CantDial = false;

	self.RingBase = self.Entity;
	self.Range = 500;

	self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));

	self.AllowMenu = StarGate.CFG:Get("ring_panel","menu",true);

end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	if (IsValid(self.Entity) and IsValid(self.RingBase) and self.RingBase != self.Entity) then

		if (timer.Exists(self.Entity:EntIndex().."Dial") and self.RingBase.Busy) then

			timer.Destroy(self.Entity:EntIndex().."Dial")
			timer.Create( self.Entity:EntIndex().."Dial", 2, 1, function()
				if IsValid(self.Entity) then
					self.DialAdress = nil;
					self.DialAdress = {};
					self.CantDial = false;
					self.Entity:SetNetworkedString("ADDRESS",string.Implode(",",self.DialAdress));
				end
			end )

		end


	end

	self.Entity:NextThink(CurTime()+1);
	return true
end

-----------------------------------FIND RINGS----------------------------------

function ENT:FindRing()
	local ring;
	local dist = self.Range;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("ring_base*")) do
		local ring_dist = (pos - v:GetPos()):Length();
		if(dist >= ring_dist) then
			dist = ring_dist;
			ring = v;
		end
	end
	return ring;
end

-----------------------------------USE---------------------------------

function ENT:Use(ply)

	if (IsValid(ply) and ply:IsPlayer()) then

		local e = self:FindRing();
		if(not IsValid(e)) then return end;
		self.RingBase = e;

		if (self.CantDial or e.Busy) then return
		else
			local button = self:GetAimingButton(ply);
			if (button) then self:PressButton(button, ply)
			elseif(self.AllowMenu) then
				umsg.Start("RingTransporterShowWindowCap", ply)
				umsg.End()
				ply.RingDialEnt = self.Entity;
			end
		end
	end

end

-----------------------------------CATDAEMON STUFF----------------------------------

function ENT:DoCallback(range, address)

	if self.RingBase == self.Entity then return end -- well that was a bloody waste of time
	if (type(address) == "number") then address = tostring(address) end

	if not self.RingBase.Busy then
		if (self.RingBase:GetClass() == "ring_base_ancient" and address == "3571") then
			local nearest_ring = self.RingBase:FindNearest("")
			if (nearest_ring == false) then return end
			if nearest_ring:GetClass() == "ring_base_ancient" then
				nearest_ring:StartLaser();
				if timer.Exists(self.Entity:EntIndex().."Dial") then timer.Destroy(self.Entity:EntIndex().."Dial") end
			end
		else
			self.RingBase.SetRange = range;
			self.RingBase:Dial(address)
		end
	end

end

function RingsDiallingCallback(ply,cmd,args)
	if ply.RingDialEnt and ply.RingDialEnt~=NULL then
		if args[1] then
			ply.RingDialEnt:DoCallback(50, args[1])
		else
			ply.RingDialEnt:DoCallback(0, "")
		end
		ply.RingDialEnt:EmitSound(Sound("button/ring_button1.mp3")); -- "Dial Button" Sound @aVoN
		ply.RingDialEnt=nil
	end
end
concommand.Add("doringsdial",RingsDiallingCallback)

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntityID = self.Entity:EntIndex()
	end
	duplicator.StoreEntityModifier(self, "RingPanelDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "RingPanelDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	local dupeInfo = Ent.EntityMods.RingPanelDupeInfo

	if dupeInfo.EntityID then
		self.Entity = CreatedEntities[ dupeInfo.EntityID ]
	end

	self.RingBase = self.Entity;

end

--######################## @Alex, aVoN -- snap gates to cap ramps
function ENT:CartersRampsRPanel(t)
	local e = t.Entity;
	if(not IsValid(e)) then return end;
	local RampOffset = StarGate.RampOffset.RingP;
	local mdl = e:GetModel();
	if(RampOffset[mdl]) then
		if (RampOffset[mdl][2]) then
			self.Entity:SetAngles(e:GetAngles() + RampOffset[mdl][2]);
		else
			self.Entity:SetAngles(e:GetAngles());
		end
		self.Entity:SetPos(e:LocalToWorld(RampOffset[mdl][1]));
		constraint.Weld(e,self.Entity,0,0,0,true);
		-- Is this needed?
		--e.CDSIgnore = true; -- Fixes Combat Damage System destroying Ramps - http://mantis.39051.vs.webtropia.com/view.php?id=45
		--return e;
	end
end

end

if CLIENT then

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

end