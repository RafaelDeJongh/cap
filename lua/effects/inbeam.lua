local matBulge 		= Material( "Effects/strider_bulge_dudv" )
local matDistortBeam 	= Material( "models/shadertest/predator" )
local matRefraction	= Material( "refract_ring" )
local matBlueBeam	= Material( "Effects/blueblacklargebeam" )
local glowMaterial = Material("sprites/portalglow")

matRefraction:SetInt("$nocull",1) -- This is so it draws from both sides

function EFFECT:Init(data)

	self.EntityO	= data:GetEntity() 	-- Give the overloader that is firing
	if (not IsValid(self.EntityO)) then return end
	self.EntityG	= self.EntityO:GetLocalGate()
	self.StartPos 	= StarGate.GetEntityCentre(self.EntityG)
 	self.EndPos 	= Vector(0,0,0)
 	self.Dir 	= Vector(0,0,0)
	self.AimVector	= Vector(0,0,0)
	self.Init	= CurTime()
	self.Time	= self.Init
	self.Rad	= 0
	self.Rel	= 0
	self.State	= 1
	self.Emit	= ParticleEmitter(self.StartPos or Vector(0,0,0))
	self.GlowSize = 40;

end

function EFFECT:Think()
	if (not IsValid(self.EntityO) or not self.StartPos) then return end
	self.Time = CurTime()
	self.Rel = self.Time-self.Init

	if self.Rel>2 and self.State ~= 3 and not (self.EntityO and self.EntityG and self.EntityG:IsValid() and self.EntityO:IsValid() and self.EntityO:IsFiring()) then
		self.State = 3
		self.Init = self.Time
		self.Rel = 0
	end

	if self.State ~= 3 then
		if self.State == 1 and self.Rel > 5 then
			self.State = 2
			self.Init = self.Time
			self.Rel = 0
		end
	elseif self.Rel > 2 then
		return false
	end

	if self.State ~= 3 then

		self.StartPos 	= self.EntityO:GetEmitterPos()
		self.EndPos	= StarGate.GetEntityCentre(self.EntityG)
		self.Dir	= self.EndPos - self.StartPos
		self.AimVector 	= self.Dir:GetNormal()
		self.Rad	= (self.Rel%3)/3

		if StarGate.VisualsWeapons("cl_overloader_dynlights") then
			local dlight = DynamicLight(self:EntIndex())
	 		dlight.Pos = self.StartPos
	 		dlight.r = 20
			dlight.g = 53
	 		dlight.b = 219
	 		dlight.Brightness = 5.47
	 		dlight.Decay = 250
	 		dlight.Size = 750
			dlight.DieTime = self.Time + 2
		end
	end

	return true
end

