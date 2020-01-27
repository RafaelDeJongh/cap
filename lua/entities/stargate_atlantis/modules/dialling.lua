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
-- FIXME: Todo - Rewrite this using "ANIM" like in "stargate_iris" sent.
ENT.Sequence = {};

--################# Pegasus gates - Dialling sequence @aVoN
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
	self.ChevronLocks = self.ChevronLocksb;
	if (count == 9) then
		chevs = 8
		if (not inbound) then
			self.ChevronLocks = self.ChevronLocks8o;
		end
	elseif (count == 10) then
		chevs = 9
		if (not inbound) then
			self.ChevronLocks = self.ChevronLocks9o;
		end
	end
	local t = self.Entity.Target;
	--################# INBOUND DIALLING
	if(inbound) then
		if (inbound and not fast and IsValid(t) and t.IsNewSlowDial) then
			action:Add({f=self.SetStatus,v={self,false,true,true},d=0.6}); -- The first true tells, "we are in use", but the last tells wire NOT to indicate us as "Active". Otherwise, on a slow dial-in, a gate becomes "Wire-Active" even if it's not currently dialling
			action:Add({f=self.SetStatus,v={self,false,true},d=0.1});
			local dly = self:CalcDelaySlow(t,true)
			action = self.Sequence:InstantOpen(action,dly,false,true);
		else
			local add = 0
			if (IsValid(t)) then
				add = self:CalcDelayFast(t,inbound);
			end
			add = add + 2.5; -- The delay is necessary because the diallin below takes about 4.5 seconds with a delay of 0.1 second between each light
			local rnd = {};
			for i=1,chevs do
				math.randomseed(os.clock()+i); -- Increases randomness
				if(i == 4 and chevs == 7) then
					-- This delay must be a bit shorter!
					rnd[i] = math.random(11,13)/100;
					add = add + (0.1-rnd[i])*12;
				elseif(i == 5 and chevs == 8) then
					-- This delay must be a bit shorter!
					rnd[i] = math.random(12.5,15)/100;
					add = add + (0.1-rnd[i])*8;
				else
					rnd[i] = math.random(14,17)/100;
					add = add + (0.1-rnd[i])*4;
				end
			end
			if IsValid(t) and not fast then
				add = add + t:DialSlowTime(chevs,self)
			end
			action:Add({f=self.SetStatus,v={self,false,true,true},d=add}); -- The first true tells, "we are in use", but the last tells wire NOT to indicate us as "Active". Otherwise, on a slow dial-in, a gate becomes "Wire-Active" even if it's not currently dialling
			action:Add({f=self.SetStatus,v={self,false,true},d=0.2});
			for i=1,9 do
				action:Add({f=self.ActivateChevron,v={self,i,false,true},d=0});
			end
			action:Add({f=self.SetChevrons,v={self,0,0},d=0}); -- Wire
			action:Add({f=self.RingLight,v={self,0,true},d=0});
			action:Add({f=self.RingLight,v={self,0,false},d=0});
			action:Add({f=self.Fire,v={self.Entity,"SetBodyGroup",0,0.05},d=0});
			action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Ring,90,math.random(98,103)},d=0.1}); -- Ring Sound
			action:Add({f=self.Fire,v={self.Entity,"SetBodyGroup",1},d=0.2}); -- Activate the mainlight
			-- We are doing exactly 36 steps, so we are adding this delay now in every step.
			--action:Add({f=self.Fire,v={self.Entity,"SetBodyGroup",1},d=0.5}); -- Activate the gate's inbound lights
			for i=1,4 do
				action:Add({f=self.RingLight,v={self,self.ChevronLocks[1] - 4 + i,true},d=rnd[1]});
			end
			-- Chevron 1-7
			for i=1,chevs do
				if (address[i] != nil) then
					DialAddress = DialAddress..tostring(address[i]);
					if (IsValid(self.Target) and self.Target.IsStargate and self.Target.Entity:GetGateAddress():len()!=0) then
						DialSymbol = tostring(address[i]);
					else
						DialSymbol = "";
					end
				end
				-- Chevron activated
				local snd = self.Sounds.Inbound;
				if(i == chevs) then snd = self.Sounds.LockInbound end;
				local s = i;
				if ((chevs == 8 or chevs == 9) and i == 4) then
					s = 8
				elseif (chevs == 9 and i == 5) then
					s = 9
				elseif (chevs == 8 and i > 4) then
					s = i-1
				elseif (chevs == 9 and i > 5) then
					s = i-2
				end
				if (i == chevs) then
					s = 7
				end
				action:Add({f=self.SetChevrons,v={self,s,1},d=0}); -- Wire
				action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
				action:Add({f=self.SetWire,v={self,"Dialing Address",DialAddress},d=0}); -- Wire
				action:Add({f=self.SetWire,v={self,"Dialed Symbol",DialSymbol},d=0}); -- Wire
				action:Add({f=self.EmitSound,v={self.Entity,snd,90,math.random(98,103)},d=0});
				action:Add({f=self.DHDSetChevron,v={self,i,0.05},d=0});
				action:Add({f=self.ActivateChevron,v={self,s,true,true},d=0});
				if(i == chevs) then
					action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
					action:Add({f=self.RingLight,v={self,0},d=0.4}); -- Stop the spinning light - We don't need it anymore
				else
					-- Spinning light
					local chevron = self.ChevronLocks[s]; -- The startindex!
					local rounds = 4;
					if(i == 3 and chevs == 7) then
						rounds = 12;
					elseif(i == 3 and (chevs == 8 or chevs==9)) then
						rounds = 4;
					elseif(i == 4 and chevs == 8) then
						rounds = 8;
					elseif(i == 5 and chevs == 9) then
						rounds = 4;
					end
					for k=1,rounds do
						action:Add({f=self.RingLight,v={self,chevron+k,true},d=rnd[1+i]});
					end
				end
			end
		end
	else
		local dir = -1; -- Direction, into the moving chevrons goes
		local spin = 32;
		local spintime = 0.07;
		local chevacdelay = 0.5;
		if(fast)then
			spintime = 0.05; -- change for inbound delay
			dir = 1;
			spin = 14;
			chevacdelay = 0.4;
		elseif (self.FasterDial) then
			chevacdelay = 0
			spintime = 0.05
		end
		--################# OUTBOUND DIALLING
		local runs = 6
		local rand = 5
		if (count == 9) then
			runs = 7
			rand = 6
		elseif (count == 10) then
			runs = 8
			rand = 7
		end
		
		-- Random delay
		action:Add({f=self.SetStatus,v={self,false,true},d=0});
		for i=1,9 do
			action:Add({f=self.ActivateChevron,v={self,i,false,true},d=0});
		end
		action:Add({f=self.SetChevrons,v={self,0,0},d=0}); -- Wire
		action:Add({f=self.RingLight,v={self,0,true},d=0});
		action:Add({f=self.RingLight,v={self,0,false},d=0});
		action:Add({f=self.Fire,v={self.Entity,"SetBodyGroup",0,0.05},d=0});
		if(fast)then
            --sound = self.Sounds.Ring; -- Ring Sound
			action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Ring,90,math.random(98,103)},d=0}); -- Ring Sound
		else
		    action:Add({f=self.RingSound,v={self,true},d=0});
		end
        local rnd = {}; -- Random time-ammount by a call to make it more "unartificial"
    	for i=1,runs do
    		math.randomseed(os.clock()+i); -- Increases randomness
    		rnd[i] = math.Round(math.random(50,125)/100);
    	end
		local rnds = rnd[1]+rnd[2]+rnd[3]+rnd[4]+rnd[5]+rnd[6];
		if(chevs == 9)then
		    rnds = rnds+rnd[7]+rnd[8];
		elseif(chevs == 8)then
		    rnds = rnds+rnd[7]-1;
		end
		
        local add = 0
		if (IsValid(t) and fast) then
			add = self:CalcDelayFast(t,inbound);
		end

    	-- Time offsets
		local del = 5.5+add
    	local delta = (del - rnds)/rand;
    	for i=1,runs do
    		rnd[i] = math.Round((rnd[i]+delta)*10)/10;
    	end
    	if(chevs == 9 or fast)then
		    rnds = rnd[1]+rnd[2]+rnd[3]+rnd[4]+rnd[5]+rnd[6];
		    if(chevs == 9)then
		        rnds = rnds+rnd[7]+rnd[8];
		    elseif(chevs == 8)then
		        rnds = rnds+rnd[7];
		    end
		end
		if (self.DialledAddress[1] != nil) then
			action:Add({f=self.SetWire,v={self,"Dialing Symbol",tostring(self.DialledAddress[1])},d=0}); -- Wire
		end
		-- Start spinning
    	local chev = self.ChevronLocks[1]-spin*dir;
    	for i=1,spin do
    		chev = chev+dir;
    		action:Add({f=self.RingLight,v={self,chev},d=spintime});
    	end
		action:Add({f=self.RingLight,v={self,0},d=0});
		-- Chevron 1-7
		for i=1,chevs do
			-- Output to wire dialled address
			if (self.DialledAddress[i] != nil) then
				DialAddress = DialAddress..tostring(self.DialledAddress[i]);
				DialSymbol = tostring(self.DialledAddress[i]);
				if (i <= chevs and self.DialledAddress[i+1] != nil and self.DialledAddress[i+1] != "DIAL") then
					DialNextSymbol = tostring(self.DialledAddress[i+1]);
				else
					DialNextSymbol = "";
				end
			end
			if(i < chevs or i == chevs and (not fail or busy) and not self.chev_destroyed[7]) then
				-- Chevron activated
	    		local snd = self.Sounds.Chevron;
				if(not fast)then
				    snd = self.Sounds.Chevron2;
				end
				if(i == chevs) then
					snd = self.Sounds.Lock
					action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
				end
				action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
				action:Add({f=self.SetWire,v={self,"Dialing Address",DialAddress},d=0}); -- Wire
				action:Add({f=self.SetWire,v={self,"Dialed Symbol",DialSymbol},d=0}); -- Wire
				if (i == chevs) then action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); end -- Wire
				action:Add({f=self.EmitSound,v={self.Entity,snd,90,math.random(98,103)},d=0});
				action:Add({f=self.DHDSetChevron,v={self,i,0.05},d=0});
				local s = i;
				local b = i+1;
				if ((chevs == 8 or chevs == 9) and i == 7) then
					s = 8
					b = 9
				elseif (chevs == 9 and i == 8) then
					s = 9
					b = 10
				elseif (i == chevs) then
					s = 7
					b = 8
					if (chevs == 8) then
						b = 11
					elseif (chevs == 9) then
						b = 12
					end
				end
				action:Add({f=self.SetChevrons,v={self,s,1},d=0}); -- Wire
				action:Add({f=self.ActivateChevron,v={self,s,true,false,b,self.FasterDial},d=chevacdelay});
				action:Add({f=self.SetWire,v={self,"Dialing Symbol",DialNextSymbol},d=0}); -- Wire
				if(i == chevs) then
					-- Delay correction, or the gate openes to fast or slow because of the random dialling times
					local correction = del - (rnds);
					if (busy) then
						action:Add({f=self.RingLight,v={self,0},d=1.4 + correction}); -- Stop the spinning light - We don't need it anymore
						action:Add({f=self.SetWire,v={self,"Chevron",-chevs},d=0}); -- Tell Wire, we failed to lock!
					else
						action:Add({f=self.RingLight,v={self,0},d=0.4 + correction}); -- Stop the spinning light - We don't need it anymore
					end
				else
					-- Spinning light
					dir = dir*(-1); -- Change the direction of the spinning
					local rounds = 0;
					if(fast)then
		    		    rounds = (rnd[i]*10-4)*2; -- Calculate the necessary rounds for each spin
					else
					    rounds = 40;
						if (not self.FasterDial) then
							action:Add({f=self.RingSound,v={self,true},d=0});
						end
		    		  	if(i == 2 or i == 4)then
	    		  	        rounds = 32;
	    		  	    elseif(i == 3)then
	    		  	        rounds = 48;
	    		  	    elseif(i == 6)then
						    rounds = 32;
							if(chevs == 8 or chevs == 9)then
	    		  	            rounds = 52;
							end
	    		  	    elseif(i == 7)then
					        if(chevs == 9)then
	    		  	            rounds = 40;
							elseif(chevs == 8)then
							    rounds = 56;
							end
				  	    elseif(i == 8)then
				  	        rounds = 20;
	    		  	    end
					end
			    	local chev = self.ChevronLocks[i+1]-rounds*dir;
		    		for i=1,rounds do
		    			chev = chev+dir;
		    			action:Add({f=self.RingLight,v={self,chev},d=spintime});
		    		end
					if(not fast and i == 8 and chevs == 9)then
					    chev = self.ChevronLocks[i+1]-36*dir;
					    for i=1,36 do
		    			    chev = chev+dir;
		    			    action:Add({f=self.RingLight,v={self,chev},d=spintime});
		    		    end
					end
					action:Add({f=self.RingLight,v={self,0},d=0}); -- Stop the light of the spinning wheel
				end
			else
				action:Add({f=self.SetWire,v={self,"Chevron",-chevs},d=0}); -- Tell Wire, we failed to lock!
				action:Add({f=self.RingSound,v={self,false},d=0});
			end
		end
	end
	if(not fail) then
		action:Add({f=self.DHDSetChevron,v={self,count},d=0}); -- Activate near DHDs
	end
	return action;
