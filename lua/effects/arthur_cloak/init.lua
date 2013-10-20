/*
	Sodan Cloak Refract Effect for GarrysMod10
	Copyright (C) 2007 jdm

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
EFFECT.Material = Material("effects/strider_bulge_dudv");

--################### Init  @jdm
function EFFECT:Init(data)
	local e = data:GetEntity();
	--if(IsValid(e)) then self.Entity:SetParent(e) end; -- Instead of "parenting" we make it move with the player (hopefully fixes multiplayer bug where the cloaking player cant see the effect on himself)
	self.Parent = e;
	self.Created = CurTime();
	self.LifeTime = 1.7;
	-- Makes it always rendered @aVoN
	local offset = 500*Vector(1,1,1);
	self.Entity:SetRenderBounds(-1*offset,offset);
end

--################### Think @jdm
function EFFECT:Think( )
	return (CurTime() - self.Created < self.LifeTime);
end

--################### Draw @jdm
function EFFECT:Render()
	if(not IsValid(self.Parent)) then return end;
	local multiply = (CurTime() - self.Created)/self.LifeTime
	if(multiply > 0) then
		if (self.Parent:IsNPC()) then
			self.Entity:SetPos(self.Parent:GetPos());
		else
			self.Entity:SetPos(self.Parent:GetShootPos()+self.Parent:GetAimVector()*10);
		end
		local size = 280 + 200*(1-multiply);
		self.Material:SetFloat("$refractamount", math.sin(multiply*math.pi)*0.16);
		render.SetMaterial(self.Material);
		render.UpdateRefractTexture();
		render.DrawSprite(self.Entity:GetPos(),size*0.5,size);
	end
end
