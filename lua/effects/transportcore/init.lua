local matLight 		= Material( "sprites/light_ignorez" )

function EFFECT:Init( data )

 	local size = 600
 	self.Entity:SetCollisionBounds( Vector( -size,-size,-size ), Vector( size,size,size ) )

 	self.Pos 	= data:GetOrigin()

 	self.Alpha = 1

	self.Up=true

	self.Number=CurTime()+math.random(100,200)
	if (math.ceil(data:GetMagnitude())==0) then
		self.Atlantis = true;
	end

end

function EFFECT:Think()

 	local dlight = DynamicLight(self.Number)
 	if ( dlight ) then
 		dlight.Pos = self:GetPos()
 		dlight.r = 250
 		dlight.g = 211
 		dlight.b = 169
 		dlight.Brightness = 10
 		dlight.Decay = 5
 		if (self.Atlantis) then
 			dlight.Size = 70
 		else
 			dlight.Size = 150
 		end
 		dlight.DieTime = CurTime() + 1
 	end

 	--local speed = FrameTime()
 	if self.Up then
 		self.Alpha = self.Alpha + 15
		if self.Alpha>350 then
			self.Up=false
		end
 	else
		self.Alpha = self.Alpha - 10
	end
 	if (self.Alpha < 0 ) then return false end
 	return true
end

function EFFECT:Render()
	render.SetMaterial( matLight )
	render.DrawSprite(self.Pos, 600, 600, Color(244,247,172,math.Clamp(self.Alpha,0,255)))
end