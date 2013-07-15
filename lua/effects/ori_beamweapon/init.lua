local matBlue		= Material( "particle/MultiPurpose04" )
matBlue:SetInt("$ignorez",1)
matBlue:SetInt("$illumfactor",8)

function EFFECT:Init(data)

	self.StartPos 	= data:GetOrigin()
	self.Speed	= data:GetMagnitude()
	self.AimVector	= data:GetNormal()
	self.Ent	= data:GetEntity() -- The weapon or the thing firing it so it doesn't get stuck
	self.Pos	= {}
	self.Visibilty	= {} -- Visibilty for the trail.
	self.StaticVis	= {} -- Visibilty for the main glow.
	self.Init 	= CurTime()
	self.Time 	= self.Init
	self.Rel 	= self.Init
	self.LastThink	= self.Time
	self.Emit	= ParticleEmitter(self.StartPos)
	self.Alpha	= 255
	self.Num	= 1

	self.Entity:SetRenderBounds(-1*Vector(1,1,1)*100000,Vector(1,1,1)*100000)

	self.Pos[1] = self.StartPos
	self.Visibilty[1] = util.GetPixelVisibleHandle()

	for i=1,4 do
		self.StaticVis[i] = util.GetPixelVisibleHandle()
	end
end

function EFFECT:Think()
	self.Time = CurTime()
	self.Rel = self.Time-self.Init

	if self.Num < 40 then
		table.insert(self.Pos, self.StartPos)
		table.insert(self.Visibilty, util.GetPixelVisibleHandle())
	end

	self.Num = table.getn(self.Pos)

	for i=0,self.Num-2 do		-- Move all positions forward one.
		local inv = self.Num-i
		self.Pos[inv] = self.Pos[inv-1]
	end

	if self.Ent.GetEndPos then
		self.Pos[1] = self.Ent:GetEndPos()
	end

	self.AimVector = (self.Pos[1]-self.Pos[2]):GetNormal()

	local ang = self.AimVector:Angle()
	local up = ang:Up()
	local ri = ang:Right()

	if StarGate.VisualsWeapons("cl_oribeam_particle") then
		for i=1,50 do
			local ang = math.random()*math.pi*2
			local vel = (math.cos(ang)*ri+math.sin(ang)*up)*100
			local part = self.Emit:Add("particle/MultiPurpose02", self.Pos[1])

			if part then
				part:SetVelocity(vel)
				part:SetLifeTime(0)
				part:SetDieTime(5)
				part:SetStartSize(50)
				part:SetEndSize(0)
				part:SetStartAlpha(255)
				part:SetEndAlpha(0)
				part:SetAirResistance(0)
				part:SetCollide(true)
				part:SetBounce(0.2)
				part:SetColor(255,math.random(25,200),25,255)
			end
		end
	end

	if StarGate.VisualsWeapons("cl_oribeam_refract") then
		for i=1,4 do
			local part = self.Emit:Add("sprites/heatwave", self.Pos[1])

			if part then
				part:SetVelocity(VectorRand():GetNormal()*50)
				part:SetLifeTime(0)
				part:SetDieTime(5)
				part:SetStartSize(200)
				part:SetEndSize(0)
				part:SetStartAlpha(255)
				part:SetEndAlpha(0)
				part:SetAirResistance(0)
				part:SetCollide(true)
				part:SetBounce(0.2)
				part:SetColor(255,255,255,255)
			end
		end
	end

	if StarGate.VisualsWeapons("cl_oribeam_dynlights") then
		local dlight = DynamicLight(self:EntIndex())

		if(dlight) then
			dlight.Pos = self.Pos[1]
			dlight.r = math.random(230,255)
			dlight.g = 200
			dlight.b = 120
			dlight.Brightness = 4
			dlight.Decay = 400
			dlight.Size = 700
			dlight.DieTime = self.Time+0.5
		end
	end

	if self.Pos[3] and self.Pos[1]:Distance(self.Pos[3]) < 1 then
		self.Alpha = self.Alpha-200*FrameTime()
	end

	if self.Alpha < 0 then return end

	self.Entity:NextThink(self.Time+1/30) -- I find the effect works best if it's simulated 30 times a second, it looks crap if the frame rate gets to high.

	return true
end

function EFFECT:Render()
	render.SetMaterial(matBlue)

	local aim = self.AimVector

	local pos = {
		self.Pos[1],
		self.Pos[1]+120*aim,
		self.Pos[1]-120*aim,
		self.Pos[1]-200*aim
	}

	local rad = {700, 400, 600, 500}

	for i=1,4 do
		if util.PixelVisible(pos[i], 1, self.StaticVis[i]) > 0 then
			render.DrawSprite(
				pos[i],
				rad[i],
				rad[i],
				Color(240,180,120,self.Alpha)
			)
		end
	end

	for i=2,self.Num do
		if util.PixelVisible(self.Pos[i], 1, self.Visibilty[i]) > 0 then
			local size = math.Clamp(10*(35-i),80,500)+150
			render.DrawSprite(
				self.Pos[i],
				size,
				size,
				Color(240,200,120,self.Alpha)
			)
		end
	end
end
