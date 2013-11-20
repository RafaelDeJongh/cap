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
StarGate.Installed = true;
--#########################################
--						Config System
--#########################################

if (not file.IsDir("stargate","DATA")) then
	file.CreateDir("stargate","DATA");
end

--################# Loads the config @aVoN
function StarGate.LoadConfig(p)
	if(not p or p:IsAdmin() or game.SinglePlayer()) then
		StarGate.CFG.SYNC = {}; -- They sync keys
		-- Loads the config only ONE time and not always when I press "sent_reload" (Increases loading times)
		if(not INIParser) then include("ini_parser.lua") end;
		if (file.Exists("lua/data/stargate/config.lua","GAME")) then
			file.Write("stargate/config.txt",file.Read("lua/data/stargate/config.lua","GAME"));
		end
		if (file.Exists("lua/data/stargate/how to create your own config.lua","GAME")) then
			file.Write("stargate/how to create your own config.txt",file.Read("lua/data/stargate/how to create your own config.lua","GAME"));
		end
		local ini = INIParser:new("stargate/config.txt",false);
		local custom_config = INIParser:new("stargate/user_config.txt",false);
		-- Merge our custom config with the default one
		if(custom_config) then
			for node,datas in pairs(custom_config.nodes) do
				ini.nodes[node] = ini.nodes[node] or {};
				for num,data in pairs(datas) do
					ini.nodes[node][num] = ini.nodes[node][num] or {};
					for k,v in pairs(data) do
						ini.nodes[node][num][k] = v;
					end
				end
			end
		end
		for name,cfg in pairs(ini:get()) do
			if(name ~= "config") then
				if (cfg[1]==nil) then continue; end
				StarGate.CFG[name] = {};
				local sync = (cfg[1].SYNC or ""):TrimExplode(",");
				for k,v in pairs(cfg[1]) do
					v=v:Trim();
					local number = tonumber(v);
					if(number) then
						v = number;
					elseif(v == "false" or v == "true") then
						v = util.tobool(v);
					end
					StarGate.CFG[name][k] = v;
					-- Sync the values with the Client
					if(table.HasValue(sync,k) or name:find("_groups_only") or name:find("cap_disabled_")) then
						StarGate.CFG.SYNC[name] = StarGate.CFG.SYNC[name] or {};
						StarGate.CFG.SYNC[name][k] = v;
					end
					/* not sure what better - disable it from selecting or show "This tool is disabled on server!" error...
					if (name == "cap_disabled_tool") then
						if (v) then
							RunConsoleCommand("toolmode_allow_"..k,0)
						else
							RunConsoleCommand("toolmode_allow_"..k,1)
						end
					end*/
				end
			end
			if (StarGate.Hook.PlayerInitialSpawn) then timer.Simple(0,function() StarGate.Hook.PlayerInitialSpawn(NULL,true) end) end -- fix for reload.
		end
	end
end
StarGate.LoadConfig();
concommand.Add("stargate_reloadconfig",StarGate.LoadConfig);

util.AddNetworkString( "StarGate_CFG" );
--################# Starts syncing the CFG from the server to the client @aVoN
function StarGate.Hook.PlayerInitialSpawn(p,reload)
	-- Now start syncing the config (also tells the client, SGPack is installed - just to be sure)
	for name,data in pairs(StarGate.CFG.SYNC) do
		if(p and IsValid(p) and p:IsPlayer() or reload) then -- Prevents crashing (must be done everytime we send a umsg!)
			net.Start("StarGate_CFG");
			net.WriteString(name); -- Tell the client, what CFG node
			net.WriteInt(table.Count(data),8); -- Tell the client, how much data will follow (Char goes from -128 to 128). But you seriously shoudln't add more than 20 umsg!
			for k,v in pairs(data) do
				net.WriteString(k); -- Tell the client, what's the keys name
				if(type(v) == "boolean") then
					net.WriteInt(0,8); -- I'm a bool
					net.WriteBit(v);
				elseif(type(v) == "string") then
					net.WriteInt(1,8); -- I'm a string
					net.WriteString(v);
				else -- I'm a sort of number
					if(v ~= math.ceil(v)) then -- I'm a float
						net.WriteInt(2,8);
						net.WriteFloat(v);
					elseif(v > -128 and v < 127) then -- I'm a Char
						net.WriteInt(3,8);
						net.WriteInt(v,8);
					elseif(v > -32768 and v < 32767) then -- I'm a short
						net.WriteInt(4,8);
						net.WriteInt(v,16);
					else -- I'm a long
						net.WriteInt(5,8);
						net.WriteInt(v,32);
					end
				end
			end
			if (reload) then
				net.Broadcast();
			else
				net.Send(p);
			end
		end
	end
