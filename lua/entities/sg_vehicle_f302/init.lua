--[[
	F302 for GarrysMod 10
	Copyright (C) 2009-2010 RononDex

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

local COCKPIT_POS = Vector(141.6306, 1.0832, -17.1564);



ENT.Model = Model("models/Madman07/F302/body.mdl");
ENT.Gibs = true;
ENT.GibTable = {
	Cockpit=Model("models/Madman07/F302/cocpit.mdl"),
	Rocket=Model("models/Madman07/F302/missile.mdl"),
	Seat1=Model("models/Madman07/F302/seat1.mdl"),
	Seat2=Model("models/Madman07/F302/seat2.mdl"),
	Wheels=Model("models/Madman07/F302/wheels.mdl"),
};

ENT.F302=true -- Needed for the turrets, as i use the turrets for the destiny shuttle aswell but just change the effect

ENT.Sounds = {
	Startup = Sound("f302/f302_startup.wav");
	Fly = Sound("f302/f302_Engine.wav");
	Missile = Sound("f302/Missile_Shoot_Small.wav");
	Stop = Sound("JetStop.wav");
};

function ENT:SpawnFunction(p, tr) --######## Pretty useless unless we can spawn it @RononDex
	if (!tr.HitWorld) then return end;

	local PropLimit = GetConVar("CAP_ships_max"):GetInt()
	if(p:GetCount("CAP_ships")+1 > PropLimit) then
		p:SendLua("GAMEMODE:AddNotify(\"Ships limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local e = ents.Create("sg_vehicle_f302");
	e:SetPos(tr.HitPos + Vector(0,0,115));
	e:SetAngles(Angle(0,p:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	e:CockpitSpawn(p) -- Spawn the cockpit
	e:SpawnSeats(p); -- Spawn the seats
	e:SpawnRocketClamps(nil,p); -- Spawn the rocket clamps
	e:SpawnMissile(p); -- Spawn the missile props
	e:Turrets(p); -- Spawn turrets
	e:SpawnWheels(nil,p);
	e:SetWire("Health",e:GetNetworkedInt("health"));
	p:AddCount("CAP_ships", e)
	return e;
end

function ENT:HangarSpawn(p)
	self:CockpitSpawn(p) -- Spawn the cockpit
	self:SpawnSeats(p); -- Spawn the seats
	self:SpawnRocketClamps(nil,p); -- Spawn the rocket clamps
	self:SpawnMissile(p); -- Spawn the missile props
	self:Turrets(p); -- Spawn turrets
	self:SpawnWheels(nil,p);
end

function ENT:Initialize() --######## What happens when it first spawns(Set Model, Physics etc.) @RononDex

	self:SetModel(self.Model);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetNetworkedInt("health",500);

	self.Roll = 0;
	self.On = 0;
	self:SetUseType(SIMPLE_USE);
	self.Vehicle = "F302";
	self.WeaponType = "Turrets";
	self.CanUse = false;
	self.Liftoff = true;
	self:StartMotionController();

	self.BaseClass.Initialize(self);

	self.CanBoost = true;

	self.NextUse = {
		Boost = CurTime(),
		Brake = CurTime(),
		Use = CurTime(),
		Wheels = CurTime(),
		Change = CurTime(),
		Cockpit = CurTime(),
	}

	--######## Weapon Vars
	self.Bullets = true;
	self.TrackTime = 1000000;
	self.MissileMaxVel=10000000;
	self.Missiles = {};
	self.MissileCount = 0;
	self.MaxMissiles = (4);
	self.MissilesFired=0;
	self:CreateWireInputs("X","Y","Z");
	self.Target = Vector(0,0,0);
	self.NextFire = CurTime();

	--######### Flight Vars
	self.Accel = {};
	self.Accel.FWD = 0;
	self.Accel.RIGHT = 0;
	self.Accel.UP = 0;
	self.ForwardSpeed = 1500;
	self.BackwardSpeed = 0;
	self.UpSpeed = 0;
	self.MaxSpeed = 2500;
	self.RightSpeed = 0;
	self.Accel.SpeedForward = 7;
	self.Accel.SpeedRight = 0;
	self.Accel.SpeedUp = 0;
	self.RollSpeed = 5;
	self.Hover = false; -- F302's don't hover...
	self.GoesRight = false;
	self.GoesUp = false;
	self.CanRoll = true;
	self:CreateWireOutputs("Health");

	self.ShouldRotorwash = true;

	self.Phys = self:GetPhysicsObject()
	if(self.Phys:IsValid()) then
		self.Phys:Wake();
		self.Phys:SetMass(400);
	end
end

function ENT:Bang()

	self.BaseClass.Bang(self)

	local velocity = self:GetVelocity()
	for k,v in pairs(self.GibTable) do
		local model = v
		local k = ents.Create("prop_physics");
		k:SetPos(self:GetPos())
		k:SetAngles(self:GetAngles());
		k:SetModel( model );
		k:PhysicsInit( SOLID_VPHYSICS );
		k:SetMoveType( MOVETYPE_VPHYSICS );
		k:SetSolid( SOLID_VPHYSICS );
		k:SetCollisionGroup( COLLISION_GROUP_WORLD );
		k:Activate();
		k:Spawn();
		k:GetPhysicsObject():SetVelocity(velocity*1000 + VectorRand()*40000);
		k:GetPhysicsObject():ApplyForceCenter(velocity*1000 +VectorRand()*40000);
		k:Fire("Kill", "", 10);
	end
end

function ENT:OnTakeDamage(dmg) --########## F302's aren't invincible are they? @RononDex

	local health=self:GetNetworkedInt("health")-(dmg:GetDamage()/5);
	self:SetNetworkedInt("health",health); -- Sets heath(Takes away damage from health)
	self:SetWire("Health",health);

	if((health)<=250) then
		self.MissileDisable = true; -- Disable Missiles
		self.Bullets = true;
	end

	if((health)<=200) then
		self.TurretDisabled = true; -- Disable Turrets
	end

	if((health)<=125) then
		self.EngineDamaged = true;
		self.ForwardSpeed = 0;

		self.MaxSpeed = 0;
	end

	if((health)<=0) then
		self:Bang(); -- Go boom
	end
end

function ENT:OnRemove()

	self.BaseClass.OnRemove(self);
	if (IsValid(self.Turret)) then
		self.Turret.Firing = false;
	end
	if (IsValid(self.Turret2)) then
		self.Turret2.Firing = false;
	end
	if (IsValid(self.Wheels)) then
		self.Wheels:Remove();
	end
	if (IsValid(self.Cockpit)) then
		self.Cockpit:Remove();
	end
	if (IsValid(self.CockpitAnim)) then
		self.CockpitAnim:Remove();
	end
	if (IsValid(self.RocketClamps)) then
		self.RocketClamps:Remove();
	end
	if (IsValid(self.WheelsAnim)) then
		self.WheelsAnim:Remove();
	end

end

function ENT:Use(p)

	self.BaseClass.Use(self,p);
	if(self.Inflight) then return end;

	local pos = self:WorldToLocal(p:GetPos()) - COCKPIT_POS;

	if self.NextUse.Use < CurTime() then
		if((pos.x>-100 and pos.x<100)and(pos.y>-120 and pos.y<120)and(pos.z>-100 and pos.z<100)) then
			if(not(self.CockpitOpen)) then
				if (IsValid(self.CockpitAnim)) then
					self:ToggleCockpit()
				end
			else
				self.CanUse = true;
				self:Enter(p)
			end
		else
			self.CanUse = false;
			self:ToggleCockpit()
		end
		self.NextUse.Use = CurTime() + 1;
	end
end

function ENT:ToggleCockpit()
	if(self.NextUse.Cockpit < CurTime()) then
		if (IsValid(self.CockpitAnim)) then
			if(not(self.CockpitOpen)) then
				self.CockpitAnim:Fire("setanimation","open","0")
				timer.Simple(1, function() if(IsValid(self)) then self.CockpitOpen = true; end end)
				self.Cockpit.CollisionGroup = self.Cockpit:GetCollisionGroup();
				self.Cockpit:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE);
			else
				self.CockpitAnim:Fire("setanimation","close","0")
				timer.Simple(1, function() if(IsValid(self)) then self.CockpitOpen = false; end end)
				if (self.Cockpit.CollisionGroup) then self.Cockpit:SetCollisionGroup(self.Cockpit.CollisionGroup); end
			end
		end
		self.NextUse.Cockpit = CurTime() + 1;
	end
end


function ENT:Enter(p)

	self.BaseClass.Enter(self,p);
	self.CanUse = false;
	if(self.CockpitOpen and IsValid(self.CockpitAnim)) then
		self:ToggleCockpit();
	end
	self.CockpitOpen = false;

end

function ENT:Exit(kill)

	self.BaseClass.Exit(self,kill);
	if(not self.CockpitOpen) then
		self:ToggleCockpit();
	end

end

function ENT:Think() --####### Now let me think... @RononDex

	self.ExitPos = self:GetPos()+self:GetForward()*100+self:GetRight()*-100+self:GetUp()*25

	if(self:WaterLevel() > 0) then
		self.ForwardSpeed = 0;
		self.MaxSpeed = 0;
	else
		if(not(self.EngineDamaged)) then
			self.ForwardSpeed = 1500;
			self.MaxSpeed = 2500;
		end
	end


	if (IsValid(self.Pilot)) then
		umsg.Start("302Data", self.Pilot);
			umsg.Short(self.MissileCount);
			umsg.Bool(self.MissileDisable);
			umsg.Bool(self.TurretDisabled);
			umsg.Bool(self.EngineDamaged);
			umsg.String(self.WeaponType);
		umsg.End();
	else
		if (IsValid(self.Turret)) then
			self.Turret.Firing = false;
		end
		if (IsValid(self.Turret2)) then
			self.Turret2.Firing = false;
		end
	end

	self.BaseClass.Think(self);

	if(IsValid(self.Pilot) and self.Bullets and not self.Missile) then
		if(self.Inflight and IsValid(self.Turret) and IsValid(self.Turret2)) then
			if((self.Pilot:KeyDown(self.Vehicle,"FIRE"))and(not(self.TurretDisabled))) then
				self.Turret.Firing = true;
				self.Turret2.Firing = true;
			else
				self.Turret.Firing = false;
				self.Turret2.Firing = false;
			end
		end
	end

	if self.Inflight then
		if IsValid(self.Pilot) then
			if self.Pilot:KeyDown(self.Vehicle,"BOOST") then
				if self.NextUse.Boost < CurTime() then
					if not self.Boost and self.CanBoost then
						self.Boost = true;
						self.CanBoost = false;
						self:SetNWBool("Boost",true);
						timer.Simple(5, function()
							self.Boost = false;
							self:SetNWBool("Boost",false);
						end);
						timer.Simple(30, function()
							self.CanBoost = true;
						end);
					end
					self.NextUse.Boost = CurTime() + 1;
				end
			end
		end
	end


	if(self.Inflight) then
		if(IsValid(self.Pilot) and self.Pilot:KeyDown(self.Vehicle,"FIRE") and self.Missile) then
			if(self.NextFire < CurTime()) then
				self:FireMissiles()
				self.NextFire = CurTime()+0.5;
			end
		end
	end

	if(self.MissileCount==0) then
		if(IsValid(self)) then
			if(not(self.MissileMade)) then
				self:SpawnMissile();
			end
		end
	end

	if(self.Inflight and IsValid(self.Pilot)) then
		if(self.Pilot:KeyDown(self.Vehicle,"CHGATK") and self.NextUse.Change < CurTime()) then
			if(not(self.Bullets)and(self.Missile)) then
				if not self.TurretDisabled then
					self.Bullets = true;
					self.WeaponType = "Turrets";
					self.Missile = false;
				end
			else
				if(not(self.MissileDisable)) then
					if(IsValid(self.Turret) and self.Turret.Firing) then return end;
					self.Bullets = false;
					self.WeaponType = "Missiles";
					self.Missile = true;
				end
			end
			self.NextUse.Change = CurTime() + 1;
		end

		if(self.Pilot:KeyDown(self.Vehicle,"TRACK")) then
			self.Track = true;
		else
			self.Track = false;
		end

		if(self.Pilot:KeyDown(self.Vehicle,"WHEELS") and self.Wheels.CanDoAnim and self.NextUse.Wheels < CurTime()) then
			self:ToggleWheels();
			self.NextUse.Wheels = CurTime() + 1;
		end

		if(self.Pilot:KeyDown(self.Vehicle,"EJECT")) then
			self:EjectorSeat();
		end
		
		if(not(self.PoppedFlares) and IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(self.Vehicle,"FLARES")) then
				self:Flares();
			end
		end
		if(self.Accel.FWD > 200) then
			if(self.CockpitOpen) then
				self:ToggleCockpit();
			end
		else
			if(IsValid(self.Pilot) and self.Pilot:KeyDown(self.Vehicle,"COCKPIT")) then
				self:ToggleCockpit();
			end
		end
	end

	if self.Inflight then
		self:NextThink(CurTime());
		return true;
	end

end

function ENT:FireMissiles()

	if((self.Missile)and((self.MissileCount)<4)) then
		if(self.Inflight) then
			if(not(self.MissileDisable)) then
				if((self.MissileCount) < (self.MaxMissiles) and self.MissileMade) then
					if(self.On==0) then
						self.On = 1;
						if (IsValid(self.M1)) then
							self:FireMissile(self.M1:GetPos());
							if((self.M1)and(self.M1:IsValid())) then
								self.M1:Remove();
							end
						end
					elseif(self.On==1) then
						self.On = 2;
						if (IsValid(self.M2)) then
							self:FireMissile(self.M2:GetPos());
							if((self.M2)and(self.M2:IsValid())) then
								self.M2:Remove();
							end
						end
					elseif(self.On==2) then
						self.On = 3;
						if (IsValid(self.M3)) then
							self:FireMissile(self.M3:GetPos());
							if((self.M3)and(self.M3:IsValid())) then
								self.M3:Remove();
							end
						end
					elseif(self.On==3) then
						self.On = 0;
						if (IsValid(self.M4)) then
							self:FireMissile(self.M4:GetPos());
							if((self.M4)and(self.M4:IsValid())) then
								self.M4:Remove();
							end
						end
						self.MissileMade = false;
					end
				end
			end
		end
	end
end

--######### Pop some flares to stop being destroyed @RononDex
function ENT:Flares()

	local e = ents.Create("prop_physics")
	e:SetModel("models/props_junk/PopCan01a.mdl")
	e:SetPos(self:GetPos()+self:GetForward()*-1250)
	e:Spawn()
	e:Activate()
	e:GetPhysicsObject():EnableMotion(false)

	local fx = EffectData()
		fx:SetOrigin(e:GetPos())
	util.Effect("RPGShotDown",fx)

	for _,v in pairs(ents.FindInSphere(e:GetPos(),1500)) do
		if(IsValid(v)) then
			if(v:GetClass()==("drone" or "302missile")) then
				local FX = EffectData()
					FX:SetOrigin(v:GetPos())
				util.Effect("dirtyxplo",FX)
				v:EmitSound("jumper/JumperExplosion.mp3",100,math.random(90,110))
				v:Remove()
			end
		end
	end
	self.PoppedFlares = true;
	e:Remove()
	timer.Simple(3, function()
		self.PoppedFlares = false;
	end);
end

function ENT:ToggleWheels()

	if(self.WheelsOpen) then
		self.WheelsAnim:Fire("setanimation","close","0")
		self.WheelsOpen = false;
		self.WheelPhys:EnableCollisions(false);
		self.WheelPhys:SetMass(1);
		self.Phys:SetMass(10000);
		self.Wheels:SetParent(self);
	else
		self.WheelsAnim:Fire("setanimation","open","0")
		self.WheelsOpen = true;
		self.WheelPhys:EnableCollisions(true);
		self.WheelPhys:SetMass(10000);
		self.Phys:SetMass(400);
		self.Roll = 0;
		self.Wheels:SetParent();
		self.Liftoff = true;
	end
end

function ENT:EjectorSeat()

	if(IsValid(self.Pilot)) then
		if(self.Inflight) then
			local e = ents.Create("prop_vehicle_prisoner_pod");
			e:SetModel("models/nova/airboat_seat.mdl");
			e:SetPos(self.PilotSeat:GetPos()+self:GetUp()*75);
			e:SetAngles(self:GetAngles());
			e:Spawn();
			e:Activate();
			e:SetColor(Color(255,255,255,0));
			e:SetRenderMode(RENDERMODE_TRANSALPHA);
			e.IsF302Seat = true;

			local p = ents.Create("prop_physics");
			p:SetModel(self.GibTable.Seat1);
			p:SetPos(e:GetPos()+e:GetForward()*-95+e:GetUp()*-17.5);
			p:SetAngles(e:GetAngles()+Angle(0,90,0));
			p:Spawn();
			p:Activate();
			p:SetParent(e);

			self.PilotSeat:Remove();
			self.Cockpit:SetParent();
			self.Cockpit:GetPhysicsObject():ApplyForceCenter(VectorRand()*40000+self:GetUp()*self:GetVelocity():Length()*5000);
			local pilot = self.Pilot;
			self:Exit();
			pilot:EnterVehicle(e);
			e:GetPhysicsObject():ApplyForceCenter(self:GetPos()+self:GetUp()*50000);
			self.Ejecting = true;

			timer.Simple(3, function()
				if (IsValid(self)) then self:Bang(); end
			end);
		end
	end
end

--################## Removes the ejector seat when you get out. @RononDex
hook.Add("PlayerLeaveVehicle", "F302EjecterSeatExit", function(p,v)
	if(IsValid(p and v)) then
		if(v.IsF302Seat) then
			v:Remove();
		end
	end
end);


function ENT:FireMissile(pos)--########### Missile firing stuff @RononDex

	local e = ents.Create("302missile");
	e.Parent = self;
	e:SetPos(pos);
	e:SetAngles(self.Entity:GetAngles());
	e:Spawn();
	e:Activate();
	e:SetVelocity(self:GetVelocity()*self.MissileMaxVel);
	e.Owner = self.Owner;
	e:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	e:SetOwner(self);
	constraint.NoCollide(e,self,0,0);
	e:EmitSound(self.Sounds.Missile,100,100);
	self.MissileCount = self.MissileCount + 1;
	self.Missiles[e] = true;

end

function ENT:ShowOutput() -- Dummy function for missiles
end

function ENT:TriggerInput(k,v) --######### Wire Inputs @ RononDex

	if(not self.EyeTrack and k == "X") then
		self.PositionSet = true;
		self.Target.x = v;
	elseif(not self.EyeTrack and k == "Y") then
		self.PositionSet = true;
		self.Target.y = v;
	elseif(not self.EyeTrack and k == "Z") then
		self.PositionSet = true;
		self.Target.z = v;
	end
end

function ENT:SpawnMissile() --############### Spawn Missile Props @RononDex
	if (not IsValid(self.RocketClamps)) then return end
	local pos = self:GetPos()+self:GetUp()*-40

	
	local m1 = ents.Create("prop_physics")
	m1:SetModel(self.GibTable.Rocket)
	m1:SetPos(self.RocketClamps:GetAttachment(self.RocketClamps:LookupAttachment("Rocket4")).Pos)
	m1:Spawn()
	m1:Activate()
	m1:SetParent(self)
	m1:SetAngles(self:GetAngles())
	
	self.M1 = m1
	self.M1:SetSolid(SOLID_NONE)

	local m2 = ents.Create("prop_physics")
	m2:SetModel(self.GibTable.Rocket)
	m2:SetPos(self.RocketClamps:GetAttachment(self.RocketClamps:LookupAttachment("Rocket1")).Pos)
	m2:Spawn()
	m2:Activate()
	m2:SetParent(self)
	m2:SetAngles(self:GetAngles())
	self.M2 = m2
	self.M2:SetSolid(SOLID_NONE)

	local m3 = ents.Create("prop_physics")
	m3:SetModel(self.GibTable.Rocket)
	m3:SetPos(self.RocketClamps:GetAttachment(self.RocketClamps:LookupAttachment("Rocket3")).Pos)
	m3:Spawn()
	m3:Activate()
	m3:SetParent(self)
	m3:SetAngles(self:GetAngles())
	self.M3 = m3
	self.M3:SetSolid(SOLID_NONE)

	local m4 = ents.Create("prop_physics")
	m4:SetModel(self.GibTable.Rocket)
	m4:SetPos(self.RocketClamps:GetAttachment(self.RocketClamps:LookupAttachment("Rocket2")).Pos)
	m4:Spawn()
	m4:Activate()
	m4:SetParent(self)
	m4:SetAngles(self:GetAngles())
	self.M4 = m4
	self.M4:SetSolid(SOLID_NONE)

	self.MissileMade=true

end


function ENT:Turrets(p) --####### Spawn the turret entities @RononDex

	local pos = self:GetPos()+self:GetUp()*-10+self:GetForward()*50

	if(IsValid(self)) then
		local e = ents.Create("302turret")
		e:SetPos(self:GetAttachment(self:LookupAttachment("TurretL")).Pos)
		e:SetAngles(self:GetAngles())
		e:Spawn()
		e:Activate()
		e:SetParent(self)
		e:SetOwner(self)
		e.Turret = 1;
		e.Parent=self
		self.Turret = e
		if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end

		local e2 = ents.Create("302turret")
		e2:SetPos(self:GetAttachment(self:LookupAttachment("TurretR")).Pos)
		e2:SetAngles(self:GetAngles())
		e2:Spawn()
		e2:Activate()
		e2:SetParent(self)
		e2:SetOwner(self)
		e2.Turret = 2;
		e2.Parent=self
		self.Turret2 = e2
		if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end
	end
end

function ENT:CockpitSpawn(p)

	if(IsValid(self.Cockpit and self.CockpitAnim)) then return end;

	local e = ents.Create("prop_physics");
	e:SetModel(self.GibTable.Cockpit);
	e:SetPos(self:GetPos());
	e:SetAngles(self:GetAngles());
	e:Spawn();
	e:Activate();
	e:SetParent(self);
	e:SetRenderMode(RENDERMODE_NONE) -- Makes it invisible
	e:SetColor(Color(255,255,255,0)); --Just in case...
	self.Cockpit = e;
	e.CanDoAnim = true;
	if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end

	e = ents.Create("prop_dynamic");
	e:SetModel(self.GibTable.Cockpit);
	e:SetParent(self);
	e:SetAngles(self:GetAngles());
	e:SetPos(self:GetPos());
	e:Spawn();
	e:Activate();
	e:SetKeyValue("MinAnimTime","0")
	e:SetKeyValue("MaxAnimTime","8")
	self.CockpitAnim = e;
	if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end

end

function ENT:SpawnRocketClamps(ent,p)

	local e = ent or ents.Create("prop_physics")
	e:SetModel("models/Madman07/F302/rocket_clamp.mdl")
	e:SetPos(self:GetPos())
	e:SetAngles(self:GetAngles())
	e:SetParent(self)
	e:SetMoveType(MOVETYPE_VPHYSICS);
	e:Spawn()
	e:Activate()
	if (not ent) then
		constraint.Weld(self,e,0,0,0,true)
	end
	if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end
	self.RocketClamps=e

end

function ENT:SpawnSeats(p)

	local pilotseat = ents.Create("prop_physics");
	pilotseat:SetModel(self.GibTable.Seat1);
	pilotseat:SetPos(self:GetPos());
	pilotseat:SetAngles(self:GetAngles());
	pilotseat:Spawn();
	pilotseat:Activate();
	pilotseat:SetParent(self);
	self.PilotSeat = pilotseat;
	if CPPI and IsValid(p) and pilotseat.CPPISetOwner then pilotseat:CPPISetOwner(p) end

	local passseat = ents.Create("prop_physics");
	passseat:SetModel(self.GibTable.Seat2);
	passseat:SetPos(self:GetPos());
	passseat:SetAngles(self:GetAngles());
	passseat:Spawn();
	passseat:Activate();
	passseat:SetParent(self);
	self.PassengerSeat = passseat;
	if CPPI and IsValid(p) and passseat.CPPISetOwner then passseat:CPPISetOwner(p) end
	
	local e = ents.Create("prop_vehicle_prisoner_pod");
	e:SetModel("models/nova/airboat_seat.mdl");
	e:SetRenderMode(RENDERMODE_TRANSALPHA);
	e:SetColor(Color(255,255,255,0));
	e:SetPos(self:GetPos()+self:GetForward()*95+self:GetUp()*10);
	e:SetAngles(self:GetAngles()+Angle(0,-90,0));
	e:Spawn();
	e:Activate();
	e:SetParent(self);
	e:SetCameraDistance(850);
	e.IsF302Seat = true;
	e.F302 = self;
	if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end
	

end

function ENT:SpawnWheels(ent,p)

	local e = ent or ents.Create("prop_physics");
	e:SetModel(self.GibTable.Wheels);
	e:SetPos(self:GetPos());
	e:SetAngles(self:GetAngles());
	e:Spawn();
	e:GetPhysicsObject():SetMass(5000);
	e:Activate();
	e:SetOwner(self);
	e:SetRenderMode(RENDERMODE_NONE)
	e:DrawShadow(false)
	if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end

	self.WheelPhys = e:GetPhysicsObject();

	if (not ent) then
		constraint.Weld(e,self,0,0,0,true);
	end

	e.CanDoAnim = true;
	self.WheelsOpen = true;
	self.Wheels = e;

	e = ents.Create("prop_dynamic");
	e:SetModel(self.GibTable.Wheels);
	e:SetParent(self);
	e:SetAngles(self:GetAngles());
	e:SetPos(self:GetPos());
	e:Spawn();
	e:Activate();
	e:SetKeyValue("MinAnimTime","0")
	e:SetKeyValue("MaxAnimTime","0")
	self.WheelsAnim = e;

	e:Fire("setanimation","open","0")
	e:SetKeyValue("MaxAnimTime","8")
end

function ENT:PhysicsSimulate(phys,deltatime)

	self.BaseClass.PhysicsSimulate(self,phys,deltatime);

	if IsValid(self and self.Pilot) then

		if self.NextUse.Brake < CurTime() then
			if self.Pilot:KeyDown(self.Vehicle,"BRAKE") then
				self.Accel.FWD = 1
				self.Pilot:SetEyeAngles(Angle(self.Pilot:EyeAngles().Pitch,self.Pilot:EyeAngles().Yaw+180,self.Pilot:EyeAngles().Roll));
				timer.Simple(0.5, function()
					self.AirBrake = true;
				end);
				timer.Simple(3, function()
					self.AirBrake = false;
				end);
			end
			self.NextUse.Brake = CurTime() + 1;
		end

		if self.Boost then
			self.Accel.FWD = 4500
		end
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if (IsValid(self.Wheels)) then
		dupeInfo.Wheels = self.Wheels:EntIndex();
	end

	if (IsValid(self.RocketClamps)) then
		dupeInfo.RocketClamps = self.RocketClamps:EntIndex();
	end

	duplicator.StoreEntityModifier(self, "F302DupeInfo", dupeInfo)
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.F302DupeInfo

	if (dupeInfo.Wheels) then
		self.Wheels = CreatedEntities[dupeInfo.Wheels];
	end

	if (dupeInfo.RocketClamps) then
		self.RocketClamps = CreatedEntities[dupeInfo.RocketClamps];
	end

	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_ships_max"):GetInt()
		if(ply:GetCount("CAP_ships")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"entity_limit_ships\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("CAP_ships", Ent);
	end

	self:CockpitSpawn() -- Spawn the cockpit
	self:SpawnSeats(); -- Spawn the seats
	self:SpawnRocketClamps(self.RocketClamps,ply); -- Spawn the rocket clamps
	self:SpawnMissile(); -- Spawn the missile props
	self:Turrets(); -- Spawn turrets
	self:SpawnWheels(self.Wheels,ply);
end

hook.Add("PlayerLeaveVehicle", "JumperSeatExit", function(p,v)
	if(IsValid(p) and IsValid(v)) then
		if(v.IsF302Seat) then
			local F302 = v.F302;
			p:SetNetworkedBool("302Passenger",false);
			p:SetNWEntity("302Passenger",NULL);
			p:SetNetworkedEntity("302Seat",NULL);
			if (not IsValid(F302)) then return end
			p:SetPos(F302:GetPos()+F302:GetForward()*100+F302:GetRight()*100+F302:GetUp()*25);
		end
	end
end);

hook.Add("PlayerEnteredVehicle","JumperSeatEnter", function(p,v)
	if(IsValid(v)) then
		if(IsValid(p) and p:IsPlayer()) then
			if(v.IsF302Seat) then
				p:SetNetworkedEntity("302Seat",v);
				p:SetNetworkedEntity("302Passenger",v:GetParent());
				p:SetNetworkedBool("302Passenger",true);
			end
		end
	end
end);

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sg_vehicle_f302", StarGate.CAP_GmodDuplicator, "Data" )
end