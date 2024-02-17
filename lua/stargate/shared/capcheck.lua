/*
	###################################
	StarGate with Groups System
	Created by AlexALX (c) 2011
	###################################
*/
StarGate_Group = StarGate_Group or {};

local addonlist = {}

if (GetAddonList!=nil) then
	for _,v in pairs(GetAddonList(true)) do
		for k,c in pairs(GetAddonInfo(v)) do
			if (k == "Name") then
				table.insert(addonlist, c);
			end
		end
	end
end

local js_addonlist = {}
if (GetAddonListJson!=nil) then
	for _,v in pairs(GetAddonListJson(true)) do
		for k,c in pairs(GetAddonInfoJson(v)) do
			if (k == "Name") then
				table.insert(js_addonlist, c);
			end
		end
	end
end

local cap_ver = tonumber(StarGate.CapVer);
local cap_res = 0;
local cap_res_req = 0;

if (file.Exists("lua/cap_res.lua","GAME")) then
	cap_res = tonumber(file.Read("lua/cap_res.lua","GAME"));
end
if (file.Exists("lua/cap_res_req.lua","GAME")) then
	cap_res_req = tonumber(file.Read("lua/cap_res_req.lua","GAME"));
end

local status = "Loaded";
StarGate_Group.Error = false;
StarGate_Group.ErrorMSG = {};
StarGate_Group.ErrorMSG_HTML = {};

if (SERVER) then
	util.AddNetworkString( "CAP_ERROR" );
	util.AddNetworkString( "CL_CAP_ERROR" );
end                                                                     

StarGate.CAP_WS_ADDONS = {[180088121]="Carter Addon Pack: Atlantis", [180088756]="Carter Addon Pack: CapBuild", [180092028]="Carter Addon Pack: CatWalkBuild", [180094475]="Carter Addon Pack: DHD",
	[180095275]="Carter Addon Pack: DHD Extra", [180095434]="Carter Addon Pack: Extra Materials", [180095783]="Carter Addon Pack: Life Support", [180098639]="Carter Addon Pack: Maps",
	[180225064]="Carter Addon Pack: Event Horizons", [180214862]="Carter Addon Pack: Optional Ramps Pack", [180266528]="Carter Addon Pack: Player Models", [180266528]="Carter Addon Pack: Player Weapons",
	[180210973]="Carter Addon Pack: Props", [180212109]="Carter Addon Pack: Ramps Important", [180213250]="Carter Addon Pack: Ramps Pack", [180215491]="Carter Addon Pack: Resources",
	[180216309]="Carter Addon Pack: Ring Ramps", [180217191]="Carter Addon Pack: Rings", [180220324]="Carter Addon Pack: Shields and Protection", [180222569]="Carter Addon Pack: Sounds",
	[180223815]="Carter Addon Pack: Stargate", [180226239]="Carter Addon Pack: Stargate Extras", [180228917]="Carter Addon Pack: Stargate Universe", [180229838]="Carter Addon Pack: Stargate Universe Extras",
	[180227098]="Carter Addon Pack: Supergate", [180227777]="Carter Addon Pack: Tool Weapons", [180230992]="Carter Addon Pack: Vehicles Pack1", [180231308]="Carter Addon Pack: Vehicles Pack2", 
	[180232188]="Carter Addon Pack: Weapons",[872872435]="Carter Addon Pack: Extras"
}

local ws_addonlist = {}
local cap_installed = false;

for _,v in pairs(engine.GetAddons()) do
	if (v.mounted) then
		ws_addonlist[tonumber(v.wsid)] = v.title;
		if (not cap_installed and StarGate.CAP_WS_ADDONS[tonumber(v.wsid)]) then cap_installed = true end
	end
end

local ws_cache = false;
local function Workshop_res_Check()
	if (ws_cache) then return ws_cache; end
	local tmp = StarGate.CAP_WS_ADDONS;
	local ret = {}; -- damn, if use table.remove directly in loop, it work incorrect.
	for k,v in pairs(tmp) do
		if not ws_addonlist[k] then ret[k] = v; end
	end
	ws_cache = ret;
	return ret;
end

local oldfiles = {};

for k,v in pairs(file.Find("addons/carter_addon_pack_*.gma","GAME")) do
	table.insert(oldfiles,v);
	-- if (not oldfpath) then oldfpath = util.RelativePathToFull("addons/"..v):Replace(v,""); end
	-- sadly, but this function was removed
