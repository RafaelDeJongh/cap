--[[
	Stargate Base Code
	Copyright (C) 2011 Madman07, Llapp
	Edited by AlexALX
]]--

ENT.Sequence = {};

--###################################################
--############# Recoded by Llapp ######################
--###################################################
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
	local add = 0;
	local runs = 7;
	local rins = 6;
	if(count >= 9 and count <= 10)then
	    runs = count-1;
		rins = count-2;
	end
	if (self.WireSpin and (inbound and fast or fast)) then
		local delspin = 0.2;
        if(inbound and self.InboundSymbols!=1)then
	        delspin = 3;
		end
		action:Add({f=self.SetSpeed,v={self,false},d=delspin}); -- Roll Forward
	end
	--################# INBOUND
	if(inbound or fast) then
		local t = self.Entity.Target;
		local add = 0.0;
		if (IsValid(t)) then
			add = self:GetDelay(inbound,fast,runs,t:GetClass());
		end
		if (inbound and not fast and IsValid(t) and self:IsNewDial(t:GetClass())) then
			action:Add({f=self.SetStatus,v={self,false,true,true},d=add}); -- The first true tells, "we are in use", but the last tells wire NOT to indicate us as "Active". Otherwise, on a slow dial-in, a gate becomes "Wire-Active" even if it's not currently dialling
			action:Add({f=self.PlaySpVal,v={self,true},d=0});
			action:Add({f=self.SetStatus,v={self,false,true},d=0.1}); -- The 0.1 seconds prevents a bug where an incoming call overrides an outgoing (slow dial) and the first chevrons stays disabled (so we need definitely a shot delay!) - This additional 0.1 we take here has been removed on the chevron7-lock delay in the for loop below
			action = self.Sequence:InstantOpen(action,self:GetDelaySlow(t:GetClass()),false,true);
		else
		    action:Add({f=self.SetStatus,v={self,false,true,true},d=add}); -- The first true tells, "we are in use", but the last tells wire NOT to indicate us as "Active". Otherwise, on a slow dial-in, a gate becomes "Wire-Active" even if it's not currently dialling
			action:Add({f=self.PlaySpVal,v={self,true},d=0});
			action:Add({f=self.SetStatus,v={self,false,true},d=0.1}); -- The 0.1 seconds prevents a bug where an incoming call overrides an outgoing (slow dial) and the first chevrons stays disabled (so we need definitely a shot delay!) - This additional 0.1 we take here has been removed on the chevron7-lock delay in the for loop below
		    --SGU havn't in inbound dial chevron symbols!!
		  	action:Add({f=self.ActivateSymbols,v={self,true},d=0}); -- deactivate all symbols
		    action:Add({f=self.ChangeSkin,v={self,1,inbound},d=0}); -- change the sgu skin
			action:Add({f=self.ActivateLights,v={self,true},d=0}); -- lights on
			action:Add({f=self.BearingSetSkin,v={self,true},d=0}); -- change the bearing skin
			action:Add({f=self.SguRampSetSkin,v={self,false},d=0}); -- change the sgu ramp skin
			action:Add({f=self.SpinFailChecker,v={self,true},d=0});
			if(inbound and self.InboundSymbols>=2)then
		  		action:Add({f=self.ActivateSymbols,v={self},d=0}); -- activate all symbols
			end
			if (not inbound) then
				if (address[1] != nil) then
					action:Add({f=self.SetWire,v={self,"Dialing Symbol",tostring(address[1])},d=0}); -- Wire
				end
			end
		    action:Add({f=self.ActivateGateSound,v={self,i},d=0.8});
			local delspin = 0.2;
	        if(inbound and self.InboundSymbols!=1)then
		        delspin = 3;
			end
			if (not self.WireSpin) then
				action:Add({f=self.SetSpeed,v={self,true,false},d=delspin}); -- Roll Forward
			end
			local tims = 3.6/rins
			if(fast and (not inbound or self.InboundSymbols==1))then
				action:Add({f=self.BearingSetSkin,v={self,true,true},d=0}); -- change the bearing skin
			    for i=1,runs do
					if (address[i] != nil) then
						DialAddress = DialAddress..tostring(address[i]);
						DialSymbol = tostring(address[i]);
						if (not inbound and i < runs and address[i+1] != nil) then
							DialNextSymbol = tostring(address[i+1]);
						else
							DialNextSymbol = "";
						end
					end
					action:Add({f=self.SetWire,v={self,"Dialing Symbol",DialNextSymbol},d=0}); -- Wire
				    if(i==runs)then
					    tims = 0.4;
				    end
					if(i==runs and (not fail or busy) or i < runs)then
						action:Add({f=self.ChangeSkin,v={self,i+1,inbound,DialSymbol},d=0}); -- change the sgu skin
				        action:Add({f=self.ChevronSound,v={self,i},d=0});
	                    action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
	  					if (i==runs) then
							action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
						end
						action:Add({f=self.SetWire,v={self,"Dialing Address",DialAddress},d=0}); -- Wire
						action:Add({f=self.SetWire,v={self,"Dialed Symbol",DialSymbol},d=0}); -- Wire
	                    action:Add({f=self.DHDSetChevron,v={self,i},d=tims});
					end
				end
			end
			local deltim = 1.3;
			if(inbound and self.InboundSymbols!=1)then
		        for i=1,runs do
	    	        action:Add({f=self.DHDSetChevron,v={self,i,0.05},d=0});
	    	    end
				deltim = 2.5;
			end
			if (not self.WireSpin) then
				action:Add({f=self.StopAtStartPos,v={self,true},d=deltim+1}); -- Stop at Started Position
			else
				action:Add({f=self.FakeDelay,v={self},d=deltim+1}); -- Stop at Started Position
			end
		    if(fail)then
		        action:Add({f=self.SetWire,v={self,"Chevron",-runs},d=0}); -- Wire
		    end
	    end
	else
		--################# OUTBOUND DIALLING (slow)
		action:Add({f=self.PlaySpVal,v={true},d=0});
		action:Add({f=self.SetStatus,v={self,false,1},d=0}); -- The 1 means, it's dailling slowly and "can be dialled in" (About Dialling out) - It's special for SG1 Gate and is handled in ENT:ActivateStargate()
		local t = self.Entity.Target;
		if (not fast and IsValid(t)) then
			action:Add({f=self.PauseActions,v={t,false,true},d=0});
		end

		if (self.WireSpin and not self.WireSpinDir) then
			action:Add({f=self.SetSpeed,v={self,false},d=0.3}); -- Roll Forward
		end
		self.WireSpin = false;

		action:Add({f=self.ActivateSymbols,v={self,true},d=0}); -- deactivate all symbols
	    action:Add({f=self.ChangeSkin,v={self,1,inbound},d=0}); -- change the sgu skin
		action:Add({f=self.ActivateLights,v={self,true},d=0}); -- lights on
		action:Add({f=self.SguRampSetSkin,v={self,false},d=0}); -- change the sgu ramp skin
		action:Add({f=self.ActivateGateSound,v={self,i},d=1.4});
		action:Add({f=self.SpinFailChecker,v={self,true},d=0});

		local delay = 0;
		-- Chevron 1-9
		--local rnd = {};
		for i=1,runs do
			if (self.DialledAddress[i] != nil) then
				DialAddress = DialAddress..tostring(self.DialledAddress[i]);
				DialSymbol = tostring(self.DialledAddress[i]);
				action:Add({f=self.SetDiallingSymbol,v={self,DialSymbol},d=0});
			end
			if (i <= runs and self.DialledAddress[i] != nil) then
				action:Add({f=self.SetWire,v={self,"Dialing Symbol",self.DialledAddress[i]},d=0}); -- Wire
			else
				action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
			end
		    action:Add({f=self.FixSpin,v={self,i},d=0}); --Fix Spin on Fail
			-- Spining delay
			/*math.randomseed(os.clock()+i); -- Increases randomness
			rnd[i] = self.LockSymbol[i]*0.11998;*/
            action:Add({f=self.BearingSetSkin,v={self,false},d=0}); -- change the bearing skin
  			--action:Add({f=self.SguRampSetSkin,v={self,false},d=0}); -- change the sgu ramp skin
			local dirspin = false;
			if(i==1 or i==3 or i==5 or i==7 or i==9)then
				dirspin = true;
			end
			action:Add({f=self.SetSpeed,v={self,true,dirspin},d=0}); -- rnd[i] -- Roll Forward
			if(i<=runs)then
			    action:Add({f=self.FixSpinOnChevron,v={self,true},d=0}); --Fix Spin on Fail
			end
			--action:Add({f=self.StopRollSound,v={self},d=0});
			action:Add({f=self.PauseActions,v={self,false},d=1});
			if (i==runs) then
				local t = self.Entity.Target;
				if (not inbound and not fast and IsValid(t)) then
					action:Add({f=self.PauseActions,v={t,true,true},d=0});
				end
				action:Add({f=self.SetWire,v={self,"Dialing Symbol",""},d=0}); -- Wire
			end
			--action:Add({f=self.SetSpeed,v={self,false},d=1}); -- Pause the ring
			if(i==runs and (not fail or busy) or i < runs)then
				action:Add({f=self.ChangeSkin,v={self,i+1,inbound,DialSymbol},d=0}); -- change the sgu skin
				action:Add({f=self.BearingSetSkin,v={self,true},d=0}); -- change the bearing skin
				if (i==runs) then
					action:Add({f=self.SguRampSetSkin,v={self,true},d=0}); -- change the sgu ramp skin
				end
				action:Add({f=self.ChevronSound,v={self,i},d=0});
				action:Add({f=self.SetWire,v={self,"Chevron",i},d=0}); -- Wire
				if (i==runs) then
					action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
				end
				action:Add({f=self.SetWire,v={self,"Dialing Address",DialAddress},d=0}); -- Wire
				action:Add({f=self.SetWire,v={self,"Dialed Symbol",DialSymbol},d=0}); -- Wire
			end
			if(i<=rins)then
			    action:Add({f=self.DHDSetChevron,v={self,i},d=0.7});
			elseif(i==runs)then
			    if(not fail)then
			      	action:Add({f=self.DHDSetChevron,v={self,i},d=1});
			    else
				    if (busy) then
				    	action:Add({f=self.SetWire,v={self,"Chevron",runs},d=0}); -- Wire
				    	action:Add({f=self.DHDSetChevron,v={self,i},d=1.5});
						action:Add({f=self.SetWire,v={self,"Chevron",-runs},d=0}); -- Wire
					else
				   		action:Add({f=self.SetWire,v={self,"Chevron",-runs},d=1}); -- Wire
					end
			    end
			end
			if(i<=runs)then
			    action:Add({f=self.FixSpinOnChevron,v={self,false},d=0}); --Fix Spin on Fail
			end
		end
	end
	if(inbound and self.InboundSymbols!=1 and not fail) then
		local dialaddress = "";
		for i=1,count-1 do
			if (address[i] != nil) then
				dialaddress = dialaddress..tostring(address[i]);
			end
		end
		action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Chevron",count-1},d=0}); -- Wire
	end
	if(not fail) then
		action:Add({f=self.FloorChevron,v={self,true},d=0}); -- change the floor chevron skin
		action:Add({f=self.SguRampSetSkin,v={self,true},d=0}); -- change the sgu ramp skin
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
	action:Add({f=self.SetSpeed,v={self,false},d=0});
	action:Add({f=self.ActivateSymbols,v={self,true},d=0}); -- deactivate all symbols
	action:Add({f=self.ChangeSkin,v={self,1, inbound},d=0}); -- change the sgu skin
	action:Add({f=self.BearingSetSkin,v={self,true},d=0}); -- change the bearing skin
	action:Add({f=self.SguRampSetSkin,v={self,true},d=0}); -- change the sgu ramp skin
	action:Add({f=self.FloorChevron,v={self,true},d=0}); -- change the floor chevron skin
	if (inbound or nox) then
		if (not nox) then
			action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Activate,90,math.random(95,100)},d=0});
		end
		if(self.InboundSymbols>=2 and inbound)then
			action:Add({f=self.ActivateSymbols,v={self},d=0}); -- activate all symbols
		end
	end
	local dialaddress = "";
	for i=1,chevs do
		if (self.DialledAddress[i] != nil) then
			dialaddress = dialaddress..tostring(self.DialledAddress[i]);
		end
	end
	local dialsymbol = "";
	for i=1,chevs do
		if (self.DialledAddress[i] != nil) then
			dialsymbol = tostring(self.DialledAddress[i]);
		end
		action:Add({f=self.DHDSetChevron,v={self,i},d=0});
		action:Add({f=self.ChangeSkin,v={self,i+1, inbound, dialsymbol},d=0}); -- change the sgu skin
	end
	action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
	if (inbound) then
		action:Add({f=self.SetWire,v={self,"Inbound",1},d=0});
	end
	if (not fail) then
		action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Chevron",chevs},d=delay}); -- Wire
	else
		action:Add({f=self.SetWire,v={self,"Chevron",-chevs},d=delay}); -- Wire
	end
	return action;
