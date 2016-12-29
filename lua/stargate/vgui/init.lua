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

-- Stargate Custom Groups sync with client @AlexALX
SG_CUSTOM_GROUPS = {}
SG_CUSTOM_TYPES = {}

net.Receive("_SGCUSTOM_GROUPS",function(len)
	SG_CUSTOM_GROUPS = net.ReadTable();
	SG_CUSTOM_TYPES = net.ReadTable();
end)

--#################
-- shelpbutton.lua
-- Help Button
--#################

local PANEL = {};

--################# Inits @aVoN
function PANEL:Init()
	self:SetSize(self:GetParent():GetWide(),25);
	self:SetToolTip("Click here to get additional Information");
	self:SetCursor("hand");
	self.Topic = "Help";
	-- VGUI Elements
	self.VGUI = {
		HelpImage = vgui.Create("DImage",self),
		HelpLabel = vgui.Create("DLabel",self),
	}
	-- Help image
	self.VGUI.HelpImage:SetPos(5,4);
	self.VGUI.HelpImage:SetSize(16,16);
	self.VGUI.HelpImage:SetImage("gui/info");

	-- Help Label
	self.VGUI.HelpLabel:SetPos(25,3);
	self.VGUI.HelpLabel:SetWide(500);
	self.VGUI.HelpLabel:SetText(SGLanguage.GetMessage("stool_help"));
	self.VGUI.HelpLabel:SetTextColor(Color(0,0,0,255))
end

local VGUI;
--################# Open the HELP @aVoN
function PANEL:OnMousePressed()
	if (self.Steam and self.URL) then
		gui.OpenURL(self.URL); return
	end
	if (VGUI and VGUI.Remove) then VGUI:Remove(); end
	VGUI = vgui.Create("SHTMLHelp");
	if(self.URL) then
		VGUI:SetURL(self.URL);
	else
		VGUI:SetHelp(self.Help);
	end
	VGUI:SetText(self.Topic);
	VGUI:SetVisible(true);
end

--################# Adds the Topic of the HTML Frame @aVoN
function PANEL:SetTopic(text)
	self.Topic = text;
end

--################# Set's the label's Text @aVoN
function PANEL:SetText(text)
	self.VGUI.HelpLabel:SetText(text);
end

--################# Set's the label's Text @aVoN
function PANEL:SetImage(image)
	self.VGUI.HelpImage:SetImage(image);
end

--################# HELP Category @aVoN
function PANEL:SetHelp(help)
	self.Help = help;
end

--################# Sets the URL - If set, "SetHelp" won't be used! OVERRIDE! @aVoN
function PANEL:SetURL(url,steam)
	self.URL = url;
	self.Steam = steam;
end

--################# Paint @aVoN
function PANEL:Paint()
	draw.RoundedBox(10,0,0,self:GetWide(),self:GetTall(),Color(16,16,16,100));
	return true;
end

vgui.Register("SHelpButton",PANEL,"Panel");

--#################
-- shtmlhelp.lua
-- This HTMl Based Frame will show HTML HELP
--#################

local PANEL = {};
PANEL.Data = {
	URL="https://github.com/RafaelDeJongh/cap/wiki/", -- Base URL
	Width=ScrW()-100,
	Heigth=ScrH()-100,
}

--################# Inits @aVoN
function PANEL:Init()
	self:SetMinimumSize(100,40);
	self.Logo = vgui.Create("DImage",self);
	self.Logo:SetPos(8,10);
	self.Logo:SetImage("gui/cap_logo");
	self.Logo:SetSize(16,16);
	self:SetSize(self.Data.Width,self.Data.Heigth);
	self:SetKeyBoardInputEnabled(true);
	self:SetMouseInputEnabled(true);
	if(not self.Data.HasBeenOpened) then
		self:Center();
		self.Data.HasBeenOpened =true;
	else
		self:SetPos(self.Data.X,self.Data.Y);
	end
	self.VGUI = {
		HTML = vgui.Create("DHTML",self),
		TitleLabel = vgui.Create("DLabel",self),
	};
	self.VGUI.TitleLabel:SetPos(30,7);
	self.VGUI.TitleLabel:SetText("Help");
	self.VGUI.TitleLabel:SetWide(300);
	self.VGUI.HTML:SetPos(10,30);
	self:RegisterHooks();
end

--################# Set the required URL @aVoN
function PANEL:SetURL(url)
	self.VGUI.HTML:OpenURL(url);
end

--################# Set the required HTML @AlexALX
function PANEL:SetHTML(html)
	self.VGUI.HTML:SetHTML(html);
end

--################# Topic! @aVoN
function PANEL:SetText(text)
	self.VGUI.TitleLabel:SetText((text or ""):gsub("#",""));
end

