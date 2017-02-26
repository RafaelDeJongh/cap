/*
	Drone for GarrysMod10
	Copyright (C) 2007  Zup

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
*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName	 = "Wired Drone"
ENT.Author = "Zup"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.CAP_NotSave = true
ENT.DoNotDuplicate = true 

if SERVER then

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile();

ENT.Untouchable = true;
ENT.IgnoreTouch = true;
ENT.NoAutoClose = true; -- Will not cause an autoclose event on the stargates!
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

--################# SENT CODE ###############

--################# Init @Zup
function ENT:Initialize()
	self.Entity:SetModel("models/zup/drone/drone.mdl");
	self.Entity:SetMaterial("Zup/drone/drone_on.vmt");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE); -- Makes drones not to collide with each other (= saves resources)
	--self.Entity:SetSolid(SOLID_VPHYSICS); -- Do not need?
	self.Entity:DrawShadow(false);
	self.LastPosition = self.Entity:GetPos()
	self.TrackTime = CurTime()+self.Parent.TrackTime;
	self.Fuel = StarGate.CFG:Get("drone","distance",20000);
	self.CurrentVelocity = 500;
	self.MaxVelocity = StarGate.CFG:Get("drone","maxspeed",6000);
	self.Created = CurTime();
	-- Defines, how "curvey" the drone will fly. This makes them not all flying the same route (looks actually to artificial)
	self.Randomness = math.random(3,9)/10;
	-- And this defines, if a drone is able to start tracking 0.5 or 1.5 seconds after it got launcher
	self.TrackStart = math.random(5,15)/10;
	self.AntiRandomness = 1-self.Randomness;
	-- Damage system
	self.Radius = StarGate.CFG:Get("drone","radius",200);
	self.Damage = StarGate.CFG:Get("drone","damage",150);
	self.CanTrack = false;
	-- Trail on the drone
	self.Trail = util.SpriteTrail(self.Entity,0,Color(255,230,100,255),true,20,3,0.15,1/12,"sprites/smoke.vmt");
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
	if(self.Fuel > 0 and (self.Parent and self.Parent:IsValid())) then
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
		if(self.CanTrack and self.Parent.Track and time < self.TrackTime) then
			-- This makes it not to look so sloppy in curves
			local dir = self.Parent.Target-pos;
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
function ENT:Blast(pos)
	local fx = EffectData()
	fx:SetOrigin(pos);
	util.Effect("HelicopterMegaBomb",fx,true,true);
	util.Effect("Explosion",fx,true,true);
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
		if(class == "drone") then return end;
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
		if(e and self.Fuel > 0 and (self.Parent and self.Parent:IsValid())) then
			if(not e.NoCollide) then self:Blast(pos) end; -- Do not explode on shields!
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

end

if CLIENT then

if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end
ENT.Glow = StarGate.MaterialFromVMT(
	"DroneSprite",
	[["UnLitGeneric"
	{
		"$basetexture"		"sprites/light_glow01"
		"$nocull" 1
		"$additive" 1
		"$vertexalpha" 1
		"$vertexcolor" 1
	}]]
);
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("drone",SGLanguage.GetMessage("drone_kill"));
end

--################### Init @aVoN
function ENT:Initialize()
	self.Created = CurTime();
end

--################# Draw @aVoN
function ENT:Draw()
	local pos = self.Entity:GetPos();
	self.Size = self.Size or 60;
	self.Alpha = self.Alpha or 255;
	local time = self.Entity:GetNetworkedInt("turn_off",false);
	if(time) then
		-- Drone turns off (But only, when the Trail has been removed before)
		if(time+1 < CurTime()) then
			self.Size = math.Clamp((2-CurTime()+(time+1))*60,0,60);
		end
	end
	if(StarGate.VisualsWeapons("cl_drone_glow")) then
		-- The sprite on the drone
		render.SetMaterial(self.Glow);
		render.DrawSprite(
			self.Entity:GetPos(),
			self.Size,self.Size,
			Color(255,210,100,255)
		);
	end
	-- Drone has to fade out
	if(self.Entity:GetNWBool("fade_out")) then
		self.Alpha = math.Clamp(self.Alpha-FrameTime()*80,0,255);
		self.Entity:SetColor(Color(255,255,255,self.Alpha));
	end
	self.Entity:DrawModel();
end

--################# Think (From StaffWeapon flyby code) @aVoN
function ENT:Think()
	if(self.Entity:GetNWBool("turn_off")) then return end;
	-- ######################## Flyby-noise
	if((self.Last or 0)+0.6 <= CurTime() and (CurTime()-self.Created) >= 0.05) then
		local v = self.Entity:GetVelocity();
		local v_len = v:Length();
		local d = (LocalPlayer():GetPos()-self.Entity:GetPos());
		local d_len = d:Length();
		if(d_len <= 700) then
			self.Last = CurTime();
			-- Vector math: Get the distance from the player orthogonally to the projectil's velocity vector
			local intensity = math.sqrt(1-(d:DotProduct(v)/(d_len*v_len))^2)*d_len;
			self.Entity:EmitSound(Sound("weapons/drone_flyby.mp3"),100*(1-intensity/1000),math.random(80,120));
		end
	end
end

end