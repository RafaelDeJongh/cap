/*
	Drone Launcher for GarrysMod10
	Copyright (C) 2007  Zup, 2010 Madman07
*/

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Drone Launcher"
ENT.Author = "Zup, Madman07"
ENT.Category = "Stargate Carter Addon Pack: Weapons"
ENT.WireDebugName = "Drone Launcher"

list.Set("CAP.Entity", ENT.PrintName, ENT);

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile();
ENT.Sound = {Shot=Sound("weapons/drone_shot.mp3")};

function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/drone_launcher/drone_launcher.mdl");

	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Target = Vector(0,0,0);
	self.energy_drain = StarGate.CFG:Get("drone","energy_per_shot",200);
	self.reloadtime = StarGate.CFG:Get("drone","delay",0.2);
	self.DroneMaxSpeed = StarGate.CFG:Get("drone","maxspeed",6000);
	self.TrackTime = 1000000;
	self.Drones = {};
	self.MaxDrones = StarGate.CFG:Get("drone","max_drones",8);

	self.DroneCount = 0;
	self.DronesLeft = 0; -- For wire/overlay output only
	self.Track = false;
	self.Launched = false;
	self.Open = false;
	self.Anim = false;
	self.TargetEnt = nil;
	self.IsAtlantisChair = false;
	self.IsChair = false;

	self:AddResource("energy",1);
	self:CreateWireInputs("Launch","Lock","Vector [VECTOR]", "Entity [ENTITY]","Kill", "Open");
	self:CreateWireOutputs("Active","Drones In Air","Drones Remaining");

	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then
		phys:Wake();
	end
end

