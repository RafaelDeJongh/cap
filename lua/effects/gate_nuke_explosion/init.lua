local matRefraction	= Material("refract_ring")

local matGlow = {}
	matGlow.Glow1 = Material("particle/light01")
	matGlow.Glow2 = StarGate.MaterialFromVMT(
	"GateNukeExpL",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/light_glow03"
		"$spriteorientation" "vp_parallel"
		"$spriteorigin" "[ 0.50 0.50 ]"
		"$additive" 1
		"$spriterendermode" 9
		"$ignorez" 1
		"$illumfactor" 10
	}]]);
	matGlow.Glow3 = StarGate.MaterialFromVMT(
	"GateNukeExpB",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/blueglow1"
		"$spriteorientation" "vp_parallel"
		"$spriteorigin" "[ 0.50 0.50 ]"
		"$additive" 1
		"$spriterendermode" 9
		"$ignorez" 1
		"$illumfactor" 10
	}]]);
	matGlow.Glow4 = Material("sprites/light_ignorez")


matRefraction:SetInt("$noclull", 1)
for _,k in pairs(matGlow) do
	k:SetInt("$additive",1)
	k:SetInt("$spriterendermode",9)
	k:SetInt("$ignorez",1)
	k:SetInt("$illumfactor",10)
end

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

	if StarGate.VisualsWeapons("cl_gate_nuke_plasma") then
		local fx = EffectData()
		fx:SetOrigin(self.StartPos)
		fx:SetMagnitude(self.Scale)
		util.Effect("Gate_Nuke_Explosion_Bits", fx)
	end

	for i=1, 40*self.Scale do

		local vec = Vector(math.Rand(-32,32),math.Rand(-32,32),math.Rand(-18,18)):GetNormal()
		local part = self.Emitter:Add("particle/Explode"..math.random(1,2), self.StartPos+vec*math.Rand(250,690)*self.Scale)

		part:SetVelocity(math.Rand(30,33)*vec*self.Scale)
		part:SetDieTime(20)
		part:SetStartAlpha(math.Rand(230,250))
		part:SetStartSize(math.Rand(130,190)*self.Scale)
		part:SetEndSize(math.Rand(310,450)*self.Scale)
		part:SetRoll(math.Rand(480,540))
		part:SetRollDelta(math.Rand(-1,1))
		part:SetColor(math.random(100,200), math.random(50,150), 255)
		part:VelocityDecay(true)
	end

	for i=1, 10 do

		local vec = VectorRand()
		local spawnpos = self.StartPos + 256*vec*self.Scale

		for k=5,26 do
			local part = self.Emitter:Add( "particle/Explode"..math.random(1,2), spawnpos - vec*50*k*self.Scale)

			part:SetVelocity(Vector(0,0,0))
			part:SetDieTime(20)
			part:SetStartAlpha(math.Rand(230, 250))
			part:SetEndAlpha(0)
			part:SetStartSize((((31-k)*math.Rand(3,4))^1.2)*self.Scale)
			part:SetEndSize((((31-k)*math.Rand(5,6))^1.2)*self.Scale)
			part:SetRoll(math.Rand(20,80))
			part:SetRollDelta(math.random(-1,1))
			part:SetColor(math.random(100,200), math.random(50,150), 255)
			part:VelocityDecay(true)
		end
	end
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

			for i=1,num do
				if (not draw) or (draw and (not CannotSpawn[i])) then
					local part = self.Emitter:Add("particle/Explode"..math.random(1,2), spawn[i])

					part:SetVelocity(Vector(0,0,0))
					part:SetDieTime(0.5)
					part:SetStartAlpha(255)
					part:SetEndAlpha(0)
					part:SetStartSize(math.random(600,680)*self.Scale)
					part:SetEndSize(math.random(520,600)*self.Scale)
					part:SetRoll(math.Rand(20, 80))
					part:SetRollDelta(math.random(-1, 1))
					part:SetColor(math.random(100,200),math.random(100,200),255)
				end
			end
		end
	end
	return true
end

function EFFECT:Render()
	local size = 30-self.Relative
	local a = math.Clamp((25-self.Relative)*12, 0, 255)

	if self.Relative < 5 then
		size = self.Relative*4000*self.Scale/1024
		local mat = Matrix()
		mat:Scale(Vector(1,1,1)*size)
		self.Entity:EnableMatrix( "RenderMultiply", mat )
		self.Entity:SetColor(Color(255,255,255,255))
		self.Entity:DrawModel()
	end

	if util.PixelVisible(self.StartPos, 400*size*self.Scale, self.Vis) > 0 then
		render.SetMaterial(matGlow.Glow1) -- All three of these are various levels of glow
		render.DrawSprite(self.StartPos, size*400*self.Scale,size*240*self.Scale,Color(255,255,255,a))

		render.SetMaterial(matGlow.Glow2)
		render.DrawSprite(self.StartPos, size*150*self.Scale, size*100*self.Scale, Color(255,255,255,a))

		render.SetMaterial(matGlow.Glow3)
		render.DrawSprite(self.StartPos, 200*size*self.Scale, 400*size*self.Scale, Color(150,150,255,a/1.5))
		render.DrawSprite(self.StartPos, 400*size*self.Scale, 200*size*self.Scale, Color(150,150,255,a))
	end

	if self.Relative < 3 then -- Mostly TetaBonitas
		local eye = EyePos()
		local Distance = eye:Distance(self.StartPos)
		local Pos = self.StartPos+(eye-self.StartPos):GetNormal()*math.sin(self.Relative/2)*1.1*Distance
		matRefraction:SetFloat( "$refractamount", math.sin(self.Relative/2)*0.2)
		render.SetMaterial(matRefraction)
		render.UpdateRefractTexture()
		render.DrawSprite(Pos, self.Relative*1000*self.Scale, self.Relative*1000*self.Scale)
	end


	if self.Relative < 5 then
		matRefraction:SetFloat( "$refractamount", (5-self.Relative)*0.4)
		render.UpdateRefractTexture()
		render.SetMaterial(matRefraction)
		size = (self.Relative*6000+1000)*self.Scale
		render.DrawQuadEasy(self.StartPos, Vector(0,0,1), size, size)
		render.DrawQuadEasy(self.StartPos, self.Aim[2]:Forward(), size, size)
	end

	if self.Relative < 2 then
		render.SetMaterial(matGlow.Glow4)
		render.DrawSprite(self.StartPos, 1000000, 1000000, Color(255,255,255,(2-self.Relative)*125*self.Scale))
	end
end
