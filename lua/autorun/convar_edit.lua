if (SERVER) then

AddCSLuaFile("autorun/convar_edit.lua");

local cap_convars = {}

	local convars = {
		{"Destiny Small Turret", "destsmall", 4},
		{"Destiny Medium Turret", "destmedium", 2},
		{"Destiny MainWeapon", "destmain", 1},
		{"Tollana Ion Cannon", "ioncannon", 6},
		{"Ship Railgun", "shiprail", 6},
		{"Stationary Railgun", "statrail", 2},
		{"Drone Launcher", "launchdrone", 2},
		{"MiniDrone Platform", "minidrone", 2},
		{"Asgard Turret", "asgbeam", 2},
		{"AG-3 Sattelites", "ag3", 6},
		{"Gate Overloader", "overloader", 1},
		{"Asuran Gate Weapon", "asuran_beam", 1},
		{"Ori Beam Weapon", "ori_beam", 2},
		{"Dakara Device", "dakara", 1},
		{"Shaped Charge", "dirn", 1},
		{"Horizon Platform", "horizon", 1},
		{"Ori Sattelite", "ori", 1},
		{"Staff Stationary", "staffstat", 2},
		{"KINO Dispenser", "dispenser", 1},
		{"Destiny Console", "destcon", 5},
		{"Destiny Apple Core", "applecore", 1},
		{"Lantean Holo Device", "lantholo", 1},
		{"Shield Core", "shieldcore",1},
		{"Sodan Obelisk", "sod_obelisk", 4},
		{"Ancient Obelisk", "anc_obelisk", 4},
		{"MCD", "mcd", 1},
	}

	local convars2 = {
		{"AG-3 Charge Time", "ag3_weapon", 60},
		{"AG-3 Health", "ag3_health", 500},
		{"Ori Satelitte Shield Time", "ori_shield", 120},
		{"Ori Satelitte Charge Time", "ori_weapon", 60},
		{"Ori Satelitte Helath", "ori_health", 500},
		{"Ship Railgun Damage", "shiprail_damage", 10},
		{"Stationary Railgun Damage", "statrail_damage", 10},
		{"Atlantis Shield Energy Consumption", "shieldcore_atlfrac", 50},
		{"Enable Ship Shields", "shipshield", 1},
	}

	local sboxlimits = {
		{"anim_ramps", 10},
		{"ramp", 50},
		{"asuran_zpm_hub", 5},
		{"zpmhub", 5},
		{"ashen_defence", 10},
		{"sgc_zpm_hub", 5},
		{"bearing", 10},
		{"brazier", 50},
		{"cap_doors_contr", 10},
		{"cap_doors_frame", 10},
		{"cap_console", 50},
		{"drone_launcher", 2},
		{"floorchevron", 10},
		{"stargate_iris", 10},
		{"goauld_iris", 5},
		{"gravitycontroller", 15},
		{"jamming_device", 5},
		{"naq_gen_mks", 10},
		{"naquadah_bomb", 1},
		{"staff_weapon_glider", 2},
		{"cloaking_generator", 1},
		{"mobile_dhd", 3},
		{"supergate_dhd", 3},
		{"shield_generator", 1},
		{"tampered_zpm", 3},
		{"tokra_emmiter", 2},
		{"tokra_key", 1},
		{"tollan_disabler", 2},
		{"wraith_harvester", 1},
		{"zpm_mk3", 6},
		{"control_panel", 10},
		{"naquadah_bottle", 5},
	}

	for _,val in pairs(convars) do
		table.insert(cap_convars,"CAP_"..val[2].."_max");
	end

	for _,val in pairs(convars2) do
		table.insert(cap_convars,"CAP_"..val[2]);
	end

	for _,val in pairs(sboxlimits) do
		table.insert(cap_convars,"sbox_max"..val[1]);
	end

	table.insert(cap_convars,"cap_drop_weapons");
	table.insert(cap_convars,"cap_ashen_en");

util.AddNetworkString("_sgcap_convars");

function Cap_Get_Convars(player,command,args)
	net.Start("_sgcap_convars")
	net.WriteInt(table.Count(cap_convars),16);
	for k,v in pairs(cap_convars) do
		net.WriteString(v);
		net.WriteInt(GetConVarNumber(v),16);
	end
	net.Send(player)
