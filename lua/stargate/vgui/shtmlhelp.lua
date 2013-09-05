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

-- This HTMl Based Frame will show HTML HELP

local PANEL = {};
PANEL.Data = {
	URL="http://sg-carterpack.com/wiki/", -- Base URL
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
			self:_SetVisible(false);
			self.FadeOut = nil;
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