function ENT:SpawnFunction(ply,tr)
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_launchdrone_max"):GetInt()
	if(ply:GetCount("CAP_launchdrone")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Drone Launchers limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("launcher_drones");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent:SetVar("Owner",ply);
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAP_launchdrone", ent)
	return ent
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_launchdrone_max"):GetInt()
		if(ply:GetCount("CAP_launchdrone")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Drone Launchers limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
		ply:AddCount("CAP_launchdrone", self.Entity)
	end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "launcher_drones", StarGate.CAP_GmodDuplicator, "Data" )
end

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

function ENT:StartTouch( ent )
	if IsValid(ent) then
		if ent:IsVehicle() then self.IsChair = true; self.IsAtlantisChair = false;
		elseif (ent:GetClass() == "control_chair") then self.IsAtlantisChair = true; self.IsChair = false;
		else return end
		if (self.APC != ent) then
			local ed = EffectData()
				ed:SetEntity(ent)
			util.Effect( "propspawn", ed, true, true )
		end
		self.APC = ent;
	end
end

function ENT:ShowOutput() end -- Dummy for drones

function ENT:TriggerInput(k,v)
	if(k == "Vector") then
		self.PositionSet = true;
		self.Target = v;
	elseif(k == "Entity") then
		self.PositionSet = true;
		self.TargetEnt = v;
	elseif(k == "Launch") then
		if(v > 0) then
			if(not self.Launched and self.Open) then
				self.Launched = true;
				if((self.LastShot or 0)+self.reloadtime < CurTime()) then
					self.Entity:NextThink(CurTime());
				end
			end
		else
			self.Launched = false;
		end
	elseif(k == "Lock") then
		if(v > 0) then
			self.Track = true;
		else
			self.Track = false;
			self.HasTrackedBefore = false;
		end
	elseif(k == "Kill") then
		self:KillDrones();
	elseif (k == "Open" and not IsValid(self.APC)) then
		if (v == 1 and not self.Open) then
			self.Anim = true;
			self.Open = true;
			timer.Simple( 1, function() self.Anim = false end);
			local seq = self.Entity:LookupSequence("Close");
			self.Entity:ResetSequence(seq);
		elseif (v == 0 and self.Open) then
			self.Anim = true;
			self.Open = false;
			timer.Simple( 1, function() self.Anim = false end);
			local seq = self.Entity:LookupSequence("Open");
			self.Entity:ResetSequence(seq);
		end
	end
end

function ENT:Think()

	local next_think = 1;

	if IsValid(self.APC) then
		if self.IsAtlantisChair then

			local rand = VectorRand()*30;
			self.APC.StartPos.X = self.Entity:GetPos().X + rand.X;
			self.APC.StartPos.Y = self.Entity:GetPos().Y + rand.Y;
			self.APC.StartPos.Z = self.Entity:GetPos().Z;
			next_think = 0.1;

			if (self.APC.Controlling and self.APC.Enabled and not self.Open) then
				self.Anim = true;
				self.Open = true;
				timer.Simple( 1, function() self.Anim = false end);
				local seq = self.Entity:LookupSequence("Close");
				self.Entity:ResetSequence(seq);
			elseif ((not self.APC.Controlling or not self.APC.Enabled) and self.Open) then
				self.Anim = true;
				self.Open = false;
				timer.Simple( 1, function() self.Anim = false end);
				local seq = self.Entity:LookupSequence("Open");
				self.Entity:ResetSequence(seq);
			end

		elseif self.IsChair then

			self.APCply = self.APC:GetPassenger(0)
			if IsValid(self.APCply) then

				if not self.Open then
					self.Anim = true;
					self.Open = true;
					timer.Simple( 1, function() self.Anim = false end);
					local seq = self.Entity:LookupSequence("Close");
					self.Entity:ResetSequence(seq);
				end

				self.APCply:CrosshairEnable();
				self.Target = self.APCply:GetEyeTrace().HitPos;
				self.Track = true;

				if self.APCply:KeyDown(IN_ATTACK)then
					if(not self.Launched and self.Open) then
						self.Launched = true;
						if((self.LastShot or 0)+self.reloadtime < CurTime()) then
							self.Entity:NextThink(CurTime());
						end
					end
				else
					self.Launched = false;
				end
			else
				self.Launched = false;
				self.Track = false;

				if self.Open then
					self.Anim = true;
					self.Open = false;
					timer.Simple( 1, function() self.Anim = false end);
					local seq = self.Entity:LookupSequence("Open");
					self.Entity:ResetSequence(seq);
				end

			end

		end

	else

		if IsValid(self.TargetEnt) then self.Target = self.TargetEnt:GetPos() end
		next_think = 1;
		local pos = self.Entity:GetPos();

		if(self.Track and self.DroneCount > 0) then
			if(self.Target == pos or not self.PositionSet) then
				next_think = 0.2;
				self.PositionSet = nil;
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
		local pos = self.Entity:GetPos();
		-- calculate the drone's position offset. Otherwise it might collide with the launcher
		local offset = StarGate.VelocityOffset({Velocity=vel,Direction=up,BoundingMax=self.Entity:OBBMaxs().z});
		local e = ents.Create("drone");
		e.Parent = self.Entity;
		local rand = VectorRand()*30; rand.Z = 0;
		e:SetPos(pos+offset+rand);
		e:SetAngles(self.Entity:GetUp():Angle()+Angle(math.random(-2,2),math.random(-2,2),math.random(-2,2)));
		e:SetOwner(self.Entity); -- Don't collide with this thing here please
		e.Owner = self.Entity.Owner;			e:Spawn();
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
	self:SetWire("Drones Remaining",self.DronesLeft);

	if self.Anim then
		next_think = 0;
	end

	self.Entity:NextThink(CurTime()+next_think);
	return true;
end

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_OPAQUE; -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_weapon_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_drone");
end
-- Kill Icon
if(file.Exists("materials/weapons/drone_killicon.vmt","GAME")) then
	killicon.Add("launcher_drones","weapons/drone_killicon",Color(255,255,255));
	killicon.Add("drone","weapons/drone_killicon",Color(255,255,255));
end

end