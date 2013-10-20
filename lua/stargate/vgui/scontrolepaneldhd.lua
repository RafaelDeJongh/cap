/*
	Stargate for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

--##################################
--###### SControlePanel_Group.lua
--##################################

local PANEL = {};
-- To store the mousepos accross sessions
PANEL.Data = {}

--##################################
--###### The DHD Panel (And Later for a mobile DHD)
--##################################

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(440,160);
	self:SetMinimumSize(440,160);
	self:SetPos(10,10); -- No Center because I'm planing making it able to dial a DHD by just clicking with the mouse on it
	--self:Center();
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressSelect = vgui.Create("SAddressSelect_Group",self),
		AddressSelectLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(SGLanguage.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetPos(30,7);
	self.VGUI.TitleLabel:SetWide(200);
	--###### Select Address
	-- The topic
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressSelectLabel[i]:SetText(SGLanguage.GetMessage("stargate_vgui_dial"));
		self.VGUI.AddressSelectLabel[i]:SetWide(200);
		self.VGUI.AddressSelectLabel[i]:SetPos(10-mul*2,35-mul*2);
		self.VGUI.AddressSelectLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end
	-- Our AddressSelect Panel (Where we dial Addresses from)
	self.VGUI.AddressSelect:SetPos(10,60);
	self.VGUI.AddressSelect.OnDial = function(e,address,mode)
		e:DialGate(address,mode,self.Nox);
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnAbort = function(e)
		e:AbortDialling();
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnTextChanged = function(AddressSelect)
		if(self.OnTextChanged) then self.OnTextChanged(AddressSelect) end;
	end
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self:RegisterHooks();
end

--################# Register Hooks @aVoN, AlexALX
function PANEL:RegisterHooks()
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self._SetVisible = self.SetVisible;
	self.SetVisible = function(self,b)
		if(b) then
			if(self.OnOpen) then
				local ret = self:OnOpen();
				if(ret ~= nil) then return ret end;
			end
		else
			if(self.OnClose) then
				local ret = self:OnClose();
				if(ret ~= nil) then return ret end;
			end
		end
		self._SetVisible(self,b);
	end
	self._Think = self.Think;
	self.Think = function(self)
		local x,y = gui.MousePos();
		if(x ~= ScrW()/2 and y ~= ScrH() and x > 1 and y > 1) then -- Prevents some resnapping bugs
			self.Data.MouseX,self.Data.MouseY = x,y;
		end
		self.Data.DialType = self.VGUI.AddressSelect:GetDialType();
		local x,y = self:GetPos();
		self.Data.PosX, self.Data.PosY = x,y;
		self._Think(self);
	end
	self._PerformLayout = self.PerformLayout;
	self.PerformLayout = function()
		--####### Save Width/Heigth
		local w,h = self:GetSize();
		self.VGUI.AddressSelect:SetSize(w-20,h-(60+10));
		self.Data.SizeW, self.Data.SizeH = w,h;
		self._PerformLayout(self);
	end
	-- for new gmod
	self:MakePopup();
	self:SetSizable(true)
	self:SetDeleteOnClose( false )
	self:SetTitle("")
	self.Logo = vgui.Create("DImage",self);
	self.Logo:SetPos(8,10);
	self.Logo:SetImage("gui/cap_logo");
	self.Logo:SetSize(16,16);
	-- for smaller font from gmod10
	for k,v in pairs(self.VGUI) do
		if (k=="NameTextEntry") then continue end
		if (v.SetFont) then
			v:SetFont("OldDefaultSmall");
		end
		if (v.Label and v.Label.SetFont) then
			v.Label:SetFont("OldDefaultSmall");
		end
		if (type(v)=="table") then
			for k2,v2 in pairs(v) do
				if (v2.SetFont) then
					v2:SetFont("OldDefaultSmall");
				end
			end
		end
	end
end

--################# Open Hook @aVoN
function PANEL:OnOpen()
	self:SetKeyBoardInputEnabled(true);
	self:SetMouseInputEnabled(true);
	self.AlphaTime = CurTime(); -- For the FadeIn/Out
	self.FadeOut = nil;
	self:SetAlpha(1); -- We will fade in!
	self.VGUI.AddressSelect:RefreshList(true);
	if(self.Data.MouseX and self.Data.MouseY) then
		gui.SetMousePos(self.Data.MouseX,self.Data.MouseY);
	end
	if (self.Data.SizeH!=nil and self.Data.SizeW!=nil) then
		self:SetSize(self.Data.SizeW,self.Data.SizeH);
	end
	if (self.Data.PosX!=nil and self.Data.PosY!=nil) then
		self:SetPos(self.Data.PosX,self.Data.PosY);
	end
	if (self.Data.DialType!=nil) then
		self.VGUI.AddressSelect:SetDialType(self.Data.DialType);
	end
end

--################# Close Hook @aVoN
function PANEL:OnClose()
	self:SetKeyBoardInputEnabled(false);
	self:SetMouseInputEnabled(false);
	self.AlphaTime = CurTime(); -- For the FadeIn/Out
	self.FadeOut = true;
	return false; -- Override default fadeout
end

--################# Paint @aVoN
function PANEL:Paint(w,h)
	-- Fade in!
	local alpha = math.Clamp(CurTime() - (self.AlphaTime or 0),0,0.20)*5;
	if(self.FadeOut) then
		alpha = 1-alpha;
		if(alpha == 0) then
			self:_SetVisible(false);
			self.FadeOut = nil;
		end
	end
	draw.RoundedBox(10,0,0,w,h,Color(16,16,16,160*alpha));
	self:SetAlpha(alpha*255);
	return true;
end

--################# Sets a value to the address field @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressSelect:SetText(text);
end

--################# Gets an address @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressSelect:GetValue();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e,nox)
	self.Entity = e;
	if (not nox) then nox = false end
	self.Nox = nox;
	self.VGUI.AddressSelect:SetEntity(e);
end

vgui.Register("SControlePanelDHD_Group",PANEL,"DFrame");

--##################################
--###### The DHD Panel (And Later for a mobile DHD)
--##################################

local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = data;
PANEL.Images = {
	Valid = "icon16/accept.png",
	Invalid = "icon16/cancel.png",
	Editing = "icon16/table_edit.png",
	Warning = "icon16/error.png",
	Info = "icon16/information.png",
}
PANEL.Sounds = {
	Warning = Sound("buttons/button2.wav"),
	Info = Sound("buttons/button9.wav"),
}

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(440,160);
	self:SetMinimumSize(440,160);
	self:SetPos(10,10); -- No Center because I'm planing making it able to dial a DHD by just clicking with the mouse on it
	--self:Center();
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressSelect = vgui.Create("SAddressSelect_Group",self),
		AddressSelectLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
		GroupLabel = vgui.Create("DLabel",self),
		GroupTextEntry = vgui.Create("DMultiChoice",self),
		GroupStatus = vgui.Create("DLabel",self),
		StatusImage = vgui.Create("DImage",self),
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(SGLanguage.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetPos(30,7);
	self.VGUI.TitleLabel:SetWide(200);
	--###### Select Address
	-- The topic
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressSelectLabel[i]:SetText(SGLanguage.GetMessage("stargate_vgui_dial"));
		self.VGUI.AddressSelectLabel[i]:SetWide(200);
		self.VGUI.AddressSelectLabel[i]:SetPos(10-mul*2,35-mul*2);
		self.VGUI.AddressSelectLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end

	-- Group
	self.VGUI.GroupLabel:SetText(SGLanguage.GetMessage("stargate_vgui_group"));
	self.VGUI.GroupStatus:SetText("");

	local grouppos = 145;
	-- The Description above the TextEntry
 	self.VGUI.GroupLabel:SetPos(grouppos,35);

	-- The Group TextEntry
	self.VGUI.GroupTextEntry:SetPos(grouppos+45,35);
	self.VGUI.GroupTextEntry:SetSize(35,self.VGUI.GroupTextEntry:GetTall());
	self.VGUI.GroupTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_grptip"));
	--This function restricts the letters you can enter to a valid address
	self.VGUI.GroupTextEntry.TextEntry.OnTextChanged = function(TextEntry)
		local text = TextEntry:GetValue();
		if(text ~= self.LastGroup) then
			local pos = TextEntry:GetCaretPos();
			local len = text:len();
			local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
			local text = ""; -- Wipe
			for _,v in pairs(letters) do
				if(not text:find(v)) then
					text = text..v;
				end
			end
			text = text:sub(1,2);
			self.LastGroup = text;
			TextEntry:SetText(text);
			TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			self:SetStatus(text);
		end
	end

	self.VGUI.GroupTextEntry.OnSelect = function(panel,index,value,data)
		local text = data;
		if(text ~= self.LastGroup) then
			local pos = panel.TextEntry:GetCaretPos();
			local len = text:len();
			local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
			text = text:sub(1,2);
			self.LastGroup = text;
			panel.TextEntry:SetText(text);
			panel.TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			self:SetStatus(text);
		else
			panel.TextEntry:SetText(text);
		end
	end

	self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp1"),"M@");
	self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp2"),"P@");
	self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp3"),"I@");
	self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp8"),"OT");
	self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp4"),"O@");
	if (SG_CUSTOM_GROUPS) then
		for g,d in pairs(SG_CUSTOM_GROUPS) do
			self.VGUI.GroupTextEntry:AddChoice(d[1],g);
		end
	end

	-- Status Label
	self.VGUI.StatusImage:SetPos(grouppos+85,35);
	self.VGUI.StatusImage:SetSize(16,16);
	self.VGUI.GroupStatus:SetPos(grouppos+105,35);
	self.VGUI.GroupStatus:SetWide(200);

	-- Our AddressPanel (Where we set Addresses with)
	self.OnAddressSet = function(e,group)
		if((self.AlphaTime or 0)+0.3 < CurTime()) then -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
			e:SetGateGroup(group);
			timer.Remove("_StarGate.RefreshAddressList");
			timer.Create("_StarGate.RefreshAddressList",0.25,1,
				function()
					if(self!=nil and self.VGUI!=nil) then
						self.VGUI.AddressSelect:RefreshList(true);
					end
				end
			);
		end
	end

	-- Our AddressSelect Panel (Where we dial Addresses from)
	self.VGUI.AddressSelect:SetPos(10,60);
	self.VGUI.AddressSelect.OnDial = function(e,address,mode)
		e:DialGate(address,mode);
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnAbort = function(e)
		e:AbortDialling();
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnTextChanged = function(AddressSelect)
		if(self.OnTextChanged) then self.OnTextChanged(AddressSelect) end;
	end
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self:RegisterHooks();
end

--################# Sets a value to the address field @aVoN
function PANEL:SetText(g)
	local g = (g or ""):upper();
	self.VGUI.GroupTextEntry.TextEntry:SetText(g);
	self.LastGroup = g;
	self:SetStatus(g,true);
end

--################# Gets an address @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressSelect:GetValue();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self.VGUI.AddressSelect:SetEntity(e);
	self:SetText(e:GetGateGroup())
end

--################# Sets the status (Valid/Invalid/Already Exists) @aVoN
function PANEL:SetStatus(g,no_message)
	local g = (g or ""):upper();
	if(g:len() == 2) then
		self.VGUI.StatusImage:SetImage(self.Images.Valid);
		if (not no_message) then surface.PlaySound(self.Sounds["Info"]); end
		if(self.OnAddressSet) then self.OnAddressSet(self.Entity,g:upper()) end; -- SET THE GROUP!
		if (g == "M@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp1"));
		elseif (g == "P@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp2"));
		elseif (g == "I@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp3"));
		elseif (g == "OT") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp8"));
		elseif (g == "O@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp4"));
		elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
			self.VGUI.GroupStatus:SetText(SG_CUSTOM_GROUPS[g][1]);
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc"));
		end
	else
		-- Typing address!
		self.VGUI.StatusImage:SetImage(self.Images.Editing);
		if (g == "M@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp1"));
		elseif (g == "P@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp2"));
		elseif (g == "I@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp3"));
		elseif (g == "OT") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp8"));
		elseif (g == "O@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp4"));
		elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
			self.VGUI.GroupStatus:SetText(SG_CUSTOM_GROUPS[g][1]);
		elseif (g:len() == 2) then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc"));
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_edit"));
		end
	end
end

vgui.Register("SControlePanelDHD_OrlinGroup",PANEL,"DFrame");

--##################################
--###### SControlePanel_GroupSGU.lua
--##################################

--##################################
--###### The DHD Panel (And Later for a mobile DHD)
--##################################

local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = data;

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(440,160);
	self:SetMinimumSize(440,160);
	self:SetPos(10,10); -- No Center because I'm planing making it able to dial a DHD by just clicking with the mouse on it
	--self:Center();
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressSelect = vgui.Create("SAddressSelect_NoGroup",self),
		AddressSelectLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(SGLanguage.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetPos(30,7);
	self.VGUI.TitleLabel:SetWide(200);
	--###### Select Address
	-- The topic
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressSelectLabel[i]:SetText(SGLanguage.GetMessage("stargate_vgui_dial"));
		self.VGUI.AddressSelectLabel[i]:SetWide(200);
		self.VGUI.AddressSelectLabel[i]:SetPos(10-mul*2,35-mul*2);
		self.VGUI.AddressSelectLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end
	-- Our AddressSelect Panel (Where we dial Addresses from)
	self.VGUI.AddressSelect:SetPos(10,60);
	self.VGUI.AddressSelect.OnDial = function(e,address,mode)
		e:DialGate(address,mode,self.Nox);
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnAbort = function(e)
		e:AbortDialling();
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnTextChanged = function(AddressSelect)
		if(self.OnTextChanged) then self.OnTextChanged(AddressSelect) end;
	end
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self:RegisterHooks();
end

--################# Sets a value to the address field @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressSelect:SetText(text);
end

--################# Gets an address @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressSelect:GetValue();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e,nox)
	self.Entity = e;
	if (not nox) then nox = false end
	self.Nox = nox;
	self.VGUI.AddressSelect:SetEntity(e);
end
vgui.Register("SControlePanelDHD_NoGroup",PANEL,"DFrame");

--##################################
--###### The DHD Panel (And Later for a mobile DHD)
--##################################

local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = data;
PANEL.Images = {
	Valid = "icon16/accept.png",
	Invalid = "icon16/cancel.png",
	Editing = "icon16/table_edit.png",
	Warning = "icon16/error.png",
	Info = "icon16/information.png",
}
PANEL.Sounds = {
	Warning = Sound("buttons/button2.wav"),
	Info = Sound("buttons/button9.wav"),
}

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(440,160);
	self:SetMinimumSize(440,160);
	self:SetPos(10,10); -- No Center because I'm planing making it able to dial a DHD by just clicking with the mouse on it
	--self:Center();
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressSelect = vgui.Create("SAddressSelect_NoGroup",self),
		AddressSelectLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
		GroupLabel = vgui.Create("DLabel",self),
		GroupTextEntry = vgui.Create("DMultiChoice",self),
		GroupStatus = vgui.Create("DLabel",self),
		StatusImage = vgui.Create("DImage",self),
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(SGLanguage.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetPos(30,7);
	self.VGUI.TitleLabel:SetWide(200);
	--###### Select Address
	-- The topic
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressSelectLabel[i]:SetText(SGLanguage.GetMessage("stargate_vgui_dial"));
		self.VGUI.AddressSelectLabel[i]:SetWide(200);
		self.VGUI.AddressSelectLabel[i]:SetPos(10-mul*2,35-mul*2);
		self.VGUI.AddressSelectLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end

	-- Group
	self.VGUI.GroupLabel:SetText(SGLanguage.GetMessage("stargate_vgui_group"));
	self.VGUI.GroupStatus:SetText("");

	local grouppos = 145;
	-- The Description above the TextEntry
 	self.VGUI.GroupLabel:SetPos(grouppos,35);

	-- The Group TextEntry
	self.VGUI.GroupTextEntry:SetPos(grouppos+45,35);
	self.VGUI.GroupTextEntry:SetSize(35,self.VGUI.GroupTextEntry:GetTall());
	self.VGUI.GroupTextEntry:SetTooltip(SGLanguage.GetMessage("stargate_vgui_grptip"));
	--This function restricts the letters you can enter to a valid address
	self.VGUI.GroupTextEntry.TextEntry.OnTextChanged = function(TextEntry)
		local text = TextEntry:GetValue();
		if(text ~= self.LastGroup) then
			local pos = TextEntry:GetCaretPos();
			local len = text:len();
			local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
			local text = ""; -- Wipe
			for _,v in pairs(letters) do
				if(not text:find(v)) then
					text = text..v;
				end
			end
			text = text:sub(1,2);
			self.LastGroup = text;
			TextEntry:SetText(text);
			TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			self:SetStatus(text);
		end
	end

	self.VGUI.GroupTextEntry.OnSelect = function(panel,index,value,data)
		local text = data;
		if(text ~= self.LastGroup) then
			local pos = panel.TextEntry:GetCaretPos();
			local len = text:len();
			local letters = text:upper():gsub("[^0-9A-Z@]",""):TrimExplode(""); -- Upper, remove invalid chars and split!
			text = text:sub(1,2);
			self.LastGroup = text;
			panel.TextEntry:SetText(text);
			panel.TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,text:len())); -- Reset the caretpos!
			self:SetStatus(text);
		else
			panel.TextEntry:SetText(text);
		end
	end

	self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp1"),"M@");
	self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp2"),"P@");
	self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp3"),"I@");
	self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp8"),"OT");
	self.VGUI.GroupTextEntry:AddChoice(SGLanguage.GetMessage("stargate_vgui_grp4"),"O@");
	if (SG_CUSTOM_GROUPS) then
		for g,d in pairs(SG_CUSTOM_GROUPS) do
			self.VGUI.GroupTextEntry:AddChoice(d[1],g);
		end
	end

	-- Status Label
	self.VGUI.StatusImage:SetPos(grouppos+85,35);
	self.VGUI.StatusImage:SetSize(16,16);
	self.VGUI.GroupStatus:SetPos(grouppos+105,35);
	self.VGUI.GroupStatus:SetWide(200);

	-- Our AddressPanel (Where we set Addresses with)
	self.OnAddressSet = function(e,group)
		if((self.AlphaTime or 0)+0.3 < CurTime()) then -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
			e:SetGateGroup(group);
			timer.Remove("_StarGate.RefreshAddressList");
			timer.Create("_StarGate.RefreshAddressList",0.25,1,
				function()
					if(self!=nil and self.VGUI!=nil) then
						self.VGUI.AddressSelect:RefreshList(true);
					end
				end
			);
		end
	end

	-- Our AddressSelect Panel (Where we dial Addresses from)
	self.VGUI.AddressSelect:SetPos(10,60);
	self.VGUI.AddressSelect.OnDial = function(e,address,mode)
		e:DialGate(address,mode);
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnAbort = function(e)
		e:AbortDialling();
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnTextChanged = function(AddressSelect)
		if(self.OnTextChanged) then self.OnTextChanged(AddressSelect) end;
	end
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self:RegisterHooks();
end

--################# Sets a value to the address field @aVoN
function PANEL:SetText(g)
	local g = (g or ""):upper();
	self.VGUI.GroupTextEntry.TextEntry:SetText(g);
	self.LastGroup = g;
	self:SetStatus(g,true);
end

--################# Gets an address @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressSelect:GetValue();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self.VGUI.AddressSelect:SetEntity(e);
	self:SetText(e:GetGateGroup())
end

--################# Sets the status (Valid/Invalid/Already Exists) @aVoN
function PANEL:SetStatus(g,no_message)
	local g = (g or ""):upper();
	if(g:len() == 2) then
		self.VGUI.StatusImage:SetImage(self.Images.Valid);
		if (not no_message) then surface.PlaySound(self.Sounds["Info"]); end
		if(self.OnAddressSet) then self.OnAddressSet(self.Entity,g:upper()) end; -- SET THE GROUP!
		if (g == "M@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp1"));
		elseif (g == "P@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp2"));
		elseif (g == "I@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp3"));
		elseif (g == "OT") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp8"));
		elseif (g == "O@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp4"));
		elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
			self.VGUI.GroupStatus:SetText(SG_CUSTOM_GROUPS[g][1]);
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc"));
		end
	else
		-- Typing address!
		self.VGUI.StatusImage:SetImage(self.Images.Editing);
		if (g == "M@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp1"));
		elseif (g == "P@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp2"));
		elseif (g == "I@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp3"));
		elseif (g == "OT") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp8"));
		elseif (g == "O@") then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grp4"));
		elseif (SG_CUSTOM_GROUPS and SG_CUSTOM_GROUPS[g]) then
			self.VGUI.GroupStatus:SetText(SG_CUSTOM_GROUPS[g][1]);
		elseif (g:len() == 2) then
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_grpc"));
		else
			self.VGUI.GroupStatus:SetText(SGLanguage.GetMessage("stargate_vgui_edit"));
		end
	end
end

vgui.Register("SControlePanelDHD_OrlinNoGroup",PANEL,"DFrame");

--##################################
--###### SControlePanel_NoGroupSGU.lua
--##################################

--##################################
--###### The DHD Panel (And Later for a mobile DHD)
--##################################

local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = data;

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(440,160);
	self:SetMinimumSize(440,160);
	self:SetPos(10,10); -- No Center because I'm planing making it able to dial a DHD by just clicking with the mouse on it
	--self:Center();
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressSelect = vgui.Create("SAddressSelect",self),
		AddressSelectLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(SGLanguage.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetPos(30,7);
	self.VGUI.TitleLabel:SetWide(200);
	--###### Select Address
	-- The topic
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressSelectLabel[i]:SetText(SGLanguage.GetMessage("stargate_vgui_dial"));
		self.VGUI.AddressSelectLabel[i]:SetWide(200);
		self.VGUI.AddressSelectLabel[i]:SetPos(10-mul*2,35-mul*2);
		self.VGUI.AddressSelectLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end
	-- Our AddressSelect Panel (Where we dial Addresses from)
	self.VGUI.AddressSelect:SetPos(10,60);
	self.VGUI.AddressSelect.OnDial = function(e,address,mode)
		e:DialGate(address,mode);
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnAbort = function(e)
		e:AbortDialling();
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnTextChanged = function(AddressSelect)
		if(self.OnTextChanged) then self.OnTextChanged(AddressSelect) end;
	end
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self:RegisterHooks();
end

--################# Sets a value to the address field @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressSelect:SetText(text);
end

--################# Gets an address @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressSelect:GetValue();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self.VGUI.AddressSelect:SetEntity(e);
end

vgui.Register("SControlePanelDHDSuper",PANEL,"DFrame");

--##################################
--###### SControlePanel_Galaxy.lua
--##################################

local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = data;

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(440,160);
	self:SetMinimumSize(440,160);
	self:SetPos(10,10); -- No Center because I'm planing making it able to dial a DHD by just clicking with the mouse on it
	--self:Center();
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressSelect = vgui.Create("SAddressSelect_Galaxy",self),
		AddressSelectLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(SGLanguage.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetPos(30,7);
	self.VGUI.TitleLabel:SetWide(200);
	--###### Select Address
	-- The topic
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressSelectLabel[i]:SetText(SGLanguage.GetMessage("stargate_vgui_dial"));
		self.VGUI.AddressSelectLabel[i]:SetPos(10-mul*2,35-mul*2);
		self.VGUI.AddressSelectLabel[i]:SetWide(200);
		self.VGUI.AddressSelectLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end
	-- Our AddressSelect Panel (Where we dial Addresses from)
	self.VGUI.AddressSelect:SetPos(10,60);
	self.VGUI.AddressSelect.OnDial = function(e,address,mode)
		e:DialGate(address,mode,self.Nox);
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnAbort = function(e)
		e:AbortDialling();
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnTextChanged = function(AddressSelect)
		if(self.OnTextChanged) then self.OnTextChanged(AddressSelect) end;
	end
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self:RegisterHooks();
end

--################# Sets a value to the address field @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressSelect:SetText(text);
end

--################# Gets an address @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressSelect:GetValue();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e,nox)
	self.Entity = e;
	if (not nox) then nox = false end
	self.Nox = nox;
	self.VGUI.AddressSelect:SetEntity(e);
end

vgui.Register("SControlePanelDHD_Galaxy",PANEL,"DFrame");

--##################################
--###### SControlePanel_NoGalaxy.lua
--##################################

local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = data;

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(440,160);
	self:SetMinimumSize(440,160);
	self:SetPos(10,10); -- No Center because I'm planing making it able to dial a DHD by just clicking with the mouse on it
	--self:Center();
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressSelect = vgui.Create("SAddressSelect_NoGalaxy",self),
		AddressSelectLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(SGLanguage.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetPos(30,7);
	self.VGUI.TitleLabel:SetWide(200);
	--###### Select Address
	-- The topic
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressSelectLabel[i]:SetText(SGLanguage.GetMessage("stargate_vgui_dial"));
		self.VGUI.AddressSelectLabel[i]:SetPos(10-mul*2,35-mul*2);
		self.VGUI.AddressSelectLabel[i]:SetWide(200);
		self.VGUI.AddressSelectLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end
	-- Our AddressSelect Panel (Where we dial Addresses from)
	self.VGUI.AddressSelect:SetPos(10,60);
	self.VGUI.AddressSelect.OnDial = function(e,address,mode)
		e:DialGate(address,mode,self.Nox);
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnAbort = function(e)
		e:AbortDialling();
		self:SetVisible(false);
	end
	self.VGUI.AddressSelect.OnTextChanged = function(AddressSelect)
		if(self.OnTextChanged) then self.OnTextChanged(AddressSelect) end;
	end
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self:RegisterHooks();
end

--################# Sets a value to the address field @aVoN
function PANEL:SetText(text)
	self.VGUI.AddressSelect:SetText(text);
end

--################# Gets an address @aVoN
function PANEL:GetValue()
	return self.VGUI.AddressSelect:GetValue();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e,nox)
	self.Entity = e;
	if (not nox) then nox = false end
	self.Nox = nox;
	self.VGUI.AddressSelect:SetEntity(e);
end

vgui.Register("SControlePanelDHD_NoGalaxy",PANEL,"DFrame");