end

--################# DialFail sequence @aVoN
function ENT.Sequence:DialFail(instant_stop,play_sound)
	local action = self:New();
	local delay = 1.5;
	if(instant_stop) then delay = 0 end;
	action:Add({f=self.SetStatus,v={self,false,true,true},d=0}); -- We need to keep in "dialling" mode to get around with conflicts
	if(self.Entity.Active or play_sound) then
	    action:Add({f=self.RingSound,v={self,false},d=0});
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
		action:Add({f=self.DisActivateLights,v={self},d=0});
	end
	action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
	action:Add({f=self.SetChevrons,v={self,0,0},d=0}); -- Wire
	action:Add({f=self.SetStatus,v={self,false,false},d=0.8}); -- Make the Wire-Value of "-7" = dial-fail stay longer so people's script work along with the sound
	action:Add({f=self.SetWire,v={self,"Chevron",0},d=0}); -- Wire
	action:Add({f=self.SetShutdown,v={self,false},d=0});
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
	local chevs = 7;
	local count = #self.DialledAddress
	if (inbound and IsValid(self.Target) and self.Target.IsStargate) then
		count = #self.Target.DialledAddress
	end
	chevs = 7
	if (count >= 8 and count <= 10) then
		chevs = count-1;
	end
	for i=1,9 do
		action:Add({f=self.ActivateChevron,v={self,i,false,true},d=0});
	end
	action:Add({f=self.SetChevrons,v={self,0,0},d=0}); -- Wire
	action:Add({f=self.RingSound,v={self,false},d=0});
	action:Add({f=self.RingLight,v={self,0,true,true},d=0});
	action:Add({f=self.RingLight,v={self,0,false,true},d=0});
	action:Add({f=self.Fire,v={self.Entity,"SetBodyGroup",0,0.05},d=0});
	for i=1,chevs do
		local b = i+1;
		if (i == 8) then
			b = 11
		elseif (i == 9) then
			b = 12
		end
		action:Add({f=self.ActivateChevron,v={self,i,true,inbound,b},d=0});
		action:Add({f=self.DHDSetChevron,v={self,i},d=0});
	end
	if (inbound) then
		action:Add({f=self.RingLight,v={self,36,true},d=0});
	end
	local dialaddress = "";
	for i=1,chevs do
		if (self.DialledAddress[i] != nil) then
			dialaddress = dialaddress..tostring(self.DialledAddress[i]);
		end
	end
	action:Add({f=self.SetChevrons,v={self,chevs,1,true},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	if (not fail) then
		action:Add({f=self.SetWire,v={self,"Chevron",chevs},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
	else
		action:Add({f=self.SetWire,v={self,"Chevron",-chevs},d=0}); -- Wire
	end
	if (inbound) then
		action:Add({f=self.SetWire,v={self,"Inbound",1},d=0});
	end
	if (nox or not inbound) then
		action:Add({f=self.FakeDelay,v={self},d=delay});
	else
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.LockInbound,90,math.random(98,103)},d=delay});
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
		for i=1,9 do
			action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
		end
		action:Add({f=self.ActivateChevron,v={self,1,false},d=0.1});
		action:Add({f=self.Shutdown,v={self},d=0});
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Fail,90,math.random(98,103)},d=0});
		action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	end
	action:Add({f=self.SetWire,v={self,"Chevron",-chev},d=0}); -- Wire
	return action;
