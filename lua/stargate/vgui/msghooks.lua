-- Must be here now, and reloading with stargate_reload command, or we have bugs with new address list transfer client-side.

--##################################
--#### VGUI/Dial Menu
--##################################

local VGUI, VGUI2, VGUI3;
usermessage.Hook("StarGate.OpenDialMenu_Group",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			local candialg = e:GetNetworkedInt("CANDIAL_GROUP_MENU");
			if (candialg==1 and not e:GetLocale()) then -- if(not VGUI) then  end;
				if (not VGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI = vgui.Create("SControlePanel_Group"); end
				VGUI:SetVisible(true);
				VGUI:SetEntity(e);
			else
				if (not VGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI2 = vgui.Create("SControlePanel_NoGroup"); end
				VGUI2:SetVisible(true);
				VGUI2:SetEntity(e);
			end
		end
	end
);

usermessage.Hook("StarGate.OpenDialMenuGate_Group",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			if (not VGUI3 or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI3 = vgui.Create("SControlePanelGate_Group"); end
			VGUI3:SetVisible(true);
			VGUI3:SetEntity(e);
		end
	end
);

local SGUVGUI, SGUVGUI2, SGUVGUI3;
usermessage.Hook("StarGate.OpenDialMenu_GroupSGU",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			local candialg = e:GetNetworkedInt("CANDIAL_GROUP_MENU");
			if (candialg==1 and not e:GetLocale()) then -- if(not VGUI) then  end;
				if (not SGUVGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then SGUVGUI = vgui.Create("SControlePanel_GroupSGU"); end
				SGUVGUI:SetVisible(true);
				SGUVGUI:SetEntity(e);
			else
				if (not SGUVGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then SGUVGUI2 = vgui.Create("SControlePanel_NoGroupSGU"); end
				SGUVGUI2:SetVisible(true);
				SGUVGUI2:SetEntity(e);
			end
		end
	end
);

usermessage.Hook("StarGate.OpenDialMenuGate_GroupSGU",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			if (not SGUVGUI3 or GetConVarNumber("stargate_cl_language_debug")>=1) then SGUVGUI3 = vgui.Create("SControlePanelGate_GroupSGU"); end
			SGUVGUI3:SetVisible(true);
			SGUVGUI3:SetEntity(e);
		end
	end
);

local GVGUI, GVGUI2, GVGUI3;
usermessage.Hook("StarGate.OpenDialMenu_Galaxy",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			local candialg = e:GetNetworkedInt("CANDIAL_GROUP_MENU");
			if (candialg==1 and not e:GetLocale()) then -- if(not VGUI) then  end;*
				if (not GVGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI = vgui.Create("SControlePanel_Galaxy"); end
				GVGUI:SetVisible(true);
				GVGUI:SetEntity(e);
			else
				if (not GVGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI2 = vgui.Create("SControlePanel_NoGalaxy"); end
				GVGUI2:SetVisible(true);
				GVGUI2:SetEntity(e);
			end
		end
	end
);

usermessage.Hook("StarGate.OpenDialMenuGate_Galaxy",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			if (not GVGUI3 or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI3 = vgui.Create("SControlePanelGate_Galaxy"); end
			GVGUI3:SetVisible(true);
			GVGUI3:SetEntity(e);
		end
	end
);

local NGVGUI, NGVGUI2, NGVGUI3;
usermessage.Hook("StarGate.OpenDialMenu_GalaxySGU",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			local candialg = e:GetNetworkedInt("CANDIAL_GROUP_MENU");
			if (candialg==1 and not e:GetLocale()) then
				if (not NGVGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then NGVGUI = vgui.Create("SControlePanel_GalaxySGU"); end
				NGVGUI:SetVisible(true);
				NGVGUI:SetEntity(e);
			else
				if (not NGVGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then NGVGUI2 = vgui.Create("SControlePanel_NoGalaxySGU"); end
				NGVGUI2:SetVisible(true);
				NGVGUI2:SetEntity(e);
			end
		end
	end
);

usermessage.Hook("StarGate.OpenDialMenuGate_GalaxySGU",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			if (not NGVGUI3 or GetConVarNumber("stargate_cl_language_debug")>=1) then NGVGUI3 = vgui.Create("SControlePanelGate_GalaxySGU"); end
			NGVGUI3:SetVisible(true);
			NGVGUI3:SetEntity(e);
		end
	end
);

local VGUI;
usermessage.Hook("StarGate.OpenDialMenu_Super",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			if(not VGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI = vgui.Create("SControlePanelSuper") end;
			VGUI:SetVisible(true);
			VGUI:SetEntity(e);
		end
	end
);

local VGUI2;
usermessage.Hook("StarGate.OpenDialMenuSuperGate",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			if(not VGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI2 = vgui.Create("SControlePanelSuperGate") end;
			VGUI2:SetVisible(true);
			VGUI2:SetEntity(e);
		end
	end
);

-- ################# Opens the Dialling Dialoge @aVoN
local VGUI,VGUI2,VGUI_ORL,VGUI_ORL2;
local DHD;
-- FIXME: Rewrite the ADDRES and NWInt part (MUCH BUGGY!)
usermessage.Hook("StarGate.OpenDialMenuDHD_Group",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			local candialg = e.Entity:GetNetworkedInt("CANDIAL_GROUP_DHD");
			DHD = data:ReadEntity();
			if (IsValid(DHD) and (DHD:GetClass()=="dhd_city" or DHD:GetClass()=="destiny_console")) then candialg = 1; end
			if (candialg==1 and e.Entity:GetNetworkedBool("Locale")==false) then
				if (not VGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI = vgui.Create("SControlePanelDHD_Group"); end
				VGUI:SetVisible(true);
				VGUI:SetEntity(e);
			else
				if (not VGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI2 = vgui.Create("SControlePanelDHD_NoGroup"); end
				VGUI2:SetVisible(true);
				VGUI2:SetEntity(e);
			end
		end
	end
);

local GVGUI, GVGUI2;
usermessage.Hook("StarGate.OpenDialMenuDHD_Galaxy",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			local candialg = e.Entity:GetNetworkedInt("CANDIAL_GROUP_DHD");
			DHD = data:ReadEntity();
			if (IsValid(DHD) and (DHD:GetClass()=="dhd_city" or DHD:GetClass()=="destiny_console")) then candialg = 1; end
			if (candialg==1 and e.Entity:GetNetworkedBool("Locale")==false) then
				if (not GVGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI = vgui.Create("SControlePanelDHD_Galaxy"); end
				GVGUI:SetVisible(true);
				GVGUI:SetEntity(e);
			else
				if (not GVGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI2 = vgui.Create("SControlePanelDHD_NoGalaxy"); end
				GVGUI2:SetVisible(true);
				GVGUI2:SetEntity(e);
			end
		end
	end
);

usermessage.Hook("StarGate.OpenDialMenuDHDGate_Group",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_")) then
			local candialg = e.Entity:GetNetworkedInt("CANDIAL_GROUP_MENU");
			local groupsystem = e.Entity:GetNetworkedBool("SG_GROUP_SYSTEM");
			DHD = data:ReadEntity();
			if (IsValid(DHD) and (DHD:GetClass()=="dhd_city" or DHD:GetClass()=="destiny_console")) then candialg = 1; end
			if (e:GetClass()=="stargate_orlin" and groupsystem) then
				if (candialg==1) then
					if (not VGUI_ORL or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI_ORL = vgui.Create("SControlePanelDHD_OrlinGroup"); end
					VGUI_ORL:SetVisible(true);
					VGUI_ORL:SetEntity(e);
				else
					if (not VGUI_ORL2 or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI_ORL2 = vgui.Create("SControlePanelDHD_OrlinNoGroup"); end
					VGUI_ORL2:SetVisible(true);
					VGUI_ORL2:SetEntity(e);
				end
			else
				if (groupsystem) then
					if (candialg==1 and e.Entity:GetNetworkedBool("Locale")==false) then
						if (not VGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI = vgui.Create("SControlePanelDHD_Group"); end
						VGUI:SetVisible(true);
						VGUI:SetEntity(e);
					else
						if (not VGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI2 = vgui.Create("SControlePanelDHD_NoGroup"); end
						VGUI2:SetVisible(true);
						VGUI2:SetEntity(e);
					end
				else
					if (candialg==1 and e.Entity:GetNetworkedBool("Locale")==false) then
						if (not GVGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI = vgui.Create("SControlePanelDHD_Galaxy"); end
						GVGUI:SetVisible(true);
						GVGUI:SetEntity(e);
					else
						if (not GVGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI2 = vgui.Create("SControlePanelDHD_NoGalaxy"); end
						GVGUI2:SetVisible(true);
						GVGUI2:SetEntity(e);
					end
				end
			end
		end
	end
);

local VGUI3;

-- FIXME: Rewrite the ADDRES and NWInt part (MUCH BUGGY!)
usermessage.Hook("StarGate.OpenDialMenuDHD",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass() == "stargate_supergate") then
			if(not VGUI3 or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI3 = vgui.Create("SControlePanelDHDSuper") end;
			VGUI3:SetVisible(true);
			VGUI3:SetEntity(e);
		elseif(IsValid(e) and e:GetClass():find("stargate_") and e:GetClass() != "stargate_supergate") then
			local candialg = e.Entity:GetNetworkedInt("CANDIAL_GROUP_DHD");
			local groupsystem = e.Entity:GetNetworkedBool("SG_GROUP_SYSTEM");
			DHD = data:ReadEntity();
			if (IsValid(DHD) and (DHD:GetClass()=="dhd_city" or DHD:GetClass()=="destiny_console")) then candialg = 1; end
			if (groupsystem) then
				if (candialg==1 and e.Entity:GetNetworkedBool("Locale")==false) then
					if (not VGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI = vgui.Create("SControlePanelDHD_Group"); end
					VGUI:SetVisible(true);
					VGUI:SetEntity(e);
				else
					if (not VGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI2 = vgui.Create("SControlePanelDHD_NoGroup"); end
					VGUI2:SetVisible(true);
					VGUI2:SetEntity(e);
				end
			else
				if (candialg==1 and e.Entity:GetNetworkedBool("Locale")==false) then
					if (not GVGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI = vgui.Create("SControlePanelDHD_Galaxy"); end
					GVGUI:SetVisible(true);
					GVGUI:SetEntity(e);
				else
					if (not GVGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI2 = vgui.Create("SControlePanelDHD_NoGalaxy"); end
					GVGUI2:SetVisible(true);
					GVGUI2:SetEntity(e);
				end
			end
		end
	end
);

usermessage.Hook("StarGate.OpenDialMenuDHDNox",
	function(data)
		local e = data:ReadEntity();
		if(IsValid(e) and e:GetClass():find("stargate_") and e:GetClass() != "stargate_supergate") then
			local candialg = e.Entity:GetNetworkedInt("CANDIAL_GROUP_DHD");
			local groupsystem = e.Entity:GetNetworkedBool("SG_GROUP_SYSTEM");
			if (groupsystem) then
				if (candialg==1 and e.Entity:GetNetworkedBool("Locale")==false) then
					if (not VGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI = vgui.Create("SControlePanelDHD_Group"); end
					VGUI:SetVisible(true);
					VGUI:SetEntity(e,true);
				else
					if (not VGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then VGUI2 = vgui.Create("SControlePanelDHD_NoGroup"); end
					VGUI2:SetVisible(true);
					VGUI2:SetEntity(e,true);
				end
			else
				if (candialg==1 and e.Entity:GetNetworkedBool("Locale")==false) then
					if (not GVGUI or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI = vgui.Create("SControlePanelDHD_Galaxy"); end
					GVGUI:SetVisible(true);
					GVGUI:SetEntity(e,true);
				else
					if (not GVGUI2 or GetConVarNumber("stargate_cl_language_debug")>=1) then GVGUI2 = vgui.Create("SControlePanelDHD_NoGalaxy"); end
					GVGUI2:SetVisible(true);
					GVGUI2:SetEntity(e,true);
				end
			end
		end
	end
);

-- ################# Closes the dialling Dialoge @aVoN
usermessage.Hook("StarGate.DialMenuDHDClose",
	function(data)
		if(VGUI and VGUI:IsValid()) then
			VGUI:SetVisible(false);
		end
		if(VGUI2 and VGUI2:IsValid()) then
			VGUI2:SetVisible(false);
		end
		if(VGUI3 and VGUI3:IsValid()) then
			VGUI3:SetVisible(false);
		end
		if(GVGUI and GVGUI:IsValid()) then
			GVGUI:SetVisible(false);
		end
		if(GVGUI2 and GVGUI2:IsValid()) then
			GVGUI2:SetVisible(false);
		end
	end
);

-- ################# Screen clicking code @aVoN
hook.Add("GUIMousePressed","StarGate.DHD.GUIMousePressed_Group",
	function(_,dir)
		--if(IsValid(DHD)) then
			local p = LocalPlayer();
			if (input.IsButtonDown( MOUSE_RIGHT )) then return end
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
						if (VGUI2 and VGUI2:IsValid()) then VGUI2:SetText(table.concat(table.ClearKeys(chevrons))); end
						if (VGUI3 and VGUI3:IsValid()) then VGUI3:SetText(table.concat(table.ClearKeys(chevrons))); end
						if (GVGUI and GVGUI:IsValid()) then GVGUI:SetText(table.concat(table.ClearKeys(chevrons))); end
						if (GVGUI2 and GVGUI2:IsValid()) then GVGUI2:SetText(table.concat(table.ClearKeys(chevrons))); end
					end
				end
			end
		--end
	end
);