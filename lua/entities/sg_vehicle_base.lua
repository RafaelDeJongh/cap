--[[
	Stargate Vehicle base for GarrysMod10
	Copyright (C) 2010-2011  RononDex

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

	Dear to whoever is reading this,
		I(RononDex) have had a lot of experience coding vehicles, and finally
		decided that I should make a base. All you need to do is to derive from
		this base and set the vars needed in the Initialize of your entity. Please
		check my other vehicles for the vars that are needed. Please give credit to me,
		if this base is used and finally do NOT reupload this anywhere.
		Regards,
	Ronon Dex
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.PrintName = "Stargate Vehicle Base"
ENT.Author = "RononDex"
ENT.Base = "base_anim"
ENT.Type = "vehicle"
ENT.Category = "Stargate Carter Addon Pack: Ships"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.IsSGVehicle = true;

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile();

ENT.NextExit = CurTime();
ENT.num = 0;
ENT.num2 = 0;
ENT.num3 = 0;
ENT.Roll = 0;
ENT.Accel = {
	FWD = 0;
	RIGHT = 0;
	UP = 0;
};
ENT.CanUse = true;

ENT.WeaponsTable={}; --Make the table for weapons out here, this when a player enters stores there weapons which we give back when they exit

function ENT:Initialize()

	self:SetModel(self.Model);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:StartMotionController();
	self.HoverPos = self:GetPos();

end

function ENT:Bang(p) --######## The effect, and killing the player if they're flying @RononDex

	self:EmitSound(Sound("jumper/JumperExplosion.mp3"),100,100); --Play the jumper's explosion sound(Only good explosion sound i have)
	local fx = EffectData();
		fx:SetOrigin(self:GetPos());
	util.Effect("dirtyxplo",fx);

	if(self.Inflight) then
		self:Exit(true); --Let the player out...
	end
	self.Done = true;
	self:Remove(); --Get rid of the vehicle

end

function ENT:OnRemove(p)

	if(self.Inflight and not self.Done) then
		self:Exit(); -- Let the player out
	end
end

--####### Standard stargate vehicle stuff @RononDex
function ENT:Think()

	if(self.Inflight) then
		if(IsValid(self.Pilot)) then
			if(self.Pilot:KeyDown(self.Vehicle,"BOOM")) then
				self:Bang(); return
			end

			if(self.NextExit<CurTime()) then
				if(self.Pilot:KeyDown(self.Vehicle,"EXIT")) then
					self.NextExit = CurTime()+1;
					self:Exit();
				end
			end
		end
	end

	if(self.RunningAnim) then
		self:NextThink(CurTime());
		return true;
	end
end

function ENT:Enter(p) --####### Get in @RononDex

	if(not(self.Inflight) and self.CanUse) then
		p:SetNetworkedEntity(self.Vehicle,self); --Set a networked entity as the name of the vehicle
		p:SetNetworkedBool("Flying"..self.Vehicle,true); --Set a bool on the player
		p:Spectate(OBS_MODE_CHASE); --Spectate the vehicle
		p:DrawWorldModel(false);
		p:DrawViewModel(false);
		p:SetMoveType(MOVETYPE_OBSERVER);
		p:SetCollisionGroup(COLLISION_GROUP_WEAPON);
		for _,v in pairs(p:GetWeapons()) do
			table.insert(self.WeaponsTable, v:GetClass());
		end
		p:StripWeapons();
		self.PlayerHealth=p:Health();
		if(p:FlashlightIsOn()) then
			p:Flashlight(false); --Turn the player's flashlight off when Flying
		end
		--p:SetScriptedVehicle(self);
		p:SetNetworkedEntity("ScriptedVehicle", self)
		p:SetViewEntity(self)
		self:GetPhysicsObject():Wake();
		self:GetPhysicsObject():EnableMotion(true); --UnFreeze us
		if(self.ShouldRotorwash) then
			self:Rotorwash(true);
		end
		self.Inflight = true;
		self.Pilot = p;
		self.NextExit = CurTime()+1;
	end
end

function ENT:Exit(kill) --####### Get out @RononDex

	if (IsValid(self.Pilot)) then
		StarGate.KeyBoard.ResetKeys(self.Pilot,self.Vehicle);
		self.Pilot:UnSpectate();
		self.Pilot:DrawViewModel(true);
		self.Pilot:DrawWorldModel(true);
		self.Pilot:Spawn();
		self.Pilot:SetNetworkedBool("Flying"..self.Vehicle,false);
		self.Pilot:SetPos(self.ExitPos or self:GetPos());
		self.Pilot:SetParent();
		self.Pilot:SetMoveType(MOVETYPE_WALK);
		self.Pilot:SetCollisionGroup(COLLISION_GROUP_PLAYER);
	end
	if(self.ShouldRotorwash) then
		self:Rotorwash(false);
	end
	self.Inflight = false;
	self:SetNetworkedEntity(self.Vehicle,nil);
	if (IsValid(self.Pilot)) then
		--self.Pilot:SetScriptedVehicle(NULL);
		self.Pilot:SetNetworkedEntity( "ScriptedVehicle", NULL )
		self.Pilot:SetViewEntity( NULL )
		self.Pilot:SetHealth(self.PlayerHealth);
		for _,v in pairs(self.WeaponsTable) do
			self.Pilot:Give(tostring(v));
		end
		if (kill) then self.Pilot:Kill(); end
	end
	self.Pilot = NULL;
	self.Accel.FWD = 0;
	self.Accel.RIGHT = 0;
	self.Accel.UP = 0;
	table.Empty(self.WeaponsTable); --Get rid of our old weapons
	self.HoverPos = self:GetPos();
end


function ENT:Use(p) --####### When you press E on it @RononDex

	if(not(self.CanUse)) then return end;

	if(not(self.Inflight)) then
		self:Enter(p); --Get in
	end
end

local FlightPhys={ -- Make the table of constants out here, to stop creating garbage.
	secondstoarrive	= 1;
	maxangular		= 9000;
	maxangulardamp	= 1000;
	maxspeed			= 1000000;
	maxspeeddamp		= 500000;
	dampfactor		= 1;
	teleportdistance	= 5000;
};
local ZAxis = Vector(0,0,1);
function ENT:PhysicsSimulate( phys, deltatime )--############## Flight code@ RononDex
	local FWD = self.Entity:GetForward();
	local UP = ZAxis;
	local RIGHT = FWD:Cross(UP):GetNormalized();

	if(self.Inflight and IsValid(self.Pilot)) then
		-- Accelerate
		if not self.AirBrake and not self.Boost then
			if((self.Pilot:KeyDown(self.Vehicle,"FWD"))and(self.Pilot:KeyDown(self.Vehicle,"SPD"))) then
				self.num = self.MaxSpeed;
			elseif((self.Pilot:KeyDown(self.Vehicle,"FWD"))) then
				self.num = self.ForwardSpeed;
			elseif(self.Pilot:KeyDown(self.Vehicle,"BACK")) then
				self.num = self.BackwardSpeed;
			else
				self.num = 0;
			end
		end
		self.Accel.FWD = math.Approach(self.Accel.FWD,self.num,self.Accel.SpeedForward);

		-- Strafe
		if(self.GoesRight) then
			if(self.Pilot:KeyDown(self.Vehicle,"RIGHT")) then
				self.num2 = self.RightSpeed;
			elseif(self.Pilot:KeyDown(self.Vehicle,"LEFT")) then
				self.num2 = -self.RightSpeed;
			else
				self.num2 = 0;
			end
		end
		self.Accel.RIGHT = math.Approach(self.Accel.RIGHT,self.num2,self.Accel.SpeedRight);

		-- Up and Down
		if(self.GoesUp) then
			if(self.Pilot:KeyDown(self.Vehicle,"UP")) then
				self.num3 = self.UpSpeed;
			elseif(self.Pilot:KeyDown(self.Vehicle,"DOWN")) then
				self.num3 = -self.UpSpeed;
			else
				self.num3 = 0;
			end
		end
		self.Accel.UP = math.Approach(self.Accel.UP,self.num3,self.Accel.SpeedUp);

		if(self.CanRoll and not self.LandingMode) then
			if(self.Pilot:KeyDown(self.Vehicle,"RL")) then
				self.Roll = self.Roll - 5;
			elseif(self.Pilot:KeyDown(self.Vehicle,"RR")) then
				self.Roll = self.Roll + 5;
			elseif(self.Pilot:KeyDown(self.Vehicle,"RROLL")) then
				self.Roll = 0;
			end
		end

		phys:Wake();
		if(not(self.Hover)) then
			if self.Accel.FWD>-200 and self.Accel.FWD < 200 then return end; --with these you float and won't move
			if(self.GoesUp) then
				if self.Accel.UP>-200 and self.Accel.UP < 200 then return end;
			end
			if(self.GoesRight) then
				if self.Accel.RIGHT>-200 and self.Accel.RIGHT < 200 then return end;
			end
		end

		local pos = self:GetPos();

		--######### Do a tilt when turning, due to aerodynamic effects @aVoN
		local velocity = self:GetVelocity();
		local aim = self.Pilot:GetAimVector();
		local ang = aim:Angle();
		local ExtraRoll = math.Clamp(math.deg(math.asin(self:WorldToLocal(pos + aim).y)),-25,25); -- Extra-roll - When you move into curves, make the shuttle do little curves too according to aerodynamic effects
		local mul = math.Clamp((velocity:Length()/1700),0,1); -- More roll, if faster.
		ang.Roll = (ang.Roll + self.Roll - ExtraRoll*mul) % 360;

		if(self.Pilot:KeyDown(self.Vehicle,"LAND")) then
			self.LandingMode = true;
			self:SetAngles(Angle(0,self:GetAngles().Yaw,self.Roll));
		else
			self.LandingMode = false;
		end

		--##### Calculate our new angles and position based on speed
		if(not(self.LandingMode)) then
			FlightPhys.angle = ang; --+ Vector(90 0, 0)
		end
		FlightPhys.deltatime = deltatime;
		FlightPhys.pos = self:GetPos()+(FWD*self.Accel.FWD)+(UP*self.Accel.UP)+(RIGHT*self.Accel.RIGHT);

		self.Pilot:SetPos(pos);

		phys:ComputeShadowControl(FlightPhys);
	end
	if (not self.Inflight and self.HoverAlways) then
		phys:Wake();
		FlightPhys.angle = Angle(0, self:GetAngles().y, 0);
		FlightPhys.deltatime = deltatime;
		FlightPhys.pos = self.HoverPos;
		phys:ComputeShadowControl(FlightPhys);
	end
end


--############## Collison Dammage @ WeltEntSturm
function ENT:PhysicsCollide(cdat, phys)

	if cdat.DeltaTime > 0.5 then --0.5 seconds delay between taking physics damage
		local mass = (cdat.HitEntity:GetClass() == "worldspawn") and 1000 or cdat.HitObject:GetMass(); --if it's worldspawn use 1000 (worldspawns physobj only has mass 1), else normal mass
		self:TakeDamage((cdat.Speed*cdat.Speed*math.Clamp(mass, 0, 1000))/9000000);
		if((self.Accel.FWD or self.Accel.RIGHT or self.Accel.UP)>500) then
			self.Accel.FWD = math.Approach(self.Accel.FWD,0,30);
		end
	end
end


 --################# After teleporting it, fix the angles of a player @aVoN
function ENT.FixAngles(self,pos,ang,vel,old_pos,old_ang,old_vel,ang_delta)
	-- Move a players view
	local diff = Angle(0,ang_delta.y+180,0);
	if(IsValid(self.Pilot)) then
		self.Pilot:SetEyeAngles(self.Pilot:GetAimVector():Angle() + diff);
	end
end
StarGate.Teleport:Add("sg_vehicle_*",ENT.FixAngles);

--########## Run the anim that's set in the arguements @RononDex
function ENT:Anims(e,anim,playback_rate,delay,nosound,sound)

	if(e.CanDoAnim) then
		self:NextThink(CurTime());
		e.CanDoAnim = false;
		e.RunningAnim = true;
		e.Anim = e:LookupSequence(anim); -- The anim, set anim as the name of the anim in a string in the arguements
		if(not(nosound)) then --Set false to allow sound
			e:EmitSound(Sound(sound),100,100); --create sound as a string in the arguements
		end
		--e:SetPlaybackRate(0.00001);
		e:SetSequence(e.Anim); -- play the sequence
		--e:Fire("setanimation",anim,"0")
		timer.Simple(delay,function() --How long until we can do the anim again?
			e.CanDoAnim = true;
			e.RunningAnim = false;
		end);
	end
end

function ENT:Rotorwash(b) --########## Toggle the rotorwash @RononDex

	if(b) then
		local e = ents.Create("env_rotorwash_emitter");
		e:SetPos(self:GetPos());
		e:SetParent(self);
		e:Spawn();
		e:Activate();
		self.RotorWash = e;
	else
		if(IsValid(self.RotorWash)) then
			self.RotorWash:Remove();
		end
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_ships_max"):GetInt()
		if(ply:GetCount("CAP_ships")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Ships limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			Ent:Remove();
			return
		end
		ply:AddCount("CAP_ships", Ent);
	end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

function playerDies( victim, weapon, killer )
	if (IsValid(victim:GetNetworkedEntity("ScriptedVehicle", NULL))) then
          local veh = victim:GetNetworkedEntity("ScriptedVehicle", NULL);
          if (veh:GetClass()!="puddle_jumper" and veh:GetClass()!="sg_vehicle_daedalus" and veh.Bang) then
			veh:Bang();
          end
     end
end
hook.Add( "PlayerDeath", "SG.VEH.playerDies", playerDies )

end

if CLIENT then

function ENT:Initialize( )
	--self:SetShouldDrawInViewMode( true )
	self.FXEmitter = ParticleEmitter( self:GetPos())
	self.SoundsOn = {}
	if (self.Sounds.Engine) then
		self.EngineSound = self.EngineSound or CreateSound(self.Entity,self.Sounds.Engine);
	end
end

function SGVehBaseCalcView(Player, Origin, Angles, FieldOfView)
	local view = {}
	local p = Player
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((self)and(self:IsValid()) and self.IsSGVehicle and not self.IsSGVehicleCustomView) then
		local pos = self:GetPos()+self:GetUp()*self.UDist+LocalPlayer():GetAimVector():GetNormal()*self.Dist
		local face = ( ( self:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle()
			view.origin = pos
			view.angles = face
		return view
	end
end
hook.Add("CalcView", "SGVehBaseCalcView", SGVehBaseCalcView)

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
	if (self.EngineSound) then
		self.EngineSound:Stop();
	end
end

function ENT:Think()

	local p = LocalPlayer()
	local IsDriver = (p:GetNetworkedEntity(self.Vehicle,NULL) == self.Entity);
	local IsFlying = p:GetNWBool("Flying"..self.Vehicle,false);

	--######### Handle engine sound
	if(IsFlying) then
		-- Normal behaviour for Pilot or people who stand outside
		self:StartClientsideSound("Engine");
		--#########  Now add Pitch etc
		local velo = self.Entity:GetVelocity();
		local pitch = self.Entity:GetVelocity():Length();
		local doppler = 0;
		-- For the Doppler-Effect!
		if(not IsDriver) then
			-- Does the vehicle fly to the player or away from him?
			local dir = (p:GetPos() - self.Entity:GetPos());
			doppler = velo:Dot(dir)/(150*dir:Length());
		end
		if(self.SoundsOn.Engine) then
			self.EngineSound:ChangePitch(math.Clamp(60 + pitch/25,75,100) + doppler,0);
		end
	else
		self:StopClientsideSound("Engine");
	end
end

--################# Starts a sound clientside @aVoN
function ENT:StartClientsideSound(mode)
	if(not self.SoundsOn[mode]) then
		if(mode == "Engine" and self.EngineSound) then
			self.EngineSound:Stop();
			self.EngineSound:SetSoundLevel(90);
			self.EngineSound:PlayEx(1,100);
		end
		self.SoundsOn[mode] = true;
	end
end

--################# Stops a sound clientside @aVoN
function ENT:StopClientsideSound(mode)
	if(self.SoundsOn[mode]) then
		if(mode == "Engine" and self.EngineSound) then
			self.EngineSound:FadeOut(2);
		end
		self.SoundsOn[mode] = nil;
	end
end

end