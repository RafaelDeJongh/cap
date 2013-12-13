/*
	Stargate wire gates lib
	Created by AlexALX (c) 2012
*/

GateActions("StarGate")

GateActions["GetAddress"] = {
	name = "Get stargate address",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "STRING" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate then return "" else return Ent:GetGateAddress() end
	end,
	label = function(Out)
		return string.format ("Address = %q", Out)
	end
}

GateActions["SetAddress"] = {
	name = "Set atargate address",
	inputs = { "Ent", "Address", "Set" },
	inputtypes = { "WIRELINK", "STRING", "NORMAL" },
	outputtypes = {},
	output = function(gate, Ent, Address, Set)
		if !IsValid(Ent) or !Ent.IsStargate then return "" elseif Set>0 then return Ent:SetGateAddress(Address) end
	end
}

GateActions["GetGroup"] = {
	name = "Get stargate group",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "STRING" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate then return "" else return Ent:GetGateGroup() end
	end,
	label = function(Out)
		return string.format ("Group = %q", Out)
	end

}

GateActions["SetGroup"] = {
	name = "Set stargate group",
	inputs = { "Ent", "Group", "Set" },
	inputtypes = { "WIRELINK", "STRING", "NORMAL" },
	outputtypes = {},
	output = function(gate, Ent, Group, Set)
		if !IsValid(Ent) or !Ent.IsStargate then return "" elseif Set>0 then return Ent:SetGateGroup(Group) end
	end
}

GateActions["GetName"] = {
	name = "Get stargate name",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "STRING" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate then return "" else return Ent:GetGateName() end
	end,
	label = function(Out)
		return string.format ("Name = %q", Out)
	end
}

GateActions["SetName"] = {
	name = "Set stargate name",
	inputs = { "Ent", "Name", "Set" },
	inputtypes = { "WIRELINK", "STRING", "NORMAL" },
	outputtypes = {},
	output = function(gate, Ent, Name, Set)
		if !IsValid(Ent) or !Ent.IsStargate then return "" elseif Set>0 then return Ent:SetGateName(Group) end
	end
}

GateActions["GetPrivate"] = {
	name = "Get stargate private",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate or !Ent:GetPrivate() then return 0 else return 1 end
	end,
	label = function(Out)
		return string.format ("Private = %q", Out)
	end
}

GateActions["SetPrivate"] = {
	name = "Set stargate private",
	inputs = { "Ent", "Private", "Set" },
	inputtypes = { "WIRELINK", "NORMAL", "NORMAL" },
	outputtypes = {},
	output = function(gate, Ent, Private, Set)
		if !IsValid(Ent) or !Ent.IsStargate then return "" elseif Set>0 then return Ent:SetPrivate(Private) end
	end
}

GateActions["GetLocale"] = {
	name = "Get stargate local",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate or !Ent:GetLocale() then return 0 else return 1 end
	end,
	label = function(Out)
		return string.format ("Locale = %q", Out)
	end
}

GateActions["SetLocale"] = {
	name = "Set stargate local",
	inputs = { "Ent", "Locale", "Set" },
	inputtypes = { "WIRELINK", "NORMAL", "NORMAL" },
	outputtypes = {},
	output = function(gate, Ent, Locale, Set)
		if !IsValid(Ent) or !Ent.IsStargate then return "" elseif Set>0 then return Ent:SetLocale(Locale) end
	end
}

GateActions["GetBlocked"] = {
	name = "Get stargate blocked",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate or !Ent:GetBlocked() then return 0 else return 1 end
	end,
	label = function(Out)
		return string.format ("Blocked = %q", Out)
	end
}

GateActions["SetBlocked"] = {
	name = "Set stargate blocked",
	inputs = { "Ent", "Blocked", "Set" },
	inputtypes = { "WIRELINK", "NORMAL", "NORMAL" },
	outputtypes = {},
	output = function(gate, Ent, Blocked, Set)
		if !IsValid(Ent) or !Ent.IsStargate then return "" elseif Set>0 then return Ent:SetBlocked(Blocked) end
	end
}

GateActions["GetGalaxy"] = {
	name = "Get stargate galaxy",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate or !Ent:GetGalaxy() then return 0 else return 1 end
	end,
	label = function(Out)
		return string.format ("Galaxy = %q", Out)
	end
}

GateActions["SetGalaxy"] = {
	name = "Set stargate galaxy",
	inputs = { "Ent", "Galaxy", "Set" },
	inputtypes = { "WIRELINK", "NORMAL", "NORMAL" },
	outputtypes = {},
	output = function(gate, Ent, Galaxy, Set)
		if !IsValid(Ent) or !Ent.IsStargate then return "" elseif Set>0 then return Ent:SetGalaxy(Galaxy) end
	end
}

