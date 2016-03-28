/*
  Stargate Expression2 Lib
  Created by AlexALX (c) 2012
*/
if (E2Lib==nil) then return end
E2Lib.RegisterExtension("stargate", true)

if EGP and EGP.ValidFonts then
	table.insert(EGP.ValidFonts,"Stargate Address Glyphs SG1");
	table.insert(EGP.ValidFonts,"Stargate Address Glyphs Concept");
	table.insert(EGP.ValidFonts,"Stargate Address Glyphs U");
	table.insert(EGP.ValidFonts,"Stargate Address Glyphs Atl");
	table.insert(EGP.ValidFonts,"Anquietas");
	table.insert(EGP.ValidFonts,"Quiver");
end

-- Stupid lua table to e2 table convertation due to wiremod "fix" @ AlexALX
local LuaTablesToArrayOfTables = function ( tbl )
	local Array, n, ntypes, size = {}, {}, {}, 0
	for _,data in pairs(tbl) do
		// This code works fine, but use array in table shorter and faster
		/*local n2, ntypes2, size2 = {}, {}, 1
		for _,v in pairs(data) do
			local Type
			if isstring(v) then
				Type = "s"
			elseif isbool(v) then
				Type = "b"
			elseif isnumber(v) then
				Type = "n"
			elseif isvector(v) then
				Type = "v"
			elseif isangle(v) then
				Type = "a"
			elseif isentity(v) then
				Type = "e"
			end
	 
			if Type then 
				n2[size2] = v
				ntypes2[size2] = Type
				size2 = size2+1
			end
		end*/
		     
		// only string indexes works with foreach in e2, but then order of array lost :( so old code is not compatible, sorry, blame wiremod devs
		n[size] = data //{n=n2,ntypes=ntypes2,s={},stypes={},size=size2}
		ntypes[size] = "r"
		size = size+1
	end	
	Array = {n=n,ntypes=ntypes,s={},stypes={},size=size}
	return Array
end

__e2setcost( 1 )

e2function string entity:stargateAddress()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return "" end
	return this:GetGateAddress() or ""
end

e2function string wirelink:stargateAddress()
	if not IsValid(this) or not this.IsStargate then return "" end
	return this:GetGateAddress() or ""
end

__e2setcost( 5 )

e2function void entity:stargateSetAddress(string address)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetGateAddress(address)
end

e2function void wirelink:stargateSetAddress(string address)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) then return end
	this:SetGateAddress(address)
end

__e2setcost( 1 )

e2function string entity:stargateGroup()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return "" end
	return this:GetGateGroup() or ""
end

e2function string wirelink:stargateGroup()
	if not IsValid(this) or not this.IsStargate then return "" end
	return this:GetGateGroup() or ""
end

__e2setcost( 5 )

e2function void entity:stargateSetGroup(string group)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetGateGroup(group)
end

e2function void wirelink:stargateSetGroup(string group)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) then return end
	this:SetGateGroup(group)
end

__e2setcost( 1 )

e2function string entity:stargateName()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return "" end
	return this:GetGateName() or ""
end

e2function string wirelink:stargateName()
	if not IsValid(this) or not this.IsStargate then return "" end
	return this:GetGateName() or ""
end

e2function void entity:stargateSetName(string name)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetGateName(name)
end

e2function void wirelink:stargateSetName(string name)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) then return end
	this:SetGateName(name)
end

e2function number entity:stargatePrivate()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local ret = this:GetPrivate()
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargatePrivate()
	if not IsValid(this) or not this.IsStargate then return -1 end
	local ret = this:GetPrivate()
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function void entity:stargateSetPrivate(number bool)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetPrivate(bool)
end

e2function void wirelink:stargateSetPrivate(number bool)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) then return end
	this:SetPrivate(bool)
end

e2function number entity:stargateLocal()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local ret = this:GetLocale()
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargateLocal()
	if not IsValid(this) or not this.IsStargate then return -1 end
	local ret = this:GetLocale()
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function void entity:stargateSetLocal(number bool)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetLocale(bool)
end

e2function void wirelink:stargateSetLocal(number bool)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) then return end
	this:SetLocale(bool)
end

e2function number entity:stargateBlocked()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local ret = this:GetBlocked()
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargateBlocked()
	if not IsValid(this) or not this.IsStargate then return -1 end
	local ret = this:GetBlocked()
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function void entity:stargateSetBlocked(number bool)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetBlocked(bool)
end

