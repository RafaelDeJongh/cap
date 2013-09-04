/*
	###################################
	StarGate with Group System
	Created by AlexALX (c) 2011
	###################################
*/

if (SERVER) then

AddCSLuaFile("autorun/stargate_convar_edit.lua");

local group_convars = {
	"stargate_group_system",
	"stargate_candial_groups_dhd",
	"stargate_candial_groups_menu",
	"stargate_candial_groups_wire",
	"stargate_sgu_find_range",
	"stargate_energy_dial",
	"stargate_energy_dial_spawner",
	"stargate_different_dial_menu",
	"stargate_dhd_protect",
	"stargate_dhd_protect_spawner",
	"stargate_dhd_destroyed_energy",
	"stargate_dhd_close_incoming",
	"stargate_show_inbound_address",
	"stargate_protect",
	"stargate_protect_spawner",
	"stargate_block_address",
	"stargate_has_rd", -- not convar
	"stargate_dhd_letters",
	"stargate_energy_target",
	"stargate_vgui_glyphs",
	"stargate_dhd_menu",
	"stargate_atlantis_override",
	"stargate_gatespawner_enabled",
	"stargate_gatespawner_protect",
	"stargate_dhd_ring",
	"stargate_physics_clipping",
	"stargate_model_clipping",
	"stargate_open_effect",
}

util.AddNetworkString("_sggroup_convars");

function Group_Get_Convars(player,command,args)
	net.Start("_sggroup_convars")
	net.WriteInt(table.Count(group_convars),16);
	for k,v in pairs(group_convars) do
		net.WriteString(v);
		if (v=="stargate_has_rd") then
			if (StarGate.HasResourceDistribution) then
				net.WriteInt(1,16);
			else
				net.WriteInt(0,16);
			end
		else
			net.WriteInt(GetConVarNumber(v),16);
		end
	end
	net.Send(player)
end
concommand.Add("_sggroup_get_convars", Group_Get_Convars);

function Group_Set_Convar(player,command,args)
	if (player:IsAdmin()) then
		if (args[1]) then
			RunConsoleCommand(args[1], args[2]);
		end
	end
end
concommand.Add("_sggroup_set_convar", Group_Set_Convar);

end

if (CLIENT) then

local GroupConvarFrame;
local group_convars = {};

local function NetGroupConvars( len )
	local count = net.ReadInt(16);
	for i=1,count do
		group_convars[net.ReadString()] = net.ReadInt(16);
	end
	Group_Convar_OpenNet();
end
net.Receive("_sggroup_convars", NetGroupConvars);

function GroupGetConvar(convar)
	return group_convars[convar] or 0;
end

function GroupSetConvar(convar,value)
	if (LocalPlayer():IsAdmin()) then
		RunConsoleCommand("_sggroup_set_convar", convar, value);
	else
		GAMEMODE:AddNotify("You are not admin!", NOTIFY_ERROR, 5); surface.PlaySound( "buttons/button2.wav" );
	end
end

function Group_Convar_Open()
	if (not LocalPlayer():IsAdmin()) then GAMEMODE:AddNotify("You are not admin!", NOTIFY_ERROR, 5); surface.PlaySound( "buttons/button2.wav" ); return end
	if (GroupConvarFrame and GroupConvarFrame:IsValid()) then GroupConvarFrame:Close() end

	group_convars = {}
	RunConsoleCommand("_sggroup_get_convars")
end

