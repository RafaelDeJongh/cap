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

-- Reload handler
-- Someone just entered lua_reloadents into console. Therefore, remove all stargates in the map or they will get all fucked
if(CurTime() > 10) then StarGate.CallReload(_) end;
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base",true)) then return end

--Include
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");
include("modules/lib.lua");
include("modules/wire_lib.lua");
include("modules/events.lua");

-- Defines
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

ENT.chevron_posd = {
	Vector(0,88.2829,104.5427),
	Vector(0,134.7614,23.2695),
	Vector(0,118.6142,-68.3697),
	Vector(0,-118.5464,-68.4004),
	Vector(0,-134.9181,22.6665),
	Vector(0,-86.8867,105.0110),
	Vector(0,0.0461,136.2538),
	Vector(0,47.0651,-128.8588),
	Vector(0,-46.6631,-128.9825),
}

ENT.chevron_poss = {
	Vector(6,88.2829,104.5427),
	Vector(6,134.7614,23.2695),
	Vector(6,118.6142,-68.3697),
	Vector(6,-118.5464,-68.4004),
	Vector(6,-134.9181,22.6665),
	Vector(6,-86.8867,105.0110),
	Vector(6,0.0461,136.2538),
	Vector(6,47.0651,-128.8588),
	Vector(6,-46.6631,-128.9825),
}

ENT.UnstableSound = Sound("stargate/orlin/gateflicker.wav");

