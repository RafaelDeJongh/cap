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
--[[
	Stargate Base Code
	Copyright (C) 2011 Madman07, Llapp
]]--

-- Some necessary dummies which are getting always called
function ENT:ActivateRing() end;
function ENT:ActivateChevron() end;

--##################################
--#### Sequence Handling & Behaviour
--##################################

--#################  It's a helper function for the RunActions @aVoN
local function StartSequence(data) -- Helper-Function
	if(data.f) then
		data.f(unpack(data.v or {}));
	else -- It's a package. Parse it at one piece - No timers :)
		for k,v in pairs(data) do
			if(k ~= "d" and v.f) then -- The d key is our delay! and if v.f does not exists, this might be a pause
				v.f(unpack(v.v or {}));
			end
		end
	end
end

--#################  Parse the actions and allocate them to a timer @aVoN
function ENT:RunActions(action)
	local s = "StarGate_"..self.Entity:EntIndex().."_"; -- The uniqueID of the timers
	local delay = 0; -- Timer delay
	local temp = {}; -- Here we store out new timers too.
	--######### Prepare timers (make packages - Actions with no delay between each other)
	local package;
	for _,v in pairs(action) do
		if(v.f or v.pause) then -- Just valid stuff please!
			v.d = tonumber(v.d) or 0; -- Prevents a bug
			--#### No delay - Add it to a package
			if(v.d == 0 and not v.pause) then
				package = package or {};
				table.insert(package,v);
			elseif(package) then
				--#### We have a delay and a package exists. At this point, some sequences failed, because they sometimes mixed up the timers.
				-- Lets say, this package has a delay of 0 seconds so there is no delay between the package and the next timer. So you have two timers which are "ran at the same time"
				-- Sadly the last added timer runs (in most cases) before the previous added so the sequence is mixed up and the script fails randomly. So we add the
				-- Next sequence to our package, so the package has first 0-delay actions and then a delayed. Now the package is delayed and ran in only one timer which can't mixup!
				package.d = v.d; -- Let the package derive the delay from our "next" sequence
				table.insert(package,v);
				table.insert(temp,package);
				package = nil;
			else
				table.insert(temp,v);
			end
		end
	end
	if(package) then table.insert(temp,package) end; -- A package which was all at a delay of 0 seconds ended in that action. Let's dont forget it!
	--######### Register timers
	for _,v in pairs(temp) do
		if(not v.pause) then
			self.Actions = (self.Actions or 0) + 1; -- Tell our gate, how much timers we have
			timer.Create(s..self.Actions,delay,1,function() StartSequence(v) end);
		end
		delay = delay + (tonumber(v.d) or 0); -- Prevents a bug
	end
end

--################# Stops any running actions (by e.g. a system fault)
function ENT:StopActions()
	local s = "StarGate_"..self.Entity:EntIndex().."_"; -- The uniqueID of the timers
	for k=1,(self.Actions or 0) do
		timer.Remove(s..k);
	end
	self.Actions = 0; -- Reset
end

--################# Pause any running actions (by e.g. slow dial) by AlexALX
function ENT:PauseActions(unpause, target)
	local s = "StarGate_"..self.Entity:EntIndex().."_"; -- The uniqueID of the timers
	if (unpause or not target) then
		for k=1,(self.Actions or 0) do
			if (unpause) then
				timer.UnPause(s..k);
			else
				timer.Pause(s..k);
			end
		end
	else
		timer.Simple(0.5,function()
			if (IsValid(self) and IsValid(self.Target) and IsValid(self.Target.Target) and self.Target.Target == self.Entity) then
				for k=1,(self.Actions or 0) do
					timer.Pause(s..k);
				end
			end
		end)
	end
end

--#################  Sets the available or not available status for the stargate @aVoN
function ENT:SetStatus(b,u,do_not_set_wire_active,newactive,fast)
	self.IsOpen = b;
	self.Dialling = u;
	if(IsValid(self.Entity)) then
		local active = not do_not_set_wire_active and util.tobool(u or b); -- If "do_not_set_wire_active" is set, (e.g. on slow dial in), the gate won't become "Active" in wire as long as this changes!
		self.Active = active;
		if (newactive and not do_not_set_wire_active) then
			self.NewActive = true;
			self:SetWire("Active",1);
		else
			self.NewActive = active;
			self:SetWire("Active",active);
		end
		self:SetWire("Open",util.tobool(b));
		self:SetWire("Inbound",util.tobool(active and not self.Outbound));
		if (active or newactive) then
			if (not self.Outbound or self.DialType.Fast or self.NoxDialingType) then
				if (self.NoxDialingType) then
					self:SetWire("Dialing Mode",2);
				else
					if (self.WireManualDial) then
						self:SetWire("Dialing Mode",0);
					else
						self:SetWire("Dialing Mode",1);
					end
				end
			else
				if (not fast) then fast = 0 end
				self:SetWire("Dialing Mode",fast);
			end
		else
			self:SetWire("Dialing Mode",-1);
		end
	end
end

--################# Prevents GMod from not sending NWorked data if the entity is not in the players Field of View @aVoN
--function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end;

--##################################
--#### Energy
--##################################

--################# Check connection type and prepare basic energy calculation
function ENT:CheckConnection()
	if (not self.HasRD) then return true end -- without RD always have energy

	local Sclass = self:GetClass();

	local isgalaxy = 0;
	local issgu = 0;

	-- calculate power consumption, notusual gates take much more energy
	-- make global variables, used in next function
	if (#self.DialledAddress==9) then self.ConnectionGalaxy = true
	else self.ConnectionGalaxy = false end
	if self.ConnectionGalaxy then isgalaxy = 1; end

	if (#self.DialledAddress==10 or Sclass == "stargate_supergate") then self.ConnectionSGU = true
	else self.ConnectionSGU = false end
	if self.ConnectionSGU then issgu = 1; end
	if (Sclass == "stargate_supergate") then issgu = 2; end

	-- our consumption, used in next funciton
	self.EnergyConsume = (self.GalaxyConsumption*isgalaxy + self.SGUConsumption*issgu + 1);
	self.LastDistance = 0;
	self.LastEnergy = 0;
end

--################# Check if gate are powered somehow and if source is capable of handling gate consumption
function ENT:HaveEnergy(check,iris,first)
	if (not self.HasRD) then return true end -- without RD always have energy
	if(not util.tobool(GetConVar("stargate_energy_dial"):GetInt()))then return true end;
	if(self.GateSpawnerSpawned and not util.tobool(GetConVar("stargate_energy_dial_spawner"):GetInt()))then return true end;
	local energy = false;
	local target = util.tobool(GetConVar("stargate_energy_target"):GetInt());
	if (not IsValid(self.Target) or not self.IsOpen) then target = false; end
	local en = self:GetResource("energy");
	local t_en = 0;
	local distance = 100;
	if (self.LastDistance!=0) then distance = self.LastDistance; end;
	if(IsValid(self.Target)) then distance = (self:GetPos() - self.Target:GetPos()):Length(); end;
	if (IsValid(self.Target) and self.Target == self.Entity) then distance = 10000 end
	local consume = distance * self.EnergyConsume;
	if (self.ConnectionSGU) then consume = consume + self.SGUAdd; elseif (self.ConnectionGalaxy) then consume = consume + self.GalaxyAdd; else consume = consume + self.ChevAdd; end
	if(not self.ConnectionSGU and not self.ConnectionGalaxy)then consume = consume / self.ChevConsumption end;
	--  energy :)
	if (iris) then consume = 500 end
	if(en >= consume)then energy = true else energy = false end;
	if (not check or iris) then
		if (not iris) then
			if (target) then
				t_en = self.Target:GetResource("energy");
			end
			if (t_en>0 and en>=consume/2 and t_en>=consume/2) then
				self.Target:ConsumeResource("energy",consume/2);
				self:ConsumeResource("energy",consume/2);
				energy = true;
			elseif (t_en<=0 or t_en>0 and en>=consume and t_en<consume/2) then
				self:ConsumeResource("energy",consume);
				if(en >= consume) then energy = true; end
			elseif (t_en>0 and en<consume/2 and t_en>=consume) then
				self.Target:ConsumeResource("energy",consume);
				if (t_en>=consume) then energy = true; end
			end
		else
			self:ConsumeResource("energy",consume);
		end
	end
	if(not iris and (not self.ConnectionSGU and not self.ConnectionGalaxy and not energy or check and not energy)) then
		for k,v in pairs(self:FindPowerDHD()) do -- look for other power sources -- look for dhd :)
			if(IsValid(v))then energy = true end
		end
	end
	if (not self.ConnectionSGU and not self.ConnectionGalaxy and not check and not iris and target) then
		for k,v in pairs(self.Target:FindPowerDHD()) do -- look for other power sources -- look for dhd :)
			if(IsValid(v))then energy = true end
		end
	end
	if(self:FindBlackHole() or not iris and target and self.Target:FindBlackHole())then energy = true end; -- black hole can power everything
	-- some cool effects
	if (not energy and not check) then self:Flicker(1); self.LastDistance = distance; end;
	if (check and en>0) then energy = true; end
    return energy;