function Group_Convar_OpenNet()
	local matBlurScreen = Material( "pp/blurscreen" )

	local allowdialgroup = {
		{SGLanguage.GetMessage("stargate_menu_01"), "stargate_candial_groups_menu", 1},
		{SGLanguage.GetMessage("stargate_menu_02"), "stargate_candial_groups_dhd", 1},
		{SGLanguage.GetMessage("stargate_menu_03"), "stargate_candial_groups_wire", 1}
	}

	local sgsettings = {
		{SGLanguage.GetMessage("stargate_menu_04"), "stargate_different_dial_menu", 0},
		{SGLanguage.GetMessage("stargate_menu_05"), "stargate_energy_dial", 1},
		{SGLanguage.GetMessage("stargate_menu_06"), "stargate_energy_dial_spawner", 0},
		{SGLanguage.GetMessage("stargate_menu_28"), "stargate_energy_target", 1},
		{SGLanguage.GetMessage("stargate_menu_21"), "stargate_protect", 0, 1},
		{SGLanguage.GetMessage("stargate_menu_22"), "stargate_protect_spawner", 0, 1},
		{SGLanguage.GetMessage("stargate_menu_33"), "stargate_atlantis_override", 1},
		{SGLanguage.GetMessage("stargate_menu_34"), "stargate_gatespawner_enabled", 1},
		{SGLanguage.GetMessage("stargate_menu_34b"), "stargate_gatespawner_protect", 1},
		{SGLanguage.GetMessage("stargate_menu_36"), "stargate_physics_clipping", 1},
		{SGLanguage.GetMessage("stargate_menu_38"), "stargate_model_clipping", 1},
		{SGLanguage.GetMessage("stargate_menu_39"), "stargate_open_effect", 1},
	}

	local dhdsettings = {
		{SGLanguage.GetMessage("stargate_menu_07"), "stargate_dhd_protect", 0, 1},
		{SGLanguage.GetMessage("stargate_menu_08"), "stargate_dhd_protect_spawner", 0, 1},
		{SGLanguage.GetMessage("stargate_menu_09"), "stargate_dhd_destroyed_energy", 1},
		{SGLanguage.GetMessage("stargate_menu_10"), "stargate_dhd_close_incoming", 1},
		{SGLanguage.GetMessage("stargate_menu_31"), "stargate_dhd_menu", 1},
		{SGLanguage.GetMessage("stargate_menu_32"), "stargate_dhd_letters", 1},
		{SGLanguage.GetMessage("stargate_menu_35"), "stargate_dhd_ring", 1},
	}

	GroupConvarFrame = vgui.Create("DFrame");
	GroupConvarFrame:SetPos(ScrW()/2-265, ScrH()/2-200);
	if (GroupGetConvar("stargate_has_rd")!=1) then
		GroupConvarFrame:SetSize(560,360);
	else
		GroupConvarFrame:SetSize(560,310);
	end
	GroupConvarFrame:SetTitle(SGLanguage.GetMessage("stargate_menu_00"));
	GroupConvarFrame:SetVisible(true);
	GroupConvarFrame:SetDraggable(false);
	GroupConvarFrame:ShowCloseButton(true);
	GroupConvarFrame:SetBackgroundBlur(false);
	GroupConvarFrame:MakePopup();
	GroupConvarFrame.Paint = function()

		// Thanks Overv, http://www.facepunch.com/threads/1041686-What-are-you-working-on-V4-John-Lua-Edition

		// Background
		-- disabled, because broken somewhy now, i see own menu
		/*surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )

		matBlurScreen:SetFloat( "$blur", 5 )

		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect( -ScrH()/10, -ScrH()/10, ScrW(), ScrH() )*/

		surface.SetDrawColor( 100, 100, 100, 150 )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )

		// Border
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawOutlinedRect( 0, 0, GroupConvarFrame:GetWide(), GroupConvarFrame:GetTall() )

		// Small frames
		local col = Color( 170, 170, 170, 255);
		local col2 = Color( 100, 100, 100, 255);
		local bor = 6;
		local diff = 2;

		draw.RoundedBox( bor, 10-diff, 35-diff, 180+2*diff, 265+2*diff, col);
		draw.RoundedBox( bor, 10, 35, 180, 265, col2);

		draw.RoundedBox( bor, 200-diff, 35-diff, 180+2*diff, 181+2*diff, col);
		draw.RoundedBox( bor, 200, 35, 180, 181, col2);

		draw.RoundedBox( bor, 390-diff, 35-diff, 160+2*diff, 65+2*diff, col);
		draw.RoundedBox( bor, 390, 35, 160, 65, col2);

		draw.RoundedBox( bor, 390-diff, 110-diff, 160+2*diff, 87+2*diff, col);
		draw.RoundedBox( bor, 390, 110, 160, 87, col2);

		draw.RoundedBox( bor, 390-diff, 207-diff, 160+2*diff, 45+2*diff, col);
		draw.RoundedBox( bor, 390, 207, 160, 45, col2);

		if (GroupGetConvar("stargate_has_rd")!=1) then
			draw.RoundedBox( bor, 125-diff, 310-diff, 340+2*diff, 40+2*diff, col);
			draw.RoundedBox( bor, 125, 310, 340, 40, col2);
		end

	end

	if (GroupGetConvar("stargate_has_rd")!=1) then
		local laber = vgui.Create( "DLabel" , GroupConvarFrame);
		laber:SetFont("OldDefaultSmall");
		laber:SetPos(135, 310);
		laber:SetText(SGLanguage.GetMessage("stargate_menu_25"));
		laber:SizeToContents();
	end

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(20, 40);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_12"));
	laber:SizeToContents();

	local i = 0;
	for k,val in pairs(sgsettings) do
		i = i + 1;

		local box = vgui.Create( "DCheckBoxLabel" , GroupConvarFrame);
		box:SetPos(15, 40+15*i);
		box:SetText(val[1]);
		box.Label:SetFont("OldDefaultSmall");
		if (val[4]==1) then
			local v = 1;
			if (GroupGetConvar(val[2])==1) then v = 0; end
			box:SetValue(v);
		else
			box:SetValue(GroupGetConvar(val[2]));
		end
		box:SizeToContents();
		box.PerformLayout = function(self)
		    local x = self.m_iIndent or 0
		    self.Button:SetSize( 14, 14 )
		    self.Button:SetPos( x, 0 )
		    if ( self.Label ) then
		        self.Label:SizeToContents()
		        self.Label:SetPos( x + 10 + 10, 0 )
		    end
		end
		if(k==7) then
			box:SetToolTip(SGLanguage.GetMessage("stargate_menu_33_tip").." "..SGLanguage.GetMessage("stargate_menu_hint",val[2]));
		elseif(k==10) then
			box:SetToolTip(SGLanguage.GetMessage("stargate_menu_36_tip").." "..SGLanguage.GetMessage("stargate_menu_hint",val[2]));
		else
			box:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint",val[2]));
		end
		if ((k==2 or k==3 or k==4) and GroupGetConvar("stargate_has_rd")!=1) then
			box:SetDisabled(true);
			box:SetTextColor(Color(128,128,128));
			box:SetValue(0);
		end
		box.OnChange = function(box, fValue)
			if (val[4]==1) then fValue = not fValue; end
			local v = 0;
			if fValue then v = 1; end
			GroupSetConvar(val[2], v);
		end
	end

	local offset = 40+15*i;

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(20, offset+15);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_13"));
	laber:SizeToContents();

	local slider = vgui.Create( "DOldNumSlider" , GroupConvarFrame);
	slider:SetPos(15, offset+30);
	slider:SetSize(170, 50);
	slider:SetText(SGLanguage.GetMessage("stargate_menu_14"));
	slider:SetMin(0);
	slider:SetMax(32000);
	slider:SetValue(GroupGetConvar("stargate_sgu_find_range"));
	slider:SetDecimals(0);
	slider:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint","stargate_sgu_find_range"));
	slider.OnValueChanged = function(Size_x, fValue)
		GroupSetConvar("stargate_sgu_find_range", fValue);
	end
	slider.Wang.OnTextChanged = function(self)
		slider:ValueChanged(slider.Wang:GetValue());
	end
	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(15, offset+65);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_15"));
	laber:SizeToContents();

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(210, 40);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_16"));
	laber:SizeToContents();

	i = 0;
	for k,val in pairs(dhdsettings) do
		i = i + 1;

		local box = vgui.Create( "DCheckBoxLabel" , GroupConvarFrame);
		box:SetPos(205, 40+17*i);
		box:SetText(val[1]);
		box.Label:SetFont("OldDefaultSmall");
		if (val[4]==1) then
			local v = 1;
			if (GroupGetConvar(val[2])==1) then v = 0; end
			box:SetValue(v);
		else
			box:SetValue(GroupGetConvar(val[2]));
		end
		box:SizeToContents();
		box:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint",val[2]));
		box.PerformLayout = function(self)
		    local x = self.m_iIndent or 0
		    self.Button:SetSize( 14, 14 )
		    self.Button:SetPos( x, 0 )
		    if ( self.Label ) then
		        self.Label:SizeToContents()
		        self.Label:SetPos( x + 10 + 10, 0 )
		    end
		end
		if (k==3 and GroupGetConvar("stargate_has_rd")!=1) then
			box:SetDisabled(true);
			box:SetTextColor(Color(128,128,128));
			box:SetValue(0);
		end
		box.OnChange = function(box, fValue)
			if (val[4]==1) then fValue = not fValue; end
			local v = 0;
			if fValue then v = 1; end
			GroupSetConvar(val[2], v);
		end
	end

	local offset = 40+17*i;

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(210, offset+17);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_17"));
	laber:SizeToContents();

	local select = vgui.Create("DMultiChoice", GroupConvarFrame);
    select:SetToolTip(SGLanguage.GetMessage("stargate_menu_18").." "..SGLanguage.GetMessage("stargate_menu_hint","stargate_show_inbound_address"));
    select:SetPos(205, offset+32);
    select:SetSize(170, 20);
    select:SetEditable(false);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_18a"),2);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_18b"),1);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_18c"),0);
    if (GroupGetConvar("stargate_show_inbound_address")==2) then
		select:ChooseOptionID(1);
    elseif (GroupGetConvar("stargate_show_inbound_address")==1) then
		select:ChooseOptionID(2);
    else
		select:ChooseOptionID(3);
    end
	select.OnSelect = function(panel,index,value,data)
		GroupSetConvar("stargate_show_inbound_address", Format("%d", data));
	end

	local closeall = vgui.Create("DButton", GroupConvarFrame);
    closeall:SetText(SGLanguage.GetMessage("stargate_menu_37"));
    closeall:SetPos(210, offset+65);
    closeall:SetSize(160, 33);
	closeall.DoClick = function ( btn )
		GroupSetConvar("stargate_close_all");
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_menu_37b"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end

	local dospawner = vgui.Create("DButton", GroupConvarFrame);
    dospawner:SetText(SGLanguage.GetMessage("stargate_menu_19"));
    dospawner:SetPos(210, offset+105);
    dospawner:SetSize(160, 33);
	dospawner.DoClick = function ( btn )
		GroupSetConvar("stargate_gatespawner_createfile");
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_menu_20"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(400, 40);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_11"));
	laber:SizeToContents();

	local i = 0;
	for _,val in pairs(allowdialgroup) do
		i = i + 1;

		local box = vgui.Create( "DCheckBoxLabel" , GroupConvarFrame);
		if (i > 2) then
			box:SetPos(395+20*i-2, 80);
		else
			box:SetPos(395, 40+20*i);
		end
		box:SetText(val[1]);
		box.Label:SetFont("OldDefaultSmall");
		if (val[4]==1) then
			local v = 1;
			if (GroupGetConvar(val[2])==1) then v = 0; end
			box:SetValue(v);
		else
			box:SetValue(GroupGetConvar(val[2]));
		end
		box:SizeToContents();
		box:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint",val[2]));
		box.PerformLayout = function(self)
		    local x = self.m_iIndent or 0
		    self.Button:SetSize( 14, 14 )
		    self.Button:SetPos( x, 0 )
		    if ( self.Label ) then
		        self.Label:SizeToContents()
		        self.Label:SetPos( x + 10 + 10, 0 )
		    end
		end
		box.OnChange = function(box, fValue)
			local v = 0;
			if fValue then v = 1; end
			GroupSetConvar(val[2], v);
		end
	end

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(400, 115);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_26"));
	laber:SizeToContents();

	local select = vgui.Create("DMultiChoice", GroupConvarFrame);
    select:SetToolTip(SGLanguage.GetMessage("stargate_menu_27").." "..SGLanguage.GetMessage("stargate_menu_hint","stargate_block_address"));
    select:SetPos(395, 130);
    select:SetSize(150, 20);
    select:SetEditable(false);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_27a"),2);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_27b"),1);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_27c"),0);
    if (GroupGetConvar("stargate_block_address")==2) then
		select:ChooseOptionID(1);
    elseif (GroupGetConvar("stargate_block_address")==1) then
		select:ChooseOptionID(2);
    else
		select:ChooseOptionID(3);
    end
	select.OnSelect = function(panel,index,value,data)
		GroupSetConvar("stargate_block_address", Format("%d", data));
	end

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(400, 155);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_29"));
	laber:SizeToContents();

	local select = vgui.Create("DMultiChoice", GroupConvarFrame);
    select:SetToolTip(SGLanguage.GetMessage("stargate_menu_30").." "..SGLanguage.GetMessage("stargate_menu_hint","stargate_vgui_glyphs"));
    select:SetPos(395, 170);
    select:SetSize(150, 20);
    select:SetEditable(false);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_30a"),2);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_30b"),1);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_30c"),0);
    if (GroupGetConvar("stargate_vgui_glyphs")==2) then
		select:ChooseOptionID(1);
    elseif (GroupGetConvar("stargate_vgui_glyphs")==1) then
		select:ChooseOptionID(2);
    else
		select:ChooseOptionID(3);
    end
	select.OnSelect = function(panel,index,value,data)
		GroupSetConvar("stargate_vgui_glyphs", Format("%d", data));
	end

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(400, 212);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_23"));
	laber:SizeToContents();

	local system = vgui.Create("DMultiChoice", GroupConvarFrame);
    system:SetToolTip(SGLanguage.GetMessage("stargate_menu_24").." "..SGLanguage.GetMessage("stargate_menu_hint","stargate_group_system"));
    system:SetPos(395, 227);
    system:SetSize(150, 20);
    system:SetEditable(false);
    system:AddChoice("Group System",1);
    system:AddChoice("Galaxy System",0);
    if (GroupGetConvar("stargate_group_system")==1) then
		system:ChooseOptionID(1);
    else
		system:ChooseOptionID(2);
    end
	system.OnSelect = function(panel,index,value,data)
		--if (GroupGetConvar("stargate_group_system")!=data) then
			LocalPlayer():ChatPrint(SGLanguage.GetMessage("stargate_reload_start"));
			GroupSetConvar("stargate_group_system", Format("%d", data));
		--end
	end

	local reloadbut = vgui.Create("DButton", GroupConvarFrame);
    reloadbut:SetText(SGLanguage.GetMessage("stargate_menu_40"));
    reloadbut:SetPos(395, 260);
    reloadbut:SetSize(150, 33);
	reloadbut.DoClick = function ( btn )
		GroupSetConvar("stargate_gatespawner_reload");
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_menu_40b"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end

	GroupConvarFrame.OnKeyCodePressed = function(self,key)
		if (key==64) then self:Close(); end
	end
end
concommand.Add("stargate_system_convars",Group_Convar_Open);

end