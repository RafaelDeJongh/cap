/*
	###################################
	StarGate with Group System
	Created by AlexALX (c) 2011
	###################################
*/

-- For some reasons, in stargate/shared/CapCheck.lua this code not always work, hope here will work.

-- It seems like sv_tags convar removed from new gmod, and also removed field in server search with tags, so i'm disabled that for now, maybe later garry back this?
          /*
if (SERVER) then
	local fil = file.Read("addons/cap/ver.txt","GAME")
	local capver = 0
	if fil then
		capver = tonumber(fil)
	end
	-- Add server tag
	local sv_tags = GetConVarString("sv_tags")
	if sv_tags == nil then
		RunConsoleCommand("sv_tags", "StargateCAP"..capver)
	elseif not sv_tags:find("StargateCAP") then
		RunConsoleCommand("sv_tags", "StargateCAP"..capver.."," .. sv_tags)
	end
	timer.Create("CapSystemTags",3,0,function()
		local sv_tags = GetConVarString("sv_tags")
		if sv_tags == nil then
			RunConsoleCommand("sv_tags", "StargateCAP"..capver)
		elseif not sv_tags:find("StargateCAP") then
			RunConsoleCommand("sv_tags", "StargateCAP"..capver.."," .. sv_tags)
		end
	end)
end*/