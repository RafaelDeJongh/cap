local mat = Material("refract_ring")
mat:SetInt("$nocull", 1)

function EFFECT:Init(data)
	self.Entity1 	= data:GetEntity()
	self.StartPos 	= StarGate.GetEntityCentre(self.Entity1)

	local pos	= data:GetOrigin()
	self.Aim	= (pos-self.StartPos):GetNormal()
	self.Pos	= self.Aim*0.7
	self.Pos.x	= self.Pos.x*0.5
	self.Pos.y	= self.Pos.y*0.5
	self.Pos	= self.Pos+self.StartPos

	self.Entity:SetModel(Model("models/zup/shields/200_shield.mdl"))
	local mat = Matrix()
	mat:Scale(Vector(0.5,0.5,1)*0.6)
	self.Entity:EnableMatrix( "RenderMultiply", mat )
	self.Entity:SetPos(self.StartPos)
	self.Entity:SetRenderBounds(Vector(1,1,1)*-10000, Vector(1,1,1)*10000)

	self.Init	= CurTime()
	self.Time	= self.Init
	self.Rel	= 0
end

function EFFECT:Think()
	if self.Rel > 0.5 then return end

	self.Time = CurTime()
	self.Rel = self.Time-self.Init
	self.StartPos = StarGate.GetEntityCentre(self.Entity1)
	self.Entity:SetPos(self.StartPos)

	return true
end

function EFFECT:Render()

	local mul = math.sin(self.Rel*3)

	render.SetMaterial(mat)
	mat:SetFloat("$refractamount", mul*0.2)

	render.DrawQuadEasy(self.Pos,self.Aim,mul*50,mul*50)

	self.Entity:DrawModel()
end
