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
	local DGREEN = Color(0,182,0,255);

	if (LocalPlayer():IsAdmin()) then
		local convarsmenu = vgui.Create("DButton", Panel);
	    convarsmenu:SetText(SGLanguage.GetMessage("stargate_settings_01"));
	    convarsmenu:SetSize(150, 25);
	    convarsmenu:SetImage("icon16/wrench.png");
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
	local _,langs = file.Find("lua/data/language/*","GAME");
	local en_count,en_msgs = SGLanguage.CountMessagesInLanguage("en",true);
	local lng_arr = {}
	for i,lang in pairs(langs) do
		local count,msgs = SGLanguage.CountMessagesInLanguage(lang,true);
		if (lang!="en"/* and (not msgs["global_lang_similar"] or msgs["global_lang_similar"]=="false")*/) then
			for k,v in pairs(msgs) do
				if (not en_msgs[k]/* or v==en_msgs[k]*/) then count = count-1; end -- stop cheating!
			end
		end
		count = math.Round(count*100/en_count);
		lng_arr[lang] = {SGLanguage.GetLanguageName(lang),count};
		clientlang:AddChoice(SGLanguage.GetLanguageName(lang));
	end
	Panel:AddPanel(clientlang);
	Panel:Help(SGLanguage.GetMessage("stargate_settings_07"));
	Panel:Help(SGLanguage.GetMessage("stargate_settings_03")):SetTextColor(DGREEN);
	local VGUI = vgui.Create("DPanel");
	VGUI:SetBackgroundColor(Color(120,120,120));
	local i = 5;
	for k,v in SortedPairs(lng_arr) do
		local count = v[2];
		local col = HSVToColor((count/100)*120,1,0.9);
		local p = vgui.Create("DLabel",VGUI);
		p:SetPos(10,i);
		p:SetText(v[1].." ("..k..") - "..count.."%");
		p:SetSize(150,15);
		p:SetAutoStretchVertical(true);
		p:SetTextColor(col);
		p:SetTall(10);
		p:DockMargin(0,0,0,0);
		i = i+15;
	end
	VGUI:SetSize(150,i+5);
	Panel:AddPanel(VGUI);
	Panel:Help(SGLanguage.GetMessage("stargate_settings_04"));
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_settings_05"));
	local VGUI = vgui.Create("DButton");
	VGUI:SetText(SGLanguage.GetMessage("stargate_settings_02"));
	VGUI:SetImage("icon16/group.png");
	VGUI:SetSize(150, 25);
	VGUI.DoClick = function()
		local help = vgui.Create("SHTMLHelp");
		help:SetURL("http://sg-carterpack.com/wiki/doc/how-to-translate-cap/");
		help:SetText(SGLanguage.GetMessage("stargate_settings_02t"));
		help:SetVisible(true);
	end
	Panel:AddPanel(VGUI);
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_settings_08"));
	Panel:Help(SGLanguage.GetMessage("stargate_settings_09"));

end