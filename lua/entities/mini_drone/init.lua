if (not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
ENT.Untouchable = true;
ENT.IgnoreTouch = true;

function ENT:Initialize()
	self.Entity:SetModel("models/miriam/minidrone/minidrone.mdl");
	self.Entity:SetMaterial("materials/miriam/minidrone/yellow_on.vmt");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	self.Entity:DrawShadow(false);
	self.LastPosition = self.Entity:GetPos()
	self.TrackTime = CurTime()+50;
	self.Fuel = StarGate.CFG:Get("mini_drone","distance",10000);
	self.CurrentVelocity = 500;
	self.MaxVelocity = StarGate.CFG:Get("mini_drone","maxspeed",6000)/6;
	self.Created = CurTime();
	self.Randomness = math.random(6,14)/10;
	self.TrackStart = math.random(5,15)/10;
	self.AntiRandomness = 1-self.Randomness;
	self.Radius = StarGate.CFG:Get("drone","radius",200)/4;
	self.Damage = StarGate.CFG:Get("drone","damage",150)/2;
	self.CanTrack = false;
	self.Trail = util.SpriteTrail(self.Entity,0,Color(255,230,100,255),true,8,2,0.05,1/12,"sprites/smoke.vmt");
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(20);
		phys:EnableGravity(false);
		phys:EnableDrag(false);
		phys:EnableCollisions(true);
	end
end

--################# Removes the trail @aVoN
function ENT:RemoveTrail(unparent)
	if(self.Trail and self.Trail:IsValid()) then
		self.Entity:SetNetworkedInt("turn_off",CurTime());
		-- Only do this when we are in SinglePlayer. In MultiPlayer i have seen the trails gowing into the sky near map-origin which was really ugly
		if(unparent) then
			if(game.SinglePlayer()) then
				self.Trail:SetParent();
				self.Trail:SetPos(self.Entity:GetPos());
			end
			self.Trail:Fire("kill","",1); -- Kill trail
		else
			self.Trail:Remove();
		end
	end
end

--################# Calculate Physics for the drone @Zup & aVoN
function ENT:PhysicsUpdate(phys,deltatime)
	local time = CurTime();
	if((self.LastPhysicsUpdate or 0) + 0.07 >= time) then return end;
	self.LastPhysicsUpdate = time;
	if(self.Fuel > 0) then
		local pos = self.Entity:GetPos();
		if(self.CurrentVelocity < self.MaxVelocity) then
			self.CurrentVelocity = math.Clamp(self.MaxVelocity*(CurTime()-self.Created)/self.TrackStart,self.CurrentVelocity,self.MaxVelocity);
			self.Direction = self.Entity:GetForward()*self.CurrentVelocity;
			-- Allow tracking only after the drone reached a critical velocity
			if(not self.CanTrack and self.Created+self.TrackStart*0.7 <= CurTime()) then
				self.CanTrack = true;
			end
		end
		self.Fuel = self.Fuel-(pos-self.LastPosition):Length(); -- Take fuel accodring to the flown way
		if(self.CanTrack and time < self.TrackTime) then
			-- This makes it not to look so sloppy in curves
			local dir = self:GetVelocity();
			if IsValid(self.Ply) then
				if self.Ply.Target then
					dir = self.Ply.Target-pos;
				end
			end
			local len = dir:Length();
			dir:Normalize();
			if(len > 250) then
				self.Direction = (dir*self.Randomness+self.Entity:GetVelocity():GetNormalized()*self.AntiRandomness)*self.CurrentVelocity;
			else
				-- We are really near the target. Do not fly around like an electron - Hit it!
				self.Direction = dir*self.CurrentVelocity;
				if(len < 100) then -- Nearly at the prop's position. Instant explode (Failsafe, or when there is no prop, the drones would collide with each other and lag servers!)
					self:StartTouch(game.GetWorld());
				end
			end
			local t={
				secondstoarrive = 1,
				pos = pos+self.Direction,
				maxangular = 50000,
				maxangulardamp = 100,
				maxspeed = 1000000,
				maxspeeddamp = 10000,
				dampfactor = 0.2,
				teleportdistance = 7000,
				angle = dir:Angle(),
				deltatime = deltatime,
			}
			phys:ComputeShadowControl(t);
		elseif(self.CurrentVelocity ~= self.MaxVelocity) then -- We havent reached full velocity yet - So constanly add velocity
			phys:SetVelocity(self.Direction);
		end
		self.LastPosition = pos;
	else
		-- Turn the missile off
		local e = self.Entity;
		timer.Simple(2,
			function()
				if(e and e:IsValid()) then
					e:SetMaterial("Zup/drone/drone.vmt");
				end
			end
		);
		self:RemoveTrail();
		-- Remove it's count from the launcher
		self:OnRemove();
		-- Make it falldown
		phys:EnableGravity(true);
		phys:EnableDrag(true);
		self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS); -- Only collide with world but not players
		-- And when the drone does not collide (aka "Lost in space"), we will kill it in 30 seconds anyway
		timer.Create("DroneDestroy"..self.Entity:EntIndex(),30,1,
			function()
				if(e and e:IsValid()) then
					e:Remove();
				end
			end
		);
		-- Dummy to save resources
		self.PhysicsUpdate = function() end;
	end