e2function void wirelink:stargateSetBlocked(number bool)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) then return end
	this:SetBlocked(bool)
end

e2function number entity:stargateGalaxy()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local ret = this:GetGalaxy()
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargateGalaxy()
	if not IsValid(this) or not this.IsStargate then return -1 end
	local ret = this:GetGalaxy()
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function void entity:stargateSetGalaxy(number bool)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetGalaxy(bool)
end

e2function void wirelink:stargateSetGalaxy(number bool)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) then return end
	this:SetGalaxy(bool)
end

/* I think this function is like exploit - we can openiris from target gate for example... So i disable it.
e2function entity entity:stargateTarget()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return nil end
	if (IsValid(this.Target) and (not this.Target:GetPrivate() or isOwner(self.Target,this) or self.player:IsAdmin())) then
		return this.Target
	else
		return nil
	end
end

e2function entity wirelink:stargateTarget()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return nil end
	if (IsValid(this.Target) and (not this.Target:GetPrivate() or isOwner(self.Target,this) or self.player:IsAdmin())) then
		return this.Target
	else
		return nil
	end
end */

e2function number entity:stargateOpen()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local ret = this.IsOpen
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargateOpen()
	if not IsValid(this) or not this.IsStargate then return -1 end
	local ret = this.IsOpen
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function number entity:stargateInbound()
 	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local ret = !this.Outbound and this.Active
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargateInbound()
 	if not IsValid(this) or not this.IsStargate then return -1 end
	local ret = !this.Outbound and this.Active
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function number entity:stargateActive()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local ret = this.NewActive
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargateActive()
	if not IsValid(this) or not this.IsStargate then return -1 end
	local ret = this.NewActive
	if (ret) then
		return 1
	else
		return 0
	end
end

__e2setcost( 5 )

e2function number entity:stargateUnstable()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	if IsValid(this.EventHorizon) and this.EventHorizon.Unstable then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargateUnstable()
	if not IsValid(this) or not this.IsStargate then return -1 end
	if IsValid(this.EventHorizon) and this.EventHorizon.Unstable then
		return 1
	else
		return 0
	end
end

__e2setcost( 30 )

e2function number entity:stargateGetRingAngle()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_universe"};
	local class = this:GetClass();
	if (not table.HasValue(vg,class)) then return -1 end
	if (class=="stargate_universe") then
		if (IsValid(this.Gate)) then
			local angle = tonumber(math.NormalizeAngle(this.Gate:GetLocalAngles().r));
			if (angle<0) then angle = angle+360; end;
			return angle;
		end
		return -1;
	else
		if (IsValid(this.Ring)) then
			local angle = tonumber(math.NormalizeAngle(this.Ring:GetLocalAngles().r));
			if (angle<0) then angle = angle+360; end;
			return angle;
		end
		return -1;
	end
end

e2function number wirelink:stargateGetRingAngle()
	if not IsValid(this) or not this.IsStargate then return -1 end
	local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_universe"};
	local class = this:GetClass();
	if (not table.HasValue(vg,class)) then return -1 end
	if (class=="stargate_universe") then
		if (IsValid(this.Gate)) then
			local angle = tonumber(math.NormalizeAngle(this.Gate:GetLocalAngles().r));
			if (angle<0) then angle = angle+360; end;
			return angle;
		end
		return -1;
	else
		if (IsValid(this.Ring)) then
			local angle = tonumber(math.NormalizeAngle(this.Ring:GetLocalAngles().r));
			if (angle<0) then angle = angle+360; end;
			return angle;
		end
		return -1;
	end
end

-- Not sure, but probably this functions is shit... also workaround for gatespawner
-- or maybe this will start new era for e2 coders not sure...

__e2setcost( 5 )

e2function number wirelink:stargateGetWire(string name)
	if not IsValid(this) or not this.GetWire or not this.CreateWireInputs then return -1 end
	local ret = this:GetWire(name,-1,true);
	if (type(ret)=="number") then
		return ret;
	end
	return -1;
end

e2function string wirelink:stargateGetWireString(string name)
	if not IsValid(this) or not this.GetWire or not this.CreateWireInputs then return "" end
	local ret = this:GetWire(name,"",true);
	if (type(ret)=="string") then
		return ret;
	end
	return "";
end