--################# SENT CODE #################
--################# Initialize
function ENT:Initialize()
	--################# Config
	self.DHDRange = StarGate.CFG:Get("dhd","range",1000); -- Maximum range a DHD can be in before the gate says "Hey, you do not belong to me, get the fuck out"
	self.DialBlocked = StarGate.CFG:Get("stargate","dial_blocked",false);
	self.DialBlockedWorld = StarGate.CFG:Get("stargate","world_blocked",false);
	self.WormHoleJumpNDMG = StarGate.CFG:Get("stargate","wormholejump",3000);
	self.EnergyTransInterval = StarGate.CFG:Get("stargate","en_trans_interval",0.1);
	self.MaxEnergyTransfer = StarGate.CFG:Get("stargate","max_energy_transfer",80000);
	self.EnergyTransfer = StarGate.CFG:Get("stargate","energy_transfer",true);
	self.ResTransInterval = StarGate.CFG:Get("stargate","res_trans_interval",0.1);
	self.MaxResTransfer = StarGate.CFG:Get("stargate","max_res_transfer",5000);
	self.ResTransfer = StarGate.CFG:Get("stargate","resource_transfer",true);

	self.ResTransferClasses = {};
	local classes = StarGate.CFG:Get("stargate","res_classes","");
	if (classes!="") then
		for _,v in pairs(classes:TrimExplode(",")) do
			self.ResTransferClasses[v:lower()] = true;
		end
	end

	self.WormHoleJumpDMG = 0;
	self:SetNetworkedInt("DHDRange",self.DHDRange);
	--################# General defines and inits
	self:RegisterSequenceTable(); -- Register a "Copy" of the self.Sequence table, so out sequence won't be mixed between Atlantis/SG1 gates
	self.GatePrivat = self.GatePrivat or false; -- Is the gate Private?
	self.GateLocal = self.GateLocal or false; -- Is the gate local?
	self.GateGalaxy = self.GateGalaxy or false; -- Is the gate Galaxy?
	self.GateName = self.GateName or ""; -- The name of this gate
	self.GateAddress = self.GateAddress or ""; -- Our Address
	self.GateGroup = self.GateGroup or "";
	self.GateBlocked = self.GateBlocked or false;
	self.DialledAddress = {}; -- Still used for compatibility reasons
	self.IsOpen = false; -- Still used for compatibility reasons
	self.Dialling = false; -- Still used for compatibility reasons
	self.Virus = false;
	self.WireDialledAddress = {};
	self.WireManualDial = false;
	self.WireBlock = false;
	self.WireEncodeSymbol = "";
	self.WireLockSymbol = "";
	self.InboundDelay = 29.5;
	self.DialType = {};
	self.Jumped = false; -- FixJumping issues
	self.Jumping = false; -- don't allow close while jumping
	self.NoxDialingType = false;
	self.NoxIrisReactivated = false;
	self.Shutingdown = false;
	self.Entity:SetUseType(SIMPLE_USE);
	--################# Wire!
	self:ChangeSystemType(GetConVar("stargate_group_system"):GetBool());
	self.WireChevrons = {};
	self:SetChevrons(0,0);
	--################# Fix for Duplicator, or the ring and chevron will look strange when loading a saved gate
	local ang = self.Entity:GetAngles();
	if(ang ~= Angle(0,0,0)) then
		self.Entity:SetAngles(Angle(0,0,0));
		local e = self.Entity;
		timer.Simple(0,
			function()
				if(ang and IsValid(e)) then
					e:SetAngles(ang);
				end
			end
		);
	end
	--################# Set physic and entity properties
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableMotion(false);
		phys:SetMass(32000); -- A stargate weights 32 tons!
	end

	-- Energy support
	if (self.HasRD) then
		self:AddResource("energy",1);
		self:SetNetworkedBool("HAS_RD",true);
	end
	self.EnergyConsume = 10;
	self.ConnectionSGU = false;
	self.ConnectionGalaxy = false;
	self.LastDistance = 0;
	self.LastEnergy = 0;

	-- for jumper, probably temporarily, fast-code
	local oldSetWire = self.SetWire;
	self.SetWire = function(self,k,v,i)
		if (k=="Dialing Address" and self.Outbound) then
			self.Entity:SetNetworkedString("DialledAddress",v);
		end
		oldSetWire(self,k,v,i);
	end
	
	self.EventHorizonType = self.EventHorizonData.Type or self.EventHorizonData.BaseClass.Type
	self.EventHorizonKawoosh = self.EventHorizonData.Kawoosh or self.EventHorizonData.BaseClass.Kawoosh
	self:SetNWString("EventHorizonType",self.EventHorizonType);

	-- I dont like it, but llapp is using think for rotation stuff, so had to do Low Proity think
	timer.Create("LowPriorityThink"..self:EntIndex(), 0.5, 0, function() if IsValid(self) then self:LowPriorityThink() end end);

	self.chev_health = { 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000 }
	self.chev_destroyed = { false, false, false, false, false, false, false, false, false }
	self.ChevDestroyed = false;

	if (self.Entity:GetClass()!="stargate_supergate") then
		self:Spark();
		StarGate.UpdateGateTemperatures(self);
	end

	self:SetNetworkedBool("SG_GROUP_SYSTEM",GetConVar("stargate_group_system"):GetBool());
	timer.Create("ConvarsThink"..self:EntIndex(), 5.0, 0, function() if IsValid(self) then self:ConvarsThink() end end);
	self:ConvarsThink();
	self.DisAutoClose = false;
	self.DisMenu = false;

	if (pewpew and pewpew.NeverEverList and not table.HasValue(pewpew.NeverEverList,self.Entity:GetClass())) then table.insert(pewpew.NeverEverList,self.Entity:GetClass()); end -- pewpew support
end

function ENT:DeriveOnSetColor(color)
	self.OrigColor = color
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
	self:CreateWireInputs("Dial Address","Dial String [STRING]","Dial Mode","Start String Dial","Close","Disable Autoclose","Disable Menu","Transmit [STRING]");
end

function ENT:GateWireOutputs(groupsystem)
	self:CreateWireOutputs("Active","Open","Inbound","Chevron","Chevron Locked","Chevrons [STRING]","Dialing Address [STRING]","Dialing Mode","Dialing Symbol [STRING]","Dialed Symbol [STRING]","Received [STRING]");
end

--#################  When getting removed..
function ENT:OnRemove()
	StarGate.StopUpdateGateTemperatures(self);
	if timer.Exists("LowPriorityThink"..self:EntIndex()) then timer.Remove("LowPriorityThink"..self:EntIndex()) end
	if timer.Exists("ConvarsThink"..self:EntIndex()) then timer.Remove("ConvarsThink"..self:EntIndex()) end
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
	StarGate.WireRD.OnRemove(self);
	self:RemoveGateFromList();
end

