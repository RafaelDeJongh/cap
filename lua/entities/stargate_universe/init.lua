/*
	Stargate Universe for GarrysMod10
	Copyright (C) 2011  Llapp
	Edited by AlexALX
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
include("modules/dialling.lua");
include("modules/wire_dial.lua");

ENT.Models = {
	Base="models/The_Sniper_9/Universe/Stargate/universegate.mdl",
	Ring="models/Iziraider/ring/ring.mdl",
    Chevrons="models/The_Sniper_9/Universe/Stargate/universechevrons.mdl",
	Symbol="models/The_Sniper_9/Universe/Stargate/symbolon.mdl",
}
ENT.Sounds = {
	Open=Sound("stargate/universe/gate_open.mp3"),
	Travel=Sound("stargate/gate_travel.mp3"),
	Close=Sound("stargate/universe/gate_close.mp3"),
	ChevronDHD=Sound("stargate/universe/chevron.mp3"),
	Inbound=Sound("stargate/universe/chevron.mp3");
	Lock=Sound("stargate/universe/chevron_lock.mp3"),
	LockDHD=Sound("stargate/universe/chevron.mp3"),
	Chevron=Sound("stargate/universe/chevlocked.wav"),
	Fail=Sound("stargate/universe/fail3.wav"),
	Activate=Sound("stargate/universe/Stargate Begin Roll.mp3"),
	GateRoll=Sound("stargate/universe/Long_Gate_Roll.wav"),
	StopRoll=Sound("stargate/universe/Chevron2.mp3"),
    EndRoll=Sound("stargate/universe/endroll.mp3"),
}

ENT.Mats = {
  Off="The_Sniper_9/Universe/Stargate/UniverseChevronOff.vmt",
  On="The_Sniper_9/Universe/Stargate/UniverseChevronOn.vmt",
}

ENT.MatsSymb = {
  Off="the_sniper_9/universe/stargate/symbols.vmt",
  On="the_sniper_9/universe/stargate/symbolson.vmt",
  ColOff=Color(70,70,70),
}

--################# Added by AlexALX

ENT.SymbolsLockGroup = {
	Z = {8, 1},
	B = {16, 2},
	[9] = {24, 3},
	J = {32, 4},
	Q = {48, 6},
	N = {56, 7},
	L = {64, 8},
	M = {72, 9},
	V = {88, 11},
	K = {96, 12},
	O = {104, 13},
	[6] = {112, 14},
	D = {128, 16},
	C = {136, 17},
	W = {144, 18},
	Y = {152, 19},
	["#"] = {168, 21},
	R = {176, 22},
	["@"] = {184, 23},
	S = {192, 24},
	[8] = {208, 26},
	A = {216, 27},
	P = {224, 28},
	U = {232, 29},
	T = {248, 31},
	[7] = {256, 32},
	H = {264, 33},
	[5] = {272, 34},
	[4] = {288, 36},
	I = {296, 37},
	G = {304, 38},
	[0] = {312, 39},
	[1] = {328, 41},
	[2] = {336, 42},
	E = {344, 43},
	[3] = {352, 44},

	-- not visible on model
	F = {80, 10},
	X = {280, 35},
}

ENT.SymbolsLockGalaxy = {
	Z = {8, 1},
	B = {16, 2},
	[9] = {24, 3},
	J = {32, 4},
	Q = {48, 6},
	N = {56, 7},
	L = {64, 8},
	M = {72, 9},
	V = {88, 11},
	K = {96, 12},
	O = {104, 13},
	[6] = {112, 14},
	D = {128, 16},
	C = {136, 17},
	W = {144, 18},
	Y = {152, 19},
	["#"] = {168, 21},
	R = {176, 22},
	["@"] = {184, 23},
	S = {192, 24},
	[8] = {208, 26},
	A = {216, 27},
	P = {224, 28},
	U = {232, 29},
	T = {248, 31},
	[7] = {256, 32},
	H = {264, 33},
	[5] = {272, 34},
	[4] = {288, 36},
	I = {296, 37},
	G = {304, 38},
	["!"] = {312, 39},
	[1] = {328, 41},
	[2] = {336, 42},
	E = {344, 43},
	[3] = {352, 44},

	-- not visible on model
	F = {80, 10},
	X = {280, 35},
}

--################# SENT CODE ###############

function ENT:Initialize()
	self.Entity:SetModel(self.Models.Base);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA);
	self.Entity:SetColor(Color(0,0,0,1)); --this make the entity invisible but alpha must be 1 for dynamic lights!
	self.DeriveIgnoreParent = true
	self.BaseClass.Initialize(self); -- BaseClass Initialize call
	self:AddModels();
	self.Speed = false;
	self:AddSymbols();
	self.InboundSymbols = 0;
	self.SpinSpeed = 0;
	self.Stop = false;
	self.PlaySp = false;
	self.Speroll = 0;
	self.DiallingSymbol = "";
	self.RingSymbol = "";
	self.SpinBack = false;
	self.StopRollSP = false;
	self.WireSpin = false;
	self.WireSpinSpeed = false;
	self.ActSymSound = false;
	self.WireSpinDir = false;
	hook.Add("Tick", self, self.RingTickUniverse);	
end

--#################  Called when stargate_group_system changed
function ENT:ChangeSystemType(groupsystem,reload)
	local delay = 4.5
	if (reload) then delay = 2.5 end
	if (groupsystem) then
		if (self.GateSpawnerSpawned) then
			timer.Simple(delay, function()
				if (IsValid(self)) then
					self:GateWireInputs(groupsystem);
				end
			end)
			timer.Simple(2, function()
				if (IsValid(self)) then
					self:GateWireOutputs(groupsystem);
					self:SetWire("Dialing Mode",-1);
					self:SetChevrons(0,0);
				end
			end)
		else
			self:GateWireInputs(groupsystem);
			self:GateWireOutputs(groupsystem);
			self:SetWire("Dialing Mode",-1);
			self:SetChevrons(0,0);
		end
		self.SymbolsLock = self.SymbolsLockGroup;
		self.WireCharters = "A-Z0-9@#";
	else
		if (self.GateSpawnerSpawned) then
			timer.Simple(delay, function()
				if (IsValid(self)) then
					self:GateWireInputs(groupsystem);
				end
			end)
			timer.Simple(2, function()
				if (IsValid(self)) then
					self:GateWireOutputs(groupsystem);
					self:SetWire("Dialing Mode",-1);
					self:SetChevrons(0,0);
				end
			end)
		else
			self:GateWireInputs(groupsystem);
			self:GateWireOutputs(groupsystem);
			self:SetWire("Dialing Mode",-1);
			self:SetChevrons(0,0);
		end
		self.SymbolsLock = self.SymbolsLockGalaxy;
		self.WireCharters = "A-Z1-9@#!";
		if (self:GetGateAddress():find("[0]")) then self:SetGateAddress("");
		elseif (self:GetGateAddress()!="") then
			for _,v in pairs(ents.FindByClass("stargate_*")) do
				if (self.Entity != v.Entity and v.IsStargate and v:GetClass()!="stargate_supergate" and v:GetGateAddress()!="") then
					local address, a = self:GetGateAddress(), string.Explode("",v:GetGateAddress());
					if (address:find(a[1]) and address:find(a[2]) and address:find(a[3]) and address:find(a[4]) and address:find(a[5]) and address:find(a[6])) then self:SetGateAddress(""); end
				end
			end
		end
	end
	if (reload) then
		StarGate.ReloadSystem(groupsystem);
	end
end

function ENT:GateWireInputs(groupsystem)
	self:CreateWireInputs("Dial Address","Dial String [STRING]","Dial Mode","Start String Dial","Close","Disable Autoclose","Transmit [STRING]","Rotate Ring","Ring Speed Mode","Encode Symbol","Symbols Lock","Force Encode Symbol [STRING]","Force Lock Symbol [STRING]","Inbound Symbols","Activate Chevrons","Activate All Symbols","Activate Symbols [STRING]","Activate Symbols Sound","Disable Menu","Event Horizon Type [STRING]","Event Horizon Color [VECTOR]");
end

function ENT:GateWireOutputs(groupsystem)
	self:CreateWireOutputs("Active","Open","Inbound","Chevron","Chevron Locked","Ring Symbol [STRING]","Ring Rotation","Dialing Address [STRING]","Dialing Mode","Dialing Symbol [STRING]","Dialed Symbol [STRING]","Received [STRING]");
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	local pos = t.HitPos+Vector(0,0,90);
	local e = ents.Create("stargate_universe");
	e:SetPos(pos);
	e:DrawShadow(false);
    e:Spawn();
	e:Activate();
	e:SetAngles(ang);
	e:SetGateGroup("U@#");
	e:SetLocale(true);
	e:CartersRamps(t); -- put gate on carters ramps
	e:SetWire("Dialing Mode",-1);
	return e;
end

function ENT:AddModels()
	local pos = self.Entity:GetPos();
	local e2 = ents.Create("prop_dynamic_override");
	e2:SetModel(self.Models.Base);
    e2:SetKeyValue("solid",0);
	e2:SetPos(pos);
	e2:SetParent(self.Entity);
	e2:DrawShadow(true);
	e2:SetDerive(self)
	e2:Spawn();
	e2:Activate();
	self.Gate = e2;
	self.Gate.Entity = e2;
	self.Gate.Moving = false;
	self:SetNWEntity("EntRing",e2)
	self.AngGate = self.Gate:GetAngles();
	local e3 = ents.Create("prop_dynamic_override");
	e3:SetModel(self.Models.Chevrons);
    e3:SetKeyValue("solid",0);
	e3:SetPos(pos);
	e3:SetParent(self.Gate);
	e3:DrawShadow(true);
	e3:SetDerive(self)
	e3:Spawn();
	e3:Activate();
	self.Chevron = e3;
	return e2;
end

function ENT:AddSymbols()
	self.Symbols={};
	self.ColR={};
	self.ColG={};
	self.ColB={};
	self.ColA={};
	local pos = self.Gate:GetPos() + self.Gate:GetForward()*0.05;
	local angForw = self.Gate:GetAngles():Up();
	local ang = self.Gate:GetAngles();
	for i=1,45 do
		local e = ents.Create("prop_dynamic_override");
		e:SetModel(self.Models.Symbol);
		e:SetKeyValue("solid",0);
		e:SetParent(self.Gate);
		e:SetMaterial(self.MatsSymb.Off)
		--e:SetDerive(self.Gate); -- Derive Material/Color from "Parent"
		e:DrawShadow(false);
		e:SetDerive(self)
		e:SetPos(pos);
		local a = angForw*(i*8);
		e:SetAngles(ang-Angle(a[1],a[2],a[3]));
		e:Spawn();
		e:Activate();
        self.Symbols[i] = e;
		local color = e:GetColor();
		self.ColR[i] = color.r;
		self.ColG[i] = color.g;
		self.ColB[i] = color.b;
		self.ColA[i] = color.a;
		e:SetColor(self.MatsSymb.ColOff);
	end
end

function ENT:DeriveOnSetColor(color)
	self.BaseClass.DeriveOnSetColor(self,color)
	if (not self.Chevron) then return end
	local coloff = self.MatsSymb.ColOff
	local colon = Color(255,255,255)
	if (self.Chevron:GetColor()!=Color(255,255,255)) then
		coloff = self.Chevron:GetColor()
		colon = self.Chevron:GetColor()
		coloff.r = coloff.r*(self.MatsSymb.ColOff.r/255)
		coloff.g = coloff.g*(self.MatsSymb.ColOff.r/255)
		coloff.b = coloff.b*(self.MatsSymb.ColOff.r/255)
	end
	
	for i=1,45 do
		local On = self.Symbols[i]:GetMaterial()==self.MatsSymb.On
		if (On) then
			self.Symbols[i]:SetColor(colon);
		else
			self.Symbols[i]:SetColor(coloff);
		end
	end
end

--############### Change the Universe Symbol Skin
function ENT:ChangeSkin(skin,inbound,symbol)
    if(skin)then
	    if(IsValid(self.Entity))then
		    if(skin > 1 and symbol and symbol!="" and (not inbound or self.InboundSymbols==1))then
			    local i = self.SymbolsLock[tonumber(symbol) or symbol][2]; --self.SymbolPositions[skin-1];
    			--self.Symbols[i]:SetColor(Color(self.ColR[i],self.ColG[i],self.ColB[i],self.ColA[i]));
				local col = Color(255,255,255) 
				if (self.Chevron:GetColor()!=Color(255,255,255)) then
					col = self.Chevron:GetColor()
				end
				self.Symbols[i]:SetColor(col)
				self.Symbols[i]:SetMaterial(self.MatsSymb.On);
			elseif(skin == 0)then
			    for i=1,45 do
				    local c = self.Symbols[i]:GetColor();
					local col = self.MatsSymb.ColOff 
					if (self.Chevron:GetColor()!=Color(255,255,255)) then
						col = self.Chevron:GetColor()
						col.r = col.r*(self.MatsSymb.ColOff.r/255)
						col.g = col.g*(self.MatsSymb.ColOff.r/255)
						col.b = col.b*(self.MatsSymb.ColOff.r/255)
					end
				    if(self.ColA[i] == c.a)then
				        --self.Symbols[i]:SetColor(self.MatsSymb.ColOff);
						self.Symbols[i]:SetColor(col)
						self.Symbols[i]:SetMaterial(self.MatsSymb.Off);
                    end
				end
				self.Chevron:SetMaterial(self.Mats.Off);
			elseif(skin == 1)then
			    self.Chevron:SetMaterial(self.Mats.On);
			end
		end
	end
end

--############# Activate/Deactivate all symbols by AlexALX
function ENT:ActivateSymbols(deactivate,syms)
	if (not IsValid(self.Entity)) then return end
	if (syms and syms!="") then
		local s = syms:gsub("[^"..self.WireCharters.."]",""):TrimExplode("")
		for i=1,45 do
			self.Symbols[i]:SetColor(self.MatsSymb.ColOff);
			self.Symbols[i]:SetMaterial(self.MatsSymb.Off);
		end
		local s2 = "";
		
		local col = Color(255,255,255) --Color(self.ColR[i],self.ColG[i],self.ColB[i],self.ColA[i])
		if (self.Chevron:GetColor()!=Color(255,255,255)) then
			col = self.Chevron:GetColor()
		end
		
		for k,v in pairs(s) do
			if (s2:find(v)) then continue end
		    local i = self.SymbolsLock[tonumber(v) or v][2]; --self.SymbolPositions[skin-1];
    		self.Symbols[i]:SetColor(col);
			self.Symbols[i]:SetMaterial(self.MatsSymb.On);
    		s2 = s2..v;
		end
		if (self.ActSymSound and table.Count(s)>0) then
			self:ChevronSound(1);
		end
	else
		if (not deactivate) then
			local col = Color(255,255,255) --Color(self.ColR[i],self.ColG[i],self.ColB[i],self.ColA[i])
			if (self.Chevron:GetColor()!=Color(255,255,255)) then
				col = self.Chevron:GetColor()
			end
		
			for i=1,45 do
				self.Symbols[i]:SetColor(col);
				self.Symbols[i]:SetMaterial(self.MatsSymb.On);
			end
		else
			local col = self.MatsSymb.ColOff
			if (self.Chevron:GetColor()!=Color(255,255,255)) then
				col = self.Chevron:GetColor()
				col.r = col.r*(self.MatsSymb.ColOff.r/255)
				col.g = col.g*(self.MatsSymb.ColOff.r/255)
				col.b = col.b*(self.MatsSymb.ColOff.r/255)
			end
		
			for i=1,45 do
			    self.Symbols[i]:SetColor(col);
				self.Symbols[i]:SetMaterial(self.MatsSymb.Off);
			end
		end
	end
end

--############# Activate Sound
function ENT:ActivateGateSound()
    util.PrecacheSound(self.Sounds.Activate)
	self.ActivateSound = CreateSound(self.Entity,self.Sounds.Activate);
	self.ActivateSound:ChangePitch(95,0);
	self.ActivateSound:SetSoundLevel(94);
	self.ActivateSound:PlayEx(1,97);
end

function ENT:StopRollSound()
    util.PrecacheSound(self.Sounds.StopRoll)
    self.StopRollSP = true;
	self.StopRollS = CreateSound(self.Entity,self.Sounds.StopRoll);
	self.StopRollS:ChangePitch(95,0);
	self.StopRollS:SetSoundLevel(94);
	self.StopRollS:PlayEx(1,107);
end

--############# stop at started position
function ENT:StopAtStartPos()
	self.Stop = true;
end

function ENT:SetStop(stop)
	self.Stop = stop;
end

function ENT:SpinSound(spin)
    if(spin)then
	    util.PrecacheSound(self.Sounds.GateRoll)
        self.RollSound = CreateSound(self.Entity,self.Sounds.GateRoll);
	    self.RollSound:ChangePitch(95,0);
	    self.RollSound:SetSoundLevel(99);
	    self.RollSound:PlayEx(1,85);
	    self.StopRollSP = false;
	else
        if(self.RollSound)then
		    self.RollSound:Stop();
		end
	end
end

--############# let the gate rotate with acc/decc @llapp
-- total recode by AlexALX, making it undepent to server tickrate/fps
function ENT:Rotation(sse)
    local spr = self.Speroll;
	local e = self.Entity;
	local g = self.Gate;
	if not IsValid(g) or self.SpinSpeed==0 then return end
	local mul = 66 / (1/FrameTime())
	if (mul<1) then mul = 1 end
	local speed,sspeed,sspeed2 = 1*mul,0.02*mul,0.18*mul
	if (self.WireSpin and not self.WireSpinSpeed) then speed,sspeed,sspeed2 = 0.5*mul,0.01*mul,0.09*mul end
	if (sse == 1 and spr < speed) then
		spr = math.Clamp(spr+speed,spr,spr+sspeed*mul)
	elseif (sse == 2 and spr > sspeed) then
		spr = math.Clamp(spr-speed,spr-sspeed*mul,spr)
	elseif (sse == -1 and spr > -speed) then
		spr = math.Clamp(spr-speed,spr-sspeed*mul,spr)
	elseif (sse == -2 and spr < -sspeed) then
		spr = math.Clamp(spr+speed,spr,spr+sspeed*mul)
	end
	if(((spr >= sspeed and spr <= sspeed2) or (spr <= -sspeed and spr >= -sspeed2)) and (sse == 2 or sse == -2))then
	    self:SpinSound(false);
	    self.Entity:SetWire("Ring Rotation",0);
		self:StopRollSound();
		--[[if (not timer.Exists("SGUniRotFix"..self:EntIndex())) then
			timer.Create("SGUniRotFix"..self:EntIndex(),0.4,1,function() 
				self.SpinSpeed = 0;
				self.WireSpin = false; 
			end)
		end    ]]
	elseif(spr > 0 and spr < sspeed or spr < 0 and spr > -sspeed) then
		--timer.Remove("SGUniRotFix"..self:EntIndex())
   	    spr = 0;
   		self.SpinSpeed = 0;
		self.WireSpin = false; -- fix for manual spin rotation bug
		--self.Speed = 0;
		/*local y = tonumber(math.NormalizeAngle(self.Gate.Entity:GetLocalAngles().r));
		if (y<0) then y = y+360; end;
		print(y)*/
   	end
	self.Speroll = spr;
   	if(spr ~= 0)then
        g:SetParent(nil);
        g:SetAngles(g:GetAngles() + Angle(0,0,spr));
        g:SetParent(e);
   	end
	if (self.Stop and spr >= speed) then
		local y = tonumber(math.NormalizeAngle(self.Gate.Entity:GetLocalAngles().r));
		--if (y<0) then y = y+360 end
		local ys = 25
		if (y>-ys and y<0) then
			self:SetSpeed(false);
		end
	end
	
	if(spr == 0 and self.Stop)then
	    g:SetAngles(e:GetAngles());
	    self.Stop = false;
	    if(self.PlaySp)then
	    	self.PlaySp = false;
	    end
	end
