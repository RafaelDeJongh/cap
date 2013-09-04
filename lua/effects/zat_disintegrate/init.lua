/*
	Zat-Desintegrate Effect for GarrysMod10
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
EFFECT.Material = StarGate.MaterialCopy("ZatDisintegrate","models/shadertest/predator");

--################### Init @aVoN
function EFFECT:Init(data)
	local e = data:GetEntity();
	if(not e:IsValid()) then return end;
	local mdl = e:GetModel();
	if(mdl == "" or mdl == "models/error.mdl") then return end;
	if(e:GetClass() == "prop_ragdoll") then self.NoShader = true end;
	self.Entity:SetModel(mdl);
	self.Entity:SetAngles(e:GetAngles());
	self.Entity:SetPos(e:GetPos());
	self.Entity:SetParent(e);
	self.Color = e:GetColor();
	self.Color.a = 255;
	self.Target = e;
	self.Entity:SetRenderMode( RENDERMODE_TRANSALPHA )
	--e:SetKeyValue("rendermode",2); -- Seems to throw errrors when a SENT
	self.Entity:SetColor(self.Color);
	self.Created = CurTime();
	self.LifeTime = data:GetScale();
	self.DissolveEffect = StarGate.VisualsWeapons("cl_zat_dissolveeffect");
	e.Dissolve = true; -- Tell the hit effect to stop drawing one material overlay
	self.draw = true;
end

--################### Think @aVoN
function EFFECT:Think()
	return (self.draw and self.Created+self.LifeTime > CurTime());
end

--################### Render the model and make it invisible/fading @aVoN
function EFFECT:Render()
	if(not self.draw or self.Created+self.LifeTime < CurTime()) then return end;
	local multiply = (self.Created+self.LifeTime-CurTime())/self.LifeTime;
	self.Color.a = 255*multiply;
	if(self.NoShader) then
		if(self.Target:IsValid()) then
			self.Target:SetColor(self.Color);
		end
	else
		-- Needs to be deactivated or it will make the shot flickering ugly! Look for more in zat_hit
		--self.Entity:SetColor(self.Color);
		--self.Entity:DrawModel();
		if(self.DissolveEffect) then
			self.Material:SetFloat("$refractamount",multiply);
			render.UpdateScreenEffectTexture();
			render.MaterialOverride(self.Material);
			self.Entity:DrawModel();
			render.MaterialOverride(nil);
		end
	end
end
