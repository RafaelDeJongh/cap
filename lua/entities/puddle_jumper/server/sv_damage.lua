function ENT:DoKill(ply)   --######### @ RononDex

	self.Done=true
	local velocity = self:GetForward()

	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetStart(self:GetUp())
	util.Effect( "dirtyxplo", effectdata )

	self:EmitSound(self.Sounds.Explosion, 100, 100)

	for k,v in pairs(self.Gibs) do
		local model = v
		local k = ents.Create("prop_physics")
		k:SetPos(self:GetPos())
		k:SetAngles(self:GetAngles())
		k:SetModel(model)
		k:PhysicsInit( SOLID_VPHYSICS )
		k:SetMoveType( MOVETYPE_VPHYSICS )
		k:SetSolid( SOLID_VPHYSICS )
		k:SetCollisionGroup( COLLISION_GROUP_WORLD )
		k:Activate()
		k:Spawn()
		k:Ignite(8.5,0)
		k:GetPhysicsObject():SetVelocity(velocity*1000 + VectorRand()*40000)
		k:GetPhysicsObject():ApplyForceCenter(velocity*1000 +VectorRand()*40000)
		k:SetColor(Color(255,255,255,math.Approach(255,0,15)))
		k:Fire("Kill", "", 10)
	end

	if(IsValid(self)) then
		if(self.Inflight) then
			self:ExitJumper(self.Pilot)
			if(self.Done) then
				if(IsValid(self.Pilot)) then
					self.Pilot:Kill()
				end
			end
		end
	end
	self.Done=true
	self:Remove()
end

--######## Make sure we take damage from energy shots @RononDex
function ENT:Touch(e)

	if(IsValid(e)) then
		if(e:GetClass()=="staff_pulse") then self:TakeDamage(150) end
		if(e:GetClass()=="energy_pulse") then self:TakeDamage(150) end
	end
end

--############ What happens when we take damage, what shall happen when we've taken a lot of damage @RononDex
function ENT:OnTakeDamage(dmg)

	if(not(self.Shields:Enabled()) or self.Shields.Depleted) then
		if(not(self.WaterDamage)) then
			--###### The wobble's back
			if(self.Inflight) then
				if(not(self.LiftOff)) then
					if(not(self.CollisionDmg)) then
						if(dmg:GetDamage()>50) then
							self:SetAngles(self:GetAngles()+Angle(-35,15,10))
						end
					end
				end
			end
		end
		--#### Disable systems when damaged
		if(not(self.Done)) then

			self.EntHealth=self.EntHealth-(dmg:GetDamage()/10)

			if((self.EntHealth)<=300) then
				if(self.Cloaked) then
					self:ToggleCloak()
				end
				self.CantCloak=true
				self.CanCloak = false
			end

			if((self.EntHealth)<=250) then
				self.CanShield = false;
				self.Shields.CantBeEnabled = true;
				if(self.Shielded) then
					self:ToggleShield()
				end
			end

			if((self.EntHealth)<=200) then
				self.CanShoot = false
			end

			if((self.EntHealth)<=100) then
				self.Engine=false
			end

			if((self.EntHealth)<=50) then
				self.CanHaveLS=false
				self.Hover=false
			end
		end
	end
end
