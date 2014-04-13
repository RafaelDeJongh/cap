/*
	Stargate for GarrysMod10
	Copyright (C) 2007-2009  aVoN

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

-- Creates the keyboard-layout "button", where you can change the current bound key to another

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
		self.Key:SetText(self.Layout:GetKey(self.__Key) or ""); -- if it's KBD_Layout:SetDefaultKey("FWD","KP_INS"), it will set to a given "FWD" the text to "KP_INS"
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
	StarGate.KeyBoard:GetPressedKey(); -- Most likely, you are holding down the spawnmenu or contextmenu key. This key is ignored once, except you press it again, if we run this once here
	self.Edit = true;
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
	if(not self.Edit) then return end;
	if(not self.Layout) then return end;
	if(input.IsKeyDown(KEY_ESCAPE)) then self.Edit = nil return end; -- Sadly, this also opens the "console". No idea how to stop it.
	local key = StarGate.KeyBoard:GetPressedKey(); -- Currently pressed key
	if(key) then self:SetNewBind(key) end;
end

--################# Hacky workaround to get mousewheel actions. garry fucked input.IsKeyDown not returning "true" if the wheel is pressed @aVoN
-- http://bugs.garrysmod.com/view.php?id=1695
function PANEL:OnMouseWheeled(mc)
	if(not self.Edit) then return end;
	if(mc == 1) then -- Wheel up
		self:SetNewBind("MWHEELUP");
	end
	if(mc == -1) then -- Wheel down
		self:SetNewBind("MWHEELDOWN");
	end
	return false;
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