function ENT:LowPriorityThink()
	-- have energy check for energy and eat it at same time, shorter code
	if(self.Outbound) then
		if(self.HasRD and self.IsOpen and IsValid(self.EventHorizon) and self.EventHorizon:IsOpen()) then
			if not self:HaveEnergy() then self:Disconnect() end
		end
	end
	if not self.IsOpen and self.Jumped then self.Jumped = false; end
	if not self.IsOpen and self.WormHoleJumpDMG>0 then self.WormHoleJumpDMG = 0; end
	if (self.HasRD) then
		local energy = self.Entity:GetResource("energy");
		if (self.Entity:GetNetworkedInt("RD_ENERGY",0) != energy) then
			self.Entity:SetNetworkedInt("RD_ENERGY",energy);
		end
	end
end

--################# Server convars to client by AlexALX
function ENT:ConvarsThink(send)
	if (not IsValid(self)) then return end;

	local convar = GetConVar("stargate_candial_groups_dhd"):GetInt()
	if (send or convar != self.Entity:GetNetworkedInt("CANDIAL_GROUP_DHD")) then
		if (send) then self.Entity:SetNetworkedInt("CANDIAL_GROUP_DHD",0); end
		self.Entity:SetNetworkedInt("CANDIAL_GROUP_DHD",convar);
	end
	convar = GetConVar("stargate_candial_groups_menu"):GetInt()
	if (send or convar != self.Entity:GetNetworkedInt("CANDIAL_GROUP_MENU")) then
		if (send) then self.Entity:SetNetworkedInt("CANDIAL_GROUP_MENU",0); end
		self.Entity:SetNetworkedInt("CANDIAL_GROUP_MENU",convar);
	end
	convar = GetConVar("stargate_sgu_find_range"):GetInt()
	if (send or convar != self.Entity:GetNetworkedInt("SGU_FIND_RANDE")) then
		if (send) then self.Entity:SetNetworkedInt("SGU_FIND_RANDE",0); end
		self.Entity:SetNetworkedInt("SGU_FIND_RANDE",convar);
	end
	convar = GetConVar("stargate_group_system"):GetBool()
	if (send or convar != self.Entity:GetNetworkedBool("SG_GROUP_SYSTEM")) then
		if (send) then self.Entity:SetNetworkedInt("SG_GROUP_SYSTEM",0); end
		self.Entity:SetNetworkedBool("SG_GROUP_SYSTEM",convar);
		if (not send) then self.Entity:ChangeSystemType(convar,true); end -- reload
	end
	convar = GetConVar("stargate_block_address"):GetInt()
	if (send or convar != self.Entity:GetNetworkedInt("SG_BLOCK_ADDRESS")) then
		if (send) then self.Entity:SetNetworkedInt("SG_BLOCK_ADDRESS",0); end
		self.Entity:SetNetworkedInt("SG_BLOCK_ADDRESS",convar);
	end
	convar = GetConVar("stargate_energy_dial"):GetInt()
	if (send or convar != self.Entity:GetNetworkedInt("SG_ENERGY")) then
		if (send) then self.Entity:SetNetworkedInt("SG_ENERGY",0); end
		self.Entity:SetNetworkedInt("SG_ENERGY",convar);
	end
	convar = GetConVar("stargate_energy_dial_spawner"):GetInt()
	if (send or convar != self.Entity:GetNetworkedInt("SG_ENERGY_SP")) then
		if (send) then self.Entity:SetNetworkedInt("SG_ENERGY_SP",0); end
		self.Entity:SetNetworkedInt("SG_ENERGY_SP",convar);
	end
	convar = GetConVar("stargate_dhd_destroyed_energy"):GetInt()
	if (send or convar != self.Entity:GetNetworkedInt("SG_ENERGY_DHD_K")) then
		if (send) then self.Entity:SetNetworkedInt("SG_ENERGY_DHD_K",0); end
		self.Entity:SetNetworkedInt("SG_ENERGY_DHD_K",convar);
	end
	convar = GetConVar("stargate_vgui_glyphs"):GetInt()
	if (send or convar != self.Entity:GetNetworkedInt("SG_VGUI_GLYPHS")) then
		if (send) then self.Entity:SetNetworkedInt("SG_VGUI_GLYPHS",0); end
		self.Entity:SetNetworkedInt("SG_VGUI_GLYPHS",convar);
	end
	convar = GetConVar("stargate_atlantis_override"):GetInt()
	if (send or convar != self.Entity:GetNetworkedInt("SG_ATL_OVERRIDE")) then
		if (send) then self.Entity:SetNetworkedInt("SG_ATL_OVERRIDE",0); end
		self.Entity:SetNetworkedInt("SG_ATL_OVERRIDE",convar);
	end
	if (send or self.sendpos==nil or self.sendpos != self.Entity:GetPos()) then
		self.sendpos = self.Entity:GetPos();
		self:RefreshGateList("pos",self.sendpos,"vector");
	end
