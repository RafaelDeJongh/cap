/*
	Wraith Harveser Beam for GarrysMod10
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

EFFECT.Material1 = StarGate.MaterialCopy("WraithBeam1","models/alyx/emptool_glow");
EFFECT.Material2 = StarGate.MaterialCopy("WraithBeam2","models/shadertest/predator");

--################# Init @aVoN
function EFFECT:Init(data)
	self.LifeTime = 0.5;
	self.Created = CurTime();
	local e = data:GetEntity();
	if(not (e and e:IsValid())) then return end;
	self.SuckIn = util.tobool(data:GetScale());
	e.Created = CurTime();
 	self.StartPos = data:GetStart();
 	self.EndPos = data:GetOrigin();
	self.Entity:SetModel(e:GetModel());
	self.Entity:SetPos(self.StartPos);
	self.Entity:SetAngles(e:GetAngles());
	if(e.GotFirstSpawnEffect) then
		self.OnlyDrawModel = true;
		e.GotFirstSpawnEffect = nil;
		local fx = EffectData();
		fx:SetStart(self.StartPos);
		fx:SetOrigin(self.EndPos);
		fx:SetScale(data:GetScale());
		fx:SetEntity(e);
		util.Effect("wraithbeam",fx,true,true);
	else
		e.GotFirstSpawnEffect = true;
	end
	self.Parent = e;
	self.Draw = true;
	local a,b = self.Entity:GetRenderBounds();
	local offset = Vector(0,0,math.abs(self.StartPos.z - self.EndPos.z)/2);
	self.Entity:SetRenderBounds(a - offset,b + offset);
end

--################# Think @aVoN
function EFFECT:Think()
	if(self.Draw and StarGate.VisualsWeapons("cl_harvester_dynlights")) then
		local dlight = DynamicLight(self:EntIndex());
		if(dlight) then
			dlight.Pos = self.EndPos;
			dlight.r = 255;
			dlight.g = 255;
			dlight.b = 255;
			dlight.Brightness = 5;
			dlight.Decay = 500;
			dlight.Size = 1000;
			dlight.DieTime = CurTime() + 2;
		end
	end
	return (self.Draw and self.Created + self.LifeTime > CurTime());
end

--################# Render @aVoN
function EFFECT:Render()
	if(not (self.Parent and self.Parent:IsValid())) then self.Draw = nil end;
	if(not self.Draw) then return end;
	local multiply = (CurTime() - self.Created)/self.LifeTime;
	local scale = multiply;
	if(self.SuckIn) then scale = 1-scale end;
	local mat = Matrix()
	mat:Scale(Vector(scale,scale,4 - 3*multiply))
	self.Entity:EnableMatrix( "RenderMultiply", mat )
	self.Entity:SetPos(self.StartPos+(self.EndPos-self.StartPos)*multiply);
	if(self.OnlyDrawModel) then
		self.Entity:SetColor(Color(255,255,255,math.Clamp(multiply^3*255,1,255)));
		self.Entity:DrawModel();
	else
		local normal = self.Entity:GetPos() - EyePos();
		-- Avoids this effect from not beeing drawn sometimes
		cam.Start3D(EyePos() + normal*0.01,EyeAngles());
			self.Entity:SetColor(Color(255,255,255,math.Clamp((1-multiply^2)*255,1,255)));
			render.MaterialOverride(self.Material1);
			self.Entity:DrawModel();
			render.MaterialOverride(nil);
			if(render.GetDXLevel() >= 80) then
				render.UpdateRefractTexture()
				self.Material2:SetFloat("$refractamount",1-multiply);
				render.MaterialOverride(self.Material2)
				self.Entity:DrawModel();
				render.MaterialOverride(nil);
			end
		cam.End3D();
		-- Catdaemon's old effect
		render.SetMaterial(self.Material1);
		render.DrawBeam(self.StartPos,self.EndPos,10,1,1,Color(255,255,255));
		for i=1,5 do
			render.DrawBeam(self.StartPos+VectorRand()*20,self.StartPos+(self.EndPos-self.StartPos+VectorRand()*20)*multiply,5,1,1,Color(255,255,200));
		end
	end
end
