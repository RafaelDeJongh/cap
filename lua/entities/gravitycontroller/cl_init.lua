include('shared.lua')

function ENT:Initialize()
	self.Glow = Material("sprites/light_glow02_add")
end

function ENT:Draw()
	local drawsprite = self:GetNetworkedBool("drawsprite")
	self.Entity:DrawModel()
	if drawsprite then
		local vel = self.Entity:GetVelocity():Length()
		local rad = self.Entity:BoundingRadius()
		local pos = (self.Entity:GetPos() --[[+ self.Entity:GetUp()*rad/2]])
		vel = vel / 700 + 0.2
		if vel > 1 then vel = 1 end
		render.SetMaterial(self.Glow)
		local color = Color(70*vel, 180*vel, 255*vel, 255)
		render.DrawSprite(pos, rad*2, rad*2, color)
		render.DrawSprite(pos, rad*3, rad*3, color)
		render.DrawSprite(pos, rad*4, rad*4, color)
	end
end