end

--################# @Llapp
function ENT:Spark()
    local spawnflags = 512;
    local maxdelay = math.Round(math.Clamp(60, .12, 120));
    local magnitude = math.Round(math.Clamp(0.38, .5, 15));
    local traillength = math.Round(math.Clamp(0.45, .12, 15));
    if(math.Round(math.Clamp(1, 0, 1)) == 1)then
	    spawnflags = spawnflags + 128;
	end
    if(math.Round(math.Clamp(1, 0, 1)) == 0)then
	    spawnflags = spawnflags + 256;
	end
    local e = ents.Create("env_spark");
    e:SetPos(self.Entity:GetPos());
    e:SetAngles(self.Entity:GetAngles());
    e:SetParent(self.Entity);
    e:SetKeyValue("MaxDelay", tostring(maxdelay));
    e:SetKeyValue("Magnitude", tostring(magnitude));
    e:SetKeyValue("TrailLength", tostring(traillength));
    e:SetKeyValue("spawnflags", tostring(spawnflags));
    e:Spawn();
    e:Activate();
    self.SparkEnt = e;
    return e;
end

--################# @Llapp
function ENT:Sparks(chev)
	local pos = self.chevron_poss[chev];
	local rang = math.random(-45,45);
	self.SparkEnt:SetPos(self.Entity:LocalToWorld(pos));
	self.SparkEnt:SetAngles(self.Entity:GetAngles()+Angle(rang,rang,0));
	self.SparkEnt:Fire("SparkOnce", "", 0);
    self.SparkEnt:Fire("StartSpark", "", 0);
end

--################# When it get's hurt, make it flicker etc
function ENT:OnTakeDamage(dmg)
	if (not IsValid(dmg:GetAttacker()) || dmg:GetAttacker():GetClass() == "point_hurt" || dmg:GetAttacker():GetClass() == "kawoosh_hurt" || self:GetClass()=="stargate_orlin") then return end
	local damage = dmg:GetDamage();

	if(dmg:GetDamageType() == DMG_BLAST and (not self.GateSpawnerSpawned and not util.tobool(GetConVar("stargate_protect"):GetInt()) or self.GateSpawnerSpawned and not util.tobool(GetConVar("stargate_protect_spawner"):GetInt())))then
		local class = self.Entity:GetClass();
		if (class!="stargate_supergate" and class!="stargate_universe" and class!="stargate_orlin") then
			for i=1,9 do
				if ((self.Entity:LocalToWorld(self.chevron_posd[i])-dmg:GetDamagePosition()):Length()<30) then
					if (self.chev_health[i]<0 and not self.chev_destroyed[i]) then
						self.chev_destroyed[i] = true;
						if (not (i==8 or i==9)) then
							self.ChevDestroyed = true;
						end
						self.Chevron[i]:Remove();
						self.Entity:SetNWBool("chevron"..i,false);
						if (self.Active) then
							self:AbortDialling();
							if(IsValid(self.EventHorizon)) then
								if(not self.EventHorizon:IsOpen()) then
									timer.Simple(3, function()
										if (IsValid(self.Entity) and self.IsOpen) then self:AbortDialling(); end
									end);
								end
							end
						end
						local effectdata = EffectData()
						effectdata:SetStart(self.Entity:LocalToWorld(self.chevron_posd[i])) // not sure if we need a start and origin (endpoint) for this effect, but whatever
						effectdata:SetOrigin(self.Entity:LocalToWorld(self.chevron_posd[i]))
						effectdata:SetScale(2)
						util.Effect( "HelicopterMegaBomb", effectdata )
					else
						self.chev_health[i] = self.chev_health[i]-damage;
					end
				end
			end
		end
	end

	if (dmg:GetDamageType() == DMG_BLAST) then
		if (self.WormHoleJumpNDMG>0 and IsValid(self.EventHorizon) and self.EventHorizon:IsOpen() and self.Outbound and not self.Jumped) then
			if (self.WormHoleJumpDMG>self.WormHoleJumpNDMG) then
				if (math.random(1,4)==4) then
					self:AbortDialling();
				else
					self:WormHoleJump();
				end
				self.WormHoleJumpDMG = 0;
				return
			else
				self.WormHoleJumpDMG = self.WormHoleJumpDMG + damage*math.Rand(0.5,1.1); -- bit randomise
			end
		end

		if (damage<=30) then
			self:Flicker(1);
		elseif (damage>30 and damage<=60) then
			self:Flicker(2);
		elseif (damage>60) then
			self:Flicker(3);
		end
	end

	// WormholeJump call is in gate_nuke
