

local matRefract = Material( "models/spawn_effect" )
local matLight	 = Material( "models/spawn_effect2" )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )

	// This is how long the spawn effect
	// takes from start to finish.
	self.Time = 1.5
	self.LifeTime = CurTime() + self.Time

	local ent = data:GetEntity()
	if ( ent == NULL ) then return end



	self.ParentEntity = ent
	self:SetModel( ent:GetModel() )
	self:SetPos( ent:GetPos() )
	self:SetAngles( ent:GetAngles() )
	self:SetParent( ent )

end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	if (!self.ParentEntity || !self.ParentEntity:IsValid()) then return false end

	local PPos = self.ParentEntity:GetPos();
	self:SetPos( PPos + (EyePos() - PPos):GetNormal() )

	return ( self.LifeTime > CurTime() )

end



/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	// What fraction towards finishing are we at
	local Fraction = (self.LifeTime - CurTime()) / self.Time
	local ColFrac = (Fraction-0.5) * 2

	Fraction = math.Clamp( Fraction, 0, 1 )
	ColFrac =  math.Clamp( ColFrac, 0, 1 )

	// Change our model's alpha so the texture will fade out
	self:SetColor( Color(255, 255, 255, 1 + 254 * (ColFrac)) )

	// Place the camera a tiny bit closer to the entity.
	// It will draw a big bigger and we will skip any z buffer problems
	local EyeNormal = self:GetPos() - EyePos()
	local Distance = EyeNormal:Length()
	EyeNormal:Normalize()

	local Pos = EyePos() + EyeNormal * Distance * 0.01

	// Start the new 3d camera position
	cam.Start3D( Pos, EyeAngles() )

		// Draw our model with the Light material
		// This is the underlying blue effect and it doubles as the DX7 only effect
		if ( ColFrac > 0 ) then

			render.MaterialOverride( matLight )
				self:DrawModel()
			render.MaterialOverride( 0 )

		end

		// If our card is DX8 or above draw the refraction effect
		if ( render.GetDXLevel() >= 80 ) then

			// Update the refraction texture with whatever is drawn right now
			render.UpdateRefractTexture()

			matRefract:SetFloat( "$refractamount", Fraction * 0.1 )
			// Draw model with refraction texture
			render.MaterialOverride( matRefract )
				self:DrawModel()
			render.MaterialOverride( 0 )

		end

	// Set the camera back to how it was
	cam.End3D()

end



