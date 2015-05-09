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
--################# The keyboard layout, you see in the stargate/Keybinders #################

--################# Adds the glider's keysettings @aVoN
--[[function StarGate.Hook.AddF302KeysettingsConfig()
	--if(not StarGate.Installed) then return end;
	spawnmenu.AddToolMenuOption("Cap","Keybinders","F302"," F302 Settings","","",StarGate.F302Settings);
end
hook.Add("AddToolMenuTabs","StarGate.Hook.AddF302KeysettingsConfig",StarGate.Hook.AddF302KeysettingsConfig);]]

--################ The controls necessary for keybinding @aVoN
function StarGate.DaedalusSettings(Panel)
	if (StarGate.CFG:Get("cap_disabled_ent","sg_vehicle_daedalus",false)) then
		Panel:Help(SGLanguage.GetMessage("stool_disabled_ship"));
		return
	end
	/*if(StarGate.HasInternet) then
		-- The HELP Button
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/jumper");
		VGUI:SetTopic("Help:  Jumper Config");
		Panel:AddPanel(VGUI);
	end */
	local LAYOUT = "Daedalus";
	-- Use soo much tables at the bottom to keep the sorting-order in exact this order.
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_turn_left"),"LEFT"},
				{SGLanguage.GetMessage("key_turn_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_target"),"MODE"},
				{SGLanguage.GetMessage("key_combat_railgun"),"FIRE"},
				{SGLanguage.GetMessage("key_combat_asgard"),"FIRE2"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_exit"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_rocket_title"),
			Keys = {},
		},
	}
	-- yes i'm lazy :D @ AlexALX
	for i=1,8 do
		KEYS[4].Keys[i] = {SGLanguage.GetMessage("key_rocket").." "..i,tostring(i)};
	end
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

