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

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
ENT.Untouchable = true;
ENT.IgnoreTouch = true;
ENT.NoAutoClose = true; -- Will not cause an autoclose event on the stargates!
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

--################# SENT CODE ###############

--################# Init @Zup
function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/F302/missile.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE); -- Makes drones not to collide with each other (= saves resources)
	--self.Entity:SetSolid(SOLID_VPHYSICS); -- Do not need?
	self.Entity:DrawShadow(false);
	self.LastPosition = self.Entity:GetPos()
	self.TrackTime = CurTime()+self.Parent.TrackTime;
	self.Fuel = 20000
	self.CurrentVelocity = 500;
	self.MaxVelocity = 6000
	self.Created = CurTime();
	-- Defines, how "curvey" the drone will fly. This makes them not all flying the same route (looks actually to artificial)
	self.Randomness = math.random(3,9)/10;
	-- And this defines, if a drone is able to start tracking 0.5 or 1.5 seconds after it got launcher
	self.TrackStart = math.random(5,15)/10;
	self.AntiRandomness = 1-self.Randomness;
	-- Damage system
	self.Radius = 200
	self.Damage = 150
	self.CanTrack = false;
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(20);
		phys:EnableGravity(false);
		phys:EnableDrag(false);
		phys:EnableCollisions(true);
	end
end


--################# What shall happen when we die? @aVoN
function ENT:OnRemove()
	local str = "DroneDestroy"..self.Entity:EntIndex();
	if(timer.Exists(str)) then
		timer.Destroy(str);
	end
	if(self.Parent and self.Parent:IsValid() and self.Parent.Missiles) then
		if(self.Parent.Missiles[self.Entity]) then -- Only decrease, if we haven't already
			self.Parent.MissileCount = self.Parent.MissileCount-1; -- Decrease count
			self.Parent.Missiles[self.Entity] = nil;
			self.Parent:ShowOutput();
		end
	end
end



function ENT:IsMissile()

	return true

end