end

--################# What shall happen when we die? @aVoN
function ENT:OnRemove()
	local str = "DroneDestroy"..self.Entity:EntIndex();
	if(timer.Exists(str)) then
		timer.Destroy(str);
	end
	if(self.Parent and self.Parent:IsValid()) then
		if(self.Parent.Drones[self.Entity]) then -- Only decrease, if we haven't already
			self.Parent.DroneCount = self.Parent.DroneCount-1; -- Decrease count
			self.Parent.Drones[self.Entity] = nil;
			self.Parent:ShowOutput();
		end
	end
end

--################# The blast @aVoN
function ENT:Blast(pos, tr)

	-- effect some why removed in new gmod, replace with old from normal drones
	/*local fx = EffectData()
		fx:SetOrigin( pos );
		fx:SetNormal( tr.HitNormal );
	util.Effect( "AR2Impact", fx ); */

	local fx = EffectData()
		fx:SetOrigin( pos );
		fx:SetNormal( tr.HitNormal );
	util.Effect("Explosion",fx,true,true);
	util.Effect("HelicopterMegaBomb",fx,true,true);

	local fx = EffectData();
		fx:SetScale(1);
		fx:SetOrigin(pos);
		fx:SetEntity(self.Entity);
		fx:SetAngles(Angle(255,200,120));
		fx:SetRadius(32);
	util.Effect("energy_muzzle",fx,true);

	local attacker,owner = StarGate.GetAttackerAndOwner(self.Entity);
	StarGate.BlastDamage(attacker,owner,pos,self.Radius,self.Damage);
end

--################# This is a remove function to avoid crashing when hitting the world @aVoN
function ENT:StartRemoving(delay_deletion)
	if(delay_deletion) then
		self:RemoveTrail();
		-- You ask, why a timer? This avoids ugly "Changing collision rules within a callback is likely to cause crashes!" spam in console. Don't ask me why this happens.
		-- It also stops crashing
		self:SetNoDraw(true); -- Stop drawing us!
		local e = self.Entity;
		-- Stop collision with us
		timer.Simple(0.1,
			function()
				if(e and e:IsValid()) then
					e:SetCollisionGroup(COLLISION_GROUP_DEBRIS);
				end
			end
		);
		-- Kill us
		timer.Simple(2,
			function()
				if(e and e:IsValid()) then
					e:Remove(); -- It's time kick ass and chew bubble gum. And your all out of gum
				end
			end
		);
	else
		-- General deletion
		self:RemoveTrail(true);
		self.Entity:Remove();
	end
end

--################# What shall happen, when we collide? @Zup & aVoN
function ENT:StartTouch(e,delay_deletion)
	if(e and e.IgnoreTouch) then return end; -- Gloabal for anyone, who want's to make his scripts "drone-passable"
	if(e == self.Parent) then return end;
	if(e and e:IsValid()) then
		local class = e:GetClass();
		if(class == "drone" or class == "mini_drone") then return end;
		if(class == "ivisgen_collision") then return end; -- Catdaemons Cloaking Field - Never collide with this
		local phys = e:GetPhysicsObject();
		if(not (phys and phys:IsValid())) then return end; -- Nothing "solid" or physical to collide
	end
	local vel = self.Entity:GetVelocity();
	if(StarGate.CanTouch({BaseVelocity=self.CannonVeloctiy,Velocity=self.Entity:GetVelocity(),Time=self.Created})) then
		local pos = self.Entity:GetPos();
		vel = vel:GetNormalized()*512;
		-- Like the staffweapon blasts, I don't want the drones to explode when they hit the sky
		local t = util.TraceLine({start=pos-vel,endpos=pos+vel,filter={self.Entity,self.Trail}});
		-- Define dummys: DO NOT CALL THE TOUCH OR THE PHYSICS AGAIN!
		self.PhysicsUpdate = function() end;
		self.StartTouch = function() end;
		if(t.HitSky) then self:StartRemoving(delay_deletion) return end;
		-- Need to replace this with a better one!
		if(e and self.Fuel > 0) then
			if(not e.nocollide) then self:Blast(pos, t) end; -- Do not explode on shields!
			self:StartRemoving(delay_deletion);
		else
			self.Entity:SetNWBool("fade_out",true);
			-- Kill after some time
			local e = self.Entity;
			timer.Simple(5,
			function()
				if(e and e:IsValid()) then
					self.Entity:Remove();
				end
			end
			);
		end
	end
end

function ENT:PhysicsCollide(data)
	-- Only and really only do this when he collides with the world
	if(data and data.HitEntity and data.HitEntity:IsWorld()) then
		self:StartTouch(data.HitEntity,true);
	end
end

