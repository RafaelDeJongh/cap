/*
	DHD SENT for GarrysMod10
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

include("shared.lua")
ENT.ChevronColor = Color(100,100,255);

ENT.Category = Language.GetMessage("stargate_category");
ENT.PrintName = Language.GetMessage("dhd_city");

--################# Draw @aVoN
function ENT:Draw()
	self.Entity:DrawModel();
	if (not StarGate.VisualsMisc("cl_dhd_letters",true)) then return end
	if self.Entity:GetNetworkedInt("DHD_LETTERS",0)<=0 then return end
	local a = self.Entity:GetAngles();
	-- ################# Get the chevrons
	local address = self.Entity:GetNetworkedString("ADDRESS"):TrimExplode(",");

	if (self.Entity:GetNetworkedBool("SG_GROUP_SYSTEM")) then
		self.ChevronPositions2 = self.ChevronPositionsGroup2;
	else
		self.ChevronPositions2 = self.ChevronPositionsGalaxy2;
	end

	-- ################# Draw keyboard - Idea of how to use the cam3D2D stuff comes from Night-Eagles Computer SENT. Thank god, you coded it ;)
	local btn;
	if((LocalPlayer():GetShootPos() - self.Entity:LocalToWorld(self.ChevronPositions2.DIAL)):Length() <= 90) then
		btn = self:GetCurrentButton(LocalPlayer());
	end
	local count = #address;
	-- Draw near buttons
	local button_angle = 30; -- Maximum distant-angle of a button to get drawn - High value = massive (clientside)lags, because the SENT will calculate vector/matrix multiplication - and this is very CPU heavy
	local btns = {};
	if(not self.Entity:GetNWBool("Busy",false)) then
		if(btn and btn ~= "DIAL" or count > 6) then
			btns = self:GetCurrentButton(LocalPlayer(),button_angle);
		end
	end
	-- ################# Lower the alpha for buttons when 6 are dialled to make the user clear to press chevron 7 now
	local alpha = 180;
	if(count >= 6) then
		alpha = 60;
		if(not table.HasValue(address,"#")) then
			table.insert(btns,{button="#",angle=0});
		end
	end
	for _,v in pairs(address) do
		if(v ~= "" and v ~= "DIAL" and not v:find(",")) then
			table.insert(btns,{button=tonumber(v) or v,angle=0});
		end
	end
	-- ################# Draw buttons
	for _,v in pairs(btns) do
		if (self.ChevronPositions2[v.button]) then
			local a = self.Entity:GetAngles();
			local p = self.Entity:LocalToWorld(self.ChevronPositions2[v.button]+Vector(0,0,0.1)); -- Position of chevron
			local d = self.Entity:LocalToWorld(self.ChevronPositions2[v.button]-self.ChevronPositions2.DIAL)-self.Entity:GetPos(); -- Direction from the DHD's center to the chevron
			a:RotateAroundAxis(self.Entity:GetUp(),90);	 -- Yaw Rotate, or the buttons face to the wrong direction
			local color = Color(255,255,255,180);

			if(v.button ~= "DIAL" and v.button ~= "IRIS") then
			if(count < 9 or table.HasValue(address,tostring(v.button))) then
				-- Fading color for the buttons pendent from their distance
				local color = Color(255,255,255,alpha*(1-v.angle/button_angle));
				-- When 6 buttons are dialled, highligh chevron 7 white. Furthermore the alpha (watch above) is lowered from 255 to 100 for all other buttons, so even noobs will find out, to press chevron 7
				if((count >= 8 and v.button == "#" and not table.HasValue(address,"#")) or count > 8 or table.HasValue(address,tostring(v.button))) then
					color = Color(255,255,255,180);
				end
				-- ################# Highlight current button aimed at orange or gray when already dialled
				if(v.button == btn and count < 9) then
					local sel = false;
					if(count < 8 or v.button == "#" or v.button == "@") then
						if(table.HasValue(address,tostring(btn))) then
							sel = true;
						end
						-- ################# Button already dialled - Make it white
						if(sel) then
							color = Color(255,255,255,180);
						else
							local brightness = 54;
							color = (self.Color.chevron.." 180"):TrimExplode(" ");
							color[1] = color[1]+brightness;
							color[2] = color[2]+brightness;
							color[3] = color[3]+brightness;
							color = Color(color[1],color[2],color[3],color[4]);
						end
					end
				end
				-- ################# Draw the buttons
				d:Normalize()
				cam.Start3D2D(p+d*0.5,a,.05);
					draw.SimpleText(v.button,"DHD_font",0,0,color,1,1);
				cam.End3D2D();
			end
			elseif (v.button == "IRIS") then
				d:Normalize()
				cam.Start3D2D(p+d*0.5,a,.05);
					draw.SimpleText(v.button,"DHD_font",0,0,color,1,1);
				cam.End3D2D();
			end
		end
	end

end