GateActions["IsOverload"] = {
	name = "Get stargate overload status",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate then
			return 0
		else
			if (Ent.isOverloading) then
				return 2
			end
			if (IsValid(Ent.overloader) and Ent.overloader.isFiring) then
				return 1
			else
				return 0
			end
		end
	end,
	label = function(Out)
		return string.format ("Overload = %q", Out)
	end
}

GateActions["OverloadPerc"] = {
	name = "Get stargate overload percent status",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate then
			return 0
		else
			if (Ent.excessPower==nil or Ent.excessPowerLimit==nil) then return 0; end
			local perc = (Ent.excessPower/Ent.excessPowerLimit)*100;
			if (perc>100) then return 100; end
			return perc;
		end
	end,
	label = function(Out)
		return string.format ("Overload percent = %q", Out)
	end
}

GateActions["OverloadTime"] = {
	name = "Get stargate time to overload",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate then
			return 0
		else
			if (Ent.excessPower==nil or Ent.excessPowerLimit==nil or not IsValid(Ent.overloader)) then return -1; end
			local energyRequired = Ent.excessPowerLimit - Ent.excessPower;
			local timeLeft = (energyRequired / Ent.overloader.energyPerSecond)
			if(StarGate.IsIrisClosed(Ent)) then
				timeLeft = timeLeft * 2;
			end
			if (Ent.isOverloading) then
				return 0;
			end
			if (Ent.overloader.isFiring) then
				return math.ceil(timeLeft);
			else
				return -1
			end
			return perc;
		end
	end,
	label = function(Out)
		return string.format ("Overload time = %q", Out)
	end
}



GateActions["IsAsuranBeam"] = {
	name = "Get stargate asuran gate weapon status",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate then
			return 0
		else
			if (IsValid(Ent.asuranweapon) and Ent.asuranweapon.isFiring) then
				return 1
			else
				return 0
			end
		end
	end,
	label = function(Out)
		return string.format ("Asuran Beam = %q", Out)
	end
}

GateActions["GetEnergyFromAddress"] = {
	name = "Get energy from address",
	inputs = { "Ent", "Address", "Refresh" },
	inputtypes = { "WIRELINK", "STRING", "NORMAL" },
	outputtypes = { "NORMAL" },
	output = function(gate, Ent, Address, Refresh)
		if !IsValid(Ent) or !Ent.IsStargate then
			return 0
		elseif Refresh>0 then
			Ent.LastGetEnergy = Ent:WireGetEnergy(Address:upper():sub(1,9));
			return Ent.LastGetEnergy;
		elseif Ent.LastGetEnergy!=nil then
			return Ent.LastGetEnergy;
		else
			return 0;
		end
	end,
	label = function(Out)
		return string.format ("Energy = %q", Out)
	end
}

GateActions["GetDistanceFromAddress"] = {
	name = "Get distance from address",
	inputs = { "Ent", "Address", "Refresh" },
	inputtypes = { "WIRELINK", "STRING", "NORMAL" },
	outputtypes = { "NORMAL" },
	output = function(gate, Ent, Address, Refresh)
		if !IsValid(Ent) or !Ent.IsStargate then
			return 0
		elseif Refresh>0 then
			Ent.LastGetDistance = Ent:WireGetEnergy(Address:upper():sub(1,9),true);
			return Ent.LastGetDistance;
		elseif Ent.LastGetDistance!=nil then
			return Ent.LastGetDistance;
		else
			return 0;
		end
	end,
	label = function(Out)
		return string.format ("Distance = %q", Out)
	end
}

GateActions["AddressList"] = {
	name = "Get address list",
	inputs = { "Ent", "Refresh" },
	inputtypes = { "WIRELINK", "NORMAL" },
	outputtypes = { "ARRAY" },
	output = function(gate, Ent, Refresh)
		if !IsValid(Ent) or !Ent.IsStargate then
			return {}
		elseif Refresh>0 then
			Ent.LastGetAddresses = Ent:WireGetAddresses();
			return Ent.LastGetAddresses;
		elseif Ent.LastGetAddresses!=nil then
			return Ent.LastGetAddresses;
		else
			return {};
		end
	end,
	label = function(Out)
		return string.format("Addresses: %d",table.Count(Out));
	end
}

GateActions["GetIrisActive"] = {
	name = "Get stargate iris active",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsStargate or !Ent:IsBlocked(1,1) then return 0 else return 1 end
	end,
	label = function(Out)
		return string.format ("Iris Activated = %q", Out)
	end
}

