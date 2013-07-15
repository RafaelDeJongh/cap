/*
	Enter Gate Effect for GarrysMod10
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
EFFECT.Material = Material("refract_ring");

--################# Init @aVoN
function EFFECT:Init(data)
	if (not StarGate.VisualsMisc("cl_stargate_kenter")) then self.Entity:Remove(); return end
	self.Size = 10;
	self.StartSize = math.Clamp(data:GetScale()-self.Size,0,1337)
	self.Refract = 0;
	local e = data:GetEntity();
	if(not e:IsValid()) then return end;
	self.Parent = e;
	self.Offset = e:WorldToLocal(self.Entity:GetPos());
	self.Draw = true;
	self.Normal = e:GetForward();
	-- Render bounds
	local offset = self.Size*Vector(1,1,1)*50;
	self.Entity:SetRenderBounds(-1*offset,offset);
end

--################# Think @aVoN
function EFFECT:Think()
	-- Actually the calculations how Catdaemon does it.
	self.Refract = self.Refract+FrameTime();
	self.Size = 20*self.Refract^(0.2) + self.StartSize;
	return (self.Draw and self.Refract < 1);
end

--################# Render @aVoN
function EFFECT:Render()
	if(self.Draw and self.Refract < 1 and IsValid(self.Parent)) then
		local pos = self.Parent:LocalToWorld(self.Offset);
		self.Material:SetFloat("$refractamount",math.sin(self.Refract*math.pi)*0.1);
		render.SetMaterial(self.Material);
		render.UpdateRefractTexture();
		render.DrawQuadEasy(pos+self.Normal*3,self.Normal,self.Size,self.Size); -- Draw from the front
		render.DrawQuadEasy(pos-self.Normal*3,-1*self.Normal,self.Size,self.Size); -- And from the back
	end
end
