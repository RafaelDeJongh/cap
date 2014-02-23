local ZAxis = Vector(0,0,1)
local FlightPhys={
	secondstoarrive	= 1,
	maxangular		= 9000,
	maxangulardamp	= 1000,
	maxspeed			= 1000000,
	maxspeeddamp		= 500000, --500000
	dampfactor		= 1,
	teleportdistance	= 5000,
};

ENT.IgnoreCollisionEnts = {
	"worldspawn",
	"stargate_*",
	"dhd_*",
	"prop_physics",
	"puddle_jumper",
	"sg_vehicle_*",
};

function ENT:ShouldIgnoreCollision(e)
	return table.HasValue(self.IgnoreCollisionEnts,e:GetClass())
end

--############## Collison Damage and Vehicle Decelleration on Collision @ WeltEntSturm, RononDex
function ENT:PhysicsCollide(cdat, phys)

	if(not(self.LiftOff)) then

		if(self:ShouldIgnoreCollision(cdat.HitEntity)) then
			local ephys = cdat.HitEntity:GetPhysicsObject();
			self.Accel.FWD = math.Approach(self.Accel.FWD,10,100*((ephys:GetVelocity():Length()+1)/ephys:GetMass()));
			self.CollisionDmg = true;
			timer.Simple(0.75, function()
				self.CollisionDmg = false;
			end);
		end

		if((cdat.DeltaTime)>0.5) then --0.5 seconds delay between taking physics damage
			local mass = (cdat.HitEntity:GetClass() == "worldspawn") and 1000 or cdat.HitObject:GetMass() --if it's worldspawn use 1000 (worldspawns physobj only has mass 1), else normal mass
			self:TakeDamage((cdat.Speed*cdat.Speed*math.Clamp(mass, 0, 1000))/6000000)
		end
	end
end

/*
 --############ After teleporting it, fix the angles of a player @aVoN
function ENT.FixAngles(self,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
	-- Move a players view
	local diff = Angle(0,ang_delta.y+180,0)
	if(IsValid(self.Pilot)) then
		self.Pilot:SetEyeAngles(self.Pilot:GetAimVector():Angle() + diff)
	end
end
StarGate.Teleport:Add("puddle_jumper",ENT.FixAngles)
*/

--######  TO DO: Fix Jumper Angles after teleporting

function ENT:PhysicsSimulate(phys,deltatime)--############## Flight code@ RononDex

	local FWD = self:GetForward()
	local UP = ZAxis
	local RIGHT = FWD:Cross(UP):GetNormalized()

	--########## This automatically closes the door if you fly off from your original position by 200 or 100 units
	if(self.Inflight) then
		if(self.Entered) then
			if(self.door) then
				if((self:GetPos().Z)>self.StartPos.Z+200) then
					self.Entered = false;
					self:ToggleDoor();
				elseif((self:GetPos().Y)>self.StartPos.Y+100) then
					self.Entered = false;
					self:ToggleDoor();
				elseif((self:GetPos().X)>self.StartPos.X+100) then
					self.Entered = false;
					self:ToggleDoor();
				elseif((self:GetPos().Z)<self.StartPos.Z-200) then
					self.Entered = false;
					self:ToggleDoor();
				elseif((self:GetPos().Y)<self.StartPos.Y-100) then
					self.Entered = false;
					self:ToggleDoor();
				elseif((self:GetPos().X)<self.StartPos.X-100) then
					self.Entered = false;
					self:ToggleDoor();
				end
			end
		end
	end

	if(IsValid(self.Pilot)) then
		if(self.Inflight) then

			-- Accelerate
			if(self.Pilot:KeyDown(self.Vehicle,"FWD")) then
				if(self.Engine) then
					if(self.epodo) then
						if(self:WaterLevel()<1) then
							self.num = 1750;
						elseif(self:WaterLevel()>0) then
							if(not self.Shields:Enabled()) then
								self.num = 1125;
							else
								self.num = 1750;
							end
						end
					else
						self.num = 750;
					end
				else
					self.num = 750;
				end
			elseif(self.Pilot:KeyDown(self.Vehicle,"BACK")) then
				self.num = -600;
			else
				self.num = 0;
			end
			self.Accel.FWD=math.Approach(self.Accel.FWD,self.num,6.75)

			-- Strafe
			if(self.Pilot:KeyDown(self.Vehicle,"RIGHT")) then
				self.num2 = 700;
			elseif(self.Pilot:KeyDown(self.Vehicle,"LEFT")) then
				self.num2 = -700;
			else
				self.num2 = 0;
			end
			self.Accel.RIGHT=math.Approach(self.Accel.RIGHT,self.num2,8)

			-- Up and Down
			if(self.Pilot:KeyDown(self.Vehicle,"UP")) then
				self.num3 = 700;
            elseif(self.Pilot:KeyDown(self.Vehicle,"DOWN")) then
				self.num3 = -700;
			else
				self.num3 = 0;
            end
			self.Accel.UP=math.Approach(self.Accel.UP,self.num3,8)

			--Roll
			if(self.Pilot:KeyDown(self.Vehicle,"RL")) then
				self.Roll = self.Roll - 5;
			elseif(self.Pilot:KeyDown(self.Vehicle,"RR")) then
				self.Roll = self.Roll + 5;
			elseif(self.Pilot:KeyDown(self.Vehicle,"RROLL")) then
				self.Roll = 0;
			end

			phys:Wake()
			if(not(self.Hover)) then
				if self.Accel.FWD>-200 and self.Accel.FWD < 200 then return end; --with out this you float
				if self.Accel.UP>-200 and self.Accel.UP < 200 then return end;
				if self.Accel.RIGHT>-200 and self.Accel.RIGHT < 200 then return end;
			end


			local ang = self.Pilot:GetAimVector():Angle();
			local pos = self:GetPos();

			--########## The tilt when you turn @aVoN
			local velocity = self:GetVelocity();
			local aim = self.Pilot:GetAimVector();
			--local ang = aim:Angle();
			local ExtraRoll = math.Clamp(math.deg(math.asin(self:WorldToLocal(pos + aim).y)),-45,45); -- Extra-roll - When you move into curves, make the shuttle do little curves too according to aerodynamic effects
			local mul = math.Clamp((velocity:Length()/1000),0,1); -- More roll, if faster.
			local oldRoll = ang.Roll;
			ang.Roll = (ang.Roll + self.Roll - ExtraRoll*mul) % 360;
			if (ang.Roll!=ang.Roll) then ang.Roll = oldRoll; end -- fix for nan values what cause despawing/crash.

			--########### Calculate our angles and position based on speed
			FlightPhys.pos = pos+(FWD*self.Accel.FWD)+(UP*self.Accel.UP)+(RIGHT*self.Accel.RIGHT);
			FlightPhys.angle = ang; --+ Vector(90 0, 0)
			FlightPhys.deltatime		= deltatime;

			self.Pilot:SetPos(pos);

			phys:ComputeShadowControl(FlightPhys);


		end
	end
	if (not self.Inflight and self.HoverAlways) then
		phys:Wake();
		FlightPhys.angle = Angle(0, self:GetAngles().y, 0);
		FlightPhys.deltatime = deltatime;
		FlightPhys.pos = self.HoverPos;
		phys:ComputeShadowControl(FlightPhys);
	end
end