GateActions["GetRingAddress"] = {
	name = "Get ring address",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "STRING" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsRings then return "" else return Ent.Address end
	end,
	label = function(Out)
		return string.format ("Address = %q", Out)
	end
}

GateActions["SetRingAddress"] = {
	name = "Set ring address",
	inputs = { "Ent", "Address", "Set" },
	inputtypes = { "WIRELINK", "STRING", "NORMAL" },
	outputtypes = {},
	output = function(gate, Ent, Address, Set)
		if !IsValid(Ent) or !Ent.IsRings then return "" elseif Set>0 then return Ent:SetRingAddress(Address) end
	end
}

GateActions["SystemType"] = {
	name = "Get stargate system type",
	inputs = { },
	timed = true,
	output = function(gate)
		local ret = GetConVar("stargate_group_system"):GetBool()
		if (ret) then
			return 1
		else
			return 0
		end
	end,
	label = function(Out)
		if (Out==1) then
			return "Group System";
		else
			return "Galaxy System";
		end
	end
}

GateActions["GetAtlantisTPName"] = {
	name = "Get atlantis transporter name",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "STRING" },
	timed = true,
	output = function(gate, Ent, Name, Set)
		if !IsValid(Ent) or !Ent.IsAtlTP then return "" else return Ent.TName end
	end,
	label = function(Out)
		return string.format ("Name = %q", Out)
	end
}

GateActions["SetAtlantisTPName"] = {
	name = "Set atlantis transporter name",
	inputs = { "Ent", "Name", "Set" },
	inputtypes = { "WIRELINK", "STRING", "NORMAL" },
	outputtypes = {},
	output = function(gate, Ent, Name, Set)
		if !IsValid(Ent) or !Ent.IsAtlTP then return "" elseif Set>0 then return Ent:SetAtlName(Name,true) end
	end
}

GateActions["GetAtlantisTPPrivate"] = {
	name = "Get atlantis transporter private",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if !IsValid(Ent) or !Ent.IsAtlTP or !Ent.TPrivate then return 0 else return 1 end
	end,
	label = function(Out)
		return string.format ("Private = %q", Out)
	end
}

GateActions["SetAtlantisTPPrivate"] = {
	name = "Set atlantis transporter private",
	inputs = { "Ent", "Private", "Set" },
	inputtypes = { "WIRELINK", "NORMAL", "NORMAL" },
	outputtypes = {},
	output = function(gate, Ent, Name, Set)
		if !IsValid(Ent) or !Ent.IsAtlTP then return "" elseif Set>0 then return Ent:SetAtlPrivate(Private) end
	end
}

GateActions["GetAtlantisTPList"] = {
	name = "Get atlantis transporter address list",
	inputs = { "Ent", "Refresh" },
	inputtypes = { "WIRELINK", "NORMAL" },
	outputtypes = { "ARRAY" },
	output = function(gate, Ent, Refresh)
		if !IsValid(Ent) or !Ent.IsAtlTP then
			return {}
		elseif Refresh>0 then
			Ent.LastGetAddresses = Ent:WireGetAddresses();
			return Ent.LastGetAddresses;
		elseif Ent.LastGetAddresses!=nil then
			return Ent.LastGetAddresses;
		else
			return {};
		end
	end,
	label = function(Out)
		return string.format("Addresses: %d",table.Count(Out));
	end
}

GateActions["GetUnstable"] = {
	name = "Get stargate unstable status",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if IsValid(Ent) and Ent.IsStargate and IsValid(Ent.EventHorizon) and Ent.EventHorizon.Unstable then
			return 1
		else
			return 0
		end
	end,
	label = function(Out)
		return string.format ("Unstable = %q", Out)
	end
}

GateActions["GetRingAngle"] = {
	name = "Get stargate ring angle",
	inputs = { "Ent" },
	inputtypes = { "WIRELINK" },
	outputtypes = { "NORMAL" },
	timed = true,
	output = function(gate, Ent)
		if not IsValid(Ent) or not Ent.IsStargate then return -1 end
		local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_universe"};
		local class = Ent:GetClass();
		if (not table.HasValue(vg,class)) then return -1 end
		if (class=="stargate_universe") then
			if (IsValid(Ent.Gate)) then
				local angle = tonumber(math.NormalizeAngle(Ent.Gate:GetLocalAngles().r));
				if (angle<0) then angle = angle+360; end;
				return angle;
			end
			return -1;
		else
			if (IsValid(Ent.Ring)) then
				local angle = tonumber(math.NormalizeAngle(Ent.Ring:GetLocalAngles().r));
				if (angle<0) then angle = angle+360; end;
				return angle;
			end
			return -1;
		end
	end,
	label = function(Out)
		return string.format ("Ring Angle = %q", Out)
	end
}

GateActions()