/*
	Wire dialling by AlexALX (c) 2011
*/

--################# Before first chevron sequence by AlexALX
function ENT.Sequence:SeqFirstActivation()
	local action = self:New();
	action:Add({f=self.SetStatus,v={self,false,false,false,true,false},d=0});
	for i=1,9 do
		action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
	end
	action:Add({f=self.SetChevrons,v={self,0,0},d=0}); -- Wire
	return action;
end

--################# Encode chevron sequence by AlexALX
function ENT.Sequence:SeqEncodeChevron(dialchev, address)
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
	action:Add({f=self.BlockWire,v={self,true},d=0}); -- Block wire
	action:Add({f=self.ActivateRing,v={self,false},d=0}); -- Stop the ring
	local s = dialchev
	if (dialchev == 7 or dialchev == 8) then
		s = s+1;
	end
	action:Add({f=self.ChevronSound,v={self,s},d=0.4}); -- Chevron Locked
	action:Add({f=self.Chevron7Animation,v={self},d=0}); -- Animate chevron 7
	action:Add({f=self.SetChevrons,v={self,7,1},d=0}); -- Wire
	action:Add({f=self.ActivateChevron,v={self,7,true},d=1.3}); -- Chevron7 lights up
	action:Add({f=self.DHDSetChevronWire,v={self,dialchev},d=0});
	action:Add({f=self.SetChevrons,v={self,s,1},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire
	action:Add({f=self.ActivateChevron,v={self,s,true},d=0.4}); -- The new chevron is getting locked in
	action:Add({f=self.SetChevrons,v={self,7,0},d=0}); -- Wire
	action:Add({f=self.ActivateChevron,v={self,7,false},d=0.4}); -- Chevron 7 goes off
	action:Add({f=self.BlockWire,v={self,false},d=0}); -- Block wire

	return action;
end

--################# Chevron 7 lock sequence by AlexALX
function ENT.Sequence:SeqChevron7Lock(dialchev,address,fail,busy)
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
	action:Add({f=self.BlockWire,v={self,true},d=0}); -- Block wire
	action:Add({f=self.ActivateRing,v={self,false},d=0}); -- Stop the ring
	if (not fail or busy) then
		action:Add({f=self.ActivateChevron,v={self,7,true},d=0}); -- Chevron7 lights up
		action:Add({f=self.SetChevrons,v={self,7,1},d=0}); -- Wire
		if (not fail) then
			action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
			action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
		end
	end
	action:Add({f=self.Chevron7Animation,v={self,true},d=0}); -- Animate chevron 7
	if (not fail) then
		action:Add({f=self.DHDSetChevronWire,v={self,dialchev},d=0});
	end
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire
	action:Add({f=self.ChevronSound,v={self,7},d=2.0}); -- Chevron Locked
	if (fail) then
		action:Add({f=self.SetWire,v={self,"Chevron",-dialchev},d=0}); -- Wire
	end
	if (not fail) then
		action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
		action:Add({f=self.DHDSetChevronWire,v={self,dialchev+1},d=0});
	end
	return action;
end