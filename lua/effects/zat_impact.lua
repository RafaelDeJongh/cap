/*
	Zat-Impact for GarrysMod10
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
if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end

-- The old Material can't use alpha-shading anymore. Seems to be a problem with the engine update and UnlitTwoTexture shaders
--EFFECT.Material1 = Material("models/props_combine/portalball001_sheet");
-- This is a reduced shader - Does not look like exactly like the one before, but much much better than with no alpha shading
EFFECT.Material1 = StarGate.MaterialFromVMT(
	"ZatFineOverlay",
	[["UnLitGeneric"
	{
		"$basetexture" "models/props_combine/portalball001b_sheet"
	 	"$model" 1
		"$nocull" "1"
		"$additive" "1"

		"Proxies"
		{
			"TextureScroll"
			{
				"texturescrollvar" "$basetexturetransform"
				"texturescrollrate" -.2
				"texturescrollangle" 60
			}
		}
	}]]
);
EFFECT.Material2 = StarGate.MaterialCopy("ZatHit","models/alyx/emptool_glow");

--################### Init @aVoN
function EFFECT:Init(data)
	self.LifeTime = 1.5;
	local pos = data:GetOrigin();
	local p = LocalPlayer();
	if(((p.LastZatHitPos or Vector(0,0,0))-pos):Length() > 200 or (p.LastZatSound or 0)+self.LifeTime < CurTime()) then
		sound.Play(Sound("zat/zat_hit.mp3"),pos,90,math.random(90,110));
		p.LastZatHitPos = pos;
		p.LastZatSound = CurTime();
	end
	-- ######################## Dynamic light
	if(StarGate.VisualsWeapons("cl_zat_dynlights")) then
		local dynlight = DynamicLight(0);
		dynlight.Pos = data:GetOrigin();
		dynlight.Size = 400;
		dynlight.Decay = 300;
		dynlight.R = 40;
		dynlight.G = 142;
		dynlight.B = 255;
		dynlight.DieTime = CurTime()+self.LifeTime+3;
	end
	if(not StarGate.VisualsWeapons("cl_zat_hiteffect")) then return end;
	local e = data:GetEntity();
	-- The way I'm using the effect does not work on any ragdoll-related stuff like NPCs,Players or Ragdolls. And NO, I don't know a solution
	if(not e:IsValid() or e:IsPlayer() or e:IsNPC() or e:GetClass() == "prop_ragdoll") then return end;
	local mdl = e:GetModel();
	if(mdl == "" or mdl == "models/error.mdl") then return end;
	self.Entity:SetModel(mdl);
	self.Entity:SetAngles(e:GetAngles());
	self.Entity:SetPos(e:GetPos());
	self.Entity:SetParent(e);
	self.Color = e:GetColor();
	self.Scale = math.Clamp(40/data:GetScale(),0.03,1);
	self.Color.a = 255*self.Scale;
	self.Target = e;
	self.Entity:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.Entity:SetColor(self.Color);
	self.Created = CurTime();
	self.draw = true;
end

--################### Render the tracer @aVoN
function EFFECT:Render()
	if(not (self.Target and self.Target:IsValid())) then self.draw = false end;
	if(not self.draw or self.Created+self.LifeTime < CurTime()) then return end;
	local multiply = self.Scale*(self.Created+self.LifeTime-CurTime())/self.LifeTime;
	self.Color.a = 255*multiply;
	self.Entity:SetColor(self.Color);
	-- Draw first mat overlay
	render.MaterialOverride(self.Material1);
	self.Entity:DrawModel();
	--if(not self.Target.Dissolve) then -- Reactivated. This has been added because the disintegration effect made it flickering for no reason. Solution was to remove alpha fading in the disint. effect
		-- Second materail overlay
		render.MaterialOverride(self.Material2);
		self.Entity:DrawModel();
	--end
	-- Undo overlay
	render.MaterialOverride(nil);
end

--################### Think @aVoN
function EFFECT:Think()
	return (self.draw and self.Created+self.LifeTime > CurTime());
end
