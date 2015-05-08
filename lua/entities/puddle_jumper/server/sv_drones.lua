ENT.DronePropFired = {
	D1 = false,
	D2 = false,
	D3 = false,
	D4 = false,
	D5 = false,
	D6 = false,
};

ENT.NextUse.DroneFire = CurTime();
function ENT:FireDrone()

	if ((self.NextUse.DroneFire < CurTime()) and self.Cloak == nil) then
		self.NextUse.DroneFire = CurTime() + 0.5;
		if(self.WepPods) then
			if(((self.On)==1 )and(self.DronePropsMade)) then
				if(IsValid(self.DroneProp4)) then
					self.On=2
					self:LoadDrones(self.DroneProp4:GetPos())
					self.DroneProp4:Remove()
					self.DronePropFired[4]=true
					print("FIRE")
				end
			elseif((self.On==2)) then
				if(IsValid(self.DroneProp3)) then
					self:LoadDrones(self.DroneProp3:GetPos())
					self.On=3
					self.DroneProp3:Remove()
					self.DronePropFired[3]=true
				end
			elseif(self.On==3) then
				if(IsValid(self.DroneProp1)) then
					self:LoadDrones(self.DroneProp1:GetPos())
					self.On=4
					self.DroneProp1:Remove()
					self.DronePropFired[1]=true
				end
			elseif(self.On==4) then
				if(IsValid(self.DroneProp2)) then
					self:LoadDrones(self.DroneProp2:GetPos())
					self.On=5
					self.DroneProp2:Remove()
					self.DronePropFired[2]=true
				end
			elseif(self.On==5) then
				if(IsValid(self.DroneProp6)) then
					self:LoadDrones(self.DroneProp6:GetPos())
					self.On=6
					self.DroneProp6:Remove()
					self.DronePropFired[6]=true
				end
			elseif(self.On==6) then
				if(IsValid(self.DroneProp5)) then
					self:LoadDrones(self.DroneProp5:GetPos())
					self.On=1
					self.FinalDrone=true
					self.DroneProp5:Remove()
					self.DronePropFired[5]=true
				end
				self.DronePropsMade=false
			end
		end
	end
end

function ENT:LoadDrones(offset) --######### @ LightDemon,RononDex

	if(not(self.Cloaked))then -- Cant fire when cloaked
		if(self.epodo)then -- Only when pods are open
			if(self.CanShoot)then -- only if we're not damaged critically
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

function ENT:CreateDrone(pos,n)

	local e = ents.Create("prop_physics");
	e:SetModel("models/Zup/Drone/drone.mdl")
	e:SetPos(pos)
	e:SetAngles(self:GetAngles())
	e:SetParent(self)
	e:SetOwner(self)
	e:Spawn()
	e:Activate()
	constraint.Weld(e,self,0,0,0,true)
	self.DronePropFired[n] = false;
	
	return e;
end

function ENT:SpawnDroneProps()

	local pos = self:GetPos()+self:GetUp()*-55
	local dronePos;
	for i=1,6 do
		if(not(self.DronePropFired[i])) then
			if(i==1) then
				dronePos = pos+self:GetRight()*-97.5+self:GetUp()*21.25;
				self.DroneProp1 = self:CreateDrone(dronePos,i);
			elseif(i==2) then
				dronePos = pos+self:GetRight()*97.5+self:GetUp()*21.25;
				self.DroneProp2 = self:CreateDrone(dronePos,i);
			elseif(i==3) then
				dronePos = pos+self:GetRight()*105+self:GetUp()*35.25;
				self.DroneProp3 = self:CreateDrone(dronePos,i);
			elseif(i==4) then
				dronePos = pos+self:GetRight()*-105+self:GetUp()*35.25;
				self.DroneProp4 = self:CreateDrone(dronePos,i);
			elseif(i==5) then
				dronePos = pos+self:GetRight()*95.5+self:GetUp()*9.25;
				self.DroneProp5 = self:CreateDrone(dronePos,i);
			elseif(i==6) then
				dronePos = pos+self:GetRight()*-95.5+self:GetUp()*9.25;
				self.DroneProp6 = self:CreateDrone(dronePos,i);
			end
		end
	end
	self.DronePropsMade = true;
end
