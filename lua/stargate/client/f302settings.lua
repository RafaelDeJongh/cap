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
function StarGate.F302Settings(Panel)
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
