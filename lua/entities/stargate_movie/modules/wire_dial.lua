/*
	Wire dialling by AlexALX (c) 2011
*/

--################# Encode chevron sequence by AlexALX
function ENT.Sequence:SeqEncodeChevron(dialchev, address)
	local action = self:New();
	local dialaddress = "";
	local dialsymbol = "";
	if (dialchev == 1) then
		action:Add({f=self.SetStatus,v={self,false,false,false,true,false},d=0});
		for i=1,9 do
			action:Add({f=self.ActivateChevron,v={self,i,false},d=0});
		end
	end
	local classicmode = false;
	local chevlight = false;
	if (dialchev == 1) then
		if (self:GetWire("Classic Mode",0) >= 1) then classicmode = true; self.ClassicMode = true; else self.ClassicMode = false; end
		if (classicmode) then self.Sounds = self.SoundsClassic; else self.Sounds = self.SoundsBak; end
		if (self:GetWire("Chevron Light",0) >= 1) then chevlight = true; self.LightMode = true; else self.LightMode = false; end
	elseif (dialchev == 0) then
		self.ClassicMode = false;
		self.LightMode = false;
	else
		classicmode = self.ClassicMode;
		chevlight = self.LightMode;
	end
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
	action:Add({f=self.SetDiallingSymbol,v={self,dialsymbol,s},d=0});
	action:Add({f=self.ChevronAnimation,v={self,s,classicmode},d=0}); -- Animate chevron
	action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire
	action:Add({f=self.DHDSetChevronWire,v={self,dialchev},d=0});
	action:Add({f=self.SetChevrons,v={self,s,1},d=0}); -- Wire
	if (classicmode) then
		action:Add({f=self.ChevronSound,v={self,s,false,false,false,true},d=1.7}); -- Chevron Locked
		action:Add({f=self.ActivateChevronLight,v={self,s,true},d=0.8}); -- Chevron lights up
	else
		if (chevlight) then
			action:Add({f=self.ChevronSound,v={self,s},d=1.7}); -- Chevron Locked
			action:Add({f=self.ActivateChevronLight,v={self,s,true},d=0.8});
		else
			action:Add({f=self.ChevronSound,v={self,s},d=2.5}); -- Chevron Locked
		end
	end
	action:Add({f=self.BlockWire,v={self,false},d=0}); -- Block wire

	return action;
end

--################# Chevron 7 lock sequence by AlexALX
function ENT.Sequence:SeqChevron7Lock(dialchev,address,fail,busy)
	local action = self:New();
	local dialaddress = "";
	local dialsymbol = "";
	local classicmode = false;
	local chevlight = false;
	if (dialchev == 1) then
		if (self:GetWire("Classic Mode",0) >= 1) then classicmode = true; self.ClassicMode = true; else self.ClassicMode = false; end
		if (classicmode) then self.Sounds = self.SoundsClassic; else self.Sounds = self.SoundsBak; end
		if (self:GetWire("Chevron Light",0) >= 1) then chevlight = true; self.LightMode = true; else self.LightMode = false; end
	elseif (dialchev == 0) then
		self.ClassicMode = false;
		self.LightMode = false;
	else
		classicmode = self.ClassicMode;
		chevlight = self.LightMode;
	end
	for i=1,dialchev do
		if (address[i] != nil) then
			dialaddress = dialaddress..tostring(address[i]);
			if (i == dialchev) then
				dialsymbol = tostring(address[i]);
			end
		end
	end
	action:Add({f=self.BlockWire,v={self,true},d=0}); -- Block wire
	action:Add({f=self.SetDiallingSymbol,v={self,dialsymbol,dialchev},d=0});
	action:Add({f=self.ActivateRing,v={self,false},d=0}); -- Stop the ring
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire
	action:Add({f=self.DHDSetChevronWire,v={self,dialchev},d=0});
	if (not fail or busy) then
		action:Add({f=self.SetChevrons,v={self,7,1},d=0}); -- Wire
		if (classicmode) then
			action:Add({f=self.ChevronAnimation,v={self,7,true},d=0}); -- Animate chevron
			if (not fail or busy) then
				action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
				action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
			end
			action:Add({f=self.ChevronSound,v={self,7,false,false,false,true},d=1.5}); -- Chevron Locked
			action:Add({f=self.ActivateChevronLight,v={self,7,true},d=0.5}); -- Chevron lights up
		else
			for c=1,dialchev do
				action:Add({f=self.ActivateChevron,v={self,c,true},d=0});
			end
			if (chevlight) then
				action:Add({f=self.ActivateChevronLight,v={self,7,true},d=0});
			end
			action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
			action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=2.0}); -- Wire
		end
		action:Add({f=self.SetWire,v={self,"Chevron",-dialchev},d=0}); -- Wire
	else
		if (classicmode) then
			action:Add({f=self.ChevronAnimation,v={self,7,true},d=0}); -- Animate chevron
			action:Add({f=self.ChevronSound,v={self,7,false,false,false,true},d=2.0}); -- Chevron Locked
		else
			for c=1,dialchev do
				action:Add({f=self.ActivateChevron,v={self,c,true},d=0});
			end
			action:Add({f=self.FakeDelay,v={self},d=1.5}); -- Wire
		end
		action:Add({f=self.SetWire,v={self,"Chevron",-dialchev},d=0}); -- Wire
	end
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire

	if (not fail) then
		action:Add({f=self.DHDSetChevronWire,v={self,dialchev+1},d=0});
	end
	return action;
end