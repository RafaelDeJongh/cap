local matBlue		= Material( "particle/MultiPurpose04" )
matBlue:SetInt("$ignorez",1)
matBlue:SetInt("$illumfactor",8)

function EFFECT:Init(data)

	self.StartPos 	= data:GetOrigin()
	self.Num	= data:GetMagnitude()*30
	self.PartPos	= {}
	self.Part	= {}
	self.PartVis	= {}
	self.PartAlpha	= 255
	self.PartAim	= {}
	self.Emit	= ParticleEmitter(self.StartPos)
	self.Start	= CurTime()
	self.End	= self.Start+15

	self.Entity:SetRenderBounds(-1*Vector(1,1,1)*100000,Vector(1,1,1)*100000)

	for i=1,self.Num do
		local part = self.Emit:Add("particle/particle_smokegrenade", self.StartPos)
		local aim = Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(0.5,1))
		table.insert(self.PartPos, i, self.StartPos)
		table.insert(self.Part, i, part)
		table.insert(self.PartAim, i, aim)
		table.insert(self.PartVis, i, util.GetPixelVisibleHandle())

		if (part) then
			part:SetVelocity(aim*1750)
			part:SetLifeTime(0)
			part:SetDieTime(15)
			part:SetStartAlpha(0)
			part:SetEndAlpha(0)
			part:SetStartSize(500)
			part:SetEndSize(500)
			part:SetColor(0,0,0)
			part:SetAirResistance(0)
			part:SetGravity(Vector(0, 0, -400))
			part:SetCollide(true)
			part:SetBounce(0)
		end
	end
end

function EFFECT:Think()
	self.Time = CurTime()
	if self.Time > self.End then return end
	for i=1,self.Num do
		local pos = self.Part[i]:GetPos()
		self.PartAim[i] = (pos-self.PartPos[i]):GetNormal()
		self.PartPos[i] = pos

		if StarGate.VisualsWeapons("cl_gate_nuke_dynlights") then
			local dlight = DynamicLight( self:EntIndex()..tostring(i) )
	 		dlight.Pos = self.PartPos[i]
	 		dlight.r = 20
			dlight.g = 53
	 		dlight.b = 219
	 		dlight.Brightness = 5
	 		dlight.Decay = 500
	 		dlight.Size = 1000
			dlight.DieTime = self.Time + 2
		end
	end
	self.PartAlpha = (self.End-self.Time)*20

	return true
end

function EFFECT:Render()
	local a = math.Clamp(self.PartAlpha, 0 ,255)
	render.SetMaterial(matBlue)

	for i=1,self.Num do
		local pos = self.PartPos[i]
		local aim = self.PartAim[i]

		if util.PixelVisible(pos, 1, self.PartVis[i]) > 0 then
			render.DrawSprite(pos,1000,1000,Color(40,120,255,a))
			render.DrawSprite(pos,400,400,Color(120,180,255,a))
			render.DrawSprite(pos-120*aim,700,700,Color(20,100,255,a))
			render.DrawSprite(pos-200*aim,500,500,Color(20,80,255,a))
			render.DrawSprite(pos-240*aim,300,300,Color(20,60,255,a))
			render.DrawSprite(pos-280*aim,200,200,Color(20,40,255,a))
			render.DrawSprite(pos-320*aim,200,200,Color(20,20,255,a))
		end
	end
end