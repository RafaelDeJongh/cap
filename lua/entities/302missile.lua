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
if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile();
ENT.IgnoreTouch = true;
ENT.CAP_NotSave = true;
ENT.NoAutoClose = true; -- Will not cause an autoclose event on the stargates!
ENT.CDSIgnore = true; -- CDS Immunity
function ENT:gcbt_breakactions() end; ENT.hasdamagecase = true; -- GCombat invulnarability!

end

ENT.Untouchable = true;
ENT.Type = "anim"
ENT.Base = "drone"
ENT.PrintName	 = "Missile"
ENT.Author = "Zup,aVoN -edit RononDex"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	language.Add("302missile",SGLanguage.GetMessage("entity_f302"));
end

--################### Init @aVoN
function ENT:Initialize()
	self.Created = CurTime();
	self.Emitter=ParticleEmitter(self:GetPos())
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

	if((self)and(self:IsValid())) then
		self:ThrusterEffect(true)
	elseif(time) then
		self:ThrusterEffect(false)
	end

	-- Drone has to fade out
	if(self.Entity:GetNWBool("fade_out")) then
		self.Alpha = math.Clamp(self.Alpha-FrameTime()*80,0,255);
		self.Entity:SetColor(Color(255,255,255,self.Alpha));
	end
	self.Entity:DrawModel();
end

function ENT:ThrusterEffect()
	if (not self:GetAttachment(self:LookupAttachment("Engine"))==nil) then return end
	local pos = self:GetAttachment(self:LookupAttachment("Engine")).Pos
	local roll = math.Rand(-90,90)
	local normal = (self.Entity:GetForward() * -1):GetNormalized()

	local fx = self.Emitter:Add("sprites/orangecore1",pos)
	fx:SetVelocity(normal*2)
	fx:SetDieTime(0.05)
	fx:SetStartAlpha(255)
	fx:SetEndAlpha(255)
	fx:SetStartSize(15)
	fx:SetEndSize(5)
	fx:SetColor(math.Rand(220,255),math.Rand(220,255),195)
	fx:SetRoll(roll)

	local heatwv = self.Emitter:Add("sprites/heatwave",pos)
	heatwv:SetVelocity(normal*2)
	heatwv:SetDieTime(0.2)
	heatwv:SetStartAlpha(255)
	heatwv:SetEndAlpha(255)
	heatwv:SetStartSize(20)
	heatwv:SetEndSize(10)
	heatwv:SetColor(255,255,255)
	heatwv:SetRoll(roll)

end

end

if SERVER then

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

end