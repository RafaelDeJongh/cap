/*
	Stargate SENT for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
--################# Include
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
include("modules/dialling.lua");
--################# Defines
-- Models
ENT.Models = {
	Base="models/AlexALX/Stargate_Cebt/sgtbase.mdl",
	Chevron="models/AlexALX/Stargate_Cebt/sgtchev.mdl",
}
-- Sounds
ENT.Sounds = {
	Open=Sound("stargate/sg1/open.mp3"),
	Travel=Sound("stargate/gate_travel.mp3"),
	Close=Sound("stargate/gate_close.mp3"),
	ChevronDHD=Sound("stargate/dhd_sg1.mp3"),
	Inbound=Sound("stargate/chevron_incoming.mp3");
	Fail=Sound("stargate/dial_fail.mp3"),
	OnButtonLock=Sound("stargate/stargate/dhd/dhd_usual_dial.wav"),
}

ENT.chevron_posd = {
	Vector(0, 72.9496, 86.4997),
	Vector(0, 111.3255, 19.6062),
	Vector(0, 96.8318, -55.8982),
	Vector(0, -97.6934, -56.3638),
	Vector(0, -111.6171, 19.7085),
	Vector(0, -72.7159, 86.5669),
	Vector(0, -0.1033, 113.0031),
	Vector(0, 38.3674, -105.9060),
	Vector(0, -38.3754, -105.8053),
}

ENT.chevron_poss = {
	Vector(3.5, 72.9496, 86.4997),
	Vector(3.5, 111.3255, 19.6062),
	Vector(3.5, 96.8318, -55.8982),
	Vector(3.5, -97.6934, -56.3638),
	Vector(3.5, -111.6171, 19.7085),
	Vector(3.5, -72.7159, 86.5669),
	Vector(3.5, -0.1033, 113.0031),
	Vector(3.5, 38.3674, -105.9060),
	Vector(3.5, -38.3754, -105.8053),
}

--################# SENT CODE ###############

--################# Init @aVoN,Assassin21
function ENT:Initialize()
	util.PrecacheModel(self.Models.Base);
	util.PrecacheModel(self.Models.Chevron);
	self.Entity:SetModel(self.Models.Base);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.BaseClass.Initialize(self); -- BaseClass Initialize call
	self:AddChevron();
end

--#################  Called when stargate_group_system changed
function ENT:ChangeSystemType(groupsystem,reload)
	self:GateWireInputs(groupsystem);
	self:GateWireOutputs(groupsystem);
	if (groupsystem) then
		self:SetWire("Dialing Mode",-1);
		self:SetChevrons(0,0);
		self.WireCharters = "A-Z0-9@#";
	else
		self:SetWire("Dialing Mode",-1);
		self:SetChevrons(0,0);
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
	self:CreateWireInputs("Dial Address","Dial String [STRING]","Dial Mode","Start String Dial","Close","Disable Autoclose","Transmit [STRING]","Activate chevron number [STRING]","Set Point of Origin","Disable Menu","Event Horizon Type [STRING]","Event Horizon Color [VECTOR]");
end

function ENT:GateWireOutputs(groupsystem)
	self:CreateWireOutputs("Active","Open","Inbound","Chevron","Chevron Locked","Chevrons [STRING]","Earth Point of Origin","Dialing Address [STRING]","Dialing Mode","Dialing Symbol [STRING]","Dialed Symbol [STRING]","Received [STRING]");
end

function ENT:WireOrigin()
	if (not self.Outbound and IsValid(self.Target)) then
		self:SetWire("Earth Point of Origin",self.Target:IsConceptDHD());
	else
		self:SetWire("Earth Point of Origin",self:IsConceptDHD());
	end
end

--################# Either allow the player to spawn this or not
function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local e = ents.Create("stargate_tollan");
	e:SetPos(t.HitPos+Vector(0,0,90));
	e:Spawn();
	e:Activate();
	--################# Set correct angle for the spawned prop
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	e:SetGateGroup("M@");
	e:SetLocale(true);
	e:CartersRamps(t); -- put gate on carters ramps @Llapp
	e:SetWire("Dialing Mode",-1);
	return e;
end

--################# Adds all chevrons @aVoN
function ENT:AddChevron()
	self.Chevron={};
	local pos = self.Entity:GetPos();
	local angForw = self.Entity:GetAngles():Up();
	local ang = self.Entity:GetAngles();
	for i=1,9 do
		local e = ents.Create("prop_dynamic_override");
		e:SetModel(self.Models.Chevron);
		e:SetParent(self.Entity);
		e:SetDerive(self.Entity); -- Derive Material/Color from "Parent"
		e:DrawShadow(false);
		e:SetPos(pos);
		local a = angForw*i*40;
		e:SetAngles(ang-Angle(a[1],a[2],a[3]));
		e:Spawn();
		e:Activate();
		if (i >= 6) then self.Chevron[i-2] = e;
		elseif (i <= 3) then self.Chevron[i] = e;
		elseif (i == 4) or (i == 5) then self.Chevron[i+4] = e;
		end
		e:SetDerive(self.Entity); -- Derive Material/Color from "Parent"
	end
end

--################# Activates or deactivates a chevron @aVoN
function ENT:ActivateChevron(chev,b)
	if(not (self and self.Chevron)) then return end;
	if(self.Chevron[chev]) then
		if(b) then
			if (IsValid(self.Chevron[chev])) then
				self.Chevron[chev]:Fire("skin",1);
				self.Entity:SetNetworkedBool("chevron"..chev,true); -- Dynamic light of the chevron
			else
				self.Entity:Sparks(chev);
			    timer.Simple(0.1, function()
		            self.SparkEnt:Fire("StopSpark", "", 0);
			    end);
			end
		else
			self.Chevron[chev]:Fire("skin",0);
			self.Entity:SetNWBool("chevron"..chev,false); -- Dynamic light of the chevron
		end
	end
end

--################# Wire input @aVoN / AlexALX
function ENT:TriggerInput(k,v,mobile,mdhd)
	self:TriggerInputDefault(k,v,mobile,mdhd);
	if(k == "Activate chevron numbers" and not self.NewActive and not self.WireManualDial) then
		if (v != "" and self:CheckEnergy(true,true)) then
			local chevs = v:gsub("[^0-9]",""):TrimExplode("");
			local sound = true;
			local act = false;
			local action = self.Sequence:New();
			for i=1,9 do
				if (chevs[i] and tonumber(chevs[i]) >= 1) then
					if (tonumber(chevs[i]) >= 2) then sound = false; end
					self:ActivateChevron(i,true);
					action:Add({f=self.SetChevrons,v={self,i,1},d=0.01}); -- Wire;
					act = true;
				else
					self:ActivateChevron(i,false);
					action:Add({f=self.SetChevrons,v={self,i,0},d=0.01}); -- Wire;
				end
			end
			self:RunActions(action);
			if (v!="000000000") then
				self.Entity:SetNWBool("ActChevronsL",true);
			else
				self.Entity:SetNWBool("ActChevronsL",false);
			end
			if (sound and act) then self:ChevronSound(7,true,true); end
		else
			for i=1,9 do
				self:ActivateChevron(i,false);
				self:SetChevrons(0,0);
			end
			self.Entity:SetNWBool("ActChevronsL",false);
		end
	end
end

--################# Makes chevron 7 go up and down @aVoN
function ENT:Chevron7Animation(fast)
	-- Up and down animation
	local delay = 0.4;
	if(fast) then delay = 0 end;
end

--################# Chevron locking sound? @aVoN
function ENT:ChevronSound(chev,fast,inbound)
	if (fast and not IsValid(self.Chevron[chev])) then return end
	if (not fast and not IsValid(self.Chevron[7])) then return end
	local snd = self.Sounds.ChevronDHD; -- Fast dial with DHD
	if(not fast or inbound) then
		snd = self.Sounds.Inbound;
	end
	self.Entity:EmitSound(snd,90,math.random(97,104));
end

function ENT:Shutdown()
	if (IsValid(self.Entity)) then
		self.Entity:SetNWBool("ActChevronsL",false);
	end
end

function ENT:DialSlowTime(chevs,caller)
	local dly = 17
	if (chevs==8) then dly = 19;
	elseif (chevs==9) then dly = 21 end
	if (caller.EventHorizonData.OpeningDelay>self.EventHorizonData.OpeningDelay) then
		dly = dly - (caller.EventHorizonData.OpeningDelay-self.EventHorizonData.OpeningDelay)
	end
	dly = dly - caller.DialFastTime
	return dly                 
end 

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "stargate_tollan", StarGate.CAP_GmodDuplicator, "Data" )
end