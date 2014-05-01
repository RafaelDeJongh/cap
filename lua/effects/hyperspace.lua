function EFFECT:Init(data)
	self.Init = CurTime()
	self.Time = self.Init
	self.Rel = 0
	self.Emit = ParticleEmitter(Vector(1,1,1))

	self.Parts = {}
end

function EFFECT:Think()

	self.Time = CurTime()
	self.Rel = self.Time-self.Init
	if self.Rel > 10 then return end

	local num = #self.Parts

	Msg("Num Particles"..num.."\n")

	for i=num+1,num+10 do
		local ang = math.random()*2*math.pi
		self.Parts[i] = self.Emit:Add("particle/MultiPurpose", Vector(2000, 1000+math.sin(ang)*1000, 1000+math.cos(ang)*1000))
		self.Parts[i]:SetVelocity(Vector(1,1,1))
		self.Parts[i]:SetGravity(Vector(0,0,0))
		self.Parts[i]:SetDieTime(10)
		self.Parts[i]:SetStartAlpha(255)
		self.Parts[i]:SetEndAlpha(0)
		self.Parts[i]:SetStartSize(30)
		self.Parts[i]:SetEndSize(30)
		self.Parts[i]:SetColor(200,200,255)
	end

	for i=1,num+10 do
		local p = (self.Parts[i]:GetPos()-Vector(1000,1000,1000))/100

		if p.x < -10 or p.x > 10 or p.y < -10 or p.y > 10 or p.z < -10 or p.z > 10 then
			self.Parts[i]:SetDieTime(0)
			Msg("Culled Particle \n")
		end

		self.Parts[i]:SetVelocity(100*Vector(	-3,
						-p.z+0.1*p.y*(p.x^2-p.y^2-p.z^2),
						p.y+0.1*p.z*(p.x*math.abs(p.x)-p.y^2-p.z^2)
					)
		)

	end


	return true
end

function EFFECT:Render()

end