end
hook.Add("PlayerInitialSpawn","StarGate.Hook.PlayerInitialSpawn",StarGate.Hook.PlayerInitialSpawn);

--################# Sends NWData of the gates to a client@aVoN
--If a new player joins the server, he normally does not have Networked Data which has been set before he joined. This hook forces to resend the date to everyone if he presses
-- "MoveForward" the first time just after he joined. Before I used a Think, but I think this was useless networked data.
local joined = {};
hook.Add("KeyPress","StarGate.KeyPress.SendGateData",
	function(p,key)
		if(not joined[p] and key == IN_FORWARD) then
			joined[p] = true; -- Do not call this hook twice!
			for _,v in pairs(ents.FindByClass("stargate_*")) do
				if(v.IsStargate) then
					v:SetNetworkedString("Address",""); -- "Reset old value" to cause an immediate update in the next step below
					v:SetNWString("Address",v.GateAddress,true);
					v:SetNWString("Group",""); -- "Reset old value" to cause an immediate update in the next step below
					v:SetNWString("Group",v.GateGroup,true);
					v:SetNWString("Name",""); -- "Reset old value" to cause an immediate update in the next step below
					v:SetNWString("Name",v.GateName,true);
					v:SetNWBool("Private",not v.GatePrivat); -- "Reset old value" to cause an immediate update in the next step below
					v:SetNWBool("Private",v.GatePrivat,true);
					v:SetNWBool("Locale",not v.GateLocal); -- "Reset old value" to cause an immediate update in the next step below
					v:SetNWBool("Locale",v.GateLocal,true);
					v:SetNWBool("Galaxy",not v.GateGalaxy);
					v:SetNWBool("Galaxy",v.GateGalaxy,true);
					v:SetNWBool("Blocked",not v.GateBlocked);
					v:SetNWBool("Blocked",v.GateBlocked,true);
					v:SendGateInfo(p);
					v:ConvarsThink(true);
				end
			end
			for _,v in pairs(ents.FindByClass("atlantis_transporter")) do
				net.Start("UpdateAtlTP")
				net.WriteInt(v:EntIndex(),16)
				net.WriteInt(3,4)
				net.WriteString(v.TName or "")
				net.WriteBit(v.TPrivate or false)
				net.Send(p)
			end
		end
	end
);

local function StarGate_CloseAll(ply)
	if (IsValid(ply) and not ply:IsAdmin()) then ply:PrintMessage( HUD_PRINTCONSOLE, "Yor are not admin!"); return end
	timer.Simple(0.1,function()
		for k,v in pairs(ents.FindByClass("stargate_*")) do
			if (v.IsStargate) then
				v:AbortDialling();
			end
		end
	end);
	if (IsValid(ply)) then
		ply:PrintMessage( HUD_PRINTCONSOLE, "All gates closed! (not including blocked stargates by some devices)");
	else
		print("All gates closed! (not including blocked stargates by some devices)");
	end
end
concommand.Add("stargate_close_all",StarGate_CloseAll);

local function StarGate_OpenAll(ply)
	if (IsValid(ply) and not ply:IsAdmin()) then ply:PrintMessage( HUD_PRINTCONSOLE, "Yor are not admin!"); return end
	timer.Simple(0.1,function()
		for k,v in pairs(ents.FindByClass("*_iris")) do
			if (v.IsIris) then
				v:TrueActivate(true);
			end
		end
	end);
	if (IsValid(ply)) then
		ply:PrintMessage( HUD_PRINTCONSOLE, "All iris is opened!");
	else
		print("All iris is opened!");
	end
end
concommand.Add("stargate_open_all_iris",StarGate_OpenAll);

