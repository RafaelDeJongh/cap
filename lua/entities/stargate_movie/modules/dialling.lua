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

	Movie Stargate for Garry's Mod
	File modified By AlexALX
	(c) 2010 by http://alex-php.net/
*/
-- FIXME: Todo - Rewrite this using "ANIM" like in "stargate_iris" sent.
ENT.Sequence = {};

--#################  Milkyway movie gates - dialling sequence @aVoN / AlexALX
-- ATTENTION: The dialling time takes exactly 7 seconds with my gates (dialled in fast mode). When you code your own gates, make them take 7 seconds too!
-- You can check a dialling sequence's length with adding "print_r(delay)" to end of the stargate_base's ENT:RunAction() function
function ENT.Sequence:Dial(inbound,fast,fail,busy)
	local action = self:New();
	local DialAddress = ""
	local DialSymbol = ""
	local DialNextSymbol = ""
	local count = #self.DialledAddress
	local address = self.DialledAddress;
	if (inbound and IsValid(self.Target) and self.Target.IsStargate) then
		count = #self.Target.DialledAddress
	elseif (inbound) then
		address = {};
	end
	local chevs = 7
	if (count >= 8 and count <= 10) then
		chevs = count-1;
	end
	local classicmode = false;
	local sgctype = false;
	if (self.Classic) then
		classicmode = true;
		if (self.RingInbound) then
			sgctype = true;
		end
	end
	local chevlight = false;
	if (self.ChevLight) then
		chevlight = true;
	end
	--################# INBOUND AND DHD (fast) DIAL
	if(inbound or fast) then
		local t = self.Entity.Target;
		if (inbound and not fast and IsValid(t) and t.IsNewSlowDial) then
			action:Add({f=self.SetStatus,v={self,false,true,true},d=0.6}); -- The first true tells, "we are in use", but the last tells wire NOT to indicate us as "Active". Otherwise, on a slow dial-in, a gate becomes "Wire-Active" even if it's not currently dialling
			action:Add({f=self.SetStatus,v={self,false,true},d=0.1}); -- The 0.1 seconds prevents a bug where an incoming call overrides an outgoing (slow dial) and the first chevrons stays disabled (so we need definitely a shot delay!) - This additional 0.1 we take here has been removed on the chevron7-lock delay in the for loop below
			local dly = self:CalcDelaySlow(t,true)
			action = self.Sequence:InstantOpen(action,dly,false,true);
		else
			local rnd = {}; -- Increase randomness (makes it less artificial)
			for i=1,chevs-2 do
				math.randomseed(os.clock()+i);
				rnd[i] = math.random(30,100)/100;
			end
			rnd[chevs-1] = 1;
			local rnds = rnd[1]+rnd[2]+rnd[3]+rnd[4]+rnd[5]+rnd[6];
			if(chevs == 9)then
			    rnds = rnds+rnd[7]+rnd[8];
			elseif(chevs == 8)then
			    rnds = rnds+rnd[7];
			end
			local add = 0.0;
			if (IsValid(t)) then
				add = self:CalcDelayFast(t,inbound);
			end
			local del = 4.8+add
			if (chevs == 9 and not inbound) then
				del = del-0.6
			end		
			local delta = (del - (rnds))/(chevs-1); -- Neede, so the eventhorizons get opened in the same time
			if (fast and not inbound or self.RingInbound) then
 				delta = ((del-0.8) - (rnds))/(chevs-1); -- Neede, so the eventhorizons get opened in the same time
			end
			local add = 0
			if (IsValid(t) and inbound and not fast) then
				add = t:DialSlowTime(chevs,self)
			end
			action:Add({f=self.SetStatus,v={self,false,true,true},d=add}); -- The first true tells, "we are in use", but the last tells wire NOT to indicate us as "Active". Otherwise, on a slow dial-in, a gate becomes "Wire-Active" even if it's not currently dialling
			action:Add({f=self.SetStatus,v={self,false,true},d=0.1}); -- The 0.1 seconds prevents a bug where an incoming call overrides an outgoing (slow dial) and the first chevrons stays disabled (so we need definitely a shot delay!) - This additional 0.1 we take here has been removed on the chevron7-lock delay in the for loop below
			for i=1,9 do
				action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
			end
			action:Add({f=self.SetChevrons,v={self,0,0},d=0}); -- Wire
			action:Add({f=self.WireOrigin,v={self},d=0}); -- Wire
			action:Add({f=self.ActivateRing,v={self,false},d=0});
			
			if (chevs == 9 and not inbound) then
				action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Chev9Dial,95,108},d=0.6});
			end
			
			if(inbound) then
				local dly = 1.9
				-- This adds some more delay between eachchevron.
				-- This corrects the 0.9 seconds which are missing from not spinning the ring (below) and the missing 1 second from Chevron7 till the event horizon openes (1.3 seconds vs 0.3)
				if (self.RingInbound) then
					action:Add({f=self.ActivateRing,v={self,true,false,_,true},d=0});
					dly = 0.9;
				end
				delta = delta + dly/(chevs-1);
			else
				if (address[1] != nil) then
					action:Add({f=self.SetWire,v={self,"Dialing Symbol",tostring(address[1])},d=0}); -- Wire
				end
				action:Add({f=self.ActivateRing,v={self,true,classicmode,_,true},d=0.9}); -- Start spinning
			end
			--Chevron 1-9
			for i=1,chevs do
				if (address[i] != nil) then
					DialAddress = DialAddress..tostring(address[i]);
					if (IsValid(self.Target) and self.Target.IsStargate and self.Target.Entity:GetGateAddress():len()!=0) then
						DialSymbol = tostring(address[i]);
					else
						DialSymbol = "";
					end
					if (not inbound and i < chevs and address[i+1] != nil) then
						DialNextSymbol = tostring(address[i+1]);
					else
						DialNextSymbol = "";
					end
				end
				action:Add({f=self.SetWire,v={self,"Dialing Symbol",DialNextSymbol},d=0}); -- Wire
				-- Chevron lights
				if (i==chevs and (self.RingInbound or fast and not inbound)) then
					action:Add({f=self.ActivateRing,v={self,false,false,true},d=0.8}); -- Stop Ring
					action:Add({f=self.StopRingSound,v={self},d=0}); -- Stop the ring sound
				end
				if(i == chevs and (fail and not self.chev_destroyed[7])) then
					if (classicmode) then
						action:Add({f=self.ChevronAnimation,v={self,7,true},d=0}); -- Animate chevron 7
					else
						action:Add({f=self.ActivateChevron,v={self,7,true},d=0});
					end
					if (busy) then
						action:Add({f=self.DHDSetChevron,v={self,i,0.05},d=0})
						if (classicmode or chevlight) then
							action:Add({f=self.ActivateChevronLight,v={self,7,true},d=0});
						end
						action:Add({f=self.SetChevrons,v={self,7,1},d=0}); -- Wire
						action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
						action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
					end
					if (classicmode) then
						action:Add({f=self.ChevronSound,v={self,7,fast,inbound,false,true},d=2.0}); -- Chevron Locked
					else
						action:Add({f=self.FakeDelay,v={self},d=1.5});
					end
					action:Add({f=self.SetWire,v={self,"Chevron",-chevs},d=0}); -- Wire
				else
					local s = i
	 				if (i == 7 and (chevs == 8 or chevs == 9)) then
						s = 8
					elseif (i == 8 and chevs == 9) then
						s = 9
					elseif (i == 8 and chevs == 8 or i == 9 and chevs == 9) then
						s = 7
					end
					action:Add({f=self.DHDSetChevron,v={self,i,0.05},d=0});
					action:Add({f=self.SetChevrons,v={self,s,1},d=0}); -- Wire
					action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
					action:Add({f=self.SetWire,v={self,"Dialing Address",DialAddress},d=0}); -- Wire
					action:Add({f=self.SetWire,v={self,"Dialed Symbol",DialSymbol},d=0}); -- Wire
					if (classicmode or chevlight) then
						action:Add({f=self.ActivateChevronLight,v={self,s,true},d=0});
					end
					if(i == chevs) then
						action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
						if(inbound) then
							if (self.RingInbound) then
								if (classicmode) then
									action:Add({f=self.ChevronAnimation,v={self,7,true},d=0}); -- Animate chevron 7
									action:Add({f=self.ChevronSound,v={self,7,fast,true,false,true},d=1.2});
								else
									action:Add({f=self.ActivateChevron,v={self,7,true,inbound},d=1.2});
								end
							else
								if (classicmode) then
									action:Add({f=self.ChevronSound,v={self,7,fast,inbound,false,true},d=0.2});
								else
									action:Add({f=self.ActivateChevron,v={self,7,true,inbound},d=0.2});
								end
							end
						else
							if (classicmode) then
								action:Add({f=self.ChevronAnimation,v={self,7,true},d=0}); -- Animate chevron 7
								action:Add({f=self.ChevronSound,v={self,7,fast,inbound,false,true},d=1.2}); -- Chevron Locked
							else
								action:Add({f=self.ActivateChevron,v={self,s,true},d=1.2});
							end
						end
					else
						if (classicmode) then
							action:Add({f=self.ChevronSound,v={self,s,fast,inbound,false,true},d=rnd[i]+delta}); -- Chevron Locked
						else
							action:Add({f=self.ActivateChevron,v={self,s,true,inbound},d=rnd[i]+delta});
						end
					end
				end
			end
		end
	else
		--################# OUTBOUND DIALLING (slow)
		local delt = 20
		if (count == 9) then
			delt = 24
		elseif (count == 10) then
			delt = 28
		end
		local rnd = {}; -- Increases randomness
		for i=1,chevs do
			math.randomseed(os.clock()+i);
			rnd[i] = math.random(300,400)/100;
		end
		local rnds = rnd[1]+rnd[2]+rnd[3]+rnd[4]+rnd[5]+rnd[6]+rnd[7];
		if(chevs == 9)then
		    rnds = rnds+rnd[8]+rnd[9];
		elseif(chevs == 8)then
		    rnds = rnds+rnd[8];
		end
		local delta = (delt-(rnds))/chevs; -- Add delta values according to the random dialling speed to fit 7 seconds
		action:Add({f=self.SetStatus,v={self,false,1,false,true,false},d=0}); -- The 1 means, it's dailling slowly and "can be dialled in" (About Dialling out) - It's special for SG1 Gate and is handled in ENT:ActivateStargate()
		for i=1,9 do
			action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
		end
		action:Add({f=self.SetChevrons,v={self,0,0},d=0}); -- Wire
		action:Add({f=self.ActivateRing,v={self,false},d=0});
		local t = self.Entity.Target;
		if (not fast and IsValid(t)) then
			action:Add({f=self.PauseActions,v={t,false,true},d=0});
		end
		if (chevs == 9 and not inbound) then
			action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Chev9Dial,95,108},d=0.7});
		end
		-- Chevron 1-9
		for i=1,chevs do
			if (self.DialledAddress[i] != nil) then
				DialAddress = DialAddress..tostring(self.DialledAddress[i]);
				DialSymbol = tostring(self.DialledAddress[i]);
				local s = i
 				if (i == 7 and (chevs == 8 or chevs == 9)) then
					s = 8
				elseif (i == 8 and chevs == 9) then
					s = 9
				elseif (i == 8 and chevs == 8 or i == 9 and chevs == 9) then
					s = 7
				end
				action:Add({f=self.SetDiallingSymbol,v={self,DialSymbol,s},d=0});
			end
			if (i <= chevs and self.DialledAddress[i] != nil) then
				action:Add({f=self.SetWire,v={self,"Dialing Symbol",self.DialledAddress[i]},d=0}); -- Wire
			else
				action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
			end
			-- Spinning ring
			action:Add({f=self.ActivateRing,v={self,true,false,false},d=1.0}); --,d=rnd[i]+delta}); -- Roll the ring
			action:Add({f=self.SetRingMoving,v={self},d=0});
			action:Add({f=self.PauseActions,v={self,false},d=0.97});
			action:Add({f=self.StopRingSound,v={self},d=0}); -- Stop the ring sound
			action:Add({f=self.DHDSetChevron,v={self,i},d=0});
			-- Chevron lights
			if(i == chevs) then
				if(fail and not self.chev_destroyed[7]) then
					if (classicmode) then
						action:Add({f=self.ChevronAnimation,v={self,7,true},d=0}); -- Animate chevron 7
					else
						for c=1,chevs do
							action:Add({f=self.ActivateChevron,v={self,c,true},d=0});
						end
					end
					if (busy) then
						if (classicmode or chevlight) then
							action:Add({f=self.ActivateChevronLight,v={self,7,true},d=0});
						end
						action:Add({f=self.SetChevrons,v={self,7,1},d=0}); -- Wire
						action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
						action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
					end
					if (classicmode) then
						action:Add({f=self.ChevronSound,v={self,7,fast,inbound,false,true},d=2.0}); -- Chevron Locked
					else
						action:Add({f=self.FakeDelay,v={self},d=1.5});
					end
					action:Add({f=self.SetWire,v={self,"Chevron",-chevs},d=0}); -- Wire
				else
					local t = self.Entity.Target;
					if (not inbound and not fast and IsValid(t)) then
						action:Add({f=self.PauseActions,v={t,true,true},d=0});
					end
					action:Add({f=self.SetWire,v={self,"Dialing Address",DialAddress},d=0}); -- Wire
					action:Add({f=self.SetWire,v={self,"Dialed Symbol",DialSymbol},d=0}); -- Wire
					action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
					action:Add({f=self.SetChevrons,v={self,7,1},d=0}); -- Wire
					action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
					local dly = self.DialSlowDelay
					if (IsValid(t)) then
						dly = self:CalcDelaySlow(t)
					end
					if (classicmode) then
						if (sgctype) then
							action:Add({f=self.ActivateChevronLight,v={self,7,true},d=0}); -- Chevron lights up
							action:Add({f=self.ChevronAnimation,v={self,7,true},d=0}); -- Animate chevron
							action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
							action:Add({f=self.ChevronSound,v={self,7,false,false,false,true},d=dly}); -- Chevron Locked
						else
							action:Add({f=self.ChevronAnimation,v={self,7,true},d=0}); -- Animate chevron
							action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
							action:Add({f=self.ChevronSound,v={self,7,false,false,false,true},d=dly-0.6}); -- Chevron Locked
							action:Add({f=self.ActivateChevronLight,v={self,7,true},d=dly-1.4}); -- Chevron lights up
						end
					else
						for c=1,chevs do
							action:Add({f=self.ActivateChevron,v={self,c,true},d=0});
						end
						if (chevlight) then
							action:Add({f=self.ActivateChevronLight,v={self,7,true},d=0});
						end
						action:Add({f=self.SetWire,v={self,"Chevron",i},d=dly}); -- Wire
					end
				end
			else
				local s = i
				if (i == 7 and (chevs == 8 or chevs == 9) or i == 8 and chevs == 9) then
					s = s+1;
				end
				if (sgctype) then
					action:Add({f=self.ChevronSound,v={self,s,false,false,false,true},d=0.4}); -- Chevron Locked
					action:Add({f=self.ChevronAnimation,v={self,s,classicmode},d=0}); -- Animate chevron
					action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
					action:Add({f=self.SetWire,v={self,"Dialed Symbol",DialSymbol},d=0}); -- Wire
					action:Add({f=self.SetChevrons,v={self,s,1},d=0}); -- Wire
					action:Add({f=self.ActivateChevronLight,v={self,s,true},d=1.8}); -- Chevron lights up
				else
					action:Add({f=self.ChevronAnimation,v={self,s,classicmode},d=0}); -- Animate chevron
					action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
					action:Add({f=self.SetWire,v={self,"Dialed Symbol",DialSymbol},d=0}); -- Wire
					action:Add({f=self.SetChevrons,v={self,s,1},d=0}); -- Wire
				end
				if (classicmode) then
					if (not sgctype) then
						action:Add({f=self.ChevronSound,v={self,s,false,false,false,true},d=1.7}); -- Chevron Locked
						action:Add({f=self.ActivateChevronLight,v={self,s,true},d=0.8}); -- Chevron lights up
					end
				else
					if (chevlight) then
						action:Add({f=self.ChevronSound,v={self,s},d=1.7}); -- Chevron Locked
						action:Add({f=self.ActivateChevronLight,v={self,s,true},d=0.8});
					else
						action:Add({f=self.ChevronSound,v={self,s},d=2.5}); -- Chevron Locked
					end
				end
				action:Add({f=self.SetWire,v={self,"Dialing Address",DialAddress},d=0}); -- Wire
			end
		end
	end
	if(not fail) then
		action:Add({f=self.DHDSetChevron,v={self,count},d=0}); -- Activate near DHDs
	end
	return action;
