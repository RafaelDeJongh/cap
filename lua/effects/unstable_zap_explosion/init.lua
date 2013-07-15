local Emit = ParticleEmitter(Vector())

function EFFECT:Init(data)

	self.Pos = data:GetOrigin()

	for i=0, 20 do

		part1 = Emit:Add("particle/particle_smokegrenade", self.Pos)

		if (part1) then
			part1:SetVelocity(VectorRand()*1500)
			part1:SetLifeTime(0)
			part1:SetDieTime(0.75)
			part1:SetStartAlpha(0)
			part1:SetEndAlpha(0)
			part1:SetStartSize(5)
			part1:SetEndSize(5)
			part1:SetColor(0,0,0)
			part1:SetAirResistance(120)
			part1:SetGravity(Vector(0, 0, -1000))
			part1:SetCollide(true)
			part1:SetBounce(0.5)
			part1:SetThinkFunction(PartThink)
			part1:SetNextThink(CurTime() + 0.1)
		end
	end

	for i= 0,15 do

		part2 = Emit:Add("particles/smokey", self.Pos)

		if (part2) then
			part2:SetVelocity(VectorRand()*1200)
			part2:SetLifeTime(0)
			part2:SetDieTime(6)
			part2:SetStartAlpha(250)
			part2:SetEndAlpha(0)
			part2:SetStartSize(200)
			part2:SetEndSize(250)
			part2:SetColor(150,150,140)
			part2:SetAirResistance(250)
			part2:SetGravity(Vector(100, 100, -80))
			part2:SetLighting(true)
			part2:SetCollide(false)
			part2:SetBounce(0)
		end
	end
end

function EFFECT:Think()
	return false
end

function PartThink(part)

	if part:GetLifeTime() > 0.18 then

		local Pos = part:GetPos()
		local Life = part:GetLifeTime()

		if Emit == nil then return end

		local part3 = Emit:Add("particles/smokey", Pos)

		if (part3) then
			part3:SetVelocity(Vector(0,0,0))
			part3:SetLifeTime(0)
			part3:SetDieTime(Life+5.25)
			part3:SetStartAlpha(150)
			part3:SetEndAlpha(0)
			part3:SetStartSize(45-Life*50)
			part3:SetEndSize(100-Life*100)
			part3:SetColor(150,150,140)
			part3:SetAirResistance(250)
			part3:SetGravity(Vector(100,100,-80))
			part3:SetLighting(true)
			part3:SetCollide(true)
			part3:SetBounce(0.5)

		end
	end

	part:SetNextThink(CurTime() + 0.1)
end

function EFFECT:Render()
end