end

function ENT:SubFlicker(target,jump,super,dly)
	if (not IsValid(self.Entity)) then return end
	local delay = 0.5;
	if (jump) then
		if (self.EventHorizon.Unstable) then return end
		delay = 4.0;
		if (super) then	delay = 6.0; end
	end                   
	if (dly) then delay = dly end
	if (self.Jumping and not jump) then return end
	self.EventHorizon:Flicker()
	if (target) then
		self.Target.EventHorizon:Flicker()
	end
	timer.Simple(delay,function()
		if (self.Jumping) then return end
	    if(IsValid(self.EventHorizon) and self.EventHorizon:IsOpen())then
			self.EventHorizon:Flicker(true)
		    if (IsValid(self.Target) and not self.Target.IsSupergate and IsValid(self.Target.EventHorizon) and self.Target.EventHorizon:IsOpen()) then
				self.Target.EventHorizon:Flicker(true)
			end
		end
	end)
end

function ENT:Flicker(magnitude)
	if (not IsValid(self.Entity)) then return end
	if (not magnitude) then return end
	if(self.IsOpen) then
		if(not(IsValid(self.EventHorizon)) or IsValid(self.EventHorizon) and not self.EventHorizon:IsOpen()) then return end
		local target = false
		if (IsValid(self.Target) and not self.Target.IsSupergate and IsValid(self.Target.EventHorizon) and self.Target.EventHorizon:IsOpen()) then target = true end
		for i=1,magnitude do
			self:SubFlicker(target);
		end
	end
end

util.AddNetworkString("StarGate.VGUI.Menu");

--#################  Use - Open the Dial Menu @aVoN
function ENT:Use(p)
	if self.Cooldown or self.jammed then return end;
	if(IsValid(p) and p:IsPlayer()) then
		if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,self.Entity) == false) then return end; -- Not allowed to dial!
		if (self.DisMenu) then return end;
		local groupmenus = GetConVar("stargate_group_system"):GetBool();
		local alternatemenu = GetConVar("stargate_different_dial_menu"):GetBool();
		local candialg = GetConVar("stargate_candial_groups_menu"):GetBool();

		local allowed = true;
		if(hook.Call("StarGate.Player.CanModifyGate",GAMEMODE,p,self.Entity) == false) then
			-- He is not allowed to modify stuff!
			if (alternatemenu) then
				return false; -- no menu
			else
				allowed = false;
			end
		elseif(self.GateSpawnerProtected) then -- It's a protected gate. Can this user change it?
			allowed = hook.Call("StarGate.Player.CanModifyProtectedGate",GAMEMODE,p,self.Entity);
			if(allowed == nil) then allowed = (p:IsAdmin() or game.SinglePlayer()) end;
			if(not allowed and alternatemenu) then
				return false; -- no menu
			end
		end

		net.Start("StarGate.VGUI.Menu");
		net.WriteEntity(self.Entity);
		if (allowed) then
			if (alternatemenu) then
				net.WriteInt(-1,8);
			else
				net.WriteInt(0,8);
			end
		else
			net.WriteInt(2,8);
			net.WriteBit(candialg);
		end
		net.Send(p);
	end
end

function ENT:CAP_CanModify(ply)
	if (not IsValid(ply)) then return false end
	local allowed = true;
	if(hook.Call("StarGate.Player.CanModifyGate",GAMEMODE,ply,self.Entity) == false) then
		allowed = false;
	elseif(self.GateSpawnerProtected) then
		allowed = hook.Call("StarGate.Player.CanModifyProtectedGate",GAMEMODE,ply,self.Entity);
		if(allowed == nil) then allowed = (ply:IsAdmin() or game.SinglePlayer()) end;
	end
	return allowed;
