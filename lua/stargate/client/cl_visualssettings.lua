function StarGate.MiscVisualSettings(Panel)
	local high = "Frame Burst: High";
	local medium = "Frame Burst: Medium";
	local low = "Frame Burst: Low";

	Panel:ClearControls();
	-- The HELP Button
	/*if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end */
	-- Configuration
	Panel:CheckBox("Draw Effects","cl_stargate_visualsmisc"):SetToolTip("Turning this off will disable all settings below. When it's on, the settings below will be used");
	Panel:Help("");
	-- Stargates
	Panel:Help("Stargate");
	Panel:CheckBox("Dynamic Lights","cl_stargate_dynlights"):SetToolTip(high);
	if (file.Exists("materials/zup/stargate/effect_03.vmt","GAME")) then
		Panel:CheckBox("Draw ripple on the Eventhorizon","cl_stargate_ripple"):SetToolTip(medium);
    end
    Panel:CheckBox("Draw kawoosh enter effect on stargate open","cl_stargate_kenter"):SetToolTip(low);
	Panel:CheckBox("Use New Kawoosh Material", "cl_kawoosh_material"):SetToolTip("Fps Drop: Nil, Just changes the Material of the Kawoosh");
	Panel:CheckBox("Draw Open/Close Effects", "cl_stargate_effects"):SetToolTip("Fps Drop: Medium, can prevent game crash in mp (for tests)");
	-- Shield
	Panel:Help("Shield");
	Panel:CheckBox("Dynamic Lights","cl_shield_dynlights"):SetToolTip(high);
	Panel:CheckBox("Shield Bubble","cl_shield_bubble"):SetToolTip(medium);
	Panel:CheckBox("Hit Refraction","cl_shield_hitradius"):SetToolTip(medium);
	Panel:CheckBox("Hit Effect","cl_shield_hiteffect"):SetToolTip(low);
	-- Harvester
	Panel:Help("Wraith Harvester");
	Panel:CheckBox("Dynamic Lights","cl_harvester_dynlights"):SetToolTip(high);
	-- Cloaking
	Panel:Help("Cloaking");
	Panel:CheckBox("Draw Effect when passing Field","cl_cloaking_hitshader"):SetToolTip(high);
	Panel:CheckBox("Cloaking Effect","cl_cloaking_shader"):SetToolTip(medium);
	-- SuperGate
	Panel:Help("Supergate");
	Panel:CheckBox("Dynamic lights", "cl_supergate_dynlights"):SetToolTip(high)	;
	-- Apple Core
	Panel:Help("Apple Core");
	Panel:CheckBox("Dynamic Lights", "cl_applecore_light"):SetToolTip(high);
	Panel:CheckBox("Smoke", "cl_applecore_smoke"):SetToolTip(medium);
	-- Atl Shield
	Panel:Help("Atlantis Shield");
	Panel:CheckBox("Refraction", "cl_shieldcore_refract"):SetToolTip("Fps Drop: Small, Removes Refraction, leave just shield material");
	-- Huds
	Panel:Help("HUD");
	Panel:CheckBox("Draw HUD on energy devices", "cl_draw_huds"):SetToolTip("Fps Drop: Small, disables hud dwawing for zpms, zpmhubs, naq-gens.");
	Panel:CheckBox("Draw Letters on DHD", "cl_dhd_letters"):SetToolTip("Fps Drop: Small, disables letters dwawing on dhd's.");
end

function StarGate.ShipVisualSettings(Panel)
	local high = "Frame Burst: High";
	local medium = "Frame Burst: Medium";
	local low = "Frame Burst: Low";

	Panel:ClearControls();
	-- The HELP Button
	/*if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end */
	-- Configuration
	Panel:CheckBox("Draw Effects","cl_stargate_visualsship"):SetToolTip("Turning this off will disable all settings below. When it's on, the settings below will be used");
	Panel:Help("");
	-- Jumper
	Panel:Help("Puddle Jumper");
	Panel:CheckBox("Dynamic Lights", "cl_jumper_dynlights"):SetToolTip(high);
	Panel:CheckBox("Heatwave", "cl_jumper_heatwave"):SetToolTip(medium);
	Panel:CheckBox("Sprites", "cl_jumper_sprites"):SetToolTip(medium);
	-- F302
	Panel:Help("F302");
	Panel:CheckBox("Heatwave", "cl_F302_heatwave"):SetToolTip(medium);
	Panel:CheckBox("Sprites", "cl_F302_sprites"):SetToolTip(medium);
	-- Shuttle
	Panel:Help("Destiny Shuttle");
	Panel:CheckBox("Heatwave", "cl_shuttle_heatwave"):SetToolTip(medium);
	Panel:CheckBox("Sprites", "cl_shuttle_sprites"):SetToolTip(medium);
	-- Wraith Dart
	Panel:Help("Wraith Dart");
	Panel:CheckBox("Heatwave", "cl_dart_heatwave"):SetToolTip(medium);

	-- Control Chair
	Panel:Help("Control Chair");
	Panel:CheckBox("Dynamic Lights", "cl_chair_dynlights"):SetToolTip(high);
