--[[
	Puddle Jumper Passenger Indicator for GarrysMod10
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

-- This VGUI tells you, who is in the jumper
-- To LightDemon: A VGUI (I know, you aren't that versatile with it) fits much more than drawing the stuff in a DrawHUD hook. It is better customable!
local PANEL = {};
PANEL.Fonts = {};

--################# Inits @aVoN
function PANEL:Init()
	self:SetSize(5*64 + 3*4 + 12,64); -- 5 64x64 PassengerIcons. Space between them = 4. Space between PilotIcon and Passengers: 12
	self.Pilot = vgui.Create("SJumperPassenger",self);
	local x = 64 + 12;
	self.Passengers = {};
	for i=1,4 do
		self.Passengers[i] = vgui.Create("SJumperPassenger",self);
		self.Passengers[i]:SetPos(x,0);
		x = x + 64 + 4;
	end
	self:SetVisible(false);
end

--################# Paint @aVoN
local num = 0;
function PANEL:Think()
	if(not self.Active) then return end;
	local p = LocalPlayer();
	local alpha = 255;
	local Jumper = p:GetNetworkedEntity("Jumper",NULL);
	if(not IsValid(Jumper)) then alpha = 0 end; -- Should never happen!
	num = math.Approach(num,alpha,10);
	self:SetAlpha(num);
	if(num == 0) then self:Deactivate() end;
	if(alpha == 0) then return end; -- Do not update. Just fade out
	local HasDriver = false;
	local i = 1;
	for _,v in pairs(player.GetAll()) do
		if(v:GetNWEntity("Jumper") == Jumper) then
			if(v:GetNWBool("isFlyingJumper")) then
				HasDriver = true;
				self.Pilot:SetPlayer(v);
			else
				self.Passengers[i]:SetPlayer(v);
				i = i + 1;
			end
		end
	end
	-- Clear those, which do not have any player
	for k=i,4 do
		self.Passengers[k]:SetPlayer(nil);
	end
	if(not HasDriver) then
		self.Pilot:SetPlayer(nil);
	end
end

--################# Activate Panel @aVoN
function PANEL:Activate()
	if(not self.Active) then
		self:SetVisible(true); -- Calling SetVisible all the time causes heavy CPU Load
		self.Active = true;
	end
end

--################# Deactivate Panel @aVoN
function PANEL:Deactivate()
	if(self.Active) then
		self:SetVisible(false); -- Calling SetVisible all the time causes heavy CPU Load
		self.Active = nil;
	end
end

vgui.Register("SJumperPassengerIndicator",PANEL,"Panel");