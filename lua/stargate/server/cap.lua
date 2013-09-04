--[[
	A global library with  bunch of usefull
	functions often used in entities on serverside
	Copyright (C) 2011 Madman07
]]--

function StarGate.FindPlayer(pos, range)
	local ply = false;
	local dist = range;
	for _,v in pairs(player.GetAll()) do
		local p_dist = (pos - v:GetPos()):Length();
		if(dist >= p_dist) then
			dist = p_dist;
			ply = true;
		end
	end
	return ply;
end

function StarGate.FindIris(gate)
	local iris;
	if (IsValid(gate) and gate.IsStargate) then
		for _,v in pairs(ents.FindInSphere(gate:GetPos(),10)) do
			if v.IsIris then
				iris = v;
			end
		end
	end
	return iris;
end

function StarGate.PTrace(ent, p)
	local trace = util.GetPlayerTrace(p);
	local t=util.TraceLine(trace);
	Msg("Player trace for "..p:GetName().."/n");
	Msg("HitPos "..ent:WorldToLocal(t.HitPos).."/n");
	Msg("HitNormal "..t.HitNormal.."/n");
end

function StarGate.Debug(ent, msg)
	Msg("Error in "..ent:GetClass().." - "..msg.."/n");
end

function StarGate.Debug2(msg1, msg2)
	Msg(msg1.." - "..msg2.."/n");
end

function StarGate.FindGate(ent, dist)
	local gate;
	local pos = ent:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate) then
			local sg_dist = (pos - v:GetPos()):Length();
			if(dist >= sg_dist) then
				dist = sg_dist;
				gate = v;
			end
		end
	end
	return gate;
end

function StarGate.FindKino(p)
	local number = 0;
	local KinoEnt = {};
	for _,v in pairs(ents.FindByClass("kino_ball*")) do
		if (v.Owner == p) then
			table.insert(KinoEnt, v)
			number = number + 1;
		end
	end
	return number, KinoEnt;
end

function StarGate.FindShield(ent)
	local gate;
	local dist = 10000;
	local pos = ent:GetPos();
	for _,v in pairs(ents.FindByClass("shield_core")) do
		local sg_dist = (pos - v:GetPos()):Length();
		if(dist >= sg_dist) then
			dist = sg_dist;
			gate = v;
		end
	end
	return gate;
end

function StarGate.IsInShieldCore(ent, core)
	if (core.ShShap == 1) then
		return StarGate.IsInEllipsoid(ent:GetPos(), core, core.Size);
	elseif (core.ShShap == 2) then
		return StarGate.IsInCuboid(ent:GetPos(), core, core.Size);
	elseif (core.ShShap == 3) then
		return StarGate.IsInAltantisoid(ent:GetPos(), core, core.Size);
	end
end

function StarGate.GetMultipleOwner(ent) // Ugly, no validation, but works :p
	local own = ent;
	if IsValid(own) then
		if own:IsPlayer() then return own end
		if (own.Owner and own.Owner:IsPlayer()) then return own.Owner end

		own = ent:GetOwner()
		if IsValid(own) then
			if own:IsPlayer() then return own end
			if (own.Owner and own.Owner:IsPlayer()) then return own.Owner end

			own = ent:GetOwner()
			if IsValid(own) then
				if own:IsPlayer() then return own end
				if (own.Owner and own.Owner:IsPlayer()) then return own.Owner end
			end
		end
	end
end

-- From stargate group system by AlexALX
messageblock = messageblock or {};

function StarGate.ReloadSystem(groupsystem)
	if (messageblock[tostring(groupsystem)]) then return; end
	local system = "Galaxy System";
	if (groupsystem) then
		system = "Group System";
	end
	for k, v in pairs(player.GetHumans()) do
		v:SendLua("LocalPlayer():ChatPrint(SGLanguage.GetMessage(\"stargate_reload\",\""..system.."\"))");
	end
	RunConsoleCommand("stargate_reload");
	if (tostring(groupsystem)=="true") then
		messageblock["false"] = false;
	elseif (tostring(groupsystem)=="false") then
		messageblock["true"] = false;
	end
	messageblock[tostring(groupsystem)] = true;
	timer.Remove("_StarGate.ReloadSystemMessage");
	timer.Create("_StarGate.ReloadSystemMessage",5.25,1,
		function()
			messageblock[tostring(groupsystem)] = false;
			StarGate.ReloadedSystemMessage();
		end
	);
end

function StarGate.ReloadedSystemMessage()
	for k, v in pairs(player.GetHumans()) do
		v:SendLua("LocalPlayer():ChatPrint(SGLanguage.GetMessage(\"stargate_reloaded\"))");
	end
end