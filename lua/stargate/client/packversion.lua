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

		local VGUImg = vgui.Create("DImage",Panel)
		VGUImg:SetSize(210,210);
		VGUImg:SetImage("gui/update_checker/cap");
		Panel:AddPanel(VGUImg);

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

		Panel:Help(SGLanguage.GetMessage("stargate_credits_08"));
		Panel:CheckBox(SGLanguage.GetMessage("stargate_credits_09"),"cl_has_internet"):SetToolTip(SGLanguage.GetMessage("stargate_credits_10"));
	end
	Panel:Help(SGLanguage.GetMessage("stargate_credits_14"));
	local VGUI = vgui.Create("SHelpButton",Panel);
	VGUI:SetText(SGLanguage.GetMessage("stargate_credits_15"));
	VGUI:SetImage("icon16/money_add.png");
	VGUI:SetURL(StarGate.HTTP.DONATE,true);
	Panel:AddPanel(VGUI);
	Panel:Help(SGLanguage.GetMessage("stargate_credits_11"));
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_credits_12"));
	Panel:Help("Creative Commons Attribution-NonCommercial-NoDerivs");
	Panel:Help("3.0 Unported License.");
end

function CAP_Outdated()
	local addons = GetAddonList(true);
	if (StarGate.HasInternet and StarGate.InstalledOnClient()) then
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