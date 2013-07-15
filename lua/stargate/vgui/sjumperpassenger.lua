--[[
	Puddle Jumper Passenger for GarrysMod10
	Copyright (C) 2007-2009 Avon,Catdeamon,LightDemon

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
]]--

local PANEL = {};

--################# Inits @aVoN
function PANEL:Init()
	local w,h = 64,64;
	self.Avatar = vgui.Create("AvatarImage",self);
	self.Avatar:SetVisible(false);
	self.Avatar:SetSize(32,32); -- Other sizes makes it look pixellish
	self.Avatar:SetPos((w - 32)/2,(w - 32)/2);
	self.Name = vgui.Create("DLabel",self);
	self.Name:SetTextColor(Color(255,255,255,255));
	self.Name:SetPos(3,w - 17);
	self.Name:SetSize(w-6,12);
	self.Name:SetText("");
	self:SetSize(w,h);
end

--################# Set a player @aVoN
function PANEL:SetPlayer(p)
	if(self.Player ~= p) then
		self.Player = p;
		if(IsValid(p)) then
			self.Avatar:SetVisible(true);
			self.Name:SetText(p:GetName());
		else
			self.Avatar:SetVisible(false);
			self.Name:SetText("");
		end
		self.Avatar:SetPlayer(p);
	end
end

--################# Paint @aVoN
local border = surface.GetTextureID("VGUI/spawnmenu/hover");
local COLOR = Color(255,255,255,20);
function PANEL:Paint()
	local w,h = self:GetSize();
	--draw.RoundedBox(3,0,0,w,h,COLOR);
	surface.SetTexture(border);
	surface.SetDrawColor(COLOR);
	surface.DrawTexturedRect(-2,0-2,w+4,w+4);
	return true;
end

vgui.Register("SJumperPassenger",PANEL,"Panel");