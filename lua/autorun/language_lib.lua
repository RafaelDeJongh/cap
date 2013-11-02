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

	###################################
	StarGate with Group System
	Created by AlexALX (c) 2011
	###################################
	Small language lib, which lacking in gmod lua functions
	Some lua function not compatiable with language messages (with #),
	and also original language messages can't use in messages other text.
	So i make this small lib.
	###################################
*/

if (SERVER) then
	AddCSLuaFile();
end

if (CLIENT) then
	CreateClientConVar( "sg_language", GetConVarString("gmod_language") or "en", true, false )
	CreateClientConVar( "sg_language_debug", "0", false, false )
end

if (Gmod13Lib==nil) then
	include("a_gmod_beta.lua")
end

LANGParser = {};
-- ############## Loads an ini file (object) @ aVoN
function LANGParser:new(file_,no_autotrim)
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
	if(file.Exists(file_,"GAME") and not var) then
		obj.file = file_;
		obj.notrim = no_autotrim;
		obj.content = file.Read(file_,"GAME"); -- Saves raw content of the file
		obj.nodes = {}; -- Stores all nodes of the ini
	else
		Msg("LANGParser:new - File "..file_.." does not exist!\n");
		return;
	end
	obj:parse();
	return obj;
end

-- ############## Strips comments from a line(string) @ aVoN
function LANGParser:StripComment(line)
	local found_comment = line:find("[/][/]");
	if(found_comment) then
		if (line:sub(found_comment-3,found_comment-1)!="tp:") then
			line = line:sub(1,found_comment-1):Trim(); -- Removes any non neccessayry stuff
		end
	end
	return line;
end

-- ############## Strips quotes from a string (when an idiot added them...) (string) @ aVoN
function LANGParser:StripQuotes(s)
	-- Replaces accidently added quotes from alphanumerical strings
	return s:gsub("^[\"'](.+)[\"']$","%1"); --" <-- needed, to make my NotePad++ to show the functions below
end

-- ############## Parses the inifile to a table (void) @ aVoN
function LANGParser:parse()
	local exploded = string.Explode("\n",self.content);
	local nodes = {};
	local cur_node = "messages";
	local cur_node_index = 1;
	local last_key = "";
	local multiline = false;
	for k,v in pairs(exploded) do
		local line = self:StripComment(v):gsub("\\n","\n"):Trim();
		-- why this happens if save with notepad in utf8?
		if (line:sub(1,1):byte()==239) then
			line = line:sub(4)
		end
		if(line ~= "" and not multiline) then -- Only add lines with contents (no commented lines)
			nodes[cur_node] = nodes[cur_node] or {};
			local data = string.Explode("=",line);
			-- This is needed, because garry missed to add a limit to string.Explode
			local table_count = table.getn(data);
			if(table_count > 2) then
				for k=3,table_count do
					data[2] = data[2].."="..data[k];
					data[k] = nil;
				end
				table_count = 2;
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
				if (value:sub(1,2)=="[[") then
					last_key = key;
					multiline = true;
					value = value:sub(3);
				end
				nodes[cur_node][cur_node_index][key] = value;
			else
				Msg("LANGParser:parse - Parse error in file "..self.file.. " at line "..k.." near \""..line.."\": No datablock specified!\n");
				--self = nil;
				--return;
			end
		elseif (multiline) then
			key = last_key;
			if(self.notrim) then
				value = self:StripQuotes(line);
			else
				value = self:StripQuotes(line):Trim();
			end
			if (value:sub(-2,-1)=="]]") then
				last_key = "";
    			multiline = false;
    			value = value:sub(0,-3);
			end
			nodes[cur_node][cur_node_index][key] = nodes[cur_node][cur_node_index][key].."\n"..value;
		end
	end
	self.nodes = nodes;
	--Msg("LANGParser:parse - File "..self.file.. " successfully parsed\n");
end

-- ############## Either you index the object directly, when you know, which value to index, or you simply get the full INI content (table) @ aVoN
function LANGParser:get()
	return self.nodes;
end

SGLanguage = SGLanguage or {};

-- it will always return english messages server-side (for lua shared files)

local SGLanguage_Messages = {};

local lang_names = {["Name"]={},["Lang"]={}}

local function LangNames()
	local fi,fo = file.Find("lua/data/language/*","GAME");
	for k,lang in pairs(fo) do
		if (not file.Exists("lua/data/language/"..lang.."/stargate.lua","GAME")) then continue; end
		ini = LANGParser:new("lua/data/language/"..lang.."/stargate.lua");
		if (ini and ini.messages) then
			for _,v in pairs(ini.messages) do
				if (v["global_lang_name"]) then lang_names["Name"][lang] = v["global_lang_name"]; lang_names["Lang"][v["global_lang_name"]] = lang; end
			end
		end
	end
end

local function LangInit()
	local langfiles = file.Find("lua/data/language/en/*.lua","GAME");
	for _,f in pairs(langfiles) do
		SGLanguage.ParseFile("en",f);
	end
	if CLIENT then
		langfiles = file.Find("lua/data/language/"..SGLanguage.GetClientLanguage().."/*.lua","GAME");
		for _,f in pairs(langfiles) do
			SGLanguage.ParseFile(SGLanguage.GetClientLanguage(),f);
		end
	end
	LangNames();
end

-- for fix old lang names
-- should be removed later
local old_langs = {
	["croatian"] = "hr",
    ["czech"] = "cs",
    ["dutch"] = "nl",
    ["english"] = "en",
    ["estonian"] = "et",
    ["french"] = "fr",
    ["german"] = "de",
    ["hungarian"] = "hu",
    ["russian"] = "ru",
    ["spanish"] = "es",
    ["swedish"] = "sv-se",
    ["turkish"] = "tr",
    ["sv"] = "sv-se",
    ["es"] = "es-es",
}
if (CLIENT) then
	local lang = GetConVarString("sg_language") or "en";
	if (old_langs[lang]) then
		if (lang=="english") then
			local lg = GetConVarString("gmod_language") or "en";
			if (lg=="uk") then lg = "ru"; end
			RunConsoleCommand("sg_language",lg);
		else
			RunConsoleCommand("sg_language",old_langs[lang]);
		end
	elseif (lang:len()>5) then
		local lg = GetConVarString("gmod_language") or "en";
		if (lg=="uk") then lg = "ru"; end
		RunConsoleCommand("sg_language",lg);
	end
end

function SGLanguage.GetClientLanguage()
	if SERVER then return "en" end
	local lang = GetConVarString("sg_language") or "en";
	if (lang=="uk") then lang = "ru"; end
	if (old_langs[lang]) then return old_langs[lang]; end
	return lang;
end

function SGLanguage.SetClientLanguage(lang)
	if SERVER then return end
	RunConsoleCommand("sg_language",lang);
	timer.Remove("SGLanguage.Reload");
	timer.Create("SGLanguage.Reload",0.5,1,function() RunConsoleCommand("sg_language_reload") end);
end

function SGLanguage.GetMessage(message, ...)
	return Format(tostring(SGLanguage_Messages[message] or message), ...) or message;
end

function SGLanguage.ValidMessage(message)
	if (SGLanguage_Messages[message] and tostring(SGLanguage_Messages[message])!="") then
		return true;
	end
	return false;
end

function SGLanguage.RegisterMessage(message,text,override)
	if (text and (not SGLanguage.ValidMessage(message) or override)) then
		SGLanguage_Messages[message] = text;
	end
end

function SGLanguage.GetLanguageName(lang)
	return lang_names["Name"][lang] or "Error";
end

function SGLanguage.GetLanguageFromName(lang)
	return lang_names["Lang"][lang] or "err";
end

if (CLIENT) then
	function SGLanguage.ReloadSGLanguages(no_msg)
		SGLanguage_Messages = {};
		lang_names = {["Name"]={},["Lang"]={}}
		LangInit();
		if (not no_msg) then MsgN("Languages successfully reloded."); end
	end
	concommand.Add("sg_language_reload", function() SGLanguage.ReloadSGLanguages() end);
end

function SGLanguage.ParseFile(lang, file)
	ini = LANGParser:new("lua/data/language/"..lang.."/"..file);
	if (ini and ini.messages) then
		for _,v in pairs(ini.messages) do
			for k,m in pairs(v) do
				SGLanguage.RegisterMessage(k,m,true);
			end
		end
	end
end

LangInit();