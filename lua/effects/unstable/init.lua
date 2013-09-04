if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end

local matRefract	= Material( "refract_ring" )
local matPinch		= Material( "particle/warp1_warp" )
local matRipple		= Material( "particle/warp_ripple" )
local matLight		= {}
	matLight.one	= Material( "sprites/light_ignorez" )
	matLight.two	= StarGate.MaterialFromVMT(
	"UnstableGlow",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/redglow2"
		"$spriteorientation" "vp_parallel"
		"$spriteorigin" "[ 0.50 0.50 ]"
		"$additive" 1
		"$ignorez" 1
		"$illumfactor" 8
		"$spriterendermode" 9
	}]]);

for _,mat in pairs(matLight) do
	mat:SetInt("$spriterendermode",9)
	mat:SetInt("$ignorez",1)
	mat:SetInt("$illumfactor",8)
end

function EFFECT:Init(data)

	self.EntityO	= data:GetEntity() 	-- Give the overloader that is firing
	if (not IsValid(self.EntityO)) then return end
	self.EntityG	= self.EntityO:GetNetworkedEntity("remoteGate", nil)
	self.StartPos	= StarGate.GetEntityCentre(self.EntityG)
	self.EntityE	= StarGate.FindEntInsideSphere(self.StartPos, 10, "event_horizon")[1]
	self.Visibilty	= util.GetPixelVisibleHandle()
	self.Init 	= CurTime()
	self.Time	= self.Init
	self.Rel	= 0
	self.AimVector	= Vector(0,0,0)

	self:SpawnLightning()

	self.Entity:SetRenderBounds(Vector(1,1,1)*-1000000, Vector(1,1,1)*1000000)

end

function EFFECT:Think()

	if not (self.EntityG and self.EntityG:IsValid()) then return end

	if self.Rel > 30 then
		return false
	end

	self.Time = CurTime()
	self.Rel = self.Time-self.Init
	self.StartPos = StarGate.GetEntityCentre(self.EntityG)
	self.AimVector = self.EntityG:GetForward()

	return true
end

function EFFECT:SpawnLightning()

	local fx = EffectData()
	fx:SetOrigin(self.StartPos)
	fx:SetStart(StarGate.ShieldTrace(
						self.StartPos,
						VectorRand():GetNormal()*2000,
						{self.EntityG, self.EntityE}
			).HitPos
	)

	util.Effect("Unstable_Zap", fx)

	timer.Simple(math.Rand(0.7, 1.3), function() if self.SpawnLightning then self:SpawnLightning() end end)
end

function EFFECT:Render()
	local ANGLE = self.AimVector:Angle()
	local fw = ANGLE:Forward()
	local up = ANGLE:Up()
	local ri = ANGLE:Right()

	if util.PixelVisible(self.StartPos, self.Rel*96, self.Visibilty) > 0.1 then
		render.SetMaterial(matPinch)
		matPinch:SetFloat("$refractamount", math.sin(self.Rel/2)*0.2)
		render.UpdateRefractTexture()
		render.DrawQuadEasy(self.StartPos+fw,fw,200,200)
		render.DrawQuadEasy(self.StartPos-fw*3,-1*fw,200,200)
		render.SetMaterial(matLight.one)
		render.DrawSprite(self.StartPos, self.Rel*80, self.Rel*96,Color(255,255,255,255))
		render.SetMaterial(matLight.two)
		render.DrawSprite(self.StartPos, self.Rel*96, self.Rel*48, Color(255,255,255,255))
	end

	if self.Rel < 5 then -- The shockwave
		local ringrad = self.Rel*5000
		render.SetMaterial(matRefract)
		matRefract:SetFloat("$refractamount", 0.2)
		render.UpdateRefractTexture()
		render.DrawSprite(self.StartPos, ringrad, ringrad, Color(255,255,255,255))
	end

	if self.Rel > 27 then
		local rel = self.Rel-27

		render.SetMaterial(matRipple)
		matRipple:SetFloat("$refractamount", math.sin(rel*2)*0.16)
		render.UpdateRefractTexture()
		render.DrawSprite(self.StartPos, rel*490, rel*490, Color(255,255,255,rel*85))
	end
end