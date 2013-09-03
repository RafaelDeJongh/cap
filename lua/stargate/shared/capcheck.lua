/*
	###################################
	StarGate with Groups System
	Created by AlexALX (c) 2011
	###################################
*/
StarGate_Group = StarGate_Group or {};

local addonlist = {}

for _,v in pairs(GetAddonList(true)) do
	for k,c in pairs(GetAddonInfo(v)) do
		if (k == "Name") then
			table.insert(addonlist, c);
		end
	end
end

local cap_ver = 0;
if (not StarGate.WorkShop) then
	local cap = file.Read("addons/cap/ver.txt","GAME")
	if cap then cap_ver = tonumber(cap) end
end
local status = "Loaded";
StarGate_Group.Error = false;
StarGate_Group.ErrorMSG = {};

if (CLIENT) then

	local function CAP_dxlevel()
		if (StarGate.InstalledOnClient()) then
			local UpdateFrame = vgui.Create("DFrame");
			UpdateFrame:SetPos(ScrW()-580, 240);
			UpdateFrame:SetSize(500,230);
			UpdateFrame:SetTitle(Language.GetMessage("stargate_dxlevel_01"));
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

				draw.DrawText(Language.GetMessage("stargate_dxlevel_02"), "ScoreboardText", 250, 25, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER);
				draw.DrawText(Language.GetMessage("stargate_dxlevel_03"), "ScoreboardText", 10, 80, Color(255, 255, 255, 255),TEXT_ALIGN_LEFT);
				draw.DrawText(Language.GetMessage("stargate_dxlevel_04"), "ScoreboardText", 250, 160, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER);
			end;

			local close = vgui.Create("DButton", UpdateFrame);
			close:SetText(Language.GetMessage("stargate_updater_04"));
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
end

-- just to be sure
if (table.HasValue( GetAddonList(true), "before_cap_sg_groups" ) or table.HasValue( GetAddonList(true), "z_cap_sg_groups" )) then
	status = "Error";
	Msg("Status: "..status.."\n")
	Msg("Error: Stargate with Group System found, please remove it.\nThis addon included in Carter Addon Pack and should be removed.\n")
	table.insert(StarGate_Group.ErrorMSG, "Stargate with Group System found, please remove it.\\nThis addon included in Carter Addon Pack and should be removed.");
end

local ws_addonlist = {}

for _,v in pairs(engine.GetAddons()) do
	if (v.mounted) then table.insert(ws_addonlist, v.title); end
end

if (not StarGate.WorkShop) then
	if (not table.HasValue( GetAddonList(true), "cap" ) or (not table.HasValue( GetAddonList(true), "cap_resources" ) and not table.HasValue( GetAddonList(true), "cap resources" ) and not table.HasValue( GetAddonList(true), "cap_resources-master") )) then
		if (status != "Error") then
			status = "Error";
			Msg("Status: "..status.."\n")
		end
		MsgN("Error: Carter Addon Pack is wrong installed.\nPlease make sure you have downloaded cap and cap_resources folders and named it correctly.")
		table.insert(StarGate_Group.ErrorMSG, "Carter Addon Pack is wrong installed.\\nPlease make sure you have downloaded cap and cap_resources folders and named it correctly.");
	elseif (not cap_ver or cap_ver==0 or cap_ver<402 and (game.SinglePlayer() or SERVER)) then
		status = "Error";
		Msg("Status: "..status.."\n")
		MsgN("Error: The file of addon version is corrupt.\nPlease remove and redownload file: cap/ver.txt.")
		table.insert(StarGate_Group.ErrorMSG, "The file of addon version is corrupt.\\nPlease remove and redownload file cap/ver.txt.");
	end if (table.HasValue( ws_addonlist, "Stargate Carter Addon Pack" )) then
		if (status != "Error") then
			status = "Error";
			Msg("Status: "..status.."\n")
		end
		MsgN("Error: Workshop version of Carter Addon Pack installed.\nPlease remove it for prevent possible problems.\nOr remove git/svn version.")
		table.insert(StarGate_Group.ErrorMSG, "Error: Workshop version of Carter Addon Pack installed.\\nPlease remove it for prevent possible problems.\\nOr remove git/svn version.");
	end
