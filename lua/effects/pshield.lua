local mat = Material( "refract_ring" )
mat:SetInt("$ignorez", 1)

function EFFECT:Init(data)
	self.Entity1 = data:GetEntity()
	self.StartPos = StarGate.GetEntityCentre(self.Entity1)
	self.Engaging = data:GetScale()
	self.Init = CurTime()
	self.Time = self.Init
	self.Rel = 0

	self.Entity:SetModel(Model("models/zup/shields/200_shield.mdl"))
	self.Entity:SetPos(self.StartPos)
	self.Entity:SetRenderBounds(Vector(1,1,1)*-10000, Vector(1,1,1)*10000)
end

function EFFECT:Think()
	if not self.Entity1:IsValid() then return end
	if self.Rel > 1 then return end

	self.StartPos = StarGate.GetEntityCentre(self.Entity1)
	self.Entity:SetPos(self.StartPos)
	self.Time = CurTime()
	self.Rel = self.Time-self.Init

	return true
end

function EFFECT:Render()
	render.SetMaterial(mat)
	mat:SetFloat("$refractamount", math.sin(self.Rel*3)*0.2)

	for i=0,3 do
		local size = math.sin(self.Rel*5+i)*160
		render.DrawSprite(self.StartPos, size*0.5, size)
	end

	local mat = Matrix()
	if self.Engaging == 1 then
		mat:Scale(self.Rel*0.7*Vector(0.5,0.5,1))
	else
		mat:Scale((1-self.Rel)*0.7*Vector(0.5,0.5,1))
	end
	self.Entity:EnableMatrix( "RenderMultiply", mat )

	self.Entity:DrawModel()
end