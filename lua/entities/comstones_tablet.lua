--[[
	Comunication Device
	Copyright (C) 2011 Madman07
]]--

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Stone Tablet"
ENT.Author = "cooldudetb, Madman07, Boba Fett"
ENT.Category = "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.WireDebugName = "Communication Tablet"

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_stone_tablet");
end

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

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile();

ENT.Sounds = {
	Place = Sound("tech/comstone_placestone.wav"),
	Transfer = Sound("tech/comstone_transferminds.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/com_device/device.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Stones = {};
	self.Channel = 1;
	self.ActiveStones = 0;
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("comstones_tablet");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

-----------------------------------USE----------------------------------

function ENT:Use(ply)
	umsg.Start("ComDeviceSet",ply)
	umsg.Entity(self.Entity);
	umsg.End()
end

-----------------------------------REMOVE----------------------------------

function ENT:OnRemove()
	for _,v in pairs(self.Stones) do
		self:Disconnect(v);
	end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)
	concommand.Add("Chan"..self:EntIndex(),function(ply,cmd,args)
		self.Channel = tonumber(args[1]);
		self.Entity:SetNetworkedInt("Chann", self.Channel);
    end);
end

-----------------------------------TOUCH----------------------------------

function ENT:StartTouch(ent)
	if (ent:GetClass()=="comstones_stone") then
		self:EmitSound(self.Sounds.Place,100,math.random(98,102));
		ent.Tablet = self.Entity;
		local effectdata = EffectData()
			effectdata:SetEntity(ent)
		util.Effect( "entity_remove", effectdata )
		if (IsValid(ent.Ply) and ent.Ply:IsPlayer()) then self:Connect(ent); end
	end
end

function ENT:EndTouch(ent)
	if (ent:GetClass() == "comstones_stone" and table.HasValue(self.Stones, ent)) then
		self:EmitSound(self.Sounds.Place,100,math.random(98,102));
		ent.Tablet = NULL;
		local effectdata = EffectData()
			effectdata:SetEntity(ent)
		util.Effect( "entity_remove", effectdata )
		if (IsValid(ent.Ply) and ent.Ply:IsPlayer()) then self:Disconnect(ent); end
	end
end

-----------------------------------CONNECT----------------------------------

function ENT:Connect(ent)
	if table.HasValue(self.Stones, ent) then return end
	table.insert(self.Stones, ent);

	local device, pair = self:FindDevice();
	if not IsValid(device) then return end
	if not IsValid(pair) then return end

	local ply1 = ent.Ply;
	local ply2 = pair.Ply;

	self:EmitSound(self.Sounds.Transfer,100,math.random(98,102));
	device:EmitSound(device.Sounds.Place,100,math.random(98,102));

	if IsValid(ply1) and IsValid(ply2) then -- swap players
		self:SwapPlayers(ply1, ply2);
	else return end

	ply1.Stone = ent; -- for both side death purposes;
	ply2.Stone = pair;
	ply1.Ply = ply2;
	ply2.Ply = ply1;
	ply1.UsingStone = true;
	ply2.UsingStone = true;

	ent.Connected = true;
	ent.PairedStone = pair;
	pair.Connected = true;
	pair.PairedStone = ent;

	self.ActiveStones = self.ActiveStones+1;
	self.Entity:SetNWInt("Active", self.ActiveStones);

	device.ActiveStones = device.ActiveStones+1;
	device:SetNWInt("Active", device.ActiveStones);
end

function ENT:Disconnect(ent)
	local new_t = {};
	for _,v in pairs(self.Stones) do
		if(v ~= ent) then table.insert(new_t,v);
		end
	end
	self.Stones = new_t;

	self:EmitSound(self.Sounds.Transfer,100,math.random(98,102));

	if ent.Connected then
		ent.Connected = false;
		local pair = ent.PairedStone;
		if IsValid(pair) then
			local ply1 = ent.Ply;
			local ply2 = pair.Ply;

			if IsValid(ply1) and IsValid(ply2) then-- swap players back
				self:SwapPlayers(ply1, ply2);
			end

			ply1.Stone = nil;
			ply1.Ply = nil;
			ply1.UsingStone = true;
			ply1 = NULL;

			if IsValid(pair.Tablet) then --- disconnect second stone
				pair.Tablet:Disconnect(pair);
			end
			pair = NULL;

			self.ActiveStones = self.ActiveStones-1;
			self.Entity:SetNWInt("Active", self.ActiveStones);
		end
	end
end

-----------------------------------DEATH----------------------------------

function PlayerDeath_Stone(ply) -- What happen if one of connected player will die?
	if ply.UsingStone then
		local stone = ply.Stone
		local ply2 = ply.Ply;
		if IsValid(ply2) then
			ply2.Ply = nil;
			ply2:Kill();
		end
		if IsValid(stone) then
			local tablet = stone.Tablet;
			if IsValid(tablet) then tablet:Disconnect(stone); end
		end
		ply.Ply = nil;
		ply.Stone = nil;
		ply.UsingStone = nil;
	end
end
hook.Add( "PlayerDeath", "PlayerDeath_Stone", PlayerDeath_Stone )
hook.Add( "PlayerSilentDeath", "PlayerDeath_Stone", PlayerDeath_Stone )

-----------------------------------FIND----------------------------------

function ENT:FindDevice()
	local ston;
	local pos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("comstones_tablet")) do
		if(v != self.Entity and v.Channel == self.Channel) then
			ston = v:FindStone();
			if IsValid(ston) then
				return v, ston;
			end
		end
	end
	return nil, nil;