--################# HELP Category @aVoN
function PANEL:SetHelp(help)
	self:SetURL(self.Data.URL..help);
end

--################# Paint @aVoN
function PANEL:Paint(w,h)
	-- Fade in!
	local alpha = math.Clamp(CurTime() - (self.AlphaTime or 0),0,0.20)*5;
	if(self.FadeOut) then
		alpha = 1-alpha;
		if(alpha == 0) then
			--self:_SetVisible(false);
			--self.FadeOut = nil;
			self:Remove();
		end
	end
	draw.RoundedBox(10,0,0,w,h,Color(16,16,16,160*alpha));
	local w,h = self.VGUI.HTML:GetSize();
	draw.RoundedBox(10,10,30,w,h,Color(255,255,255,255*alpha));
	self:SetAlpha(alpha*255);
	return true;
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
		self.Data.X,self.Data.Y = self:GetPos();
		self._Think(self);
	end
	self._PerformLayout = self.PerformLayout;
	self.PerformLayout = function()
		local w,h = self:GetSize();
		self.VGUI.HTML:SetSize(w-20,h-40);
		self.Data.Width,self.Data.Heigth = w,h;
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
end

--################# Open Hook @aVoN
function PANEL:OnOpen()
	self:SetKeyBoardInputEnabled(true);
	self:SetMouseInputEnabled(true);
	self.AlphaTime = CurTime(); -- For the FadeIn/Out
	self.FadeOut = nil;
	self:SetAlpha(1); -- We will fade in!
	if (self.Data.Width!=nil and self.Data.Heigth!=nil) then
		self:SetSize(self.Data.Width,self.Data.Heigth);
	end
	if (self.Data.X!=nil and self.Data.Y!=nil) then
		self:SetPos(self.Data.X,self.Data.Y);
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

vgui.Register("SHTMLHelp",PANEL,"DFrame");

--#################
-- skeyboardkey.lua
-- Creates the keyboard-layout "button", where you can change the current bound key to another
--#################

local PANEL = {};
PANEL.KeyboardPanels = {}; -- Stores all related KeyBoard-Key buttons, so if one overrides the bind of another, the other one get's "empty"

--################# Inits @aVoN
function PANEL:Init()
	local w,h = self:GetParent():GetWide(),20;
	self:SetSize(w,h);
	-- name of this key
	self.Label = vgui.Create("DLabel",self);
	self.Label:SetFont("Default");
	self.Label:SetText("");
	-- Key it is bound to
	self.Key = vgui.Create("DLabel",self);
	self.Key:SetFont("Default");
	self.Key:SetText("");
	self.Key.__IsVisible = true;
end

--################# Name of this button @aVoN
-- This e.g. says "Forward Key"
function PANEL:SetText(s)
	self.Label:SetText(s);
end

--################# Sets all data at once @aVoN
function PANEL:SetData(layout,name,key)
	self:SetLayout(layout);
	self:SetKey(key);
	self:SetText(name);
end

--################# Update current key @aVoN
function PANEL:Update()
	if(self.Layout) then
		self.Key:SetText((self.Layout:GetKey(self.__Key) or ""):upper()); -- if it's KBD_Layout:SetDefaultKey("FWD","KP_INS"), it will set to a given "FWD" the text to "KP_INS"
	end
end

--################# Set's a keystring, we want to rebind @aVoN
-- Which key-string is it referred to? This is NOT the key like KP_INS or other stuff. It is that string, you defined in KBD_Layout:SetDefaultKey(key_string,key). E.g. KBD_Layout:SetDefaultKey("FWD","KP_INS"). -> Then, it'S "FWD" you need to use here
-- Make sure, you call this AFTER you set a Layout
function PANEL:SetKey(key)
	self.__Key = key;
	self:Update();
end

--################# Sets a layout @aVoN
function PANEL:SetLayout(name)
	self.Layout = StarGate.KeyBoard:Get(name);
	self.KeyboardPanels[self.Layout] = self.KeyboardPanels[self.Layout] or {};
	table.insert(self.KeyboardPanels[self.Layout],self);
end

--################# Get clicks and double-clicks @aVoN
local CURRENT; -- Used for the current active keysettings binder to highlight

function PANEL:OnMousePressed(mc)
	if(self.Edit) then return end; -- Must be disabled on edit. Otherwise, OnMousePressed overides our StarGate.KeyBoard:GetPressedKey() function so we dont get "he pressed MOUSE1" etc
	if(mc == MOUSE_LEFT) then
		local time = CurTime();
		if(CURRENT == self and (self.LastClick or 0) + 0.3 > time) then -- Double-clicked!
			-- Do double click stuff!
			self:OnDoubleClick();
		else -- Single clicked
			self:OnClick()
			CURRENT = self;
		end
		self.LastClick = time;
	end
end