end
concommand.Add("_sgcap_get_convars", Cap_Get_Convars);

function Cap_Set_Convar(player,command,args)
	if (player:IsAdmin()) then
		if (args[1]) then
			RunConsoleCommand(args[1], args[2]);
		end
	end
end
concommand.Add("_sgcap_set_convar", Cap_Set_Convar);

end

if (CLIENT) then

local CapConvarFrame;
local cap_convars = {};

local function NetCapConvars( len )
	local count = net.ReadInt(16);
	for i=1,count do
		cap_convars[net.ReadString()] = net.ReadInt(16);
	end
	Cap_Convar_OpenNet();
end
net.Receive("_sgcap_convars", NetCapConvars);

function CapGetConvar(convar)
	return cap_convars[convar] or 0;
end

function CapSetConvar(convar,value)
	if (LocalPlayer():IsAdmin()) then
		RunConsoleCommand("_sgcap_set_convar", convar, value);
	else
		GAMEMODE:AddNotify("You are not admin!", NOTIFY_ERROR, 5); surface.PlaySound( "buttons/button2.wav" );
	end
end

function Cap_Convar_Open()
	if (not LocalPlayer():IsAdmin()) then GAMEMODE:AddNotify("You are not admin!", NOTIFY_ERROR, 5); surface.PlaySound( "buttons/button2.wav" ); return end
	if (CapConvarFrame and CapConvarFrame:IsValid()) then CapConvarFrame:Close() end

	cap_convars = {}
	RunConsoleCommand("_sgcap_get_convars")
end