else
	if (table.HasValue( ws_addonlist, "Stargate Carter Addon Pack" ) and (not table.HasValue( GetAddonList(true), "cap_resources" ) and not table.HasValue( GetAddonList(true), "cap resources" ) and not table.HasValue( GetAddonList(true), "cap_resources-master" ) )) then
		if (status != "Error") then
			status = "Error";
			Msg("Status: "..status.."\n")
		end
		MsgN("Error: Please download CAP resources folder from git/svn.")
		table.insert(StarGate_Group.ErrorMSG, "Error: Please download CAP resources folder from git/svn.");
	end if (table.HasValue( ws_addonlist, "Stargate Carter Addon Pack" ) and table.HasValue( GetAddonList(true), "cap" )) then
		if (status != "Error") then
			status = "Error";
			Msg("Status: "..status.."\n")
		end
		MsgN("Error: Git/svn version of Carter Addon Pack installed.\nPlease remove it for prevent possible problems.\nOr remove workshop version.")
		table.insert(StarGate_Group.ErrorMSG, "Error: Git/svn version of Carter Addon Pack installed.\\nPlease remove it for prevent possible problems.\\nOr remove workshop version.");
	end
end

if (VERSION<159) then
	if (status != "Error") then
		status = "Error";
		Msg("Status: "..status.."\n")
	end
	MsgN("Error: Your GMod is old, please update it.")
	table.insert(StarGate_Group.ErrorMSG, "Your GMod is old, please update it.");
end if (not WireAddon and #file.Find("weapons/gmod_tool/stools/wire.lua","LUA") == 0) then
	if (status != "Error") then
		status = "Error";
		Msg("Status: "..status.."\n")
	end
	MsgN("Error: Wiremod not found or wrong installed.")
	table.insert(StarGate_Group.ErrorMSG, "Wiremod not found or wrong installed.");
end if (string.find(util.RelativePathToFull("gameinfo.txt"),"garrysmodbeta")) then
	if (status != "Error") then
		status = "Error";
		Msg("Status: "..status.."\n")
	end
	MsgN("Error: Sorry, Garry's Mod 13 beta isn't supported anymore.\nPlease use normal Garry's Mod which is already 13.")
	table.insert(StarGate_Group.ErrorMSG, "Error: Sorry, Garry's Mod 13 beta isn't supported anymore.\\nPlease use normal Garry's Mod which is already 13.");
end
if (status != "Error") then
	Msg("Status: "..status.."\n")
else
	StarGate_Group.Error = true;
end
Msg("--------------------------\n")

function StarGate_Group.ShowError(ply)
	for k,v in pairs(StarGate_Group.ErrorMSG) do
		if (k==1) then
			MsgN("================================");
			MsgN("Carter Addon Pack Error:"); MsgN("-------");
			if (IsValid(ply)) then
				ply:SendLua( "MsgN(\"================================\")");
				ply:SendLua("MsgN(\"Carter Addon Pack Error:\")"); ply:SendLua("MsgN(\"-------\")");
			end
		else
			MsgN("-------");
			if (IsValid(ply)) then
				ply:SendLua("MsgN(\"-------\")");
			end
		end
		Msg(v:Replace("\\n","\n").."\n");
		if (IsValid(ply)) then
			ply:SendLua("Msg(\""..v.."\\n\")");
		end
	end
	MsgN("================================");
	if (IsValid(ply)) then
		ply:SendLua("MsgN(\"================================\")");
		ply:SendLua("GAMEMODE:AddNotify(\"Carter Addon Pack: Error, check your console\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
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