/*
	INI-Parser to parse .ini files and read out the data
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
INIParser = {};
-- ############## Loads an ini file (object) @ aVoN
function INIParser:new(file_,no_autotrim,game_folder,commtype,no_msg)
	local obj = {};
	setmetatable(obj,self);
	self.__index = function(t,n)
		local nodes = rawget(t,"nodes");
		if(nodes) then
			if(nodes[n]) then
				return nodes[n];
			end
		end
		return self[n]; -- Returns self or the nodes if directly indexed
	end
	local exists = false;
	local mod = true;
	if (game_folder) then
		exists = file.Exists(file_,"MOD");
		if not exists then
			exists = file.Exists(file_,"GAME");
			mod = false;
		end
	else
		exists = file.Exists(file_,"DATA");
	end
	if(exists) then
		obj.file = file_;
		obj.notrim = no_autotrim;
		obj.commtype = commtype;
		if (game_folder) then
			obj.content = file.Read(file_,mod and "MOD" or "GAME"); -- Saves raw content of the file
		else
			obj.content = file.Read(file_,"DATA"); -- Saves raw content of the file
		end
		obj.nodes = {}; -- Stores all nodes of the ini
	else
		if (not no_msg) then
			Msg("INIParser:new - File "..file_.." does not exist!\n");
		end
		return;
	end
	obj:parse(no_msg);
	return obj;
end

-- ############## Strips comments from a line(string) @ aVoN
function INIParser:StripComment(line)
	local found_comment = line:find("[;#]");
	if (self.commtype) then
		found_comment = line:find("[/][/]");
	end
	if(found_comment) then
		line = line:sub(1,found_comment-1):Trim(); -- Removes any non neccessayry stuff
	end
	return line;
end

-- ############## Strips quotes from a string (when an idiot added them...) (string) @ aVoN
function INIParser:StripQuotes(s)
	-- Replaces accidently added quotes from alphanumerical strings
	return s:gsub("^[\"'](.+)[\"']$","%1"); --" <-- needed, to make my NotePad++ to show the functions below
end

-- ############## Parses the inifile to a table (void) @ aVoN
function INIParser:parse(no_msg)
	local exploded = string.Explode("\n",self.content);
	local nodes = {};
	local cur_node = "";
	local cur_node_index = 1;
	for k,v in pairs(exploded) do
		local line = self:StripComment(v):gsub("\n",""):Trim();
		if (line:sub(1,1):byte()==239) then
			line = line:sub(4)
		end
		if(line ~= "") then -- Only add lines with contents (no commented lines)
			if(line:sub(1,1) == "[") then -- Holy shit, it's a node
				local node_end = line:find("%]");
				if(node_end) then
					local node = line:sub(2,node_end-1); -- Get single node name
					nodes[node] = nodes[node] or {};
					cur_node = node;
					cur_node_index = table.getn(nodes[node])+1;
				else
					Msg("INIParser:parse - Parse error in file "..self.file.. " at line "..k.." near \""..line.."\": Expected node!\n");
					self = nil;
					return;
				end
			else
				if(cur_node == "") then
					Msg("INIParser:parse - Parse error in file "..self.file.. " at line "..k.." near \""..line.."\": No node specified!\n");
					self = nil;
					return;
				else
					local data = string.Explode("=",line);
					-- This is needed, because garry missed to add a limit to string.Explode
					local table_count = table.getn(data);
					if(table_count > 2) then
						for k=3,table_count do
							data[2] = data[2].."="..data[k];
							data[k] = nil;
						end
					end
					if(table_count == 2) then
						local key = ""
						local value = ""
						if(self.notrim) then
							key = self:StripQuotes(data[1]);
							value = self:StripQuotes(data[2]);
						else
							key = self:StripQuotes(data[1]):Trim();
							value = self:StripQuotes(data[2]):Trim();
						end
						nodes[cur_node][cur_node_index] = nodes[cur_node][cur_node_index] or {};
						nodes[cur_node][cur_node_index][key] = value;
					else
						Msg("INIParser:parse - Parse error in file "..self.file.. " at line "..k.." near \""..line.."\": No datablock specified!\n");
						self = nil;
						return;
					end
				end
			end
		end
	end
	self.nodes = nodes;
	if (not no_msg) then
		Msg("INIParser:parse - File "..self.file.. " successfully parsed\n");
	end
end

-- ############## Either you index the object directly, when you know, which value to index, or you simply get the full INI content (table) @ aVoN
function INIParser:get()
	return self.nodes;
end
