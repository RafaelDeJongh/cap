/*
	Created by AlexALX (c) 2012
	Small settings tab
	For some functions what come from my addon
*/

function StarGate_Settings(Panel)
	local LAYOUT = "Convars/Limits/Language";
	local GREEN = Color(0,255,0,255);
	local ORANGE = Color(255,128,0,255);
	local RED = Color(255,0,0,255);
	local DGREEN = Color(0,192,0,255);

	if (LocalPlayer():IsAdmin()) then
		local convarsmenu = vgui.Create("DButton", Panel);
	    convarsmenu:SetText(SGLanguage.GetMessage("stargate_settings_01"));
	    convarsmenu:SetSize(150, 25);
		convarsmenu.DoClick = function ( btn )
			RunConsoleCommand("stargate_cap_convars");
		end
		Panel:AddPanel(convarsmenu);
		local convarsmenu = vgui.Create("DButton", Panel);
	    convarsmenu:SetText(SGLanguage.GetMessage("stargate_settings_02"));
	    convarsmenu:SetSize(150, 25);
		convarsmenu.DoClick = function ( btn )
			RunConsoleCommand("stargate_system_convars");
		end
		Panel:AddPanel(convarsmenu);
		local convarsmenu = vgui.Create("DButton", Panel);
	    convarsmenu:SetText(SGLanguage.GetMessage("stargate_settings_02n"));
	    convarsmenu:SetSize(150, 25);
		convarsmenu.DoClick = function ( btn )
			RunConsoleCommand("stargate_settings");
		end
		Panel:AddPanel(convarsmenu);
	end
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_settings_06")):SetTextColor(DGREEN);
	local clientlang = vgui.Create("DMultiChoice",Panel);
	clientlang:SetSize(50,20);
	local lg = SGLanguage.GetLanguageName(SGLanguage.GetClientLanguage());
	if (lg!="Error") then
		clientlang:SetText(lg);
	else
		clientlang:SetText(SGLanguage.GetClientLanguage());
	end
	clientlang.TextEntry:SetTooltip(SGLanguage.GetMessage("stargate_settings_07"));
	clientlang.TextEntry.OnTextChanged = function(TextEntry)
		local pos = TextEntry:GetCaretPos();
		local text = TextEntry:GetValue();
		local len = text:len();
		local letters = text:lower():gsub("[^a-z-]",""); -- Lower, remove invalid chars and split!
		TextEntry:SetText(letters);
		TextEntry:SetCaretPos(math.Clamp(pos - (len-letters:len()),0,text:len())); -- Reset the caretpos!
		timer.Remove("SG.lang_check");
		timer.Create("SG.lang_check",0.4,1,function()
			local lg = SGLanguage.GetLanguageName(letters);
			if (IsValid(TextEntry) and lg!="Error") then
				TextEntry:SetText(lg);
				TextEntry:SetCaretPos(lg:len()); -- Reset the caretpos!
			end
			if (letters!="") then SGLanguage.SetClientLanguage(letters); end
		end)
	end
	clientlang.OnSelect = function(panel,index,value)
		if (value!="") then
			local lg = SGLanguage.GetLanguageFromName(value);
			SGLanguage.SetClientLanguage(lg);
		end
	end
	-- add exists languages
	local langstext = "";
	local _,langs = file.Find("lua/data/language/*","GAME");
	for i,lang in pairs(langs) do
		if (i!=1) then langstext = langstext..", "; end
		langstext = langstext..SGLanguage.GetLanguageName(lang).." ("..lang..")"
		clientlang:AddChoice(SGLanguage.GetLanguageName(lang));
	end
	Panel:AddPanel(clientlang);
	Panel:Help(SGLanguage.GetMessage("stargate_settings_03")):SetTextColor(DGREEN);
	Panel:Help(langstext.."."):SetTextColor(DGREEN);
	Panel:Help(SGLanguage.GetMessage("stargate_settings_04"));
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_settings_05"));
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_settings_08"));

end