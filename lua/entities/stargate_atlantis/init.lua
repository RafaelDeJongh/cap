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
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
--################# Include
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
include("modules/dialling.lua");
--################# Defines
-- Models
ENT.Models = {
	Base="models/Madman07/Stargate/base_atlantis.mdl",
	Chevron="models/Madman07/Stargate/chevron.mdl",
	Dial={
		"models/zup/stargate/sga_dial_part1.mdl",
		"models/zup/stargate/sga_dial_part2.mdl",
	},
	Incoming={
		"models/zup/stargate/sga_incoming_part1.mdl",
		"models/zup/stargate/sga_incoming_part2.mdl",
	},
}
-- Sounds
ENT.Sounds = {
	Ring=Sound("stargate/gate_roll_atlantis.mp3"),
	Ring2=Sound("stargate/atlantis/roll.wav"),
	Open=Sound("stargate/atlantis/open.mp3"),
	Travel=Sound("stargate/gate_travel.mp3"),
	Close=Sound("stargate/gate_close.mp3"),
	Chevron=Sound("stargate/chevron_atlantis.mp3"),
	Chevron2=Sound("stargate/atlantis/chevron.mp3"),
	Inbound=Sound("stargate/chevron_atlantis_incoming.mp3"),
	Lock=Sound("stargate/chevron_lock_atlantis.mp3"),
	LockInbound=Sound("stargate/chevron_lock_atlantis_incoming.mp3"),
	Fail=Sound("stargate/dial_fail_atlantis.mp3"),
	OnButtonLock=Sound("stargate/chevron_lock_atlantis_incoming.mp3"),
}
-- In which slot do the chevron a lock?
ENT.ChevronLocks = {4,8,12,24,28,32,36,16,20};
ENT.ChevronLocksb = {4,8,12,24,28,32,36,16,20};
ENT.ChevronLocks8 = {4,8,12,16,24,28,32,36,20};
ENT.ChevronLocks9 = {4,8,12,16,20,24,28,32,36};
ENT.ChevronLocks8o = {4,8,12,24,28,32,16,36,20};
ENT.ChevronLocks9o = {4,8,12,24,28,32,16,20,36};
--ENT.AlwaysFast = true; -- Tells the activation code in stargate_base/events.lua:ActivateStargate() not to add a delay when called by this gate here (Atlantis always dials fast!)
--################# SENT CODE ###############

--################# Init @aVoN
function ENT:Initialize()
	util.PrecacheModel(self.Models.Base);
	util.PrecacheModel(self.Models.Chevron);
	util.PrecacheModel(self.Models.Dial[1]);
	util.PrecacheModel(self.Models.Incoming[1]);
	util.PrecacheModel(self.Models.Dial[2]);
	util.PrecacheModel(self.Models.Incoming[2]);

	self.Entity:SetModel(self.Models.Base);
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:Fire("skin",1);
	self.BaseClass.Initialize(self); -- BaseClass Initialize call
	self:AddRing();
	self:AddChevron();
	self.SpinLight = 1;
	self.AtlType = false;
	self.AtlTypeAct = false;

	timer.Create("AtlTypeThink"..self:EntIndex(), 5.0, 0, function() if IsValid(self) then self:AtlTypeThink() end end);
end

--#################  Called when stargate_group_system changed
function ENT:ChangeSystemType(groupsystem)
	self:GateWireInputs(groupsystem);
	if (groupsystem) then
		if (self.GateSpawnerSpawned) then
			timer.Simple(1.75, function()
				if (IsValid(self)) then
					self:GateWireOutputs(groupsystem);
					self:SetWire("Dialing Mode",-1);
					self:SetChevrons(0,0);
				end
			end)
		else
			self:GateWireOutputs(groupsystem);
			self:SetWire("Dialing Mode",-1);
			self:SetChevrons(0,0);
		end
		self.WireCharters = "A-Z0-9@#";
	else
		if (self.GateSpawnerSpawned) then
			timer.Simple(1.75, function()
				if (IsValid(self)) then
					self:GateWireOutputs(groupsystem);
					self:SetWire("Dialing Mode",-1);
					self:SetChevrons(0,0);
				end
			end)
		else
			self:GateWireOutputs(groupsystem);
			self:SetWire("Dialing Mode",-1);
			self:SetChevrons(0,0);
		end
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
	self:CreateWireInputs("Dial Address","Dial String [STRING]","Dial Mode","Start String Dial","Close","Disable Autoclose","Transmit [STRING]","Turn on ring light","Activate chevron numbers [STRING]","Disable Menu","Atlantis Type");