end

function ENT:Think()
	if (not IsValid(self)) then return false end;
    self:Rotation(self.SpinSpeed);
    self:UpdateEntity();
	self.Entity:NextThink(CurTime()+(1/66)); -- fix for tickrate >66, this is lua limitation due to float precision
	return true;
end

function ENT:UpdateEntity()
  self.Entity:__SetColor(Color(0,0,0,1));
end

-- Damn, I spent the whole day and night for calculating this formula.
function ENT:StopFormula(y,x,n,n2)
	-- Adjusting ranges to actually be big enough so it works with the set Tickrate.
	local tickRateRelation = 66.666668156783 / (1 / engine.TickInterval())
	local inBetween = (n + n2) / 2
	local diff = (n - n2) * tickRateRelation
	n = inBetween + diff
	n2 = inBetween - diff

	if (y==nil or x==nil) then return end
	local stop = false;
	local b,c;
	if (self.SpinSpeed==1) then
		if (x<n) then
			b = 360-(n-x);
			if (x<n2) then
				c = 360-(n2-x);
				if (y >= b and y <= c) then stop = true; end
			else
				c = x-n2;
				if (y >= b and c <= y) then stop = true; end
			end
		else
			b = x-n;
			c = x-n2;
			if (y >= b and y <= c) then stop = true; end
		end
	elseif(self.SpinSpeed==-1) then
		local b
		if (x>=(360-n)) then
			b = (x+n)-360;
			if (x>=(360-n2)) then
				c = (x+n2)-360;
				if (y <= b and y >= c) then stop = true; end
			else
				c = x+n2;
				if (y <= b and c >= y) then stop = true; end
			end
		else
			b = x+n;
			c = x+n2;
			if (y <= b and y >= c) then stop = true; end
		end
	end
	return stop;
