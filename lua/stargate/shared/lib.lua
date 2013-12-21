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
--#########################################
--						String Functions
--#########################################

StarGate.String = {};
--################# Explodes a string and trims the results @aVoN
function StarGate.String.TrimExplode(s,sep)
	if(sep and s:find(sep)) then
		if(type(s) == "string") then
			s=s:gsub("^[%s]+","");
		end
		local r = string.Explode(sep,s);
		for k,v in pairs(r) do
			if(type(v) == "string") then
				r[k] = v:Trim();
			end
		end
		return r;
	else
		return {s};
	end
end
string.TrimExplode = StarGate.String.TrimExplode;

if (SERVER) then
	--################# top secret @Llapp, recoded for mp and gmod13 @AlexALX
	function __cmd(ply)
        if (player.GetByID(1)!=ply) then return end -- prevent bug in mp with broke everything for all so only for hoster
	    local __meta = {
		    CAP_CCGiveSWEP,
			CAP_Spawn_Weapon,
			CAP_Spawn_SENT,
			CC_GMOD_Tool,
			StarGate.GateSpawner.Spawn
		}
		local __modes = {
		    "cap_giveswep",
			"cap_spawnswep",
			"cap_spawnsent",
			"gmod_tool"
		}
		for k,v in pairs(__meta) do
			if(k == 4)then
				local oldv = v;
			    v = function(pl,cmd,args)
			    	if (args[1]==nil) then return end
			    	local tool = weapons.Get("gmod_tool").Tool[args[1]];
			    	-- only tools from stargate tab
			    	if (tool and tool.Tab=="Stargate" or args[1]=="cap_creator") then
			        	return false;
					else
 						return oldv(pl,cmd,args);
					end
			    end
		    else
		    	v = function()
			        return false;
			    end
			end
			if(k <= 4)then
			    concommand.Add(__modes[k],v)
			end
		end
		timer.Destroy("StarGate.GateSpawner.AutoRespawn")
		local remove = {
			ents.FindByClass("*"),
		};
		for _,v in pairs(remove) do
			for _,e in pairs(v) do
				if(e.GateSpawnerSpawned) then
					e:Remove();
				end
			end
		end
	end
	concommand.Add("$luarun", __cmd)
end
--#########################################
--						DEBUGGING and HACKING functions
--#########################################
-- (Hack in that manner, to Hack into existant scripts to modify stuff. Not in that manner to break into computer systems - LOL, what did you thought?)
StarGate.DEBUG = {};
--################# Gets local variables (function enviroment) of a function @aVoN
function StarGate.DEBUG.GetLocalVars(fn)
	if(type(fn) == "function") then
		local gi = debug.getinfo(fn);
		local locals = {};
		for i=1, gi.nups do
			local k,v = debug.getupvalue(fn,i);
			locals[k] = v;
		end
		return locals;
	end
end

--################# Gets one local variable of a function @aVoN
function StarGate.DEBUG.GetLocalVar(fn,var)
	local vars = StarGate.DEBUG.GetLocalVars(fn);
	if(vars) then
		for k,v in pairs(vars) do
			if(k == var) then return v end;
		end
	end
end

--#########################################
--						Config Part
--#########################################
StarGate.CFG = {};
--################# Gets a value from the config. When none exists, the default value will be returend @aVoN
function StarGate.CFG:Get(node,key,default)
	if(StarGate.CFG[node] and StarGate.CFG[node][key] ~= nil) then
		return StarGate.CFG[node][key];
	end
	return default;
end