end

--################# On Button Chevron Press Feature @Madman07, Edited by AlexALX

function ENT.Sequence:OnButtonDialFail(chev,only_chev_wire)
	local action = self:New();
	if (not only_chev_wire) then
		action:Add({f=self.ActivateSymbols,v={self,true},d=0}); -- deactivate all symbols
		action:Add({f=self.ChangeSkin,v={self,1},d=0}); -- change the sgu skin
		action:Add({f=self.ChangeSkin,v={self,0},d=0}); -- change the sgu skin
		action:Add({f=self.BearingSetSkin,v={self,false},d=0}); -- change the bearing skin
		action:Add({f=self.FloorChevron,v={self,false},d=0}); -- change the floor chevron skin
		action:Add({f=self.SguRampSetSkin,v={self,false,true},d=0}); -- change the sgu ramp skin
		action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Fail,90,math.random(98,103)},d=0});
		action:Add({f=self.SetWire,v={self,"Dialing Address",""},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialed Symbol",""},d=0}); -- Wire
	end
	action:Add({f=self.SetWire,v={self,"Chevron",-chev},d=0}); -- Wire
	return action;
end

function ENT.Sequence:OnButtonChevron(lightup, dialchev, address, symbol, fail, busy)
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
		action:Add({f=self.SetDialMode,v={self,false,true},d=0});
		if (self.WireSpin) then
			action:Add({f=self.StopAtStartPos,v={self},d=0}); -- Stop at Started Position
		end
	else
		action:Add({f=self.SetStatus,v={self,false,false,false,false},d=0});
		action:Add({f=self.SetDialMode,v={self,false,false},d=0});
	end
	if lightup then
		if (dialchev == 1) then
			action:Add({f=self.ActivateSymbols,v={self,true},d=0}); -- deactivate all symbols
			action:Add({f=self.ChangeSkin,v={self,1, false},d=0});
			action:Add({f=self.EmitSound,v={self.Entity,self.Sounds.Activate,90,math.random(95,100)},d=0.5});
		end
		if (not fail or busy) then
			action:Add({f=self.ChangeSkin,v={self,dialchev+1, false, dialsymbol},d=0}); -- change the sgu skin
			action:Add({f=self.BearingSetSkin,v={self,true},d=0}); -- change the bearing skin
			action:Add({f=self.SguRampSetSkin,v={self,false},d=0}); -- change the sgu ramp skin
			action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
			if (symbol=="#" or dialchev==9) then
				action:Add({f=self.SetWire,v={self,"Chevron Locked",1},d=0}); -- Wire
			end
		elseif (fail) then
			action:Add({f=self.SetWire,v={self,"Chevron",-dialchev},d=0}); -- Wire
		end
		action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire
	else
		action:Add({f=self.SetWire,v={self,"Chevron",dialchev},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialing Address",dialaddress},d=0}); -- Wire
		action:Add({f=self.SetWire,v={self,"Dialed Symbol",dialsymbol},d=0}); -- Wire
		--action:Add({f=self.ChevronSound,v={self,dialchev+1, true},d=0}); -- Chevron Locked
		action:Add({f=self.ActivateRing,v={self,false},d=0}); -- Stop the ring
		action:Add({f=self.SetWire,v={self,"Chevron Locked",0},d=0}); -- Wire
		if(dialchev > 0)then
			local i = self.SymbolsLock[tonumber(symbol) or symbol][2];
			self.Symbols[i]:SetColor(Color(40,40,40,255));
		else
			self:ChangeSkin(0, false)
			self:SguRampSetSkin(false,true); -- change the sgu ramp skin
			self:BearingSetSkin(false); -- change the bearing skin
			self:ActivateSymbols(true); -- deactivate all symbols
		end
	end
	return action;
end