e2function vector wirelink:stargateGetWireVector(string name)
	if not IsValid(this) or not this.GetWire or not this.CreateWireInputs then return {0,0,0} end
	local ret = this:GetWire(name,"",true);
	if (type(ret)=="Vector") then
		return {ret.x,ret.y,ret.z};
	end
	return {0,0,0};
end

e2function vector wirelink:stargateGetWireEntity(string name)
	if not IsValid(this) or not this.GetWire or not this.CreateWireInputs then return NULL end
	local ret = this:GetWire(name,NULL,true);
	if (IsValid(ret)) then
		return ret;
	end
	return NULL;
end

e2function number wirelink:stargateGetWireInput(string name)
	if not IsValid(this) or not this.GetWire or not this.CreateWireInputs then return -1 end
	local ret = this:GetWire(name,-1);
	if (type(ret)=="number") then
		return ret;
	end
	return -1;
end

e2function string wirelink:stargateGetWireStringInput(string name)
	if not IsValid(this) or not this.GetWire or not this.CreateWireInputs then return "" end
	local ret = this:GetWire(name,"");
	if (type(ret)=="string") then
		return ret;
	end
	return "";
end

e2function vector wirelink:stargateGetWireVectorInput(string name)
	if not IsValid(this) or not this.GetWire or not this.CreateWireInputs then return {0,0,0} end
	local ret = this:GetWire(name,"");
	if (type(ret)=="Vector") then
		return {ret.x,ret.y,ret.z};
	end
	return {0,0,0};
end

e2function vector wirelink:stargateGetWireEntityInput(string name)
	if not IsValid(this) or not this.GetWire or not this.CreateWireInputs then return NULL end
	local ret = this:GetWire(name,NULL);
	if (IsValid(ret)) then
		return ret;
	end
	return NULL;
end

e2function void wirelink:stargateSetWire(string name, number value)
	if not IsValid(this) or not this.SetWire or not this.CreateWireInputs then return end
	this:SetWire(name,value,true);
end

e2function void wirelink:stargateSetWire(string name, string value)
	if not IsValid(this) or not this.SetWire or not this.CreateWireInputs then return end
	this:SetWire(name,value,true);
end

e2function void wirelink:stargateSetWire(string name, vector value)
	if not IsValid(this) or not this.SetWire or not this.CreateWireInputs then return end
	this:SetWire(name,Vector(value[1],value[2],value[3]),true);
end

e2function void wirelink:stargateSetWire(string name, entity value)
	if not IsValid(this) or not this.SetWire or not this.CreateWireInputs then return end
	this:SetWire(name,value,true);
end

-- end

__e2setcost( 5 )

e2function number entity:stargateOverload()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	if (this.isOverloading) then
		return 2
	end
	if (IsValid(this.overloader) and this.overloader.isFiring) then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargateOverload()
	if not IsValid(this) or not this.IsStargate then return -1 end
	if (this.isOverloading) then
		return 2
	end
	if (IsValid(this.overloader) and this.overloader.isFiring) then
		return 1
	else
		return 0
	end
end

__e2setcost( 10 )

e2function number entity:stargateOverloadPerc()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	if (this.excessPower==nil or this.excessPowerLimit==nil) then return 0; end
	local perc = (this.excessPower/this.excessPowerLimit)*100;
	if (perc>100) then return 100; end
	return perc;
end

e2function number wirelink:stargateOverloadPerc()
	if not IsValid(this) or not this.IsStargate then return -1 end
	if (this.excessPower==nil or this.excessPowerLimit==nil) then return 0; end
	local perc = (this.excessPower/this.excessPowerLimit)*100;
	if (perc>100) then return 100; end
	return perc;
end

__e2setcost( 20 )

e2function number entity:stargateOverloadTime()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	if (this.excessPower==nil or this.excessPowerLimit==nil or not IsValid(this.overloader)) then return -1; end
	local energyRequired = this.excessPowerLimit - this.excessPower;
	local timeLeft = (energyRequired / this.overloader.energyPerSecond)
	if(StarGate.IsIrisClosed(this)) then
		timeLeft = timeLeft * 2;
	end
	if (this.isOverloading) then
		return 0;
	end
	if (this.overloader.isFiring) then
		return math.ceil(timeLeft);
	else
		return -1
	end
	return perc;
end