end

--################# Tick function added by AlexALX
function ENT:RingTickUniverse()
	--for _,self in pairs(ents.FindByClass("stargate_universe")) do
		if (IsValid(self.Gate)) then
			if ((self.Outbound or self.WireSpin) and self.Gate.Moving) then
				local y = tonumber(math.NormalizeAngle(self.Gate.Entity:GetLocalAngles().r));
				if (y<0) then y = y+360; end;
				local reset = true;
				local symbols = self.SymbolsLock;
				local so,so1,so2 = 12.125,1.5,0.8			
				if (self.WireSpinSpeed or not self.WireSpin) then
					so,so1,so2 = 24.5,1.5,1
				end
				local s1,s2 = so+so1,so-so1
				local s3,s4 = so+so2,so-so2
				for k, v in pairs(symbols) do
					local symbol = self:StopFormula(y,tonumber(self.SymbolsLock[tonumber(k) or k][1]),s1,s2);
					if (symbol) then
						self.Entity:SetWire("Ring Symbol",tostring(k)); -- Wire
						self.RingSymbol = tostring(k);
						reset = false;
					end
				end
				if (reset and self.RingSymbol != "") then
					self.Entity:SetWire("Ring Symbol",""); -- Wire
					self.RingSymbol = "";
				end
				local nsym = self.DiallingSymbol;
				local lock = false;
				local encode = false;
				if (self.WireEncodeSymbol!="") then nsym = self.WireEncodeSymbol; encode = true; end
				if (self.WireLockSymbol!="") then nsym = self.WireLockSymbol; lock = true; end
				if (nsym != "") then
					if (self.SymbolsLock[tonumber(nsym) or nsym]==nil) then self:AbortDialling(); self.Gate.Moving = false; else
						local x = tonumber(self.SymbolsLock[tonumber(nsym) or nsym][1]);
						if (self:StopFormula(y,x,s3,s4) and not self.Shutingdown) then
							if (encode or lock) then
								--print(y)
								self:TriggerInput("Rotate Ring",0);
								timer.Simple(1,function()
									if (IsValid(self)) then
										if (lock) then
											self.Entity:Chevron7Lock();
										else
											self.Entity:EncodeChevron();
										end
									end
								end)
							else
								--print(y)
								self:SetSpeed(false);
								self.Entity:DHDSetAllBusy();
								self.Gate.Moving = false;
								self.Entity:PauseActions(true);
							end
						end
					end
				end
			end
		end
	--end
