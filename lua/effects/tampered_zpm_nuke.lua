local matRefraction	= Material("refract_ring")
matRefraction:SetInt("$noclull", 1)

function EFFECT:Init(data)
	self.StartPos 	= data:GetOrigin()
	self.Scale	= data:GetMagnitude()/100
	self.Init 	= CurTime()
	self.Aim	= {Angle(90, 0, 0), data:GetAngles()}
	self.Time 	= self.Init
	self.Relative	= 0
	self.Vis	= util.GetPixelVisibleHandle()
	self.Emitter = ParticleEmitter(self.StartPos)

	self.Entity:SetModel(Model("models/zup/shields/1024_shield.mdl"))
	self.Entity:SetPos(self.StartPos)
	self.Entity:SetRenderBounds(-1*Vector(1,1,1)*100000,Vector(1,1,1)*100000)
end

function EFFECT:Think()
	self.Time = CurTime()
	self.Relative = self.Time-self.Init
	if self.Relative > 25 then return end
	if not StarGate.VisualsWeapons("cl_gate_nuke_rings") then return true end
	if (self.Relative < 10) then
		local num = self.Relative*25
		for _,ang in pairs(self.Aim) do
			local fw = ang:Up()
			local ri = ang:Right()
			local spawn = {}
			for i=1,num do
				local Ang = i*math.pi*2/num
				spawn[i] = self.StartPos+self.Relative*1000*self.Scale*(math.sin(Ang)*ri+math.cos(Ang)*fw)
			end
			local CannotSpawn = {}
			local draw = StarGate.VisualsWeapons("cl_gate_nuke_shieldrings")
			if draw then
				CannotSpawn = StarGate.ArePointsInsideAShield(spawn, 200)
			end
		end
	end
	return true
end

function EFFECT:Render()
	local size = 30-self.Relative
	local a = math.Clamp((25-self.Relative)*12, 0, 255)
	if self.Relative < 24 then -- Mostly TetaBonitas
		local eye = EyePos()
		local Distance = eye:Distance(self.StartPos)
		local Pos = self.StartPos+(eye-self.StartPos):GetNormal()*math.sin(self.Relative/2)*1.1*Distance
		matRefraction:SetFloat( "$refractamount", math.sin(self.Relative/2)*0.2)
		render.SetMaterial(matRefraction)
		render.UpdateRefractTexture()
		render.DrawSprite(Pos, self.Relative*1000*self.Scale, self.Relative*1000*self.Scale)
	end
end