e2function number wirelink:stargateOverloadTime()
	if not IsValid(this) or not this.IsStargate then return -1 end
	if (this.excessPower==nil or this.excessPowerLimit==nil or not IsValid(this.overloader)) then return -1; end
	local energyRequired = this.excessPowerLimit - this.excessPower;
	local timeLeft = (energyRequired / this.overloader.energyPerSecond)
	if(StarGate.IsIrisClosed(this)) then
		timeLeft = timeLeft * 2;
	end
	if (this.isOverloading) then
		return 0;
	end
	if (this.overloader.isFiring) then
		return math.ceil(timeLeft);
	else
		return -1
	end
	return perc;
end

__e2setcost( 10 )

e2function number entity:stargateAsuranBeam()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	if (IsValid(this.asuranweapon) and this.asuranweapon.isFiring) then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargateAsuranBeam()
	if not IsValid(this) or not this.IsStargate then return -1 end
	if (IsValid(this.asuranweapon) and this.asuranweapon.isFiring) then
		return 1
	else
		return 0
	end
end

__e2setcost( 5 )

e2function void entity:stargateDial(string address)
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:DialGate(string.upper(address))
end

e2function void wirelink:stargateDial(string address)
	if not IsValid(this) or not this.IsStargate then return end
	this:DialGate(string.upper(address))
end

e2function void entity:stargateDial(string address, number mode)
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	if (mode>=2) then
		this:NoxDialGate(string.upper(address))
	else
		this:DialGate(string.upper(address),util.tobool(mode))
	end
end

e2function void wirelink:stargateDial(string address, number mode)
	if not IsValid(this) or not this.IsStargate then return end
	if (mode>=2) then
		this:NoxDialGate(string.upper(address))
	else
		this:DialGate(string.upper(address),util.tobool(mode))
	end
end

e2function void entity:stargateClose()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:AbortDialling()
end

e2function void wirelink:stargateClose()
	if not IsValid(this) or not this.IsStargate then return end
	this:AbortDialling()
end

e2function number entity:stargateIrisActive()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local ret = this:IsBlocked(1,1)
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function number wirelink:stargateIrisActive()
	if not IsValid(this) or not this.IsStargate then return -1 end
	local ret = this:IsBlocked(1,1)
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function void entity:stargateIrisToggle()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:IrisToggle();
end

e2function void wirelink:stargateIrisToggle()
	if not IsValid(this) or not this.IsStargate then return end
	this:IrisToggle();
end

e2function void entity:stargateDHDPressButton(string char)
	if not IsValid(this) or not this.IsDHD or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:TriggerInput("Press Button",char:byte())
end

e2function void wirelink:stargateDHDPressButton(string char)
	if not IsValid(this) or not this.IsDHD then return end
	this:TriggerInput("Press Button",char:byte())
end

__e2setcost( 50 )

e2function number wirelink:stargateGetEnergyFromAddress(string address)
	if not IsValid(this) or not this.IsStargate then return -2 end
	return this:WireGetEnergy(address:upper():sub(1,9));
end

e2function number entity:stargateGetEnergyFromAddress(string address)
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -2 end
	return this:WireGetEnergy(address:upper():sub(1,9));
end

e2function number wirelink:stargateGetDistanceFromAddress(string address)
	if not IsValid(this) or not this.IsStargate then return -2 end
	return this:WireGetEnergy(address:upper():sub(1,9),true);
end

e2function number entity:stargateGetDistanceFromAddress(string address)
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -2 end
	return this:WireGetEnergy(address:upper():sub(1,9),true);
end

e2function table wirelink:stargateAddressList()
	if not IsValid(this) or not this.IsStargate then return LuaTablesToArrayOfTables({}) end
	return LuaTablesToArrayOfTables(this:WireGetAddresses());
end

e2function table entity:stargateAddressList()
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return LuaTablesToArrayOfTables({}) end
	return LuaTablesToArrayOfTables(this:WireGetAddresses());
end

e2function void wirelink:stargateRandomAddress(number mode)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) or not StarGate or not StarGate.RandomGateName then return end
	StarGate.RandomGateName(nil,this,nil,true,mode);
end

e2function void entity:stargateRandomAddress(number mode)
	if not IsValid(this) or not this.IsStargate or not this:CAP_CanModify(self.player) or not StarGate or not StarGate.RandomGateName or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	StarGate.RandomGateName(nil,this,nil,true,mode);
end

e2function number entity:stargateTransferEnergy(number value)
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	return this:TransferResource("energy",value);
end