end

function ENT:GateWireOutputs(groupsystem)
	self:CreateWireOutputs("Active","Open","Inbound","Chevron","Chevron Locked","Chevrons [STRING]","Dialing Address [STRING]","Dialing Mode","Dialing Symbol [STRING]","Dialed Symbol [STRING]","Received [STRING]");
end

--################# Either allow the player to spawn this or not
function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local e = ents.Create("stargate_atlantis");
	e:SetPos(t.HitPos+Vector(0,0,90));
	e:Spawn();
	e:Activate();
	--################# Set correct angle for the spawned prop
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	e:SetGateGroup("P@");
	e:SetLocale(true);
	e:CartersRamps(t);
	e:SetWire("Dialing Mode",-1);
	return e;
end

--################# Creates the ring for the gate @aVoN
function ENT:AddRing()
	local pos = self.Entity:GetPos();
	self.Ring = {Dial={},Incoming={}};
	for i=1,2 do
		local e = ents.Create("prop_dynamic_override");
		e:SetModel(self.Models.Dial[i]);
		e:SetPos(pos);
		e:SetParent(self.Entity);
		e:SetDerive(self.Entity); -- Derive Material/Color from "Parent"
		e:DrawShadow(false);
		e:Spawn();
		e:Activate();
		self.Ring.Dial[i] = e;
		e = nil;
		e = ents.Create("prop_dynamic_override");
		e:SetModel(self.Models.Incoming[i]);
		e:SetPos(pos);
		e:SetParent(self.Entity);
		e:SetDerive(self.Entity); -- Derive Material/Color from "Parent"
		e:DrawShadow(false);
		e:Spawn();
		e:Activate();
		e:SetRenderMode(RENDERMODE_TRANSALPHA);
		self.Ring.Incoming[i] = e;
	end
end

--################# Turns on a light on the ring @aVoN
function ENT:RingLight(light,inbound,shutdown,atlantis)
	local ring = self.Ring.Dial;
	if(inbound) then ring = self.Ring.Incoming end;
	if (atlantis) then
		for i=1,2 do
			ring[i]:SetColor(Color(255,255,255,100));
		end
		self.AtlTypeAct = true;
	else
		for i=1,2 do
			ring[i]:SetColor(Color(255,255,255,255));
		end
		self.AtlTypeAct = false;
	end
	local part = 1;
	if(light < 0) then
		light = light + 36;
	elseif(light > 36) then
		light = light - 36;
	end
	if(light > 18) then
		part = 2; -- Take second  ring part
		light = light - 18;
		-- Deactivate the other ring part. We don't need it anymore
		ring[1]:Fire("SetBodyGroup",0);
	else
		-- Deactivate the other ring part. We don't need it anymore
		ring[2]:Fire("SetBodyGroup",0);
	end
	--############# 36 glyph fix by Llapp #############
	if(light == 0 and self.SpinLight == 17 and not shutdown)then
		light = 18
		part = 2
	end
    self.SpinLight = light;
	ring[part]:Fire("SetBodyGroup",light);
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
		e:Fire("skin",2);
	end
end

--################# Wire input @aVoN / AlexALX
function ENT:TriggerInput(k,v,mobile,mdhd)
	self:TriggerInputDefault(k,v,mobile,mdhd);
	if(k == "Activate chevron numbers" and not self.NewActive) then
		if (v != "" and self:CheckEnergy(true,true)) then
			local chevs = v:gsub("[^0-9]",""):TrimExplode("");
			local action = self.Sequence:New();
			for i=1,9 do
				if (chevs[i] and tonumber(chevs[i]) >= 1) then
					self:ActivateChevron(i,true);
					action:Add({f=self.SetChevrons,v={self,i,1},d=0.01}); -- Wire;
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
		else
			for i=1,9 do
				self:ActivateChevron(i,false);
				self:SetChevrons(0,0);
			end
			self.Entity:SetNWBool("ActChevronsL",false);
		end
	elseif(k == "Turn on ring light" and not self.NewActive) then
		if (v >= 2 and self:CheckEnergy(true,true)) then
			self:RingLight(36,true);
			self.Entity:SetNWBool("ActRingL",true);
		elseif (v == 1 and self:CheckEnergy(true,true)) then
			self:RingLight(36,true,false,true);
			self.Entity:SetNWBool("ActRingL",true);
		else
			self:RingLight(0,true);
			self:RingLight(0,false);
			self.Entity:Fire("SetBodyGroup",0,0.05); -- Needs a certain delay
			self.Entity:SetNWBool("ActRingL",false);
		end
	elseif(k == "Disable Menu") then
		self.DisMenu = util.tobool(v);
		self.Entity:SetNWBool("DisMenu",util.tobool(v));
	elseif(k == "Atlantis Type") then
		self.AtlType = util.tobool(v);
		self.Entity:SetNWBool("AtlType",util.tobool(v));
		self:AtlTypeThink();
	end
