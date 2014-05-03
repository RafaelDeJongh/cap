if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end
EFFECT.GlowMat = Material("sprites/portalglow");
EFFECT.GlowMat2 = Material("sprites/light_ignorez");
EFFECT.GlowMat3 = StarGate.MaterialFromVMT(
	"GateWeapGlowIn",
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
	self.Parent	= data:GetEntity();
	if (not IsValid(self.Parent) or self.Parent.GetLocalGate==nil or not IsValid(self.Parent:GetLocalGate())) then return end
	self.EH	= StarGate.FindEntInsideSphere(self.Parent:GetLocalGate():GetPos(), 10, "event_horizon")[1]	-- Remote Gate
	if (not IsValid(self.EH)) then return end
	self.Beam = self.Parent:GetInboundBeam();
	self.Parent.BeamEffect = self;

	self.MainStart = self.Parent:GetEmitterPos();
	self.EndPos	= StarGate.GetEntityCentre(self.EH);

	self.SmallBeamStart = {
		self.MainStart,
		self.MainStart,
		self.MainStart,
		self.MainStart
	}

	self.ShouldDrawBeam = true;
	self.GlowScale = 0;
	self.Size = {10, 40};
	self.Length = 256;
	self.AimVector = self.EH:GetForward();

	self.Entity:SetRenderBoundsWS(self.MainStart,self.EndPos);
end

function EFFECT:Think()
	if (not IsValid(self.Parent)) then return false end
	if (self.GlowScale==nil) then return false end
	if not IsValid(self.Beam) then
		self.ShouldDrawBeam = false;
	end
	if self.ShouldDrawBeam then
		self.GlowScale = math.Clamp(self.GlowScale+0.03, 0, 1);
	else
		self.GlowScale = math.Clamp(self.GlowScale-0.03, 0, 1);
		if (self.GlowScale < 0.04) then self:Remove(); end
	end

	if IsValid(self.Parent) then
		self.MainStart = self.Parent:GetEmitterPos();
		self.SmallBeamStart = {
			self.Parent:GetSubBeamPos(1),
			self.Parent:GetSubBeamPos(2),
			self.Parent:GetSubBeamPos(3),
			self.Parent:GetSubBeamPos(4)
		}
	end
	if IsValid(self.EH) then
		self.EndPos	= StarGate.GetEntityCentre(self.EH);
		self.AimVector = self.EH:GetForward();
	end

	if StarGate.VisualsWeapons("cl_asuran_dynlights") then
		local dlight = DynamicLight(self:EntIndex()) ;
	 	dlight.Pos = self.EndPos;
	 	dlight.r = 255;
		dlight.g = 50;
	 	dlight.b = 50;
	 	dlight.Brightness = 5.47;
	 	dlight.Decay = 250;
		dlight.Size = 750;
		dlight.DieTime = CurTime() + 0.2;
	end

	self.Entity:SetRenderBoundsWS(self.MainStart,self.EndPos);
	return true
end

function EFFECT:Render()
	if (not IsValid(self.Parent)) then return false end
	local texcoor = CurTime()*-7;

	if self.ShouldDrawBeam then
		render.SetMaterial(self.GlowMat);
		render.DrawSprite(self.MainStart, 200, 200, Color(255,50,50,255));
		render.DrawSprite(self.MainStart, 150, 150, Color(255,255,255,255));

		render.SetMaterial(self.RefractBeam);
		render.DrawBeam(self.MainStart, self.EndPos, 20, texcoor, texcoor+self.Length/256);
		render.SetMaterial(self.BeamMat);
		render.DrawBeam(self.MainStart, self.EndPos, 35, texcoor, texcoor+self.Length/256);
		render.DrawBeam(self.MainStart, self.EndPos, 50, texcoor, texcoor+self.Length/256, Color(255,50,50,150));

		local pos = self.EndPos + self.AimVector*4;
		if (StarGate.LOSVector(EyePos(), pos, {GetViewEntity(),self.EH}, 10)) then
			render.SetMaterial(self.GlowMat2);
			render.DrawQuadEasy(pos, self.AimVector, 400, 400);
			render.SetMaterial(self.GlowMat3);
			render.DrawQuadEasy(pos, self.AimVector, 450, 450);
		end
	end

	if (StarGate.LOSVector(EyePos(), self.MainStart, {GetViewEntity()}, 10)) then
		render.SetMaterial(self.GlowMat2);
		render.DrawSprite(self.MainStart, 25, 25, Color(255,50,50,255));
		render.SetMaterial(self.GlowMat3);
		render.DrawSprite(self.MainStart, 25, 25, Color(255,50,50,255));
	end

	if StarGate.VisualsWeapons("cl_asuran_laser") then
		for _,startbeam in pairs(self.SmallBeamStart) do
			if self.ShouldDrawBeam then
				render.SetMaterial(self.RefractBeam);
				render.DrawBeam(self.EndPos, startbeam, 5, texcoor, texcoor+self.Length/256);
				render.SetMaterial(self.BeamMat);
				render.DrawBeam(self.EndPos, startbeam, 10, texcoor, texcoor+self.Length/256);
				render.DrawBeam(self.EndPos, startbeam, 15, texcoor, texcoor+self.Length/256, Color(255,50,50,150));

				render.SetMaterial(self.GlowMat);
				render.DrawSprite(startbeam, 60, 60, Color(255,50,50,255));
				render.DrawSprite(startbeam, 45, 45, Color(255,255,255,255));
			end

			if (StarGate.LOSVector(EyePos(), startbeam, {GetViewEntity()}, 10)) then
				render.SetMaterial(self.GlowMat2);
				render.DrawSprite(startbeam, 30, 30, Color(255,50,50,255));
				render.SetMaterial(self.GlowMat3);
				render.DrawSprite(startbeam, 30, 30, Color(255,50,05,255));
			end
		end
	end

end