function Cap_Convar_OpenNet()
	local matBlurScreen = Material( "pp/blurscreen" )

	local limits = {
		{SGLanguage.GetMessage("stargate_cap_menu_01"), "destsmall", 4},
		{SGLanguage.GetMessage("stargate_cap_menu_02"), "destmedium", 2},
		{SGLanguage.GetMessage("stargate_cap_menu_03"), "destmain", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_04"), "ioncannon", 6},
		{SGLanguage.GetMessage("stargate_cap_menu_05"), "shiprail", 6},
		{SGLanguage.GetMessage("stargate_cap_menu_06"), "statrail", 2},
		{SGLanguage.GetMessage("stargate_cap_menu_08"), "launchdrone", 2},
		{SGLanguage.GetMessage("stargate_cap_menu_09"), "minidrone", 2},
		{SGLanguage.GetMessage("stargate_cap_menu_10"), "asgbeam", 2},
		{SGLanguage.GetMessage("stargate_cap_menu_11"), "ag3", 6},
		{SGLanguage.GetMessage("stargate_cap_menu_12"), "overloader", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_13"), "asuran_beam", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_15"), "ori_beam", 2},
		{SGLanguage.GetMessage("stargate_cap_menu_16"), "dakara", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_17"), "dirn", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_18"), "horizon", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_19"), "ori", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_20"), "staffstat", 2},
		{SGLanguage.GetMessage("stargate_cap_menu_21"), "dispenser", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_22"), "destcon", 5},
		{SGLanguage.GetMessage("stargate_cap_menu_23"), "applecore", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_24"), "lantholo", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_25"), "shieldcore",1},
		{SGLanguage.GetMessage("stargate_cap_menu_26"), "sod_obelisk", 4},
		{SGLanguage.GetMessage("stargate_cap_menu_27"), "anc_obelisk", 4},
		{SGLanguage.GetMessage("entity_mcd"), "mcd", 1}
	}
	local wepssett = {
		{SGLanguage.GetMessage("stargate_cap_menu_28"), "ag3_weapon", 60},
		{SGLanguage.GetMessage("stargate_cap_menu_29"), "ag3_health", 500},
		{SGLanguage.GetMessage("stargate_cap_menu_30"), "ori_shield", 120},
		{SGLanguage.GetMessage("stargate_cap_menu_31"), "ori_weapon", 60},
		{SGLanguage.GetMessage("stargate_cap_menu_32"), "ori_health", 500},
		{SGLanguage.GetMessage("stargate_cap_menu_33"), "shiprail_damage", 10},
		{SGLanguage.GetMessage("stargate_cap_menu_34"), "statrail_damage", 10},
		{SGLanguage.GetMessage("stargate_cap_menu_35"), "shieldcore_atlfrac", 50},
	}

	local miscsett = {
		{SGLanguage.GetMessage("stargate_cap_menu_36"), "CAP_shipshield", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_37"), "cap_drop_weapons", 1},
		{SGLanguage.GetMessage("stargate_cap_menu_38"), "cap_ashen_en", 1}
	}

	local sboxlimits = {
		{SGLanguage.GetMessage("stargate_cap_sbox_01"), "anim_ramps", 10},
		{SGLanguage.GetMessage("stargate_cap_sbox_02"), "ramp", 50},
		{SGLanguage.GetMessage("stargate_cap_sbox_03"), "asuran_zpm_hub", 5},
		{SGLanguage.GetMessage("stargate_cap_menu_07"), "ashen_defence", 10},
		{SGLanguage.GetMessage("stargate_cap_sbox_04"), "zpmhub", 5},
		{SGLanguage.GetMessage("stargate_cap_sbox_05"), "sgc_zpm_hub", 5},
		{SGLanguage.GetMessage("stargate_cap_sbox_06"), "bearing", 10},
		{SGLanguage.GetMessage("stargate_cap_sbox_07"), "brazier", 50},
		{SGLanguage.GetMessage("stargate_cap_sbox_08"), "cap_doors_contr", 10},
		{SGLanguage.GetMessage("stargate_cap_sbox_09"), "cap_doors_frame", 10},
		{SGLanguage.GetMessage("stargate_cap_sbox_10"), "cap_console", 50},
		{SGLanguage.GetMessage("stool_controlpanel"), 	"control_panel", 10},
		{SGLanguage.GetMessage("stargate_cap_sbox_11"), "drone_launcher", 2},
		{SGLanguage.GetMessage("stargate_cap_sbox_12"), "floorchevron", 10},
		{SGLanguage.GetMessage("stargate_cap_sbox_13"), "stargate_iris", 10},
		{SGLanguage.GetMessage("stargate_cap_sbox_28"), "goauld_iris", 5},
		{SGLanguage.GetMessage("stargate_cap_sbox_14"), "gravitycontroller", 15},
		{SGLanguage.GetMessage("stargate_cap_sbox_15"), "jamming_device", 5},
		{SGLanguage.GetMessage("stargate_cap_sbox_16"), "naq_gen_mks", 10},
		{SGLanguage.GetMessage("stargate_cap_menu_14"), "naquadah_bomb", 1},
		{SGLanguage.GetMessage("stargate_cap_sbox_17"), "staff_weapon_glider", 2},
		{SGLanguage.GetMessage("stargate_cap_sbox_18"), "cloaking_generator", 1},
		{SGLanguage.GetMessage("stargate_cap_sbox_19"), "mobile_dhd", 3},
		{SGLanguage.GetMessage("stargate_cap_sbox_27"), "supergate_dhd", 3},
		{SGLanguage.GetMessage("stargate_cap_sbox_20"), "shield_generator", 1},
		{SGLanguage.GetMessage("stargate_cap_sbox_21"), "tampered_zpm", 3},
		{SGLanguage.GetMessage("stargate_cap_sbox_22"), "tokra_emmiter", 2},
		{SGLanguage.GetMessage("stargate_cap_sbox_23"), "tokra_key", 1},
		{SGLanguage.GetMessage("stargate_cap_sbox_24"), "tollan_disabler", 2},
		{SGLanguage.GetMessage("stargate_cap_sbox_25"), "wraith_harvester", 1},
		{SGLanguage.GetMessage("stargate_cap_sbox_26"), "zpm_mk3", 6},
		{SGLanguage.GetMessage("stool_naq_bottle"), 	"naquadah_bottle", 5},
	}

	CapConvarFrame = vgui.Create("DFrame");
	CapConvarFrame:SetPos(ScrW()/2-360, ScrH()/2-325);
	CapConvarFrame:SetSize(760,650);
	CapConvarFrame:SetTitle(SGLanguage.GetMessage("stargate_cap_menu_00"));
	CapConvarFrame:SetVisible(true);
	CapConvarFrame:SetDraggable(false);
	--CapConvarFrame:ShowCloseButton(false);
	CapConvarFrame:SetBackgroundBlur(false);
	CapConvarFrame:MakePopup();
	CapConvarFrame.Paint = function()

		// Thanks Overv, http://www.facepunch.com/threads/1041686-What-are-you-working-on-V4-John-Lua-Edition

		// Background
		surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )

		matBlurScreen:SetFloat( "$blur", 5 )

		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect( -ScrH()/10, -ScrH()/10, ScrW(), ScrH() )

		surface.SetDrawColor( 100, 100, 100, 150 )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )

		// Border
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawOutlinedRect( 0, 0, CapConvarFrame:GetWide(), CapConvarFrame:GetTall() )

		// Small frames
		local col = Color( 170, 170, 170, 255);
		local col2 = Color( 100, 100, 100, 255);
		local bor = 6;
		local diff = 2;

		draw.RoundedBox( bor, 10-diff, 35-diff, 240+2*diff, 570+2*diff, col);
		draw.RoundedBox( bor, 10, 35, 240, 570, col2);

		draw.RoundedBox( bor, 265-diff, 35-diff, 230+2*diff, 330+2*diff, col);
		draw.RoundedBox( bor, 265, 35, 230, 330, col2);

		draw.RoundedBox( bor, 275-diff, 380-diff, 210+2*diff, 60+2*diff, col);
		draw.RoundedBox( bor, 275, 380, 210, 60, col2);

		draw.RoundedBox( bor, 510-diff, 35-diff, 240+2*diff, 600+2*diff, col);
 			draw.RoundedBox( bor, 510, 35, 240, 600, col2);

	end

	local DVScrollBarFrame = vgui.Create("DFrame", CapConvarFrame);
	DVScrollBarFrame:SetPos(10, 35);
	DVScrollBarFrame:SetSize(240,570);
	DVScrollBarFrame:SetTitle("");
	DVScrollBarFrame:ShowCloseButton(false);
	DVScrollBarFrame:SetVisible(true);
	DVScrollBarFrame:SetDraggable(false);
	DVScrollBarFrame:SetBackgroundBlur(false);
	--DVScrollBarFrame:MakePopup();
	DVScrollBarFrame.Paint = function()	end

	local DVScrollBar = vgui.Create( "DVScrollBar", CapConvarFrame )
	DVScrollBar:SetSize( 16, 560)
	DVScrollBar:SetPos(230,40)
	DVScrollBar:SetEnabled(true)
	i = 0;
	local sliders = {}
	for _,val in pairs(limits) do
		local convar = "CAP_"..val[2].."_max";

		local slider = vgui.Create( "DOldNumSlider" , DVScrollBarFrame);
		sliders[i] = slider;
		sliders[i]:SetPos(5, 5+40*i);
		sliders[i]:SetSize(210, 50);
		sliders[i]:SetText(val[1].." "..SGLanguage.GetMessage("stargate_cap_menu_l"));
		sliders[i]:SetMin(0);
		sliders[i]:SetMax(val[3]*3);
		sliders[i]:SetValue(CapGetConvar(convar));
		sliders[i]:SetDecimals(0);
		sliders[i]:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint",convar));
		sliders[i].OnValueChanged = function(Size_x, fValue)
			CapSetConvar(convar, fValue);
		end
		sliders[i].Wang.OnTextChanged = function(self)
			slider:ValueChanged(slider.Wang:GetValue());
		end
		i = i + 1;
	end
	DVScrollBar.Think = function() for k,s in pairs(sliders) do s:SetPos(5, DVScrollBar:GetOffset()+5+40*k) end end
	DVScrollBar:SetUp(40,5+40*(i-13))
	DVScrollBarFrame.OnMouseWheeled = function(self, dlta)
		DVScrollBar:OnMouseWheeled(dlta);
	end

	i = 0;
	for _,val in pairs(wepssett) do
		i = i + 1;
		local convar = "CAP_"..val[2];

		local slider = vgui.Create( "DOldNumSlider" , CapConvarFrame);
		slider:SetPos(270, 40*i);
		slider:SetSize(220, 50);
		slider:SetText(val[1]);
		slider:SetMin(0);
		slider:SetMax(val[3]*3);
		slider:SetValue(CapGetConvar(convar));
		slider:SetDecimals(0);
		slider:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint",convar));
		slider.OnValueChanged = function(Size_x, fValue)
			CapSetConvar(convar, fValue);
		end
		slider.Wang.OnTextChanged = function(self)
			slider:ValueChanged(slider.Wang:GetValue());
		end
	end

	i = 0;
	for _,val in pairs(miscsett) do
		i = i + 1;

		local box = vgui.Create( "DCheckBoxLabel" , CapConvarFrame);
		box:SetPos(285, 363+20*i);
		box:SetText(val[1]);
		box:SetValue(CapGetConvar(val[2]));
		box:SizeToContents();
		box:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint",val[2]));
		box.Label:SetFont("OldDefaultSmall");
		box.OnChange = function(box, fValue)
			local v = 0;
			if fValue then v = 1; end
			CapSetConvar(val[2], v);
		end
		box.PerformLayout = function(self)
		    local x = self.m_iIndent or 0
		    self.Button:SetSize( 14, 14 )
		    self.Button:SetPos( x, 0 )
		    if ( self.Label ) then
		        self.Label:SizeToContents()
		        self.Label:SetPos( x + 10 + 10, 0 )
		    end
		end
	end

	local DVScrollBarFrame = vgui.Create("DFrame", CapConvarFrame);
	DVScrollBarFrame:SetPos(510, 35);
	DVScrollBarFrame:SetSize(240,600);
	DVScrollBarFrame:SetTitle("");
	DVScrollBarFrame:ShowCloseButton(false);
	DVScrollBarFrame:SetVisible(true);
	DVScrollBarFrame:SetDraggable(false);
	DVScrollBarFrame:SetBackgroundBlur(false);
	--DVScrollBarFrame:MakePopup();
	DVScrollBarFrame.Paint = function()	end

	local DVScrollBar = vgui.Create( "DVScrollBar", CapConvarFrame )
	DVScrollBar:SetSize( 16, 590)
	DVScrollBar:SetPos(730,40)
	DVScrollBar:SetEnabled(true)
	i = 0;
	local sliders = {}
	for _,val in pairs(sboxlimits) do
		local convar = "sbox_max"..val[2];

		local slider = vgui.Create( "DOldNumSlider" , DVScrollBarFrame);
		sliders[i] = slider;
		sliders[i]:SetPos(5, 5+40*i);
		sliders[i]:SetSize(210, 50);
		sliders[i]:SetText(val[1].." "..SGLanguage.GetMessage("stargate_cap_menu_l"));
		sliders[i]:SetMin(0);
		sliders[i]:SetMax(val[3]*3);
		sliders[i]:SetValue(CapGetConvar(convar));
		sliders[i]:SetDecimals(0);
		sliders[i]:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint",convar));
		sliders[i].OnValueChanged = function(Size_x, fValue)
			CapSetConvar(convar, fValue);
		end
		sliders[i].Wang.OnTextChanged = function(self)
			slider:ValueChanged(slider.Wang:GetValue());
		end
		i = i + 1;
	end
	DVScrollBar.Think = function() for k,s in pairs(sliders) do s:SetPos(5, DVScrollBar:GetOffset()+5+40*k) end end
	DVScrollBar:SetUp(40,5+40*(i-14))
	DVScrollBarFrame.OnMouseWheeled = function(self, dlta)
		DVScrollBar:OnMouseWheeled(dlta);
	end

	local sgsets = vgui.Create("DButton", CapConvarFrame);
    sgsets:SetText( SGLanguage.GetMessage("stargate_settings_02") );
    sgsets:SetPos(45, 615);
    sgsets:SetSize(160, 25);
	sgsets.DoClick = function ( btn )
		LocalPlayer():ConCommand("stargate_system_convars");
		CapConvarFrame:Close();
	end

	local img = vgui.Create("DImage", CapConvarFrame)
	img:SetPos(283,445);
	img:SetSize(200,200);
	img:SetImage("gui/update_checker/cap")
end

concommand.Add("stargate_cap_convars",Cap_Convar_Open);

end