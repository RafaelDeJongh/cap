/*
	Drone Launcher for GarrysMod10
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
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
ENT.Sound = {Shot=Sound("weapons/drone_shot.mp3")};
--################# SENT CODE ###############

--################# Init @Zup & aVoN
function ENT:Initialize()
	--self.Entity:SetModel("models/props_phx/box_amraam.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Target = Vector(0,0,0);
	self.energy_drain = StarGate.CFG:Get("drone","energy_per_shot",200);
	self.reloadtime = StarGate.CFG:Get("drone","delay",0.2);
	self.DroneMaxSpeed = StarGate.CFG:Get("drone","maxspeed",6000);
	self.AllowAutoTrack = StarGate.CFG:Get("drone","auto_track",true);
	self.AllowEyeTrack = StarGate.CFG:Get("drone","eye_track",true);
	self.TrackTime = 1000000;
	self.Drones = {};
	self.MaxDrones = StarGate.CFG:Get("drone","max_drones",8);
	self.DroneCount = 0;
	self.DronesLeft = 0; -- For wire/overlay output only
	self.Track = false;
	self.Launched = false;
	self:AddResource("energy",1);
	self:CreateWireInputs("Launch","Lock","X","Y","Z","LockTime","Kill");
	self:CreateWireOutputs("Active","Drones In Air","Drones Remaining");
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
		phys:SetMass(10);
	end
end

--################# Spawnfunction for the SENT menu @Zup
function ENT:SpawnFunction(p,t)
	if(not t.Hit ) then return end
	local e = ents.Create("drone_launcher")
	e:SetPos(t.HitPos+t.HitNormal*16);
	e:Spawn()
	e:Activate()
	e:SetVar("Owner",p);
	return e;
end

--################# Let all drons fall down @aVoN
function ENT:KillDrones()
	for k,_ in pairs(self.Drones) do
		if(k and k:IsValid()) then
			k.Fuel = 0;
		end
		self.Drones[k] = nil;
	end
	self.DroneCount = 0;
	self:SetWire("Drones In Air",0);
end

--################# Wire interaction @Zup
function ENT:TriggerInput(k,v)
	if(not self.EyeTrack and k == "X") then
		self.PositionSet = true;
		self.Target.x = v;
	elseif(not self.EyeTrack and k == "Y") then
		self.PositionSet = true;
		self.Target.y = v;
	elseif(not self.EyeTrack and k == "Z") then
		self.PositionSet = true;
		self.Target.z = v;
	elseif(k == "Launch") then
		if(v > 0) then
			if(not self.Launched) then
				self.Launched = true;
				if((self.LastShot or 0)+self.reloadtime < CurTime()) then
					self.Entity:NextThink(CurTime());
					self:ShowOutput();
				end
			end
		else
			self.Launched = false;
			self:ShowOutput();
		end
	elseif(k == "Lock") then
		if(v > 0) then
			self.Track = true;
			self:ShowOutput();
		else
			self.Track = false;
			self.HasTrackedBefore = false; -- To make Wire always overwrite the Lock
			self:ShowOutput();
		end
	elseif(k == "LockTime") then
		if(v > 0) then
			self.TrackTime = v;
		else
			self.TrackTime = 1000000;
		end
	elseif(k == "Kill") then
		self:KillDrones();
	end
end

--#################  Shoot like hell! @aVoN
function ENT:Use(p)
	self:TriggerInput("Launch",1);
	local id = "StarGate.DroneLauncher"..self.Entity:EntIndex();
	local e = self.Entity;
	timer.Destroy(id);
	timer.Create(id,0.1,1,
		function()
			if(IsValid(e)) then self:TriggerInput("Launch",0) end;
		end
	);
end

--#################  Updates the overlay text @aVoN
function ENT:ShowOutput()
	local add = "Off";
	if(self.Launched) then
		add = "On";
		if(StarGate.HasWire) then
			Wire_TriggerOutput(self.Entity,"Active",1);
		end
	else
		if(StarGate.HasWire) then
			Wire_TriggerOutput(self.Entity,"Active",0);
		end
	end
	self:SetWire("Active",util.tobool(self.Launched));
	local track = "";
	if(self.Track) then
		track = " - Tracking";
	end
	local left = self.DronesLeft;
	if(game.SinglePlayer()) then left = "INF" end;
	self:SetOverlayText("Drone Launcher ("..add..")"..track.."\n"..left.." left");
	self:SetWire("Drones In Air",self.DroneCount);
end

--################# An Evil Think function for firering @Zup & aVoN
function ENT:Think()
	-- No target aquired (by Wire) - Use the nearest player (Do this only when drones got fired)
	local next_think = 1;
	local pos = self.Entity:GetPos();
	if(self.Track and self.DroneCount > 0) then
		-- Track the owner's eyes
		local p = self.Entity.Owner;
		if(self.EyeTrack and p and p:IsValid() and p:Alive()) then
			if(self.AllowEyeTrack) then
				local trace = util.TraceLine(util.GetPlayerTrace(p));
				if(trace.HitPos ~= Vector(0,0,0)) then
					self.Target = trace.HitPos;
				end
				next_think = 0.3;
			end
		else
			if(self.AllowAutoTrack) then
				-- Track for players
				if(self.Target == Vector(0,0,0) or not self.PositionSet) then
					-- I love bubble-sort (not rly)
					local dist;
					for _,v in pairs(player.GetAll()) do
						if(v ~= self.Entity.Owner and v:Alive()) then
							local p_pos = v:GetPos();
							-- Fix for people in a shuttle
							if(v:GetNetworkedBool("isDriveShuttle",false)) then
								local shuttle = v:GetNWEntity("Shuttle",nil);
								if(IsValid(shuttle)) then
									p_pos = shuttle:GetPos();
								end
							end
							-- Fix for people in a Jumper - Lightdaemon rewrote Catdaemon's shuttle-code that way it uses another VariableName now after V3 - Which needs me to make my code more hacky...
							if(v:GetNWBool("isDriveJumper",false)) then
								local shuttle = v:GetNWEntity("Jumper",nil);
								if(IsValid(shuttle)) then
									p_pos = shuttle:GetPos();
								end
							end
							local len = (p_pos-pos):Length();
							if(not dist or len < dist) then
								self.Target = p_pos;
								dist = len;
							end
						end
					end
					next_think = 0.2;
					self.PositionSet = nil;
				end
			end
		end
	end
	local energy = self:GetResource("energy",self.energy_drain);
	if(self.Launched) then
		if(self.DroneCount >= self.MaxDrones and not game.SinglePlayer()) then return end;
		if(energy < self.energy_drain) then
			self.Launched = false;
			return
		end
		self:ConsumeResource("energy",self.energy_drain);
		local vel = self.Entity:GetVelocity();
		local up = self.Entity:GetUp();
		-- calculate the drone's position offset. Otherwise it might collide with the launcher
		local offset = StarGate.VelocityOffset({Velocity=vel,Direction=up,BoundingMax=self.Entity:OBBMaxs().z});
		local e = ents.Create("drone");
		e.Parent = self.Entity;
		e:SetPos(pos+offset);
		e:SetAngles(self.Entity:GetUp():Angle()+Angle(math.random(-2,2),math.random(-2,2),math.random(-2,2)));
		e:SetOwner(self.Entity); -- Don't collide with this thing here please
		e.Owner = self.Entity.Owner;
		e:Spawn();
		e:SetVelocity(vel);
		-- This is necessary to make the drone not collide and explode with the cannon when it's moving
		e.CurrentVelocity = math.Clamp(vel:Length(),0,self.DroneMaxSpeed-500)+500;
		e.CannonVeloctiy = vel;
		self.DroneCount = self.DroneCount + 1;
		self.Drones[e] = true;
		self.LastShot = CurTime();
		self.Entity:EmitSound(self.Sound.Shot,90,math.random(90,110));
		-- Take energy from the shot and prepare for next one
		next_think = self.reloadtime;
	end
	self.DronesLeft = math.Clamp(self.MaxDrones-self.DroneCount,0,math.floor((energy/self.energy_drain)));
	-- ######################## Handle wire
	self:SetWire("Drones Remaining",self.DronesLeft);
	self:ShowOutput();
	self.Entity:NextThink(CurTime()+next_think);
	return true;
end
