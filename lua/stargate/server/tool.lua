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
--						STOOL Additions
--#########################################

--################# Spawnfunction for SENTs (ToolUsage) @aVoN
StarGate.TOOL = StarGate.TOOL or {};
StarGate.TOOL.Entities = StarGate.TOOL.Entities or {};

-- Input is the SENT classname and the table keys, which shall be saved when used by duplicator (must be strings)
function StarGate.TOOL.CreateSpawner(class,...)
	StarGate.TOOL.Entities[class] = StarGate.TOOL.Entities[class] or {};
	StarGate.TOOL.Entities[class].args = {...};
	StarGate.TOOL.Entities[class].func = function (p,ang,pos,...)
		if(not IsValid(p) or not p:CheckLimit(class)) then return end; -- Spawned too much!
		local arg = {...}
		-- Create Entity
		local e = ents.Create(class);
		if(not e:IsValid()) then return false end;
		e:SetAngles(ang);
		e:SetPos(pos);
		-- Calls the PreEntitySpawn function. There, you can add special things like setting modles etc
		if(StarGate.TOOL.Entities[class].PreEntitySpawn) then
			StarGate.TOOL.Entities[class].PreEntitySpawn(p,e,...);
		end
		e:Spawn();
		e:Activate();
		e.Owner = p;
		-- Calls the PostEntitySpawn function. There, you can add e.g. numpad bindings and other things
		if(StarGate.TOOL.Entities[class].PostEntitySpawn) then
			StarGate.TOOL.Entities[class].PostEntitySpawn(p,e,...);
		end
		-- Tell the duplicator, what to save for a restore
		if(arg and type(arg) == "table") then
			for k,v in pairs(StarGate.TOOL.Entities[class].args) do
				e[v] = arg[k];
			end
		end
		-- This function updates the keys for the duplicator. This is necessary to update a SENT via a tool or the changes won't get saved
		e.UpdateKeys = function(self,...)
			local argc = {...}
			for k,v in pairs(argc) do
				if(v ~= _ and v ~= nil) then
					local k = StarGate.TOOL.Entities[class].args[k];
					if(k) then
						self[k] = v;
					end
				end
			end
		end
		p:AddCount(class,e)
		return e;
	end
	-- Register the SENT to the duplicator
	if(duplicator and duplicator.RegisterEntityClass) then
		duplicator.RegisterEntityClass(class,StarGate.TOOL.Entities[class].func,"Ang","Pos",...);
	end
end
