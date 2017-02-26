--[[
	Destiny Timer
	Copyright (C) 2010 Madman07
]]--

-- gui by AlexALX

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Destiny Timer"
ENT.WireDebugName = "Destiny Timer"
ENT.Author = "Madman07, Rafael De Jongh, AlexALX"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile()

ENT.Sounds = {
	Start = Sound("destiny/timer_start.wav"),
	Stop = Sound("destiny/timer_stop.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	util.PrecacheModel("models/Iziraider/destinytimer/timer.mdl");
	self.Entity:SetModel("models/Iziraider/destinytimer/timer.mdl");

	self.Entity:SetName("Destiny Timer");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	self:CreateWireInputs("Count","Pause","Reset","Minutes","Seconds","Normal Font","Auto Start","Auto Reset","Auto Close","Count Up","Disable Use");
	self:CreateWireOutputs("End", "Close Stargate","Minutes","Seconds");

	self.Count = true;
	self.Minutes = 0;
	self.Seconds = 0;
	self.MiliSeconds = 0;

	self.WireCount = 0;
	self.WireMinutes = 0;
	self.WireSeconds = 0;
	self.WireReset = false;
	self.WirePause = false;

	self.AutoStart = false;
	self.AutoStop = false;
	self.AutoClose = false;
	self.CountUp = false;
end

util.AddNetworkString("CAP.DestinyTimer");

function ENT:Use(ply)
	if (self:GetWire("Disable Use")>=1) then return end

	net.Start("CAP.DestinyTimer");
	net.WriteEntity(self);
	net.WriteInt(self.WireMinutes,16);
	net.WriteInt(self.WireSeconds,16);
	net.WriteBit(self.AutoStart);
	net.WriteBit(self.AutoStop);
	net.WriteBit(self.AutoClose);
	net.WriteBit(self.CountUp);
	net.WriteBit(self:GetNWBool("Font",false));
	net.Send(ply);
end

net.Receive("CAP.DestinyTimer",function(len,ply)
	local self = net.ReadEntity();
	if (not IsValid(self)) then return end
	if (self:GetWire("Disable Use")>=1) then return end
	local type = net.ReadInt(4);
	if (type==0) then
		local t = net.ReadInt(8);
		if (t==0) then
			self.WireMinutes = math.Clamp(net.ReadInt(8), 0, 59);
			self.WireReset = true;
		elseif (t==1) then
			self.WireSeconds = math.Clamp(net.ReadInt(8), 0, 59);
			self.WireReset = true;
		elseif (t==2) then
			self.AutoStart = util.tobool(net.ReadBit());
		elseif (t==3) then
			self.AutoStop = util.tobool(net.ReadBit());
		elseif (t==4) then
			self.AutoClose = util.tobool(net.ReadBit());
		elseif (t==5) then
			self.CountUp = util.tobool(net.ReadBit());
			self.WireReset = true;
		elseif(t==6) then
			self:SetNWBool("Font",util.tobool(net.ReadBit()));
		end
	elseif (type==1) then
		if (self.AutoStop) then
			local gate = self:FindGate(gate);
			if (IsValid(gate) and not gate.IsOpen) then
				ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"destimer_error\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
				return
			end
		end
		if (self.WireCount == 0 and self.Count) then
			self.WireCount = 1;
			self:EmitSound(self.Sounds.Start,500,math.random(90,110));
			self.WirePause = false;
		end
	elseif (type==2) then
		self.WireCount = 0;
		self.WirePause = true;
	elseif (type==3) then
		self.WireReset = true;
	elseif (type==4) then
		self:CloseGate();
	end
end)

function ENT:FindGate(gt)
	if (IsValid(gt)) then return gt end
	if (IsValid(self.LockedGate)) then return self.LockedGate; end
	local gate;
	local dist = 1024;
	local pos = self:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and v:GetClass() != "stargate_supergate" and (not IsValid(v.LockedDTimer) or v.LockedDTimer==self)) then
			local sg_dist = (pos - v:GetPos()):Length();
			if(dist >= sg_dist) then
				dist = sg_dist;
				gate = v;
			end
		end
	end
	return gate;
end

function ENT:CloseGate(gt)
	local gate = self:FindGate(gt);
	if (IsValid(gate)) then
		gate:AbortDialling();
	end
end

function ENT:Touch(ent)
	if not IsValid(self.LockedGate) then
		if (string.find(ent:GetClass(), "stargate")) then
			local gate = self:FindGate()
			if IsValid(gate) and gate==ent and not IsValid(gate.LockedDTimer) then
				self.LockedGate = gate;
				gate.LockedDTimer = self;
				local ed = EffectData()
 					ed:SetEntity( self )
 				util.Effect( "propspawn", ed, true, true )
			end
		end
	end
end

function ENT:OnRemove()
	if (IsValid(self.LockedGate)) then
		self.LockedGate.LockedDTimer = nil;
	end
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if (!tr.Hit) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("destiny_timer");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent;
end

-----------------------------------WIRE----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Count") then
		if (self.WireCount == 0 and self.Count) then
			self.WireCount = value;
			self:EmitSound(self.Sounds.Start,500,math.random(90,110));
			self.WirePause = false;
		end
	elseif (variable == "Pause") then self.WirePause = util.tobool(value);
	elseif (variable == "Reset") then self.WireReset = util.tobool(value);
	elseif (variable == "Minutes") then self.WireMinutes = math.Clamp(value, 0, 59);
	elseif (variable == "Seconds") then self.WireSeconds = math.Clamp(value, 0, 59);
	elseif (variable == "Auto Start") then self.AutoStart = util.tobool(value);
	elseif (variable == "Auto Reset") then self.AutoStop = util.tobool(value);
	elseif (variable == "Auto Close") then self.AutoClose = util.tobool(value);
	elseif (variable == "Count Up") then self.CountUp = util.tobool(value); self.WireReset = true;
	elseif (variable == "Normal Font") then self:SetNWBool("Font",util.tobool(value));
	end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	local NextThink = CurTime()+0.1;
	local gate

	if (self.WireReset) then
		self.WireReset = false;
		self.WirePause = false;
		self.Count = true;
		self.WireCount = 0;

		self:SetWire("End",0);

		if (self.CountUp) then
			self.MiliSeconds = 9;
			self.Seconds = 0;
			self.Minutes = 0;
		else
			self.MiliSeconds = 0;
			self.Seconds = self.WireSeconds;
			self.Minutes = self.WireMinutes;
		end

		self:SetWire("Seconds",self.Seconds);
		self:SetWire("Minutes",self.Minutes);

		local time = self.Minutes*60 + self.Seconds;
		self.Entity:SetNetworkedInt("time",time);

		local maxtime = self.WireMinutes*60 + self.WireSeconds;
		if (self.CountUp) then
			self.Entity:SetNWInt("maxtime",maxtime);
		else
			self.Entity:SetNWInt("maxtime",0);
		end
	elseif (self.Count and self.WireCount == 0 and self.AutoStart and not self.WirePause) then
		gate = self:FindGate(gate);
		if (IsValid(gate) and gate.IsOpen) then
        	self.WireCount = 1;
        	self:EmitSound(self.Sounds.Start,500,math.random(90,110));
		end
	end

	if (self.WireCount == 0 and self.Count) then
		if (self.Minutes == 0 and self.Seconds == 0 and not self.CountUp) then
			self.Seconds = self.WireSeconds;
			self.Minutes = self.WireMinutes;

			self:SetWire("Seconds",self.Seconds);
			self:SetWire("Minutes",self.Minutes);

			local time = self.Minutes*60 + self.Seconds;
			self.Entity:SetNWInt("time",time)
		/*elseif (self.Minutes == 60 and self.Seconds == 60 and self.CountUp) then
			self.Seconds = 0;
			self.Minutes = 0;

			self:SetWire("Seconds",self.Seconds);
			self:SetWire("Minutes",self.Minutes);

			local time = self.Minutes*60 + self.Seconds;
			self.Entity:SetNWInt("time",time)*/
		end
	end

	if (self.AutoStop) then
		gate = self:FindGate(gate);
		if (IsValid(gate) and not gate.IsOpen) then
			self.WireReset = true;
		end
	end

	if (self.WireCount == 1 and self.Count and not self.WirePause) then
		self.MiliSeconds = self.MiliSeconds - 1;
		if (self.MiliSeconds == -1) then
			if (self.CountUp) then
				self.Seconds = self.Seconds + 1;
			else
				self.Seconds = self.Seconds - 1;
			end

			-- damn madman, this was your bug, wire gets -1 instead 59...
			if (self.Seconds==60) then
				self:SetWire("Seconds",0);
				self:SetWire("Minutes",self.Minutes+1);
			elseif(self.Seconds==-1) then
				self:SetWire("Seconds",59);
				self:SetWire("Minutes",self.Minutes-1);
			else
				self:SetWire("Seconds",self.Seconds);
				self:SetWire("Minutes",self.Minutes);
			end

			local time = self.Minutes*60 + self.Seconds;
			local maxtime = self.WireMinutes*60 + self.WireSeconds;
			self.Entity:SetNWInt("time",time)
			if (self.CountUp) then
				self.Entity:SetNWInt("maxtime",maxtime)
			else
				self.Entity:SetNWInt("maxtime",0)
			end

			if (self.Seconds == -1 or self.CountUp and (self.Seconds==60 or time>=maxtime)) then
				if (self.CountUp) then
					self.Minutes = self.Minutes + 1;
				else
					self.Minutes = self.Minutes - 1;
				end
				if (self.Minutes == -1 or self.CountUp and (self.Minutes==60 or time>=maxtime)) then
					self.Seconds = 0;
					self.Minutes = 0;
					self.MiliSeconds = 0;
					self.WireCount = 0;
					self.Count = false;

					self:SetWire("End",1);
					self:SetWire("Close Stargate",1);
					if (self.AutoClose) then self:CloseGate(gate); end

					if (self.CountUp) then
						self:SetWire("Seconds",self.WireSeconds);
						self:SetWire("Minutes",self.WireMinutes);
						self.Entity:SetNWInt("time",maxtime);
					else
						self:SetWire("Seconds",0);
						self:SetWire("Minutes",0);
						self.Entity:SetNWInt("time",0);
					end

					timer.Simple(0.1, function() if (IsValid(self)) then self:SetWire("Close Stargate",0); end end);
					self:EmitSound(self.Sounds.Stop,500,math.random(90,110));
				else
					if (self.CountUp) then
						self.Seconds = 0;
					else
						self.Seconds = 59;
					end
					self.MiliSeconds = 9;
				end
			else
				self.MiliSeconds = 9;
			end
		end
	end

	self.Entity:NextThink(NextThink)
	return true
end

function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	dupeInfo.Minutes = self.WireMinutes;
	dupeInfo.Seconds = self.WireSeconds;
	dupeInfo.AutoStart = self.AutoStart;
	dupeInfo.AutoStop = self.AutoStop;
	dupeInfo.AutoClose = self.AutoClose;
	dupeInfo.CountUp = self.CountUp;
	dupeInfo.Font = self:GetNWBool("Font",false);

	if (IsValid(self.LockedGate)) then
		dupeInfo.LockedGate = self.LockedGate:EntIndex();
	end

	duplicator.StoreEntityModifier(self, "TimerDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "TimerDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.TimerDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.TimerDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.TimerDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	self.WireMinutes = dupeInfo.Minutes;
	self.WireSeconds = dupeInfo.Seconds;
	self.AutoStart = dupeInfo.AutoStart;
	self.AutoStop = dupeInfo.AutoStop;
	self.AutoClose = dupeInfo.AutoClose;
	self.CountUp = dupeInfo.CountUp;
	self:SetNWBool("Font",dupeInfo.Font or false);

	if (dupeInfo.LockedGate and CreatedEntities[dupeInfo.LockedGate]) then
		self.LockedGate = CreatedEntities[dupeInfo.LockedGate];
		CreatedEntities[dupeInfo.LockedGate].LockedDTimer = self.Entity;
	end

	self.WireReset = true;

	self.Owner = ply;
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "destiny_timer", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

local font = {
	font = "Anquietas",
	size = 70,
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("AncientsT", font);

local font = {
	font = "quiver",
	size = 90,
	weight = 400,
	antialias = true,
	additive = true,
}
surface.CreateFont("DigitalTimer", font)

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_dest_timer");
end

function ENT:Draw()

	self.Entity:DrawModel();

	local pos = self.Entity:GetPos() + self.Entity:GetUp()*2.5 - self.Entity:GetForward()*2;
	local ang = self.Entity:GetAngles();
	ang:RotateAroundAxis(ang:Up(), -90);
	ang:RotateAroundAxis(ang:Up(), 180);

	local Time = self.Entity:GetNetworkedInt("time",0);
	local maxtime = self.Entity:GetNetworkedInt("maxtime",0);

	local Col = Color(200,230,255,255);
	if (Time < 11 and maxtime==0) then Col = Color(225,50,50,255)
	elseif (maxtime!=0 and Time>maxtime-11) then Col = Color(225,50,50,255) end

	local TimeStr = string.ToMinutesSeconds(Time);
	--surface.SetFont("AncientsT");

	local font = "AncientsT";
	if (self:GetNWBool("Font",false)) then
		font = "DigitalTimer"
		pos = self.Entity:GetPos() + self.Entity:GetUp()*2.5 - self.Entity:GetForward()*3.2;
	end

	cam.Start3D2D(pos, ang, 0.07 );
		draw.DrawText(TimeStr, font, 0, 0, Col, TEXT_ALIGN_CENTER );
	cam.End3D2D();

end

net.Receive("CAP.DestinyTimer",function(len)
	local ent = net.ReadEntity();
	if (not IsValid(ent)) then return end
	local val_min = net.ReadInt(16);
	local val_sec = net.ReadInt(16);
	local val_start = util.tobool(net.ReadBit());
	local val_stop = util.tobool(net.ReadBit());
	local val_close = util.tobool(net.ReadBit());
	local val_countup = util.tobool(net.ReadBit());
	local val_font = util.tobool(net.ReadBit());

	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetSize(300, 160)
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

 	local image = vgui.Create("DImage" , DermaPanel);
    image:SetSize(16, 16);
    image:SetPos(5, 5);
    image:SetImage("gui/cap_logo");

  	local title = vgui.Create( "DLabel", DermaPanel );
 	title:SetText(SGLanguage.GetMessage("destimer_title"));
  	title:SetPos( 25, 0 );
 	title:SetSize( 400, 25 );

  	local title = vgui.Create( "DLabel", DermaPanel );
 	title:SetText(SGLanguage.GetMessage("destimer_time"));
  	title:SetPos( 10, 32 );
 	title:SizeToContents();

	local minwang = vgui.Create( "DNumberWang", DermaPanel );
	minwang:SetPos(65,30);
	minwang:SetSize(30,20);
	minwang:SetMinMax(0,59);
	minwang:SetDecimals(0);
	minwang:SetValue(val_min);
	minwang.OnValueChanged = function( self, val )
		if (tonumber(val)>self.m_numMax) then
			self:SetText(self.m_numMax)
		elseif (tonumber(val)<self.m_numMin) then
			self:SetText(self.m_numMin)
		end
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(0,4);
		net.WriteInt(0,8);
		net.WriteInt(math.Clamp(tonumber(val),0,59),8);
		net.SendToServer();
	end

	local secwang = vgui.Create( "DNumberWang", DermaPanel );
	secwang:SetPos(100,30);
	secwang:SetSize(30,20);
	secwang:SetMinMax(0,59);
	secwang:SetDecimals(0);
	secwang:SetValue(val_sec);
	secwang.OnValueChanged = function( self, val )
		if (tonumber(val)>self.m_numMax) then
			self:SetText(self.m_numMax)
		elseif (tonumber(val)<self.m_numMin) then
			self:SetText(self.m_numMin)
		end
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(0,4);
		net.WriteInt(1,8);
		net.WriteInt(math.Clamp(tonumber(val),0,59),8);
		net.SendToServer();
	end

	local autostart = vgui.Create("DCheckBoxLabel" , DermaPanel )
	autostart:SetText(SGLanguage.GetMessage("destimer_autostart"))
	autostart:SizeToContents()
	autostart:SetPos(10, 55)
	autostart:SetValue( autocloseval )
	autostart:SizeToContents()
	autostart:SetTooltip(SGLanguage.GetMessage("destimer_autostart_desc"))
	autostart:SetChecked(val_start)
	autostart.OnChange = function(self,val)
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(0,4);
		net.WriteInt(2,8);
		net.WriteBit(val);
		net.SendToServer();
	end

	local autostop = vgui.Create("DCheckBoxLabel" , DermaPanel )
	autostop:SetText(SGLanguage.GetMessage("destimer_autostop"))
	autostop:SizeToContents()
	autostop:SetPos(10, 75)
	autostop:SetValue( autocloseval )
	autostop:SizeToContents()
	autostop:SetTooltip(SGLanguage.GetMessage("destimer_autostop_desc"))
	autostop:SetChecked(val_stop)
	autostop.OnChange = function(self,val)
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(0,4);
		net.WriteInt(3,8);
		net.WriteBit(val);
		net.SendToServer();
	end

	local autoclose = vgui.Create("DCheckBoxLabel" , DermaPanel )
	autoclose:SetText(SGLanguage.GetMessage("destimer_autoclose"))
	autoclose:SizeToContents()
	autoclose:SetPos(10, 95)
	autoclose:SetValue( autocloseval )
	autoclose:SizeToContents()
	autoclose:SetTooltip(SGLanguage.GetMessage("destimer_autoclose_desc"))
	autoclose:SetChecked(val_close)
	autoclose.OnChange = function(self,val)
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(0,4);
		net.WriteInt(4,8);
		net.WriteBit(val);
		net.SendToServer();
	end

	local countup = vgui.Create("DCheckBoxLabel" , DermaPanel )
	countup:SetText(SGLanguage.GetMessage("destimer_countup"))
	countup:SizeToContents()
	countup:SetPos(10, 115)
	countup:SetValue( autocloseval )
	countup:SizeToContents()
	countup:SetTooltip(SGLanguage.GetMessage("destimer_countup_desc"))
	countup:SetChecked(val_countup)
	countup.OnChange = function(self,val)
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(0,4);
		net.WriteInt(5,8);
		net.WriteBit(val);
		net.SendToServer();
	end

	local font = vgui.Create("DCheckBoxLabel" , DermaPanel )
	font:SetText(SGLanguage.GetMessage("destimer_font"))
	font:SizeToContents()
	font:SetPos(10, 135)
	font:SetValue( autocloseval )
	font:SizeToContents()
	font:SetTooltip(SGLanguage.GetMessage("destimer_font_desc"))
	font:SetChecked(val_font)
	font.OnChange = function(self,val)
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(0,4);
		net.WriteInt(6,8);
		net.WriteBit(val);
		net.SendToServer();
	end

	local startButton = vgui.Create("DButton" , DermaPanel )
	startButton:SetParent( DermaPanel )
	startButton:SetText(SGLanguage.GetMessage("destimer_start"))
	startButton:SetPos(160, 34)
	startButton:SetSize(130, 25)
	startButton.DoClick = function ( btn )
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(1,4);
		net.SendToServer();
	end

	local stopButton = vgui.Create("DButton" , DermaPanel )
	stopButton:SetParent( DermaPanel )
	stopButton:SetText(SGLanguage.GetMessage("destimer_stop"))
	stopButton:SetPos(160, 64)
	stopButton:SetSize(130, 25)
	stopButton.DoClick = function ( btn )
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(2,4);
		net.SendToServer();
	end

	local resetButton = vgui.Create("DButton" , DermaPanel )
	resetButton:SetParent( DermaPanel )
	resetButton:SetText(SGLanguage.GetMessage("destimer_reset"))
	resetButton:SetPos(160, 94)
	resetButton:SetSize(130, 25)
	resetButton.DoClick = function ( btn )
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(3,4);
		net.SendToServer();
	end

	local closeButton = vgui.Create("DButton" , DermaPanel )
	closeButton:SetParent( DermaPanel )
	closeButton:SetText(SGLanguage.GetMessage("destimer_close"))
	closeButton:SetPos(160, 124)
	closeButton:SetSize(130, 25)
	closeButton.DoClick = function ( btn )
		net.Start("CAP.DestinyTimer");
		net.WriteEntity(ent);
		net.WriteInt(4,4);
		net.SendToServer();
	end
end)

end