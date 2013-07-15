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
EFFECT.Material1 = StarGate.MaterialCopy("ShieldRefract","refract_ring");

--################# Init @aVoN
function EFFECT:Init(data)
	self.StartSize = math.random(20,40);
	self.Size = self.StartSize;
	self.AdditionalSize = math.Clamp(data:GetScale()*6,0,100);
	self.Alpha = math.Clamp(self.AdditionalSize/40,0.7,1);
	self.Refract = 0;
	self.Normal = data:GetNormal();
	local e = data:GetEntity();
	if not IsValid(e) then return end;
	local col = e:GetNetworkedVector("Col", Vector(170,185,255));
	self.Col = Color(col.x,col.y,col.z);

	local pos = data:GetOrigin();
	self.Offset = pos-e:GetPos();
	self.DrawRadius = StarGate.VisualsMisc("cl_shield_hitradius");
	self.DrawEffect = StarGate.VisualsMisc("cl_shield_hiteffect");
	if(StarGate.VisualsMisc("cl_shield_dynlights")) then
		local dynlight = DynamicLight(0);
		dynlight.Pos = pos;
		dynlight.Size = 300;
		dynlight.Decay = 300;
		dynlight.R = self.Col.r;
		dynlight.G = self.Col.g;
		dynlight.B = self.Col.b;
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
	if(self.Refract < 1) then
		if(self.DrawRadius) then
			self.Material1:SetFloat("$alpha",self.Alpha);
			self.Material1:SetFloat("$refractamount",math.sin(self.Refract*math.pi)*0.1);
			render.SetMaterial(self.Material1);
			render.UpdateRefractTexture();
			render.DrawQuadEasy(self.Entity:GetPos()+self.Normal*2,self.Normal,self.Size,self.Size); -- Draw from the front, add normal to be visible from both sides
			render.DrawQuadEasy(self.Entity:GetPos()-self.Normal*2,-1*self.Normal,self.Size,self.Size); -- And from the back
		end
	end
end