end

--################# Instantly open sequence for new slow dial and on button press by AlexALX
function ENT.Sequence:InstantOpen(action,delay,instant,inbound,slow,nox,fail)
	if (not action) then
		action = self:New();
	end
	if (instant) then
		action:Add({f=self.SetStatus,v={self,false,true,false,true},d=0});
	end
	if (inbound) then
		self:SetWire("Inbound",1)
	end
	local chevs = 7;
	local count = #self.DialledAddress
	if (inbound and IsValid(self.Target) and self.Target.IsStargate) then count = #self.Target.DialledAddress end
	chevs = 7
	if (count >= 8 and count <= 10) then chevs = count-1; end
	local classicmode = false;
	if (self.Classic) then classicmode = true; end
	if (classicmode) then self.Sounds = self.SoundsClassic; else self.Sounds = self.SoundsBak; end
	local chevlight = false;
	if (self.ChevLight) then chevlight = true; end
	for i=1,9 do
		action:Add({f=self.ActivateChevron,v={self,i,false,false,true},d=0});
	end
	action:Add({f=self.SetChevrons,v={self,0,0},d=0}); -- Wire
	action:Add({f=self.WireOrigin,v={self},d=0}); -- Wire
	if (instant) then
		action:Add({f=self.ActivateRing,v={self,false},d=0});
	else
		action:Add({f=self.ActivateRing,v={self,false},d=0.1});
	end
	for i=1,chevs do
		if (classicmode or chevlight) then
			action:Add({f=self.ActivateChevronLight,v={self,i,true},d=0});
		end
		if (not classicmode) then
			action:Add({f=self.ActivateChevron,v={self,i,true,false,not inbound and not nox},d=0});
		end
		action:Add({f=self.DHDSetChevron,v={self,i},d=0});
	end
	local dialaddress = "";
	for i=1,chevs do
		if (self.DialledAddress[i] != nil) then
			dialaddress = dialaddress..tostring(self.DialledAddress[i]);
		end
	end
	action:Add({f=self.SetChevrons,v={self,chevs,1,true},d=0}); -- Wire
	if (inbound and classicmode and not nox) then
		action:Add({f=self.ChevronSound,v={self,1,false,true,false,true,true},d=0});
	end
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
	if (not fail) then
		action:Add({f=self.SetWire,v={self,"Chevron",chevs},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
	else
		action:Add({f=self.SetWire,v={self,"Chevron",-chevs},d=0}); -- Wire
	end
	if (inbound) then
		action:Add({f=self.SetWire,v={self,"Inbound",1},d=0});
	end
	/*if (not inbound and not slow and not nox) then
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.OnButtonLock,90,math.random(98,103)},d=0});
	end*/
	if (instant) then
		action:Add({f=self.FakeDelay,v={self},d=delay}); -- Wire
	else
		action:Add({f=self.FakeDelay,v={self},d=delay-0.1}); -- Wire
	end
	return action;
end

--################# On Button Chevron Press Feature @Madman07, Edited by AlexALX
function ENT.Sequence:OnButtonDialFail(chev,only_chev_wire,busy)
	local action = self:New();
	if (busy) then
		--action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.OnButtonLock,90,math.random(98,103)},d=1.0});
		action:Add({f=self.FakeDelay,v={self.Entity},d=1.0});
	end
	if (not only_chev_wire) then
		action:Add({f=self.ActivateRing,v={self,false},d=0}); -- Stop the ring
		for i=1,9 do
			action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
		end
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Fail,90,math.random(98,103)},d=0});
		action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	end
	action:Add({f=self.SetWire,v={self,"Chevron",-chev},d=0}); -- Wire
	return action;
