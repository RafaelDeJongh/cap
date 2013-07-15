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

-- ATTENTION: The dialling time takes exactly 7 seconds with my gates (dialled in fast mode). When you code your own gates, make them take 7 seconds too!
-- You can check a dialling sequence's length with adding "print_r(delay)" to end of the stargate_base's ENT:RunAction() function
function ENT.Sequence:Dial(inbound,fast,fail)
	local action = self:New();
	local address = self.DialledAddress;
	if (inbound and IsValid(self.Target) and self.Target.IsStargate) then
		count = #self.Target.DialledAddress
	elseif (inbound) then
		address = {};
	end
	local dialaddress = "";
	for i=1,6 do
		if (address[i] != nil) then
			dialaddress = dialaddress..tostring(address[i]);
		end
	end
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
	--################# INBOUND AND DHD (fast) DIAL
	if(inbound or fast) then
	    local add = self:GetDelay(inbound,fast,0,"stargate_supergate");
		action:Add({f=self.GateSound,v={self},d=0}); -- Sound
		if (inbound and not fast) then
			action:Add({f=self.SetStatus,v={self,false,true,true},d=29});
			action:Add({f=self.SetStatus,v={self,false,true},d=0.1});
			action:Add({f=self.LightUps,v={self, 0.07},d=7}); -- Lights income
		end
		add = add + 0.1
		if (inbound and fast) then
			action:Add({f=self.SetStatus,v={self,false,true},d=0.1});
			action:Add({f=self.LightUps,v={self, 0.07},d=7}); -- Lights income
		end
		if (fast and not inbound) then
			action:Add({f=self.SetStatus,v={self,false,true},d=0.1});
			action:Add({f=self.LightUp,v={self, 0.07},d=7}); -- Lights Outbound
		end
	end
	if (not fast and not inbound) then
		action:Add({f=self.GateSound,v={self},d=0}); -- Sound
		action:Add({f=self.SetStatus,v={self,false,true},d=0.1});
		--action:Add({f=self.SetStatus,v={self,false,true,true},d=29});
		action:Add({f=self.LightUp,v={self, 0.48},d=36});
	end
	return action;
end