end

function StarGate.WeaponVisualSettings(Panel)
	local high = "Frame Burst: High";
	local medium = "Frame Burst: Medium";
	local low = "Frame Burst: Low";

	Panel:ClearControls();
	-- The HELP Button
	/*if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end */
	-- Configuration
	Panel:CheckBox("Draw Effects","cl_stargate_visualsweapon"):SetToolTip("Turning this off will disable all settings below. When it's on, the settings below will be used");
	Panel:Help("");
	-- Staff Weapon and Dexgun
	Panel:Help("Staff Weapon, Ronon's Gun, Ori Staff, Destiny Cannons, Tollana Cannon");
	Panel:CheckBox("Dynamic Lights when hitting","cl_staff_dynlights"):SetToolTip(high);
	Panel:CheckBox("Dynamic Lights while flying","cl_staff_dynlights_flight"):SetToolTip(high);
	Panel:CheckBox("Smoke","cl_staff_smoke"):SetToolTip(medium);
	Panel:CheckBox("Scorch on Walls","cl_staff_scorch"):SetToolTip(low);
	-- Zat'nik'tel
	Panel:Help("Zat'nik'tel");
	Panel:CheckBox("Dynamic Lights","cl_zat_dynlights"):SetToolTip(high);
	Panel:CheckBox("Hit Effect","cl_zat_hiteffect"):SetToolTip(medium);
	Panel:CheckBox("Dissolve Effect","cl_zat_dissolveeffect"):SetToolTip(medium);
	-- Drones
	Panel:Help("Drone");
	Panel:CheckBox("Glow","cl_drone_glow"):SetToolTip(low);
	-- Naquadah Bomb
	Panel:Help("Naquadah Bomb");
	Panel:CheckBox("SunBeams", "cl_gate_nuke_sunbeams"):SetToolTip("Requires SM v2, "..high);
	Panel:CheckBox("Particle rings", "cl_gate_nuke_rings"):SetToolTip(high);
	Panel:CheckBox("Shielded Particles", "cl_gate_nuke_shieldrings"):SetToolTip(high.." Prevents particles from spawning in shield");
	Panel:CheckBox("Plasma", "cl_gate_nuke_plasma"):SetToolTip(low.." This effects the one below.");
	Panel:CheckBox("Plasma Dynamic Lighting", "cl_gate_nuke_dynlights"):SetToolTip(medium.." This one is effected by the one above");
	-- Stargate Overloader
	Panel:Help("Stargate Overloader");
	Panel:CheckBox("Refraction Ring Pulse", "cl_overloader_refract"):SetToolTip("Fps Drop: Medium");
	Panel:CheckBox("Particle rings", "cl_overloader_particle"):SetToolTip(medium);
	Panel:CheckBox("Dynamic Lights", "cl_overloader_dynlights"):SetToolTip(high);
		-- Asuran Gun
	Panel:Help("Asuran Gate Weapon");
	Panel:CheckBox("Small lasers", "cl_asuran_laser"):SetToolTip(low);
	Panel:CheckBox("Dynamic Lights", "cl_asuran_dynlights"):SetToolTip(high);
	-- Dakara Super Weapon
	Panel:Help("Dakara Super Weapon");
	Panel:CheckBox("Charge up rings", "cl_dakara_rings"):SetToolTip(low);
	Panel:CheckBox("Refraction spheres", "cl_dakara_refract"):SetToolTip(medium);
	-- Ori Beam Weapon
	Panel:Help("Ori Beam Weapon");
	Panel:CheckBox("Particle Trail", "cl_oribeam_particle"):SetToolTip(low);
	Panel:CheckBox("Refraction Trail", "cl_oribeam_refract"):SetToolTip(medium);
	Panel:CheckBox("Dynamic lights", "cl_oribeam_dynlights"):SetToolTip(high);
end

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
concommand.Add("CAP_NotLegal",CAP_NotLegal)