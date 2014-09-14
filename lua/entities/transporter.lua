--Idea and originally code by PiX06 - Recoded,shrinked,fixed and optimized (:D) by aVoN
--http://forums.facepunchstudios.com/showthread.php?p=6341522

-- gui by AlexALX

-- FIXME: Rewrite every single line below and add a stool so it's not required to use wire

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

ENT.PrintName	= "Asgard Transporter"
ENT.Author = "PiX06, aVoN, Boba Fett, AlexALX"
ENT.Contact = "pix06@hotmail.co.uk"
ENT.Category = "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile();

--include("entities/event_horizon/modules/teleport.lua"); -- FIXME: Move all teleportation code of the eventhorizon to /stargate/server/teleport.lua. Then create a teleportation class

local snd = Sound("tech/asgard_teleport.mp3");

--################### Init @PiX06,aVoN
function ENT:Initialize()
	self.Entity:SetModel("models/Boba_Fett/props/asgard_console/asgard_console.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Origin = Vector(0,0,0);
	self.Destination = Vector(0,0,0);
	self.TeleportEverything = false;
	self.Exceptions = {}; -- Used internal
	self:AddResource("energy",1);
	self:CreateWireInputs("Origin [VECTOR]","Origin X","Origin Y","Origin Z","Dest [VECTOR]","Dest X","Dest Y","Dest Z","Teleport Everything","Send","Retrieve","Disable Use");
	self:CreateWireOutputs("Teleport Distance","Targets at Origin","Targets at Destination");
	self.Disallowed = {};
	for _,v in pairs(StarGate.CFG:Get("asgard_transporter","classnames",""):TrimExplode(",")) do
		self.Disallowed[v:lower()] = true;
	end
	self.BusyTime = StarGate.CFG:Get("asgard_transporter","busy_time",5);
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
	end

	self.Entity:SetUseType(SIMPLE_USE);
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("transporter");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end
	ent.Owner = ply;

	return ent
end

--################### Update some vars @aVoN
function ENT:Think()
	if (not IsValid(self)) then return end
	local orig,dest = 0,0;
	local dist = 0;
	if(self.Origin ~= self.Destination) then
		orig = table.Count(self:FindObjects(self.Origin,true));
		dest = table.Count(self:FindObjects(self.Destination,true));
		dist = self.Destination:Distance(self.Origin);
	end
	self:SetWire("Targets at Origin",orig);
	self:SetWire("Targets at Destination",dest);
	self:SetWire("Teleport Distance",dist);
	--self:SetOverlayText("Asgard Transporter\nTeleport Distance: "..dist);
	self.Entity:NextThink(CurTime()+0.5);
	return true;
end

-- Tiny helper function
local function TableValuesToKeys(tab)
	local ret = {};
	for _,v in pairs(tab) do
		ret[v] = v;
	end
	return ret;
end

--################### Is the entity we want to teleport valid? @aVoN
function ENT:ValidForTeleport(e)
	local phys = e:GetPhysicsObject();
	if(not IsValid(phys) or e.GateSpawnerProtected or e:IsWorld() or IsValid(e:GetParent())) then return false end;
	if(e:IsWeapon() and type(e:GetParent()) == "Player") then return end;
	local class = e:GetClass():lower();
	local mdl = e:GetModel() or "";
	if(not (self.Disallowed[class] or class:find("func_") or mdl:find("*") or class=="prop_door_rotating")) then return true end;
	return false;
end

--################### Get valid objects for teleport @aVoN
function ENT:FindObjects(pos,quick)
	local objects = {};
	for _,e in pairs(ents.FindInSphere(pos,130)) do
		if(e:IsValid()) then
			-- Only players?
			local allow = hook.Call("StarGate.Transporter.TeleportEnt",nil,e,self);
			if (allow==false) then continue end
			if(e:IsPlayer() or e:IsNPC()) then
				objects[e] = e
			-- Everything?
			elseif(self.TeleportEverything and not self.Exceptions[e]) then
				local class = e:GetClass();
				local mdl = e:GetModel() or "";
				-- Validity checked
				if(self:ValidForTeleport(e)) then
					-- Is this stuff in whatever kind constrained to other stuff? And is this "other stuff" frozen? If yes, do not allow teleportation.
					-- If no, allow teleportation but the whole stuff!
					-- FIXME: Use the stargate teleportation code. Look at the top of the file
					local allow = true;
					if(not quick) then
						local entities = StarGate.GetConstrainedEnts(e);
						if(#entities < 50) then -- So much to teleport? NAH! (Maybe later with the stargate teleport stuff)
							for k,v in pairs(entities) do
								if(self.Exceptions[v] or v == self.Entity) then allow = false break end;
								local phys = v:GetPhysicsObject();
								if(phys:IsValid() and v ~= e) then
									-- One part is frozen: So the whole contraption can't get teleported
									if(not phys:IsMoveable()) then allow = false break end;
								else
									entities[k] = nil;
								end
							end
							-- Add the whole (small) contration.
							if(allow) then
								for _,v in pairs(entities) do
									if(self:ValidForTeleport(v)) then objects[v] = v end;
								end
							end
						else
							allow = false;
						end
					end
					if(allow) then objects[e] = e end;
				end
			end
		end
	end
	return objects;
end

--################### Wire input has been triggered @aVoN
function ENT:TriggerInput(k,v)
	local b = util.tobool(v);
	if(k == "Origin") then
		self.Origin = v;
	elseif(k == "Origin X") then
		self.Origin.X = v;
	elseif(k == "Origin Y") then
		self.Origin.Y = v;
	elseif(k == "Origin Z") then
		self.Origin.Z = v;
	elseif(k == "Dest X") then
		self.Destination.X = v;
	elseif(k == "Dest Y") then
		self.Destination.Y = v;
	elseif(k == "Dest Z") then
		self.Destination.Z = v;
	elseif(k == "Dest") then
		self.Destination = v;
	elseif(k == "Send") then
		if(b) then
			self:Teleport(self.Origin,self.Destination);
		end
	elseif(k == "Retrieve") then
		if(b) then
			self:Teleport(self.Destination,self.Origin);
		end
	elseif(k == "Teleport Everything") then
		self.TeleportEverything = b;
		self:SetWire("Teleport Everything",b);
	end
end

--################### Do teleport @aVoN
-- Helper function. Out here because it's called by a timer. And we do not want to create new function objects everytime we teleport - This fights an issue with GarbageCollection
local function DoTeleportTimer(e,pos,r,g,b,a,rm)
	if not IsValid(e) then return end
	local isplayer = e:IsPlayer();
	local mtype;
	if(isplayer) then
		-- Set him noclip for a second. Otherwise he probably gets stuck "on the destination" and GMod seems to have an inbuild mechanism to
		-- teleport him "back" to the old positon. So he never moved.
		mtype = e:GetMoveType();
		e:SetMoveType(MOVETYPE_NOCLIP);
	end
	e:SetPos(pos);
	e:SetColor(Color(r,g,b,a));
	e:SetRenderMode(rm);
	if(isplayer) then e:SetMoveType(mtype) end;
end

function ENT:Teleport(from,to,ply,gps_ent)
	local time = CurTime();
	if((self.Next or 0) > time) then
		if (IsValid(ply)) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"asgardtp_busy\"), NOTIFY_ERROR, 3); surface.PlaySound( \"buttons/button2.wav\" )");
		end
		return
	end
	-- first check for jammming devices, we can telepor from and to only if jaiming is offline (madman07)
	local radius = 1024; -- max range of jamming, we will adjust it later
	local jaiming_online = false;
	for _,v in pairs(ents.FindInSphere(from,  radius)) do
		if IsValid(v) and v.CapJammingDevice then
			if v.IsEnabled then
				local dist = from:Distance(v:GetPos());
				if (dist < v.Size) then  -- ow jaiming, we cant do anything
					if v.Immunity and v.Owner == self.Owner then local a; -- but we are the owner so we know codes :D it does nothign, so create some value...
					else jaiming_online = true end
				end
			end
		end
	end
	for _,v in pairs(ents.FindInSphere(to,  radius)) do
		if IsValid(v) and v.CapJammingDevice then
			if v.IsEnabled then
				local dist = to:Distance(v:GetPos());
				if (dist < v.Size) then -- ow jaiming, we cant do anything
					if v.Immunity and v.Owner == self.Owner then local a; -- but we are the owner so we know codes :D it does nothign, so create some value...
					else jaiming_online = true end
				end
			end
		end
	end
	if (not util.IsInWorld(to)) then
		if (IsValid(ply)) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"asgardtp_wrong\"), NOTIFY_ERROR, 3); surface.PlaySound( \"buttons/button2.wav\" )");
		end
		return
	end
	if not jaiming_online then
		-- Prepare teleport
		self.Exceptions = TableValuesToKeys(StarGate.GetConstrainedEnts(self.Entity)); -- Not allowed because constrained to this teleporter
		if (IsValid(gps_ent)) then self.Exceptions[gps_ent] = true; end
		local entities = self:FindObjects(from);
		local num = table.Count(entities);
		if(num == 0) then return end;
		local distance = (from - to):Length();
		local needed_energy = distance/5*num;
		local energy = self:GetResource("energy",needed_energy);
		if(energy < needed_energy) then
			if (IsValid(ply)) then
				ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"asgardtp_energy\"), NOTIFY_ERROR, 3); surface.PlaySound( \"buttons/button2.wav\" )");
			end
			return
		end
		self:ConsumeResource("energy",needed_energy);
		self.Next = time + self.BusyTime;

		if (IsValid(ply)) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"asgardtp_succ\"), NOTIFY_GENERIC, 4); surface.PlaySound( \"buttons/button9.wav\" )");
		end

		-- This here is the actual teleport
		sound.Play(snd,from,100,100);
		sound.Play(snd,to,100,100);
		local diff = to - from;
		for _,v in pairs(entities) do
			local start = v:GetPos();
			local dest = diff + start; dest.z = dest.z + 1; -- Offset so you never get stuck in ground
			if (not util.IsInWorld(dest)) then continue end
			-- Effects for teleport. That's what you actually see. But you seriously should see me coding this shit all around because a teleporter IS NOT ONLY THE EFFECT - idiot!
			local color = v:GetColor();
			local rendmode = v:GetRenderMode();
			v:SetRenderMode( RENDERMODE_TRANSALPHA );
			v:SetColor(Color(color.r,color.g,color.b,0));
			local fx = EffectData();
			fx:SetEntity(v);
			fx:SetOrigin(start);
			fx:SetScale(1); -- "Suck in" - a.k.a. "beam me up". Suck it!
			util.Effect("teleport_effect",fx,true,true);
			fx:SetOrigin(dest);
			fx:SetScale(0); -- "Spit out" - a.k.a. "beam me down". Don't spit bitch
			-- Note to myself: Why am I so damn sarcastic and vogue?
			util.Effect("teleport_effect",fx,true,true);
			timer.Simple(0.8,function() DoTeleportTimer(v,dest,color.r,color.g,color.b,color.a,rendmode) end);
		end
	elseif (IsValid(ply)) then
		ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"asgardtp_jamming\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "transporter", StarGate.CAP_GmodDuplicator, "Data" )