end

--################# Activates or deactivates a chevron @aVoN
function ENT:ActivateChevron(chev,b,inbound,body)
	if(not (self and self.Chevron)) then return end;
	if(self.Chevron[chev]) then
		if(b) then
			if (IsValid(self.Chevron[chev])) then
				self.Chevron[chev]:Fire("skin",3);
				self.Entity:SetNetworkedBool("chevron"..chev,true); -- Dynamic light of the chevron
			else
				self.Entity:Sparks(chev);
			    timer.Simple(0.1, function()
		            self.SparkEnt:Fire("StopSpark", "", 0);
			    end);
			end
			if(not inbound) then
				self.Entity:Fire("SetBodyGroup",body);
			end
			if(not inbound and not fast)then
			    self:RingSound(false);
			end
		else
			self.Chevron[chev]:Fire("skin",2);
			if(body) then
				self.Entity:Fire("SetBodyGroup",body);
			else
				self.Entity:Fire("SetBodyGroup",0);
			end
			self.Entity:SetNWBool("chevron"..chev,false); -- Dynamic light of the chevron
			--if(not inbound and not fast)then
			--    self:RingSound(false);
			--end
		end
	end
end

--#################  When getting removed..
function ENT:OnRemove()
	StarGate.StopUpdateGateTemperatures(self);
	if timer.Exists("LowPriorityThink"..self:EntIndex()) then timer.Remove("LowPriorityThink"..self:EntIndex()) end
	if timer.Exists("ConvarsThink"..self:EntIndex()) then timer.Remove("ConvarsThink"..self:EntIndex()) end
	if timer.Exists("AtlTypeThink"..self:EntIndex()) then timer.Remove("AtlTypeThink"..self:EntIndex()) end

	self:Close(); -- Close the horizon
	self:StopActions(); -- Stop all actions and sounds
	self:DHDDisable(0); -- Shutdown near DHD's
	if(self.RingSnd)then
	    self:RingSound(false);
	end
	if(IsValid(self.Target)) then
		if(self.IsOpen) then
			self.Target:DeactivateStargate(true);
		elseif(self.Dialling) then
			self.Target:EmergencyShutdown(true);
		end
	end
	if (self.HasRD) then StarGate.WireRD.OnRemove(self) end;
	self:RemoveGateFromList();
end

--################# SlowDial Sound @Llapp
function ENT:RingSound(play)
    if(play)then
		self.RingSnd = self.RingSnd or CreateSound(self.Entity,self.Sounds.Ring2);
	    self.RingSnd:ChangePitch(95,0);
	    self.RingSnd:SetSoundLevel(94);
	    self.RingSnd:PlayEx(1,97)
	else
	    if(self.RingSnd)then
			self.RingSnd:Stop()
		end
	end
end

function ENT:AtlTypeThink()
	if (not self.Active and not self.NewActive) then
		if (self.AtlType) then
			if (self.AtlTypeAct) then
				if (not self:CheckEnergy(true,true)) then
					self:RingLight(0,true,true);
				end
			else
				if (self:CheckEnergy(true,true)) then
					self:RingLight(36,true,false,true);
				end
			end
		elseif (self.AtlTypeAct) then
			self:RingLight(0,true,true);
		end
	end
end

--################# Stops the gate's lights
function ENT:Shutdown(fail,play_sound)
	if(not (self and self.RingLight)) then return end;
	if (play_sound) then
		self:RingLight(0,true,true);
		self:RingLight(0,false,true);
		if (IsValid(self.Entity)) then
			self.Entity:Fire("SetBodyGroup",0,0.05); -- Needs a certain delay
		end
	end
	if (IsValid(self.Entity)) then
		self.Entity:SetNWBool("ActChevronsL",false);
		self.Entity:SetNWBool("ActRingL",false);
	end
	self:RingSound(false);
	if (self.AtlType and self:CheckEnergy(true,true)) then
		self:RingLight(36,true,false,true);
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "stargate_atlantis", StarGate.CAP_GmodDuplicator, "Data" )
end