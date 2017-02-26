if SERVER then

local convars_cache = {}

util.AddNetworkString("_sg_convars");
util.AddNetworkString("_sg_config");

-- automatically get default values of convars, now all in one stargate/server/convars.lua file!
local function build_cache()
	convars_cache = {
		["stargate_has_rd"] = 0, -- not convar
	}
	table.Merge(convars_cache,StarGate.CAP_Convars);
	table.Merge(convars_cache,StarGate.CAP_SGConvars);
	local tools = list.Get("CAP.Tool");
	for k,v in pairs(tools) do
		--if (not v or not v.Entity or not v.Entity.Class or not v.Entity.Limit) then continue end
		convars_cache["sbox_max"..v.Entity.Class] = v.Entity.Limit;
		if (v.Entity.Limits) then
			for c,l in pairs(v.Entity.Limits) do
				convars_cache["sbox_max"..c] = l;
			end
		end
	end
end

net.Receive("_sg_convars",function(len,ply)
	if (not IsValid(ply) or not ply:IsAdmin()) then return end
	if (table.Count(convars_cache)==0) then build_cache(); end
	local get = util.tobool(net.ReadBit());
	if (get) then
		net.Start("_sg_convars")
		net.WriteUInt(0,4)
		net.WriteUInt(table.Count(convars_cache),8);
		for k,v in pairs(convars_cache) do
			net.WriteString(k);
			if (k=="stargate_has_rd") then
				net.WriteUInt(StarGate.HasResourceDistribution and 1 or 0,20);
			else
				net.WriteUInt(GetConVarNumber(k),20);
			end
			net.WriteUInt(v,20);
		end
		net.Send(ply)
	else
		local convar,value = net.ReadString(),net.ReadUInt(20);
		if (convar=="stargate_gatespawner_createfile") then
			if (StarGate and StarGate.GateSpawner and StarGate.GateSpawner.CreateFile) then
				StarGate.GateSpawner.CreateFile(ply);
			end
		else
			RunConsoleCommand(convar,value);
		end
	end
end)