e2function number wirelink:stargateTransferEnergy(number value)
	if not IsValid(this) or not this.IsStargate then return -1 end
	return this:TransferResource("energy",value);
end

e2function number entity:stargateTransferResource(string resname, number value)
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	return this:TransferResource(resname,value);
end

e2function number wirelink:stargateTransferResource(string resname, number value)
	if not IsValid(this) or not this.IsStargate then return -1 end
	return this:TransferResource(resname,value);
end

__e2setcost( 1 )

e2function number stargateSystemType()
	local ret = GetConVar("stargate_group_system"):GetBool()
	if (ret) then
		return 1
	else
		return 0
	end
end

__e2setcost( 50 )

e2function number stargateIsInJamming(vector from)
	local radius = 1024; -- max range of jamming, we will adjust it later
	local jaiming_online = 0;
	for _,v in pairs(ents.FindInSphere(from,  radius)) do
		if IsValid(v) and v.CapJammingDevice then
			if v.IsEnabled then
				local dist = from:Distance(v:GetPos());
				if (dist < v.Size) then  -- ow jaiming, we cant do anything
					jaiming_online = 1
				end
			end
		end
	end
	return jaiming_online;
end

e2function number stargateIsInJamming(vector from, entity player)
	if (not IsValid(player) or not player:IsPlayer()) then return -1 end
	local radius = 1024; -- max range of jamming, we will adjust it later
	local jaiming_online = 0;
	for _,v in pairs(ents.FindInSphere(from,  radius)) do
		if IsValid(v) and v.CapJammingDevice then
			if v.IsEnabled then
				local dist = from:Distance(v:GetPos());
				if (dist < v.Size) then  -- ow jaiming, we cant do anything
					if not (v.Immunity and v.Owner == player) then jaiming_online = 1 end
				end
			end
		end
	end
	return jaiming_online;
end

__e2setcost( 1 )

e2function string wirelink:stargateTransmit(string value)
	if not IsValid(this) or not this.IsStargate then return end
	return this:TriggerInput("Transmit",value);
end

e2function number entity:stargateTransmit(number value)
	if not IsValid(this) or not this.IsStargate or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	return this:TriggerInput("Transmit",value);
end

e2function string entity:stargateRingAddress()
	if not IsValid(this) or not this.IsRings or not(isOwner(self,this) or self.player:IsAdmin()) then return "" end
	return this.Address or "";
end

e2function string wirelink:stargateRingAddress()
	if not IsValid(this) or not this.IsRings then return "" end
	return this.Address or "";
end

e2function void entity:stargateRingSetAddress(string address)
	if not IsValid(this) or not this.IsRings or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetRingAddress(address);
end

e2function void wirelink:stargateRingSetAddress(string address)
	if not IsValid(this) or not this.IsRings or not this:CAP_CanModify(self.player) then return end
	this:SetRingAddress(address);
end

__e2setcost( 5 )

e2function void entity:stargateRingDial(string address)
	if not IsValid(this) or not this.IsRings or this.Busy or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	local adr = address:gsub("[^0-9]","");
	if (adr!="") then
		this:Dial(address);
	else
		this:Dial(" "); -- fail
	end
end

e2function void entity:stargateRingDialClosest()
	if not IsValid(this) or not this.IsRings or this.Busy or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:Dial("");
end

e2function void wirelink:stargateRingDial(string address)
	if not IsValid(this) or not this.IsRings or this.Busy then return end
	local adr = address:gsub("[^0-9]","");
	if (adr!="") then
		this:Dial(address);
	else
		this:Dial(" "); -- fail
	end
end

e2function void wirelink:stargateRingDialClosest()
	if not IsValid(this) or not this.IsRings or this.Busy then return end
	this:Dial("");
end

e2function void entity:stargateAsgardTeleport(vector origin, vector dest, number all)
	if not IsValid(this) or this:GetClass() != "transporter" or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this.TeleportEverything = util.tobool(all);
	this:Teleport(Vector(origin[1],origin[2],origin[3]), Vector(dest[1],dest[2],dest[3]));
end

e2function void wirelink:stargateAsgardTeleport(vector origin, vector dest, number all)
	if not IsValid(this) or this:GetClass() != "transporter" then return end
	this.TeleportEverything = util.tobool(all);
	this:Teleport(Vector(origin[1],origin[2],origin[3]), Vector(dest[1],dest[2],dest[3]));