end
--hook.Add("Tick", "RingTick Universe", RingTickUniverse);

function ENT:SetDiallingSymbol(symbol)
	if (symbol) then
		self.DiallingSymbol = tostring(symbol);
	end
end

--############# Set gate direction
function ENT:SetSpeed(speed,speed2)
    self.Speed = speed;
    if(IsValid(self.Entity))then
        if(speed)then
	        if(speed2)then
				self.SpinSpeed = -1;
				self.Entity:SetWire("Ring Rotation",1);
		    else
				self.SpinSpeed = 1;
				self.Entity:SetWire("Ring Rotation",-1);
		    end
			self:SpinSound(true);
			self:SetWire("Ring Symbol","");
			timer.Create("RingTickDelay"..self.Entity:EntIndex(), 1.3, 1, function() if IsValid(self.Entity) then self:RingTickDelay() end end);
			--self.Gate.Moving = true;
        else
			if timer.Exists("RingTickDelay"..self.Entity:EntIndex()) then timer.Remove("RingTickDelay"..self.Entity:EntIndex()) end
		    if(self.SpinSpeed == -1)then
			    self.SpinSpeed = -2;
			elseif(self.SpinSpeed == 1)then
			    self.SpinSpeed = 2;
			end
			self.Gate.Moving = false;
			self.WireEncodeSymbol = "";
			self.WireLockSymbol = "";
			self.Entity:SetNWBool("ActRotRingL",false);
        end
	end
