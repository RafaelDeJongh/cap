/*
	Teleport Effect for GarrysMod10
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

EFFECT.Material1 = CreateMaterial("MuzzleGlow","UnlitGeneric",
	{
		["$basetexture"] = "models/alyx/emptool_glow",
		["$nodecal"] = 1,
		["$model"] = 1,
		["$additive"] = 1,
		["$nocull"] = 1,
		Proxies = {
			TextureScroll = {
				texturescrollvar = "$basetexturetransform",
				texturescrollrate = 33.3,
				texturescrollangle = 60,
			}
		},
	}
);
EFFECT.Material2 = Material("models/shadertest/predator");


--################# Init @aVoN
function EFFECT:Init(data)
	local e = data:GetEntity();
	if(not IsValid(e)) then return end;
	local mdl = e:GetModel();
	if(mdl == "" or mdl == "models/error.mdl") then return end;
	if(mdl == "models/player/urban.mbl") then mdl = "models/player/urban.mdl" end; -- Fixes a typo
	local scale = data:GetScale();
	local pos = data:GetOrigin();
	self.LifeTime = 0.8;
	self.Created = CurTime();
	self.SuckIn = util.tobool(scale);
 	self.StartPos = pos;
 	self.EndPos = self.StartPos + Vector(0,0,150);
	-- Switch from "suck in" to "spit out"
	if(not self.SuckIn) then
		local pos = self.EndPos;
		self.EndPos = self.StartPos;
		self.StartPos = pos;
	end
	self.Entity:SetModel(mdl);
	local color = e:GetColor();
	local r,g,b,a = color.r,color.g,color.b,color.a;
	self.Color = Color(r,g,b,a);
	self.Entity:SetColor(Color(r,g,b,255));
	self.Entity:SetPos(self.StartPos);
	self.Entity:SetParent(e);
	self.Entity:SetAngles(e:GetAngles());
	if(math.Round(data:GetRadius()) == 0) then
	local fx = EffectData();
		self.OnlyDrawModel = true;
		fx:SetOrigin(pos);
		fx:SetScale(scale);
		fx:SetRadius(1);
		fx:SetEntity(e);
		util.Effect("teleport_effect",fx,true,true);
	end
	self.Parent = e;
	self.Draw = true;
	--Renderbounds
	local a,b = self.Entity:GetRenderBounds();
	local offset = Vector(0,0,math.abs(self.StartPos.z - self.EndPos.z)/2);
	self.Entity:SetRenderBounds(a - offset,b + offset);
	-- Bloom off - FIXME: Reactivate it later if necessary
	RunConsoleCommand("pp_bloom",0);
end

--################# Think @aVoN
function EFFECT:Think()
	if(self.Draw) then
		local dlight = DynamicLight(self:EntIndex());
		if(dlight) then
			dlight.Pos = self.EndPos;
			dlight.r = 255;
			dlight.g = 255;
			dlight.b = 255;
			dlight.Brightness = 5;
			dlight.Decay = 200;
			dlight.Size = 200;
			dlight.DieTime = CurTime() + 1;
		end
	end
	local valid = (self.Draw and self.Created + self.LifeTime > CurTime());
	if(not valid and IsValid(self.Parent)) then
		self.Parent:SetColor(Color(self.Color.r,self.Color.g,self.Color.b,255));
	end
	return valid;
end

--################# Render @aVoN
-- Declared here to avoid GarbageCollection issues
local beam_color1 = Color(255,255,255);
local beam_color2 = Color(255,255,200);

function EFFECT:Render()
	if(not IsValid(self.Parent)) then self.Draw = nil end;
	if(not self.Draw) then return end;
	local time = CurTime();
	local multiply = (time - self.Created)/self.LifeTime;
	local scale = multiply;
	self.Parent:SetColor(Color(self.Color.r,self.Color.g,self.Color.b,0)); -- Player has to be invisible - Bug in GMOD since #40
	if(self.SuckIn) then scale = 1-scale end;
	-- Move the effect with this player - It will look better!
	if(self.SuckIn) then
		self.StartPos = self.Parent:GetPos();
		self.EndPos = self.Parent:GetPos(); self.EndPos.z = self.EndPos.z + 150; -- Offset
		if(LocalPlayer() == self.Parent and self.OnlyDrawModel and (time - self.Created) > self.LifeTime*0.3) then
			local new_mul = (time - self.Created - self.LifeTime*0.3)/(0.7*self.LifeTime); -- Updated multiply to the delayed start (so it starts at 0 again)
			local intense = math.sin(new_mul*math.pi);
			DrawBloom(0.3*intense,5.48*intense,0,4.57*intense,intense,0,1,1,1);
		end
	end
	local mat = Matrix()
	mat:Scale(Vector(scale,scale,4 - 3*multiply))
	self.Entity:EnableMatrix( "RenderMultiply", mat )
	self.Entity:SetPos(self.StartPos+(self.EndPos-self.StartPos)*multiply);
	if(self.OnlyDrawModel) then
		self.Entity:SetColor(Color(255,255,255,math.Clamp(scale^3*255,1,255)));
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
		render.DrawBeam(self.StartPos,self.EndPos,10,1,1,beam_color1);
		for i=1,5 do
			render.DrawBeam(self.StartPos+VectorRand()*20,self.StartPos+(self.EndPos-self.StartPos+VectorRand()*20)*multiply,5,1,1,beam_color2);
		end
	end
end