--################ The controls necessary for keybinding @aVoN
function StarGate.DartSettings(Panel)
	if (StarGate.CFG:Get("cap_disabled_ent","sg_vehicle_dart",false)) then
		Panel:Help(SGLanguage.GetMessage("stool_disabled_ship"));
		return
	end
	/*if(StarGate.HasInternet) then
		-- The HELP Button
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/dart");
		VGUI:SetTopic("Help:  Destiny Dart Config");
		Panel:AddPanel(VGUI);
	end */
	local LAYOUT = "Dart";
	-- Use soo much tables at the bottom to keep the sorting-order in exact this order.
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{SGLanguage.GetMessage("key_combat_primary"),"FIRE"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_destruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_harv"),"SUCK"},
				{SGLanguage.GetMessage("key_act_spit"),"SPIT"},
				{SGLanguage.GetMessage("key_act_dhd"),"DHD"},
				{SGLanguage.GetMessage("key_act_exit"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

--################ The controls necessary for keybinding @aVoN
function StarGate.F302Settings(Panel)
	if (StarGate.CFG:Get("cap_disabled_ent","sg_vehicle_f302",false)) then
		Panel:Help(SGLanguage.GetMessage("stool_disabled_ship"));
		return
	end
	/*if(StarGate.HasInternet) then
		-- The HELP Button
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/f302");
		VGUI:SetTopic("Help:  F302 Config");
		Panel:AddPanel(VGUI);
	end */
	local LAYOUT = "F302";
	-- Use soo much tables at the bottom to keep the sorting-order in exact this order.
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_roll_left"),"RL"},
				{SGLanguage.GetMessage("key_roll_right"),"RR"},
				{SGLanguage.GetMessage("key_roll_reset"),"RROLL"},
				{SGLanguage.GetMessage("key_air_brake"),"BRAKE"},
				{SGLanguage.GetMessage("key_move_boost"),"BOOST"},

			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{SGLanguage.GetMessage("key_combat_primary"),"FIRE"},
				{SGLanguage.GetMessage("key_track_missiles"),"TRACK"},
				{SGLanguage.GetMessage("key_combat_toggle"),"CHGATK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_destruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_eject"),"EJECT"},
				{SGLanguage.GetMessage("key_act_wheels"),"WHEELS"},
				{SGLanguage.GetMessage("key_act_flares"),"FLARES"},
				{SGLanguage.GetMessage("key_act_exit"),"EXIT"},
				{SGLanguage.GetMessage("key_act_cockpit"),"COCKPIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
			--	{"Toggle thirdperson view","VIEW"},
				{SGLanguage.GetMessage("key_view_hud"),"HIDE"},
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
				{SGLanguage.GetMessage("key_view_toggle"),"FPV"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

--################ The controls necessary for keybinding @aVoN
function StarGate.GateGliderSettings(Panel)
	if (StarGate.CFG:Get("cap_disabled_ent","sg_vehicle_gate_glider",false)) then
		Panel:Help(SGLanguage.GetMessage("stool_disabled_ship"));
		return
	end
	/*if(StarGate.HasInternet) then
		-- The HELP Button
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/gateglider");
		VGUI:SetTopic("Help:  GateGlider Config");
		Panel:AddPanel(VGUI);
	end */
	local LAYOUT = "GateGlider";
	-- Use soo much tables at the bottom to keep the sorting-order in exact this order.
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_roll_left"),"RL"},
				{SGLanguage.GetMessage("key_roll_right"),"RR"},
				{SGLanguage.GetMessage("key_roll_reset"),"RROLL"},
			},
		},

		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{SGLanguage.GetMessage("key_combat_primary"),"FIRE"},
				--{"Track Drones","TRACK"},
			},
		},

		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_destruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_dhd"),"DHD"},
				{SGLanguage.GetMessage("key_act_exit"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

--################ The controls necessary for keybinding @aVoN
function StarGate.DeathGliderSettings(Panel)
	if (StarGate.CFG:Get("cap_disabled_ent","sg_vehicle_glider",false)) then
		Panel:Help(SGLanguage.GetMessage("stool_disabled_ship"));
		return
	end
	/*if(StarGate.HasInternet) then
		-- The HELP Button
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/deathglider");
		VGUI:SetTopic("Help:  DeathGlider Config");
		Panel:AddPanel(VGUI);
	end */
	local LAYOUT = "DeathGlider";
	-- Use soo much tables at the bottom to keep the sorting-order in exact this order.
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_roll_left"),"RL"},
				{SGLanguage.GetMessage("key_roll_right"),"RR"},
				{SGLanguage.GetMessage("key_roll_reset"),"RROLL"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{SGLanguage.GetMessage("key_combat_primary"),"FIRE"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_destruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_exit"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

--################ The controls necessary for keybinding @aVoN
function StarGate.JumperSettings(Panel)
	if (StarGate.CFG:Get("cap_disabled_ent","puddle_jumper",false)) then
		Panel:Help(SGLanguage.GetMessage("stool_disabled_ship"));
		return
	end
	/*if(StarGate.HasInternet) then
		-- The HELP Button
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/jumper");
		VGUI:SetTopic("Help:  Jumper Config");
		Panel:AddPanel(VGUI);
	end */
	local LAYOUT = "PuddleJumper";
	-- Use soo much tables at the bottom to keep the sorting-order in exact this order.
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_roll_left"),"RL"},
				{SGLanguage.GetMessage("key_roll_right"),"RR"},
				{SGLanguage.GetMessage("key_roll_reset"),"RROLL"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{SGLanguage.GetMessage("key_combat_drones"),"FIRE"},
				{SGLanguage.GetMessage("key_track_drones"),"TRACK"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_destruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_cloak"),"CLOAK"},
				{SGLanguage.GetMessage("key_act_dhd"),"DHD"},
				{SGLanguage.GetMessage("key_act_pods"),"SPD"},
				{SGLanguage.GetMessage("key_act_weapon"),"WEPPODS"},
				{SGLanguage.GetMessage("key_act_door"),"DOOR"},
				{SGLanguage.GetMessage("key_act_light"),"LIGHT"},
				{SGLanguage.GetMessage("key_act_shield"),"SHIELD"},
				{SGLanguage.GetMessage("key_act_standby"),"HOVER"},
				{SGLanguage.GetMessage("key_act_auto"),"AUTOPILOT"},
				{SGLanguage.GetMessage("key_act_exit"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_hud"),"HIDEHUD"},
				{SGLanguage.GetMessage("key_view_lsd"),"HIDELSD"},
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
				{SGLanguage.GetMessage("key_view_toggle"),"VIEW"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

--################ The controls necessary for keybinding @aVoN
function StarGate.MALPSettings(Panel)
	if (StarGate.CFG:Get("cap_disabled_ent","malp",false)) then
		Panel:Help(SGLanguage.GetMessage("stool_disabled_ent"));
		return
	end
	/*if(StarGate.HasInternet) then
		-- The HELP Button
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/malp");
		VGUI:SetTopic("Help:  MALP Config");
		Panel:AddPanel(VGUI);
	end */
	local LAYOUT = "MALP";
	-- Use soo much tables at the bottom to keep the sorting-order in exact this order.
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_turn_left"),"LEFT"},
				{SGLanguage.GetMessage("key_turn_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
			},
		},

		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_cam_view"),"VIEW"},
				{SGLanguage.GetMessage("key_cam_left"),"CAMLEFT"},
				{SGLanguage.GetMessage("key_cam_right"),"CAMRIGHT"},
				{SGLanguage.GetMessage("key_cam_up"),"CAMUP"},
				{SGLanguage.GetMessage("key_cam_down"),"CAMDOWN"},
				{SGLanguage.GetMessage("key_cam_reset"),"RESETCAM"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

--################ The controls necessary for keybinding @aVoN
function StarGate.ShuttleSettings(Panel)
	if (StarGate.CFG:Get("cap_disabled_ent","sg_vehicle_shuttle",false)) then
		Panel:Help(SGLanguage.GetMessage("stool_disabled_ship"));
		return
	end
	/*if(StarGate.HasInternet) then
		-- The HELP Button
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/shuttle");
		VGUI:SetTopic("Help:  Destiny Shuttle Config");
		Panel:AddPanel(VGUI);
	end */
	local LAYOUT = "Shuttle";
	-- Use soo much tables at the bottom to keep the sorting-order in exact this order.
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_combat_title"),
			Keys = {
				{SGLanguage.GetMessage("key_combat_primary"),"FIRE"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_destruct"),"BOOM"},
				{SGLanguage.GetMessage("key_act_shield"),"SHIELD"},
				{SGLanguage.GetMessage("key_act_exit"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end

--################ The controls necessary for keybinding @aVoN
function StarGate.TeltakSettings(Panel)
	if (StarGate.CFG:Get("cap_disabled_ent","sg_vehicle_teltac",false)) then
		Panel:Help(SGLanguage.GetMessage("stool_disabled_ship"));
		return
	end
	/*if(StarGate.HasInternet) then
		-- The HELP Button
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/Teltak");
		VGUI:SetTopic("Help:  Teltak Config");
		Panel:AddPanel(VGUI);
	end */
	local LAYOUT = "Teltac";
	-- Use soo much tables at the bottom to keep the sorting-order in exact this order.
	local KEYS = {
		{
			Name = SGLanguage.GetMessage("key_move_title"),
			Keys = {
				{SGLanguage.GetMessage("key_move_forward"),"FWD"},
				{SGLanguage.GetMessage("key_move_left"),"LEFT"},
				{SGLanguage.GetMessage("key_move_right"),"RIGHT"},
				{SGLanguage.GetMessage("key_move_back"),"BACK"},
				{SGLanguage.GetMessage("key_move_up"),"UP"},
				{SGLanguage.GetMessage("key_move_down"),"DOWN"},
				{SGLanguage.GetMessage("key_move_boost"),"SPD"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_act_title"),
			Keys = {
				{SGLanguage.GetMessage("key_act_destruct"),"BOOM"},
				{"Ring Beam Weapon","FIRE"},
				{SGLanguage.GetMessage("key_act_cloak"),"CLOAK"},
				{SGLanguage.GetMessage("key_act_door"),"DOOR"},
				{SGLanguage.GetMessage("key_act_land"),"LAND"},
				{SGLanguage.GetMessage("key_act_hyper"),"HYPERSPACE"},
				{SGLanguage.GetMessage("key_act_exit"),"EXIT"},
			},
		},
		{
			Name = SGLanguage.GetMessage("key_view_title"),
			Keys = {
				{SGLanguage.GetMessage("key_view_zoomin"),"Z+"},
				{SGLanguage.GetMessage("key_view_zoomout"),"Z-"},
				{SGLanguage.GetMessage("key_view_up"),"A+"},
				{SGLanguage.GetMessage("key_view_down"),"A-"},
				{SGLanguage.GetMessage("key_view_toggle"),"FPV"},
			},
		},
	}
	for _,v in pairs(KEYS) do
		Panel:Help("");
		Panel:Help(v.Name);
		for _,v in pairs(v.Keys) do
			local KEY = vgui.Create("SKeyboardKey",Panel);
			KEY:SetData(LAYOUT,v[1],v[2]);
			Panel:AddPanel(KEY);
		end
	end
end