end

function ENT:RingTickDelay()
	if(IsValid(self.Entity) and IsValid(self.Gate.Entity))then
		self.Gate.Moving = true;
	end
end

--############# Activates or deactivates dynamic lights of chevrons
function ENT:ActivateLights(active)
    if(IsValid(self.Entity))then
        if(active) then
	        for i=1,18 do
		        self.Entity:SetNetworkedEntity( "GateLights", self.Gate );
		        self.Entity:SetNetworkedBool("chevron"..i,true);
	        end
	    else
	       for i=1,18 do
			    self.Entity:SetNetworkedEntity( "GateLights" );
			    self.Entity:SetNWBool("chevron"..i,false);
		    end
	    end
    end
end

--############# Fix the Spin Bugs
function ENT:FixSpin(number)
    self.Entity:SetNetworkedEntity( "SpinNumber", number );
end
function ENT:FixSpinOnChevron(bool)
    self.Entity:SetNetworkedEntity( "ChevronBool", bool );
end

--############# Activates/Deactivates the Steam effect
function ENT:Smoke(smoke)
    if(smoke)then
	    self.Entity:SetNWBool( "Smoke", true )
	else
	    self.Entity:SetNWBool( "Smoke", false )
	end
end

function ENT:SpinFailChecker(sb)
    if(sb)then
	    self.SpinBack = true;
	else
	    self.SpinBack = false;
	end
end

--############# Activates Sound and Steam
function ENT:StopWithSteam(fast,outbound,fail) -- muss noch verbessert werden!!!!
    local delay;
    if(outbound and not fast)then
    	delay = 3.5;
	else
	    if(fast and fail)then
	        delay = 2;
	    else
	        delay = 0;
	    end
	end
	timer.Simple( delay, function()
	    if(IsValid(self.Entity))then
	        self:Smoke(true);
		end
    end);
	timer.Simple( delay+3, function()
		if(IsValid(self.Entity))then
	        self:Smoke(false);
		end
    end);
end

--################# Chevron locking sound
function ENT:ChevronSound(chev)
	util.PrecacheSound(self.Sounds.Chevron)
    self.Entity:EmitSound(self.Sounds.Chevron,90,math.random(95,100));
end

--##############################################################################################################
--##############################################################################################################
--################################################  EVENT  #####################################################
--##############################################################################################################
--##############################################################################################################