end

function ENT.Sequence:OnButtonChevron(lightup, dialchev, address, symbol, fail, busy, slow)
	local action = self:New();
	local dialaddress = "";
	local dialsymbol = "";
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
	else
		action:Add({f=self.SetStatus,v={self,false,false,false,false},d=0});
	end

 	local actdialchev = dialchev
	if (not lightup) then actdialchev = actdialchev+1 end
	if (symbol != "#" and actdialchev!=9) then
		if (actdialchev==7 or actdialchev==8) then
			actdialchev = actdialchev+1;
		end
	else
		actdialchev = 7
	end

	local b = dialchev+1;

	if (dialchev == 7 and symbol != "#") then
		b = 9
	elseif (dialchev == 8 and symbol != "#") then
		b = 10
	elseif (dialchev == 8 and symbol == "#") then
		b = 11
	elseif (dialchev == 9) then
		b = 12
	end

	if (not lightup) then
		if (dialchev == 7 and symbol == "#") then
			b = 9
		elseif (dialchev == 8) then
			b = 10
		end
	end

	if lightup then
		local dir = (-1)^(dialchev); -- Direction, into the moving chevrons goes
		local rounds = 16;
		local spintime = 0.05;
		if(slow)then
			spintime = 0.06;
			rounds = 32;
		end
		local snd = self.Sounds.Chevron2;
		local chev = self.ChevronLocksb[actdialchev]-rounds*dir; -- where are we starting?
		action:Add({f=self.RingLight,v={self,0,true,true},d=0});
		action:Add({f=self.RingLight,v={self,0,false,true},d=0});
		action:Add({f=self.SetWire,v={self,"Dialing Symbol",dialsymbol},d=0}); -- Wire
		--action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Ring,90,math.random(98,103)},d=0}); -- Ring Sound
		if (slow) then action:Add({f=self.RingSound,v={self,true},d=0}); end
		for i=1,rounds do
			chev = chev+dir;
			action:Add({f=self.RingLight,v={self,chev},d=spintime});
		end
		action:Add({f=self.RingSound,v={self,false},d=0});
		if (actdialchev != 7 or not fail) then
			action:Add({f=self.EmitSound,v={self.Entity,snd,90,math.random(98,103)},d=0});
		end
		if (not fail or busy) then
			action:Add({f=self.ActivateChevron,v={self,actdialchev,true,false,b},d=0}); -- Chevron lights up
			action:Add({f=self.SetChevrons,v={self,actdialchev,1},d=0}); -- Wire
			action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
		elseif (fail) then
			action:Add({f=self.RingLight,v={self,0,true,true},d=0});
			action:Add({f=self.RingLight,v={self,0,false,true},d=0});
			action:Add({f=self.SetWire,v={self,"Chevron",-dialchev},d=0}); -- Wire
		end
		action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire

		if (actdialchev == 7) then
			if (not fail) then
				action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
			else
				local delay = 2.0
				if (busy) then delay = 1.5 end
				action:Add({f=self.EmitSound,v={self.Entity,snd,90,math.random(98,103)},d=delay});
			end
		end
	else
		--local snd = self.Sounds.Chevron2;
		--action:Add({f=self.EmitSound,v={self.Entity,snd,90,math.random(98,103)},d=0});
		action:Add({f=self.StopActions,v={self},d=0});
		action:Add({f=self.RingLight,v={self,0,true,true},d=0});
		action:Add({f=self.RingLight,v={self,0,false,true},d=0});

		action:Add({f=self.ActivateChevron,v={self,actdialchev,false,false,b},d=0}); -- Chevron lights down
		action:Add({f=self.SetChevrons,v={self,actdialchev,0},d=0}); -- Wire

		action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
	end
	return action;
end