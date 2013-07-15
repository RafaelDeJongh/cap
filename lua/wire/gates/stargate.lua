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
	outputs = {},
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
	outputs = {},
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
	outputs = {},
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
	outputs = {},
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
	outputs = {},
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
	outputs = {},
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
	outputs = {},
	output = function(gate, Ent, Galaxy, Set)
		if !IsValid(Ent) or !Ent.IsStargate then return "" elseif Set>0 then return Ent:SetGalaxy(Galaxy) end
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
	outputs = {},
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
	outputs = {},
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
	outputs = {},
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

GateActions()