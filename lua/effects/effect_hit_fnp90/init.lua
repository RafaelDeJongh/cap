function EFFECT:Init( data )

	local vOffset = data:GetOrigin()

	local emitter = ParticleEmitter( vOffset )

		for i = 0,3 do
			local particle = emitter:Add( "particle/particle_smokegrenade", vOffset )

				particle:SetVelocity( 200 * i * data:GetNormal() + 8 * VectorRand() )
				particle:SetAirResistance(400)

				particle:SetDieTime( math.Rand( 0.5, 1.0 ) )

				particle:SetStartAlpha( math.Rand( 50, 150 ) )
				particle:SetEndAlpha( math.Rand( 0, 5 ) )

				particle:SetStartSize( math.Rand( 5, 9 ) )
				particle:SetEndSize( math.Rand( 35, 55 ) )

				particle:SetRoll( math.Rand( -25, 25 ) )
				particle:SetRollDelta( math.Rand( -0.05, 0.05 ) )

				particle:SetColor(120, 120, 120)
		end

		for i=1,2 do
			local particle = emitter:Add( "effects/muzzleflash"..math.random(1,4), vOffset )

				particle:SetVelocity( 100 * data:GetNormal() )
				particle:SetAirResistance( 200 )

				particle:SetDieTime( 0.18 )

				particle:SetStartAlpha( 160 )
				particle:SetEndAlpha( 0 )

				particle:SetStartSize( 3 * i )
				particle:SetEndSize( 1 * i )

				particle:SetRoll( math.Rand(180,480) )
				particle:SetRollDelta( math.Rand(-1,1) )

				particle:SetColor(255,255,255)
		end

			/*local particle = emitter:Add( "sprites/heatwave", vOffset )

				particle:SetVelocity( 80 * data:GetNormal() + 20 * VectorRand() )
				particle:SetAirResistance( 200 )

				particle:SetDieTime( math.Rand(0.2, 0.25) )

				particle:SetStartSize( math.random(15,20) )
				particle:SetEndSize( 3 )


				particle:SetRoll( math.Rand(180,480) )
				particle:SetRollDelta( math.Rand(-1,1) )*/

	emitter:Finish()
end

function EFFECT:Think( )

	return false
end

function EFFECT:Render()

end