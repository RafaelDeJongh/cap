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

--#################  Milkyway gates - dialling sequence @aVoN
-- ATTENTION: The dialling time takes exactly 7 seconds with my gates (dialled in fast mode). When you code your own gates, make them take 7 seconds too!
-- You can check a dialling sequence's length with adding "print_r(delay)" to end of the stargate_base's ENT:RunAction() function
function ENT.Sequence:Dial(inbound,fast,fail)
	local action = self:New();
	local count = #self.DialledAddress
	local address = self.DialledAddress;
	if (inbound and IsValid(self.Target) and self.Target.IsStargate) then
		count = #self.Target.DialledAddress
	elseif (inbound) then
		address = {};
	end
	--################# INBOUND AND DHD (fast) DIAL
	if(fast or not fast) then
		local t = self.Entity.Target;
		action:Add({f=self.SetStatus,v={self,false,true,true},d=0}); -- The first true tells, "we are in use", but the last tells wire NOT to indicate us as "Active". Otherwise, on a slow dial-in, a gate becomes "Wire-Active" even if it's not currently dialling
		action:Add({f=self.SetStatus,v={self,false,true},d=0.1}); -- The 0.1 seconds prevents a bug where an incoming call overrides an outgoing (slow dial) and the first chevrons stays disabled (so we need definitely a shot delay!) - This additional 0.1 we take here has been removed on the chevron7-lock delay in the for loop below
		local add = 0
		if (IsValid(t)) then
			add = self:CalcDelayFast(t,inbound);
		end
		action:Add({f=self.GateSound,v={self},d=6.9+add});
		--Chevron 1-7
		for i=1,7 do
			-- Chevron lights
			if(i == 7 and fail) then
				action:Add({f=self.SetWire,v={self,"Chevron",-count+1},d=0}); -- Wire
			else
				action:Add({f=self.ActivateChevron,v={self,i,true},d=0});
				action:Add({f=self.DHDSetChevron,v={self,i,0.05},d=0});
				--action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
			end
		end
	end
	if(not fail) then
		local dialaddress = "";
		for i=1,count-1 do
			if (tostring(address[i]) != nil) then
				dialaddress = dialaddress..tostring(address[i]);
			end
		end
		action:Add({f=self.WireOrigin,v={self},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Chevron",count-1},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
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
	local chevs = 7;
	local count = #self.DialledAddress
	if (inbound and IsValid(self.Target) and self.Target.IsStargate) then
		count = #self.Target.DialledAddress
	end
	chevs = 7
	if (count >= 8 and count <= 10) then
		chevs = count-1;
	end
	action:Add({f=self.WireOrigin,v={self},d=0}); -- Wire
	for i=1,7 do
		action:Add({f=self.ActivateChevron,v={self,i,true},d=0});
	end
	local dialaddress = "";
	for i=1,chevs do
		if (self.DialledAddress[i] != nil) then
			dialaddress = dialaddress..tostring(self.DialledAddress[i]);
		end
	end
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
	if (not fail) then
		action:Add({f=self.SetWire,v={self,"Chevron",chevs},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
	else
		action:Add({f=self.SetWire,v={self,"Chevron",-chevs},d=0}); -- Wire
	end
	--if (inbound or nox) then
		action:Add({f=self.FakeDelay,v={self},d=delay});
	/*else
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.OnButtonLock,90,math.random(98,103)},d=delay});
	end*/
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
		for i=1,7 do
			action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
		end
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Fail,90,math.random(130,150)},d=0});-- Fail soun
		action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	end
	action:Add({f=self.SetWire,v={self,"Chevron",-chev},d=0}); -- Wire
	return action;
end

function ENT.Sequence:OnButtonChevron(lightup, dialchev)
	local action = self:New();
	if (dialchev >= 1) then
		action:Add({f=self.SetStatus,v={self,false,false,false,true,true},d=0});
	else
		action:Add({f=self.SetStatus,v={self,false,false,false,false},d=0});
	end
	if dialchev > 7 then return action; end
	if lightup then
		action:Add({f=self.ActivateChevron,v={self,dialchev,true},d=0}); -- Chevron7 lights up
		--action:Add({f=self.ChevronSound,v={self,dialchev, true},d=0}); -- Chevron Locked
	else
		action:Add({f=self.ActivateChevron,v={self,dialchev+1,false},d=0}); -- Chevron7 lights up
		--action:Add({f=self.ChevronSound,v={self,dialchev, true},d=0}); -- Chevron Locked
	end
	return action;
end