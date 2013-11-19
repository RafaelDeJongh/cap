/*
	Wire dialling by AlexALX (c) 2011
*/

--################# Before first chevron sequence by AlexALX
function ENT.Sequence:SeqFirstActivation()
	local action = self:New();
	action:Add({f=self.BlockWire,v={self,true},d=0}); -- Block wire
	action:Add({f=self.SetStatus,v={self,false,false,false,true,false},d=0});
	action:Add({f=self.SetDialMode,v={self,false,true},d=0});
	action:Add({f=self.ActivateSymbols,v={self,true},d=0}); -- deactivate all symbols
	action:Add({f=self.ChangeSkin,v={self,1, false},d=0});
	action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Activate,90,math.random(95,100)},d=0});
	action:Add({f=self.SguRampSetSkin,v={self,false},d=1.4}); -- change the sgu ramp skin
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

	action:Add({f=self.ChevronSound,v={self,dialchev},d=0});
	action:Add({f=self.DHDSetChevronWire,v={self,dialchev},d=0});
	action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire
	action:Add({f=self.BearingSetSkin,v={self,true},d=0}); -- change the bearing skin
	action:Add({f=self.ChangeSkin,v={self,dialchev+1, false, dialsymbol},d=1}); -- change the sgu skin
	action:Add({f=self.BearingSetSkin,v={self,false},d=0}); -- change the bearing skin

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

	action:Add({f=self.DHDSetChevronWire,v={self,dialchev},d=0});
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
	action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire
	if (fail and not busy) then
		action:Add({f=self.SetWire,v={self,"Chevron",-dialchev},d=0}); -- Wire
	else
		action:Add({f=self.ChevronSound,v={self,dialchev},d=0});
		action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
		action:Add({f=self.BearingSetSkin,v={self,true},d=0}); -- change the bearing skin
		action:Add({f=self.SguRampSetSkin,v={self,true},d=0}); -- change the sgu ramp skin
		action:Add({f=self.ChangeSkin,v={self,dialchev+1, false, dialsymbol},d=2}); -- change the sgu skin
		if (fail) then
			action:Add({f=self.SetWire,v={self,"Chevron",-dialchev},d=0}); -- Wire
		else
			action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
			action:Add({f=self.DHDSetChevronWire,v={self,dialchev+1},d=0});
		end
	end
	return action;
end