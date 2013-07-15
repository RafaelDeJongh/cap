function ENT:FireDrone()

	if ((self.lastswitch*4)+2<(CurTime()*4) and self.Cloak == nil) then
		self.lastswitch=CurTime()
		if(self.WepPods) then
			if(((self.On)==1 )and(self.DronePropsMade)) then
				if(IsValid(self.DroneProp4)) then
					self.On=2
					self:LoadDrones(self.DroneProp4:GetPos())
					self.DroneProp4:Remove()
					self.DroneProp4Fired=true
				end
			elseif((self.On==2)) then
				if(IsValid(self.DroneProp3)) then
					self:LoadDrones(self.DroneProp3:GetPos())
					self.On=3
					self.DroneProp3:Remove()
					self.DroneProp3Fired=true
				end
			elseif(self.On==3) then
				if(IsValid(self.DroneProp1)) then
					self:LoadDrones(self.DroneProp1:GetPos())
					self.On=4
					self.DroneProp1:Remove()
					self.DroneProp1Fired=true
				end
			elseif(self.On==4) then
				if(IsValid(self.DroneProp2)) then
					self:LoadDrones(self.DroneProp2:GetPos())
					self.On=5
					self.DroneProp2:Remove()
					self.DroneProp2Fired=true
				end
			elseif(self.On==5) then
				if(IsValid(self.DroneProp6)) then
					self:LoadDrones(self.DroneProp6:GetPos())
					self.On=6
					self.DroneProp6:Remove()
					self.DroneProp6Fired=true
				end
			elseif(self.On==6) then
				if(IsValid(self.DroneProp5)) then
					self:LoadDrones(self.DroneProp5:GetPos())
					self.On=1
					self.FinalDrone=true
					self.DroneProp5:Remove()
					self.DroneProp5Fired=true
				end
				self.DronePropsMade=false
			end
		end
	end
end

function ENT:LoadDrones(offset) --######### @ LightDemon,RononDex

	if(not(self.Cloaked))then -- Cant fire when cloaked
		if(self.epodo)then -- Only when pods are open
			if(self.CanShoot)then -- only if were not damaged critically
				if self.DroneCount < self.MaxDrones then
					local pos = self:GetPos()+self:GetForward()*-50+self:GetUp()*-55
					local vel = self:GetVelocity()
					--calculate the drone's position offset. Otherwise it might collide with the launcher
					local e = ents.Create("drone")
					e.Parent = self
					e:SetPos(offset)
					e:SetAngles(self:GetForward():Angle()+Angle(math.random(-2,2),math.random(-2,2),math.random(-2,2)))
					e:SetOwner(self) -- Don't collide with this thing here please
					e.Owner = self.Owner
					e:Spawn()
					e:SetVelocity(vel)
					self:EmitSound(self.Sounds.Drone,100,math.random(85,120))
					self.DroneCount = self.DroneCount + 1
					self.Drones[e] = true
					-- This is necessary to make the drone not collide and explode with the Jumper when it's moving
					e.CurrentVelocity = math.Clamp(vel:Length(),0,self.DroneMaxSpeed-500)+500
					e.CannonVeloctiy = vel
					self.Drone = e
				end
			end
		end
	end
end

function ENT:RemoveDrones()

	if(self.DronePropsMade) then
		if(IsValid(self.DroneProp1)) then
			self.DroneProp1:Remove()
		end
		if(IsValid(self.DroneProp2)) then
			self.DroneProp2:Remove()
		end
		if(IsValid(self.DroneProp3)) then
			self.DroneProp3:Remove()
		end
		if(IsValid(self.DroneProp4)) then
			self.DroneProp4:Remove()
		end
		if(IsValid(self.DroneProp5)) then
			self.DroneProp5:Remove()
		end
		if(IsValid(self.DroneProp6)) then
			self.DroneProp6:Remove()
		end
	end
	self.DronePropsMade=false
