local matBeam = Material( "particle/redblacklargebeam" )
local matBeam2 = Material( "models/shadertest/predator" )

function EFFECT:Init(data)
	self.StartPos	= data:GetOrigin()
	self.EndPos	= data:GetStart()
	self.Length	= self.StartPos:Distance(self.EndPos)
	self.AimVector	= (self.EndPos-self.StartPos):GetNormal()

	self.Init 	= CurTime()
	self.Time	= self.Init
	self.Rel = self.Time-self.Init

	local fx = EffectData()
	fx:SetOrigin(self.EndPos)
	util.Effect("Unstable_Zap_Explosion",fx)

	self.Entity:SetRenderBounds(Vector(1,1,1)*-1000000, Vector(1,1,1)*1000000)

	--timer.Simple(0.5, function() self:Remove() end)
end

function EFFECT:Think()
	if self.Rel > 0.5 then
		return false
	end

	self.Time = CurTime()
	self.Rel = self.Time-self.Init
	return true
end

function EFFECT:Render()

	local pos = {}

	render.SetMaterial(matBeam2)
	render.StartBeam(14)
	render.AddBeam(self.StartPos, 32, 1, Color(255,255,255,255))

	local increment = self.Length/12

	for i = 1, 12 do
		pos[i] = self.StartPos+self.AimVector*i*increment+VectorRand():GetNormal()*((1-(i/6-1)^2)*200)

		render.AddBeam(pos[i], (13-i)*4, 1, Color(255,255,255,255))
	end

	render.AddBeam(self.EndPos, 2, 1, Color(255, 255, 255, 255))
	render.EndBeam()

	render.SetMaterial(matBeam) -- Draw the Colored beam
	render.StartBeam(14)

	render.AddBeam(self.StartPos, 32, 1, Color(255,255,255,255))

	for i = 1, 12 do
		render.AddBeam(pos[i], (13-i)*4, 1, Color(255,255,255,255))
	end

	render.AddBeam(self.EndPos, 2, 1, Color(255,255,255,255))
	render.EndBeam()

	for i= 1, 12, math.random(2,5) do
		self:DrawExtraBeams(pos[i], i)
	end
end

function EFFECT:DrawExtraBeams(pos, num)

	local points = {}

	render.SetMaterial(matBeam2)
	render.StartBeam(num/2+1)
	render.AddBeam(pos, (13-num)*4, self.Rel, color)

	local ang = math.random()*2*math.pi
	local up = self.AimVector:Angle():Up()
	local ri = self.AimVector:Angle():Right()

	local vec = math.cos(ang)*ri+math.sin(ang)*up

	for i= 1, num/2 do
		points[i] = pos+100*self.AimVector*i+vec*75*i+VectorRand()*((1-(i/(4*num)-1)^2)*50)
		render.AddBeam(points[i], (13-num-i)*4, self.Rel, color)
	end

	render.EndBeam()

	render.SetMaterial(matBeam)
	render.StartBeam(num/2+1)
	render.AddBeam(pos, (13-num)*4, self.Rel, color)

	for i= 1, num/2 do
		render.AddBeam(points[i], (13-num-i)*4, self.Rel, color)
	end

	render.EndBeam()
end