end

function ENT.Sequence:OnButtonChevron(lightup, dialchev, address, symbol, fail, busy, no_ring)
	if (not GetConVar("stargate_dhd_ring"):GetBool()) then no_ring = true end
	local action = self:New();
	local dialaddress = "";
	local dialsymbol = "";
	local chev = dialchev;
	for i=1,dialchev do
		if (address[i] != nil) then
			dialaddress = dialaddress..tostring(address[i]);
			if (i == dialchev) then
				dialsymbol = tostring(address[i]);
			end
		end
	end
	if (dialchev >= 1) then
		action:Add({f=self.SetStatus,v={self,false,false,false,true,true},d=0});
		if (not self.Ring.WireMoving and not no_ring) then
			action:Add({f=self.ActivateRing,v={self,true},d=0}); -- Stop the ring
		end
	else
		action:Add({f=self.SetStatus,v={self,false,false,false,false},d=0});
		action:Add({f=self.ActivateRing,v={self,false},d=0}); -- Stop the ring
	end
	local classicmode = false;
	local chevlight = false;
	if (dialchev == 1) then
		if (self.Classic) then classicmode = true; self.ClassicMode = true; else self.ClassicMode = false; end
		if (classicmode) then self.Sounds = self.SoundsClassic; else self.Sounds = self.SoundsBak; end
		if (self.ChevLight) then chevlight = true; self.LightMode = true; else self.LightMode = false; end
	elseif (dialchev == 0) then
		self.ClassicMode = false;
		self.LightMode = false;
	else
		classicmode = self.ClassicMode;
		chevlight = self.LightMode;
	end
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire

	if (not lightup) then dialchev = dialchev+1 end
	if (symbol != "#" and dialchev!=9) then
		if (dialchev==7 or dialchev==8) then
			dialchev = dialchev+1;
		end
	else
		dialchev = 7
	end

	if (lightup) then
		if (dialchev == 7 and (not no_ring or self.Ring.WireMoving)) then
			action:Add({f=self.ActivateRing,v={self,false,false,true},d=0.9}); -- Stop the ring
			action:Add({f=self.StopRingSound,v={self},d=0}); -- Stop the ring
		end
		if (fail and not busy) then
			action:Add({f=self.SetWire,v={self,"Chevron",-chev},d=0}); -- Wire
		else
			action:Add({f=self.SetWire,v={self,"Chevron",chev},d=0}); -- Wire
		end
		if (not fail) then
			if (classicmode or chevlight) then
				action:Add({f=self.ActivateChevronLight,v={self,dialchev,true},d=0});
			end
			if (not classicmode) then
				action:Add({f=self.ActivateChevron,v={self,dialchev,true,false},d=0});
			end
			action:Add({f=self.SetChevrons,v={self,dialchev,1},d=0}); -- Wire
			if (classicmode and self.chev_destroyed and not self.chev_destroyed[dialchev] and dialchev != 7) then
				action:Add({f=self.EmitSound,v={self.Entity,self.ButtChevSounds[math.random(1,table.getn(self.ButtChevSounds))],90,math.random(97,103)},d=0}); -- Chevron lights up
			end
		elseif (not classicmode) then
			action:Add({f=self.ActivateChevron,v={self,dialchev,true,false},d=0});
		end
		if (dialchev == 7) then
			if (not fail) then
				if (classicmode) then
					action:Add({f=self.ChevronSound,v={self,7,fast,false,false,true},d=0});
					action:Add({f=self.ChevronAnimation,v={self,7,true},d=0}); -- Animate chevron 7
				end
				action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
			else
				local delay = 2.0
				if (busy) then delay = 1.5 end
				if (classicmode) then
					action:Add({f=self.ChevronAnimation,v={self,7,true},d=0}); -- Animate chevron 7
					action:Add({f=self.ChevronSound,v={self,7,fast,false,false,true},d=delay});
				else
					action:Add({f=self.FakeDelay,v={self},d=delay});
				end
			end
		end
	else
		action:Add({f=self.SetWire,v={self,"Chevron",chev},d=0}); -- Wire
		action:Add({f=self.ActivateChevron,v={self,dialchev,false},d=0}); -- Chevron lights down
		action:Add({f=self.SetChevrons,v={self,dialchev,0},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
	end
	return action;
end