end

__e2setcost( 1 )

e2function string wirelink:stargateAtlantisTPGetName()
	if not IsValid(this) or not this.IsAtlTP then return "" end
	return this.TName or "";
end

e2function void wirelink:stargateAtlantisTPSetName(string name)
	if not IsValid(this) or not this.IsAtlTP or not this:CAP_CanModify(self.player) then return end
	this:SetAtlName(name);
end

e2function string wirelink:stargateAtlantisTPGetGroup()
	if not IsValid(this) or not this.IsAtlTP then return "" end
	return this.TGroup or "";
end

e2function void wirelink:stargateAtlantisTPSetGroup(string group)
	if not IsValid(this) or not this.IsAtlTP or not this:CAP_CanModify(self.player) then return end
	this:SetAtlGrp(group);
end

e2function number wirelink:stargateAtlantisTPGetPrivate()
	if not IsValid(this) or not this.IsAtlTP then return -1 end
	local ret = this.TPrivate;
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function void wirelink:stargateAtlantisTPSetPrivate(number bool)
	if not IsValid(this) or not this.IsAtlTP or not this:CAP_CanModify(self.player) then return end
	this:SetAtlPrivate(bool);
end

e2function number wirelink:stargateAtlantisTPGetLocal()
	if not IsValid(this) or not this.IsAtlTP then return -1 end
	local ret = this.TLocal;
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function void wirelink:stargateAtlantisTPSetLocal(number bool)
	if not IsValid(this) or not this.IsAtlTP or not this:CAP_CanModify(self.player) then return end
	this:SetAtlLocal(bool);
end


__e2setcost( 5 )

e2function void wirelink:stargateAtlantisTPTeleport(string name)
	if not IsValid(this) or not this.IsAtlTP then return end
	this.Destination = name;
	this:Teleport();
end

__e2setcost( 10 )

e2function table wirelink:stargateAtlantisTPAddressList()
	if not IsValid(this) or not this.IsAtlTP then return LuaTablesToArrayOfTables({}) end
	return LuaTablesToArrayOfTables(this:WireGetAddresses());
end

__e2setcost( 1 )

e2function string entity:stargateAtlantisTPGetName()
	if not IsValid(this) or not this.IsAtlTP or not(isOwner(self,this) or self.player:IsAdmin()) then return "" end
	return this.TName or "";
end

e2function void entity:stargateAtlantisTPSetName(string name)
	if not IsValid(this) or not this.IsAtlTP or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetAtlName(name);
end

e2function string entity:stargateAtlantisTPGetGroup()
	if not IsValid(this) or not this.IsAtlTP or not(isOwner(self,this) or self.player:IsAdmin()) then return "" end
	return this.TGroup or ""; 
end

e2function void entity:stargateAtlantisTPSetGroup(string group)
	if not IsValid(this) or not this.IsAtlTP or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetAtlGrp(group);
end

e2function number entity:stargateAtlantisTPGetPrivate()
	if not IsValid(this) or not this.IsAtlTP or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local ret = this.TPrivate;
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function void entity:stargateAtlantisTPSetPrivate(number bool)
	if not IsValid(this) or not this.IsAtlTP or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetAtlPrivate(bool);
end

e2function number entity:stargateAtlantisTPGetLocal()
	if not IsValid(this) or not this.IsAtlTP or not(isOwner(self,this) or self.player:IsAdmin()) then return -1 end
	local ret = this.TLocal;
	if (ret) then
		return 1
	else
		return 0
	end
end

e2function void entity:stargateAtlantisTPSetLocal(number bool)
	if not IsValid(this) or not this.IsAtlTP or not this:CAP_CanModify(self.player) or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this:SetAtlLocal(bool);
end

__e2setcost( 5 )

e2function void entity:stargateAtlantisTPTeleport(string name)
	if not IsValid(this) or not this.IsAtlTP or not(isOwner(self,this) or self.player:IsAdmin()) then return end
	this.Destination = name;
	this:Teleport();
end

__e2setcost( 10 )

e2function table entity:stargateAtlantisTPAddressList()
	if not IsValid(this) or not this.IsAtlTP or not(isOwner(self,this) or self.player:IsAdmin()) then return LuaTablesToArrayOfTables({}) end
	return LuaTablesToArrayOfTables(this:WireGetAddresses());
end

__e2setcost( nil )