--################# Wire input @aVoN
function ENT:TriggerInput(k,v,mobile,mdhd,ignore)
	self:TriggerInputDefault(k,v,mobile,mdhd);
	if(k == "Rotate Ring" and not self.Active and (not self.NewActive or self.WireManualDial) and (not self.WireBlock or ignore)) then
		if (v >= 1) then
			if (not self.WireSpin and (self:CheckEnergy(true,true) or self.WireManualDial)) then
				self.WireSpin = true;
				local dir
				if (v==2) then dir = true; elseif (v>=3) then dir = false; end
				if (dir==nil or dir!=self.WireSpinDir) then
					if (self.WireSpinDir) then
						self.WireSpinDir = false;
					else
						self.WireSpinDir = true;
					end
				end
				self:SetSpeed(true,self.WireSpinDir);
				self.WireBlock = true;
				if (timer.Exists("StarGate.Universe.WireBlock_"..self.Entity:EntIndex())) then
					timer.Remove("StarGate.Universe.WireBlock_"..self.Entity:EntIndex());
				end
				timer.Create("StarGate.Universe.WireBlock_"..self.Entity:EntIndex(), 0.1, 1, function ()
					if (IsValid(self.Entity)) then
						self.WireBlock = false;
					end
				end );
				self.Entity:SetNWBool("ActRotRingL",true);
			end
		elseif (self.WireSpin) then
			--self.WireSpin = false;
			self:SetSpeed(false);
			self.WireBlock = true;
			/*local y = tonumber(math.NormalizeAngle(self.Gate.Entity:GetLocalAngles().r));
			if (y<0) then y = y+360; end;
			print(y)*/
			if (timer.Exists("StarGate.Universe.WireBlock_"..self.Entity:EntIndex())) then
				timer.Remove("StarGate.Universe.WireBlock_"..self.Entity:EntIndex());
			end
			timer.Create("StarGate.Universe.WireBlock_"..self.Entity:EntIndex(), 1.0, 1, function ()
				if (IsValid(self.Entity)) then
					self.WireBlock = false;
				end
			end );
			self.Entity:SetNWBool("ActRotRingL",false);
		end
	elseif(k == "Ring Speed Mode" and IsValid(self.Gate) and not self.Active and (not self.NewActive or self.WireManualDial)) then
		if (v >= 1) then
			self.WireSpinSpeed = true;
			if (self.Speroll>0) then self.Speroll = self.Speroll*2 end
		else
			self.WireSpinSpeed = false;
			if (self.Speroll>0) then self.Speroll = self.Speroll/2 end
		end
	elseif(k == "Encode Symbol" and not self.Active and (not self.NewActive or self.WireManualDial) and not self.WireBlock and not self.WireSpin) then
		if (v >= 1) then
			self:EncodeChevron();
		end
	elseif(k == "Symbols Lock" and not self.Active and (not self.NewActive or self.WireManualDial) and not self.WireBlock and not self.WireSpin) then
		if (v >= 1) then
			self:Chevron7Lock();
		end
	elseif(k == "Inbound Symbols")then
		if (v == 1) then
	    	self.InboundSymbols = 1;
	    elseif (v >= 2) then
	    	self.InboundSymbols = 2;
	    else
			self.InboundSymbols = 0;
		end
		self.Entity:SetNWInt("ActSymsI",self.InboundSymbols);
	elseif(k == "Activate All Symbols" and not self.NewActive and not self.WireManualDial)then
		if (v >= 1 and self:CheckEnergy(true,true)) then
	    	self:ActivateSymbols();
	    	self.Entity:SetNWBool("ActSymsAL",true);
	    else
			self:ActivateSymbols(true);
			self.Entity:SetNWBool("ActSymsAL",false);
		end
	elseif(k == "Activate Symbols" and not self.NewActive and not self.WireManualDial)then
		if (v!="" and self:CheckEnergy(true,true)) then
	    	self:ActivateSymbols(false,v);
	    else
			self:ActivateSymbols(true);
		end
	elseif(k == "Activate Symbols Sound")then
		if (v>=1) then
	    	self.ActSymSound = true;
	    else
			self.ActSymSound = false;
		end
	elseif(k == "Activate Chevrons" and not self.NewActive and not self.WireManualDial)then
		if (v >= 1 and self:CheckEnergy(true,true)) then
			self.Entity:EmitSound(self.Sounds.Activate,90,math.random(95,100));
	    	self.Chevron:SetMaterial("The_Sniper_9/Universe/Stargate/UniverseChevronOn.vmt");
	    	self.Entity:SetNWBool("ActChevronsL",true);
	    else
			self.Chevron:SetMaterial("The_Sniper_9/Universe/Stargate/UniverseChevronOff.vmt");
			self.Entity:SetNWBool("ActChevronsL",false);
		end
	elseif(k == "Force Encode Symbol" and IsValid(self.Gate) and not self.Active and (not self.NewActive or self.WireManualDial) and not self.WireBlock and not self.WireSpin) then
		if (v != "" and v:len()==1 and not self.Gate.Moving) then
			if (self:GetWire("Chevron",0,true)==0) then
				self.WireManualDial = true;
				local action = self.Sequence:New();
				action = self.Sequence:SeqFirstActivation(t);
				self:RunActions(action);
				timer.Simple(1.4,function()
					if (IsValid(self)) then
						self:TriggerInput("Rotate Ring",1,mobile,mdhd,true);
						self.WireEncodeSymbol = v;
						self.Entity:SetWire("Dialing Symbol",v);
					end
				end)
			else
				self:TriggerInput("Rotate Ring",1,mobile,mdhd);
				self.WireEncodeSymbol = v;
				self.Entity:SetWire("Dialing Symbol",v);
			end
		end
	elseif(k == "Force Lock Symbol" and IsValid(self.Gate) and not self.Active and (not self.NewActive or self.WireManualDial) and not self.WireBlock and not self.WireSpin) then
		if (v != "" and v:len()==1 and not self.Gate.Moving) then
			if (self:GetWire("Chevron",0,true)==0) then
				self.WireManualDial = true;
				local action = self.Sequence:New();
				action = self.Sequence:SeqFirstActivation(t);
				self:RunActions(action);
				timer.Simple(1.4,function()
					if (IsValid(self)) then
						self:TriggerInput("Rotate Ring",1,mobile,mdhd,true);
						self.WireEncodeSymbol = v;
						self.Entity:SetWire("Dialing Symbol",v);
					end
				end)
			else
				self:TriggerInput("Rotate Ring",1,mobile,mdhd);
				self.WireEncodeSymbol = v;
				self.Entity:SetWire("Dialing Symbol",v);
			end
		end
	end
