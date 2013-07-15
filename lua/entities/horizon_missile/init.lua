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
if (not StarGate.CheckModule("entweapon")) then return end
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
	self.Entity:SetModel("models/Iziraider/Horizon/warhead.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetCollisionGroup(COLLISION_GROUP_PROJECTILE); -- Makes drones not to collide with each other (= saves resources)
	--self.Entity:SetSolid(SOLID_VPHYSICS); -- Do not need?
	self.Entity:DrawShadow(false);
	self.LastPosition = self.Entity:GetPos()
	self.TrackTime = CurTime()+1000000;
	self.Fuel = 20000
	self.CurrentVelocity = 100;
	self.MaxVelocity = 1000
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
end

function ENT:Blast(pos)

	if self.IsDecoy then
		local fx = EffectData()
		fx:SetOrigin(pos);
		util.Effect("HelicopterMegaBomb",fx,true,true);
		util.Effect("Explosion",fx,true,true);
		local attacker,owner = StarGate.GetAttackerAndOwner(self.Entity);
		StarGate.BlastDamage(attacker,owner,pos,self.Radius,self.Damage);
	else
		-- local ent = ents.Create("sat_blast_wave");
		-- ent:SetPos(pos+Vector(0,0,300));
		-- ent:Spawn();
		-- ent:Activate();
		-- ent:SetOwner(self.Entity);
		local warhead = ents.Create("gate_nuke")
		warhead:Setup(self.Entity:GetPos(), 100)
		warhead:SetVar("owner",self.Owner)
		warhead:Spawn()
		warhead:Activate()
		self.Entity:Remove()
	end

end