local function CanPlayerSpawnSENT( player, EntityName )

	-- Is this in the SpawnableEntities list?
	local SpawnableEntities = list.Get( "CAP.Entity" )
	if (!SpawnableEntities) then return false end

	-- check for spawnable
	local EntTable
	for k,v in pairs(SpawnableEntities) do
		if (v.ClassName==EntityName) then
			EntTable = v; break;
		end
	end
	if (EntTable == nil) then return false end

	local sent = EntTable

	-- We need a spawn function. The SENT can then spawn itself properly
	if (!sent.SpawnFunction) then return false end

	if (StarGate_Group and StarGate_Group.Error == true) then StarGate_Group.ShowError(player); return false
	elseif (StarGate_Group==nil or StarGate_Group.Error==nil) then
		Msg("Carter Addon Pack - Unknown Error\n");
		player:SendLua("Msg(\"Carter Addon Pack - Unknown Error\\n\")");
		player:SendLua("GAMEMODE:AddNotify(\"Carter Addon Pack: Unknown Error\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end

	if (table.HasValue(StarGate.SlGort,player:SteamID())) then return false end

	-- You're not allowed to spawn this unless you're an admin!
	if (StarGate.NotSpawnable(EntityName,player)) then return false end

	return true

end

function CAP_Spawn_SENT( player, EntityName, tr )

	if ( EntityName == nil ) then return end

	if ( !CanPlayerSpawnSENT( player, EntityName ) ) then return end

	-- Ask the gamemode if it's ok to spawn this
	if ( !gamemode.Call( "PlayerSpawnSENT", player, EntityName ) ) then return end

	local vStart = player:EyePos()
	local vForward = player:GetAimVector()

	if ( !tr ) then

		local trace = {}
		trace.start = vStart
		trace.endpos = vStart + (vForward * 4096)
		trace.filter = player

		tr = util.TraceLine( trace )

	end

	local entity = nil
	local PrintName = nil
	local sent = scripted_ents.GetStored( EntityName )
	if ( sent ) then

		local sent = sent.t

		ClassName = EntityName

		entity = sent:SpawnFunction( player, tr )

		ClassName = nil

		PrintName = sent.PrintName

	else

		-- Spawn from list table
		local SpawnableEntities = list.Get( "CAP.Entity" )
		if (!SpawnableEntities) then return end
		local EntTable = SpawnableEntities[ EntityName ]
		if (!EntTable) then return end

		PrintName = EntTable.PrintName

		local SpawnPos = tr.HitPos + tr.HitNormal * 16
		if ( EntTable.NormalOffset ) then SpawnPos = SpawnPos + tr.HitNormal * EntTable.NormalOffset end

		entity = ents.Create( EntTable.ClassName )
			entity:SetPos( SpawnPos )
		entity:Spawn()
		entity:Activate()

		if ( EntTable.DropToFloor ) then
			entity:DropToFloor()
		end

	end


	if ( IsValid( entity ) ) then

		if ( IsValid( player ) ) then
			gamemode.Call( "PlayerSpawnedSENT", player, entity )
		end

		undo.Create("SENT")
			undo.SetPlayer(player)
			undo.AddEntity(entity)
			if ( PrintName ) then
				undo.SetCustomUndoText( "Undone "..PrintName )
			end
		undo.Finish( "Scripted Entity ("..tostring( EntityName )..")" )

		player:AddCleanup( "sents", entity )
		entity:SetVar( "Player", player )

	end


end

concommand.Add( "cap_spawnsent", function( ply, cmd, args ) CAP_Spawn_SENT( ply, args[1] ) end )

function CAP_CCGiveSWEP( player, command, arguments )

	if ( arguments[1] == nil ) then return end

	if (StarGate_Group and StarGate_Group.Error == true) then StarGate_Group.ShowError(player); return false
	elseif (StarGate_Group==nil or StarGate_Group.Error==nil) then
		Msg("Carter Addon Pack - Unknown Error\n");
		player:SendLua("Msg(\"Carter Addon Pack - Unknown Error\\n\")");
		player:SendLua("GAMEMODE:AddNotify(\"Carter Addon Pack: Unknown Error\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end

	if (table.HasValue(StarGate.SlGort,player:SteamID())) then return false end

	-- Make sure this is a SWEP
	local swept = list.Get( "CAP.Weapon" );
	local swep;

	for k,v in pairs(swept) do
		if (v.ClassName==arguments[1]) then
			swep = v; break;
		end
	end

	if (swep == nil) then return end

	-- You're not allowed to spawn this!
	if (StarGate.NotSpawnable(arguments[1],player,"swep")) then return end

	if ( !gamemode.Call( "PlayerGiveSWEP", player, arguments[1], swep ) ) then return end

	MsgAll( "Giving "..player:Nick().." a "..swep.ClassName.."\n" )
	player:Give( swep.ClassName )
	-- And switch to it
	player:SelectWeapon( swep.ClassName )

end

concommand.Add( "cap_giveswep", CAP_CCGiveSWEP )

--[[---------------------------------------------------------
	-- Give a swep.. duh.
-----------------------------------------------------------]]
function CAP_Spawn_Weapon( Player, wepname, tr )

	if ( wepname == nil ) then return end

	if (StarGate_Group and StarGate_Group.Error == true) then StarGate_Group.ShowError(player); return false
	elseif (StarGate_Group==nil or StarGate_Group.Error==nil) then
		Msg("Carter Addon Pack - Unknown Error\n");
		player:SendLua("Msg(\"Carter Addon Pack - Unknown Error\\n\")");
		player:SendLua("GAMEMODE:AddNotify(\"Carter Addon Pack: Unknown Error\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end

	if (table.HasValue(StarGate.SlGort,Player:SteamID())) then return false end

	local swept = list.Get( "CAP.Weapon" );
	local swep;

	for k,v in pairs(swept) do
		if (v.ClassName==wepname) then
			swep = v; break;
		end
	end

	-- Make sure this is a SWEP
	if ( swep == nil ) then return end

	-- You're not allowed to spawn this!
	if (StarGate.NotSpawnable(wepname,Player,"swep")) then return end

	if ( !gamemode.Call( "PlayerSpawnSWEP", Player, wepname, swep ) ) then return end

	if ( !tr ) then
		tr = Player:GetEyeTraceNoCursor()
	end

	if ( !tr.Hit ) then return end

	local entity = ents.Create( swep.ClassName )

	if ( IsValid( entity ) ) then

		entity:SetPos( tr.HitPos + tr.HitNormal * 32 )
		entity:Spawn()

		gamemode.Call( "PlayerSpawnedSWEP", Player, entity )

	end


end

concommand.Add( "cap_spawnswep", function( ply, cmd, args ) CAP_Spawn_Weapon( ply, args[1] ) end )

function StarGate.NotSpawnable(class,player,mode)
	if (not mode) then mode = "ent" end
	if ( StarGate.CFG:Get("cap_disabled_"..mode,class,false) ) then player:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"cap_disabled_"..mode.."\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )"); return true end
	if ( StarGate.CFG:Get(mode.."_groups_only",class,false)) then
		local tbl = StarGate.CFG:Get(mode.."_groups_only",class,""):TrimExplode(",");
		local disallow = true;
		for k,v in pairs(tbl) do
			if (v=="add_shield") then continue end
			if (player:IsUserGroup(v)) then
				disallow = false; break;
			end
		end
		if (disallow) then
			player:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"cap_group_"..mode.."\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return true;
		end
	end
	return false;
end

util.AddNetworkString("_SGCUSTOM_GROUPS");
if (not file.Exists("stargate/custom_groups.txt","DATA") and file.Exists("lua/data/stargate/custom_groups.lua","GAME")) then
	file.Write("stargate/custom_groups.txt",file.Read("lua/data/stargate/custom_groups.lua","GAME"))
end

StarGate.CUSTOM_GROUPS = {};
StarGate.CUSTOM_TYPES = {};

local ini = INIParser:new("stargate/custom_groups.txt",false,false,true);
if(ini) then
	if (ini.nodes.stargate_custom_groups and ini.nodes.stargate_custom_groups[1]) then
		for k,v in pairs(ini.nodes.stargate_custom_groups[1]) do
			StarGate.CUSTOM_GROUPS[k] = {v};
		end
	end
	if (ini.nodes.stargate_custom_types and ini.nodes.stargate_custom_types[1]) then
		for k,v in pairs(ini.nodes.stargate_custom_types[1]) do
			if (v:find(" !SHARED")) then
				StarGate.CUSTOM_TYPES[k] = {v:Replace(" !SHARED",""),1};
			else
				StarGate.CUSTOM_TYPES[k] = {v};
			end
		end
	end

	hook.Add("PlayerInitialSpawn","SG_INIT_CUSTOM_GROUPS",function(ply)
		net.Start("_SGCUSTOM_GROUPS");
		net.WriteTable(StarGate.CUSTOM_GROUPS);
		net.WriteTable(StarGate.CUSTOM_TYPES);
		net.Send(ply);
	end)

	-- if reload config
	timer.Simple(1.0,function()
		net.Start("_SGCUSTOM_GROUPS");
		net.WriteTable(StarGate.CUSTOM_GROUPS);
		net.WriteTable(StarGate.CUSTOM_TYPES);
		net.Broadcast();
	end)
end
