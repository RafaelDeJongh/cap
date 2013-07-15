local matBeam = Material( "Effects/blueblacklargebeam" )

function EFFECT:Init(data)

	self.Ent	= data:GetEntity()
	self.End	= data:GetMagnitude() -- How long for the effect to last
	self.Rad	= {}
	self.Num	= data:GetScale() -- Number Of Rings
	self.Ang	= {}
	self.Distance 	= 0
	self.Time 	= CurTime()
	self.Init	= self.Time
	self.Pos 	= self.Ent:GetPos()+Vector(0,0,2400);--self.Ent:GetUp()*2300
	self.Emit	= ParticleEmitter(self.Pos)

	self.Entity:SetModel(Model("models/zup/shields/1024_shield.mdl"))
	self.Entity:SetPos(self.Pos)
	self.Entity:SetRenderBounds(Vector(1,1,1)*-1000000, Vector(1,1,1)*1000000)

	--############ This is to set up the angles and radii of the rings
	for i=1,self.Num do
		self.Ang[i] = {}
		-- Start Angles
		self.Ang[i][1] = {	p = math.Rand(-1,1)*180,
					y = math.Rand(-1,1)*180,
		}
		-- Target Angles
		self.Ang[i][2] = {	p = self.Ang[i][1].p+math.Rand(-1,1)*90,
					y = self.Ang[i][1].y+math.Rand(-1,1)*90
		}
		self.Rad[i] = 0
	end
end

function EFFECT:Think()
	if self.Init+self.End < self.Time then return end

	self.Time	= CurTime()
	self.Rel	= self.Time-self.Init

	--############ This is the think for all the rings and radii
	for i=1,self.Num do

		if self.Ang[i][1].p == self.Ang[i][2].p then -- If the pitch reaches the target pitch the set a new one
			self.Ang[i][2].p = self.Ang[i][2].p+math.Rand(-1,1)*180
		else
			self.Ang[i][1].p = math.Approach(self.Ang[i][1].p, self.Ang[i][2].p, 100*FrameTime())
		end

		if self.Ang[i][1].y == self.Ang[i][2].y then -- If the yaw reaches the target yaw the set a new one
			self.Ang[i][2].y = self.Ang[i][2].y+math.Rand(-1,1)*180
		else
			self.Ang[i][1].y = math.Approach(self.Ang[i][1].y, self.Ang[i][2].y, 100*FrameTime())
		end

		self.Rad[i] = math.Clamp((1-3/self.Rel),0,1)*900+math.sin(self.Rel+i)*150
	end

	self.Rad[self.Num+1] = math.Clamp((1-4/self.Rel),0,1)*300/1024

	return true
end

function EFFECT:Render()

	if StarGate.VisualsWeapons("cl_dakara_refract") then
		local mat = Matrix()
		mat:Scale(Vector(1,1,1)*self.Rad[self.Num+1]*6)
		self.Entity:EnableMatrix( "RenderMultiply", mat )
		self.Entity:DrawModel()
	end

	if not StarGate.VisualsWeapons("cl_dakara_rings") then return end

	for i=1,self.Num do
		render.SetMaterial(matBeam)
		render.StartBeam(20)

		local up = Angle(self.Ang[i][1].p, self.Ang[i][1].y,0):Up()
		local ri = Angle(self.Ang[i][1].p, self.Ang[i][1].y,0):Right()
		local point = ri*self.Rad[i]
		self:EmitPart(point)

		render.AddBeam(self.Pos+point, 32, 1, Color(255,255,255,255))

		for k=1,18 do
			local Angle = k*math.pi/9
			point = (math.cos(Angle)*ri+math.sin(Angle)*up)*self.Rad[i]
			self:EmitPart(point)

			render.AddBeam(self.Pos+point, 32, 1, Color(255,255,255,255))
		end

		render.AddBeam(self.Pos+ri*self.Rad[i], 32, 1, Color(255,255,255,255))
		render.EndBeam()
	end
end

function EFFECT:EmitPart(pos)
	local part = self.Emit:Add("particle/MultiPurpose02",self.Pos+pos)

	if part then
		part:SetVelocity(Vector(0,0,0))
		part:SetDieTime(2)
		part:SetStartSize(15)
		part:SetEndSize(0)
		part:SetStartAlpha(255)
		part:SetEndAlpha(0)
		part:SetGravity(-1*pos)
		part:SetColor(150,150,255,255)
	end
end