end

function ENT:CheckEnergy(dhd, no_consume)
	if (not self.HasRD) then return true end -- without RD always have energy
	if(not util.tobool(GetConVar("stargate_energy_dial"):GetInt()))then return true end;
	if(self.GateSpawnerSpawned and not util.tobool(GetConVar("stargate_energy_dial_spawner"):GetInt()))then return true end;
	local energy = false;
	local en = self:GetResource("energy");
	if (dhd or self.LastEnergy==0) then self.LastEnergy = en; else en = self.LastEnergy end
	local distance = 100;
	if(IsValid(self.Target) and self.Target!=self.Entity) then distance = (self:GetPos() - self.Target:GetPos()):Length(); end;
	local consume = distance * self.EnergyConsume;
	if (self.ConnectionSGU) then consume = consume + self.SGUAdd; elseif (self.ConnectionGalaxy) then consume = consume + self.GalaxyAdd; else consume = consume + self.ChevAdd; end
	if(not self.ConnectionSGU and not self.ConnectionGalaxy)then consume = consume / self.ChevConsumption end;
	if (self.ConnectionSGU) then
		consume = consume*2;
	else
		consume = consume*5;
	end
	--  energy :)
	if(en >= consume)then energy = true else energy = false end;
	if(dhd and en > 0) then energy = true end;
	if (not no_consume) then
		self:ConsumeResource("energy",consume);
	end
	if(not self.ConnectionSGU and not self.ConnectionGalaxy and not energy or dhd and not energy) then
		for k,v in pairs(self:FindPowerDHD()) do -- look for other power sources -- look for dhd :)
			if(IsValid(v))then energy = true end
		end
	end
	if(self:FindBlackHole())then energy = true end; -- black hole can power everything
    return energy;
end

function ENT:CheckEnergyDHD()
	if (not self.HasRD) then return false end
	if(not util.tobool(GetConVar("stargate_energy_dial"):GetInt()))then return false end;
	if(self.GateSpawnerSpawned and not util.tobool(GetConVar("stargate_energy_dial_spawner"):GetInt()))then return false end;
	local energy = false;
	local en = self:GetResource("energy");
	if(en > 0) then energy = true end;
	if(self:FindBlackHole())then energy = true end; -- black hole can power everything
    return energy;
end

