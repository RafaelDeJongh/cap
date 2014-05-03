--[[
	Energy Laser ONeill
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end

EFFECT.GlowMat = Material("sprites/portalglow");
EFFECT.GlowMat2 = Material("sprites/light_ignorez");
EFFECT.GlowMat3 = StarGate.MaterialFromVMT(
	"ONeillBeamGlow",
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

EFFECT.GlowMat2:SetInt("$spriterendermode", 9)
EFFECT.GlowMat2:SetInt("$ignorez", 1)
EFFECT.GlowMat2:SetInt("$illumfactor", 7)

EFFECT.BeamMat = Material("effects/laser_beam");
EFFECT.RefractBeam = Material("models/shadertest/predator");

function EFFECT:Init(data)
	self.StartPos	= data:GetOrigin();
	self.TargetEnt	= StarGate.FindEntInsideSphere(self.StartPos, 10, "ring_base_ancient")[1];	-- Remote Gate
	self.Parent		= data:GetEntity();
	self.StartPos	= StarGate.GetEntityCentre(self.Parent);
	self.Length		= 256;
	self.AimVector	= self.TargetEnt:GetUp();
	self.Draw		= false;

	self.Entity:SetRenderBoundsWS(-1*Vector(1,1,1)*100000000000,Vector(1,1,1)*100000000000);
end

function EFFECT:Think()
	if not (IsValid(self.Parent) and IsValid(self.TargetEnt)) then return end
	self.StartPos 	= StarGate.GetEntityCentre(self.TargetEnt);
	self.AimVector	= self.TargetEnt:GetUp();
	self.StargateTrace = StarGate.Trace:New(self.StartPos+self.AimVector*5, self.AimVector*1000000000, {self.Parent, self.Target});
	self.Draw = true;
	self.Entity:SetRenderBoundsWS(self.StartPos,self.StargateTrace.HitPos);
	return true
end

function EFFECT:Render()
	if (self.Draw) then
		local texcoor = CurTime()*-7;
		render.SetMaterial(self.RefractBeam);
		render.DrawBeam(self.StartPos, self.StargateTrace.HitPos, 75, texcoor, texcoor+self.Length/256);
		render.SetMaterial(self.BeamMat);
		render.DrawBeam(self.StartPos, self.StargateTrace.HitPos, 90, texcoor, texcoor+self.Length/256);
		render.DrawBeam(self.StartPos, self.StargateTrace.HitPos, 120, texcoor, texcoor+self.Length/256, Color(0,0,255,150));

		local pos = self.StartPos + self.AimVector*4;
		if (StarGate.LOSVector(EyePos(), pos, {GetViewEntity(),self.Parent}, 10)) then
			render.SetMaterial(self.GlowMat2);
			render.DrawQuadEasy(pos, self.AimVector, 900, 900);
			render.SetMaterial(self.GlowMat3);
			render.DrawQuadEasy(pos, self.AimVector, 1000, 1000, Color(0,0,255,150));
		end

		local pos = self.StargateTrace.HitPos-self.AimVector*5;
		if (StarGate.LOSVector(EyePos(), pos, {GetViewEntity(),self.Parent}, 10)) then
			render.SetMaterial(self.GlowMat2);
			render.DrawSprite(pos, 900, 900);
			render.SetMaterial(self.GlowMat3);
			render.DrawSprite(pos, 1000, 1000, Color(0,0,255,150))
		end
	end;
end