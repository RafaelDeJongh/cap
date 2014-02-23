/*
	Stargate Shield for GarrysMod10
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
if (StarGate==nil or StarGate.MaterialCopy==nil) then return end
EFFECT.Material1 = StarGate.MaterialCopy("ShieldRefract","refract_ring");
EFFECT.Material2 = StarGate.MaterialCopy("ShieldGlow","models/roller/rollermine_glow");

--################# Init @aVoN
function EFFECT:Init(data)
	if(self.Material1:GetName() == "___error") then self:Remove(); return end;
	if(self.Material2:GetName() == "___error") then self:Remove(); return end;
	self.StartSize = math.random(20,40);
	self.Size = self.StartSize;
	self.AdditionalSize = math.Clamp(data:GetScale()*6,0,100);
	self.Alpha = math.Clamp(self.AdditionalSize/40,0.7,1);
	self.Refract = 0;
	local e = data:GetEntity();
	if(not e:IsValid()) then return end;
	local radius = e:GetNetworkedInt("size",false); -- Needed from the shield, to make this hit effect exactly there, where the "rounded" shield ended, even when the shield actually is cubic
	--self.Entity:SetParent(e); -- Parent to the shield so it moves along with it
	-- This above was the old method. Sadly, it looks ugly when the hit effect does the same barrel roll like your ship
	local pos = self.Entity:GetPos();
	self.Offset = pos-e:GetPos();
	if(radius) then
		-- Update the position with correct radius
		self.Offset = self.Offset:GetNormalized()*radius;
	end
	self.DrawRadius = StarGate.VisualsMisc("cl_shield_hitradius");
	self.DrawEffect = StarGate.VisualsMisc("cl_shield_hiteffect");
	if(StarGate.VisualsMisc("cl_shield_dynlights")) then
		local color = e:GetShieldColor();
		local dynlight = DynamicLight(0);
		dynlight.Pos = pos;
		dynlight.Size = 300;
		dynlight.Decay = 300;
		dynlight.R = color.r*255;
		dynlight.G = color.g*255;
		dynlight.B = color.b*255;
		dynlight.DieTime = CurTime()+1;
	end
	if(not (self.DrawRadius or self.DrawEffect)) then return end;
	self.Draw = true;
	self.Parent = e;
	local offset = self.Size*Vector(1,1,1)*10;
	self.Entity:SetRenderBounds(-1*offset,offset);
end

--################# Think @aVoN
function EFFECT:Think()
	-- Actually the calculations how Catdaemon does it.
	self.Refract = self.Refract+2*FrameTime();
	if(self.Refract > 1) then
		self.Alpha = self.Alpha-FrameTime();
	end
	self.Size = 2*self.StartSize*self.Refract^(0.2)+self.AdditionalSize;
	return (self.Draw and self.Alpha > 0);
end

--################# Render @aVoN
function EFFECT:Render()
	-- Catdaemon, when you read this: You are free to use this method on your shields too. This really looks better
	-- The "refract" effect like on catdaemons cool shield
	if(not (self.Parent and self.Parent:IsValid())) then self.Draw = nil end;
	if(not self.Draw) then return end;
	self.Entity:SetPos(self.Offset+self.Parent:GetPos()); -- Instead of parenting (look in Init why I'm doing it)
	local normal = (self.Entity:GetPos()-self.Parent:GetPos()):GetNormalized();
	if(self.Refract < 1) then
		if(self.DrawRadius) then
			self.Material1:SetFloat("$alpha",self.Alpha);
			self.Material1:SetFloat("$refractamount",math.sin(self.Refract*math.pi)*0.1);
			render.SetMaterial(self.Material1);
			render.UpdateRefractTexture();
			render.DrawQuadEasy(self.Entity:GetPos(),normal,self.Size,self.Size); -- Draw from the front
			render.DrawQuadEasy(self.Entity:GetPos(),-1*normal,self.Size,self.Size); -- And from the back
		end
	end
	-- The glow effect
	if(self.DrawEffect and IsValid(self.Parent)) then
		local color = self.Parent:GetShieldColor();
		self.Material2:SetVector("$color",Vector(color.r,color.g,color.b));
		self.Material2:SetFloat("$alpha",math.Clamp(self.Alpha,0,1));
		render.SetMaterial(self.Material2);
		local hitsize = self.Size*2;
		render.DrawQuadEasy(self.Entity:GetPos(),normal,hitsize,hitsize); -- Draw from the front
		render.DrawQuadEasy(self.Entity:GetPos(),-1*normal,hitsize,hitsize); -- And from the back
	end
end