end

util.AddNetworkString("CAP.AsgardTransporter");

local function GetPlayers()
	local plys = {}
	for k,v in pairs(player.GetAll()) do
		if (v:IsConnected()) then
			table.insert(plys,{v:EntIndex(),v:Name()});
		end
	end
	return plys;
end

local function GetNPCs()
	local npcs = {}
	for k,v in pairs(ents.FindByClass("npc_*")) do
		table.insert(npcs,{v:EntIndex(),"["..v:EntIndex().."] "..v:GetClass()});
	end
	return npcs;
end

local function GetGPS()
	local gps = {}
	for k,v in pairs(ents.FindByClass("gmod_wire_gps")) do
		local name = v:GetNetworkedString("WireName",v:GetClass());
		if (name=="") then name = v:GetClass() end
		table.insert(gps,{v:EntIndex(),"["..v:EntIndex().."] "..name});
	end
	return gps;
end

function ENT:Use(ply)
	if (self:GetWire("Disable Use")>=1) then return end

	net.Start("CAP.AsgardTransporter");
	net.WriteEntity(self);
	net.WriteInt(0,8);
	net.WriteTable(GetPlayers());
	net.WriteTable(GetNPCs());
	net.WriteTable(GetGPS());
	net.Send(ply);
end

net.Receive("CAP.AsgardTransporter",function(len,ply)
	local self = net.ReadEntity();
	if (not IsValid(self)) then return end
	if (self:GetWire("Disable Use")>=1) then return end
	local type = net.ReadInt(4);
	if (type==0) then
		local tent = Entity(net.ReadInt(16));
		local dent = Entity(net.ReadInt(16));
		local ents = util.tobool(net.ReadBit());
		local ignore_gps = util.tobool(net.ReadBit())
		if (IsValid(tent) and IsValid(dent)) then
			self.TeleportEverything = ents;
			if (ignore_gps) then
				self:Teleport(tent:GetPos(), dent:GetPos(), ply, tent);
			else
				self:Teleport(tent:GetPos(), dent:GetPos(), ply);
			end
		else
		   ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"asgardtp_error\"), NOTIFY_ERROR, 3); surface.PlaySound( \"buttons/button2.wav\" )");
		end
	elseif(type==1) then
		local dest = util.tobool(net.ReadBit());
		local t = net.ReadInt(4);
		net.Start("CAP.AsgardTransporter");
		net.WriteEntity(self);
		net.WriteInt(1,8);
		net.WriteBit(dest);
		if (t==2) then
			net.WriteTable(GetNPCs());
		elseif (t==3) then
			net.WriteTable(GetGPS());
		else
			net.WriteTable(GetPlayers());
		end
		net.Send(ply);
	elseif(type==2) then
		net.Start("CAP.AsgardTransporter");
		net.WriteEntity(self);
		net.WriteInt(2,8);
		net.WriteTable(GetPlayers());
		net.WriteTable(GetNPCs());
		net.WriteTable(GetGPS());
		net.Send(ply);
	end