end

function ENT:FindStone()
	local stone;
	for _,v in pairs(self.Stones) do
		if not v.Connected then
			stone = v;
		end
	end
	return stone;
end

-----------------------------------SWAP----------------------------------

function ENT:SwapPlayers(pl1,pl2)

	if (not IsValid(pl1) or not IsValid(pl2)) then return end

	local fx1 = EffectData();
		fx1:SetEntity(pl1);
	util.Effect("com_device_light",fx1,true);
	local fx2 = EffectData();
		fx2:SetEntity(pl2);
	util.Effect("com_device_light",fx2,true);

	local v1 = pl1:GetPos();
	local v2 = pl2:GetPos();
	local a1 = pl1:EyeAngles();
	local a2 = pl2:EyeAngles();
	local m1 = pl1:GetModel();
	local m2 = pl2:GetModel();
	local n1 = pl1:GetName();
	local n2 = pl1:GetName();
	local vh1 = pl1:GetVehicle();
	local vh2 = pl2:GetVehicle();
	local h1 = pl1:Health();
	local h2 = pl2:Health();
	local m1 = pl1:GetMoveType();
	local m2 = pl2:GetMoveType();

	local w1 = {};
	for k,v in pairs(pl1:GetWeapons()) do table.insert(w1, v:GetClass()) end
	local w2 = {};
	for k,v in pairs(pl2:GetWeapons()) do table.insert(w2, v:GetClass()) end

	if (not IsValid(pl1:GetActiveWeapon()) or not IsValid(pl2:GetActiveWeapon())) then return end

	local aw1 = pl1:GetActiveWeapon():GetClass();
	local aw2 = pl2:GetActiveWeapon():GetClass();

	-- pl1.__PreviousMoveType = pl1:GetMoveType();
	-- pl1:SetMoveType(MOVETYPE_NOCLIP)
	-- pl2.__PreviousMoveType = pl2:GetMoveType();
	-- pl2:SetMoveType(MOVETYPE_NOCLIP)

	pl1:SetPos(v2);
	pl2:SetPos(v1);
	pl1:SetEyeAngles(a2);
	pl2:SetEyeAngles(a1);

	pl1:SetMoveType(m2);
	pl2:SetMoveType(m1);

	pl1:SetModel(m2);
	pl2:SetModel(m1);
	pl1:SetName(n2);
	pl2:SetName(n1);

	pl1:SetHealth(h2);
	pl2:SetHealth(h1);

	if IsValid(vh1) then pl1:ExitVehicle() end
	if IsValid(vh2) then pl2:ExitVehicle() end

	pl1:StripWeapons();
	pl2:StripWeapons();
	for k,v in pairs(w2) do pl1:Give(tostring(v)); end
	for k,v in pairs(w1) do pl2:Give(tostring(v)); end
	pl1:SelectWeapon(aw2);
	pl2:SelectWeapon(aw1);

	if (IsValid(vh1)) then pl2:EnterVehicle(vh1) end
	if (IsValid(vh2)) then pl1:EnterVehicle(vh2) end
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	dupeInfo.Channel = self.Channel;

	duplicator.StoreEntityModifier(self, "StoneTabletDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "StoneTabletDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.StoneTabletDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.Channel = dupeInfo.Channel;
	self.Entity:SetNWInt("Chann", self.Channel);

end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "comstones_tablet", StarGate.CAP_GmodDuplicator, "Data" )
end

end