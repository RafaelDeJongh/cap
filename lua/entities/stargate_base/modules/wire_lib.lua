/*
	Wire dialling by AlexALX (c) 2011
*/

--################# Block wire inputs function by AlexALX
function ENT:BlockWire(block)
	self.WireBlock = util.tobool(block);
end

--################# Check right symbols for groupsystem/galaxysystem by AlexALX
function ENT:CheckWireSymbol(symbol)
	local groupsystem = GetConVar("stargate_group_system"):GetBool();
	local secret = false;
	if (symbol=="*" and #self.WireDialledAddress==8 and string.Implode("",self.WireDialledAddress)=="E7?M2IX9"
	or symbol=="?" and #self.WireDialledAddress==2 and string.Implode("",self.WireDialledAddress)=="E7") then secret = true end
	if (groupsystem) then
		if ((symbol=="*" or symbol=="?") and not secret or symbol=="!") then return false; end
	else
		if ((symbol=="*" or symbol=="?") and not secret or symbol=="0") then return false; end
	end
	return true;
end

--################# First activation function by AlexALX
function ENT:FirstActivation()
	self.WireManualDial = true;
	self.Outbound = true;
	local action = self.Sequence:New();
	action = self.Sequence:SeqFirstActivation(n,true);
	self:RunActions(action);
end

--################# Encode chevron function by AlexALX
function ENT:EncodeChevron()
	local n = table.getn(self.WireDialledAddress);
	local candialg = GetConVar("stargate_candial_groups_wire"):GetInt()
	local allowed_symbols = 8
	self.Outbound = true;
	if (n >= allowed_symbols || self.RingSymbol == "" || self.RingSymbol!="" and (table.HasValue(self.WireDialledAddress,self.RingSymbol) or not self:CheckWireSymbol(self.RingSymbol))) then
		local action = self.Sequence:New();
		action = self.Sequence:OnButtonDialFail(n,true)
		action = action + self.Sequence:DialFail(nil,true,true);
		self:RunActions(action);
	else
		local action = self.Sequence:New();
		if (n==0 and not self.WireManualDial) then
			self:FirstActivation();
			self.WireManualDial = true;
		elseif (n>0) then
			self.WireManualDial = true;
		end
		table.insert(self.WireDialledAddress, self.RingSymbol);
		action = action + self.Sequence:SeqEncodeChevron(n+1, self.WireDialledAddress);
		self:RunActions(action);
	end
end

--################# Chevron 7 lock function by AlexALX
function ENT:Chevron7Lock()
	local n = table.getn(self.WireDialledAddress);
	local candialg = GetConVar("stargate_candial_groups_wire"):GetInt()
	local allowed_symbols = 9
	if (candialg==0 or self:GetLocale()==true) then
		allowed_symbols = 7
	end
	self.Outbound = true;
	if (n < 6 or n >= allowed_symbols or self.RingSymbol=="" or self.RingSymbol!="" and (table.HasValue(self.WireDialledAddress,self.RingSymbol) or not self:CheckWireSymbol(self.RingSymbol))) then
		local action = self.Sequence:New();
		if (n >= allowed_symbols) then
			action = self.Sequence:SeqChevron7Lock(table.getn(self.WireDialledAddress)+1,self.WireDialledAddress,true) + self.Sequence:DialFail(false,true,true);
		else
			action = self.Sequence:OnButtonDialFail(n,true);
			action = action + self.Sequence:DialFail(nil,true);
		end
		self:RunActions(action);
	else
		table.insert(self.WireDialledAddress, self.RingSymbol);
		table.insert(self.WireDialledAddress, "DIAL");
		self.DialledAddress = self.WireDialledAddress;
		self.WireManualDial = false;
		self:WireDialGate();
	end
end

--################# Wire Manual Slow Dial Feature by AlexALX
function ENT:WireDialGate()
	if(IsValid(self.EventHorizon)) then
		if(self.IsOpen or self.Dialling) then return end; -- We are opened or dialling - Do not allow additional dialling.
		self.EventHorizon:Remove(); -- Remove the EH. We neither are dialling, nor we are opened so it's a bug and the EH stood. Remove it now immediately!
	end
	if self.Target and IsValid(self.Target) and self.Target.Outbound and not self.Target.IsOpen and self.Target.Dialling then
		local target = "";
		if (self.Target.Target and IsValid(self.Target.Target)) then target = self.Target.Target end
		self.Target:StopActions();
		if (target != self.Entity) then
			--target:Close();
			target:EmergencyShutdown(true,true);
		end
		self.Target:EmergencyShutdown(true,false);
	end
	self:SetDialMode(false,false);
	self:WireStartDialling();
end

function ENT:WireStartDialling()
	self:FindGate();
	local allow = hook.Call("StarGate.Dial",GAMEMODE,self.Entity,self.Target or NULL,table.concat(self.DialledAddress or {}):sub(1,9),self.DialType);
	if(allow == false or GetConVar("stargate_group_system"):GetBool() and self:GetGateGroup()=="") then return end;
	self:WireActivateStargate(self.DialType.Inbound);
end

function ENT:WireActivateStargate(inbound)
	local e = self.Target; -- Quick reference (keeps code shorter)
	local fail = false;
	local busy = false;
	 -- prepare power calculations, and check for energy
	self:CheckConnection() -- prepare power calculations
	self.NoxDialingType = false;
	if (self.HasRD and not self:CheckEnergy() and not self.Dialling and not inbound) then
		local action = self.Sequence:New();
		action = self.Sequence:SeqChevron7Lock(table.getn(self.DialledAddress)-1,self.DialledAddress,true) + self.Sequence:DialFail(false,true,true);
		self:RunActions(action);
	else
	-- proper dialing
	if(not self.Dialling) then
		local action = self.Sequence:New();
		if(self.IsOpen) then
			self:DeactivateStargate();
		else
			if(inbound or (self.DialledAddress and (#self.DialledAddress >= 8 and #self.DialledAddress <= 10) and (inbound or not self:IsBlocked(nil,nil,true)))) then
				local secret = false;
				if(#self.DialledAddress == 10 and string.Implode("",self.DialledAddress)=="E7?M2IX9*DIAL") then secret = true; end
				if(IsValid(e) and e.IsStargate and not (e.IsOpen or e.Dialling == true) or secret) then
					action = self.Sequence:OpenGate();
					--################# And open the other gate
					if(not inbound) then
						self:StopActions();
						if (not secret) then
							-- When the other gate just was going to dial out, stop it now!
							if(IsValid(e.Target)) then
								e.Target:StopActions();
								if(e.Target ~= self.Entity) then
									-- FIXME: CHECK IF THIS IS A BUG!
									e.Target:Close();
									e.Target:EmergencyShutdown(true,false);
								end
							end
							e:EmergencyShutdown(true,true); -- Interrupt manual dialing, but keep the address (second true means, to make the gate's chevron disabled immediately)

							e.Target = self.Entity; -- Tell the other gate, who is calling now
							e.NoxDialingType = false;
							e:WireActivateStargate(true); -- Dialed by a DHD
							for _,v in pairs(e:FindDHD()) do
								v:SetBusy(2);
							end
						end
						for _,v in pairs(self:FindDHD()) do -- Lock DHD, so ppl wont shutdown gates so fast
							v:SetBusy(2);
						end
					end
				else
					if (IsValid(e) and e.IsStargate and (e.IsOpen or e.Dialling == true or e:IsBlocked(nil,nil,true)) or self:IsSelfDial()) then
						busy = true;
					end
					self.Target = nil;
					action = action + self.Sequence:SeqChevron7Lock(table.getn(self.DialledAddress)-1,self.DialledAddress,true,busy) + self.Sequence:DialFail(false,true,true);
					fail = true;
				end
				if(not DEBUG and not fail) then -- No debug, no instant open
					local dly = self:GetDelaySG1(self.Target:GetClass(),self.Target.Classic);
					if (not inbound) then
						action = self.Sequence:InstantOpen(nil,0 + dly,true,inbound,true) + action;
						action = self.Sequence:SeqChevron7Lock(#self.DialledAddress-1, self.DialledAddress) + action;
					else
						action = self.Sequence:InstantOpen(nil,2.0 + dly,false,inbound,true) + action;
					end
				end
			else
				action = self:DialFail(nil,true);
			end
			if(inbound) then
				self.Outbound = false;
			else
				self.Outbound = true;
			end
		end
		action:Add({f=function() if(self) then self.DialledAddress = {} end end,v={},d=0}); -- Clear old address after dial
		self:RunActions(action);
	end
	end
end

--################# Light every DHD near us up @aVoN, AlexALX
-- Chevron,Delay,NoShutdon (Noshutdown is used, when every DHD near the gate will get "light up" again, when the stagate openes)
function ENT:DHDSetChevronWire(ch,delay,ns)
	local delay = delay or 0.4;
	if(not self.WireDialledAddress) then return false; end
	for k,v in pairs(self:FindDHD()) do
		if(v:IsValid() and v.Target ~= self.Entity) then
			if(ch == 1 and not ns) then
				v:Shutdown(0);
			end
			local btn = self.WireDialledAddress[ch];
			timer.Create("dhd_chevron"..k..ch..self.Entity:EntIndex(),delay,1,
				function()
					if(IsValid(v)) then
						v:AddChevron(btn,true,true);
						v:SetBusy(10);
					end
				end
			);
		end
	end
end

-- Set all available addresses for this gate by AlexALX
function ENT:WireGetAddresses()
	local list = {}
	local gates = self:GetGates();
	local candialg = GetConVar("stargate_candial_groups_wire"):GetInt()
	if (self:GetLocale()==true) then candialg = 0 end
	if (self.Entity:GetClass()=="stargate_supergate") then
		for k,v in pairs(gates) do
			if(IsValid(v) and v ~= self.Entity and not v:GetPrivate()) then
			    local address = v:GetGateAddress();
				if(address ~= "") then
					local name = v:GetGateName();
					if(name == "") then name = "N/A" end;
					table.insert(list, address.." "..name );
				end
			end
		end
	else
		if (GetConVar("stargate_group_system"):GetBool() == true) then
			if (candialg==1) then
				for k,v in pairs(gates) do
					if(IsValid(v) and v ~= self.Entity and not v:GetPrivate()) then
						local address = v:GetGateAddress();
						local group = v:GetGateGroup();
						local locale = v:GetLocale();
						local ent = self.Entity;
						if(address != "" and group != "" and IsValid(ent) and (not locale and not ent:GetLocale() or (ent:GetGateGroup() == group or v:GetClass()=="stargate_universe" and ent:GetClass()=="stargate_universe")) and (address!=ent:GetGateAddress() or group!=ent:GetGateGroup())) then
							local range = (ent:GetPos() - v:GetPos()):Length();
							local c_range = ent:GetNetworkedInt("SGU_FIND_RANDE"); -- GetConVar("stargate_sgu_find_range"):GetInt();
							if (ent:GetGateGroup() != group and (v:GetClass()!="stargate_universe" or ent:GetClass()!="stargate_universe") or c_range > 0 and range>c_range and ent:GetGateGroup():len()==3) then
								if (locale or ent:GetLocale()) then	continue end
								if (ent:GetGateGroup():len()==3 and group:len()==3 or ent:GetGateGroup():len()==2 and group:len()==2) then
									address = address..group:sub(1,1);
								else
									address = address..group;
								end
								if (group:len()==2 and ent:GetGateGroup():len()==3) then
									address = address.."#";
								end
							end
							local name = v:GetGateName();
							if(name == "") then name = "N/A" end;
							if (v:GetBlocked()) then address = "1 "..address; end
							if(not table.HasValue(list, address.." "..name)) then
								table.insert(list, address.." "..name);
							end
						end
					end
				end
			else
				for k,v in pairs(gates) do
					if(IsValid(v) and v ~= self.Entity and not v:GetPrivate()) then
						local address = v:GetGateAddress();
						local group = v:GetGateGroup();
						local ent = self.Entity;
						if(address != "" and group != "" and IsValid(ent) and (address!=ent:GetGateAddress() or group!=ent:GetGateGroup())) then
							local range = (ent:GetPos() - v:GetPos()):Length();
							local c_range = ent:GetNetworkedInt("SGU_FIND_RANDE"); -- GetConVar("stargate_sgu_find_range"):GetInt();
							if ((ent:GetGateGroup() == group or v:GetClass()=="stargate_universe" and ent:GetClass()=="stargate_universe") and (range<=c_range and ent:GetGateGroup():len()==3 or ent:GetGateGroup():len()==2 or c_range == 0 and ent:GetGateGroup():len()==3)) then
								local name = v:GetGateName();
								if(name == "") then name = "N/A" end;
								if (v:GetBlocked()) then address = "1 "..address; end
								if(not table.HasValue(list, address.." "..name)) then
									table.insert(list, address.." "..name);
								end
							end
						end
					end
				end
			end
		else
			for k,v in pairs(gates) do
				if(IsValid(v) and v ~= self.Entity and not v:GetPrivate()) then
				    local address = v:GetGateAddress();
				    local g = self.Entity;
					if(address ~= "") then
						local range = (g:GetPos() - v:GetPos()):Length();
						local c_range = g:GetNetworkedInt("SGU_FIND_RANDE");
					    if(v:GetGalaxy() or g:GetGalaxy() or
						   v:GetClass()=="stargate_universe" and g:GetClass()=="stargate_universe" and
						   c_range > 0 and range>c_range)then
						    address = address.."@";
					    end
					    if(v:GetClass() == "stargate_atlantis" and g:GetClass() == "stargate_atlantis" and #address == 7 and g:GetGalaxy() and v:GetGalaxy())then
							address = string.Explode("@",tostring(address));
							address = address[1];
						end
						if(#address == 7 and g:GetGalaxy() and v:GetGalaxy() and ((v:GetClass() ~= "stargate_atlantis" and g:GetClass() ~= "stargate_atlantis") and
						   (v:GetClass() ~= "stargate_universe" and g:GetClass() ~= "stargate_universe")))then
							address = string.Explode("@",tostring(address));
							address = address[1];
						end
						if((v:GetClass() == "stargate_universe" and g:GetClass() ~= "stargate_universe") or --#address == 7 and
						   (v:GetClass() ~= "stargate_universe" and g:GetClass() == "stargate_universe"))then
							address = string.Explode("@",tostring(address));
							address = address[1].."@!";
						end
						local name = v:GetGateName();
						if(name == "") then name = "N/A" end;
						if (address:len()==6 or candialg==1) then
							if (v:GetBlocked()) then address = "1 "..address; end
							table.insert(list, address.." "..name);
						end
					end
				end
			end
		end
	end
	return list;
end

--################# Get every valid gates by AlexALX
function ENT:GetGates()
	local class = "stargate_*"
	if (self.Entity:GetClass()=="stargate_supergate") then class = "stargate_supergate" end
	local stargate = ents.FindByClass(class);
	local gates = {};
	for _,v in pairs(stargate) do
		if (v.IsStargate and self.Entity:GetClass()=="stargate_supergate" or v.IsGroupStargate) then
			table.insert(gates,v);
		end
	end
	return gates;
end