local function CfgBackup(fil)
	if (not file.IsDir("stargate/cfg/backup","DATA")) then
		file.CreateDir("stargate/cfg/backup");
	end
	local cb = tonumber(StarGate.CFG:Get("cap_misc","cfgbackup",3)) or 3;
	if (cb<1) then return end
	for i=cb,1,-1 do
		local ni = i-1
		file.Delete("stargate/cfg/backup/"..fil..i..".txt")
		if i!=1 and file.Exists("stargate/cfg/backup/"..fil..ni..".txt","DATA") then
			-- damn, why there is no rename function? modification time lost =(
			file.Write("stargate/cfg/backup/"..fil..i..".txt",file.Read("stargate/cfg/backup/"..fil..ni..".txt","DATA"))
		end
		if i==1 and file.Exists("stargate/cfg/"..fil..".txt","DATA") then
			file.Write("stargate/cfg/backup/"..fil..i..".txt",file.Read("stargate/cfg/"..fil..".txt","DATA"))
		end
	end
end

local CfgTable = {};

net.Receive("_sg_config",function(len,ply)
	if (not IsValid(ply) or not ply:IsAdmin()) then return end
	local typ = net.ReadUInt(8);
	if (typ==0 or typ==3 or typ==4) then
		if (typ==3) then
			file.Delete("stargate/custom_config.txt");
		end
		if (typ==3 or typ==4) then
			StarGate.LoadConfig();
		end
		local ini = INIParser:new("stargate/cfg/config.txt",false,false,false,true);
		if (not ini) then
			StarGate.LoadConfig();
			ini = INIParser:new("stargate/cfg/config.txt",false,false,false,true);
		end
		local custom_config = INIParser:new("stargate/cfg/custom_config.txt",false,false,false,true);
		-- Merge our custom config with the default one
		if(ini and custom_config) then
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

		net.Start("_sg_config");
		net.WriteUInt(0,8);
		net.Send(ply);

		if (ini) then
			for name,cfg in pairs(ini:get()) do
				if(name ~= "config") then
					if (cfg[1]==nil) then continue; end
					local tbl = {};
					for k,v in pairs(cfg[1]) do
						v=v:Trim();
						local number = tonumber(v);
						if(number) then
							v = number;
						elseif(v == "false" or v == "true") then
							v = util.tobool(v);
						end
						tbl[k] = v;
					end
					net.Start("_sg_config");
					net.WriteUInt(1,8);
					net.WriteString(name);
					-- due to bug with floats in writetable i must use this until it will be fixed
					net.WriteUInt(table.Count(tbl),16);
					for k,v in pairs(tbl) do
						net.WriteString(k);
						if (type(v)=="number") then
							net.WriteUInt(0,8);
							net.WriteDouble(v);
						elseif (type(v)=="boolean") then
							net.WriteUInt(1,8);
							net.WriteBit(v);
						else
							net.WriteUInt(2,8);
							net.WriteString(v);
						end
					end
					--net.WriteTable(tbl);
					net.Send(ply);
				end
			end
		end

		net.Start("_sg_config");
		net.WriteUInt(2,8);
		net.Send(ply);
	elseif (typ==2) then
		local cust = {"ent_groups_only","swep_groups_only","npc_groups_only","tool_groups_only","cap_disabled_ent","cap_disabled_swep","cap_disabled_npc","cap_disabled_tool"};
		local ini = INIParser:new("stargate/cfg/config.txt",false,false,false,true);
		local write = "# Config generated using Config Editor from Stargate Settings Menu.\r\n";
		write = write.."# Config generator created by AlexALX (c) 2014\r\n"
		write = write.."# Carter Addon Pack - http://sg-carterpack.com/\r\n"
		local written = {};
		local cust_write = {};
		if (not ini) then
			StarGate.LoadConfig();
			ini = INIParser:new("stargate/cfg/config.txt",false,false,false,true);
		end
		if (ini) then
			for name,cfg in pairs(ini:get()) do
				if(name ~= "config") then
					if (cfg[1]==nil) then continue; end
					for k,v in pairs(cfg[1]) do
						v=v:Trim();
						local number = tonumber(v);
						if(number) then
							v = number;
						elseif(v == "false" or v == "true") then
							v = util.tobool(v);
						end
						if (table.HasValue(cust,name)) then
							if (not cust_write[name]) then
								cust_write[name] = {};
							end
							cust_write[name][tostring(k)] = v;
							continue;
						end
						if (CfgTable[name][k]!=v) then
							if (not written[name]) then
								write = write.."\r\n["..name.."]\r\n";
								written[name] = true;
							end
							write = write..tostring(k).." = "..tostring(CfgTable[name][k]).."\r\n";
						end
					end
				end
			end
			for k,cat in pairs(cust) do
				local dis = false;
				if (cat:find("cap_disabled_")) then dis = true end
				for name,val in pairs(CfgTable[cat] or {}) do
					local cw = (cust_write[cat] and cust_write[cat][name]);
					if ((val=="" or val==false and dis) and not cw) then continue end
					if (not CfgTable[cat] or CfgTable[cat][name] and not cw or cw and val!=cust_write[cat][name]) then
						if (not written[cat]) then
							write = write.."\r\n["..cat.."]\r\n";
							written[cat] = {};
						end
						if (not written[cat][tostring(name)]) then
							if (dis and cw) then val = false end
							write = write..tostring(name).." = "..tostring(val).."\r\n";
							written[cat][tostring(name)] = true;
						end
					end
				end
			end
		end
		CfgBackup("custom_config")
		if (table.Count(written)>0) then
			file.Write("stargate/cfg/custom_config.txt",write);
		else
			file.Delete("stargate/cfg/custom_config.txt");
		end
		StarGate.LoadConfig();
		CfgTable = {};
	elseif(typ==1) then
		-- due to bug with floats in writetable i must use this until it will be fixed
		local cat = net.ReadString();
		CfgTable[cat] = {};
		local count = net.ReadUInt(16);
		for i=1,count do
			local name = net.ReadString();
			local typ = net.ReadUInt(8)
			if (typ==0) then
				CfgTable[cat][name] = net.ReadDouble();
			elseif (typ==1) then
				CfgTable[cat][name] = util.tobool(net.ReadBit());
			else
				CfgTable[cat][name] = net.ReadString();
			end
		end
		--CfgTable[net.ReadString()] = net.ReadTable();
	elseif(typ==5 or typ==7) then
		if (typ==7) then
			StarGate.LoadGroupConfig();
		end
		local ini = INIParser:new("stargate/cfg/custom_groups.txt",false,false,true,true);
		if (not ini) then
			StarGate.LoadGroupConfig();
			ini = INIParser:new("stargate/cfg/custom_groups.txt",false,false,true,true);
		end
		net.Start("_sg_config");
		net.WriteUInt(4,8);
		net.Send(ply);

		if (ini) then
			for name,cfg in pairs(ini:get()) do
				if (cfg[1]==nil) then continue; end
				local tbl = {};
				for k,v in pairs(cfg[1]) do
					tbl[k] = v:Trim();
				end
				net.Start("_sg_config");
				net.WriteUInt(1,8);
				net.WriteString(name);
				net.WriteUInt(table.Count(tbl),16);
				for k,v in pairs(tbl) do
					net.WriteString(k);
					net.WriteUInt(2,8);
					net.WriteString(v);
				end
				--net.WriteTable(tbl);
				net.Send(ply);
			end
		end

		net.Start("_sg_config");
		net.WriteUInt(3,8);
		net.Send(ply);
	elseif(typ==6) then
		local write = "// Config generated using Config Editor from Stargate Settings Menu.\r\n";
		write = write.."// Config generator created by AlexALX (c) 2014\r\n"
		write = write.."// Carter Addon Pack - http://sg-carterpack.com/\r\n"
		local written = {};
		for name,cfg in pairs(CfgTable) do
			if (not written[name]) then
				write = write.."\r\n["..name.."]\r\n";
				written[name] = true;
			end
			for k,v in pairs(cfg) do
				write = write..tostring(k).." = "..tostring(v).."\r\n";
			end
		end
		CfgBackup("custom_groups")
		if (table.Count(written)>0) then
			file.Write("stargate/cfg/custom_groups.txt",write);
		else
			file.Delete("stargate/cfg/custom_groups.txt");
		end
		StarGate.LoadGroupConfig();
		CfgTable = {};
	elseif(typ==8) then
		RunConsoleCommand("changelevel",game.GetMap());
	elseif(typ==9) then
		local ConvarsTbl = {}
		local cat_count = net.ReadUInt(8);
		if (cat_count>0) then
			for i=1,cat_count do
				local cat = net.ReadString();
				local count = net.ReadUInt(16);
				if (count>0) then
					ConvarsTbl[cat] = {};
					for c=1,count do
						ConvarsTbl[cat][net.ReadString()] = net.ReadDouble();
					end
				end
			end
		end
		local write = "# Config generated using Cap Limits from Stargate Settings Menu.\r\n";
		write = write.."# Config generator created by AlexALX (c) 2014\r\n"
		write = write.."# Carter Addon Pack - http://sg-carterpack.com/\r\n"
		local written = {};
		for name,cfg in pairs(ConvarsTbl) do
			if (not written[name]) then
				write = write.."\r\n["..name.."]\r\n";
				written[name] = true;
			end
			for k,v in pairs(cfg) do
				write = write..tostring(k).." = "..tostring(v).."\r\n";
			end
		end
		CfgBackup("convars")
		if (table.Count(written)>0) then
			file.Write("stargate/cfg/convars.txt",write);
		else
			file.Delete("stargate/cfg/convars.txt");
		end
	elseif(typ==10) then
		CfgBackup("convars")
		file.Delete("stargate/cfg/convars.txt");
	elseif(typ==11) then
		local action = net.ReadUInt(4)
		local vfiles = {"custom_config[%d]+.txt","custom_groups[%d]+.txt","convars[%d]+.txt"}
		if (action==1) then
			local rmf = net.ReadTable()
			for k,v in pairs(rmf) do
				local allow = false
				for i,vf in pairs(vfiles) do
					if k:find(vf) then 
						allow = true
						break
					end
				end
				if (allow) then
					file.Delete("stargate/cfg/backup/"..k)
				end
			end
		elseif (action==2) then
			local fil = net.ReadString()
			local allow = false
			for i,vf in pairs(vfiles) do
				if fil:find(vf) then 
					allow = true
					break
				end
			end
			if (allow and file.Exists("stargate/cfg/backup/"..fil,"DATA")) then
				net.Start("_sg_config");
				net.WriteUInt(5,8);
				net.WriteUInt(1,4);
				net.WriteString(file.Read("stargate/cfg/backup/"..fil,"DATA"))
				net.Send(ply);
			end
		elseif (action==3) then
			local fil = net.ReadString()
			local allow = false
			for i,vf in pairs(vfiles) do
				if fil:find(vf) then 
					allow = true
					break
				end
			end
			if (allow and file.Exists("stargate/cfg/backup/"..fil,"DATA")) then
				if (fil:find("custom_config")) then
					file.Write("stargate/cfg/custom_config.txt",file.Read("stargate/cfg/backup/"..fil,"DATA"));
					StarGate.LoadConfig();
				elseif (fil:find("custom_groups")) then
					file.Write("stargate/cfg/custom_groups.txt",file.Read("stargate/cfg/backup/"..fil,"DATA"));
					StarGate.LoadGroupConfig();
				elseif (fil:find("convars")) then
					local oldc = {}
					local ini = INIParser:new("stargate/cfg/convars.txt",false);
					if(ini) then
						if (ini.nodes.cap_convars and ini.nodes.cap_convars[1]) then
							for k,v in pairs(ini.nodes.cap_convars[1]) do
								if (StarGate.CAP_Convars[k] or k:find("sbox_max")) then -- for security
									oldc[k] = convars_cache[k];
								end
							end
						end
					end
					file.Write("stargate/cfg/convars.txt",file.Read("stargate/cfg/backup/"..fil,"DATA"));
					local ref = StarGate.LoadConvars()
					for k,v in pairs(oldc) do
						if ref[k]==nil then
							RunConsoleCommand(k,convars_cache[k]);
							ref[k] = convars_cache[k]
						end
					end
					
					net.Start("_sg_convars")
					net.WriteUInt(1,4)
					net.WriteUInt(table.Count(ref),8);
					for k,v in pairs(ref) do
						net.WriteString(k);
						net.WriteUInt(v,20);
					end
					net.Send(ply)
				end
			end
		else
			net.Start("_sg_config");
			net.WriteUInt(5,8);
			net.WriteUInt(0,4);
			local files = {}
			local vfiles = {"custom_config*.txt","custom_groups*.txt","convars*.txt"}
			for i,vf in pairs(vfiles) do
				local f, d = file.Find("stargate/cfg/backup/"..vf, "DATA")
				for k,v in pairs(f) do
					files[v] = true
				end
			end
			net.WriteTable(files)		
			net.Send(ply);
		end
	end
end)

else -- CLIENT

local sg_convars = {};
local sg_def_convars = {};
CapPanel = CapPanel or nil;

local function SGGetConvar(convar)
	return sg_convars[convar] or 0;
end

local function SGSetConvar(convar,value)
	if (LocalPlayer():IsAdmin()) then
		net.Start("_sg_convars")
		net.WriteBit(false)
		net.WriteString(convar)
		net.WriteUInt(value or 0, 20)
		net.SendToServer()
	else
		GAMEMODE:AddNotify("You are not admin!", NOTIFY_ERROR, 5); surface.PlaySound( "buttons/button2.wav" );
	end
end

local function SG_Settings_Open()
	if (not LocalPlayer():IsAdmin()) then GAMEMODE:AddNotify("You are not admin!", NOTIFY_ERROR, 5); surface.PlaySound( "buttons/button2.wav" ); return end
	if (CapPanel and IsValid(CapPanel)) then CapPanel:Remove() end

	sg_convars = {}
	net.Start("_sg_convars")
	net.WriteBit(true)
	net.SendToServer()
end

local function SetupConvars(tbl,prep,app)
	prep = prep or "";
	app = app or "";
	--local rtbl = {};
	for k,val in pairs(tbl) do
		local name = prep..val[2]..app;
		tbl[k] = {SGLanguage.GetMessage(val[1]),name,sg_def_convars[name] or 0,val[3]};
		--table.insert(rtbl,{SGLanguage.GetMessage(val[1]),val[2],sg_def_convars[val[2]] or 0,val[3]});
	end
	--tbl = rtbl;
end

local function SG_Settings_OpenNet()
	local sizew,sizeh = 600,460;

	local limits = {
		{"stargate_cap_menu_01", "destsmall"},
		{"stargate_cap_menu_02", "destmedium"},
		{"stargate_cap_menu_03", "destmain"},
		{"stargate_cap_menu_04", "ioncannon"},
		{"stargate_cap_menu_05", "shiprail"},
		{"stargate_cap_menu_06", "statrail"},
		{"stargate_cap_menu_08", "launchdrone"},
		{"stargate_cap_menu_09", "minidrone"},
		{"stargate_cap_menu_10", "asgbeam"},
		{"stargate_cap_menu_11", "ag3"},
		{"stargate_cap_menu_12", "overloader"},
		{"stargate_cap_menu_13", "asuran_beam"},
		{"stargate_cap_menu_15", "ori_beam"},
		{"stargate_cap_menu_16", "dakara"},
		{"stargate_cap_menu_17", "dirn"},
		{"stargate_cap_menu_18", "horizon"},
		{"stargate_cap_menu_19", "ori"},
		{"stargate_cap_menu_20", "staffstat"},
		{"stargate_cap_menu_21", "dispenser"},
		{"stargate_cap_menu_22", "destcon"},
		{"stargate_cap_menu_23", "applecore"},
		{"stargate_cap_menu_24", "lantholo"},
		{"stargate_cap_menu_25", "shieldcore"},
		{"stargate_cap_menu_26", "sod_obelisk"},
		{"stargate_cap_menu_27", "anc_obelisk"},
		{"entity_mcd", "mcd"},
		{"stargate_cap_menu_39", "ships"},
		{"stargate_cap_menu_40", "iris_comp"},
		{"weapon_misc_virus", "agv"},
	}
	SetupConvars(limits,"CAP_","_max");

	local sboxlimits = {
		{"stargate_cap_sbox_01", "anim_ramps"},
		{"stargate_cap_sbox_02", "ramp"},
		{"stargate_cap_sbox_03", "asuran_zpm_hub"},
		{"stargate_cap_menu_07", "ashen_defence"},
		{"stargate_cap_sbox_04", "zpmhub"},
		{"stargate_cap_sbox_05", "sgc_zpm_hub"},
		{"stargate_cap_sbox_06", "bearing"},
		{"stargate_cap_sbox_07", "brazier"},
		{"stargate_cap_sbox_08", "cap_doors_contr"},
		{"stargate_cap_sbox_09", "cap_doors_frame"},
		{"stargate_cap_sbox_10", "cap_console"},
		{"stool_controlpanel", "control_panel"},
		{"stargate_cap_sbox_11", "drone_launcher"},
		{"stargate_cap_sbox_12", "floorchevron"},
		{"stargate_cap_sbox_13", "stargate_iris"},
		{"stargate_cap_sbox_28", "goauld_iris"},
		{"stargate_cap_sbox_14", "gravitycontroller"},
		{"stargate_cap_sbox_15", "jamming_device"},
		{"stargate_cap_sbox_16", "naq_gen_mks"},
		{"stargate_cap_menu_14", "naquadah_bomb"},
		{"stargate_cap_sbox_17", "staff_weapon_glider"},
		{"stargate_cap_sbox_18", "cloaking_generator"},
		{"stargate_cap_sbox_19", "mobile_dhd"},
		{"stargate_cap_sbox_27", "supergate_dhd"},
		{"stargate_cap_sbox_20", "shield_generator"},
		{"stargate_cap_sbox_21", "tampered_zpm"},
		{"stargate_cap_sbox_22", "tokra_emmiter"},
		{"stargate_cap_sbox_23", "tokra_key"},
		{"stargate_cap_sbox_24", "tollan_disabler"},
		{"stargate_cap_sbox_25", "wraith_harvester"},
		{"stargate_cap_sbox_26", "zpm_mk3"},
		{"stool_naq_bottle", "naquadah_bottle"},
		{"stool_sgcscreen", "sgc_monitor"},
		{"stool_sgcscreen_srv", "sgc_server"},
	}
	SetupConvars(sboxlimits,"sbox_max");

	local allowdialgroup = {
		{"stargate_menu_01", "stargate_candial_groups_menu"},
		{"stargate_menu_02", "stargate_candial_groups_dhd"},
		{"stargate_menu_03", "stargate_candial_groups_wire"}
	}
	SetupConvars(allowdialgroup);

	local sgsettings = {
		{"stargate_menu_04", "stargate_different_dial_menu"},
		{"stargate_menu_05", "stargate_energy_dial"},
		{"stargate_menu_06", "stargate_energy_dial_spawner"},
		{"stargate_menu_28", "stargate_energy_target"},
		{"stargate_menu_21", "stargate_protect", 1},
		{"stargate_menu_22", "stargate_protect_spawner", 1},
		{"stargate_menu_33", "stargate_atlantis_override"},
		{"stargate_menu_34", "stargate_gatespawner_enabled"},
		{"stargate_menu_34b", "stargate_gatespawner_protect"},
		{"stargate_menu_38", "stargate_model_clipping"},
		{"stargate_menu_36", "stargate_physics_clipping"},
		{"stargate_menu_41", "stargate_random_address"},
	}
	SetupConvars(sgsettings);

	local dhdsettings = {
		{"stargate_menu_07", "stargate_dhd_protect", 1},
		{"stargate_menu_08", "stargate_dhd_protect_spawner", 1},
		{"stargate_menu_09", "stargate_dhd_destroyed_energy"},
		{"stargate_menu_10", "stargate_dhd_close_incoming"},
		{"stargate_menu_31", "stargate_dhd_menu"},
		{"stargate_menu_32", "stargate_dhd_letters"},
		{"stargate_menu_35", "stargate_dhd_ring"},
	}
	SetupConvars(dhdsettings);

	CapPanel = vgui.Create( "EditablePanel" );
	CapPanel:SetPaintBackgroundEnabled( false );
	CapPanel:SetPaintBorderEnabled( false );
	CapPanel:SetSize(sizew+10,sizeh+10);
	CapPanel:Center();
	CapPanel:MakePopup();

	local PropertySheet = vgui.Create( "DPropertySheet", CapPanel )
	PropertySheet:SetPos( 5, 5 )
	PropertySheet:SetSize( sizew, sizeh )
	PropertySheet.tabScroller:DockMargin( 0, 0, 20, 0 )
	-- fix for fade
	PropertySheet.CrossFade = function(self, anim, delta, data )

		local old = data.OldTab:GetPanel()
		local new = data.NewTab:GetPanel()
		if ( anim.Finished ) then

			old:SetVisible( false )
			new:SetAlpha( 255 )

			old:SetZPos( 0 )
			new:SetZPos( 0 )
			return
		end

		if ( anim.Started ) then

			old:SetZPos( 0 )
			new:SetZPos( 1 )

			old:SetAlpha( 255 )
			new:SetAlpha( 0 )

		end

		old:SetVisible( true )
		new:SetVisible( true )

		old:SetAlpha( 255 * (1-delta) )
		new:SetAlpha( 255 * delta )

	end
	PropertySheet.animFade = Derma_Anim( "Fade", PropertySheet, PropertySheet.CrossFade )

	PropertySheet.CloseButton = vgui.Create( "DImageButton", CapPanel)
	PropertySheet.CloseButton:SetImage( "icon16/cross.png" )
	--PropertySheet.CloseButton:SetColor( Color( 10, 10, 10, 200 ) );
	--PropertySheet.CloseButton:DockMargin( 0, 0, 0, 12 )
	PropertySheet.CloseButton:SetSize( 16, 16 )
	--PropertySheet.CloseButton:Dock( RIGHT )
	PropertySheet.CloseButton:SetPos(sizew-12,7);
	PropertySheet.CloseButton.DoClick = function() CapPanel:Remove() end

	local AdminFrame = vgui.Create("DPanel");
	AdminFrame.Paint = function(self)

		// Thanks Overv, http://www.facepunch.com/threads/1041686-What-are-you-working-on-V4-John-Lua-Edition

		// Background
		/*surface.SetMaterial( matBlurScreen )
		surface.SetDrawColor( 255, 255, 255, 255 )

		matBlurScreen:SetFloat( "$blur", 5 )

		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect( -ScrH()/10, -ScrH()/10, ScrW(), ScrH() )

		surface.SetDrawColor( 100, 100, 100, 150 )
		surface.DrawRect( 0, 0, ScrW(), ScrH() )

		// Border
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawOutlinedRect( 0, 0, CapConvarFrame:GetWide(), CapConvarFrame:GetTall() )
             */
		// Small frames
		local alpha = self:GetAlpha();
		local col = Color( 170, 170, 170, alpha);
		local col2 = Color( 100, 100, 100, alpha);
		local bor = 6;
		local diff = 2;

		draw.RoundedBox( bor, 5-diff, 5-diff, 200+2*diff, 120+2*diff, col);
		draw.RoundedBox( bor, 5, 5, 200, 120, col2);

		draw.RoundedBox( bor, 5-diff, 135-diff, 200+2*diff, 90+2*diff, col);
		draw.RoundedBox( bor, 5, 135, 200, 90, col2);

	end

	local laber = vgui.Create( "DLabel" , AdminFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(10, 10);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_44"));
	laber:SetSize(190, 15);
	laber:SetContentAlignment(5);

	local offset = 30;
	local closeall = vgui.Create("DButton", AdminFrame);
    closeall:SetText(SGLanguage.GetMessage("stargate_menu_37"));
    closeall:SetPos(10, offset);
    closeall:SetSize(190, 25);
	closeall.DoClick = function ( btn )
		SGSetConvar("stargate_close_all");
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_menu_37b"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end
	offset = offset+30;

	local closeall = vgui.Create("DButton", AdminFrame);
    closeall:SetText(SGLanguage.GetMessage("stargate_menu_42"));
    closeall:SetPos(10, offset);
    closeall:SetSize(190, 25);
	closeall.DoClick = function ( btn )
		SGSetConvar("stargate_open_all_iris");
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_menu_42b"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end
	offset = offset+30;

	local closeall = vgui.Create("DButton", AdminFrame);
    closeall:SetText(SGLanguage.GetMessage("stargate_menu_43"));
    closeall:SetPos(10, offset);
    closeall:SetSize(190, 25);
	closeall.DoClick = function ( btn )
		SGSetConvar("stargate_shutdown_shields");
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_menu_43b"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end
	offset = offset+50

	local laber = vgui.Create( "DLabel" , AdminFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(10, offset);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_45"));
	laber:SetSize(190, 15);
	laber:SetContentAlignment(5);
	offset = offset+20

	local dospawner = vgui.Create("DButton", AdminFrame);
    dospawner:SetText(SGLanguage.GetMessage("stargate_menu_19"));
    dospawner:SetPos(10, offset);
    dospawner:SetSize(190, 25);
	dospawner.DoClick = function ( btn )
		SGSetConvar("stargate_gatespawner_createfile");
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_menu_20"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end
	offset = offset+30;

	local reloadbut = vgui.Create("DButton", AdminFrame);
    reloadbut:SetText(SGLanguage.GetMessage("stargate_menu_40"));
    reloadbut:SetPos(10, offset);
    reloadbut:SetSize(190, 25);
	reloadbut.DoClick = function ( btn )
		SGSetConvar("stargate_gatespawner_reload");
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_menu_40b"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end

	local GroupConvarFrame = vgui.Create("DPanel");
	GroupConvarFrame.Paint = function(self)

		// Small frames
		local alpha = self:GetAlpha();
		local col = Color( 170, 170, 170, alpha);
		local col2 = Color( 100, 100, 100, alpha);
		local bor = 6;
		local diff = 2;

		draw.RoundedBox( bor, 5-diff, 5-diff, 200+2*diff, 280+2*diff, col);
		draw.RoundedBox( bor, 5, 5, 200, 280, col2);

		draw.RoundedBox( bor, 210-diff, 5-diff, 200+2*diff, 180+2*diff, col);
		draw.RoundedBox( bor, 210, 5, 200, 180, col2);

		draw.RoundedBox( bor, 210-diff, 190-diff, 200+2*diff, 95+2*diff, col);
		draw.RoundedBox( bor, 210, 190, 200, 95, col2);

		draw.RoundedBox( bor, 415-diff, 5-diff, 165+2*diff, 87+2*diff, col);
		draw.RoundedBox( bor, 415, 5, 165, 87, col2);

		draw.RoundedBox( bor, 415-diff, 97-diff, 165+2*diff, 45+2*diff, col);
		draw.RoundedBox( bor, 415, 97, 165, 45, col2);

	end

	-- Energy check
	local has_energy = util.tobool(SGGetConvar("stargate_has_rd"));

	local frame = vgui.Create("DPanel",GroupConvarFrame);
	frame.Paint = function(self)
		// Small frames
		local alpha = self:GetAlpha();
		local col = Color( 170, 170, 170, alpha);
		local col2 = Color( 100, 100, 100, alpha);
		local bor = 6;
		local diff = 2;
		draw.RoundedBox( bor, 0, 0, self:GetWide(), self:GetTall(), col);
		draw.RoundedBox( bor, diff, diff, self:GetWide()-2*diff, self:GetTall()-2*diff, col2);
	end

	local img = vgui.Create("DImage",frame);
	img:SetPos(8,0);
	if (has_energy) then
		img:SetImage("icon16/accept.png");
	else
		img:SetImage("icon16/error.png");
	end
	img:SetSize(16,16);

	local laber = vgui.Create("DLabel",frame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(30, 0);
	if (has_energy) then
		laber:SetText(SGLanguage.GetMessage("stargate_menu_25b"));
	else
		laber:SetText(SGLanguage.GetMessage("stargate_menu_25"));
	end
	laber:SizeToContents();

	frame:SizeToChildren(true,true);
	frame:SetSize(frame:GetWide()+15,frame:GetTall()+15);
	frame:SetPos(sizew/2-frame:GetWide()/2,305);

	local x,y = laber:GetSize();
	laber:SetPos(30,frame:GetTall()/2-y/2);
	img:SetPos(8,frame:GetTall()/2-7);

	-- End of energy check

	local frame = vgui.Create("DPanel",GroupConvarFrame);
	frame.Paint = function(self)
		// Small frames
		local alpha = self:GetAlpha();
		local col = Color( 170, 170, 170, alpha);
		local col2 = Color( 100, 100, 100, alpha);
		local bor = 6;
		local diff = 2;
		draw.RoundedBox( bor, 0, 0, self:GetWide(), self:GetTall(), col);
		draw.RoundedBox( bor, diff, diff, self:GetWide()-2*diff, self:GetTall()-2*diff, col2);
	end

	local img = vgui.Create("DImage",frame);
	img:SetPos(8,0);
	img:SetImage("icon16/information.png");
	img:SetSize(16,16);

	local laber = vgui.Create("DLabel",frame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(30, 0);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_info"));
	laber:SizeToContents();

	frame:SizeToChildren(true,true);
	frame:SetSize(frame:GetWide()+15,frame:GetTall()+15);
	frame:SetPos(sizew/2-frame:GetWide()/2,360);

	local x,y = laber:GetSize();
	laber:SetPos(30,frame:GetTall()/2-y/2);
	img:SetPos(8,frame:GetTall()/2-7);

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(20, 10);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_12"));
	laber:SizeToContents();

	local i = 0;
	local boxes = {}
	for k,val in pairs(sgsettings) do
		i = i + 1;

		local box = vgui.Create( "DCheckBoxLabel" , GroupConvarFrame);
		boxes[i] = box;
		box:SetPos(15, 10+16*i);
		box:SetText(val[1]);
		box.Label:SetFont("OldDefaultSmall");
		if (val[4]==1) then
			local v = 1;
			if (SGGetConvar(val[2])==1) then v = 0; end
			box:SetValue(v);
		else
			box:SetValue(SGGetConvar(val[2]));
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
		if ((k==2 or k==3 or k==4) and not has_energy) then
			box:SetDisabled(true);
			box:SetTextColor(Color(128,128,128));
			box:SetValue(0);
		elseif ((k==3 or k==6 or k==9 or k==11) and not boxes[k-1]:GetChecked()) then
			box:SetDisabled(true);
		end
		box.OnChange = function(box, fValue)
			local fval = fValue
			if (val[4]==1) then fval = not fval; end
			local v = 0;
			if fval then v = 1; end
			SGSetConvar(val[2], v);
			if (k==2 or k==5 or k==8 or k==10) then
				boxes[k+1]:SetDisabled(not fValue);
			end
		end
	end

	local offset = 10+16*i;

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(20, offset+15);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_13"));
	laber:SizeToContents();

	local slider = vgui.Create( "DOldNumSlider" , GroupConvarFrame);
	slider:SetPos(15, offset+30);
	slider:SetSize(185, 50);
	slider:SetText(SGLanguage.GetMessage("stargate_menu_14"));
	slider:SetMin(0);
	slider:SetMax(32000);
	slider:SetValue(SGGetConvar("stargate_sgu_find_range"));
	slider:SetDecimals(0);
	slider:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint","stargate_sgu_find_range"));
	slider.OnValueChanged = function(Size_x, fValue)
		SGSetConvar("stargate_sgu_find_range", fValue);
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
	laber:SetPos(220, 10);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_16"));
	laber:SizeToContents();

	i = 0;
	local boxes = {}
	for k,val in pairs(dhdsettings) do
		i = i + 1;

		local box = vgui.Create( "DCheckBoxLabel" , GroupConvarFrame);
		boxes[i] = box;
		box:SetPos(215, 10+17*i);
		box:SetText(val[1]);
		box.Label:SetFont("OldDefaultSmall");
		if (val[4]==1) then
			local v = 1;
			if (SGGetConvar(val[2])==1) then v = 0; end
			box:SetValue(v);
		else
			box:SetValue(SGGetConvar(val[2]));
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
		if (k==3 and not has_energy) then
			box:SetDisabled(true);
			box:SetTextColor(Color(128,128,128));
			box:SetValue(0);
		elseif (k==2 and not boxes[k-1]:GetChecked()) then
			box:SetDisabled(true);
		end
		box.OnChange = function(box, fValue)
			local fval = fValue
			if (val[4]==1) then fval = not fval; end
			local v = 0;
			if fval then v = 1; end
			SGSetConvar(val[2], v);
			if (k==1) then
				boxes[k+1]:SetDisabled(not fValue);
			end
		end
	end

	local offset = 10+17*i;

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(220, offset+17);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_17"));
	laber:SizeToContents();

	local select = vgui.Create("DMultiChoice", GroupConvarFrame);
    select:SetToolTip(SGLanguage.GetMessage("stargate_menu_18").." "..SGLanguage.GetMessage("stargate_menu_hint","stargate_show_inbound_address"));
    select:SetPos(215, offset+32);
    select:SetSize(190, 20);
    select:SetEditable(false);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_18a"),2);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_18b"),1);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_18c"),0);
    if (SGGetConvar("stargate_show_inbound_address")==2) then
		select:ChooseOptionID(1);
    elseif (SGGetConvar("stargate_show_inbound_address")==1) then
		select:ChooseOptionID(2);
    else
		select:ChooseOptionID(3);
    end
	select.OnSelect = function(panel,index,value,data)
		SGSetConvar("stargate_show_inbound_address", Format("%d", data));
	end

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(220, offset+65);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_11"));
	laber:SizeToContents();

	local i = 0;
	for _,val in pairs(allowdialgroup) do
		i = i + 1;

		local box = vgui.Create( "DCheckBoxLabel" , GroupConvarFrame);
		box:SetPos(215, offset+63+22*i);
		box:SetText(val[1]);
		box.Label:SetFont("OldDefaultSmall");
		if (val[4]==1) then
			local v = 1;
			if (SGGetConvar(val[2])==1) then v = 0; end
			box:SetValue(v);
		else
			box:SetValue(SGGetConvar(val[2]));
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
			SGSetConvar(val[2], v);
		end
	end

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(425, 10);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_26"));
	laber:SizeToContents();

	local select = vgui.Create("DMultiChoice", GroupConvarFrame);
    select:SetToolTip(SGLanguage.GetMessage("stargate_menu_27").." "..SGLanguage.GetMessage("stargate_menu_hint","stargate_block_address"));
    select:SetPos(420, 25);
    select:SetSize(155, 20);
    select:SetEditable(false);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_27a"),2);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_27b"),1);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_27c"),0);
    if (SGGetConvar("stargate_block_address")==2) then
		select:ChooseOptionID(1);
    elseif (SGGetConvar("stargate_block_address")==1) then
		select:ChooseOptionID(2);
    else
		select:ChooseOptionID(3);
    end
	select.OnSelect = function(panel,index,value,data)
		SGSetConvar("stargate_block_address", Format("%d", data));
	end

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(425, 50);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_29"));
	laber:SizeToContents();

	local select = vgui.Create("DMultiChoice", GroupConvarFrame);
    select:SetToolTip(SGLanguage.GetMessage("stargate_menu_30").." "..SGLanguage.GetMessage("stargate_menu_hint","stargate_vgui_glyphs"));
    select:SetPos(420, 65);
    select:SetSize(155, 20);
    select:SetEditable(false);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_30a"),2);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_30b"),1);
    select:AddChoice(SGLanguage.GetMessage("stargate_menu_30c"),0);
    if (SGGetConvar("stargate_vgui_glyphs")==2) then
		select:ChooseOptionID(1);
    elseif (SGGetConvar("stargate_vgui_glyphs")==1) then
		select:ChooseOptionID(2);
    else
		select:ChooseOptionID(3);
    end
	select.OnSelect = function(panel,index,value,data)
		SGSetConvar("stargate_vgui_glyphs", Format("%d", data));
	end

	local laber = vgui.Create( "DLabel" , GroupConvarFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(425, 100);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_23"));
	laber:SizeToContents();

	local system = vgui.Create("DMultiChoice", GroupConvarFrame);
    system:SetToolTip(SGLanguage.GetMessage("stargate_menu_24").." "..SGLanguage.GetMessage("stargate_menu_hint","stargate_group_system"));
    system:SetPos(420, 115);
    system:SetSize(150, 20);
    system:SetEditable(false);
    system:AddChoice("Group System",1);
    system:AddChoice("Galaxy System",0);
    if (SGGetConvar("stargate_group_system")==1) then
		system:ChooseOptionID(1);
    else
		system:ChooseOptionID(2);
    end
	system.OnSelect = function(panel,index,value,data)
		--if (SGGetConvar("stargate_group_system")!=data) then
			LocalPlayer():ChatPrint(SGLanguage.GetMessage("stargate_reload_start"));
			SGSetConvar("stargate_group_system", Format("%d", data));
		--end
	end

	local img = vgui.Create("DImageButton", GroupConvarFrame)
	img:SetPos(428,145);
	img:SetSize(140,140);
	img:SetImage("gui/update_checker/cap");
	img:SetToolTip(SGLanguage.GetMessage("stargate_menu_48"));
	img.DoClick = function()
		gui.OpenURL(StarGate.HTTP.NEWS);
	end

	/*GroupConvarFrame.OnKeyCodePressed = function(self,key)
		if (key==64) then self:Close(); end
	end*/

	local CapConvarFrame = vgui.Create("DPanel");
	CapConvarFrame.Paint = function(self)
		// Small frames
		local alpha = self:GetAlpha();
		local col = Color( 170, 170, 170, alpha);
		local col2 = Color( 100, 100, 100, alpha);
		local bor = 6;
		local diff = 2;

		draw.RoundedBox( bor, 5-diff, 20-diff, 280+2*diff, sizeh-93+2*diff, col);
		draw.RoundedBox( bor, 5, 20, 280, sizeh-93, col2);

		draw.RoundedBox( bor, 300-diff, 20-diff, 280+2*diff, sizeh-93+2*diff, col);
		draw.RoundedBox( bor, 300, 20, 280, sizeh-93, col2);
	end

	local CapConvarsTbl = {}
	local function SetCapConvar(typ,id,convar,value)
		local tbl,cat = limits,"cap_convars";
		if (typ=="sbox") then tbl,cat = sboxlimits,"cap_convars"; end
		if (not CapConvarsTbl[cat]) then CapConvarsTbl[cat] = {}; end
		if (tbl[id] and tbl[id][3]) then
			local val = tonumber(value) or tbl[id][3]
			if (tbl[id][3]!=val) then
				CapConvarsTbl[cat][convar] = tonumber(value) or tbl[id][3];
			else
				CapConvarsTbl[cat][convar] = nil;
			end
		end
	end

	local limit_sliders = {}

	local DVScrollBar = vgui.Create( "DScrollPanel", CapConvarFrame )
	DVScrollBar:SetPos(10, 20);
	DVScrollBar:SetSize(270,sizeh-93);
	DVScrollBar.VBar:DockMargin(0,5,0,5);
	local i = 0;
	for k,val in pairs(limits) do
		local convar = val[2];

		local slider = vgui.Create( "DOldNumSlider" , DVScrollBar);
		slider.ConvarID = k;
		limit_sliders[convar] = slider;
		slider:SetPos(5, 5+40*i);
		slider:SetSize(245, 50);
		slider:SetText(val[1]);
		slider:SetMin(0);
		slider:SetMax(val[3]*5);
		slider:SetDecimals(0);
		slider.Wang:SetText(SGGetConvar(convar));
		slider:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint",convar));
		slider.OnValueChanged = function(self, fValue)
			if not self.NoSend then
				SGSetConvar(convar, fValue);
			end
			SetCapConvar("cap",self.ConvarID,convar,fValue);
		end
		slider.Wang.OnTextChanged = function(self)
			slider:ValueChanged(slider.Wang:GetValue());
		end
		SetCapConvar("cap",k,convar,SGGetConvar(convar));
		i = i + 1;
	end

	local lframe = vgui.Create( "DPanel" , CapConvarFrame);
	lframe:SetPos(15, 0);
	lframe:SetSize(250,15);

	local laber = vgui.Create( "DLabel" , lframe);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(15, 0);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_46"));
	laber:SizeToContents();
	laber:SetColor(Color(0,0,0));
	laber:Center();

	local lframe = vgui.Create( "DPanel" , CapConvarFrame);
	lframe:SetPos(310, 0);
	lframe:SetSize(250,15);

	local laber = vgui.Create( "DLabel" , lframe);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(15, 0);
	laber:SetText(SGLanguage.GetMessage("stargate_menu_47"));
	laber:SizeToContents();
	laber:SetColor(Color(0,0,0));
	laber:Center();

	local DVScrollBar = vgui.Create( "DScrollPanel", CapConvarFrame )
	DVScrollBar:SetPos(305, 20);
	DVScrollBar:SetSize(270,sizeh-93);
	DVScrollBar.VBar:DockMargin(0,5,0,5);
	i = 0;
	
	if (game.SinglePlayer()) then
		local img = vgui.Create("DImage",DVScrollBar);
		img:SetPos(0,10);
		img:SetImage("icon16/information.png");
		img:SetSize(16,16);
	
		local laber = vgui.Create( "DLabel" , DVScrollBar);
		laber:SetFont("OldDefaultSmall");
		laber:SetPos(19, 10);
		laber:SetText(SGLanguage.GetMessage("stargate_menu_sp"));
		laber:SizeToContents();
		--laber:SetColor(Color(0,0,0));
		--laber:Center();
		i = i+1;
	end
	
	for k,val in pairs(sboxlimits) do
		local convar = val[2];

		local slider = vgui.Create( "DOldNumSlider" , DVScrollBar);
		slider.ConvarID = k;
		limit_sliders[convar] = slider;
		slider:SetPos(5, 5+40*i);
		slider:SetSize(245, 50);
		slider:SetText(val[1]);
		slider:SetMin(0);
		slider:SetMax(val[3]*5);
		slider:SetDecimals(0);
		slider.Wang:SetText(SGGetConvar(convar));
		slider:SetToolTip(SGLanguage.GetMessage("stargate_menu_hint",convar));
		slider.OnValueChanged = function(self, fValue)
			if not self.NoSend then
				SGSetConvar(convar, fValue);
			end
			SetCapConvar("sbox",self.ConvarID,convar,fValue);
		end
		slider.Wang.OnTextChanged = function(self)
			if self.NoSend then return end
			slider:ValueChanged(slider.Wang:GetValue());
		end
		SetCapConvar("sbox",k,convar,SGGetConvar(convar));
		i = i + 1;
	end
	
	CapPanel.LimitSliders = limit_sliders

	local Frame = CapConvarFrame;
	local cfgbutton = vgui.Create("DButton", Frame);
	cfgbutton:SetText(SGLanguage.GetMessage("stargate_cfg_restore_con"));
	cfgbutton:SetImage("icon16/server_delete.png");
	cfgbutton:SetPos(0, 395);
	cfgbutton:SetSize(290, 28);
	cfgbutton.DoClick = function ( btn )
		if (lastWarn and IsValid(lastWarn) and lastWarn.Remove) then lastWarn:Remove() end
		local edit = vgui.Create("DFrame",Frame);
		edit:SetSize(400,120);
		edit:SetPos(sizew/2-200,sizeh/2-130);
		--local x,y = data:GetPos();
		--edit:SetPos(sizew/2-200,y)
		edit:SetTitle(SGLanguage.GetMessage("stargate_cfg_restore_con"));
		edit:RequestFocus();
		lastWarn = edit;

		local label = vgui.Create("DLabel",edit);
		label:SetPos(35,35);
		label:SetText(SGLanguage.GetMessage("stargate_cfg_restore_desc_con"));
		label:SizeToContents();

		local img = vgui.Create("DImage",edit);
		img:SetPos(10,47);
		img:SetImage("icon16/error.png");
		img:SetSize(16,16);

		local butt = vgui.Create("DButton",edit);
		butt:SetPos(40,85);
		butt:SetText(SGLanguage.GetMessage("stargate_cfg_restore_cancel"));
		butt:SetSize(150,25);
		butt.DoClick = function(self)
			edit:Remove();
		end

		local butt = vgui.Create("DButton",edit);
		butt:SetPos(210,85);
		butt:SetText(SGLanguage.GetMessage("stargate_cfg_restore_ok"));
		butt:SetSize(150,25);
		butt.DoClick = function(self)
			net.Start("_sg_config")
			net.WriteUInt(10,8);
			net.SendToServer();
			for k,val in pairs(limits) do
				limit_sliders[val[2]]:SetValue(val[3]);
			end
			for k,val in pairs(sboxlimits) do
				limit_sliders[val[2]]:SetValue(val[3]);
			end
			GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_cfg_restored_con"), NOTIFY_GENERIC, 5);
			surface.PlaySound( "buttons/button9.wav" );
			edit:Remove();
		end
		surface.PlaySound("buttons/button2.wav");
	end

	local cfgbutton = vgui.Create("DButton", Frame);
	cfgbutton:SetText(SGLanguage.GetMessage("stargate_cfg_save_con"));
	cfgbutton:SetImage("icon16/disk.png");
	cfgbutton:SetPos(294, 395);
	cfgbutton:SetSize(290, 28);
	cfgbutton.DoClick = function ( btn )
		net.Start("_sg_config");
		net.WriteUInt(9,8);
		net.WriteUInt(table.Count(CapConvarsTbl),8);
		for name,cfg in pairs(CapConvarsTbl) do
			net.WriteString(name);
			net.WriteUInt(table.Count(cfg),16);
			for convar,value in pairs(cfg) do
				net.WriteString(convar);
				net.WriteDouble(value);
			end
		end
		net.SendToServer();
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_cfg_saved_con"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end

	local CfgFrame = vgui.Create("DPanel");
	CfgFrame.Paint = function(self) end

	local CfgPropertySheet = vgui.Create( "DPropertySheet", CfgFrame )
	CfgPropertySheet:SetPos( 1, 0 )
	CfgPropertySheet:SetSize( sizew-17, sizeh-36 )
	-- fix for fade
	CfgPropertySheet.CrossFade = PropertySheet.CrossFade;
	CfgPropertySheet.animFade = Derma_Anim( "Fade", CfgPropertySheet, CfgPropertySheet.CrossFade )

	local CfgEditorFrame = vgui.Create("DPanel");
	CfgEditorFrame.Paint = function(self) end

    local cust = {"ent_groups_only","swep_groups_only","npc_groups_only","tool_groups_only","cap_disabled_ent","cap_disabled_swep","cap_disabled_npc","cap_disabled_tool"};

	CapPanel.CfgEditor = function(self,tbl)
		if (CfgEditorFrame.DProperties) then CfgEditorFrame.DProperties:Clear() end
    	CfgFrame.CfgTable = tbl;
		CfgFrame.SetCfg = function(v,val)
			if (v[3]=="number") then val = tonumber(val)
			elseif (v[3]=="boolean") then val = util.tobool(val) end
			CfgFrame.CfgTable[v[1]][v[2]] = val;
		end
		CfgFrame:UpdateRest();
    	CfgEditorFrame.DProperties = vgui.Create("DProperties", CfgEditorFrame);
    	CfgEditorFrame.DProperties:SetPos(0,0);
    	CfgEditorFrame.DProperties:SetSize( 567, sizeh-100 );
		for name,t in SortedPairs(CfgFrame.CfgTable) do
			if (table.HasValue(cust,name)) then continue end
			local lang_name = name;
			if (SGLanguage.ValidMessage("sg_sets["..name.."]")) then
				lang_name = SGLanguage.GetMessage("sg_sets["..name.."]");
			end
			for k,v in pairs(t) do
				if (k=="SYNC") then continue end
				local lang_key = k;
				if (SGLanguage.ValidMessage("sg_sets["..name.."]["..k.."]")) then
					lang_key = SGLanguage.GetMessage("sg_sets["..name.."]["..k.."]");
				elseif (SGLanguage.ValidMessage("sg_sets_global["..k.."]")) then
					lang_key = SGLanguage.GetMessage("sg_sets_global["..k.."]");
				end
				local typ = type(v);
				local row = CfgEditorFrame.DProperties:CreateRow( lang_name, lang_key );
				local cat = CfgEditorFrame.DProperties:GetCategory(lang_name);
				if (cat) then
					cat.Expand:SetVisible(false);
					cat.Container:DockMargin( 5, 0, 0, 0 )
					if (SGLanguage.ValidMessage("sg_sets["..name.."][desc]")) then
						cat:SetToolTip(SGLanguage.GetMessage("sg_sets["..name.."][desc]"));
					end
				end
				if (typ=="boolean") then
					row:Setup("Boolean");
				elseif(typ=="number") then
					row:Setup("CapNumber");
				else
					row:Setup("Generic",{}); -- ??? whats wrong? why needed second parameter now?
				end
				if (SGLanguage.ValidMessage("sg_sets["..name.."]["..k.."][desc]")) then
					row:SetToolTip(SGLanguage.GetMessage("sg_sets["..name.."]["..k.."][desc]"));
				elseif (SGLanguage.ValidMessage("sg_sets_global["..k.."][desc]")) then
					row:SetToolTip(SGLanguage.GetMessage("sg_sets_global["..k.."][desc]"));
				end
				row:SetValue(v);
				row.KeyType = {name,k,type(v)};
				row.DataChanged = function( self, val )
					CfgFrame.SetCfg(self.KeyType,val)
				end
			end
		end
	end

	local CfgRestFrame = vgui.Create("DPanel");
	CfgRestFrame.Paint = function(self) end

	local lastWarn;

	for i=1,2 do
		local Frame = CfgEditorFrame;
		if (i==2) then Frame = CfgRestFrame end

		local cfgbutton = vgui.Create("DButton", Frame);
	    cfgbutton:SetText(SGLanguage.GetMessage("stargate_cfg_restore"));
		cfgbutton:SetImage("icon16/database_delete.png");
	    cfgbutton:SetPos(0, 363);
	    cfgbutton:SetSize(187, 25);
		cfgbutton.DoClick = function ( btn )
			if (lastWarn and IsValid(lastWarn) and lastWarn.Remove) then lastWarn:Remove() end
			local edit = vgui.Create("DFrame",Frame);
			edit:SetSize(400,120);
			edit:SetPos(sizew/2-200,sizeh/2-130);
			--local x,y = data:GetPos();
			--edit:SetPos(sizew/2-200,y)
			edit:SetTitle(SGLanguage.GetMessage("stargate_cfg_restore"));
			edit:RequestFocus();
			lastWarn = edit;

			local label = vgui.Create("DLabel",edit);
			label:SetPos(35,35);
			label:SetText(SGLanguage.GetMessage("stargate_cfg_restore_desc"));
			label:SizeToContents();

			local img = vgui.Create("DImage",edit);
			img:SetPos(10,47);
			img:SetImage("icon16/error.png");
			img:SetSize(16,16);

			local butt = vgui.Create("DButton",edit);
			butt:SetPos(40,85);
			butt:SetText(SGLanguage.GetMessage("stargate_cfg_restore_cancel"));
			butt:SetSize(150,25);
			butt.DoClick = function(self)
				edit:Remove();
			end

			local butt = vgui.Create("DButton",edit);
			butt:SetPos(210,85);
			butt:SetText(SGLanguage.GetMessage("stargate_cfg_restore_ok"));
			butt:SetSize(150,25);
			butt.DoClick = function(self)
				net.Start("_sg_config")
				net.WriteUInt(3,8);
				net.SendToServer();
				GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_cfg_restored"), NOTIFY_GENERIC, 5);
				surface.PlaySound( "buttons/button9.wav" );
				edit:Remove();
			end
			surface.PlaySound("buttons/button2.wav");
		end

		local cfgbutton = vgui.Create("DButton", Frame);
	    cfgbutton:SetText(SGLanguage.GetMessage("stargate_cfg_reload"));
		cfgbutton:SetImage("icon16/database_refresh.png");
	    cfgbutton:SetPos(190, 363);
	    cfgbutton:SetSize(187, 25);
		cfgbutton.DoClick = function ( btn )
			net.Start("_sg_config")
			net.WriteUInt(4,8);
			net.SendToServer();
			GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_cfg_reloaded"), NOTIFY_GENERIC, 5);
			surface.PlaySound( "buttons/button9.wav" );
		end

		local cfgbutton = vgui.Create("DButton", Frame);
	    cfgbutton:SetText(SGLanguage.GetMessage("stargate_cfg_save"));
		cfgbutton:SetImage("icon16/disk.png");
	    cfgbutton:SetPos(380, 363);
	    cfgbutton:SetSize(187, 25);
		cfgbutton.DoClick = function ( btn )
			if (lastWarn and IsValid(lastWarn) and lastWarn.Remove) then lastWarn:Remove() end

			for name,cfg in pairs(CfgFrame.CfgTable) do
				net.Start("_sg_config")
				net.WriteUInt(1,8);
				net.WriteString(name);
				-- due to bug with floats in writetable i must use this until it will be fixed
				net.WriteUInt(table.Count(cfg),16);
				for k,v in pairs(cfg) do
					net.WriteString(k);
					if (type(v)=="number") then
						net.WriteUInt(0,8);
						net.WriteDouble(v);
					elseif (type(v)=="boolean") then
						net.WriteUInt(1,8);
						net.WriteBit(v);
					else
						net.WriteUInt(2,8);
						net.WriteString(v);
					end
				end
				--net.WriteTable(cfg);
				net.SendToServer();
			end
			net.Start("_sg_config")
			net.WriteUInt(2,8);
			net.SendToServer();
			GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_cfg_saved"), NOTIFY_GENERIC, 5);
			surface.PlaySound( "buttons/button9.wav" );

			local edit = vgui.Create("DFrame",Frame);
			edit:SetSize(490,120);
			edit:SetPos(sizew/2-265,sizeh/2-130);
			--local x,y = data:GetPos();
			--edit:SetPos(sizew/2-200,y)
			edit:SetTitle(SGLanguage.GetMessage("stargate_cfg_saved"));
			edit:RequestFocus();
			lastWarn = edit;

			local label = vgui.Create("DLabel",edit);
			label:SetPos(35,35);
			label:SetText(SGLanguage.GetMessage("stargate_cfg_saved_desc"));
			label:SizeToContents();

			local img = vgui.Create("DImage",edit);
			img:SetPos(10,47);
			img:SetImage("icon16/information.png");
			img:SetSize(16,16);

			local butt = vgui.Create("DButton",edit);
			butt:SetPos(10,85);
			butt:SetText(SGLanguage.GetMessage("stargate_cfg_saved_restart"));
			butt:SetSize(150,25);
			butt.DoClick = function(self)
				net.Start("_sg_config")
				net.WriteUInt(8,8);
				net.SendToServer();
				edit:Remove();
			end

			local butt = vgui.Create("DButton",edit);
			butt:SetPos(170,85);
			butt:SetText(SGLanguage.GetMessage("stargate_cfg_saved_reload"));
			butt:SetSize(150,25);
			butt.DoClick = function(self)
				SGSetConvar("stargate_reload");
				surface.PlaySound( "buttons/button9.wav" );
				edit:Remove();
			end

			local butt = vgui.Create("DButton",edit);
			butt:SetPos(330,85);
			butt:SetText(SGLanguage.GetMessage("stargate_cfg_saved_close"));
			butt:SetSize(150,25);
			butt.DoClick = function(self)
				edit:Remove();
			end
		end
	end

	local CfgGroupFrame = vgui.Create("DPanel");
	CfgGroupFrame.Paint = function(self) end

	local name_tbl = {};
 	local cap_ents = {["ent"] = list.Get("CAP.Entity"),["swep"] = list.Get("CAP.Weapon")}; -- this was best my idea (create own spawnmenu tab), because now i can also use this for menu... @ AlexALX
	for c,e in pairs(cap_ents) do
		name_tbl[c] = {};
		for k,v in pairs(e) do
			if (v.ClassName) then
			 	name_tbl[c][v.ClassName] = v.PrintName or c;
			end
		end
	end

	name_tbl["npc"] = {};
	for k,v in pairs(list.Get("CAP.NPC")) do
		if (v.Name) then
			name_tbl["npc"][k] = v.Name;
		end
	end

	name_tbl["tool"] = {};
	for k,v in pairs(list.Get("CAP.Tool")) do
		if (v.Name) then
			name_tbl["tool"][k] = v.Name;
		end
	end

	local RestScrollBar = vgui.Create( "DScrollPanel", CfgRestFrame )
	RestScrollBar:SetPos(0, 0);
	RestScrollBar:SetSize(567,sizeh-100);

	local rest_types = {["ent_groups_only"]="ent",["swep_groups_only"]="swep",["npc_groups_only"]="npc",["tool_groups_only"]="tool"};
	local y_pos = 0;
	local RestLists,RestListsD = {},{};

	local lastLine;

	for restk,rest in pairs(rest_types) do
		local lframe = vgui.Create( "DPanel" , RestScrollBar);
		lframe:SetPos(0, y_pos);
		lframe:SetSize(547,15);

		local laber = vgui.Create( "DLabel" , lframe);
		laber:SetText(SGLanguage.GetMessage("stargate_cfg_rest_"..rest));
		laber:SizeToContents();
		laber:SetColor(Color(0,0,0));
		laber:Center();

		local RestList = vgui.Create( "DListView", RestScrollBar )
		RestLists[rest.."_groups_only"] = RestList;
		RestList:SetMultiSelect( true )
		RestList:SetPos(0,y_pos+20)
		RestList:SetSize(547,200);
		RestList:AddColumn(SGLanguage.GetMessage("stargate_cfg_rest_name"))
		RestList:AddColumn(SGLanguage.GetMessage("stargate_cfg_rest_group"))
		RestList.DoDoubleClick = function(self,line,data)
			if (lastLine and IsValid(lastLine) and lastLine.Remove) then lastLine:Remove() end
			local edit = vgui.Create("DFrame",CfgRestFrame);
			edit:SetSize(400,150);
			edit:SetPos(sizew/2-200,sizeh/2-130);
			--local x,y = data:GetPos();
			--edit:SetPos(sizew/2-200,y)
			edit:SetTitle(data:GetColumnText(1));
			edit:RequestFocus();
			edit.line = data;
			lastLine = edit;

			local value = data:GetColumnText(2):TrimExplode(",");
			local groups,add_shield,exclude = "",false,false;
			for n,val in pairs(value) do
				if (val=="add_shield") then add_shield = true; continue end
				if (val=="exclude_mod") then exclude = true; continue end
				if (groups!="") then groups = groups..","; end
				groups = groups..val;
			end

			local label = vgui.Create("DLabel",edit);
			label:SetPos(15,30);
			label:SetText(SGLanguage.GetMessage("stargate_cfg_rest_ugroup"));
			label:SizeToContents();

			local text = vgui.Create("DTextEntry",edit);
			text:SetValue(groups);
			text:SetPos(10,50);
			text:SetSize(380,20);

			local check = vgui.Create("DCheckBoxLabel",edit);
			check:SetPos(10,80);
			check:SetText(SGLanguage.GetMessage("stargate_cfg_rest_shield"));
			check:SetValue(add_shield);
			check:SizeToContents();

			local check_exc = vgui.Create("DCheckBoxLabel",edit);
			check_exc:SetPos(10,100);
			check_exc:SetText(SGLanguage.GetMessage("stargate_cfg_rest_exclud"));
			check_exc:SetToolTip(SGLanguage.GetMessage("stargate_cfg_rest_exclud_desc"));
			check_exc:SetValue(exclude);
			check_exc:SizeToContents();

			local butt = vgui.Create("DButton",edit);
			butt:SetPos(130,120);
			butt:SetText(SGLanguage.GetMessage("stargate_cfg_rest_save"));
			butt:SetSize(150,25);
			butt.DoClick = function(self)
				local val = text:GetValue():Trim();
				if (val!="") then
					if (check:GetChecked()) then
						val = val..",add_shield";
					end
					if (check_exc:GetChecked()) then
						val = val..",exclude_mod";
					end
					edit.line:SetColumnText(2,val);
					if (not CfgFrame.CfgTable[rest.."_groups_only"]) then CfgFrame.CfgTable[rest.."_groups_only"] = {} end
					CfgFrame.CfgTable[rest.."_groups_only"][edit.line:GetColumnText(3)] = val;
					edit:Remove();
				end
			end

		end

		local RestDel = vgui.Create("DButton",RestScrollBar);
		RestDel:SetPos(0,y_pos+225);
		RestDel:SetText(SGLanguage.GetMessage("stargate_cfg_rest_del"));
		RestDel:SetImage("icon16/table_delete.png");
		RestDel:SetSize(270,25);
		RestDel.DoClick = function(self)
			if (lastLine and IsValid(lastLine) and lastLine.Remove) then lastLine:Remove() end
			local lines = RestList:GetSelected();
			for k,v in pairs(lines) do
				CfgFrame.CfgTable[rest.."_groups_only"][v:GetColumnText(3)] = "";
				RestList:RemoveLine(v:GetID());
			end
		end

		local lframe = vgui.Create( "DPanel" , RestScrollBar);
		lframe:SetPos(0, y_pos+255);
		lframe:SetSize(547,15);

		local laber = vgui.Create( "DLabel" , lframe);
		laber:SetText(SGLanguage.GetMessage("stargate_cfg_restd_"..rest));
		laber:SizeToContents();
		laber:SetColor(Color(0,0,0));
		laber:Center();

		local RestListD = vgui.Create( "DListView", RestScrollBar )
		RestListsD["cap_disabled_"..rest] = RestListD;
		RestListD:SetMultiSelect( true )
		RestListD:SetPos(0,y_pos+275)
		RestListD:SetSize(547,200);
		RestListD:AddColumn(SGLanguage.GetMessage("stargate_cfg_rest_name"))

		local RestDel = vgui.Create("DButton",RestScrollBar);
		RestDel:SetPos(0,y_pos+480);
		RestDel:SetText(SGLanguage.GetMessage("stargate_cfg_rest_del"));
		RestDel:SetImage("icon16/table_delete.png");
		RestDel:SetSize(270,25);
		RestDel.DoClick = function(self)
			if (lastLine and IsValid(lastLine) and lastLine.Remove) then lastLine:Remove() end
			local lines = RestListD:GetSelected();
			for k,v in pairs(lines) do
				CfgFrame.CfgTable["cap_disabled_"..rest][v:GetColumnText(2)] = "";
				RestListD:RemoveLine(v:GetID());
			end
		end

		local RestAdd = vgui.Create("DButton",RestScrollBar);
		RestAdd:SetPos(277,y_pos+225);
		RestAdd:SetText(SGLanguage.GetMessage("stargate_cfg_rest_add_"..rest));
		RestAdd:SetImage("icon16/table_add.png");
		RestAdd:SetSize(270,25);
		RestAdd.DoClick = function(self)
			if (lastLine and IsValid(lastLine) and lastLine.Remove) then lastLine:Remove() end
			local edit = vgui.Create("DFrame",CfgRestFrame);
			edit:SetSize(400,170);
			edit:SetPos(sizew/2-200,sizeh/2-130);
			edit:SetTitle(SGLanguage.GetMessage("stargate_cfg_rest_add_"..rest));
			edit:RequestFocus();
			lastLine = edit;

			local sel = vgui.Create("DComboBox",edit);
			sel:SetPos(10,30);
			sel:SetSize(380,20);
			sel:SetValue(SGLanguage.GetMessage("stargate_cfg_rest_sel_"..rest))

			local exs_tbl = {}
			for k,v in pairs(RestList:GetLines()) do
				exs_tbl[v:GetColumnText(3)] = true;
			end
			for k,v in pairs(RestListD:GetLines()) do
				exs_tbl[v:GetColumnText(2)] = true;
			end

			for k,v in SortedPairsByValue(name_tbl[rest]) do
				local key = table.KeyFromValue(name_tbl[rest],v);
				if (not exs_tbl[key]) then
					sel:AddChoice(v.." ("..key..")",key);
				end
			end
			sel.OnSelect = function(self,index,name,key)
				self.key = key;
				self.value = name;
			end

			local label = vgui.Create("DLabel",edit);
			label:SetPos(15,55);
			label:SetText(SGLanguage.GetMessage("stargate_cfg_rest_ugroup"));
			label:SizeToContents();

			local text = vgui.Create("DTextEntry",edit);
			text:SetValue("admin,superadmin");
			text:SetPos(10,75);
			text:SetSize(380,20);

			local check = vgui.Create("DCheckBoxLabel",edit);
			check:SetPos(10,100);
			check:SetText(SGLanguage.GetMessage("stargate_cfg_rest_shield"));
			check:SetValue(true);
			check:SizeToContents();

			local check_exc = vgui.Create("DCheckBoxLabel",edit);
			check_exc:SetPos(10,120);
			check_exc:SetText(SGLanguage.GetMessage("stargate_cfg_rest_exclud"));
			check_exc:SetToolTip(SGLanguage.GetMessage("stargate_cfg_rest_exclud_desc"));
			check_exc:SetValue(false);
			check_exc:SizeToContents();

			local butt = vgui.Create("DButton",edit);
			butt:SetPos(130,140);
			butt:SetText(SGLanguage.GetMessage("stargate_cfg_rest_add"));
			butt:SetSize(150,25);
			butt.DoClick = function(self)
				local name = sel.value;
				if (not name) then return end
				local key = sel.key;
				local val = text:GetValue():Trim();
				if (val!="") then
					if (check:GetChecked()) then
						val = val..",add_shield";
					end
					if (check_exc:GetChecked()) then
						val = val..",exclude_mod";
					end
					RestList:AddLine(name,val,key);
					if (not CfgFrame.CfgTable[rest.."_groups_only"]) then CfgFrame.CfgTable[rest.."_groups_only"] = {} end
					CfgFrame.CfgTable[rest.."_groups_only"][key] = val;
					edit:Remove();
				end
			end

		end

		local DRestAdd = vgui.Create("DButton",RestScrollBar);
		DRestAdd:SetPos(277,y_pos+480);
		DRestAdd:SetText(SGLanguage.GetMessage("stargate_cfg_rest_dis_"..rest));
		DRestAdd:SetImage("icon16/table_add.png");
		DRestAdd:SetSize(270,25);
		DRestAdd.DoClick = function(self)
			if (lastLine and IsValid(lastLine) and lastLine.Remove) then lastLine:Remove() end
			local edit = vgui.Create("DFrame",CfgRestFrame);
			edit:SetSize(400,90);
			edit:SetPos(sizew/2-200,sizeh/2-130);
			edit:SetTitle(SGLanguage.GetMessage("stargate_cfg_rest_dis_"..rest));
			edit:RequestFocus();
			lastLine = edit;

			local sel = vgui.Create("DComboBox",edit);
			sel:SetPos(10,30);
			sel:SetSize(380,20);
			sel:SetValue(SGLanguage.GetMessage("stargate_cfg_rest_sel_"..rest))

			local exs_tbl = {}
			for k,v in pairs(RestListD:GetLines()) do
				exs_tbl[v:GetColumnText(2)] = true;
			end

			for k,v in SortedPairsByValue(name_tbl[rest]) do
				local key = table.KeyFromValue(name_tbl[rest],v);
				if (not exs_tbl[key]) then
					sel:AddChoice(v.." ("..key..")",key);
				end
			end
			sel.OnSelect = function(self,index,name,key)
				self.key = key;
				self.value = name;
			end

			local butt = vgui.Create("DButton",edit);
			butt:SetPos(130,60);
			butt:SetText(SGLanguage.GetMessage("stargate_cfg_rest_add"));
			butt:SetSize(150,25);
			butt.DoClick = function(self)
				local name = sel.value;
				if (not name) then return end
				local key = sel.key;
				RestListD:AddLine(name,key);
				if (not CfgFrame.CfgTable["cap_disabled_"..rest]) then CfgFrame.CfgTable["cap_disabled_"..rest] = {} end
				CfgFrame.CfgTable["cap_disabled_"..rest][key] = true;
				edit:Remove();
				for k,v in pairs(RestList:GetLines()) do
					if (v:GetColumnText(3)==key) then
						CfgFrame.CfgTable[rest.."_groups_only"][v:GetColumnText(3)] = "";
						RestList:RemoveLine(v:GetID());
					end
				end
			end

		end

		y_pos = 510 + y_pos;
	end

	CfgFrame.UpdateRest = function(self)
		local rest_types = rest_types;
		rest_types["cap_disabled_ent"] = "ent";
		rest_types["cap_disabled_swep"] = "swep";
		rest_types["cap_disabled_npc"] = "npc";
		rest_types["cap_disabled_tool"] = "tool";
		for restk,rest in pairs(rest_types) do
			local RList,dis = RestLists[restk],false;
			if (restk:find("cap_disabled_")) then RList,dis = RestListsD[restk],true end
			RList:Clear();
			if (self.CfgTable[restk]) then
				for k,v in pairs(self.CfgTable[restk]) do
					if (v=="" or dis and v==false) then continue end
					local cat_name = name_tbl[rest][k] or k;
					if (cat_name!=k) then cat_name = cat_name.." ("..k..")" end
					if (dis) then
						RList:AddLine(cat_name,k);
					else
						RList:AddLine(cat_name,v,k);
					end
				end
			end
		end
	end

	local y_pos = 0;
	local lastLine;
	local GroupLists = {};
	local dgrp = {[1]={"M@","P@","I@","OT","O@"},[2]={"U@#","SGI","DST"}};

	for i=1,2 do
		local grp_type,grp_lang = "stargate_custom_groups","";
		if (i==2) then grp_type,grp_lang = "stargate_custom_types","u"; end

		local lframe = vgui.Create( "DPanel" , CfgGroupFrame);
		lframe:SetPos(0, y_pos);
		lframe:SetSize(567,15);

		local laber = vgui.Create( "DLabel" , lframe);
		laber:SetText(SGLanguage.GetMessage("stargate_cfg_grp_title"..grp_lang));
		laber:SizeToContents();
		laber:SetColor(Color(0,0,0));
		laber:Center();

		local GroupList = vgui.Create( "DListView", CfgGroupFrame )
		GroupLists[grp_type] = GroupList;
		GroupList:SetMultiSelect( true )
		GroupList:SetPos(0,y_pos+20)
		GroupList:SetSize(567,125);
		GroupList:AddColumn(SGLanguage.GetMessage("stargate_cfg_grp_addr"))
		GroupList:AddColumn(SGLanguage.GetMessage("stargate_cfg_grp_name"))
		GroupList.DoDoubleClick = function(self,line,data)
			if (lastLine and IsValid(lastLine) and lastLine.Remove) then lastLine:Remove() end
			local val = data:GetColumnText(1);
			local nams = data:GetColumnText(2);
			local shar = false;
			if (nams:sub(-8)==" !SHARED") then
				shar = true;
				nams = nams:sub(0,-9);
			end
			local edit = vgui.Create("DFrame",CfgGroupFrame);
			if (i==2) then
				edit:SetSize(400,110);
			else
				edit:SetSize(400,90);
			end
			edit:SetPos(sizew/2-200,sizeh/2-130);
			edit:SetTitle(val);
			edit:RequestFocus();
			lastLine = edit;
			edit.line = data;

			local label = vgui.Create("DLabel",edit);
			label:SetPos(15,35);
			label:SetText(SGLanguage.GetMessage("stargate_cfg_grp_add2"..grp_lang));
			label:SizeToContents();

			local name = vgui.Create("DTextEntry",edit);
			name:SetPos(label:GetWide()+20,33);
			name:SetSize(370-label:GetWide(),20);
			name:SetText(nams);
			name:SetAllowNonAsciiCharacters(true);

			local shared
			if (i==2) then
				shared = vgui.Create("DCheckBoxLabel",edit);
				shared:SetPos(15,60);
				shared:SetText(SGLanguage.GetMessage("stargate_cfg_grp_shared"));
				shared:SetToolTip(SGLanguage.GetMessage("stargate_cfg_grp_shared_desc"));
				shared:SetValue(shar);
				shared:SizeToContents();
			end

			local butt = vgui.Create("DButton",edit);
			if (i==2) then
				butt:SetPos(130,80);
			else
				butt:SetPos(130,60);
			end
			butt:SetText(SGLanguage.GetMessage("stargate_cfg_rest_save"));
			butt:SetSize(150,25);
			butt.DoClick = function(self)
				local nam = name:GetValue():Trim();
				if (nam!="") then
					if (i==2 and shared:GetChecked()) then
						nam = nam.." !SHARED";
					end
					edit.line:SetColumnText(2,nam);
					if (not CfgGroupFrame.CfgTable[grp_type]) then CfgGroupFrame.CfgTable[grp_type] = {} end
					CfgGroupFrame.CfgTable[grp_type][val] = nam;
					edit:Remove();
				else
					surface.PlaySound("buttons/button2.wav");
				end
			end

		end

		local RestDel = vgui.Create("DButton",CfgGroupFrame);
		RestDel:SetPos(0,y_pos+150);
		RestDel:SetText(SGLanguage.GetMessage("stargate_cfg_rest_del"));
		RestDel:SetImage("icon16/table_delete.png");
		RestDel:SetSize(280,25);
		RestDel.DoClick = function(self)
			if (lastLine and IsValid(lastLine) and lastLine.Remove) then lastLine:Remove() end
			local lines = GroupList:GetSelected();
			for k,v in pairs(lines) do
				CfgGroupFrame.CfgTable[grp_type][v:GetColumnText(1)] = nil;
				GroupList:RemoveLine(v:GetID());
			end
		end

		local RestAdd = vgui.Create("DButton",CfgGroupFrame);
		RestAdd:SetPos(287,y_pos+150);
		RestAdd:SetText(SGLanguage.GetMessage("stargate_cfg_grp_add"..grp_lang));
		RestAdd:SetImage("icon16/table_add.png");
		RestAdd:SetSize(280,25);
		RestAdd.DoClick = function(self)
			if (lastLine and IsValid(lastLine) and lastLine.Remove) then lastLine:Remove() end
			local edit = vgui.Create("DFrame",CfgGroupFrame);
			if (i==2) then
				edit:SetSize(400,130);
			else
				edit:SetSize(400,110);
			end
			edit:SetPos(sizew/2-200,sizeh/2-130);
			edit:SetTitle(SGLanguage.GetMessage("stargate_cfg_grp_add"..grp_lang));
			edit:RequestFocus();
			lastLine = edit;

			local exs_tbl = {}
			for k,v in pairs(GroupList:GetLines()) do
				exs_tbl[v:GetColumnText(1)] = true;
			end

			local label = vgui.Create("DLabel",edit);
			label:SetPos(15,30);
			label:SetText(SGLanguage.GetMessage("stargate_cfg_grp_add1"..grp_lang));
			label:SizeToContents();

			local warn = vgui.Create("DLabel",edit);
			warn:SetPos(label:GetWide()+60+(i-1)*10,30);
			warn:SetText("");
			warn:SizeToContents();
			warn:SetVisible(false);

			local text = vgui.Create("DTextEntry",edit);
			text:SetPos(label:GetWide()+20,28);
			if (i==2) then
				text:SetSize(40,20);
			else
				text:SetSize(30,20);
			end
			text:SetToolTip(SGLanguage.GetMessage("stargate_cfg_grp_desc"..grp_lang,string.Implode(", ",dgrp[i])))
			text.OnTextChanged = function(TextEntry)
				local text = TextEntry:GetValue();
				local pos = TextEntry:GetCaretPos();
				local len = text:len();
				local letters = text:upper():gsub("[^0-9A-Z@#]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
				local text = ""; -- Wipe
				for k,v in pairs(letters) do
					if(not text:find(v)) then
						text = text..v;
					end
				end
				text = text:sub(1,3);
				if (i==2) then
					if (letters[1]=="#") then text = ""; end
					if (letters[2]=="#") then text = text:sub(1,1); end
				end
				if (table.HasValue(dgrp[i],text) or exs_tbl[text]) then
					text = text:sub(1,i);
					surface.PlaySound("buttons/button2.wav");
					warn:SetVisible(true);
					warn:SetText(SGLanguage.GetMessage("stargate_cfg_grp_err"));
					warn:SizeToContents();
				else
					warn:SetVisible(false);
				end
				TextEntry:SetText(text);
				TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			end

			local label = vgui.Create("DLabel",edit);
			label:SetPos(15,55);
			label:SetText(SGLanguage.GetMessage("stargate_cfg_grp_add2"..grp_lang));
			label:SizeToContents();

			local name = vgui.Create("DTextEntry",edit);
			name:SetPos(label:GetWide()+20,53);
			name:SetSize(370-label:GetWide(),20);
			name:SetAllowNonAsciiCharacters(true);

			local shared
			if (i==2) then
				shared = vgui.Create("DCheckBoxLabel",edit);
				shared:SetPos(15,80);
				shared:SetText(SGLanguage.GetMessage("stargate_cfg_grp_shared"));
				shared:SetToolTip(SGLanguage.GetMessage("stargate_cfg_grp_shared_desc"));
				shared:SetValue(true);
				shared:SizeToContents();
			end

			local butt = vgui.Create("DButton",edit);
			if (i==2) then
				butt:SetPos(130,100);
			else
				butt:SetPos(130,80);
			end
			butt:SetText(SGLanguage.GetMessage("stargate_cfg_rest_add"));
			butt:SetSize(150,25);
			butt.DoClick = function(self)
				local val = text:GetValue():Trim();
				local nam = name:GetValue():Trim();
				if (val:len()==(i+1) and nam!="") then
					if (i==2 and shared:GetChecked()) then
						nam = nam.." !SHARED";
					end
					GroupList:AddLine(val,nam);
					if (not CfgGroupFrame.CfgTable[grp_type]) then CfgGroupFrame.CfgTable[grp_type] = {} end
					CfgGroupFrame.CfgTable[grp_type][val] = nam;
					edit:Remove();
				else
					warn:SetVisible(true);
					warn:SetText(SGLanguage.GetMessage("stargate_cfg_grp_err2"));
					warn:SizeToContents();
					surface.PlaySound("buttons/button2.wav");
				end
			end

		end

		y_pos = 180;
	end

	local cfgbutton = vgui.Create("DButton", CfgGroupFrame);
	cfgbutton:SetText(SGLanguage.GetMessage("stargate_cfg_grp_reload"));
	cfgbutton:SetImage("icon16/database_refresh.png");
	cfgbutton:SetPos(0, 360);
	cfgbutton:SetSize(280, 28);
	cfgbutton.DoClick = function ( btn )
		net.Start("_sg_config")
		net.WriteUInt(7,8);
		net.SendToServer();
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_cfg_grp_reloaded"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end

	local cfgbutton = vgui.Create("DButton", CfgGroupFrame);
	cfgbutton:SetText(SGLanguage.GetMessage("stargate_cfg_grp_save"));
	cfgbutton:SetImage("icon16/disk.png");
	cfgbutton:SetPos(287, 360);
	cfgbutton:SetSize(280, 28);
	cfgbutton.DoClick = function ( btn )
		for name,cfg in pairs(CfgGroupFrame.CfgTable) do
			net.Start("_sg_config")
			net.WriteUInt(1,8);
			net.WriteString(name);
			net.WriteUInt(table.Count(cfg),16);
			for k,v in pairs(cfg) do
				net.WriteString(k);
				net.WriteUInt(2,8);
				net.WriteString(v);
			end
			--net.WriteTable(cfg);
			net.SendToServer();
		end
		net.Start("_sg_config")
		net.WriteUInt(6,8);
		net.SendToServer();
		GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_cfg_grp_saved"), NOTIFY_GENERIC, 5);
		surface.PlaySound( "buttons/button9.wav" );
	end

	CapPanel.CfgGrpEditor = function(self,tbl)
		CfgGroupFrame.CfgTable = tbl;
		for cat,cfg in pairs(tbl) do
			local RList = GroupLists[cat];
			RList:Clear();
			for k,v in pairs(cfg) do
				RList:AddLine(k,v);
			end
		end
	end

	CfgPropertySheet.__SetActiveTab = PropertySheet.SetActiveTab;
	CfgPropertySheet.SetActiveTab = function(self, active)
		if (not CfgPropertySheet.CFGSended and active:GetText()==SGLanguage.GetMessage("stargate_cfg_tab3")) then
			CfgPropertySheet.CFGSended = true;
        	net.Start("_sg_config");
        	net.WriteUInt(5,8);
        	net.SendToServer();
		end
		CfgPropertySheet:__SetActiveTab(active);
	end

	CfgPropertySheet:AddSheet( SGLanguage.GetMessage("stargate_cfg_tab1"), CfgEditorFrame, "icon16/script_edit.png", false, false )
	CfgPropertySheet:AddSheet( SGLanguage.GetMessage("stargate_cfg_tab2"), CfgRestFrame, "icon16/server_edit.png", false, false )
	CfgPropertySheet:AddSheet( SGLanguage.GetMessage("stargate_cfg_tab3"), CfgGroupFrame, "icon16/world_edit.png", false, false )

	local BackupFrame = vgui.Create("DPanel");
	BackupFrame.Paint = function(self)
		// Small frames
		local alpha = self:GetAlpha();
		local col = Color( 170, 170, 170, alpha);
		local col2 = Color( 100, 100, 100, alpha);
		local bor = 6;
		local diff = 2;

		draw.RoundedBox( bor, 5-diff, 5-diff, 577+2*diff, 385+2*diff, col);
		draw.RoundedBox( bor, 5, 5, 577, 385, col2);

	end
	
	local laber = vgui.Create( "DLabel" , BackupFrame);
	laber:SetFont("OldDefaultSmall");
	laber:SetPos(10, 10);
	laber:SetText(SGLanguage.GetMessage("stargate_cfg_backup_title"));
	laber:SetSize(567, 15);
	laber:SetContentAlignment(5);
	--laber:CenterHorizontal()

	local CfgList = vgui.Create( "DListView", BackupFrame )
	CfgList:SetMultiSelect( true )
	CfgList:SetPos(10,30)
	CfgList:SetSize(567,sizeh-105);
	CfgList:AddColumn(SGLanguage.GetMessage("stargate_cfg_backup_file"))
	CfgList.DoDoubleClick = function(self,line,data)
		local val = data:GetColumnText(1);
		CapPanel:OpenCfgView(val,SGLanguage.GetMessage("stargate_cfg_backup_loading"))
		net.Start("_sg_config")
		net.WriteUInt(11,8);
		net.WriteUInt(2,4);
		net.WriteString(val)
		net.SendToServer();
	end
	
	local cfgbutton = vgui.Create("DButton", BackupFrame);
	cfgbutton:SetText(SGLanguage.GetMessage("stargate_cfg_backup_delete"));
	cfgbutton:SetImage("icon16/drive_delete.png");
	cfgbutton:SetPos(10, 395);
	cfgbutton:SetSize(185, 28);
	cfgbutton.DoClick = function ( btn )
		local rmf = {}
		local lines = CfgList:GetSelected();
		for k,v in pairs(lines) do
			rmf[v:GetColumnText(1)] = true;
			CfgList.CfgTable[v:GetColumnText(1)] = nil;
			CfgList:RemoveLine(v:GetID());
		end
		if (table.Count(rmf)>0) then
			net.Start("_sg_config")
			net.WriteUInt(11,8);
			net.WriteUInt(1,4);
			net.WriteTable(rmf)
			net.SendToServer();
		end
	end
	
	local cfgbutton = vgui.Create("DButton", BackupFrame);
	cfgbutton:SetText(SGLanguage.GetMessage("stargate_cfg_backup_view"));
	cfgbutton:SetImage("icon16/drive_magnify.png");
	cfgbutton:SetPos(201, 395);
	cfgbutton:SetSize(185, 28);
	cfgbutton.DoClick = function ( btn )
		local lines = CfgList:GetSelected();
		for k,v in pairs(lines) do
			CfgList:DoDoubleClick(k,v)
			break 
		end
	end


	local cfgbutton = vgui.Create("DButton", BackupFrame);
	cfgbutton:SetText(SGLanguage.GetMessage("stargate_cfg_backup_load"));
	cfgbutton:SetImage("icon16/drive_go.png");
	cfgbutton:SetPos(392, 395);
	cfgbutton:SetSize(185, 28);
	local lastWarn
	cfgbutton.DoClick = function ( btn )
		if (lastWarn and IsValid(lastWarn) and lastWarn.Remove) then lastWarn:Remove() end
		
		local lines = CfgList:GetSelected();
		local fil = ""
		for k,v in pairs(lines) do
			fil = v:GetColumnText(1)
			break 
		end
		if (fil=="") then return end
		
		local edit = vgui.Create("DFrame",BackupFrame);
		edit:SetSize(400,120);
		edit:Center();
		--local x,y = data:GetPos();
		--edit:SetPos(sizew/2-200,y)
		edit:SetTitle(SGLanguage.GetMessage("stargate_cfg_backup_con"));
		edit:RequestFocus();
		lastWarn = edit;

		local label = vgui.Create("DLabel",edit);
		label:SetPos(35,35);
		label:SetText(SGLanguage.GetMessage("stargate_cfg_backup_desc_con",fil));
		label:SizeToContents();

		local img = vgui.Create("DImage",edit);
		img:SetPos(10,47);
		img:SetImage("icon16/error.png");
		img:SetSize(16,16);

		local butt = vgui.Create("DButton",edit);
		butt:SetPos(40,85);
		butt:SetText(SGLanguage.GetMessage("stargate_cfg_backup_cancel"));
		butt:SetSize(150,25);
		butt.DoClick = function(self)
			edit:Remove();
		end

		local butt = vgui.Create("DButton",edit);
		butt:SetPos(210,85);
		butt:SetText(SGLanguage.GetMessage("stargate_cfg_backup_ok"));
		butt:SetSize(150,25);
		butt.DoClick = function(self)
			net.Start("_sg_config")
			net.WriteUInt(11,8);
			net.WriteUInt(3,4);
			net.WriteString(fil);
			net.SendToServer();
			GAMEMODE:AddNotify(SGLanguage.GetMessage("stargate_cfg_backup_loaded"), NOTIFY_GENERIC, 5);
			surface.PlaySound( "buttons/button9.wav" );
			edit:Remove();
			CapPanel.CFGSended = false;
        	net.Start("_sg_config");
        	net.WriteUInt(5,8);
        	net.SendToServer(); 
			
		end
		surface.PlaySound("buttons/button2.wav");
	end
	
	CapPanel.CfgList = function(self,tbl)
		CfgList.CfgTable = tbl;
		CfgList:Clear()
		for k,v in pairs(tbl) do
			CfgList:AddLine(k);
		end
		CfgList:SortByColumn(1)
	end
	
	--local lastView	
	CapPanel.OpenCfgView = function(self, name, data)
		if (CapPanel.lastCfgView and IsValid(CapPanel.lastCfgView) and CapPanel.lastCfgView.Remove) then CapPanel.lastCfgView:Remove() end
		local edit = vgui.Create("DFrame",BackupFrame);
		edit:SetSize(550,350);
		//edit:SetPos(sizew/2-200,sizeh/2-200);
		edit:SetTitle(name);
		edit:Center()
		edit:RequestFocus();
		CapPanel.lastCfgView = edit;

		local label = vgui.Create("DTextEntry",edit);
		label:SetPos(10,35);
		label:SetText(data);
		label.Text = data
		label:SizeToContents();
		label:Dock(FILL)
		label:SetEditable(true)
		label:SetMultiline(true)
		label:SetVerticalScrollbarEnabled( true )
		
		edit.TxtField = label
	end
	
	PropertySheet.__SetActiveTab = PropertySheet.SetActiveTab;
	PropertySheet.SetActiveTab = function(self, active)
		if (not CapPanel.CFGSended and active:GetText()==SGLanguage.GetMessage("stargate_menu_t4")) then
			CapPanel.CFGSended = true;
        	net.Start("_sg_config");
        	net.WriteUInt(0,8);
        	net.SendToServer();
		end
		if (not CapPanel.CFGBackupSended and active:GetText()==SGLanguage.GetMessage("stargate_menu_t6")) then
			--CapPanel.CFGBackupSended = true;
        	net.Start("_sg_config");
        	net.WriteUInt(11,8);
			net.WriteUInt(0,4);
        	net.SendToServer();
		end
		PropertySheet:__SetActiveTab(active);
	end

	PropertySheet:AddSheet( SGLanguage.GetMessage("stargate_menu_t1"), GroupConvarFrame, "gui/cap_logo", false, false )
	PropertySheet:AddSheet( SGLanguage.GetMessage("stargate_menu_t2"), CapConvarFrame, "icon16/server.png", false, false )
	PropertySheet:AddSheet( SGLanguage.GetMessage("stargate_menu_t4"), CfgFrame, "icon16/wrench.png", false, false )
	PropertySheet:AddSheet( SGLanguage.GetMessage("stargate_menu_t5"), AdminFrame, "icon16/shield.png", false, false )
	PropertySheet:AddSheet( SGLanguage.GetMessage("stargate_menu_t6"), BackupFrame, "icon16/drive_disk.png", false, false )
end

concommand.Add("stargate_settings",SG_Settings_Open);

net.Receive("_sg_convars", function(len)
	local mode = net.ReadUInt(4);
	local count = net.ReadUInt(8);
	local ref = {}
	for i=1,count do
		local name = net.ReadString();
		sg_convars[name] = net.ReadUInt(20); 
		if (mode==0) then
			sg_def_convars[name] = net.ReadUInt(20);
		else
			ref[name] = sg_convars[name]
		end             
	end
	if (mode==1) then
		if (CapPanel and CapPanel.LimitSliders) then
			for k,v in pairs(ref) do
				local slider = CapPanel.LimitSliders[k]
				slider.NoSend = true
				slider:SetValue(v)
				slider.NoSend = false
			end
		end
	else
		SG_Settings_OpenNet();
	end
end);

local CFGEditor = {};

net.Receive("_sg_config", function(len)
	local typ = net.ReadUInt(8);
	if (typ==0) then
		CFGEditor = {};
	elseif (typ==1) then
		-- due to bug with floats in writetable i must use this until it will be fixed
		local cat = net.ReadString();
		CFGEditor[cat] = {};
		local count = net.ReadUInt(16);
		for i=1,count do
			local name = net.ReadString();
			local typ2 = net.ReadUInt(8)                
			if (typ2==0) then
				CFGEditor[cat][name] = net.ReadDouble();
			elseif (typ2==1) then
				CFGEditor[cat][name] = util.tobool(net.ReadBit());
			else
				CFGEditor[cat][name] = net.ReadString();
			end
		end
		--CFGEditor[net.ReadString()] = net.ReadTable();
	elseif (typ==2) then
		if (CapPanel and CapPanel.CfgEditor) then
			CapPanel:CfgEditor(CFGEditor);
		end
	elseif (typ==3) then
		if (CapPanel and CapPanel.CfgGrpEditor) then
			CapPanel:CfgGrpEditor(CFGEditor);
		end
	elseif (typ==4) then
		CFGEditor = {};
		CFGEditor["stargate_custom_groups"] = {};
		CFGEditor["stargate_custom_types"] = {};
	elseif (typ==5) then
		if (CapPanel and CapPanel.CfgList) then
			local action = net.ReadUInt(4)
			if (action==1) then
				if (CapPanel.lastCfgView and IsValid(CapPanel.lastCfgView)) then
					local str = net.ReadString()
					if (str[1]=="#") then
						str = "#"..str -- special fix
					end
					CapPanel.lastCfgView.TxtField:SetText(str);
					CapPanel.lastCfgView.TxtField.OnTextChanged = function(self) self:SetText(str) return end
				end
			else		
				CapPanel:CfgList(net.ReadTable());
			end
		end
	end
end)

end