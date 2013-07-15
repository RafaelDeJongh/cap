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

--##################################
--#### Sequences - Scripted animations!
--##################################
ENT.Sequence = {};

--################################## Register a new Sequence Table to this gate @aVoN
function ENT:RegisterSequenceTable()
	local new_Sequence = table.Copy(self.Sequence); -- We need a unique "Sequence" table for this SENT. ENT.Sequence is global so we create our own "local"
	new_Sequence.BaseClass = nil; -- If there is a "BaseClass" in it, make it nil - We need a table without "BaseClass" in it, or we will index the wrong table later.
	-- Tells "new_Sequence" to index this entitie's self instead of "new_Sequence"
	setmetatable(new_Sequence,{__index=self,__newindex=self}); -- ATTENTION: In your sequence table, do not use a function which already exists in the Entity, or you will overwrite it! - This is for purpose!
	self.Sequence = new_Sequence;
end

--################# Adds possibility to tables to be "additive" (needed for the effects later because they are various combinations of each other) @aVoN
local seq_base = {Add=function(self,t) table.insert(self,t) end}; -- The "Additive function"
function ENT.Sequence:New(t_in)
	local t = {};
	if(type(t_in) == "table") then t = t_in end;
	--################# Adds an object directly to our aditive table (avoids long table.insert code) @aVoN
	local meta = {__index=seq_base};
	-- Our Add function
	local add = function(t1,t2)
		local t = {};
		for _,v in pairs(t1) do
			table.insert(t,v);
		end
		for _,v in pairs(t2) do
			table.insert(t,v);
		end
		-- Add the metatable again!
		setmetatable(t,meta);
		return t;
	end
	meta.__add = add;
	setmetatable(t,meta);
	return t;
end

--################# DialFail sequence @aVoN
function ENT.Sequence:DialFail(instant_stop,play_sound)
	local action = self:New();
	local delay = 1.5;
	if(instant_stop) then delay = 0 end;
	action:Add({f=self.SetStatus,v={self,false,true,true},d=0}); -- We need to keep in "dialling" mode to get around with conflicts
	if(self.Entity.Active or play_sound) then
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Fail,90,math.random(95,105)},d=0});-- Fail sound
	end
	action:Add({f=self.SetShutdown,v={self,true},d=0});
	action:Add({f=self.DHDDisable,v={self,1.5,true},d=delay});-- Shutdown EVERY DHD

	-- Stop all chevrons (if active only!)
	if(self.Entity.Active or play_sound) then
		--if (self.Entity:GetClass() == "stargate_supergate") then
		--	action:Add({f=self.DisActivateLights,v={self,true},d=0});
		--end

		action:Add({f=self.ActivateRing,v={self,false},d=0});

		for i=1,9 do
			action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
		end
	end
	if(self.Shutdown) then
		action:Add({f=self.Shutdown,v={self,true,self.Entity.Active or play_sound},d=0});
	end
	if self.Entity:GetClass() == "stargate_supergate" then
		action:Add({f=self.DisActivateLights,v={self,false,true},d=0});
	end
	action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Received",""},d=0}); -- Wire
	action:Add({f=self.SetChevrons,v={self,0,0},d=0}); -- Wire
	action:Add({f=self.SetStatus,v={self,false,false},d=0.8}); -- Make the Wire-Value of "-7" = dial-fail stay longer so people's script work along with the sound
	action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Chevron",0},d=0}); -- Wire
	action:Add({f=self.SetShutdown,v={self,false},d=0});
	return action;
end


