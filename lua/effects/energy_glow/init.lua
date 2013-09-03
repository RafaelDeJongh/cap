--[[
	Energy Glow
	Copyright (C) 2011 Madman07
]]--

EFFECT.GlowMat = Material("sprites/portalglow");
EFFECT.GlowMat2 = Material("sprites/light_ignorez");
EFFECT.GlowMat3 = StarGate.MaterialFromVMT(
	"EnergyGlowRed",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/redglow2"
		"$spriteorientation" "vp_parallel"
		"$spriteorigin" "[ 0.50 0.50 ]"
		"$additive" 1
		"$ignorez" 1
		"$illumfactor" 7
		"$spriterendermode" 9
	}]]
);

function EFFECT:Init( data )
	self.LocalPos = data:GetStart();
	self.Parent = data:GetEntity();
	local color = data:GetAngles();
	self.Color = Color(255,200,120);
	if(color ~= Angle(0,0,0)) then
		self.Color = Color(color.p,color.y,color.r);
	end
	self.Size = data:GetScale();
	self.LifeTime = CurTime()+data:GetMagnitude();

	self.GlowScale = 0;
	if (IsValid(self.Parent)) then self.LastPos = self.Parent:LocalToWorld(self.LocalPos); end
	self.Entity:SetRenderBounds(-1*Vector(1,1,1)*100000,Vector(1,1,1)*100000);
end

function EFFECT:Think()
	if (not IsValid(self.Parent) or self.LifeTime < CurTime()) then
		self.GlowScale = math.Clamp(self.GlowScale-0.04, 0, 1);
		if (self.GlowScale < 0.03) then self:Remove(); end
	else
		self.GlowScale = math.Clamp(self.GlowScale+0.04, 0, 1);

		local dynlight = DynamicLight(math.Rand(0,1000));
			dynlight.Pos = self.LastPos;
			dynlight.Size = self.Size;
			dynlight.Decay = self.Size;
			dynlight.R = self.Color.r;
			dynlight.G = self.Color.g;
			dynlight.B = self.Color.b;
			dynlight.DieTime = CurTime()+0.2;
	end
	return true
end

function EFFECT:Render()
	if IsValid(self.Parent) then
		self.LastPos = self.Parent:LocalToWorld(self.LocalPos);
	end
	render.SetMaterial(self.GlowMat);
	render.DrawSprite(self.LastPos, self.GlowScale*self.Size*5, self.GlowScale*self.Size*5, self.Color);
	render.DrawSprite(self.LastPos, self.GlowScale*self.Size*3, self.GlowScale*self.Size*3, Color(255,255,255));

	render.SetMaterial(self.GlowMat2);
	render.DrawSprite(self.LastPos, self.GlowScale*self.Size*3, self.GlowScale*self.Size*3, self.Color);
	render.SetMaterial(self.GlowMat3);
	render.DrawSprite(self.LastPos, self.GlowScale*self.Size*2, self.GlowScale*self.Size*2, self.Color);
end