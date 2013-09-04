--[[
	Pack Version
	Copyright (C) 2011 Madman07
]]--

function StarGate.Update_Check(Panel)
	local LAYOUT = SGLanguage.GetMessage("stargate_credits_01");
	local GREEN = Color(0,255,0,255);
	local ORANGE = Color(255,128,0,255);

	if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		-- VGUI:SetHelp("credits");
		VGUI:SetTopic(SGLanguage.GetMessage("stargate_credits_01"));
		VGUI:SetText(SGLanguage.GetMessage("stargate_credits_01"));
		VGUI:SetImage("icon16/star.png");
		VGUI:SetURL(StarGate.HTTP.CREDITS);
		Panel:AddPanel(VGUI);

		Panel:Help(SGLanguage.GetMessage("stargate_credits_02", StarGate.HTTP.BUGS));
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetTopic(SGLanguage.GetMessage("stargate_credits_13"));
		VGUI:SetText(SGLanguage.GetMessage("stargate_credits_13"));
		VGUI:SetImage("icon16/exclamation.png");
		VGUI:SetURL(StarGate.HTTP.BUGS);
		Panel:AddPanel(VGUI);
		Panel:Help("");

		local VGUImg = vgui.Create("DImage",Panel)
		VGUImg:SetSize(210,210);
		VGUImg:SetImage("gui/update_checker/cap");
		Panel:AddPanel(VGUImg);

		Panel:Help("");

		if (StarGate.LATEST_VERSION == 0) then
			Panel:Help(SGLanguage.GetMessage("stargate_credits_03")):SetTextColor(ORANGE);
		elseif (StarGate.CURRENT_VERSION == 0) then
			Panel:Help(SGLanguage.GetMessage("stargate_credits_04")):SetTextColor(ORANGE);
		elseif (StarGate.LATEST_VERSION == 0 and StarGate.CURRENT_VERSION == 0) then
			Panel:Help(SGLanguage.GetMessage("stargate_credits_01")):SetTextColor(ORANGE);
			Panel:Help(SGLanguage.GetMessage("stargate_credits_04")):SetTextColor(ORANGE);
		else
			if (StarGate.CURRENT_VERSION >= StarGate.LATEST_VERSION) then
				Panel:Help(SGLanguage.GetMessage("stargate_credits_05").." "..StarGate.CURRENT_VERSION.." :)"):SetTextColor(GREEN);
				VGUImg:SetImage("gui/update_checker/cap_is")
			else
				Panel:Help(SGLanguage.GetMessage("stargate_credits_06", StarGate.CURRENT_VERSION, StarGate.LATEST_VERSION)):SetTextColor(ORANGE);
				Panel:Help(SGLanguage.GetMessage("stargate_credits_07"));
				VGUImg:SetImage("gui/update_checker/cap_not")
			end
		end

		Panel:Help("");
		Panel:Help("");

		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetText("www.sg-carterpack.com");
		VGUI:SetImage("icon16/star.png");
		VGUI:SetURL(StarGate.HTTP.SITE);
		Panel:AddPanel(VGUI);

		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetText("www.facepunch.com/threads/1162629");
		VGUI:SetImage("icon16/star.png");
		VGUI:SetURL(StarGate.HTTP.FACEPUNCH);
		Panel:AddPanel(VGUI);

	else
		local VGUImg = vgui.Create("DImage",Panel)
		VGUImg:SetSize(210,210);
		VGUImg:SetImage("gui/update_checker/cap");
		Panel:AddPanel(VGUImg);
		Panel:Help("");

		Panel:Help(SGLanguage.GetMessage("stargate_credits_08"));
		Panel:CheckBox(SGLanguage.GetMessage("stargate_credits_09"),"cl_has_internet"):SetToolTip(SGLanguage.GetMessage("stargate_credits_10"));
	end

	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_credits_11"));
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_credits_12"));
	Panel:Help("Creative Commons Attribution-NonCommercial-NoDerivs");
	Panel:Help("3.0 Unported License.");
end

function CAP_Outdated()
	local addons = GetAddonList(true);
	if (StarGate.HasInternet and (table.HasValue(addons,"cap") or table.HasValue(addons,"cap_resources") or table.HasValue(addons,"cap resources"))) then
		local UpdateFrame = vgui.Create("DFrame");
		UpdateFrame:SetPos(ScrW()-540, 100);
		UpdateFrame:SetSize(440,130);
		UpdateFrame:SetTitle(SGLanguage.GetMessage("stargate_updater_01"));
		UpdateFrame:SetVisible(true);
		UpdateFrame:SetDraggable(true);
		UpdateFrame:ShowCloseButton(true);
		UpdateFrame:SetBackgroundBlur(false);
		UpdateFrame:MakePopup();
		UpdateFrame.Paint = function()

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
			surface.DrawOutlinedRect( 0, 0, UpdateFrame:GetWide(), UpdateFrame:GetTall() )

			draw.DrawText(SGLanguage.GetMessage("stargate_updater_02",StarGate.CURRENT_VERSION,StarGate.LATEST_VERSION).."\n"..SGLanguage.GetMessage("stargate_updater_03"), "ScoreboardText", 220, 30, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER);
		end;

		local close = vgui.Create("DButton", UpdateFrame);
		close:SetText(SGLanguage.GetMessage("stargate_updater_04"));
		close:SetPos(340, 95);
		close:SetSize(80, 25);
		close.DoClick = function (btn)
			UpdateFrame:Close();
		end


	end
end
concommand.Add("CAP_Outdated",CAP_Outdated)

function CAP_TAC()

	local TACFrame = vgui.Create("DFrame");
	TACFrame:SetPos(ScrW()/2-400, 50);
	TACFrame:SetSize(800,ScrH()-100);
	TACFrame:SetTitle("Carter Addon Pack - Terms and Conditions");
	TACFrame:SetVisible(true);
	TACFrame:SetDraggable(true);
	TACFrame:ShowCloseButton(false);
	TACFrame:SetBackgroundBlur(false);
	TACFrame:MakePopup();
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
		surface.DrawRect( 20, 45, TACFrame:GetWide() - 35, TACFrame:GetTall() - 145 )

	end

	if file.Exists("addons/cap/tac/motd.txt", "GAME") then
		local MOTDHTMLFrame = vgui.Create( "HTML", TACFrame )
		MOTDHTMLFrame:SetPos( 25, 50 )
		MOTDHTMLFrame:SetSize( TACFrame:GetWide() - 50, TACFrame:GetTall() - 150 )
		MOTDHTMLFrame:SetHTML(file.Read("addons/cap/tac/motd.txt", "GAME"))
		//MOTDHTMLFrame:OpenURL("http://sg-carterpack.com/tac")
	end

	local yes = vgui.Create("DButton", TACFrame);
		yes:SetText("Yes, I agree");
		yes:SetPos(450, TACFrame:GetTall()-50);
		yes:SetSize(140, 30);
		yes.DoClick = function (btn)
			RunConsoleCommand("cl_TAC_agree",1);
			TACFrame:Close();
	end

	local no = vgui.Create("DButton", TACFrame);
		no:SetText("No, I do not agree");
		no:SetPos(625, TACFrame:GetTall()-50);
		no:SetSize(140, 30);
		no.DoClick = function (btn)
			if (IsValid(LocalPlayer())) then
				LocalPlayer():ConCommand("$luarun");
			end
			RunConsoleCommand("cl_TAC_agree",2);
			TACFrame:Close();
	end

end
concommand.Add("CAP_TAC",CAP_TAC)