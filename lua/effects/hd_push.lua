/*
	Hand Device Refract Effect for GarrysMod10
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
EFFECT.Material = Material("refract_ring");

--################### Init  @jdm
function EFFECT:Init(data)
	self.Owner = data:GetEntity();
	self.Normal = self.Owner:GetAimVector();
	self.Position = self.Owner:GetShootPos();
	self.Entity:SetPos(self.Position+self.Normal*50); -- Make it in the view of the Player
	self.Entity:SetParent(self.Owner); -- Parent to owner
	self.Created = CurTime();
	self.LifeTime = 0.7;
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
	local multiply = (CurTime() - self.Created)/self.LifeTime
	if(multiply > 0) then
		local pos = self.Position+150*multiply*self.Normal; -- Make it move forward
		local size = math.Clamp(multiply*300,10,200);
		local refractamount = self.Material:GetFloat("$refractamount"); -- We always need to reset changed Material properties
		self.Material:SetFloat("$refractamount",math.sin(multiply*math.pi)*0.2);
		self.Material:SetFloat("$nocull",1); -- Drawing from both sides (maybe helps, I dont know) @aVoN
		render.SetMaterial(self.Material);
		render.UpdateRefractTexture();
		render.DrawQuadEasy(pos+self.Normal,self.Normal,size,size);
		render.DrawQuadEasy(pos-self.Normal,-1*self.Normal,size,size); -- Draw it from the back @aVoN
		-- Reset to be compatible with other scripts using this texture
		self.Material:SetFloat("$refractamount",refractamount);
	end
end
