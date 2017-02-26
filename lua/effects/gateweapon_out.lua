--[[
	Energy Laser
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end

EFFECT.GlowMat = Material("sprites/portalglow");
EFFECT.GlowMat2 = Material("sprites/light_ignorez");
EFFECT.GlowMat3 = StarGate.MaterialFromVMT(
	"GateWeapGlowOut",
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
	self.TargetEnt	= StarGate.FindEntInsideSphere(self.StartPos, 10, "event_horizon")[1];	-- Remote Gate
	if (not IsValid(self.TargetEnt)) then return end
	self.Parent		= data:GetEntity();
	self.StartPos	= StarGate.GetEntityCentre(self.Parent);
	self.Length		= 256;
	self.AimVector	= self.TargetEnt:GetForward();
	self.Draw		= false;

	self.Entity:SetRenderBounds(-1*Vector(1,1,1)*10000000,Vector(1,1,1)*10000000);
end

function EFFECT:Think()
	if not (IsValid(self.Parent) and IsValid(self.TargetEnt)) then return end
	self.StartPos 	= StarGate.GetEntityCentre(self.TargetEnt);
	self.AimVector	= self.TargetEnt:GetForward();
	self.StargateTrace = StarGate.Trace:New(self.StartPos+self.AimVector*5, self.AimVector*1000000000, {self.Parent, self.Target});

	local iris = StarGate.FindEntInsideSphere(self.StartPos, 50, "stargate_iris");

	self.Entity:SetRenderBounds(self.StartPos,self.StargateTrace.HitPos);

	self.Draw = not (IsValid(iris[1]) and iris[1]:GetNWBool("Activated"));
	return true
end

function EFFECT:Render()
	if (self.Draw) then
		local texcoor = CurTime()*-7;
		render.SetMaterial(self.RefractBeam);
		render.DrawBeam(self.StartPos, self.StargateTrace.HitPos, 170, texcoor, texcoor+self.Length/256);
		render.SetMaterial(self.BeamMat);
		render.DrawBeam(self.StartPos, self.StargateTrace.HitPos, 200, texcoor, texcoor+self.Length/256);
		render.DrawBeam(self.StartPos, self.StargateTrace.HitPos, 260, texcoor, texcoor+self.Length/256, Color(255,0,0,150));

		local pos = self.StartPos + self.AimVector*4;
		if (StarGate.LOSVector(EyePos(), pos, {GetViewEntity(),self.Parent}, 10)) then
			render.SetMaterial(self.GlowMat2);
			render.DrawQuadEasy(pos, self.AimVector, 1200, 1200);
			render.SetMaterial(self.GlowMat3);
			render.DrawQuadEasy(pos, self.AimVector, 700, 700);
		end

		local pos = self.StargateTrace.HitPos-self.AimVector*5;
		if (StarGate.LOSVector(EyePos(), pos, {GetViewEntity(),self.Parent}, 10)) then
			render.SetMaterial(self.GlowMat2);
			render.DrawSprite(pos, 800, 800);
			render.SetMaterial(self.GlowMat3);
			render.DrawSprite(pos, 900, 900)
		end
	end;
end