end
--######## The drones you see in the pods @RononDex
function ENT:SpawnDroneProps()

	local pos = self:GetPos()+self:GetForward()*-50+self:GetUp()*-55

	if(self.DroneCount<6) then
		if(not(self.DroneProp1Fired)) then
			local e = ents.Create("prop_physics")
			e:SetModel("models/Zup/Drone/drone.mdl")
			e:SetPos(pos+self:GetRight()*-97.5+self:GetUp()*21.25+self:GetForward()*50)
			e:SetAngles(self:GetAngles())
			e:SetParent(self)
			e:SetOwner(self)
			e:Spawn()
			e:Activate()
			constraint.Weld(e,self,0,0,0,true)
			self.DroneProp1=e
			self.DroneProp1Fired=false
		end
	end

	if(self.DroneCount<5) then
		if(not(self.DroneProp2Fired)) then
			local e2 = ents.Create("prop_physics")
			e2:SetModel("models/Zup/Drone/drone.mdl")
			e2:SetPos(pos+self:GetRight()*97.5+self:GetUp()*21.25+self:GetForward()*50)
			e2:SetAngles(self:GetAngles())
			e2:SetParent(self)
			e2:SetOwner(self)
			e2:Spawn()
			e2:Activate()
			constraint.Weld(e2,self,0,0,0,true)
			self.DroneProp2=e2
			self.DroneProp2Fired=false
		end
	end

	if(self.DroneCount<4) then
		if(not(self.DroneProp3Fired)) then
			local e3 = ents.Create("prop_physics")
			e3:SetModel("models/Zup/Drone/drone.mdl")
			e3:SetPos(pos+self:GetRight()*105+self:GetUp()*35.25+self:GetForward()*50)
			e3:SetAngles(self:GetAngles())
			e3:SetParent(self)
			e3:SetOwner(self)
			e3:Spawn()
			e3:Activate()
			constraint.Weld(e3,self,0,0,0,true)
			self.DroneProp3=e3
			self.DroneProp3Fired=false
		end
	end

	if(self.DroneCount<3) then
		if(not(self.DroneProp4Fired)) then
			local e4 = ents.Create("prop_physics")
			e4:SetModel("models/Zup/Drone/drone.mdl")
			e4:SetPos(pos+self:GetRight()*-105+self:GetUp()*35.25+self:GetForward()*50)
			e4:SetAngles(self:GetAngles())
			e4:SetParent(self)
			e4:SetOwner(self)
			e4:Spawn()
			e4:Activate()
			constraint.Weld(e4,self,0,0,0,true)
			self.DroneProp4=e4
			self.DroneProp4Fired=false
		end
	end

	if(self.DroneCount<2) then
		if(not(self.DroneProp5Fired)) then
			local e5 = ents.Create("prop_physics")
			e5:SetModel("models/Zup/Drone/drone.mdl")
			e5:SetPos(pos+self:GetRight()*95.5+self:GetUp()*9.25+self:GetForward()*50)
			e5:SetAngles(self:GetAngles())
			e5:SetParent(self)
			e5:SetOwner(self)
			e5:Spawn()
			e5:Activate()
			constraint.Weld(e5,self,0,0,0,true)
			self.DroneProp5=e5
			self.DroneProp5Fired=false
		end
	end

	if(self.DroneCount<1) then
		if(not(self.DroneProp6Fired)) then
			local e6 = ents.Create("prop_physics")
			e6:SetModel("models/Zup/Drone/drone.mdl")
			e6:SetPos(pos+self:GetRight()*-95.5+self:GetUp()*9.25+self:GetForward()*50)
			e6:SetAngles(self:GetAngles())
			e6:SetParent(self)
			e6:SetOwner(self)
			e6:Spawn()
			e6:Activate()
			constraint.Weld(e6,self,0,0,0,true)
			self.DroneProp6=e6
			self.DroneProp6Fired=false
		end
	end
	self.DronePropsMade=true
end