function EFFECT:Render()
	if (not self.AimVector or not self.StartPos) then return end
	local ANGLE = self.AimVector:Angle()
	local fw = self.AimVector
	local up = ANGLE:Up()
	local ri = ANGLE:Right()
	local Emit = self.Emit
	local sPart = StarGate.VisualsWeapons("cl_overloader_particle")
	local sRefr = StarGate.VisualsWeapons("cl_overloader_refract")

	if (self.EntityO and IsValid(self.EntityO)) then
		self:SetRenderBoundsWS(self.EntityO:GetPos(), self.EndPos)
	end

	-- The starting Effect
	if self.State == 1 then

		if sRefr then
			matBulge:SetFloat("$refractamount", .2)
			render.UpdateRefractTexture()
			render.SetMaterial(matBulge)
			render.DrawSprite(self.StartPos,75,75,Color(255,255,255))
		end

		local Ran = (5-self.Rel)*125
		local a  = self.Rel*50

		-- Lots Of Little Beams
		for i = 0,20 do
			local ang = math.random()*2*math.pi
			local Vec = (math.sin(ang)*up+math.cos(ang)*ri)*math.random(0,Ran)

			render.SetMaterial(matDistortBeam)
			render.DrawBeam(self.StartPos, self.EndPos+Vec, 10, 1, 1, Color(50,50,255,Alpha))

			render.SetMaterial(matBlueBeam)
			render.DrawBeam(self.StartPos, self.EndPos+Vec, 15, 1, 1, Color(150,150,255,Alpha))
		end

		for beam = 1, 6 do
			local startbeam = self.EntityO:GetSubBeamPos(beam)
			render.SetMaterial(matDistortBeam)
			render.DrawBeam(self.StartPos, startbeam, 5, 1, 1, Color(50,50,255))
			render.SetMaterial(matBlueBeam)
			render.DrawBeam(self.StartPos, startbeam, 10, 1, 1, Color(150,150,255))
			render.SetMaterial(glowMaterial)
			render.DrawSprite(startbeam, self.GlowSize, self.GlowSize, Color(255,255,255,255))
		end

		if sPart then

			for i = 1,10 do
				local ang = math.random()*2*math.pi

				local spawn = math.random(0,300)*(math.cos(ang)*ri + math.sin(ang)*up)
				local part = Emit:Add("particle/MultiPurpose02",self.StartPos+spawn)

				if part then
					part:SetVelocity(Vector(0,0,0))
					part:SetLifeTime(0)
					part:SetDieTime(1)
					part:SetStartSize(15)
					part:SetEndSize(0)
					part:SetStartAlpha(255)
					part:SetEndAlpha(0)
					part:SetAirResistance(0)
					part:SetGravity(spawn*-2)
					part:SetCollide(true)
					part:SetBounce(0.4)
					part:SetColor(150,150,255,255)
				end
			end

			if self.Rel > 4.9 then

				for i=1,40 do

					local ang = math.random()*2*math.pi
					local part = Emit:Add("particle/MultiPurpose02",self.StartPos)

					if part then
						part:SetVelocity(self.AimVector*300+math.random(0,150)*(math.cos(ang)*ri+math.sin(ang)*up))
						part:SetLifeTime(0)
						part:SetDieTime(4)
						part:SetStartSize(15)
						part:SetEndSize(0)
						part:SetStartAlpha(255)
						part:SetEndAlpha(0)
						part:SetRoll(0)
						part:SetRollDelta(0)
						part:SetAirResistance(0)
						part:SetGravity(-400*self.AimVector)
						part:SetCollide(true)
						part:SetBounce(0.6)
						part:SetColor(255,255,255,255)
					end
				end
			end
		end

	-- The main Effect
	elseif self.State == 2 then

		local ref

		if sRefr then
			ref = 0.2
		else
			ref = 0
		end

		render.SetMaterial(matDistortBeam)
		render.DrawBeam(self.StartPos, self.EndPos, 10, 1, 1, Color(50,50,255))
		render.SetMaterial(matBlueBeam)
		render.DrawBeam(self.StartPos, self.EndPos, 15, 1, 1, Color(150,150,255))

		for beam = 1, 6 do
			local startbeam = self.EntityO:GetSubBeamPos(beam)
			render.SetMaterial(matDistortBeam)
			render.DrawBeam(self.StartPos, startbeam, 5, 1, 1, Color(50,50,255))
			render.SetMaterial(matBlueBeam)
			render.DrawBeam(self.StartPos, startbeam, 10, 1, 1, Color(150,150,255))
			render.SetMaterial(glowMaterial)
			render.DrawSprite(startbeam, self.GlowSize, self.GlowSize, Color(255,255,255,255))
		end

		local pos = self.StartPos+self.Dir*self.Rad
		local size = self.Rad*300

		matRefraction:SetFloat("$refractamount", ref)
		render.SetMaterial(matRefraction)
		render.UpdateRefractTexture()
		render.DrawQuadEasy(pos,self.AimVector,size,size)

		size = size/1.5

		matBulge:SetFloat("$refractamount", ref)
		render.SetMaterial(matBulge)
		render.UpdateRefractTexture()
		render.DrawSprite(pos,size,size,Color(255,255,255)) -- One that moves
		render.DrawSprite(self.StartPos,75,75,Color(255,255,255)) -- One that stays Still

		if not sPart then return end

		-- The leaking particles
		local part = Emit:Add("particle/MultiPurpose02", self.StartPos+math.Rand(0,self.Rad)*self.Dir)

		if part then
			part:SetVelocity(Vector(0,0,0))
			part:SetLifeTime(0)
			part:SetDieTime(1.5)
			part:SetStartSize(10)
			part:SetEndSize(7)
			part:SetStartAlpha(255)
			part:SetEndAlpha(0)
			part:SetAirResistance(0)
			part:SetGravity(Vector(0,0,-400))
			part:SetCollide(true)
			part:SetBounce(0.4)
			part:SetColor(150,150,250,255)
		end

		for i = 0,7 do 		-- The spiriling particles
			local ang = self.Rel*2 + i*math.pi/4
			local spawn = pos+(size/1.8)*(math.cos(ang)*ri + math.sin(ang)*up)
			local part = Emit:Add("particle/MultiPurpose02",spawn)

			if part then
				part:SetVelocity(Vector(0,0,0))
				part:SetLifeTime(0)
				part:SetDieTime(3)
				part:SetStartSize(25)
				part:SetEndSize(20)
				part:SetStartAlpha(255)
				part:SetEndAlpha(0)
				part:SetAirResistance(0)
				part:SetGravity(Vector(0,0,0))
				part:SetCollide(true)
				part:SetBounce(0.4)
				part:SetColor(150,150,255,255)
			end
		end

	-- The Dying Effect
	else if self.State == 3 then

		if sPart then
			local num = math.floor(self.Dir:Length()/20)
			if self.Rel < 0.5 then

				for i = 1,num do
					local Spawn = self.StartPos + self.AimVector*20*i

					for i = 1,5 do
						local part = Emit:Add("particle/MultiPurpose02",Spawn)

						if part then
							part:SetVelocity(VectorRand()*150)
							part:SetLifeTime(0)
							part:SetDieTime(3)
							part:SetStartSize(15)
							part:SetEndSize(0)
							part:SetStartAlpha(255)
							part:SetEndAlpha(0)
							part:SetAirResistance(0)
							part:SetGravity(Vector(0,0,-400))
							part:SetCollide(true)
							part:SetBounce(0.6)
							part:SetColor(150,150,255,255)
						end
					end
				end

				for i = 1,30 do
					local ang = math.random()*2*math.pi
					local part = Emit:Add("particle/MultiPurpose02",self.StartPos)

					if part then
						part:SetVelocity((math.cos(ang)*ri + math.sin(ang)*up)*300+self.AimVector*300)
						part:SetLifeTime(0)
						part:SetDieTime(5)
						part:SetStartSize(15)
						part:SetEndSize(15)
						part:SetStartAlpha(255)
						part:SetEndAlpha(0)
						part:SetAirResistance(50)
						part:SetGravity(self.AimVector*-75)
						part:SetCollide(true)
						part:SetBounce(0.4)
						part:SetColor(150,150,255,255)
					end
				end
			end
		end

		if sRefr then
			render.SetMaterial(matRefraction) 	-- The three expanding rings
			--where is self.RingRad? anyway works wrong
			--render.DrawQuadEasy(self.StartPos,fw,self.RingRad,self.RingRad)
			--render.DrawQuadEasy(self.StartPos,up,self.RingRad,self.RingRad)
			--render.DrawQuadEasy(self.StartPos,ri,self.RingRad,self.RingRad)
		end

		end

	end
end
