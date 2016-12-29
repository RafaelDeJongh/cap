/*
	Stargate Lib for GarrysMod10
	Copyright (C) 2007-2009  aVoN

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
--[[
	Stargate Lib for GarrysMod10
	Copyright (C) 2010 Madman07
]]--

--################# Header ###################
StarGate.HTTP = {
	FORUM = "http://steamcommunity.com/sharedfiles/filedetails/discussions/180077636",
	BUGS = "https://github.com/RafaelDeJongh/cap/issues",
	VER = "https://raw.github.com/RafaelDeJongh/cap/master/lua/cap_ver.lua",
	SITE = "https://github.com/RafaelDeJongh/cap",
	NEWS = "https://github.com/RafaelDeJongh/cap/commits/master",
	WIKI = "https://github.com/RafaelDeJongh/cap/wiki",
	--MULTI = "http://sg-carterpack.com/forums/forum/support/multi-language-support/", -- this is used by default for all languages, if not defined another url in language file.
	FACEPUNCH = "http://www.facepunch.com/threads/1250181",
	CREDITS = "https://github.com/RafaelDeJongh/cap/wiki#credits",
	DONATE = "http://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=rafael_boba_fett%40msn%2ecom&lc=US&item_name=Carter%20Addon%20Pack&no_note=0&currency_code=EUR&bn=PP&2dDonationsBF&3adonate&2epng&3aNonHostedGuest"
};
StarGate.LATEST_VERSION = 0;
StarGate.CURRENT_VERSION = 0;

--################# CODE ###################

--#########################################
--						Internet communication
--#########################################

-- compare two digit versions @AlexALX
function StarGate.CompareVersion(ver, verc, add)
	local v1t = string.Explode(".",ver)
	local v2t = string.Explode(".",verc)
	if (add!=nil) then v2t[1] = v2t[1]-add; end
	if v2t[2]==nil then
		return tonumber(ver)>tonumber(v2t[1]);
	elseif v1t[2]==nil then
		return tonumber(v1t[1])>tonumber(verc);
	end
	if tonumber(v2t[1])<tonumber(v1t[1]) or tonumber(v2t[1])==tonumber(v1t[1]) and tonumber(v1t[2])>tonumber(v2t[2]) then
		return true;
	end
	return false;
end

-- Do we have internet?
local InternetCheck = CreateClientConVar("cl_has_internet",0,true,false); -- Some percentage crashes by this online help check. Now we check this if they crash once during this check, this check will be disabled permanently for them
StarGate.HasInternet = false;
function StarGate.Hook.GetInternetStatus(_,key)
    string.__todivide(key);
	if(key ~= "+menu") then return end;
	hook.Remove("PlayerBindPress","StarGate.Hook.GetInternetStatus");

	StarGate.CURRENT_VERSION = StarGate.CapVer;

	local installed = StarGate.InstalledOnClient();

	-- displaying warning message when user have dxlevel 81 or lower
	if (installed and GetConVar("mat_dxlevel"):GetInt()<90) then
		LocalPlayer():ConCommand("CAP_dxlevel");
	end

	if (installed and StarGate_Group.Error and not game.SinglePlayer()) then
		net.Start("CL_CAP_ERROR");
		net.WriteTable(StarGate_Group.ErrorMSG);
		net.WriteTable(StarGate_Group.ErrorMSG_HTML);
		net.SendToServer();
		timer.Create("CL_CAP_ERROR",1200.0,0,function()
			net.Start("CL_CAP_ERROR");
			net.WriteTable(StarGate_Group.ErrorMSG);
			net.WriteTable(StarGate_Group.ErrorMSG_HTML);
			net.SendToServer();
		end);
	end

	local mode = InternetCheck:GetString();
	if(mode == "1") then -- Manual override
		StarGate.HasInternet = true;
		http.Fetch(StarGate.HTTP.VER,
			function(html,size)
				local version = StarGate.ParseVersion(html);
				if(version) then
					StarGate.LATEST_VERSION = version;

					if (installed and (not StarGate.WorkShop or StarGate.CompareVersion(StarGate.LATEST_VERSION,StarGate.CURRENT_VERSION,-8)) and StarGate.CompareVersion(StarGate.LATEST_VERSION,StarGate.CURRENT_VERSION)) then
						LocalPlayer():ConCommand("CAP_Outdated");
					end
				end
			end
		);
	elseif(mode ~= "false") then -- Not checked yet
		RunConsoleCommand("cl_has_internet","false");

		-- Do we have the latest version of SG installed?
		http.Fetch(StarGate.HTTP.VER,
			function(html,size)
				local version = StarGate.ParseVersion(html);
				if(version) then
					StarGate.HasInternet = true;
					StarGate.LATEST_VERSION = version;

					if (installed and not StarGate.WorkShop and StarGate.CompareVersion(StarGate.LATEST_VERSION,StarGate.CURRENT_VERSION)) then
						LocalPlayer():ConCommand("CAP_Outdated");
					end
				end
				-- Delete the "http-crash" file, but in here, to be sure, it has been deleted AFTER the "online-check" has been performed (fights delay/ping the HTTPRequest needs)
				RunConsoleCommand("cl_has_internet",0);
			end
		);
	end
end
hook.Add("PlayerBindPress","StarGate.Hook.GetInternetStatus",StarGate.Hook.GetInternetStatus);

--#########################################
--						Config Part
--#########################################

--################# Getting synced data from the server @aVoN
function StarGate.CFG.GetSYNC(len)
	local name = net.ReadString();
	-- fix for reload
	if (name=="_CFG_RELOAD_") then
		if (StarGate.CFG.Get and type(StarGate.CFG.Get)=="function") then
			local copy = StarGate.CFG.Get;
			StarGate.CFG = {};
			StarGate.CFG.Get = copy;
		end
		return
	end
	StarGate.CFG[name] = {};
	local count = net.ReadUInt(8);
	for i=1,count do
		local k = net.ReadString();
		local t = net.ReadUInt(8); -- What type are we?
		if(t == 0) then
			StarGate.CFG[name][k] = util.tobool(net.ReadBit());
		elseif(t == 1) then
			StarGate.CFG[name][k] = net.ReadString();
		elseif(t == 2) then
			StarGate.CFG[name][k] = net.ReadDouble();
		elseif(t == 3) then
			StarGate.CFG[name][k] = net.ReadInt(8);
		elseif(t == 4) then
			StarGate.CFG[name][k] = net.ReadInt(16);
		elseif(t == 5) then
			StarGate.CFG[name][k] = net.ReadInt(32);
		end
	end
end
net.Receive("StarGate_CFG",StarGate.CFG.GetSYNC);

--################# Adds LifeSupport,ResourceDistribution and WireSupport to an entity when getting called - HAS TO BE CALLED BEFORE ANY OTHERTHING IS DONE IN A SENT (like includes) @aVoN
-- My suggestion is to put this on the really top of the shared.lua
function StarGate.LifeSupportAndWire(ENT)
	-- Currently a dummy, but maybe I need this sometime later?
end

--#########################################
--						Material Helpers
--#########################################

--################# Creates a new Material according to a given VMT String @aVoN
-- This is necessary, because sometimes you need to edit a material in an effect which results into conflicts with other scripts using that material too
function StarGate.MaterialFromVMT(name,VMT)
	if(type(VMT) ~= "string" or type(name) ~= "string") then return Material(" ") end; -- Return a dummy Material
	local t = util.KeyValuesToTable("\"material\"{"..VMT.."}");
	for shader,params in pairs(t) do
		return CreateMaterial(name,shader,params);
	end
end

--################# Creates a copy of an existing Material and returns it @aVoN
function StarGate.MaterialCopy(name,filename)
	if(type(filename) ~= "string" or type(name) ~= "string") then return Material(" ") end; -- Return a dummy Material
	filename = "materials/"..filename:Trim():gsub(".vmt$","")..".vmt";
	return StarGate.MaterialFromVMT(name,file.Read(filename,"GAME"));
end

StarGate.GroupSystem = StarGate.GroupSystem or 1;
-- Get stargate system type
net.Receive("stargate_systemtype",function(len)
   	StarGate.GroupSystem = net.ReadBit();
end);

StarGate.InstalledOnCl = nil;
function StarGate.InstalledOnClient()
	if (StarGate.InstalledOnCl!=nil) then return StarGate.InstalledOnCl; end -- cache
	StarGate.InstalledOnCl = false;
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
	local ws_addonlist = {}
	local cap_installed = false;
	for _,v in pairs(engine.GetAddons()) do
		if (v.mounted) then
			table.insert(ws_addonlist, v.title);
			if (table.HasValue(StarGate.CAP_WS_ADDONS or {}, v.title)) then cap_installed = true end
		end
	end
	if (table.HasValue(ws_addonlist,"Stargate Carter Addon Pack") or cap_installed) then StarGate.InstalledOnCl = true; return true end
	if (table.HasValue(addonlist,"Carter Addon Pack") or table.HasValue(addonlist,"Carter Addon Pack - Resources")) then StarGate.InstalledOnCl = true; return true end
	return false;
end

function StarGate.ShowCapMotd(title,text)
	local TACFrame = vgui.Create("DFrame");
	TACFrame:SetPos(50, 50);
	TACFrame:SetSize(ScrW()-100,ScrH()-100);
	--TACFrame:SetSize(Width, Height);
	TACFrame:SetTitle(title);
	TACFrame:SetVisible(true);
	TACFrame:SetDraggable(false);
	TACFrame:ShowCloseButton(true);
	TACFrame:SetBackgroundBlur(false);
	TACFrame:MakePopup();
	--TACFrame:Center();
	TACFrame.Paint = function()

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
		surface.DrawOutlinedRect( 0, 0, TACFrame:GetWide(), TACFrame:GetTall() )

		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawRect( 20, 35, TACFrame:GetWide() - 40, TACFrame:GetTall() - 55 )

	end

	local MOTDHTMLFrame = vgui.Create( "HTML", TACFrame )
	MOTDHTMLFrame:SetPos( 25, 40 )
	MOTDHTMLFrame:SetSize( TACFrame:GetWide() - 50, TACFrame:GetTall() - 65 )
    -- background-image: url(http://sg-carterpack.com/wp-content/uploads/2013/09/bg1.jpg);
	local html = [[<html>
	<head>
	<style type='text/css'>
		body {
			background-color: #171717;
			background-repeat: repeat;
			font-family: Verdana, Geneva, sans-serif;
			color: #FFF;
		}
		a:link {
			text-decoration: underline;
			color: #e5e5e5;
		}
		a:visited {
			text-decoration: underline;
			color: #e5e5e5;
		}
		a:active {
			text-decoration: underline;
		}
		a:hover {
			text-decoration: underline;
			color: #FFF;
		}
		#nav {
			padding: 0px;
			margin: 0px;
			text-align: center;
		}

		#nav li {
			display: inline-block;
			list-style-type: none;

		}
	</style>
	</head>
	<body><hr><ul id="nav">
		<li><a href="https://github.com/RafaelDeJongh/cap">Home</a> |</li>
	    <li><a href="https://github.com/RafaelDeJongh/cap/commits/master">News</a> |</li>
	    <li><a href="https://github.com/RafaelDeJongh/cap/wiki">Wiki</a> |</li>
	    <li><a href="http://steamcommunity.com/sharedfiles/filedetails/discussions/180077636">Support</a></li>
	</ul><hr>]]..text.."</body></html>";

	MOTDHTMLFrame:SetHTML(html)
end

net.Receive( "CAP_GATESPAWNER", function( length )
	local map = net.ReadString();
	local path = net.ReadString();

	StarGate.ShowCapMotd(SGLanguage.GetMessage("sg_gtsp_title"),SGLanguage.GetMessage("sg_stsp_text",map,map,path))
end)

--################
-- cl_convars.lua
--################

--################################ DON'T EDIT THIS FILE YOU CAN MAKE CHANGES IN THE GAME!!!!!!!!!!!!!

-- Defines
CreateClientConVar("cl_stargate_visualsship",1,true,false); -- Global - Turns on or off all visuals which may suck FPS. Turning this to off will turn of all. If it's on, the one below will be used
CreateClientConVar("cl_stargate_visualsmisc",1,true,false); -- Global - Turns on or off all visuals which may suck FPS. Turning this to off will turn of all. If it's on, the one below will be used
CreateClientConVar("cl_stargate_visualsweapon",1,true,false); -- Global - Turns on or off all visuals which may suck FPS. Turning this to off will turn of all. If it's on, the one below will be used

CreateClientConVar("cl_stargate_dynlights",0,true,false);
CreateClientConVar("cl_stargate_un_dynlights",0,true,false);
CreateClientConVar("cl_stargate_ripple",0,true,false);
CreateClientConVar("cl_stargate_kenter",1,true,false);
CreateClientConVar("cl_stargate_effects",1,true,false);
CreateClientConVar("cl_kawoosh_material",1,true,false);

CreateClientConVar("cl_draw_huds",1,true,false);
CreateClientConVar("cl_dhd_letters",1,true,false);

CreateClientConVar("cl_shield_hitradius",1,true,false);
CreateClientConVar("cl_shield_hiteffect",1,true,false);
CreateClientConVar("cl_shield_dynlights",0,true,false);
CreateClientConVar("cl_shield_bubble",1,true,false);
CreateClientConVar("cl_harvester_dynlights",1,true,false);
CreateClientConVar("cl_cloaking_shader",1,true,false);
CreateClientConVar("cl_cloaking_hitshader",1,true,false);
CreateClientConVar("cl_supergate_dynlights",0,true,false);
CreateClientConVar("cl_applecore_light",1,true,false);
CreateClientConVar("cl_applecore_smoke",1,true,false);
CreateClientConVar("cl_shieldcore_refract",1,true,false);

CreateClientConVar("cl_jumper_dynlights",1,true,false);
CreateClientConVar("cl_jumper_heatwave",1,true,false);
CreateClientConVar("cl_jumper_sprites",1,true,false);
CreateClientConVar("cl_f302_heatwave",1,true,false);
CreateClientConVar("cl_f302_sprites",1,true,false);
CreateClientConVar("cl_shuttle_heatwave",1,true,false);
CreateClientConVar("cl_shuttle_sprites",1,true,false);
CreateClientConVar("cl_dart_heatwave",1,true,false);
CreateClientConVar("cl_chair_dynlights",1,true,false);

CreateClientConVar("cl_zat_dynlights",1,true,false);
CreateClientConVar("cl_zat_hiteffect",1,true,false);
CreateClientConVar("cl_zat_dissolveeffect",1,true,false);
CreateClientConVar("cl_staff_dynlights",0,true,false);
CreateClientConVar("cl_staff_dynlights_flight",0,true,false);
CreateClientConVar("cl_staff_scorch",1,true,false);
CreateClientConVar("cl_staff_smoke",1,true,false);
CreateClientConVar("cl_drone_glow",1,true,false);
CreateClientConVar("cl_gate_nuke_sunbeams",1,true,false);
CreateClientConVar("cl_gate_nuke_rings",1,true,false);
CreateClientConVar("cl_gate_nuke_shieldrings",1,true,false);
CreateClientConVar("cl_gate_nuke_dynlights",0,true,false);
CreateClientConVar("cl_gate_nuke_plasma",1,true,false);
CreateClientConVar("cl_overloader_refract",1,true,false);
CreateClientConVar("cl_overloader_particle",1,true,false);
CreateClientConVar("cl_overloader_dynlights",0,true,false);
CreateClientConVar("cl_asuran_laser",1,true,false);
CreateClientConVar("cl_asuran_dynlights",0,true,false);
CreateClientConVar("cl_dakara_rings",1,true,false);
CreateClientConVar("cl_dakara_refract",1,true,false);