end

--#############################################################
function ENT:BearingSetSkin(BearingLight)
    if(IsValid(self.Entity))then
	    local delay = 0;
	    for k,v in pairs(StarGate.GetConstrainedEnts(self.Entity,2) or {}) do
		    if(IsValid(v))then
		    	if (v:GetClass()=="bearing") then
				    timer.Create("Bearing"..k..self.Entity:EntIndex(),delay,1,
					    function()
						    if(IsValid(v)) then
						        if(BearingLight)then
					                v:Bearing(true);
							    else
							        v:Bearing(false);
							    end
						    end
					    end
					);
				elseif (v:GetClass()=="floorchevron" and v.BearingMode) then
				    timer.Create("FloorChevronBM"..k..self.Entity:EntIndex(),delay,1,
					    function()
						    if(IsValid(v)) then
						        if(BearingLight)then
					                v:FloorChev(true);
							    else
							        v:FloorChev(false);
							    end
						    end
					    end
					);
				end
		    end
	    end
    end
end

-- FloorChevron
function ENT:FloorChevron(FloorChevLight)
    if(IsValid(self.Entity))then
	    local delay = 0;
	    for k,v in pairs(StarGate.GetConstrainedEnts(self.Entity,2) or {}) do
		    if(IsValid(v) and v:GetClass()=="floorchevron")then
			    timer.Create("FloorChevron"..k..self.Entity:EntIndex(),delay,1,
				    function()
					    if(IsValid(v)) then
					        if(FloorChevLight)then
				                v:FloorChev(true);
						    else
						        v:FloorChev(false);
						    end
					    end
				    end
				);
		    end
	    end
    end
end

--SGU Ramp
function ENT:SguRampSetSkin(rampchevlight,rampchevlightoff)
    if(IsValid(self.Entity))then
	    local delay = 0;
	    for k,v in pairs(StarGate.GetConstrainedEnts(self.Entity,2) or {}) do
		    if(v:IsValid() and v:GetClass():find("sgu_ramp"))then
			    timer.Create("SguRamp"..k..self.Entity:EntIndex(),delay,1,
				    function()
					    if(IsValid(v)) then
					        if(rampchevlight)then
				                v:SguRampSkin(2);
						    else
						        v:SguRampSkin(1);
						    end
							if(rampchevlightoff)then v:SguRampSkin(0) end
					    end
				    end
				);
		    end
	    end
    end
end

--#################  When getting removed..
function ENT:OnRemove()
	StarGate.StopUpdateGateTemperatures(self);
	if timer.Exists("LowPriorityThink"..self:EntIndex()) then timer.Remove("LowPriorityThink"..self:EntIndex()) end
	if timer.Exists("ConvarsThink"..self:EntIndex()) then timer.Remove("ConvarsThink"..self:EntIndex()) end
	if timer.Exists("RingTickDelay"..self.Entity:EntIndex()) then timer.Remove("RingTickDelay"..self.Entity:EntIndex()) end

	self:Close(); -- Close the horizon
	self:StopActions(); -- Stop all actions and sounds
	self:DHDDisable(0); -- Shutdown near DHD's
	if(IsValid(self.Target)) then
		if(self.IsOpen) then
			self.Target:DeactivateStargate(true);
		elseif(self.Dialling) then
			self.Target:EmergencyShutdown(true);
		end
	end
	if(self.RollSound)then
	    self.RollSound:Stop();
	end
	if (self.HasRD) then StarGate.WireRD.OnRemove(self) end;
	self:RemoveGateFromList();
end

function ENT:Shutdown() -- It is called at the end of ENT:Close or ENT.Sequence:DialFail
	self.DiallingSymbol = "";
	self.RingSymbol = "";
	self.WireDialledAddress = {};
	self.WireManualDial = false;
	self.WireSpin = false;
	self.WireSpinDir = false;
	self.WireBlock = false;
	self.WireEncodeSymbol = "";
	self.WireLockSymbol = "";
	if (IsValid(self.Gate)) then
		self.Gate.Moving = false;
	end
	if (IsValid(self.Entity)) then
		self.Entity:SetNWBool("ActChevronsL",false);
		self.Entity:SetNWBool("ActRotRingL",false);
		self.Entity:SetNWBool("ActSymsL",false);
		self:SetWire("Ring Symbol",""); -- Wire
		if timer.Exists("RingTickDelay"..self.Entity:EntIndex()) then timer.Remove("RingTickDelay"..self.Entity:EntIndex()) end
	end
end

