/*
	Stargate Lib for GarrysMod10
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
--################# DEFINES #################
StarGate.Hook = StarGate.Hook or {};
-- CreateConVar("gmod_stargate_version",StarGate.CURRENT_VERSION); -- Which version?

/* Workshop part code
local ws_addons = {}
for _,v in pairs(engine.GetAddons()) do
	if (v.mounted) then table.insert(ws_addons, v.title); end
end
local addonlist = {}
for _,v in pairs(GetAddonList(true)) do
	for k,c in pairs(GetAddonInfo(v)) do
		if (k == "Name") then
			table.insert(addonlist, c);
		end
	end
end
local types = {
	code = "StarGate CAP - Base Code",
	base = "StarGate CAP - Base Content",
}
function StarGate.CheckModule(type)
	if (types[type] and table.HasValue(ws_addons,types[type]) or table.HasValue(addonlist,"Carter Addon Pack - Resources")) then return true end
	return false;
end
*/

function StarGate.CheckModule(type)
	return true;
end

--################# Init @aVoN
function StarGate.Init()
	-- Resource Distribution Installed?
	if((CLIENT and file.Exists("stargate/client/energy.lua","LUA") or SERVER and StarGate.CheckModule("energy")) and (Environments or #file.Find("weapons/gmod_tool/environments_tool_base.lua","LUA") == 1 or Dev_Link or rd3_dev_link or #file.Find("weapons/gmod_tool/stools/dev_link.lua","LUA") == 1 or #file.Find("weapons/gmod_tool/stools/rd3_dev_link.lua","LUA") == 1)) then //Thanks to mercess2911: http://www.facepunch.com/showpost.php?p=15508150&postcount=10070
		StarGate.HasResourceDistribution = true;
	else
		StarGate.HasResourceDistribution = false;
	end
	-- Wire?
	if(WireAddon or #file.Find("weapons/gmod_tool/stools/wire.lua","LUA") == 1) then
		StarGate.HasWire = true;
		if (file.IsDir("expression2","DATA") and not file.IsDir("expression2/cap_shared","DATA")) then
			file.CreateDir("expression2/cap_shared");
		end
	else
		StarGate.HasWire = false;
	end
end
StarGate.Init(); -- Call the Init

-- Add some usefull sounds to Wire Soundemitter
local snd = {
	["SGC Alarm"] = "SGC_alarm.wav",
	["SGC Offworld Alarm"] = "SGC_offworld-alarm.wav",
	["SGA Offworld Alarm"] = "SGA_offworld-alarm.wav",
	["SGA Selfdestruct Alarm"] = "SGA_selfdestruct-alarm.wav",
	["Midway Offworld Alarm"] = "SGA_midway_alarm.wav",
	["Midway Selfdestruct Alarm"] = "SGA_midway_selfdestruct.wav",
	["Walter: Chevron 1 encoded"] = "stargate/walter/c1.mp3",
	["Walter: Chevron 2 encoded"] = "stargate/walter/c2.mp3",
	["Walter: Chevron 3 encoded"] = "stargate/walter/c3.mp3",
	["Walter: Chevron 4 encoded"] = "stargate/walter/c4.mp3",
	["Walter: Chevron 5 encoded"] = "stargate/walter/c5.mp3",
	["Walter: Chevron 6 encoded"] = "stargate/walter/c6.mp3",
	["Walter: Chevron 7 encoded"] = "stargate/walter/c7.mp3",
	["Walter: Chevron 7 locked"] = "stargate/walter/c7_locked.mp3",
	["Walter: Chevron 7 failed"] = "stargate/walter/c7_failed.mp3",
	["Walter: Chevron 8 locked"] = "stargate/walter/c8_locked.mp3",
	["Walter: Unscheduled Offworld Activation"] = "stargate/walter/unscheduled_offworld_activation.mp3",
	["Ring Transporter Button 1"] = "tech/ring_button1.mp3",
	["Ring Transporter Button 2"] = "tech/ring_button2.mp3",
}
for k,v in pairs(snd) do
	list.Set("WireSounds",k,{wire_soundemitter_sound=v});
end

if SERVER then

	local meta = FindMetaTable("Player");
	if(meta and not meta.__GodEnable) then
		meta.__GodEnable = meta.GodEnable
		function meta:GodEnable()
		   self.__pGodMode = true
		   self:SetNWBool("__pGodMode",true)
		   self:__GodEnable()
		end

		meta.__GodDisable = meta.GodDisable
		function meta:GodDisable()
		   self.__pGodMode = false
		   self:SetNWBool("__pGodMode",false)
		   self:__GodDisable()
		end

		function meta:HasGodMode()
		   return self.__pGodMode or self.IsFlagSet and self:IsFlagSet(FL_GODMODE);
		end

		hook.Add("PlayerDeath","Player.Death.ResetGod",function(ply)
			ply.__pGodMode = false;
			ply:SetNWBool("__pGodMode",false)
		end)
		hook.Add("PlayerSilentDeath","Player.Death.ResetGod",function(ply)
			ply.__pGodMode = false;
			ply:SetNWBool("__pGodMode",false)
		end)
	end

else

	local meta = FindMetaTable("Player");
	if(meta and not meta.HasGodMode) then
		function meta:HasGodMode()
		   return self:GetNWBool("__pGodMode",false);
		end
	end

end