end
for k,v in pairs(file.Find("addons/stargate_carter_addon_pack_175394472.gma","GAME")) do
	table.insert(oldfiles,v);
end 
/* for upcoming update 
for k,v in pairs(file.Find("addons/cap_*.gma","GAME")) do
	table.insert(oldfiles,v);
end
*/

if (CLIENT) then

	local function CAP_dxlevel()
		if (StarGate.InstalledOnClient()) then
			local UpdateFrame = vgui.Create("DFrame");
			UpdateFrame:SetPos(ScrW()-580, 240);
			UpdateFrame:SetSize(500,230);
			UpdateFrame:SetTitle(SGLanguage.GetMessage("stargate_dxlevel_01"));
			UpdateFrame:SetVisible(true);
			UpdateFrame:SetDraggable(true);
			UpdateFrame:ShowCloseButton(true);
			UpdateFrame:SetBackgroundBlur(false);
			UpdateFrame:MakePopup();
			UpdateFrame.Paint = function()

				// Thanks Overv, http://www.facepunch.com/threads/1041686-What-are-you-working-on-V4-John-Lua-Edition
				local matBlurScreen = Material( "pp/blurscreen" )

				// Background
				surface.SetMaterial( matBlurScreen )
				surface.SetDrawColor( 255, 255, 255, 255 )

				matBlurScreen:SetFloat( "$blur", 5 )
				render.UpdateScreenEffectTexture()

				surface.DrawTexturedRect( -ScrW()/10, -ScrH()/10, ScrW(), ScrH() )

				surface.SetDrawColor( 100, 100, 100, 150 )
				surface.DrawRect( 0, 0, ScrW(), ScrH() )

				// Border
				surface.SetDrawColor( 50, 50, 50, 255 )
				surface.DrawOutlinedRect( 0, 0, UpdateFrame:GetWide(), UpdateFrame:GetTall() )

				draw.DrawText(SGLanguage.GetMessage("stargate_dxlevel_02"), "ScoreboardText", 250, 25, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER);
				draw.DrawText(SGLanguage.GetMessage("stargate_dxlevel_03"), "ScoreboardText", 10, 80, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT);
				draw.DrawText(SGLanguage.GetMessage("stargate_dxlevel_04"), "ScoreboardText", 250, 160, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER);
			end;

			local close = vgui.Create("DButton", UpdateFrame);
			close:SetText(SGLanguage.GetMessage("stargate_updater_04"));
			close:SetPos(380, 195);
			close:SetSize(80, 25);
			close.DoClick = function (btn)
				UpdateFrame:Close();
			end


		end
	end
	concommand.Add("CAP_dxlevel",CAP_dxlevel)

	if (GetConVar("mat_dxlevel"):GetInt()<90) then
		Msg("-------\nWarning: your gmod running under DirectX 8.1 or lower.\nThis will cause compatibility problems with Carter Addon Pack.\nList of problems:\n* No kawoosh when stargate opens.\n* White boxes on huds.\n* Universe stargate have always all glyphs enabled.\n* Some other glitches.\nPlease Run gmod under dxlevel 90 or higher (95 recommended).\nThis can be changed with convar mat_dxlevel.\n-------\n")
	end

	local function CAP_ShowError(tbl)
		local text = "";
		for k,v in pairs(tbl) do
			if (k!=1) then
				text = text.."<br><br>";
			end
			if (type(v)=="table") then
				local adds = "";
				for t,a in pairs(v[2]) do
					if (v[1]=="sg_err_09") then                            
						adds = adds.."<br><a href='http://steamcommunity.com/sharedfiles/filedetails/?id="..t.."'>"..a:Replace("Carter Addon Pack:","CAP:").."</a>";
					else
						adds = adds.."<br>"..a;
					end
				end
				if (v[1]=="sg_err_13" and v[3]) then
					text = text.."<b>"..SGLanguage.GetMessage("sg_err_n").." #"..v[1]:gsub("[^0-9]","").."</b><br>"..SGLanguage.GetMessage(v[1],v[3],adds);
				else
					text = text.."<b>"..SGLanguage.GetMessage("sg_err_n").." #"..v[1]:gsub("[^0-9]","").."</b><br>"..SGLanguage.GetMessage(v[1],adds);
				end
			else
				text = text.."<b>"..SGLanguage.GetMessage("sg_err_n").." #"..v:gsub("[^0-9]","").."</b><br>"..SGLanguage.GetMessage(v);
			end
		end

		surface.PlaySound( "buttons/button2.wav" );

		--local Width, Height = ScrW() * 0.8, ScrH() * 0.8 --Half screen size

		StarGate.ShowCapMotd(SGLanguage.GetMessage("sg_err_title"),"<h2>"..SGLanguage.GetMessage("sg_err_html_t").."</h2>"..text)

	end

	net.Receive( "CAP_ERROR", function( length )
		local tbl = net.ReadTable();
		if (table.Count(tbl)==0) then return end
		CAP_ShowError(tbl);
	end)

	local function CAP_DebugError(ply,cmd,args)
		local tbl = {};
		local err = 0;
		if (args[1]) then err = math.Clamp(tonumber(args[1]),0,14); end
		if (err>0) then
			if (err<10) then err = "0"..err end
			if (err==13) then
				table.insert(tbl,{"sg_err_"..err,{"_FILE_1_","_FILE_2_","_FILE_3_","_FILE_X_"},"_SYSTEM_PATH_"});
			elseif (err=="09") then
				table.insert(tbl,{"sg_err_"..err,{"_ADDON_1_","_ADDON_2_","_ADDON_3_","_ADDON_X_"}});
			else
				table.insert(tbl,"sg_err_"..err);
			end
			CAP_ShowError(tbl);
		else
			for i=1,14 do
				local err = i;
				if (err<10) then err = "0"..err end
				if (err==13) then
					table.insert(tbl,{"sg_err_"..err,{"_FILE_1_","_FILE_2_","_FILE_3_","_FILE_X_"},"_SYSTEM_PATH_"});
				elseif (err=="09") then
					table.insert(tbl,{"sg_err_"..err,{"_ADDON_1_","_ADDON_2_","_ADDON_3_","_ADDON_X_"}});
				else
					table.insert(tbl,"sg_err_"..err);
				end
			end
			CAP_ShowError(tbl);
		end
	end
	concommand.Add("CAP_debugerror",CAP_DebugError)