--################# He clicked once@aVoN
function PANEL:OnClick()
	if(IsValid(CURRENT)) then
		CURRENT.Highlight = nil;
		CURRENT.Edit = nil;
	end
	self.Highlight = true;
end

--################# He clicked once@aVoN
function PANEL:OnDoubleClick()
	--StarGate.KeyBoard:GetPressedKey(); -- Most likely, you are holding down the spawnmenu or contextmenu key. This key is ignored once, except you press it again, if we run this once here
	self.Edit = true;
	input.StartKeyTrapping();
	self.Highlight = false;
end

--################# Highlight and Edit colors in Paint@aVoN
local HIGHLIGHT = Color(0,211,255);
local EDIT = Color(255,166,0);
local BLACK = Color(255,255,255,255);
local WHITE = Color(0,0,0,255);

function PANEL:Paint()
	if(self.Highlight) then
		local w,h = self:GetSize();
		draw.RoundedBox(1,0,0,w,h,HIGHLIGHT);
		self.Label:SetTextColor(BLACK);
		self.Key:SetTextColor(BLACK);
	else
		self.Label:SetTextColor(WHITE);
		self.Key:SetTextColor(WHITE);
	end
	if(self.Edit) then
		local w,h = self:GetSize();
		draw.RoundedBox(1,w*0.6,0,w*0.4,h,EDIT);
		-- Because we are in a Paint hook, calling SetVisible all the time causes lag. So we just call it, if necessary
		if(self.Key.__IsVisible) then
			self.Key.__IsVisible = nil;
			self.Key:SetVisible(false);
		end
	else
		if(not self.Key.__IsVisible) then
			self.Key.__IsVisible = true
			self.Key:SetVisible(true);
		end
	end
end

--################# Perform layout@aVoN
function PANEL:PerformLayout()
	local w,h = self:GetSize();
	self.Label:SetPos(2,0);
	self.Label:SetSize(w*0.6 - 4,h);
	self.Key:SetPos(w*0.6 + 2,0);
	self.Key:SetSize(w*0.4 - 4,h);
end

--################# Binds a new key @aVoN
function PANEL:SetNewBind(key)
	self.Edit = nil;
	self.Layout:SetKey(self.__Key,key);
	-- Update all other VGUIs
	for k,v in pairs(self.KeyboardPanels[self.Layout]) do
		v:Update();
	end
end

--################# Think - Here, we retrieve the current pressed button @aVoN
function PANEL:Think()
	if(not self.Edit or not input.IsKeyTrapping()) then return end;
	if(not self.Layout) then return end;
	local key = input.CheckKeyTrapping(); --StarGate.KeyBoard:GetPressedKey(); -- Currently pressed key
	if(key == KEY_ESCAPE) then self.Edit = nil return end;
	if(key) then self:SetNewBind(key) end;
end

-- Must be called after the gamemode loaded or we get an error
local function OnInitialize()
	--################# Disallows closing the spawn- or contextmenu if we are in "EDIT" mode @aVoN
	GAMEMODE.__OnContextMenuClose = GAMEMODE.__OnContextMenuClose or GAMEMODE.OnContextMenuClose;
	GAMEMODE.__OnSpawnMenuClose = GAMEMODE.__OnSpawnMenuClose or GAMEMODE.OnSpawnMenuClose;
	function GAMEMODE:OnContextMenuClose()
		if(IsValid(CURRENT) and CURRENT.Edit) then return end;
		if (self.__OnContextMenuClose!=nil) then self.__OnContextMenuClose(self) end
	end
	function GAMEMODE:OnSpawnMenuClose()
		if(IsValid(CURRENT) and CURRENT.Edit) then return end;
		if (self.__OnSpawnMenuClose!=nil) then self.__OnSpawnMenuClose(self) end
	end
end
hook.Add("Initialize","SKeyboardKey.Initialize",OnInitialize);

vgui.Register("SKeyboardKey",PANEL,"Panel");

--
-- prop_generic is the base for all other properties.
-- All the business should be done in :Setup using inline functions.
-- So when you derive from this class - you should ideally only override Setup.
--

local PANEL = {}

function PANEL:Setup( vars )

	self:Clear()

	local text = self:Add( "DTextEntry" )
	text:SetUpdateOnType( true )
	text:SetDrawBackground( false )
	text:Dock( FILL )
	text:SetNumeric(true)
	self.TextEntry = text;

	-- Return true if we're editing
	self.IsEditing = function( self )
		return text:IsEditing()
	end

	-- Set the value
	self.SetValue = function( self, val )
		text:SetText( util.TypeToString( val ) )
	end

	-- Alert row that value changed
	text.OnValueChange = function( text, newval )

		self:ValueChanged( newval )

	end

end

vgui.Register( "DProperty_CapNumber", PANEL, "DProperty_Generic" )