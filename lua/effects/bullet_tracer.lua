--[[
	Trace effect
	Copyright (C) 2010 Madman07

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

EFFECT.BulletO = Material("effects/bullet_orange");
EFFECT.BulletB = Material("effects/bullet_blue");

function EFFECT:Init( data )
	self.StartPos 	= data:GetStart();
	self.EndPos 	= data:GetOrigin();
	self.Smoke 		= math.ceil(data:GetMagnitude());
	self.Type 		= math.ceil(data:GetRadius());
	self.Dir		= (self.EndPos-self.StartPos):GetNormal();
	self.LifeTime 	= CurTime() + 4;
	self.Killme 	= false;

	self.MaxLenght = self.StartPos:Distance(self.EndPos);

	if self.Type == 1 then
		self.Mat = self.BulletO;
		self.Col = Angle(235,215,128);
	else
		self.Mat = self.BulletB;
		self.Col = Angle(100,95,220);
	end

	self.Size = 20;
	self.Beam = 80;
	self.Lenght = 0;
	self.Speed = 500;

	self:SetRenderBounds(-10000000*Vector(1,1,1), 10000000*Vector(1,1,1));
end

function EFFECT:Think( )

	if (CurTime() > self.LifeTime) then return false end
	if (self.Killme == true or self.Lenght > self.MaxLenght) then
		if (self.Smoke == 1) then
			local effectdata = EffectData()
				effectdata:SetStart( self.EndPos)
				effectdata:SetOrigin( self.EndPos)
				effectdata:SetMagnitude(self.Smoke);
				effectdata:SetScale(1);
				effectdata:SetAngles(self.Col);
			util.Effect( "Energy_hit", effectdata )
		end
		return false
	end
	return true
end

function EFFECT:Render( )

	local newstart = self.StartPos + self.Dir*(self.Lenght-2*self.Beam);
	local newend = self.StartPos + self.Dir*(self.Lenght+2*self.Beam);
	self.Lenght = self.Lenght + self.Speed;

	self.Entity:SetRenderBoundsWS(newstart, newend);

	render.SetMaterial(self.Mat);
	render.DrawBeam(
		newstart,
		newend,
		self.Size,
		1,
		0,
		Color(255, 255, 255)
	);

	-- local dlight = DynamicLight(0)
	-- dlight.Pos = Pos
	-- dlight.r = Col.r
	-- dlight.g = Col.g
	-- dlight.b = .Colb
	-- dlight.Brightness = 100
	-- dlight.Size = 50
	-- dlight.Decay = dlight.Size * 5
	-- dlight.DieTime = CurTime() + 0.2
end