end

-- just to be sure
if (GetAddonList!=nil and (table.HasValue( GetAddonList(true), "before_cap_sg_groups" ) or table.HasValue( GetAddonList(true), "z_cap_sg_groups" ))) then
	status = "Error";
	MsgN("Status: "..status)
	table.insert(StarGate_Group.ErrorMSG, {"The Stargate Group System has been found on your system. Please remove it.","01"});
	table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_01");
	MsgN("-------");
	MsgN("Error #01\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
end

local function Workshop_res_Installed()
	local adds = Workshop_res_Check();
	if (table.Count(adds)==0) then
		return true;
	end
	return false;
end

--[[if (Workshop_res_Installed() and not table.HasValue( addonlist, "Carter Addon Pack - Resources" ) and not table.HasValue( addonlist, "Carter Addon Pack - Fonts" )) then
	local files_check = {"resource/fonts/anquietas.ttf","resource/fonts/quiver.ttf","resource/fonts/stargate_atlantis.ttf",
	"resource/fonts/stargate_concept.ttf","resource/fonts/stargate_sg1.ttf","resource/fonts/stargate_universe.ttf"}
	local manual = true;
	for k,v in pairs(files_check) do
		if (not file.Exists(v,"GAME")) then
			manual = false;
		end
	end
	if (manual) then
		MsgN("---");
		MsgN("Warning! The custom fonts installed manually and can not work!");
		MsgN("---");
	else
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"The custom fonts are not installed, please follow the instructions in the motd to install the custom fonts.","11"});
		table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_11");
		MsgN("-------");
		MsgN("Error #11\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	end
end  ]]
--[[if (not StarGate.WorkShop) then
	if (cap_installed and not Workshop_res_Installed()) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"Please subscribe to all workshop addons to make CAP functional.","09"});
		table.insert(StarGate_Group.ErrorMSG_HTML, {"sg_err_09",Workshop_res_Check()});
		MsgN("-------");
		MsgN("Error #09\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	elseif (Workshop_res_Installed() and table.HasValue( addonlist, "Carter Addon Pack - Resources" )) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"The Github version of the Resources have been detected on your system and might conflict with the workshop version you've subscribed to.\\nPlease remove one of both.","10"});
		table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_10");
		MsgN("-------");
		MsgN("Error #10\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	elseif (not Workshop_res_Installed() and (not table.HasValue( addonlist, "Carter Addon Pack" ) or not table.HasValue( addonlist, "Carter Addon Pack - Resources" ))) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"Carter Addon Pack is incorrectly installed.\\nMake sure you downloaded cap and cap_resources folders and placed the folders correctly.","02"});
		table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_02");
		MsgN("-------");
		MsgN("Error #02\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	elseif (not cap_ver or cap_ver==0 or cap_ver<493 and (game.SinglePlayer() or SERVER)) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"The addon version file is corrupt.\\nPlease remove and redownload the file cap/lua/cap_ver.lua.","03"});
		table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_03");
		MsgN("-------");
		MsgN("Error #03\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	end if (ws_addonlist[175394472]) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"The Git version of the Code pack from Carter Addon Pack is installed.\\nPlease remove this to prevent possible problems.\\nOr remove the workshop version.","04"});
		table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_04");
		MsgN("-------");
		MsgN("Error #04\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	end if (table.HasValue( addonlist, "Carter Addon Pack - Resources" ) and cap_res<cap_res_req) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"Cap_resources folder is outdated!\\nPlease update it.","12"});
		table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_12");
		MsgN("-------");
		MsgN("Error #12\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	end
else
	if (cap_installed and not Workshop_res_Installed()) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"Please subscribe to all workshop addons to make CAP functional.","09"});
		table.insert(StarGate_Group.ErrorMSG_HTML, {"sg_err_09",Workshop_res_Check()});
		MsgN("-------");
		MsgN("Error #09\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	end	if (ws_addonlist[175394472] and (not cap_installed and not table.HasValue( addonlist, "Carter Addon Pack - Resources" ))) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"Please download all the resources from steam workshop collection or from github.","05"});
		table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_05");
		MsgN("-------");
		MsgN("Error #05\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	end if (not cap_installed and table.HasValue( addonlist, "Carter Addon Pack - Resources" ) and cap_res<cap_res_req) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"Cap_resources folder is outdated!\\nPlease update it.","12"});
		table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_12");
		MsgN("-------");
		MsgN("Error #12\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	end if (Workshop_res_Installed() and table.HasValue( addonlist, "Carter Addon Pack - Resources" )) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"The Github version of the Resources have been detected on your system and might conflict with the workshop version you've subscribed to.\\nPlease remove one of both.","10"});
		table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_10");
		MsgN("-------");
		MsgN("Error #10\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	end if (ws_addonlist[175394472] and table.HasValue( addonlist, "Carter Addon Pack" )) then
		if (status != "Error") then
			status = "Error";
			MsgN("Status: "..status)
		end
		table.insert(StarGate_Group.ErrorMSG, {"The Git version of the Code pack from Carter Addon Pack is installed.\\nPlease remove this to prevent possible problems.\\nOr remove the workshop version.","04"});
		table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_04");
		MsgN("-------");
		MsgN("Error #04\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
	end
end	]]

if (table.getn(oldfiles)>0) then
	if (status != "Error") then
		status = "Error";
		MsgN("Status: "..status)
	end
	table.insert(StarGate_Group.ErrorMSG, {"Old workshop files found, please remove it.","13"});
	table.insert(StarGate_Group.ErrorMSG_HTML, {"sg_err_13",oldfiles,"C:/Program Files (x86)/Steam/SteamApps/common/GarrysMod/garrysmod/addons"});
	MsgN("-------");
	MsgN("Error #13\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
end

if (VERSION<201023) then
	if (status != "Error") then
		status = "Error";                 
		MsgN("Status: "..status)
	end
	table.insert(StarGate_Group.ErrorMSG, {"Your GMod is out of date, please update it.","06"});
	table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_06");
	MsgN("-------");
	MsgN("Error #06\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
end if (not WireAddon and not file.Exists("weapons/gmod_tool/stools/wire_adv.lua","LUA")) then
	if (status != "Error") then
		status = "Error";
		MsgN("Status: "..status)
	end
	table.insert(StarGate_Group.ErrorMSG, {"Wiremod has not been found or is incorrectly installed.","07"});
	table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_07");
	MsgN("-------");
	MsgN("Error #07\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
elseif (file.Exists("weapons/gmod_tool/stools/wire_adv.lua","LUA") and not ws_addonlist[160250458] and not table.HasValue(js_addonlist,"Wiremod")) then
	if (status != "Error") then
		status = "Error";
		MsgN("Status: "..status)
	end
	table.insert(StarGate_Group.ErrorMSG, {"Your Wiremod is outdated, please update it.\\nYou're using an older repository of the Wiremod SVN.\\nWe suggest you to switch to the newer github or Steam Workshop version of Wiremod.","14"});
	table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_14");
	MsgN("-------");
	MsgN("Error #14\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
end /*if (string.find(util.RelativePathToFull("gameinfo.txt"),"garrysmodbeta")) then
	if (status != "Error") then
		status = "Error";
		MsgN("Status: "..status)
	end
	table.insert(StarGate_Group.ErrorMSG, {"Sorry, Garry's Mod 13 beta isn't supported anymore.\\nPlease make use of the normal Garry's Mod that already came out of the beta.","08"});
	table.insert(StarGate_Group.ErrorMSG_HTML, "sg_err_08");
	MsgN("-------");
	MsgN("Error #08\n"..StarGate_Group.ErrorMSG[table.Count(StarGate_Group.ErrorMSG)][1]:Replace("\\n","\n"));
end  */
if (status != "Error") then
	MsgN("Status: "..status)
else
	StarGate_Group.Error = true;
end
Msg("--------------------------\n")

if (SERVER) then
	net.Receive("CL_CAP_ERROR",function(len,ply)
		if (IsValid(ply) and ply:IsPlayer()) then
			local tbl = {net.ReadTable(),net.ReadTable()};
			StarGate_Group.ShowError(ply,tbl)
		end
	end)
end

function StarGate_Group.ShowError(ply,cl)
	local ErrorMSG = StarGate_Group.ErrorMSG;
	local ErrorMSG_HTML = StarGate_Group.ErrorMSG_HTML;
	if (cl!=nil) then
		ErrorMSG = cl[1];
		ErrorMSG_HTML = cl[2];
	end
	for k,v in pairs(ErrorMSG) do
		if (k==1) then
			MsgN("================================");
			MsgN("Carter Addon Pack Error:"); MsgN("-------");
			if (IsValid(ply)) then
				MsgN("Player: "..ply:Name());
				ply:SendLua( "MsgN(\"================================\")");
				ply:SendLua("MsgN(\"Carter Addon Pack Error:\")"); ply:SendLua("MsgN(\"-------\")");
			end
		else
			MsgN("-------");
			if (IsValid(ply)) then
				ply:SendLua("MsgN(\"-------\")");
			end
		end
		Msg("Error #"..v[2].."\n"..v[1]:Replace("\\n","\n").."\n");
		if (IsValid(ply)) then
			ply:SendLua("Msg(\"Error #"..v[2].."\\n"..v[1].."\\n\")");
		end
	end
	MsgN("================================");
	if (IsValid(ply)) then
		ply:SendLua("MsgN(\"================================\")");
		--ply:SendLua("GAMEMODE:AddNotify(\"Carter Addon Pack: Error, check your console\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		net.Start("CAP_ERROR");
		net.WriteTable(ErrorMSG_HTML);
		net.Send(ply);
	end
end

if (status == "Error") then
	MsgN("Carter Addon Pack: Loading error.");
elseif SERVER then
	/*-- Add server tag
	local sv_tags = GetConVarString("sv_tags")
	if sv_tags == nil then
		RunConsoleCommand("sv_tags", "StargateCAP"..cap_ver)
	elseif not sv_tags:find("StargateCAP") then
		RunConsoleCommand("sv_tags", "StargateCAP"..cap_ver.."," .. sv_tags)
	end
	timer.Create("CapSystemTags",3,0,function()
		local sv_tags = GetConVarString("sv_tags")
		if sv_tags == nil then
			RunConsoleCommand("sv_tags", "StargateCAP"..cap_ver)
		elseif not sv_tags:find("StargateCAP") then
			RunConsoleCommand("sv_tags", "StargateCAP"..cap_ver.."," .. sv_tags)
		end
	end)   */
end