--#################  Open the stargate @aVoN
function ENT.Sequence:OpenGate()
	-- The DHD On/Off is for the random gatejump (to fix it)
	local action = self:New({{f=self.DHDDisable,v={self,0},d=0}}); -- First, disable all DHDs near it (not the DHD which dialled this gate!)
	for i=1,#self.DialledAddress-1 do
		action:Add({f=self.DHDSetChevron,v={self,i,0.05,true},d=0}); -- Reactivate every DHD's symbols (exept of the one, which dialled)
	end
	action:Add({f=self.CheckTarget,v={self},d=0});
	action:Add({f=self.DHDSetChevron,v={self,#self.DialledAddress,0.2,true},d=0}); -- DIAL Button
	action:Add({f=self.DHDSetAllBusy,v={self},d=0}); -- Set them all busy to avoid problems
	action:Add({f=self.SetShutdown,v={self,false},d=0});
	action:Add({f=self.Open,v={self},d=0}); -- This actually openes the gate
	-- Close the gate after certain ammount of time
	local autoclose = StarGate.CFG:Get("stargate","autoclose_time",38);
	action:Add({f=self.SetStatus,v={self,true,false},d=autoclose*60});
	if(autoclose > 0) then
		action:Add({f=self.Close,v={self},d=0}); -- Close the gate after the ammount of time mentioned above
	end
	return action;
end

function ENT:CheckTarget()
	if (not IsValid(self.Target)) then return end
	if (not IsValid(self.Target.Target)) then
		self.Target.Target = self.Entity
	end
end

--##################################
--#### Open/Close Handling
--##################################


--################# Close wormhole (effect) @aVoN
function ENT:Close(ignore)
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
	-- Add additional shutdown sequences
	if(self.Shutdown) then
		action:Add({f=self.Shutdown,v={self,false,true},d=0});
	end
	if self.Entity:GetClass() == "stargate_supergate" then
		action:Add({f=self.DisActivateLights,v={self},d=0});
	end
	action:Add({f=self.SetWire,v={self,"Chevron",0},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
	action:Add({f=self.SetChevrons,v={self,0,0},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Received",""},d=0}); -- Wire
	action:Add({f=self.SetStatus,v={self,false,false},d=0}); -- Add the "close" flag
	action:Add({f=self.DHDDisable,v={self,0,true},d=0});
	action:Add({f=self.SetShutdown,v={self,false},d=0});
	self:RunActions(action);

end

--################# Openes the gate (creates the event horizon) @aVoN
function ENT:Open()
	local e = ents.Create("event_horizon");
	if(self.Entity:GetClass()=="stargate_supergate")then
		e:SetPos(self.Entity:GetPos()+self.Entity:GetUp()*2375);
	else
		e:SetPos(self.Entity:GetPos());
	end
	e:SetAngles(self.Entity:GetAngles());
	e:SetParent(self.Entity);
	-- Set another sound to the gate (must be done before spawning it)
	if(self.Sounds and self.Sounds.Open) then
		e.Sounds.Open = self.Sounds.Open;
	end
	e:Spawn();
	e:Activate();
	if(self.Outbound) then e:SetTarget(self.Target) end;  -- We tell the Eventhorizon the GATE (not the EH of the gate) where to find the EH of this gate
	if(IsValid(self.EventHorizon)) then self.EventHorizon:Remove() end; -- WORKAROUND for the EH-Stay bug: New EH's will definitely override the old!
	self.EventHorizon = e;
	self.OnButtLock = false;
end

--################# Emergency shutdown of the gate @aVoN
function ENT:EmergencyShutdown(dont_clear_address,instant_stop)
	if(not self.IsOpen) then
		self:StopActions(); -- Stop all previous actions
		if(self.Dialling) then
			self:RunActions(self.Sequence:DialFail(instant_stop)); -- Add dialfail sequence
			if(IsValid(self.Target)) then
				self.Target.NoxDialingType = false;
			end
			self.OnButtLock = false;
			self.Target = nil;
			self.Dialling = false;
			self.NoxDialingType = false;
			if(not dont_clear_address) then
				self.DialledAddress = {};
			end
		end
	end

end

function ENT:ResetVars()
	self.NoxDialingType = false;
	self:Close(ignore);
	self.OnButtLock = false;
	self.DialledAddress = {};
	table.Empty(self.DialledAddress);
	self.Target = nil;
end

--################# Deactivates the stargate, when it's opened @aVoN
function ENT:DeactivateStargate(ignore)
	if(self.IsOpen and not self.Dialling and (self.Outbound or ignore)) then
		if(IsValid(self.Target)) then
			self.Target:Close(ignore);
			self.Target.NoxDialingType = false;
			self.Target.Target = nil;
			self.Target.OnButtLock = false;
			self.Target.DialledAddress = {};
			table.Empty(self.Target.DialledAddress);
		end
		self.NoxDialingType = false;
		self:Close(ignore);
		self.OnButtLock = false;
		self.DialledAddress = {};
		table.Empty(self.DialledAddress);
		self.Target = nil;
	end
end

--#################  Run the dial process, activate the gate ETC @aVoN
function ENT:ActivateStargate(inbound,fast)
	local e = self.Target; -- Quick reference (keeps code shorter)
	local fail = false;
	local busy = false;
	 -- prepare power calculations, and check for energy
	self:CheckConnection()
	self.NoxDialingType = false;
	if (self.HasRD and not self:CheckEnergy(true) and not self.Dialling and not inbound) then
		local action = self.Sequence:New();
		action = self.Sequence:DialFail(nil,true);
		self:RunActions(action);
	else
		-- proper dialing
		if(not self.Dialling) then
			local action = self.Sequence:New();
			if(self.IsOpen) then
				self:DeactivateStargate();
			else
				if(inbound or (self.DialledAddress and (#self.DialledAddress >= 8 and #self.DialledAddress <= 10) and not self:IsBlocked(nil,nil,true))) then
					if(IsValid(e) and e.IsStargate and not (e.IsOpen or e.Dialling == true) and (inbound or not inbound and self:CheckEnergy()) and (inbound or not e:IsBlocked(nil,nil,true))) then
						action = self.Sequence:OpenGate();
						--################# And open the other gate
						if(not inbound) then
							self:StopActions();
							-- When the other gate just was going to dial out, stop it now!
							if(IsValid(e.Target)) then
								e.Target:StopActions();
								if(e.Target ~= self.Entity) then
									-- FIXME: CHECK IF THIS IS A BUG!
									--e.Target:Close();
									e.Target:EmergencyShutdown(true,false);
								end
							end
							e:EmergencyShutdown(true,fast); -- Interrupt manual dialing, but keep the address (second true means, to make the gate's chevron disabled immediately)
							e.Target = self.Entity; -- Tell the other gate, who is calling now
							e.NoxDialingType = false;
							if(fast) then
								e:ActivateStargate(true,true); -- Dialed by a DHD
							else
								e:ActivateStargate(true); -- Dialed by a dialup computer :P
							end
						end
					else
						if (IsValid(e) and e.IsStargate and (e.IsOpen or e.Dialling == true or e:IsBlocked(nil,nil,true)) and not inbound or self:IsSelfDial()) then
							busy = true;
						end
						self.Target = nil;
						action = self.Sequence:DialFail(nil,true,true);
						fail = true;
					end
					self:SetShutdown(false);
					if(not DEBUG) then -- No debug, no instant open
						action = self.Sequence:Dial(inbound,fast,fail,busy) + action;
					end
				else
					action = self.Sequence:DialFail(nil,true);
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

--#################  Run the dial process, activate the gate ETC @aVoN
function ENT:NoxActivateStargate(inbound)
	if self.Cooldown then return end;
	local e = self.Target; -- Quick reference (keeps code shorter)
	local fail = false;
	 -- prepare power calculations, and check for energy
	self:CheckConnection();
	self.NoxDialingType = true;
	if (self.HasRD and not self:CheckEnergy(true) and not self.Dialling and not inbound or not IsValid(e) and not self:IsSelfDial()) then
		local action = self.Sequence:New();
		action = self.Sequence:DialFail(nil,true);
		self:RunActions(action);
		return
	end
	-- proper dialing
	if(not self.Dialling) then
		local action = self.Sequence:New();
		if(self.IsOpen) then
			self:DeactivateStargate();
		else
			if(inbound or (self.DialledAddress and (#self.DialledAddress >= 8 and #self.DialledAddress <= 10) and not self:IsBlocked(nil,nil,true))) then
				if(IsValid(e) and e.IsStargate and not (e.IsOpen or e.Dialling == true) and (inbound or not inbound and self:CheckEnergy()) and (inbound or not e:IsBlocked(nil,nil,true))) then
					action = self.Sequence:OpenGate();
					--################# And open the other gate
					if(not inbound) then
						self:StopActions();
						-- When the other gate just was going to dial out, stop it now!
						if(IsValid(e.Target)) then
							e.Target:StopActions();
							if(e.Target ~= self.Entity) then
								-- FIXME: CHECK IF THIS IS A BUG!
								--e.Target:Close();
								e.Target:EmergencyShutdown();
							end
						end
						e:EmergencyShutdown(true,true); -- Interrupt manual dialing, but keep the address (second true means, to make the gate's chevron disabled immediately)
						e.Target = self.Entity; -- Tell the other gate, who is calling now
						e.NoxDialingType = true; -- no kawoosh
						e:NoxActivateStargate(true); -- Dialed by a DHD
					end
				else
				    self.Target = nil;
					action = self.Sequence:DialFail(nil,true);
					fail = true;
				end
				if(not DEBUG) then -- No debug, no instant open
					action = self.Sequence:InstantOpen(nil,0.0,true,inbound,false,true,fail) + action;
				end
			else
				action = self.Sequence:DialFail(nil,true);
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

--################# On Button Chevron Press Feature @Madman07
function ENT:OnButtActivateStargate(inbound)
	local e = self.Target; -- Quick reference (keeps code shorter)
	local fail = false;
	 -- prepare power calculations, and check for energy
	self:CheckConnection() -- prepare power calculations
	self.NoxDialingType = false;
	if (self.HasRD and not self:CheckEnergy() and not inbound or not inbound and IsValid(e) and not e.OnButtLock) then
		local action = self.Sequence:New();
		local busy = false;
		if (IsValid(e) and self:CheckEnergy() and e.IsStargate and (e.IsOpen or e.Dialling == true or e:IsBlocked(nil,nil,true)) and not inbound or self:IsSelfDial() or self:IsBlocked(nil,nil,true)) then
			busy = true;
		end
		action = self.Sequence:OnButtonDialFail(table.getn(self.DialledAddress)-1,true,busy);
		action = action + self.Sequence:DialFail(nil,true);
		self:RunActions(action);
	else
		-- proper dialing
		if(not self.Dialling or self.OnButtLock) then
			local action = self.Sequence:New();
			if(self.IsOpen) then
				self:DeactivateStargate();
			else
				if(inbound or (self.DialledAddress and (#self.DialledAddress >= 8 and #self.DialledAddress <= 10))) then
					if(IsValid(e) and e.IsStargate and (not (e.IsOpen or e.Dialling == true) or e.OnButtLock) and (inbound or not e:IsBlocked(nil,nil,true))) then
						action = self.Sequence:OpenGate();
						--################# And open the other gate
						if(not inbound) then
							self:StopActions();
							-- When the other gate just was going to dial out, stop it now!
							if(IsValid(e.Target)) then
								e.Target:StopActions();
								if(e.Target ~= self.Entity) then
									-- FIXME: CHECK IF THIS IS A BUG!
									--e.Target:Close();
									e.Target:EmergencyShutdown(true,false);
								end
							end
							--e:EmergencyShutdown(true,true); -- Interrupt manual dialing, but keep the address (second true means, to make the gate's chevron disabled immediately)

							e.Target = self.Entity; -- Tell the other gate, who is calling now
							e.NoxDialingType = false;
							e:OnButtActivateStargate(true); -- Dialed by a DHD
							for _,v in pairs(e:FindDHD()) do
								v:SetBusy(2);
							end
							for _,v in pairs(self:FindDHD()) do -- Lock DHD, so ppl wont shutdown gates so fast
								v:SetBusy(2);
							end
						end
					else
						local busy = false;
						if (IsValid(e) and self:CheckEnergy() and e.IsStargate and (e.IsOpen or e.Dialling == true or e:IsBlocked(nil,nil,true)) and not inbound or self:IsSelfDial()) then
							busy = true;
						end
						action = self.Sequence:OnButtonDialFail(table.getn(self.DialledAddress)-1,true,busy);
						action = action + self.Sequence:DialFail(nil,true);
						fail = true;
					end
					if(not DEBUG and not fail) then -- No debug, no instant open
						if (self.OnButtLock) then
							local act = action;
							action = self.Sequence:New();
							action:Add({f=self.FakeDelay,v={self},d=0.5});
							action = action + act;
						else
							action = self.Sequence:InstantOpen(nil,0.5,true,inbound) + action;
						end
					end
				else
					action = self.Sequence:DialFail(nil,true);
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

function ENT:OnButtLockStargate()
	local e = self.Target; -- Quick reference (keeps code shorter)
	local action = e.Sequence:New();
	if(IsValid(e) and e.IsStargate and not (e.IsOpen or e.Dialling == true or self:IsBlocked(nil,nil,true))) then
		action = e.Sequence:InstantOpen(nil,0.2,true,true);
		--self:StopActions();
		-- When the other gate just was going to dial out, stop it now!
		if(IsValid(e.Target)) then
			e.Target:StopActions();
			if(e.Target ~= self.Entity) then
				-- FIXME: CHECK IF THIS IS A BUG!
				--e.Target:Close();
				e.Target:EmergencyShutdown(true,false);
			end
		end
		e:EmergencyShutdown(true,true); -- Interrupt manual dialing, but keep the address (second true means, to make the gate's chevron disabled immediately)
        e.OnButtLock = true;
		e.Target = self.Entity; -- Tell the other gate, who is calling now
		e.NoxDialingType = false;
		--e:OnButtActivateStargate(true); -- Dialed by a DHD
		for _,v in pairs(e:FindDHD()) do
			v:SetBusy(2);
		end
	else
		return false;
	end
	e:RunActions(action);
end

--################# On Button Chevron Press Feature @Madman07
function ENT:OnButtCheckStargate()
	self:FindGate();
	local allow = hook.Call("StarGate.Dial",GAMEMODE,self.Entity,self.Target or NULL,table.concat(self.DialledAddress or {}):sub(1,9),self.DialType);
	if(allow == false) then return false end;
	local e = self.Target; -- Quick reference (keeps code shorter)
	 -- prepare power calculations, and check for energy
	self:CheckConnection() -- prepare power calculations
	if (self.HasRD and not self:CheckEnergy(false,true) and not self.Dialling) then
		return false;
	else
		-- proper dialing
		if(not self.Dialling) then
			if(IsValid(e) and e.IsStargate) then
				return true;
			else
				return false;
			end
		end
	end
	return false;
end

--##################################
--#### We hit the iris! (Call gate:IsBlocked() before, or you will have no valid Iris!
--##################################

--################# Tells the iris, we hit it @aVoN
function ENT:HitIris(e,pos,dir)
	if(IsValid(self.Iris) and self.Iris.IsActivated) then
		self.Iris:HitIris(e,pos,dir);
	end
end

--##################################
--#### Dialling
--##################################

--################# Sets the address of the gate which we want to dial @aVoN
function ENT:SetAddress(a)
	if(type(a) == "string") then
		if (a:len() == 6) then
			self.DialledAddress = {a:sub(1,1),a:sub(2,2),a:sub(3,3),a:sub(4,4),a:sub(5,5),a:sub(6,6),"#","DIAL"};
		elseif (a:len() == 7 and a:sub(7,7) == "#") then
			self.DialledAddress = {a:sub(1,1),a:sub(2,2),a:sub(3,3),a:sub(4,4),a:sub(5,5),a:sub(6,6),"#","DIAL"};
		elseif (a:len() == 7 and a:sub(7,7) != "#") then
			self.DialledAddress = {a:sub(1,1),a:sub(2,2),a:sub(3,3),a:sub(4,4),a:sub(5,5),a:sub(6,6),a:sub(7,7),"#","DIAL"};
		elseif (a:len() == 8 and GetConVar("stargate_group_system"):GetBool()) then
			self.DialledAddress = {a:sub(1,1),a:sub(2,2),a:sub(3,3),a:sub(4,4),a:sub(5,5),a:sub(6,6),a:sub(7,7),a:sub(8,8),"DIAL"};
		elseif (a:len() == 8) then
			self.DialledAddress = {a:sub(1,1),a:sub(2,2),a:sub(3,3),a:sub(4,4),a:sub(5,5),a:sub(6,6),a:sub(7,7),a:sub(8,8),"#","DIAL"};
		elseif (a:len() == 9) then
			self.DialledAddress = {a:sub(1,1),a:sub(2,2),a:sub(3,3),a:sub(4,4),a:sub(5,5),a:sub(6,6),a:sub(7,7),a:sub(8,8),a:sub(9,9),"DIAL"};
		end
	elseif(type(a) == "table" and #a >= 8 and #a <= 10) then
		self.DialledAddress = a;
	end
end

--################# Sets the dial type of the gate @aVoN
function ENT:SetDialMode(inbound,fast,nox)
	self.DialType.Inbound = inbound;
	self.DialType.Fast = fast;
	self.DialType.Nox = nox;
end

--################# Finally starts dialling the gate @aVoN
function ENT:StartDialling()
	self:FindGate();
	local allow = hook.Call("StarGate.Dial",GAMEMODE,self.Entity,self.Target or NULL,table.concat(self.DialledAddress or {}):sub(1,9),self.DialType);
	if(allow == false or GetConVar("stargate_group_system"):GetBool() and self:GetGateGroup()=="" and self.Entity:GetClass()!="stargate_supergate") then return end;
	self:ActivateStargate(self.DialType.Inbound,self.DialType.Fast);
end

function ENT:NoxStartDialling()
	self:FindGate();
	local allow = hook.Call("StarGate.Dial",GAMEMODE,self.Entity,self.Target or NULL,table.concat(self.DialledAddress or {}):sub(1,9),self.DialType);
	if(allow == false or GetConVar("stargate_group_system"):GetBool() and self:GetGateGroup()=="") then return end;
	self:NoxActivateStargate(self.DialType.Inbound);
end

function ENT:OnButtStartDialling()
	self:FindGate();
	local allow = hook.Call("StarGate.Dial",GAMEMODE,self.Entity,self.Target or NULL,table.concat(self.DialledAddress or {}):sub(1,9),self.DialType);
	if(allow == false or GetConVar("stargate_group_system"):GetBool() and self:GetGateGroup()=="") then return end;
	self:OnButtActivateStargate(self.DialType.Inbound);
end