--################# DialFail sequence @aVoN
function ENT.Sequence:DialFail(instant_stop,play_sound,fail)
	self:StopActions();
	if timer.Exists("RingTickDelay"..self.Entity:EntIndex()) then timer.Remove("RingTickDelay"..self.Entity:EntIndex()) end
	local action = self:New();
	local delay = 1.5;
	local y = tonumber(math.NormalizeAngle(self.Gate.Entity:GetLocalAngles().r));
	action:Add({f=self.SetShutdown,v={self,true},d=0});
	if ((y>=0.25 or y<=-0.25) and (self.WireSpin or self.WireManualDial)) then
		self.WireSpin = false;
		local delay = 0;
		if (self.WireManualDial) then
			delay = 1;
			if (self.WireSpinDir) then
				action:Add({f=self.SetSpeed,v={self,false},d=delay}); -- Stop at Started Position
				delay = 0;
			end
		end
		action:Add({f=self.SetSpeed,v={self,true},d=delay}); -- Stop at Started Position
	end
	if(self.DialType.Fast or self.WireManualDial)then
		action:Add({f=self.StopAtStartPos,v={self},d=1}); -- Stop at Started Position
	end
	if(instant_stop) then delay = 0 end;
	action:Add({f=self.SetStatus,v={self,false,true,true},d=0}); -- We need to keep in "dialling" mode to get around with conflicts
	if(self.Entity.Active or play_sound) then
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Fail,90,math.random(95,105)},d=0});-- Fail sound
	end
	action:Add({f=self.DHDDisable,v={self,1.5,true},d=delay});-- Shutdown EVERY DHD
	action:Add({f=self.ActivateRing,v={self,false},d=0}); -- Deactivate ring (if existant);
	-- Stop all chevrons (if active only!)
	if(self.Entity.Active or play_sound) then
		for i=1,9 do
			action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
		end
	end
	if(self.Shutdown) then
		action:Add({f=self.Shutdown,v={self},d=0});
		action:Add({f=self.ChangeSkin,v={self,0},d=0});  -- @Llapp, needs to change the skin to default!
		action:Add({f=self.FloorChevron,v={self,false},d=0}); -- change the floor chevron skin
		action:Add({f=self.ActivateSymbols,v={self,true},d=0}); -- lights off of symbols
		action:Add({f=self.BearingSetSkin,v={self,false},d=0}); -- change the bearing skin
		action:Add({f=self.SguRampSetSkin,v={self,false,true},d=0}); -- change the sgu ramp skin

		local number=0;
	    if(self.Entity:GetNetworkedEntity( "SpinNumber", number ))then
	        number = self.Entity:GetNetworkedEntity( "SpinNumber", number );
		end
		local lightdelay = 0;
		if(number==2 or number==4 or number==6 or number==8)then
		    lightdelay = 1.6;
		end
		action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	    action:Add({f=self.ActivateLights,v={self,false},d=lightdelay}); -- lights off of chevs -- verbessern
		if(self.Outbound or fail)then -- and self.SpinBack
		    if(not self.DialType.Fast)then
				local chevron = self.Entity:GetNetworkedEntity( "ChevronBool", false );
				if(number==1 or number==3 or number==5 or number==7 or number==9)then
				    action:Add({f=self.SetSpeed,v={self,false},d=2}); -- Pause the ring
				    --action:Add({f=self.StopRollSound,v={self},d=0});
					action:Add({f=self.SetSpeed,v={self,true,false},d=0}); -- Fix the StartAtStopPos
				else
			 	    action:Add({f=self.SetSpeed,v={self,true,false},d=0}); -- Fix the StartAtStopPos
				end
				self.Entity:SetNetworkedEntity( "SpinNumber", 0 );
				self.Entity:SetNetworkedEntity( "ChevronBool", false );
		    end
		end
		action:Add({f=self.StopWithSteam,v={self,self.DialType.Fast,self.Outbound,fail},d=0});
		if(not self.DialType.Fast)then
		    if(fail and self.Outbound)then
		        action:Add({f=self.SetSpeed,v={self,true,false},d=0});
			end
		    action:Add({f=self.StopAtStartPos,v={self},d=1.5}); -- Stop at Started Position
		end
	end

	action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Received",""},d=0}); -- Wire
	action:Add({f=self.SetStatus,v={self,false,false},d=0.8}); -- Make the Wire-Value of "-7" = dial-fail stay longer so people's script work along with the sound
	action:Add({f=self.SetWire,v={self,"Chevron",0},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
	action:Add({f=self.SpinFailChecker,v={self,false},d=0});
	action:Add({f=self.SetShutdown,v={self,false},d=0});
	return action;
end

--################# Close wormhole (effect) @aVoN
function ENT:Close(ignore,fast)
	self.DialType = self.DialType or {};
	if (self.DialType.Fast==nil) then self.DialType.Fast = false end
	self:StopActions();
	-- Remove the EH
	if(self.EventHorizon and self.EventHorizon:IsValid()) then
		self.EventHorizon:Shutdown(ignore);
	end
	-- Stop all chevrons
	local action = self.Sequence:New({
		{f=self.SetStatus,v={self,true,true},d=0},
		{pause=true,d=2.7},
	});
	action:Add({f=self.SetShutdown,v={self,true},d=0});
	for i=1,9 do
		action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
	end
	action:Add({f=self.SetStatus,v={self,false,false},d=0}); -- Add the "close" flag
	action:Add({f=self.SetWire,v={self,"Chevron",0},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Received",""},d=0}); -- Wire
	-- Add additional shutdown sequences
	if(self.Shutdown) then
		action:Add({f=self.Shutdown,v={self},d=0});
		action:Add({f=self.ChangeSkin,v={self,0},d=0});  -- @Llapp, needs to change the skin to default!
		action:Add({f=self.ActivateSymbols,v={self,true},d=0}); -- lights off of symbols
		action:Add({f=self.BearingSetSkin,v={self,false},d=0}); -- change the bearing skin
		action:Add({f=self.SguRampSetSkin,v={self,false,true},d=0}); -- change the sgu ramp skin
		action:Add({f=self.FloorChevron,v={self,false},d=0}); -- change the floor chevron skin
	    action:Add({f=self.ActivateLights,v={self,false},d=1.2}); -- lights off of chevs
		if(self.Outbound and not self.DialType.Fast or self.WireSpin)then
		    action:Add({f=self.SetSpeed,v={self,true,false},d=0}); -- Fix the StartAtStopPos
			action:Add({f=self.StopAtStartPos,v={self,true},d=1.5}); -- Stop at Started Position
 		end
		action:Add({f=self.StopWithSteam,v={self,self.DialType.Fast,self.Outbound},d=0}); -- Stop at Started Position
	end
	action:Add({f=self.DHDDisable,v={self,0,true},d=0});
	action:Add({f=self.SpinFailChecker,v={self,false},d=0});
	action:Add({f=self.SetShutdown,v={self,false},d=0});
	self:RunActions(action);
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "stargate_universe", StarGate.CAP_GmodDuplicator, "Data" )
end