end

--##################################
--#### Wire Inputs
--##################################

function ENT:TriggerInput(k,v,mobile,mdhd)
	self:TriggerInputDefault(k,v,mobile,mdhd);
end

--################# Wire input @aVoN
function ENT:TriggerInputDefault(k,v,mobile,mdhd)
	if(k == "Disable Autoclose") then
		self.DisAutoClose = util.tobool(v);
		self.Entity:SetNWBool("DisAutoClose",util.tobool(v));
	elseif(k == "Disable Menu") then
		self.DisMenu = util.tobool(v);
		self.Entity:SetNWBool("DisMenu",util.tobool(v));
	elseif(k == "Dial Address") then
		if ((self:GetWire("Dial Address",0) >= 1 or mobile and IsValid(mdhd) and mdhd:GetWire("Dial Address",0) >= 1) and not self.Active and self:CheckEnergy(true,true)) then
			local candialg = GetConVar("stargate_candial_groups_wire"):GetInt()
			if (self:GetLocale()==true or self.Entity:GetClass()=="stargate_supergate") then candialg = 0 end
			local char = string.char(v):upper();
			local a = self.DialledAddress;
			if(v == StarGate.KeyEnter and (#a >= 6 and #a <= 9 and candialg==1 or #a == 6 or #a == 7 and a[7] == "#")) then -- Enter Key
				if(#a == 6 or #a == 7 and a[7] != "#") then
					table.insert(self.DialledAddress,"#");
				end
				if (#self.DialledAddress >= 7 and #self.DialledAddress <= 9) then
					table.insert(self.DialledAddress,"DIAL");
					local fast = self:GetWire("Dial Mode",0) == 1;
					local nox = self:GetWire("Dial Mode",0) >= 2;
					if (mobile and IsValid(mdhd)) then fast = mdhd:GetWire("Dial Mode",0) >= 1; nox = mdhd:GetWire("Dial Mode",0) >= 2; end
					if(self.Entity:GetClass() == "stargate_orlin") then fast = true end; -- orlin is ALWAYS dialling fast!
					if(self.Entity:GetClass()=="stargate_supergate" and nox) then nox = fasle; fast = true end
					if (nox) then
						self:SetDialMode(false,true,true); -- If DialMode is 0, we dial slowly, if Dial Mode is greater we dial fast
						self.NoxDialingType = true;
						self:NoxStartDialling();
					else
						self:SetDialMode(false,fast); -- If DialMode is 0, we dial slowly, if Dial Mode is greater we dial fast
						self:StartDialling();
					end
				end
			elseif(v == 127) then -- Backspace key
				table.remove(self.DialledAddress);
			elseif(char:find("["..self.WireCharters.."]")) then -- Only alphanumerical and the @, #
				if(#self.DialledAddress < 9 and not table.HasValue(self.DialledAddress,char)) then
					table.insert(self.DialledAddress,char);
				end
			elseif ((v == StarGate.KeyEnter or v == 127) and self.Active and not self:IsShutdown()) then
				self:AbortDialling();
			end
		end
	elseif(k == "Start String Dial") then
		if ((self:GetWire("Start String Dial",0) >= 1 or mobile and IsValid(mdhd) and mdhd:GetWire("Start String Dial",0) >= 1) and not self.Active and self:CheckEnergy(true,true)) then
			local candialg = GetConVar("stargate_candial_groups_wire"):GetInt()
			if (self:GetLocale()==true or self.Entity:GetClass()=="stargate_supergate") then candialg = 0 end
			local a = self:GetWire("Dial String",""):upper():TrimExplode("");
			if (mobile and IsValid(mdhd)) then a = mdhd:GetWire("Dial String",""):upper():TrimExplode(""); end
			if (#a >= 6 and #a <= 9 and candialg==1 or #a == 6 or #a == 7 and a[7] == "#") then
				local abort = false
				self.DialledAddress = {}
				for _,v in pairs(a) do
					if (not abort and not table.HasValue(self.DialledAddress,v) and v:find("["..self.WireCharters.."]")) then
						table.insert(self.DialledAddress,v);
					else
						abort = true;
					end
				end
				if (not abort) then
					if(#a == 6 or #a == 7 and a[7] != "#") then
						table.insert(self.DialledAddress,"#");
					end
					if (#self.DialledAddress >= 7 and #self.DialledAddress <= 9) then
						table.insert(self.DialledAddress,"DIAL");
						local fast = self:GetWire("Dial Mode",0) == 1;
						local nox = self:GetWire("Dial Mode",0) >= 2;
						if (mobile and IsValid(mdhd)) then fast = mdhd:GetWire("Dial Mode",0) >= 1; nox = mdhd:GetWire("Dial Mode",0) >= 2; end
						if(self.Entity:GetClass() == "stargate_orlin") then fast = true end; -- orlin is ALWAYS dialling fast!
						if(self.Entity:GetClass()=="stargate_supergate" and nox) then nox = fasle; fast = true end
						if (nox) then
							self:SetDialMode(false,true,true); -- If DialMode is 0, we dial slowly, if Dial Mode is greater we dial fast
							self.NoxDialingType = true;
							self:NoxStartDialling();
						else
							self:SetDialMode(false,fast); -- If DialMode is 0, we dial slowly, if Dial Mode is greater we dial fast
							self:StartDialling();
						end
					end
				end
			end
		end
	elseif(k == "Close") then
		if (v >= 1) then
			if (self.WireManualDial) then
				local n = table.getn(self.WireDialledAddress);
				local action = self.Sequence:New();
				action = self.Sequence:OnButtonDialFail(n,true);
				action = action + self.Sequence:DialFail(nil,true);
				self:RunActions(action);
			else
				self:AbortDialling();
			end
		end
	elseif(k == "Set Point of Origin") then
		if (v==1) then
			self.Entity:SetNetworkedInt("Point_of_Origin",1);
		elseif (v>=2) then
			self.Entity:SetNetworkedInt("Point_of_Origin",2);
		else
			self.Entity:SetNetworkedInt("Point_of_Origin",0);
		end
	elseif(k == "Transmit") then
		if (self.IsOpen and IsValid(self.Target) and self.Target.IsStargate and self.Target.IsOpen) then
			self.Target:SetWire("Received", v);
		end
	elseif(k == "Event Horizon Type") then
		if (table.HasValue(StarGate.EventHorizonTypes,v) and not self.IsSuperGate and not self.IsStargateOrlin) then
			self.EventHorizonType = v;
			self:SetNWString("EventHorizonType",self.EventHorizonType);
			if (IsValid(self.EventHorizon)) then
				self.EventHorizon:EHType(true);
			end
		end
	elseif(k == "Event Horizon Color") then
		if (v.x==0 and v.y==0 and v.z==0) then
			local type = self.EventHorizonType;
			local Data = StarGate.EventHorizonTypes[type] or {}
			if (Data.Color) then v = Vector(Data.Color.r,Data.Color.g,Data.Color.b) end
		end
		self.EHColor = Color(v.x,v.y,v.z);
		self:SetNWVector("EHColor",v)
		if (IsValid(self.EventHorizon)) then
			self.EventHorizon:SetEHColor(self.EHColor);
		end
	end
end

--################# Wire ouput - Relay to a mobile DHD @aVoN
function ENT:WireOutput(k,v)
	if (not self.DHDRange or not IsValid(self.Entity)) then return end
	if (IsValid(self.LockedMDHD)) then
		self.LockedMDHD:SetWire(k,v);
	else
		local pos = self.Entity:GetPos();
		for _,e in pairs(ents.FindByClass("mobile_dhd")) do
			if(IsValid(e) and not IsValid(e.LockedGate)) then
				local e_pos = e:GetPos();
				local dist = (e_pos - pos):Length();
			 	if (dist <= self.DHDRange) then
					local add = true;
					for _,gate in pairs(self:GetAllGates()) do
						if(gate ~= self.Entity and (gate:GetPos() - e_pos):Length() < dist and not IsValid(gate.LockedMDHD)) then
							add = false;
							break;
						end
					end
					if(add) then
						e:SetWire(k,v);
					end
			 	end
			end
		end
	end
end

--################# If DHD is concept added by AlexALX
function ENT:IsConceptDHD()
	if(not (self and self.FindDHD)) then return false end;
	if (self.Entity:GetClass()=="stargate_atlantis" or self.Entity:GetClass()=="stargate_universe") then return true end
	if (self.Entity:GetNetworkedInt("Point_of_Origin",0)==1) then
		return true;
	elseif (self.Entity:GetNetworkedInt("Point_of_Origin",0)>=2) then
		return false;
	end
	for _,v in pairs(self:FindDHD()) do
		if(v:IsValid() and v:GetClass() == "dhd_concept") then
			return true;
		end
	end
	if (table.Count(self:FindDHD())==0) then return true end
	return false;
end

--######################## @Alex, aVoN -- snap gates to cap ramps
function ENT:CartersRamps(t)
	local e = t.Entity;
	if(not IsValid(e)) then return end;
	local RampOffset = StarGate.RampOffset.Gates;
	local mdl = e:GetModel();
	if(RampOffset[mdl]) then
		local i = 1;
		-- Check, if there is already a gate snapped to it...
		for _,v in pairs(StarGate.GetConstrainedEnts(e,2) or {}) do
			if(IsValid(v) and v:GetClass():find("stargate_")) then
				if (RampOffset[mdl][3] and i==1) then i = 3; else return end;
			end
		end
		-- Freeze ramp
		local phys = e:GetPhysicsObject();
		if(phys:IsValid()) then
			phys:EnableMotion(false);
		end
		if (RampOffset[mdl][i+1]) then
			self.Entity:SetAngles(e:GetAngles() + RampOffset[mdl][i+1]);
		else
			self.Entity:SetAngles(e:GetAngles());
		end
		self.Entity:SetPos(e:LocalToWorld(RampOffset[mdl][i]));
		constraint.Weld(self.Entity,e,0,0,0,true);
		e.CDSIgnore = true; -- Fixes Combat Damage System destroying Ramps - http://mantis.39051.vs.webtropia.com/view.php?id=45
		return e;
	end
end

--######################## Check if gate in ramp (for gatespawner) by AlexALX
function ENT:CheckRamp()
	if (self.Entity:GetClass()=="stargate_orlin"||self.Entity:GetClass()=="stargate_supergate") then return false; end;
	for _,e in pairs(ents.FindInSphere(self.Entity:GetPos(),100)) do
		if (e.IsRamp) then
			constraint.Weld(self.Entity,e,0,0,0,true);
			break;
		end
	end
end

-- simple energy transfer function @AlexALX
function ENT:TransferResource(resname,value)
	if not resname then return -1; end
	resname = resname:lower();
	value = tonumber(value);
	local is_energy = (resname=="energy")
	local Transfer = self.EnergyTransfer
	local NextTransfer = self.NextTransfer
	local MaxTransfer = self.MaxEnergyTransfer
	if not is_energy then
		Transfer = self.ResTransfer
		NextTransfer = self.NextResTransfer
		MaxTransfer = self.MaxResTransfer
	end
	if not self.HasRD or not value or not Transfer then return -1; end
	if not is_energy and table.Count(self.ResTransferClasses)>0 and not self.ResTransferClasses[resname] then return -1 end
	if NextTransfer and NextTransfer>CurTime() then return 0; end
	if self.IsOpen and IsValid(self.Target) and self.Target.IsOpen then
		local origin = self;
		local target = self.Target;
		if (value<0) then
			value = value * -1;
			origin = self.Target;
			target = self;
		end
		if MaxTransfer>0 and value>MaxTransfer then value = MaxTransfer end
		if (StarGate.WireRD.Connected(target) and origin:GetResource(resname)>0) then
			-- we can only transport energy at both ends due to stargate rules, also if there is iris then block tranfser
			if not is_energy and not origin.Outbound or origin:IsBlocked(true) or target:IsBlocked(true) then return 0 end
			local energy = origin:GetResource(resname);
			local capacity = target:GetNetworkCapacity(resname);
			local tenergy = target:GetResource(resname);
			if (value>capacity) then value = capacity end
			if (energy<value) then value = energy end
			if (tenergy+value>capacity) then value = capacity-tenergy end
			if (value>0) then
				origin:ConsumeResource(resname,value);
				target:SupplyResource(resname,value);
				if is_energy then
					self.NextTransfer = CurTime()+self.EnergyTransInterval;
				else
					self.NextResTransfer = CurTime()+self.ResTransInterval;
				end
				return value;
			end
		end
	end
	return 0;
end

function ENT:FakeDelay() return true end;

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end