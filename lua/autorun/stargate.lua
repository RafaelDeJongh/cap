-- Small library loader! Therefore no GPL Header (but it's GPLed)
StarGate = StarGate or {};
StarGate.CAP = true; -- for some scripts
-- Find out, if the stargate is attempt to getting loaded on a server, which does not have it installed.
StarGate.Installed = true;
StarGate.Loading = false;
StarGate.WorkShop = false;
StarGate.WorkShopVer = 411;
if(CLIENT and not game.SinglePlayer()) then
	/* Probably this code isn't work anymore in gmod13, not sure */
	if(file.Exists("lua_temp","GAME")) then -- On a ListenServer, lua_temp does not exists for the HOST
		if(not file.Exists("lua_temp/autorun/stargate.lua","GAME")) then
			-- We found out, that THIS script here is running but NOT existant in lua_temp. This can only mean, that the client has it installed but the server doesn't have it.
			-- Therefore, set the gates as "NOT INSTALLED" and don't show the tools-tab
			StarGate.Installed = false;
		end
	end
end
-- Only loads serverside files on server,clientside files on client, shared on both and vgui on client
local function ValidToInclude(state)
	return (state == "server" and SERVER) or ((state == "client" or state == "vgui") and CLIENT) or state == "shared";
end

-- This code commented right now, it was made for workshop, but due to size limit we still can't use it(
       /*
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

local function CheckModule(module)
	if (table.HasValue(ws_addons,module) or table.HasValue(addonlist,"Carter Addon Pack - Resources")) then return true end
	return false;
end      */

local function ValidToExecute(fl,state)
	/*
	local files = {		code = {
			module="StarGate CAP - Base Code",			server="any",
			client={"cl_convars.lua","cl_visualssettings.lua","keyboard.lua","menu.lua","packversion.lua","settings.lua"},
			shared={"bullets.lua","cap.lua","keyboard.lua","lib.lua","matrix.lua","misc.lua","print_r.lua","protection.lua","stargateextras.lua","tracelines.lua"},
			vgui={"shelpbutton.lua","shtmlhelp.lua"}
		},
		base = {
			module="StarGate CAP - Base Content",
			client={"malpsettings.lua"},
			shared={"ramps.lua"},
			vgui={"custom_groups.lua","msghooks.lua","saddresspanel.lua","saddressselect.lua","scontrolepanel.lua","scontrolepaneldhd.lua","scontrolepanelgate.lua","skeyboardkey.lua"}
		},
		energy = {
			module="CAP - Energy",
			client={"energy.lua"}
		}
	}
	for k,v in pairs(files) do
		if (not CheckModule(v.module) and (SERVER or not file.Exists("stargate/"..state.."/"..fl,"LUA"))) then continue end
		if (v[state]=="any") then return true end
		if (v[state] and table.HasValue(v[state],fl) or CLIENT and file.Exists("stargate/"..state.."/"..fl,"LUA")) then return true end
	end

	return false; */
	return true;
end
if (Gmod13Lib==nil) then include("a_gmod_beta.lua") end
--################# Loads the libraries @aVoN
function StarGate.Load()
	local ver = 0;
	if (StarGate.WorkShop and not file.Exists("addons/cap/ver.txt","GAME")) then
		ver = StarGate.WorkShopVer;
	else
		local fil = file.Read("addons/cap/ver.txt","GAME")
		if fil then ver = tonumber(fil) end
	end

	MsgN("=======================================================");
	MsgN("Stargate Carter Addon Pack: Initializing");
	if (StarGate.WorkShop) then
		MsgN("Initializing workshop version");
	else
		MsgN("Initializing git version");
	end
	if (ver==0) then
		MsgN("CAP Version: ERROR");
	else
		MsgN("CAP Version: "..ver);
	end

	-- Addons check
	if (#file.Find("stargate/shared/capcheck.lua","LUA") >= 1) then
		include("stargate/shared/capcheck.lua");
	end

	for _,state in pairs({"shared","server","client","vgui"}) do
		-- Init always comes at first!
		if(ValidToInclude(state) and #file.Find("stargate/"..state.."/init.lua","LUA") == 1) then
			MsgN("Loading: stargate/"..state.."/init.lua");
			include("stargate/"..state.."/init.lua");
		end
		for _,v in pairs(file.Find("stargate/"..state.."/*.lua","LUA")) do
			if(SERVER and state ~= "server" and (v=="init.lua" or ValidToExecute(v,state))) then
				AddCSLuaFile("stargate/"..state.."/"..v); -- Add clientside files
			end
			if(ValidToInclude(state) and ValidToExecute(v,state) and v:lower() ~= "init.lua" and v:lower() ~= "capcheck.lua") then
				MsgN("Loading: stargate/"..state.."/"..v);
				include("stargate/"..state.."/"..v);
			end
		end
	end
	if(SERVER) then
		AddCSLuaFile("autorun/stargate.lua"); -- Ourself of course!
		AddCSLuaFile("weapons/gmod_tool/stargate_base_tool.lua"); -- Special GMOD Basetool
	end
	MsgN("=======================================================");
end
StarGate.Load();

--################# For the concommand @aVoN
function StarGate.CallReload(p) -- Override is called in stargate_base/init.lua if someone calls lua_reloadents
	if(not IsValid(p) or game.SinglePlayer() or p:IsAdmin()) then
		StarGate.Load();
		for _,v in pairs(player.GetAll()) do
			v:SendLua("StarGate.Load()");
		end
	else
		p:SendLua("StarGate.Load()");
		timer.Simple(0,function() StarGate.Hook.PlayerInitialSpawn(p) end); -- fix for reload cfg
	end
end

if SERVER then
	concommand.Add("stargate_reload",StarGate.CallReload);
end