function ENT:WireGetEnergy(addr,dist)
	if (addr:Trim()=="") then return 0; end
	local address = string.Explode("",addr);
	if (#address==6 or #address==7 and address[7]!="#") then table.insert(address,"#"); end
	local isgalaxy = 0
	local issgu = 0
	if (#address==8) then isgalaxy = 1 end
	if (#address==9) then issgu = 1 end
	if (self:GetClass()=="stargate_supergate") then issgu = 2 end
	table.insert(address,"DIAL");
	local target = self:FindGate(true,address);
	local distance = 100;
	if(IsValid(target)) then distance = (self:GetPos() - target:GetPos()):Length(); elseif (dist) then distance = -1; end
	if (dist) then return distance; end
	if (not self.HasRD) then return -1 end -- without RD always have energy
	if(not util.tobool(GetConVar("stargate_energy_dial"):GetInt()))then return -1 end;
	if(self.GateSpawnerSpawned and not util.tobool(GetConVar("stargate_energy_dial_spawner"):GetInt()))then return -1 end;
	local enconsume = (self.GalaxyConsumption*isgalaxy + self.SGUConsumption*issgu + 1);
	local energy = 0;
	local en = self:GetResource("energy");
	local consume = distance * enconsume;
	if (#address==10) then consume = consume + self.SGUAdd; elseif (#address==9) then consume = consume + self.GalaxyAdd; else consume = consume + self.ChevAdd; end
	if(#address==8 and self:GetClass()!="stargate_supergate")then consume = consume / self.ChevConsumption end;
	if (issgu) then
		consume = consume*2;
	else
		consume = consume*5;
	end
	--  energy :)
	energy = consume;
	if(#address==8 and self:GetClass()!="stargate_supergate") then
		for k,v in pairs(self:FindPowerDHD()) do -- look for other power sources -- look for dhd :)
			if(IsValid(v))then energy = -1 end
		end
	end
	if(self:FindBlackHole())then energy = -1 end; -- black hole can power everything
    return energy;
end

function ENT:Disconnect()
	self:DeactivateStargate(true)
	if IsValid(self.Target) then self.Target:DeactivateStargate(true) end
end

function ENT:Viru(vir)
  self.Virus = false;
	if(vir)then self.Virus = true end;
end

function ENT:CheckWormJump(target,range,c_range,old_target,groupsystem)
	local result = true;
	local chevs = #self.DialledAddress;
	if (groupsystem) then
		/*if (chevs==10) then
			if (target.IsSupergate or target:GetLocale()) then
				result = false;
			end
			result = false;
		else*/if(chevs==9) then
			if (self.IsUniverseGate) then
				if (not target.IsUniverseGate or target.IsSupergate or c_range!=0 and range>=c_range) then
					result = false;
				end
			else
				if (target.IsUniverseGate or target.IsSupergate or target:GetGateGroup()!=old_target:GetGateGroup()) then
					result = false;
				end
			end
		else
			if (self.IsUniverseGate) then
				if (not target.IsUniverseGate and not target.IsSupergate or c_range!=0 and range>=c_range) then
					result = false;
				end
			else
				if (not target.IsSupergate and self:GetGateGroup()!=target:GetGateGroup()) then
					result = false;
				end
			end
		end
	else
		if(chevs==9) then
			if (self.IsUniverseGate) then
				if (not target.IsUniverseGate or target:GetGalaxy()!=old_target:GetGalaxy()) then
					result = false;
				end
			else
				if (target.IsUniverseGate or target:GetGalaxy()!=old_target:GetGalaxy()) then
					result = false;
				end
			end
		else
			if (self.IsUniverseGate) then
				if (not target.IsUniverseGate and not target.IsSupergate or target:GetGalaxy()!=old_target:GetGalaxy()) then
					result = false;
				end
			else
				if (target.IsUniverseGate or not target.IsSupergate and target:GetGalaxy()!=old_target:GetGalaxy()) then
					result = false;
				end
			end
		end
	end
	return result;
end

function ENT:WormHoleShutdown(old)
	self:SubFlicker(false,true);
	self.Jumping = true;
	if (IsValid(old)) then
		old:Close();
		old.EventHorizon:Shutdown(true);
	end
	timer.Simple(2,function()
		if (IsValid(self)) then
			self.Jumping = false;
			self:AbortDialling();
		end
	end);
	self.Jumped = true;
	self.Target = self;
end

--################# Jump wormhole to nearest gate
function ENT:WormHoleJump()
	if (self.IsOpen and self.Outbound and IsValid(self.EventHorizon) and self.Entity:GetClass() != "stargate_orlin" and not self.IsSupergate and (not IsValid(self.Target) or not self.Target.jammed)) then
		local old = self.Target;

		if (self.Jumped) then
			self:WormHoleShutdown(old);
			return
		end

		if not IsValid(old) then return end

		local groupsystem = GetConVar("stargate_group_system"):GetBool();

		local gate;
		local dist = 32000;
		local pos = old:GetPos();
		for _,v in pairs(ents.FindByClass("stargate_*")) do
			if ((v.IsGroupStargate or v:GetClass() == "stargate_supergate") and v~=self.Entity and v~=old and not v.IsOpen and not v.IsDialling and v:GetClass() != "stargate_orlin") then
				local sg_dist = (pos - v:GetPos()):Length();
				local range = GetConVar("stargate_sgu_find_range"):GetInt();
				if (not self:CheckWormJump(v,sg_dist,range,old,groupsystem)) then continue end
				if(dist >= sg_dist) then
					dist = sg_dist;
					gate = v;
				end
			end
		end

		if (not IsValid(gate) or #self.DialledAddress==10) then
    		self:WormHoleShutdown(old);
			return
		end

		old:Close();
		old.EventHorizon:Shutdown(true);
		gate.Target = self;
		self.Target = gate;
		self.Jumping = true;
		gate.Jumping = true;
		gate.Outbound = false;

		local action = gate.Sequence:New();

		if gate:GetClass() == "stargate_supergate" then
			gate:InstantLightUp();
		else
			action = action + gate.Sequence:InstantOpen(nil,0.0,true,true,false);
		end

		action = action + gate.Sequence:OpenGate();
		gate:RunActions(action);

		self:SubFlicker(false,true,gate.IsSupergate);

		-- little delay or it will give us nil
		timer.Simple(0.3,function()
			if (IsValid(self) and IsValid(gate) and IsValid(self.EventHorizon)) then
				self.EventHorizon.Target = gate.EventHorizon;
				self.EventHorizon.TargetGate = gate;
			end
		end)
		timer.Simple(3.0,function()
			if (IsValid(self)) then
				self.Jumping = false;
			end
			if (IsValid(gate)) then
				gate.Jumping = false;
			end
		end)
		self.Jumped = true;
	end
end

--##################################
--#### DHD helper functions
--##################################


--################# Find's all DHD's which may call this gate @aVoN
function ENT:FindDHD()
	if (IsValid(self.LockedDHD)) then
		if self.LockedDHD.Disabled then return {} end
		return {self.LockedDHD}
	end
	local pos = self.Entity:GetPos();
	local dhd = {};
	for _,v in pairs(ents.FindByClass("dhd_*")) do
		if (v.IsGroupDHD and not v.Disabled and self.DHDRange and (not IsValid(v.LockedGate) or v.LockedGate==self.Entity)) then
			local e_pos = v:GetPos();
			local dist = (e_pos - pos):Length(); -- Distance from DHD to this stargate
			if(dist <= self.DHDRange) then
				-- Check, if this DHD really belongs to this gate
				local add = true;
				for _,gate in pairs(self:GetAllGates()) do
					if(gate ~= self.Entity and (not IsValid(gate.LockedDHD) or gate.LockedDHD==v) and (gate:GetPos() - e_pos):Length() < dist) then
						add = false;
						break;
					end
				end
				if(add) then
					table.insert(dhd,v);
				end
			end
		end
	end
	return dhd;
end

--################# Find's special DHD's which may power this gate @Mad
function ENT:FindPowerDHD()
	if (IsValid(self.LockedDHD) and (not self.LockedDHD.Destroyed or util.tobool(GetConVar("stargate_dhd_destroyed_energy"):GetInt()))) then 
		if self.LockedDHD.Disabled then return {} end
		return {self.LockedDHD} 
	end
	if (IsValid(self.LockedMDHD)) then return {self.LockedMDHD} end
	if (IsValid(self.LockedDestC)) then return {self.LockedDestC} end
	local pos = self.Entity:GetPos();
	local dhd = {};
	local posibble_dhd = {}

	table.Add(posibble_dhd, ents.FindByClass("mobile_dhd"));
	table.Add(posibble_dhd, ents.FindByClass("goauld_dhd_prop"));
	table.Add(posibble_dhd, ents.FindByClass("gravitycontroller"));
	table.Add(posibble_dhd, ents.FindByClass("destiny_console"));
	table.Add(posibble_dhd, self:FindDHD());

	-- ramp energy for sgu @Llapp
	if(self.Entity:GetClass() == "stargate_universe")then
	    for _,v in pairs(StarGate.GetConstrainedEnts(self.Entity,2) or {}) do
            if(IsValid(v) and not v:GetClass():find("stargate_"))then
   	            if(StarGate.RampOffset.Gates[v:GetModel()])then
				    table.insert(dhd,v);
					return dhd;
     			end
			end
        end
	end

	for _,v in pairs(posibble_dhd) do
		if (v:GetClass()=="dhd_city" or IsValid(v.LockedGate) and v.LockedGate!=self.Entity) then continue end
		local e_pos = v:GetPos();
		local dist = (e_pos - pos):Length(); -- Distance from DHD to this stargate
		local range = self.DHDRange or 1000;
		if(dist <= range) then
			-- Check, if this DHD really belongs to this gate
			local add = true;
			for _,gate in pairs(self:GetAllGates()) do
				if(gate ~= self.Entity and (not IsValid(gate.LockedMDHD) or gate.LockedMDHD==v)
				 and (not IsValid(gate.LockedDestC) or gate.LockedDestC==v) and (gate:GetPos() - e_pos):Length() < dist) then
					add = false;
					break;
				end
			end
			if (v:GetClass():find("dhd_") and v.Destroyed and not util.tobool(GetConVar("stargate_dhd_destroyed_energy"):GetInt())) then
				add = false;
			end
			if(add) then
				table.insert(dhd,v);
			end
		end
	end

	return dhd;
end

--################# Find's Black holes
function ENT:FindBlackHole()
	local pos = self.Entity:GetPos();
	local hole = false;

	for _,v in pairs(ents.FindByClass("black_hole_power")) do
		local e_pos = v:GetPos();
		local dist = (e_pos - pos):Length(); -- Distance from hole to this stargate
		if(dist <= self.DHDRange*4) then
			if not hole then hole = true; end
		end
	end

	return hole;
end

--################# Light every DHD near us up @aVoN
-- Chevron,Delay,NoShutdon (Noshutdown is used, when every DHD near the gate will get "light up" again, when the stagate openes)
function ENT:DHDSetChevron(ch,delay,ns)
	if(not (self and self.FindDHD)) then return end;
	local delay = delay or 0.4;
	if(not self.DialledAddress or (table.getn(self.DialledAddress) < 8 or table.getn(self.DialledAddress) > 10)) then
		self.DialledAddress={"","","","","","","","DIAL"};
		if (IsValid(self.Target)) then
			if (#self.Target.DialledAddress==9) then
				self.DialledAddress={"","","","","","","","","DIAL"};
			elseif (#self.Target.DialledAddress==10) then
				self.DialledAddress={"","","","","","","","","","DIAL"};
			end
		end
	end
	for k,v in pairs(self:FindDHD()) do
		if(v:IsValid() and v.Target ~= self.Entity) then
			if(ch == 1 and not ns) then
				v:Shutdown(0);
			end
			local btn = self.DialledAddress[ch];
			local DialledAddress = self.DialledAddress;
			timer.Create("dhd_chevron"..k..ch..self.Entity:EntIndex(),delay,1,
				function()
					if(IsValid(v)) then
						v:AddChevron(btn,true,true);
						v:SetBusy(10);
						if(ch == table.getn(DialledAddress)) then
							v:SetBusy(0.8); -- Unset busy
						end
					end
				end
			);
		end
	end
end

--################# Disables near DHDs @aVoN
function ENT:DHDSetAllBusy()
	if(not (self and self.FindDHD)) then return end;
	-- Set all DHD's busy during the opening sequence - necessary to avoid some evil bugs
	for _,v in pairs(self:FindDHD()) do
		v:SetBusy(4);
	end
end

--################# Disables near DHDs @aVoN
function ENT:DHDDisable(d,shutdown_all)
	if(not (self and self.FindDHD)) then return end;
	for _,v in pairs(self:FindDHD()) do
		if(v:IsValid()) then
			if(shutdown_all or v.Target ~= self.Entity) then
				v:Shutdown(d);
				v:SetBusy(0.8); -- Unset busy
			end
		end
	end
end



--##################################
--#### Gate finding functions
--##################################



--################# Gets all (valid) gates @aVoN
function ENT:GetAllGates(closed)
	local sg = {};
	local super = "stargate_supergate";
	local class = self.Entity:GetClass();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and not (closed and (v.IsOpen or v.Dialling))) then
			if ((class == super and v:GetClass() == super) or (class != super and v:GetClass() != super)) then
				table.insert(sg,v);
			end
		end
	end
	return sg;
end

--################# Find's a gate to the gateaddress stored in self.DialledAddress
function ENT:FindGate(no_target,addr)

	local groupsystem = GetConVar("stargate_group_system"):GetBool();

	if (not groupsystem) then return self:FindGateGalaxy(no_target,addr); end

	if(not (self.IsOpen or self.Dialling) or no_target) then
		local dialadr = self.DialledAddress;
		if (addr) then dialadr = addr; end
		if(dialadr and (#dialadr >= 8 and #dialadr <= 10)) then
			local gates = {};
			local a = dialadr; -- Fast index (Code shorter);
			local g = self:GetGateGroup();
			for _,v in pairs(self:GetAllGates()) do
				if(v ~= self.Entity) then
					local address = v:GetGateAddress();
					local group = v:GetGateGroup();
					local locale = v:GetLocale();
					local range = (self.Entity:GetPos() - v.Entity:GetPos()):Length();
					local c_range = GetConVar("stargate_sgu_find_range"):GetInt();
					local caddress = false;
					if (address:find(a[1]) and address:find(a[2]) and address:find(a[3]) and address:find(a[4]) and address:find(a[5]) and address:find(a[6]) and not self.Virus and not self.ChevDestroyed and not v.ChevDestroyed) then
						caddress = true;
					end
					if (#dialadr == 8 and
						caddress and
						a[7] == "#" and
						(group == g or self.Entity:GetClass()=="stargate_universe") and
						(self.Entity:GetClass()!="stargate_universe" or
						c_range == 0 or
						c_range > 0 and
						group:len()==3 and
						g:len()==3 and
						range<=c_range)
					) then
						table.insert(gates,v);
					elseif (#dialadr == 9 and self.chev_destroyed and v.chev_destroyed and
						not self.chev_destroyed[8] and
						not v.chev_destroyed[8] and
						not locale and
						not self:GetLocale() and
						caddress and
						string.find(group:sub(1,1),a[7]) and
						a[8] == "#" and
						(g:len()==2 and
						group != g and group:len()==2 or
						c_range > 0 and
						group:len()==3 and
						g:len()==3 and
						(range>c_range))
					) then
						table.insert(gates,v);
					elseif (#dialadr == 10 and self.chev_destroyed and v.chev_destroyed and
						not self.chev_destroyed[8] and
						not self.chev_destroyed[9] and
						not v.chev_destroyed[8] and
						not v.chev_destroyed[9] and
						not locale and
						not self:GetLocale() and
						caddress and
						(string.find(group:sub(1,1),a[7]) and
						string.find(group:sub(2,2),a[8]) and
						string.find(group:sub(3,3),a[9]) and
						group:len()!=2 and g:len()==2 or
						string.find(group:sub(1,1),a[7]) and
						string.find(group:sub(2,2),a[8]) and
						a[9] == "#" and
						group:len()==2 and g:len()!=2)
					) then
						table.insert(gates,v);
					end
				elseif(#dialadr == 10 and string.Implode("",a)==self.ScrAddress.."DIAL") then
					table.insert(gates,v);
				end
			end
			-- We just found ONE gate (what we actually need)
			if(#gates >= 1) then
				local target = gates[1];
				if (#gates > 1 and GetConVar("stargate_atlantis_override"):GetInt()>=1) then
					for k,v in pairs(gates) do
						if (IsValid(v) and v:GetClass()=="stargate_atlantis") then
							target = gates[k];
							break;
						end
					end
				end
				if (no_target) then return target end
				self.Target = target;
				if (self.Entity == self.Target) then return end
				-- Tell the other gate, who is calling
				local n = self.Entity:GetGateAddress();
				local g = self.Entity:GetGateGroup();
				if (n!=self.Target:GetGateAddress() or g!=self.Target:GetGateGroup()) then
					if(n:len() == 6) then
						local hide = GetConVar("stargate_show_inbound_address"):GetInt();
						if (g == self.Target:GetGateGroup()) then
							if (hide==0 or hide==1 and self.Entity:GetPrivate()==true) then
								self.Target.DialledAddress = {"","","","","","","","DIAL"};
							else
								self.Target.DialledAddress = {n:sub(1,1),n:sub(2,2),n:sub(3,3),n:sub(4,4),n:sub(5,5),n:sub(6,6),"#","DIAL"};
							end
						elseif(g != self.Target:GetGateGroup() and g:len() == 2 and self.Target.Entity:GetGateGroup():len()==2) then
							if (hide==0 or hide==1 and self.Entity:GetPrivate()==true) then
								self.Target.DialledAddress = {"","","","","","","","","DIAL"};
							else
								self.Target.DialledAddress = {n:sub(1,1),n:sub(2,2),n:sub(3,3),n:sub(4,4),n:sub(5,5),n:sub(6,6),g:sub(1,1),"#","DIAL"};
							end
						elseif(g != self.Target:GetGateGroup() and g:len() == 2 and self.Target.Entity:GetGateGroup():len()==3) then
							if (hide==0 or hide==1 and self.Entity:GetPrivate()==true) then
								self.Target.DialledAddress = {"","","","","","","","","","DIAL"};
							else
								self.Target.DialledAddress = {n:sub(1,1),n:sub(2,2),n:sub(3,3),n:sub(4,4),n:sub(5,5),n:sub(6,6),g:sub(1,1),g:sub(2,2),"#","DIAL"};
							end
						elseif(g != self.Target:GetGateGroup() and g:len() == 3) then
							if (hide==0 or hide==1 and self.Entity:GetPrivate()==true) then
								self.Target.DialledAddress = {"","","","","","","","","","DIAL"};
							else
								self.Target.DialledAddress = {n:sub(1,1),n:sub(2,2),n:sub(3,3),n:sub(4,4),n:sub(5,5),n:sub(6,6),g:sub(1,1),g:sub(2,2),g:sub(3,3),"DIAL"};
							end
						end
					end
					return;
				end
			end
		end
		self.Target = nil;
	end
end

--################# Find's a gate to the gateaddress stored in self.DialledAddress
function ENT:FindGateGalaxy(no_target,addr)
	if(not (self.IsOpen or self.Dialling)) then
		local dialadr = self.DialledAddress;
		if (addr) then dialadr = addr; end
		if(dialadr and (#dialadr >= 8 and #dialadr <= 10) or no_target) then
			local gates = {};
			local a = dialadr; -- Fast index (Code shorter);
			local g = self:GetGalaxy();
			for _,v in pairs(self:GetAllGates()) do
				if(v ~= self.Entity) then
					local address = v:GetGateAddress();
					local galaxy = v:GetGalaxy();
					--local locale = v:GetLocale();
					local range = (self.Entity:GetPos() - v.Entity:GetPos()):Length();
					local c_range = GetConVar("stargate_sgu_find_range"):GetInt();
					local caddress = false;
					if (address:find(a[1]) and address:find(a[2]) and address:find(a[3]) and address:find(a[4]) and address:find(a[5]) and address:find(a[6]) and not self.Virus and not self.ChevDestroyed and not v.ChevDestroyed) then
						caddress = true;
					end
					if (#dialadr == 8 and
						caddress and
						a[7] == "#" and
						g==galaxy and
						(self.Entity:GetClass()!="stargate_universe" or
						c_range == 0 or
						c_range > 0 and
						v:GetClass()=="stargate_universe" and
						self.Entity:GetClass()=="stargate_universe" and
						range<=c_range)
					) then
						table.insert(gates,v);
					elseif (#dialadr == 9 and
						not self.chev_destroyed[8] and
						not v.chev_destroyed[8] and
						--not locale and
						--not self:GetLocale() and
						caddress and
						a[7] == "@" and
						a[8] == "#" and
						(g!=galaxy or v:GetClass()=="stargate_universe" and
						self.Entity:GetClass()=="stargate_universe" and
						c_range > 0 and
						range>c_range)
					) then
						table.insert(gates,v);
					elseif (#dialadr == 10 and
						not self.chev_destroyed[8] and
						not self.chev_destroyed[9] and
						not v.chev_destroyed[8] and
						not v.chev_destroyed[9] and
						--not locale and
						--not self:GetLocale() and
						caddress and
						a[7] == "@" and
						a[8] == "!" and
						a[9] == "#" and
						(v:GetClass()=="stargate_universe" and
						self.Entity:GetClass()!="stargate_universe" or
						v:GetClass()!="stargate_universe" and
						self.Entity:GetClass()=="stargate_universe")
					) then
						table.insert(gates,v);
					end
				elseif(#dialadr == 10 and string.Implode("",a)==self.ScrAddress.."DIAL") then
					table.insert(gates,v);
				end
			end
			-- We just found ONE gate (what we actually need)
			if(#gates >= 1) then
				local target = gates[1];
				if (#gates > 1) then
					for k,v in pairs(gates) do
						if (IsValid(v) and v:GetClass()=="stargate_atlantis") then
							target = gates[k];
							break;
						end
					end
				end
				if (no_target) then return target end
				self.Target = target;
				if (self.Entity == self.Target) then return end
				-- Tell the other gate, who is calling
				local n = self.Entity:GetGateAddress();
				if (n!=self.Target:GetGateAddress() or g!=self.Target:GetGalaxy()) then
					if(n:len() == 6) then
						local hide = GetConVar("stargate_show_inbound_address"):GetInt();
						if (#dialadr == 8) then
							if (hide==0 or hide==1 and self.Entity:GetPrivate()==true) then
								self.Target.DialledAddress = {"","","","","","","","DIAL"};
							else
								self.Target.DialledAddress = {n:sub(1,1),n:sub(2,2),n:sub(3,3),n:sub(4,4),n:sub(5,5),n:sub(6,6),"#","DIAL"};
							end
						elseif(#dialadr == 9) then
							if (hide==0 or hide==1 and self.Entity:GetPrivate()==true) then
								self.Target.DialledAddress = {"","","","","","","","","DIAL"};
							else
								self.Target.DialledAddress = {n:sub(1,1),n:sub(2,2),n:sub(3,3),n:sub(4,4),n:sub(5,5),n:sub(6,6),"@","#","DIAL"};
							end
						elseif(#dialadr == 10) then
							if (hide==0 or hide==1 and self.Entity:GetPrivate()==true) then
								self.Target.DialledAddress = {"","","","","","","","","","DIAL"};
							else
								self.Target.DialledAddress = {n:sub(1,1),n:sub(2,2),n:sub(3,3),n:sub(4,4),n:sub(5,5),n:sub(6,6),"@","!","#","DIAL"};
							end
						end
					end
					return;
				end
			end
		end
		self.Target = nil;
	end
end

function ENT:GetDelayNN(tgate)
	if (tgate.EventHorizonData.OpeningDelay>self.EventHorizonData.OpeningDelay) then
		return tgate.EventHorizonData.OpeningDelay-self.EventHorizonData.OpeningDelay;
	end
	return 0;
end

function ENT:CalcDelaySlow(target,inbound)
	local t_dly = target.DialSlowDelay
	local teh_dly = target.EventHorizonData.OpeningDelay 
	local dly = self.DialSlowDelay 
	local eh_dly = self.EventHorizonData.OpeningDelay
	if (inbound) then
		if (dly<t_dly) then dly = t_dly end
		if (eh_dly<teh_dly) then dly = dly+(teh_dly-eh_dly) end
		dly = dly - 0.2
	else 
		if (t_dly>dly) then dly = t_dly end
		if (teh_dly>eh_dly) then dly = dly+(teh_dly-eh_dly) end
		--dly = dly - 0.1
	end
	return dly
end

function ENT:CalcDelayFast(target,inbound)
	local t_dly = target.DialFastTime
	local teh_dly = target.EventHorizonData.OpeningDelay 
	local dly = self.DialFastTime 
	local eh_dly = self.EventHorizonData.OpeningDelay
	if (inbound) then
		if (dly<t_dly) then dly = t_dly end
		if (eh_dly<teh_dly) then dly = dly+(teh_dly-eh_dly) end
	else 
		if (t_dly>dly) then dly = t_dly end
		if (teh_dly>eh_dly) then dly = dly+(teh_dly-eh_dly) end
	end
	if (dly>self.DialFastTime) then dly = dly-self.DialFastTime;
	else dly = 0 end
	return dly
end

function ENT:DialSlowTime(chevs,caller)
	return 0
end 

--##################################
--#### Duplicator Entity Modifiers (for the gates)
--##################################

--################# Sets a new value to one modifier @aVoN
function ENT:SetEntityModifier(k,v)
	self.Duplicator = self.Duplicator or {};
	self.Duplicator[k] = v;
	duplicator.StoreEntityModifier(self.Entity,"StarGate",self.Duplicator);
end

-- FIXME: Maybe a recode? The PostEntityPaste etc functions are already used by Wire/RD2 so I do not want to override them.
function ENT.DuplicatorEntityModifier(_,e,data)
	if(data) then
		for k,v in pairs(data) do
			if(k == "Address") then
				e:SetGateAddress(v);
			end
			if(k == "Group") then
				e:SetGateGroup(v);
			end
			if(k == "Name") then
				e:SetGateName(v);
			end
			if(k == "Private") then
				e:SetPrivate(v);
			end
			if(k == "Locale") then
				e:SetLocale(v);
			end
			if(k == "Galaxy") then
				e:SetGalaxy(v);
			end
			if(k == "Blocked") then
				e:SetBlocked(v);
			end
			e:SetEntityModifier(k,v);
		end
	end
end
duplicator.RegisterEntityModifier("StarGate",ENT.DuplicatorEntityModifier);

util.AddNetworkString("RefreshGateList")
util.AddNetworkString("RemoveGateFromList")

function ENT:RefreshGateList(type,value,typ,pl)
	if not IsValid(self.Entity) then return end
	net.Start( "RefreshGateList" )
	net.WriteInt(self.Entity:EntIndex(), 16)
	net.WriteString(self.Entity:GetClass())
	net.WriteBit(self.IsGroupStargate)
	net.WriteString( type );
	net.WriteString( typ or "" );
	if (typ=="bool") then
		net.WriteBit(value)
	elseif (typ=="vector") then
		net.WriteVector(value)
	else
		net.WriteString(value)
	end
	if (pl) then
		net.Send(pl)
	else
		net.Broadcast()
	end
end

function ENT:SendGateInfo(pl)
	local v = self;
	local info = {}
	info["ent"] = v:EntIndex();
	info["groupgate"] = v.IsGroupStargate or false;
	info["address"] = v:GetGateAddress();
	info["group"] = v:GetGateGroup();
	info["name"] = v:GetGateName();
	info["private"] = v:GetPrivate();
	info["blocked"] = v:GetBlocked();
	info["locale"] = v:GetLocale();
	info["galaxy"] = v:GetGalaxy();
	info["class"] = v:GetClass();
	info["pos"] = v:GetPos();

	local t = 0;
	for k,i in pairs(info) do
		t = t + 0.01;
		local typ = "";
		if (type(i)=="boolean") then typ = "bool" elseif (type(i)=="Vector") then typ = "vector" end
		timer.Simple(t,function() if (IsValid(v)) then v:RefreshGateList(k,i,typ,pl) end end);
	end
end

function ENT:RemoveGateFromList()
	net.Start( "RemoveGateFromList" )
		net.WriteInt(self.Entity:EntIndex(), 16)
	net.Broadcast()
end

--##################################
--#### Name/Address/Private Handling
--##################################

-- Address interaction - Use this for your own scripts

function ENT:CheckAddress(address,group)
	if (address=="") then return true end
	local letters = address:TrimExplode("");
	local lettersg = group:TrimExplode("");
	if (not GetConVar("stargate_group_system"):GetBool()) then lettersg = {} end
	local text = "";
	local add = true;
	for _,v in pairs(letters) do
		if(#lettersg>=1 and v:find(lettersg[1]) or #lettersg>=2 and v:find(lettersg[2])) then
			return false;
		end
		if(not text:find(v) and (#lettersg==0 or add)) then
			text = text..v;
		else
			return false;
		end
	end
	return true;
end

function ENT:CheckGroup(group,address)
	if (address=="") then return true end
	local lettersa = address:TrimExplode("");
	local letters = group:TrimExplode("");
	local text = "";
	if (self.Entity:GetClass()=="stargate_universe") then
		local add1 = true;
		local add2 = true;
		local add3 = true;
		for _,v in pairs(lettersa) do
			if(#letters>=1 and v:find(letters[1])) then
				return false;
			end
			if(#letters>=2 and v:find(letters[2])) then
				return false;
			end
			if(#letters==3 and v:find(letters[3])) then
				return false;
			end
		end
		if (letters[1]=="#") then add1 = false end
		if (letters[2]=="#") then add2 = false end
		local i = 1
		for _,v in pairs(letters) do
			if((add1 and i==1 or add2 and i==2 or add3 and i==3) and not text:find(v)) then
				text = text..v;
			else
				return false;
			end
			i = i+1;
		end
	else
		local add1 = true;
		local add2 = true;
		for _,v in pairs(lettersa) do
			if(#letters>=1 and v:find(letters[1])) then
				return false;
			end
			if(#letters>=2 and v:find(letters[2])) then
				return false;
			end
		end
		local i = 1
		for _,v in pairs(letters) do
			if((add1 and i==1 or add2 and i==2) and not text:find(v)) then
				text = text..v;
			else
				return false;
			end
			i = i+1;
		end
	end
	return true;
end

--################# Retrieves the address of this Stargate @aVoN
function ENT:GetGateAddress()
	return self.GateAddress or "";
end

--################# Sets the address @aVoN
function ENT:SetGateAddress(s)
	if (self.Entity:GetClass()=="stargate_orlin") then return end
	s = tostring(s or ""):gsub("[^"..self.WireCharters:gsub("#","").."]","");
	if(s:len() == 6 or s == "") then
		if not self:CheckAddress(s,self.GateGroup) then return end
		local address = s:upper();
		address = hook.Call("StarGate.SetGateAddress",GAMEMODE,self.Entity,self.GateAddress or "",address) or address;
		if(not (address and (tostring(address):len() == 6 or address == ""))) then return end;
		self.GateAddress = address;
		self:SetEntityModifier("Address",address); -- Entity Modifiers for Duplicator
		self.Entity:SetNetworkedString("Address",address);
		self:RefreshGateList("address",self.GateAddress);
	end
end

--################# Get the group of this gate by AlexALX
function ENT:GetGateGroup()
	if (not GetConVar("stargate_group_system"):GetBool()) then return "" end
	return self.GateGroup or "";
end

--################# Sets the point of origin by AlexALX
function ENT:SetGateGroup(s)
	if (self.Entity:GetClass()=="stargate_supergate") then return end
	if (self.Entity:GetClass()=="stargate_universe") then
		s = tostring(s or ""):gsub("[^"..self.WireCharters.."]","");
		if (s!="" and s:len() == 3 and (s:sub(1,1)=="#" or s:sub(2,2)=="#")) then return end
	else
		s = tostring(s or ""):gsub("[^"..self.WireCharters:gsub("#","").."]","");
	end
	if (s:len() == 1) then s = s.."@"; end
	if(s:len() == 2 and self.Entity:GetClass() != "stargate_universe" or s:len() == 3 and self.Entity:GetClass() == "stargate_universe") then
		local group = s:upper();
		if not self:CheckGroup(s,self.GateAddress) then return end
		group = hook.Call("StarGate.SetGateGroup",GAMEMODE,self.Entity,self.GateGroup or "",group) or group;
		if(not (group and (tostring(group):len() == 2 or tostring(group):len() == 3))) then return end;
		self.GateGroup = group;
		self:SetEntityModifier("Group",group); -- Entity Modifiers for Duplicator
		self.Entity:SetNWString("Group",group);
		self:RefreshGateList("group",self.GateGroup);
	end
end

--################# Retrieves the name of this Stargate @aVoN
function ENT:GetGateName()
	return self.GateName or "";
end

--################# Sets the name of this stargate @aVoN
function ENT:SetGateName(s)
	if(s) then
		s = hook.Call("StarGate.SetGateName",GAMEMODE,self.Entity,self.GateName or "",s) or s;
		if(not (type(s) == "string" or type(s) == "number")) then return end;
		s = tostring(s);
		self.GateName = s;
		self:SetEntityModifier("Name",s); -- Entity Modifiers for Duplicator
		self.Entity:SetNWString("Name",s);
		self:RefreshGateList("name",self.GateName);
	end
end

--################# Is this gate Private? @aVoN
function ENT:GetPrivate()
	return self.GatePrivat;
end

--################# Set it private @aVoN
function ENT:SetPrivate(b)
	b = util.tobool(b);
	local override = hook.Call("StarGate.SetPrivate",GAMEMODE,self.Entity,self.GatePrivat or false,b);
	if(type(override) == "boolean") then b = override end;
	self.GatePrivat = b;
	self:SetEntityModifier("Private",b); -- Entity Modifiers for Duplicator
	self.Entity:SetNWBool("Private",b);
	self:RefreshGateList("private",self.GatePrivat,"bool");
end

--################# Is this gate local? by AlexALX
function ENT:GetLocale()
	if (not GetConVar("stargate_group_system"):GetBool()) then return false; end
	return self.GateLocal;
end

--################# Set local by AlexALX
function ENT:SetLocale(b)
	if (self.Entity:GetClass()=="stargate_supergate" or self.Entity:GetClass()=="stargate_orlin") then return end
	if (not GetConVar("stargate_group_system"):GetBool()) then
		self.GateLocal = false;
		self:SetEntityModifier("Locale",false); -- Entity Modifiers for Duplicator
		self.Entity:SetNWBool("Locale",false);
		self:RefreshGateList("locale",self.GateLocal,"bool");
		return;
	end
	b = util.tobool(b);
	local override = hook.Call("StarGate.SetLocal",GAMEMODE,self.Entity,self.GateLocal or false,b);
	if(type(override) == "boolean") then b = override end;
	self.GateLocal = b;
	self:SetEntityModifier("Locale",b); -- Entity Modifiers for Duplicator
	self.Entity:SetNWBool("Locale",b);
	self:RefreshGateList("locale",self.GateLocal,"bool");
end

function ENT:GetGalaxy()
	if (GetConVar("stargate_group_system"):GetBool()) then return false; end
	return self.GateGalaxy;
end

function ENT:SetGalaxy(b)
	if (self.Entity:GetClass()=="stargate_supergate" or self.Entity:GetClass()=="stargate_orlin") then return end
	if (GetConVar("stargate_group_system"):GetBool()) then
		self.GateGalaxy = false;
		self:SetEntityModifier("Galaxy",false); -- Entity Modifiers for Duplicator
		self.Entity:SetNWBool("Galaxy",false);
		self:RefreshGateList("galaxy",self.GateGalaxy,"bool");
		return;
	end
	b = util.tobool(b);
	local override = hook.Call("StarGate.SetGalaxy",GAMEMODE,self.Entity,self.GateGalaxy or false,b);
	if(type(override) == "boolean") then b = override end;
	self.GateGalaxy = b;
	self:SetEntityModifier("Galaxy",b); -- Entity Modifiers for Duplicator
	self.Entity:SetNWBool("Galaxy",b);
	self:RefreshGateList("galaxy",self.GateGalaxy,"bool");
end

--################# Is this gate blocked? by AlexALX
function ENT:GetBlocked()
	if (self:GetNetworkedInt("SG_BLOCK_ADDRESS")<=0 or self:GetNetworkedInt("SG_BLOCK_ADDRESS")==1 and self:GetClass()!="stargate_universe") then return false; end
	return self.GateBlocked;
end

--################# Set it blocked by AlexALX
function ENT:SetBlocked(b)
	if (self.Entity:GetClass()=="stargate_supergate" or self.Entity:GetClass()=="stargate_orlin") then return end
	b = util.tobool(b);
	local override = hook.Call("StarGate.SetBlocked",GAMEMODE,self.Entity,self.GateBlocked or false,b);
	if(type(override) == "boolean") then b = override end;
	self.GateBlocked = b;
	self:SetEntityModifier("Blocked",b); -- Entity Modifiers for Duplicator
	self.Entity:SetNWBool("Blocked",b);
	self:RefreshGateList("blocked",self.GateBlocked,"bool");
end

--################# Client->Server communication @aVoN
concommand.Remove("_StarGate.SetValue"); -- In case of a sent_reload (or lua_reload? How is that new command named?)
concommand.Add("_StarGate.SetValue",
	function(p,_,arg)
		local e = ents.GetByIndex(tonumber(arg[1])); -- Entity
		local c = arg[2]; -- Command
		local d = arg[3]; -- Data
		local d2 = arg[4]; -- Data2 (e.g. for dial!)
		if(IsValid(e) and c and d) then
			--##### Allowed? (Prevents clients using the clientside functions to cheat on my system)
			if(c == "Address" or c == "Name" or c == "Private" or c == "Group" or c == "Locale") then
				-- Is he allowed to change an address/name/private state?
				if(hook.Call("StarGate.Player.CanModifyGate",GAMEMODE,p,e) == false) then return end; -- On any gate?
				if(e.GateSpawnerProtected) then -- On a protected gate?
					local allowed = hook.Call("StarGate.Player.CanModifyProtectedGate",GAMEMODE,p,e);
					if(allowed == nil) then allowed = (p:IsAdmin() or game.SinglePlayer()) end;
					if(not allowed) then return end;
				end
			elseif(c == "Dial" or c == "AbortDialling") then
				if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,e) == false) then return end;
			end
			if(c == "Address") then
				e:SetGateAddress(d);
			elseif(c == "Group") then
				e:SetGateGroup(d);
			elseif(c == "Name") then
				e:SetGateName(d);
			elseif(c == "Private") then
				e:SetPrivate(util.tobool(d));
			elseif(c == "Locale") then
				e:SetLocale(util.tobool(d));
			elseif(c == "Galaxy") then
				e:SetGalaxy(util.tobool(d));
			elseif(c == "Blocked") then
				e:SetBlocked(util.tobool(d));
			elseif(c == "Dial" and d2) then
				local b = util.tobool(d);
				if(e:GetClass() == "stargate_orlin") then b = true end; -- SGA is ALWAYS dialling fast! - FIXME: Add new dialling to this gate (with the new sounds!)
				/*if (e.NoxDialingType == true) then //nox dialing type
					e:NoxDialGate(d2);
				else */
					e:DialGate(d2,b);
				--end
				hook.Call("StarGate.Player.DialledGate",GAMEMODE,p,e,d2,b);
			elseif(c == "NoxDial") then
				e:NoxDialGate(d);
				hook.Call("StarGate.Player.DialledGate",GAMEMODE,p,e,d,true,true);
			elseif(c == "AbortDialling") then
				e:AbortDialling();
				hook.Call("StarGate.Player.ClosedGate",GAMEMODE,p,e);
			end
		end
	end
);

--################# Is the gate blocked or can it get opened? @aVoN
function ENT:IsBlocked(only_by_iris,no_open,only_block)
	if(self.IsOpen or no_open or only_block) then
		for _,v in pairs(ents.FindInSphere(self.Entity:GetPos(),10)) do
			if(v.IsIris) then
				if(v.IsActivated) then
					if (not no_open) then
						self.Iris = v; -- So we have an iris - Fine (Called by event_horizon SENT to "draw" hiteffects)
					end
					if (not only_block) then return true; else break; end
				end
				break;
			end
		end
	end
	if (only_block and self.DialBlocked) then return false end
	if(not only_by_iris) then -- Avoids this long and probably CPU intensive check when a bullet shall be transported
		local hits = 0;
		local radius = math.floor(1/10*self.Entity:BoundingRadius()*2/3); -- About 5 units space between each circle (saves performance) and just 2/3 of the actual gates size (event horizon shall be blocked! not the gate rings lol)
		local min_hits = radius*20*0.7; -- If 70% is covered call this gate "blocked"
		-- Polar coordinates - I love them
		for r=1,radius do
			r = r*10;
			for phi=0,20 do
				local phi = math.pi*phi/10; -- Fraction of 2pi
				local pos = self.Entity:LocalToWorld(Vector(0,r*math.cos(phi),r*math.sin(phi))); -- Position on the surface of the eventhorizon
				local trace = util.QuickTrace(pos,self.Entity:GetForward()*15,{self.Entity,self.Iris,self.EventHorizon});
				if(trace.Hit) then
					if(trace.HitWorld) then -- Just the boring world. World always counts as a hit
						hits = hits + 1;
					elseif((self.IsOpen or only_block and not self.DialBlockedWorld) and IsValid(trace.Entity) and not trace.Entity.IsIris and v ~= self.Entity) then -- Hit an Entity!
						if(((trace.Entity.__StargateTeleport or {}).__LastTeleport or 0) + 2 < CurTime()) then
							if(not IsValid(trace.Entity:GetParent())) then -- Do not allow parented props!
								hits = hits + 1;
							end
						end
					end
					if(hits >= min_hits) then
						return true;
					end
				end
			end
		end
	end
	return false;
end

-- for iris comp by AlexALX
function ENT:GetIris()
	for _,v in pairs(ents.FindInSphere(self.Entity:GetPos(),10)) do
		if(v.IsIris) then
			return v;
		end
	end
	return NULL;
end

-- for e2 lib by AlexALX
function ENT:IrisToggle()
	local iris = self:GetIris();
	if (IsValid(iris)) then
		iris:Toggle();
	end
end

--################# On Button Chevron Press Feature @Madman07

function ENT:OnButtDialGate()
	if(IsValid(self.EventHorizon)) then
		if(self.IsOpen or self.Dialling) then return end; -- We are opened or dialling - Do not allow additional dialling.
		self.EventHorizon:Remove(); -- Remove the EH. We neither are dialling, nor we are opened so it's a bug and the EH stood. Remove it now immediately!
	end

	/*if self.Target and self.Target.OnButtLock and IsValid(self.Target) and self.Target.Outbound and not self.Target.IsOpen and self.Target.Dialling then
		local target = "";
		if (self.Target.Target and IsValid(self.Target.Target)) then target = self.Target.Target end
		self.Target:StopActions();
		if (target != self.Entity) then
			--target:Close();
			target:EmergencyShutdown(true,true);
		end
		self.Target:EmergencyShutdown(true,false);
	end  */
	self:SetDialMode(false,true);
	self:OnButtStartDialling();
end

function ENT:LightUpGates(n)
	self:FindGate();
	local e = self.Target;

	if IsValid(e) then
		--self:ActivateChevron(7, true);
		local action = e.Sequence:New();
		action = e.Sequence:InstantOpen(action,0.5); -- =incoming
		e:RunActions(action);
	else
		self:DHDDisable(1,false);
		local action = self.Sequence:New();
		action = self.Sequence:OnButtonDialFail(n); --fail
		self:RunActions(action);
		return
	end

	for _,v in pairs(self:FindDHD()) do
		v:SetBusy(1.5);
	end
end

function ENT:NoxDialGate(address)
	local allow_override_dial = false;
	 -- We can't dial again while we already dial!
	if(not allow_override_dial and (self.Dialling or self.IsOpen)) then return end;
	-- I hope this fixes issues the EH staying open
	if(IsValid(self.EventHorizon)) then
		if(self.IsOpen or self.Dialling) then return end; -- We are opened or dialling - Do not allow additional dialling.
		self.EventHorizon:Remove(); -- Remove the EH. We neither are dialling, nor we are opened so it's a bug and the EH stood. Remove it now immediately!
	end
	self:SetAddress(address);
	self:SetDialMode(false,true,true);
	self:NoxStartDialling();
end

--##################################
--#### Dial a gate or abort dialling.
--##################################

-- !!!!!ONLY USE THESE FUNCTIONS FOR YOUR SCRIPTS!!!!!!!

--################# Dials a gate direcly (mode means: true = DHD like, false = SGC-Computer like) @aVoN
function ENT:DialGate(address,mode)
	local allow_override_dial = false;
	-- Someone dials in. Are we getting dialled slowly? If yes, allow dialling out (and abort the dial-in)
	if(not self.Outbound and not self.Active and IsValid(self.Target)) then
		allow_override_dial = true;
	end
	 -- We can't dial again while we already dial!
	if(not allow_override_dial and (self.Dialling or self.IsOpen)) then return end;
	if(not mode) then mode = false end;
	-- I hope this fixes issues the EH staying open
	if(IsValid(self.EventHorizon)) then
		if(self.IsOpen or self.Dialling) then return end; -- We are opened or dialling - Do not allow additional dialling.
		self.EventHorizon:Remove(); -- Remove the EH. We neither are dialling, nor we are opened so it's a bug and the EH stood. Remove it now immediately!
	end
	-- Do we override this dial-in?
	if(allow_override_dial) then
		self.Target:AbortDialling();
	end
	self:SetAddress(address);
	self:SetDialMode(false,mode);
	self:StartDialling();
end

--################# Aborts Dialling a gate @aVoN
function ENT:AbortDialling()
	if (self.Shutingdown or self.Jumping) then return end
	-- Do not allow closing, if the eventhorizon is currently establishing (Or you will have massive bugs)
	if(IsValid(self.EventHorizon)) then
		if(not self.EventHorizon:IsOpen()) then return end;
	end
	if(IsValid(self.Target) and IsValid(self.Target.EventHorizon)) then
		if(not self.Target.EventHorizon:IsOpen()) then return end;
	end
	if(self.IsOpen) then
		self:DeactivateStargate(true);
	elseif(self.Dialling and self.Outbound) then
		if(IsValid(self.Target)) then
			self.Target:EmergencyShutdown();
		end
		self:EmergencyShutdown();
	elseif(self.NewActive and not self.Dialling) then
		if(IsValid(self.Target) and self.Target.OnButtLock) then
			local action = self.Target.Sequence:New();
			action = action + self.Target.Sequence:DialFail(nil,true);
			self.Target:RunActions(action);
			self.Target.OnButtLock = false;
		end
		local action = self.Sequence:New();
		action = action + self.Sequence:DialFail(nil,true);
		self:RunActions(action);
	end
end

--################# Wire output with chevrons by AlexALX
function ENT:SetChevrons(chev,set,chevs)
	if (self.WireChevrons == nil) then return end
	if (chev and chev>0) then
		if (chevs) then
			for i=1,chev do
				self.WireChevrons[i] = tonumber(set);
			end
		else
			self.WireChevrons[chev] = tonumber(set);
		end
	else
		for i=1,9 do
			self.WireChevrons[i] = tonumber(set);
		end
	end
	local ch = self.WireChevrons;
	self:SetWire("Chevrons",ch[1]..ch[2]..ch[3]..ch[4]..ch[5]..ch[6]..ch[7]..ch[8]..ch[9]);
end

ENT.ScrAddress = "H5C?W#3E*";
ENT.ScrSymCnt = {3,8};

--################# Set shutdown status by AlexALX
function ENT:SetShutdown(b)
	self.Shutingdown = b;
end

--################# Get shutdown status by AlexALX
function ENT:IsShutdown()
	return self.Shutingdown;
end

function ENT:IsSelfDial()
	local a = self.DialledAddress;
	local address = self:GetGateAddress();
	if (#self.DialledAddress==8 and	address:find(a[1]) and address:find(a[2]) and address:find(a[3]) and address:find(a[4]) and address:find(a[5]) and address:find(a[6])) then
		return true;
	end
	return false;
end

function ENT:DialFailSound()
	if (not IsValid(self.Entity) or self.Sounds==nil) then return end
	if (self.Sounds.Fail_NC and self.Entity:GetWire("Chevron",0,true)==0) then
		self.Entity:EmitSound(self.Sounds.Fail_NC,90,math.random(90,92));
	else
		self.Entity:EmitSound(self.Sounds.Fail,90,math.random(95,105));
	end
end