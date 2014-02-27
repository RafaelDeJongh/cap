-- Must be here now, and reloading with stargate_reload command, or we have bugs with new address list transfer client-side.

--##################################
--#### VGUI/Dial Menu
--##################################

local VGUI
net.Receive("StarGate.VGUI.Menu",function(len)
	local gate = net.ReadEntity();
	if (not IsValid(gate)) then return end
	if(VGUI and VGUI:IsValid()) then
		VGUI:SetVisible(false);
	end
	local type = net.ReadInt(8);
	local groupsystem = gate:GetNetworkedBool("SG_GROUP_SYSTEM");
	if (type<=0) then -- 0 is normal menu, -1 is alternative (without dial)
		local candialg = util.tobool(gate:GetNetworkedInt("CANDIAL_GROUP_MENU"));
		local alternatemenu = (type<0);
		VGUI = vgui.Create("SControlePanel");
		VGUI:SetSettings(gate,groupsystem,alternatemenu,candialg);
		VGUI:SetVisible(true);
	elseif(type==1) then -- 1 is normal dial menu (used in ships/mobile dhd etc)
		local candialg = util.tobool(gate:GetNetworkedInt("CANDIAL_GROUP_DHD"));
		VGUI = vgui.Create("SControlePanelDHD");
		VGUI:SetSettings(gate,groupsystem,candialg);
		VGUI:SetVisible(true);
	elseif(type==2) then -- 2 is for dial menu with feature to override candialg option (for dhds/destiny console etc).
		local candialg = util.tobool(net.ReadBit());
		VGUI = vgui.Create("SControlePanelDHD");
		VGUI:SetSettings(gate,groupsystem,candialg);
		VGUI:SetVisible(true);
	elseif(type==3) then -- 3 is for nox dial
		local candialg = util.tobool(gate:GetNetworkedInt("CANDIAL_GROUP_DHD"));
		VGUI = vgui.Create("SControlePanelDHD");
		VGUI:SetSettings(gate,groupsystem,candialg,true);
		VGUI:SetVisible(true);
	elseif(type==4) then -- 4 is for orlin gate
		local candialg = util.tobool(gate:GetNetworkedInt("CANDIAL_GROUP_MENU"));
		VGUI = vgui.Create("SControlePanelDHD");
		VGUI:SetSettings(gate,groupsystem,candialg,false,true);
		VGUI:SetVisible(true);
	end
end)

-- ################# Reset vgui settings @ AlexALX
concommand.Add("stargate_reset_menu",function(ply)
	local RVGUI = vgui.Create("Panel");
	RVGUI:SetCookieName("StarGate.SControlePanel");
	RVGUI:SetCookie("SG.Size.W",nil);
	RVGUI:SetCookie("SG.Size.H",nil);
	RVGUI:SetCookie("SG.Pos.X",nil);
	RVGUI:SetCookie("SG.Pos.Y",nil);
	RVGUI:SetCookieName("StarGate.SControlePanel_Alt");
	RVGUI:SetCookie("SG.Pos.X",nil);
	RVGUI:SetCookie("SG.Pos.Y",nil);
	RVGUI:SetCookieName("StarGate.SControlePanelDHD");
	RVGUI:SetCookie("SG.Size.W",nil);
	RVGUI:SetCookie("SG.Size.H",nil);
	RVGUI:SetCookie("SG.Pos.X",nil);
	RVGUI:SetCookie("SG.Pos.Y",nil);
	RVGUI:Remove();
end)

-- ################# Closes the dialling Dialoge @aVoN
usermessage.Hook("StarGate.DialMenuDHDClose",
	function(data)
		if(VGUI and VGUI:IsValid()) then
			VGUI:SetVisible(false);
		end
	end
);

-- ################# Screen clicking code @aVoN
hook.Add("GUIMousePressed","StarGate.DHD.GUIMousePressed_Group",
	function(_,dir)
		--if(IsValid(DHD)) then
			local p = LocalPlayer();
			if (input.IsButtonDown( MOUSE_RIGHT ) or not IsValid(p)) then return end
			local trace = util.QuickTrace(p:GetShootPos(),dir*1024,p);
			if(IsValid(trace.Entity) and trace.Entity.IsDHD and not trace.Entity:GetNetworkedBool("BusyGUI",false)) then
				DHD = trace.Entity;
				if (DHD:GetPos():Distance(p:GetPos()) > 110) then return end
				local btn = DHD:GetCurrentButton(p);
				if(btn and btn != "IRIS") then
					p:ConCommand("_StarGate.DHD.AddSymbol_Group "..DHD:EntIndex().." "..btn);
					-- ######### Add/Remove symbols
					if(btn ~= "DIAL") then
						local chevrons = DHD:GetNWString("ADDRESS",""):upper():TrimExplode(",");
						btn = tostring(btn):upper();
						local add = true;
						for k,v in pairs(chevrons) do
							if(v == btn) then
								chevrons[k] = nil;
								add = false;
							end
							-- Should never be addedto the VGUI
							if(v == "DIAL") then
								chevrons[k] = nil;
							end
						end
						if(add and #chevrons < 9) then
							table.insert(chevrons,btn);
						end
						if (VGUI and VGUI:IsValid()) then VGUI:SetText(table.concat(table.ClearKeys(chevrons))); end
					end
				end
			end
		--end
	end
);