end)

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_asgart_trans");
end

function ENT:Initialize()
	self.SaveTable = {};
end

local DermaPanel

net.Receive("CAP.AsgardTransporter",function(len)
	local ent = net.ReadEntity();
	if (not IsValid(ent)) then return end

	local type = net.ReadInt(8);

	local function updateAction()
		local target = DermaPanel.targetList:GetSelectedLine();
		local dest = DermaPanel.destList:GetSelectedLine();
		if (target and dest) then
			local tname = DermaPanel.targetList:GetLine(target):GetColumnText(1);
			local dname = DermaPanel.destList:GetLine(dest):GetColumnText(1);
			local withents = "";
			if (DermaPanel.withEnts:GetChecked()) then
				withents = "\n"..SGLanguage.GetMessage("asgardtp_acte");
			end
			if (ent.SaveTable.targetType and ent.SaveTable.targetType==3) then
				DermaPanel.action:SetText(SGLanguage.GetMessage("asgardtp_act2",tname,dname)..withents);
			else
				DermaPanel.action:SetText(SGLanguage.GetMessage("asgardtp_act",tname,dname)..withents);
			end
			DermaPanel.action:SizeToContents();
			DermaPanel.action:CenterHorizontal();
		else
			DermaPanel.action:SetText(SGLanguage.GetMessage("asgardtp_none"));
			DermaPanel.action:SizeToContents();
			DermaPanel.action:CenterHorizontal();
		end
	end

	if (type==1) then
		if (DermaPanel and DermaPanel:IsValid()) then
			local dest = util.tobool(net.ReadBit());
			local list = DermaPanel.targetList;
			if (dest) then list = DermaPanel.destList; end
			local ents = net.ReadTable();
			list:Clear();
			for k,v in pairs(ents) do
				list:AddLine(v[2],v[1]);
			end
			updateAction();
		end
	elseif (type==2) then
		if (DermaPanel and DermaPanel:IsValid()) then
			local plys = net.ReadTable();
			local npcs = net.ReadTable();
			local gps = net.ReadTable();

			DermaPanel.targetList:Clear();
			local ents = plys;
			if (ent.SaveTable.targetType and ent.SaveTable.targetType==2) then
				ents = npcs;
			elseif (ent.SaveTable.targetType and ent.SaveTable.targetType==3) then
				ents = gps;
			end
			for k,v in pairs(ents) do
				DermaPanel.targetList:AddLine(v[2],v[1])
			end

			DermaPanel.destList:Clear();
			local ents = plys;
			if (ent.SaveTable.destType and ent.SaveTable.destType==2) then
				ents = npcs;
			elseif (ent.SaveTable.destType and ent.SaveTable.destType==3) then
				ents = gps;
			end
			for k,v in pairs(ents) do
				DermaPanel.destList:AddLine(v[2],v[1])
			end
			updateAction();

		end
	elseif (type==0) then

	if (DermaPanel and DermaPanel:IsValid()) then DermaPanel:Close() end

	local plys = net.ReadTable();
	local npcs = net.ReadTable();
	local gps = net.ReadTable();

	DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetSize(380, 390)
	DermaPanel:Center()
	DermaPanel:SetTitle("")
	DermaPanel:SetVisible( true )
	DermaPanel:SetDraggable( false )
	DermaPanel:ShowCloseButton( true )
	DermaPanel:MakePopup()
	DermaPanel.Paint = function(self,w,h)
		surface.SetDrawColor( 80, 80, 80, 185 )
		surface.DrawRect( 0, 0, w, h )
	end

	local refreshButton = vgui.Create("DButton" , DermaPanel )
	refreshButton:SetParent( DermaPanel )
	refreshButton:SetText("")
	refreshButton:SetToolTip(SGLanguage.GetMessage("asgardtp_refresh"))
	refreshButton:SetPos(178, 30)
	refreshButton:SetSize(25, 20)
	refreshButton:SetImage( "icon16/arrow_refresh_small.png" );
	refreshButton.DoClick = function ( btn )
		net.Start("CAP.AsgardTransporter");
		net.WriteEntity(ent);
		net.WriteInt(2,4);
		net.SendToServer();
	end

  	local title = vgui.Create( "DLabel", DermaPanel );
 	title:SetText(SGLanguage.GetMessage("asgardtp_title"));
  	title:SetPos( 25, 0 );
 	title:SetSize( 400, 25 );

 	local image = vgui.Create("DImage" , DermaPanel);
    image:SetSize(16, 16);
    image:SetPos(5, 5);
    image:SetImage("gui/cap_logo");

	local targetType = vgui.Create("DMultiChoice", DermaPanel);
    targetType:SetPos(20, 30);
    targetType:SetSize(150, 20);
    targetType:SetEditable(false);
    targetType:AddChoice(SGLanguage.GetMessage("asgardtp_type1"),1);
    targetType:AddChoice(SGLanguage.GetMessage("asgardtp_type2"),2);
    targetType:AddChoice(SGLanguage.GetMessage("asgardtp_type3"),3);
	targetType:ChooseOptionID(ent.SaveTable.targetType or 1);
	targetType.OnSelect = function(panel,index,value,data)
		ent.SaveTable.targetType = data;
		net.Start("CAP.AsgardTransporter");
		net.WriteEntity(ent);
		net.WriteInt(1,4);
		net.WriteBit(false);
		net.WriteInt(data,4);
		net.SendToServer();
	end
	targetType:SetToolTip(SGLanguage.GetMessage("asgardtp_target_desc"));
	DermaPanel.targetType = targetType;

	local targetList = vgui.Create( "DListView", DermaPanel )
	targetList:SetMultiSelect(false)
	targetList:SetPos(20, 55)
	targetList:SetSize(160, 200)
	targetList:AddColumn(SGLanguage.GetMessage("asgardtp_target"))
	targetList:SortByColumn(1, true)
	DermaPanel.targetList = targetList;
	targetList.OnRowSelected = function(self,id,line)
		updateAction();
	end

	local destType = vgui.Create("DMultiChoice", DermaPanel);
    destType:SetPos(210, 30);
    destType:SetSize(150, 20);
    destType:SetEditable(false);
    destType:AddChoice(SGLanguage.GetMessage("asgardtp_type1"),1);
    destType:AddChoice(SGLanguage.GetMessage("asgardtp_type2"),2);
    destType:AddChoice(SGLanguage.GetMessage("asgardtp_type3"),3);
	destType:ChooseOptionID(ent.SaveTable.destType or 1);
	destType.OnSelect = function(panel,index,value,data)
		ent.SaveTable.destType = data;
		net.Start("CAP.AsgardTransporter");
		net.WriteEntity(ent);
		net.WriteInt(1,4);
		net.WriteBit(true);
		net.WriteInt(data,4);
		net.SendToServer();
	end
	destType:SetToolTip(SGLanguage.GetMessage("asgardtp_dest_desc"));
	local destList = vgui.Create( "DListView", DermaPanel )
	destList:SetMultiSelect(false)
	destList:SetPos(200, 55)
	destList:SetSize(160, 200)
	destList:AddColumn(SGLanguage.GetMessage("asgardtp_dest"))
	destList:SortByColumn(1, true)
	DermaPanel.destList = destList;
	destList.OnRowSelected = function(self,id,line)
		updateAction();
	end

	local ents = plys;
	if (ent.SaveTable.targetType==2) then
		ents = npcs;
	elseif (ent.SaveTable.targetType==3) then
		ents = gps;
	end
	for k,v in pairs(ents) do
		targetList:AddLine(v[2],v[1])
	end

	local ents = plys;
	if (ent.SaveTable.destType==2) then
		ents = npcs;
	elseif (ent.SaveTable.destType==3) then
		ents = gps;
	end
	for k,v in pairs(ents) do
		destList:AddLine(v[2],v[1])
	end

  	local action = vgui.Create( "DLabel", DermaPanel );
 	action:SetText(SGLanguage.GetMessage("asgardtp_action"));
  	action:SetPos( 0, 280 );
 	action:SizeToContents();
	action:CenterHorizontal();

  	local act = vgui.Create( "DLabel", DermaPanel );
 	act:SetText(SGLanguage.GetMessage("asgardtp_none"));
  	act:SetPos( 0, 300 );
 	act:SizeToContents();
  	act:CenterHorizontal();
 	DermaPanel.action = act;

	local withEnts = vgui.Create("DCheckBoxLabel" , DermaPanel )
	withEnts:SetText(SGLanguage.GetMessage("asgardtp_ents"))
	withEnts:SizeToContents()
	withEnts:SetPos(30, 260)
	withEnts:SetValue(ent.SaveTable.withEnts or 0)
	withEnts:SizeToContents()
	withEnts:SetTooltip(SGLanguage.GetMessage("asgardtp_ents_desc"))
	withEnts.OnChange = function(self,val)
		ent.SaveTable.withEnts = val;
		updateAction();
	end
	DermaPanel.withEnts = withEnts;

	local sendButton = vgui.Create("DButton" , DermaPanel )
	sendButton:SetParent( DermaPanel )
	sendButton:SetText(SGLanguage.GetMessage("asgardtp_send"))
	sendButton:SetPos(215, 360)
	sendButton:SetSize(130, 25)
	sendButton.DoClick = function ( btn )
		local target = targetList:GetSelectedLine();
		local dest = destList:GetSelectedLine();
		if (target and dest) then
			local tent = targetList:GetLine(target):GetColumnText(2);
			local dent = destList:GetLine(dest):GetColumnText(2);
			local ents = DermaPanel.withEnts:GetChecked();
			net.Start("CAP.AsgardTransporter");
			net.WriteEntity(ent);
			net.WriteInt(0,4);
			net.WriteInt(tent,16);
			net.WriteInt(dent,16);
			net.WriteBit(ents);
			if (ent.SaveTable.targetType and ent.SaveTable.targetType==3) then
				net.WriteBit(true);
			else
				net.WriteBit(false);
			end
			net.SendToServer();
		else
			GAMEMODE:AddNotify(SGLanguage.GetMessage("asgardtp_noact"), NOTIFY_ERROR, 5); surface.PlaySound( "buttons/button2.wav" );
		end
	end

	local retrieveButton = vgui.Create("DButton" , DermaPanel )
	retrieveButton:SetParent( DermaPanel )
	retrieveButton:SetText(SGLanguage.GetMessage("asgardtp_retrieve"))
	retrieveButton:SetPos(35, 360)
	retrieveButton:SetSize(130, 25)
	retrieveButton.DoClick = function ( btn )
		local target = targetList:GetSelectedLine();
		local dest = destList:GetSelectedLine();
		if (target and dest) then
			local tent = targetList:GetLine(target):GetColumnText(2);
			local dent = destList:GetLine(dest):GetColumnText(2);
			local ents = DermaPanel.withEnts:GetChecked();
			net.Start("CAP.AsgardTransporter");
			net.WriteEntity(ent);
			net.WriteInt(0,4);
			net.WriteInt(dent,16);
			net.WriteInt(tent,16);
			net.WriteBit(ents);
			if (ent.SaveTable.destType and ent.SaveTable.destType==3) then
				net.WriteBit(true);
			else
				net.WriteBit(false);
			end
			net.SendToServer();
		else
			GAMEMODE:AddNotify(SGLanguage.GetMessage("asgardtp_noact"), NOTIFY_ERROR, 5); surface.PlaySound( "buttons/button2.wav" );
		end
	end

	end

end)

end