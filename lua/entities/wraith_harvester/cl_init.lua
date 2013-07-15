/*
	Wraith Harveserfor GarrysMod10
	Copyright (C) 2007  Catdaemon

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
include("shared.lua");
ENT.RenderGroup = RENDERGROUP_BOTH;
ENT.Beam = StarGate.MaterialCopy("HarvesterBeam","models/alyx/emptool_glow");
ENT.LightMaterial = StarGate.MaterialFromVMT(
	"HarvesterSprite",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/light_glow01"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
		"$ignorez"	1
	}]]
);
ENT.PixVis = util.GetPixelVisibleHandle(); -- Visibility handler

--################# Think @Catdaemon
function ENT:Think()
	if(self.Entity:GetNetworkedBool("on",false)) then
		if(not StarGate.VisualsMisc("cl_harvester_dynlights")) then return end;
		if((self.NextLight or 0) < CurTime()) then -- Fixes a crashing bug, which spawns more and more lights all over the time until the clientside "overflowed blubb" message appears
			self.NextLight = CurTime()+0.001;
		 	local dlight = DynamicLight(self:EntIndex());
		 	if(dlight) then
				--local trace=util.QuickTrace(self.Entity:GetPos(),self:GetBeamNormal(),self.Entity)
				local trace = StarGate.Trace:New(self.Entity:GetPos(),self:GetBeamNormal(),self.Entity)
		 		dlight.Pos = trace.HitPos
		 		dlight.r = 255
		 		dlight.g = 255
		 		dlight.b = 255
		 		dlight.Brightness = 5
		 		dlight.Decay = 500
		 		dlight.Size = 500
		 		dlight.DieTime = CurTime()+1;
		 	end
		end
	end
end

--################# Draw @Catdaemon
function ENT:Draw()
	self.BaseClass.Draw(self); -- For the WorldTips
	self.Entity:SetRenderBoundsWS(self.Entity:GetPos(),self.Entity:GetPos()+self:GetBeamNormal());
	if(self.Entity:GetNWBool("on",false)) then
		local pos = self.Entity:GetPos();
		--local trace = util.QuickTrace(pos,self:GetBeamNormal(),self.Entity)
		local trace = StarGate.Trace:New(pos,self:GetBeamNormal(),self.Entity)
		render.SetMaterial(self.Beam);
		render.DrawBeam(self.Entity:GetPos(),trace.HitPos,10,1,1,Color(255,255,255,255));
		for i=1,5 do
			render.DrawBeam(self.Entity:GetPos(),trace.HitPos + Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50)),5,1,1,Color(255,255,200,255));
		end

	 	local ViewNormal = self:GetPos() - EyePos();
	 	local Distance = ViewNormal:Length();
	 	ViewNormal:Normalize();
	 	local color = self:GetColor();
	 	local r,g,b,a = color.r,color.g,color.b,color.a;

	 	render.SetMaterial(self.LightMaterial);
	 	local Visibile = util.PixelVisible(trace.HitPos,16,self.PixVis);
	 	if(Visibile ~= 0) then
		 	local Size = math.Clamp(Distance*Visibile*2,64,512);

		 	Distance = math.Clamp(Distance,32,800);
		 	local Alpha = math.Clamp((1000 - Distance)*Visibile,0,100);
		 	local Col = Color(r,g,b,Alpha);
		 	render.DrawSprite(trace.HitPos, Size * 0.5, Size * 0.5, Col, Visibile )
			for i=1,4 do
				render.DrawSprite(trace.HitPos,16,16,Color(255,255,255,Alpha),Visibile);
			end
		end
	 	render.SetMaterial(self.LightMaterial)
	 	local Visibile = util.PixelVisible(pos,16,self.PixVis);
	 	if(Visibile ~= 0) then
		 	local Size = math.Clamp(Distance*Visibile*2,64,512);

		 	Distance = math.Clamp( Distance,32,800);
		 	local Alpha = math.Clamp((1000 - Distance)*Visibile,0,100);
		 	local Col = Color(r,g,b,Alpha);
		 	render.DrawSprite(pos,Size*0.5,Size*0.5,Col,Visibile);
			for i=1,4 do
				render.DrawSprite(pos,16,16,Color(255,255,255,Alpha),Visibile);
			end
		end
	end
end
