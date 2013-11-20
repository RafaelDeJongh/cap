function StarGate.MiscVisualSettings(Panel)
	local high = SGLanguage.GetMessage("vis_fps_high");
	local medium = SGLanguage.GetMessage("vis_fps_medium");
	local low = SGLanguage.GetMessage("vis_fps_low");

	Panel:ClearControls();
	-- The HELP Button
	/*if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end */
	-- Configuration
	Panel:CheckBox(SGLanguage.GetMessage("vis_title"),"cl_stargate_visualsmisc"):SetToolTip(SGLanguage.GetMessage("vis_title_desc"));
	Panel:Help("");
	-- Stargates
	Panel:Help(SGLanguage.GetMessage("stool_cat"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"),"cl_stargate_dynlights"):SetToolTip(high);
	if (file.Exists("materials/zup/stargate/effect_03.vmt","GAME")) then
		Panel:CheckBox(SGLanguage.GetMessage("vis_ripple"),"cl_stargate_ripple"):SetToolTip(medium);
    end
    Panel:CheckBox(SGLanguage.GetMessage("vis_kawoosh_eff"),"cl_stargate_kenter"):SetToolTip(low);
	Panel:CheckBox(SGLanguage.GetMessage("vis_kawoosh_mat"), "cl_kawoosh_material"):SetToolTip(SGLanguage.GetMessage("vis_kawoosh_mat_desc"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_stargate_eff"), "cl_stargate_effects"):SetToolTip(SGLanguage.GetMessage("vis_stargate_eff_desc",medium));
	-- Shield
	Panel:Help(SGLanguage.GetMessage("stool_shield"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"),"cl_shield_dynlights"):SetToolTip(high);
	Panel:CheckBox(SGLanguage.GetMessage("vis_shield_bubble"),"cl_shield_bubble"):SetToolTip(medium);
	Panel:CheckBox(SGLanguage.GetMessage("vis_hit_refl"),"cl_shield_hitradius"):SetToolTip(medium);
	Panel:CheckBox(SGLanguage.GetMessage("vis_hit_eff"),"cl_shield_hiteffect"):SetToolTip(low);
	-- Atl Shield
	Panel:Help(SGLanguage.GetMessage("vis_atl_shield"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_refl"), "cl_shieldcore_refract"):SetToolTip(SGLanguage.GetMessage("vis_refl_desc",low));
	-- Harvester
	Panel:Help(SGLanguage.GetMessage("stool_harvester"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"),"cl_harvester_dynlights"):SetToolTip(high);
	-- Cloaking
	Panel:Help(SGLanguage.GetMessage("stool_cloak"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_cloak_pass"),"cl_cloaking_hitshader"):SetToolTip(high);
	Panel:CheckBox(SGLanguage.GetMessage("vis_cloak_eff"),"cl_cloaking_shader"):SetToolTip(medium);
	-- SuperGate
	Panel:Help("Supergate");
	Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_supergate_dynlights"):SetToolTip(high);
	-- Apple Core
	Panel:Help(SGLanguage.GetMessage("entity_apple_core"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_applecore_light"):SetToolTip(high);
	Panel:CheckBox(SGLanguage.GetMessage("vis_smoke"), "cl_applecore_smoke"):SetToolTip(medium);
	-- Huds
	Panel:Help(SGLanguage.GetMessage("vis_hud_title"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_hud_energy"), "cl_draw_huds"):SetToolTip(SGLanguage.GetMessage("vis_hud_energy_desc",low));
	Panel:CheckBox(SGLanguage.GetMessage("vis_dhd_glyphs"), "cl_dhd_letters"):SetToolTip(SGLanguage.GetMessage("vis_dhd_glyphs_desc",low));
end

function StarGate.ShipVisualSettings(Panel)
	local high = SGLanguage.GetMessage("vis_fps_high");
	local medium = SGLanguage.GetMessage("vis_fps_medium");
	local low = SGLanguage.GetMessage("vis_fps_low");

	Panel:ClearControls();
	-- The HELP Button
	/*if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end */
	-- Configuration
	Panel:CheckBox(SGLanguage.GetMessage("vis_title"),"cl_stargate_visualsship"):SetToolTip(SGLanguage.GetMessage("vis_title_desc"));
	Panel:Help("");
	-- Jumper
	Panel:Help(SGLanguage.GetMessage("entity_jumper"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_jumper_dynlights"):SetToolTip(high);
	Panel:CheckBox(SGLanguage.GetMessage("vis_heatwave"), "cl_jumper_heatwave"):SetToolTip(medium);
	Panel:CheckBox(SGLanguage.GetMessage("vis_sprites"), "cl_jumper_sprites"):SetToolTip(medium);
	-- F302
	Panel:Help(SGLanguage.GetMessage("entity_f302"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_heatwave"), "cl_F302_heatwave"):SetToolTip(medium);
	Panel:CheckBox(SGLanguage.GetMessage("vis_sprites"), "cl_F302_sprites"):SetToolTip(medium);
	-- Shuttle
	Panel:Help(SGLanguage.GetMessage("entity_dest_shuttle"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_heatwave"), "cl_shuttle_heatwave"):SetToolTip(medium);
	Panel:CheckBox(SGLanguage.GetMessage("vis_sprites"), "cl_shuttle_sprites"):SetToolTip(medium);
	-- Wraith Dart
	Panel:Help(SGLanguage.GetMessage("entity_dart"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_heatwave"), "cl_dart_heatwave"):SetToolTip(medium);
	-- Control Chair
	Panel:Help(SGLanguage.GetMessage("entity_control_chair"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_chair_dynlights"):SetToolTip(high);
end

function StarGate.WeaponVisualSettings(Panel)
	local high = SGLanguage.GetMessage("vis_fps_high");
	local medium = SGLanguage.GetMessage("vis_fps_medium");
	local low = SGLanguage.GetMessage("vis_fps_low");

	Panel:ClearControls();
	-- The HELP Button
	/*if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end */
	-- Configuration
	Panel:CheckBox(SGLanguage.GetMessage("vis_title"),"cl_stargate_visualsweapon"):SetToolTip(SGLanguage.GetMessage("vis_title_desc"));
	Panel:Help("");
	-- Staff Weapon and Dexgun
	Panel:Help(SGLanguage.GetMessage("vis_weap_title"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_hit_dyn_light"),"cl_staff_dynlights"):SetToolTip(high);
	Panel:CheckBox(SGLanguage.GetMessage("vis_fly_dyn_light"),"cl_staff_dynlights_flight"):SetToolTip(high);
	Panel:CheckBox(SGLanguage.GetMessage("vis_smoke"),"cl_staff_smoke"):SetToolTip(medium);
	Panel:CheckBox(SGLanguage.GetMessage("vis_wall"),"cl_staff_scorch"):SetToolTip(low);
	-- Zat'nik'tel
	Panel:Help(SGLanguage.GetMessage("weapon_zat"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"),"cl_zat_dynlights"):SetToolTip(high);
	Panel:CheckBox(SGLanguage.GetMessage("vis_hit_eff"),"cl_zat_hiteffect"):SetToolTip(medium);
	Panel:CheckBox(SGLanguage.GetMessage("vis_diss_eff"),"cl_zat_dissolveeffect"):SetToolTip(medium);
	-- Drones
	Panel:Help(SGLanguage.GetMessage("stool_drones"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_glow"),"cl_drone_glow"):SetToolTip(low);
	-- Naquadah Bomb
	Panel:Help(SGLanguage.GetMessage("stool_naq_bomb"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_sunbeams"), "cl_gate_nuke_sunbeams"):SetToolTip(SGLanguage.GetMessage("vis_sunbeams_desc",high));
	Panel:CheckBox(SGLanguage.GetMessage("vis_part_rings"), "cl_gate_nuke_rings"):SetToolTip(high);
	Panel:CheckBox(SGLanguage.GetMessage("vis_shield_part"), "cl_gate_nuke_shieldrings"):SetToolTip(SGLanguage.GetMessage("vis_shield_part_desc",high));
	Panel:CheckBox(SGLanguage.GetMessage("vis_plasma"), "cl_gate_nuke_plasma"):SetToolTip(SGLanguage.GetMessage("vis_plasma_desc",low));
	Panel:CheckBox(SGLanguage.GetMessage("vis_plasma_light"), "cl_gate_nuke_dynlights"):SetToolTip(SGLanguage.GetMessage("vis_plasma_desc",medium));
	-- Stargate Overloader
	Panel:Help(SGLanguage.GetMessage("entity_overloader"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_refl_rings"), "cl_overloader_refract"):SetToolTip(medium);
	Panel:CheckBox(SGLanguage.GetMessage("vis_part_rings"), "cl_overloader_particle"):SetToolTip(medium);
	Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_overloader_dynlights"):SetToolTip(high);
	-- Asuran Gun
	Panel:Help(SGLanguage.GetMessage("entity_asuran_weapon"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_sm_laser"), "cl_asuran_laser"):SetToolTip(low);
	Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_asuran_dynlights"):SetToolTip(high);
	-- Dakara Super Weapon
	Panel:Help(SGLanguage.GetMessage("entity_dakara"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_charge_up"), "cl_dakara_rings"):SetToolTip(low);
	Panel:CheckBox(SGLanguage.GetMessage("vis_refl_sphere"), "cl_dakara_refract"):SetToolTip(medium);
end

/*
function CAP_NotLegal()
	if StarGate.HasInternet then
		local LegalFrame = vgui.Create("DFrame");
		LegalFrame:SetPos(100, 100);
		LegalFrame:SetSize(400,150);
		LegalFrame:SetTitle("Cap Legality Checker");
		LegalFrame:SetVisible(true);
		LegalFrame:SetDraggable(false);
		LegalFrame:ShowCloseButton(false);
		LegalFrame:SetBackgroundBlur(false);
		LegalFrame:MakePopup();
		LegalFrame.Paint = function()

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
			surface.DrawOutlinedRect( 0, 0, LegalFrame:GetWide(), LegalFrame:GetTall() )

			draw.DrawText("An error occured. If your Steam profile is private, please\nturn it to Public mode in order to use Carter Addon Pack.\nIf your copy of Garry's Mod is illegal, your Steam ID will be\nreported. Please buy a legal copy of Garry's Mod.", "ScoreboardText", 200, 30, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER);
		end;

		LegalFrame.Count = RealTime()+15;

		local close = vgui.Create("DButton", LegalFrame);
		close:SetText("15");
		close:SetPos(300, 115);
		close:SetSize(80, 25);
		close.DoClick = function (btn)
			local rel = LegalFrame.Count - RealTime();
			if (rel < 0) then LegalFrame:Close(); end
		end

		function LegalFrame:Think()
			local rel = LegalFrame.Count - RealTime();
			if (rel > 0) then close:SetText(Format("Wait %i sec.", rel));
			else close:SetText("Close"); end
		end

	end
end
concommand.Add("CAP_NotLegal",CAP_NotLegal)*/