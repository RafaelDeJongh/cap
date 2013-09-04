if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Sound when firing begins
local fireSoundPath = Sound("weapons/overloader_charge.wav")
-- Ambient sound while firing
local beamSoundPath = Sound("weapons/asuran_beam.wav")
-- Sound when a valid target gate is detected and the overloader prepares to fire
local startupSoundPath  = Sound("NPC_FloorTurret.Deploy")
-- Sound when the overloader shuts down (no longer able to fire)
local shutdownSoundPath = Sound("NPC_FloorTurret.Retire")

-- Animation names
local startupAnimName = "open"
local shutdownAnimName = "close"
local firingAnimName = "firing"

-- A multiplier for the amount of energy needed to destroy a stargate.
-- i.e. energyNeeded = gate.capacity * energyMultiplier
local energyMultiplier = 0

local MAX_GATE_DISTANCE = 2000
local MIN_ENERGY_USAGE = 200
local MAX_ENERGY_USAGE = 2000

-- The numbe of seconds between each Think() call
ENT.cycleInterval = 0.25

-- The beam that is being fired
ENT.beam = nil
-- The gate on the overloader's end of the wormhole
ENT.localGate = nil
-- The gate on the other end of the wormhole
ENT.remoteGate = nil

-- Whether the weapon should prepare to fire
ENT.isArmed = false
-- Whether the weapon has a gate targetted and is ready to fire
ENT.isActive = false
-- Whether the weapon is firing into a gate
ENT.isFiring = false

-- The stargate overloader is immune to EMP, as seen in the series
ENT.CDSEmp_Ignore = true

-- Spawns a gate overloader for the given player
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_asuran_beam_max"):GetInt()
	if(ply:GetCount("CAP_asuran_beam")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Asuran Gate Weapon limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = ang.y % 360;

	local ent = ents.Create("asuran_gate_weapon");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAP_asuran_beam", ent)
	return ent
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("CAP_asuran_beam_max"):GetInt()
	if(ply:GetCount("CAP_asuran_beam")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Asuran Gate Weapon limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end
	ply:AddCount("CAP_asuran_beam", self.Entity)
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

-- Sets the gate overloader's model, physics, health, resources, wire inputs/outputs, etc.
function ENT:Initialize()

	self.Entity:SetModel("models/Iziraider/gateweapon/gateweapon.mdl")
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)

	-- Round up energy requirement
	self:SetEnergyUsage(1)

	-- Reset states (this sets them as networked variables)
	self:SetIsActive(false)
	self:SetIsFiring(false)

	-- Set resources
	if(self.HasRD) then
		self:AddResource("energy", 1)
	end

	 -- Set up wire inputs and outputs
	if(self.HasWire) then
		self:CreateWireInputs("Fire")
	end

	-- The time when the USE key was last pressed on this entity
	self.lastUseTime = 0;
end

-- Respond to a given wire input
function ENT:TriggerInput(inputName, inputValue)
	if(inputName == "Fire") then
		if(inputValue ~= 0) then
			self:Arm()
		else
			self:Disarm()
		end
	end
end

-- Toggle armed state when the USE key is pressed on the overloader
function ENT:Use()
	if(self.lastUseTime + 3 >= CurTime()) then
		return
	end

	if(self.isArmed == false) then
		self:Arm()
	else
		self:Disarm()
	end

	self.lastUseTime = CurTime()
end

-- Sets the amount of energy the overloader should use per second
function ENT:SetEnergyUsage(energyUsage)
	if(energyUsage < MIN_ENERGY_USAGE) then
		energyUsage = MIN_ENERGY_USAGE
	elseif(energyUsage > MAX_ENERGY_USAGE) then
		energyUsage = MAX_ENERGY_USAGE
	end

	self.energyPerSecond = energyUsage
	self.energyPerCycle = energyUsage * self.cycleInterval
end

-- Returns a valid target stargate (nearby and in front of the overloader)
function ENT:FindTarget()
	for _, gate in pairs(ents.FindByClass("stargate_*")) do
		if (gate:GetClass() == "stargate_orlin") then return end
		local gateDistance = self.Entity:GetPos():Distance(gate:GetPos())

		if(gateDistance < MAX_GATE_DISTANCE && self:IsAimedAtGate(gate)) then
			return gate
		end
	end

	return nil
end

-- Returns whether there is Line-Of-Sight between the overloader's emitter and the given entity
function ENT:IsAimedAtGate(gate)
	if(gate == nil || gate:IsValid() == false) then
		return false
	end

	local gateCentre = StarGate.GetEntityCentre(gate)
	local emitterPos = self:GetEmitterPos()

	local gateDirection = gateCentre - emitterPos
	local emitterDirection = emitterPos - gateCentre

	local angleToGate = gateDirection:GetNormal():Dot(self.Entity:GetAngles():Forward())
	local angleFromGate = emitterDirection:GetNormal():Dot(gate:GetAngles():Forward())

	-- If the cannon is not facing almost directly at the gate, return false
	if(angleToGate < 0.98 || angleFromGate < 0.98) then
		return false
	end

	local vector = (gateCentre - emitterPos) * 1.1
	local ignorableEntities = { self.Entity }
	self.trace = StarGate.Trace:New(emitterPos,
											  vector,
											  ignorableEntities)

	local traceEnt = self.trace.Entity

	-- If we had LOS on a gate, but now are hitting a player/NPC, return true so the overloader doesn't shut off
	-- (the player/NPC will be disintegrated shortly and LOS should be restored)
	if(IsValid(self.localGate) &&
		IsValid(traceEnt) && (traceEnt:IsPlayer() || traceEnt:IsNPC())) then

		return true
	end

	local hasTraceHitGate = IsValid(traceEnt) &&
									(traceEnt == gate ||
									 traceEnt == gate.EventHorizon)

	return hasTraceHitGate
end

-- Returns whether the overloader is upright
function ENT:IsUpright()
	return self.Entity:GetAngles():Up():Dot(Vector(0,0,1)) > 0.8
end

-- Returns whether the given gate is a valid target
function ENT:IsGateValidTarget(gate)
	if(gate ~= nil && gate:IsValid() && self:IsAimedAtGate(gate)) then
		return true
	else
		return false
	end
end

function ENT:SetLocalGate(gate)
	self.localGate = gate
	self.Entity:SetNetworkedEntity("localGate", gate)
end

-- Clears the current target and shuts down the overloader
function ENT:ClearTarget()
	self:Shutdown()

	self:SetLocalGate(nil)
end

-- Handles state transitions and cools down all stargates
function ENT:Think()
	if(self.localGate && self:IsGateValidTarget(self.localGate) == false) then
		self:ClearTarget()
	end

	if(self.isArmed) then
		if(self:IsUpright()) then
			if(self.isActive) then
				self:FireBeam()
			else
				self.localGate = self:FindTarget()

				if(self.localGate) then
					self:Startup()
				end
			end
		else
			self:Shutdown()
		end
	end

   if(self.HasRD) then
      local energyAvailable = self:GetResource("energy")
      self:ConsumeResource("energy", self.energyPerCycle*100)
      -- If there isn't enough energy left to power the beam for another second, stop firing
      if(energyAvailable < self.energyPerSecond) then
         self:StopFiring()
         return false
      end
   end

	self.Entity:NextThink(CurTime() + self.cycleInterval)
	return true
end


-- Prepares the overloader to fire
-- Returns: Whether startup was successful
function ENT:Startup()
	if(self.isArmed == false) then
		return false
	elseif(self.isActive == true) then
		return true
	end

	local readyAnimation = self.Entity:LookupSequence(startupAnimName)

	if(readyAnimation ~= -1) then
		self.Entity:ResetSequence(readyAnimation)
	end

	self.Entity:EmitSound(startupSoundPath, 80, 100)

	self:SetLocalGate(self.localGate) -- Sets the local gate as a networked entity
       /*
	if(self.HasRD) then
		-- Allow the overloader to store the energy it needs for one second of fire
		self:AddResource("energy", self.energyPerSecond)
	end */

	self:SetIsActive(true)

	return true
end

-- Returns: whether the overloader could be shutdown
function ENT:Shutdown()
	if(self.isActive == false) then
		return true
	end

	self:StopFiring()
              /*
	if(self.HasRD) then
		-- Remove energy storage while the device is not active
		self:AddResource("energy", 1)
	end         */

	self.Entity:EmitSound(shutdownSoundPath, 100, 100)

	local idleAnimation = self.Entity:LookupSequence(shutdownAnimName)

	if(idleAnimation ~= -1) then
		self.Entity:SetSequence(idleAnimation)
	end

	self:SetIsActive(false)

	return true
end

-- Allows the overloader to acquire a target gate and fire when ready
-- Returns: whether the overloader could be armed
function ENT:Arm()
	self.isArmed = true

	return true
end

-- Shuts down the overloader and prevents it from firing or acquiring a new target
-- Returns: whether the overloader could be disarmed
function ENT:Disarm()
	if(self.isArmed == false) then
		return true
	end

	self:Shutdown()
	self.isArmed = false

	return true
end

-- Fires the beam
-- Returns: whether firing succeeded
function ENT:FireBeam()
	if(self.isArmed == false || self.isActive == false ||
		self:IsGateValidTarget(self.localGate) == false ||
		StarGate.IsStargateOpen(self.localGate) == false ||
		StarGate.GetRemoteStargate(self.localGate) == nil) then
		self:StopFiring()
		return false
	elseif(StarGate.IsIrisClosed(self.localGate)) then
		self:StopFiring()
		return false
	elseif(StarGate.IsStargateOutbound(self.localGate) == false) then
		self:StopFiring()
		return false
	end

	if(self.HasRD) then
		local energyAvailable = self:GetResource("energy")

		-- If there isn't enough energy left to power the beam for another second, stop firing
		if(energyAvailable < self.energyPerSecond) then
			self:StopFiring()
			return false
		end
	end

	self.remoteGate = StarGate.GetRemoteStargate(self.localGate)

	if(self.remoteGate == nil || self.remoteGate:IsValid() == false) then
		self:StopFiring()
		return false
	end

	-- If this is the starting shot
	if(self.isFiring == false) then
		self:StartFiring()
	end

	if(self.beamSound) then
		self.beamSound:Play()
	end

	-- Make sure any DHDs near the gate are jammed
	-- Do this constantly while firing to prevent players spawning a DHD in order to shut down the gate
	for _, dhd in pairs(self.remoteGate:FindDHD()) do
		StarGate.JamDHD(dhd, self.cycleInterval * 2)
	end

	self:SetIsFiring(true)

	if(self.beam == nil) then
		self.beam = self:CreateBeam()
	end

	return true
end

function ENT:StartFiring()
	self.lastUseTime = CurTime()

	self.Entity:EmitSound(fireSoundPath, 100, 100)

	local firingAnimation = self.Entity:LookupSequence(firingAnimName)

	if(firingAnimation ~= -1) then
		self.Entity:SetSequence(firingAnimation)
	end

	StarGate.JamRemoteGate(self.remoteGate)
    /*
	if(StarGate.GetStargateEnergyCapacity(self.remoteGate) == nil) then
		StarGate.SetStargateEnergyCapacity(self.remoteGate, StarGate.STARGATE_DEFAULT_ENERGY_CAPACITY)
	end

	if(self.remoteGate.excessPowerLimit == nil) then
		self.remoteGate.excessPowerLimit = StarGate.GetStargateEnergyCapacity(self.remoteGate) *
													  energyMultiplier
	end

	self.remoteGate.overloader = self.Entity
	self.Entity:SetNetworkedEntity("remoteGate", self.remoteGate)  */
end

function ENT:SetIsActive(isActive)
	self.isActive = util.tobool(isActive)
	self.Entity:SetNetworkedBool("isActive", self.isActive)
end

function ENT:SetIsFiring(isFiring)
	self.isFiring = util.tobool(isFiring)
	--self.Entity:SetNetworkedBool("isFiring", self.isFiring)
end

function ENT:CreateBeam()

	local gateMarker = StarGate.GetGateMarker(self.localGate)

	local beam = ents.Create("env_laser")
	beam:SetPos(self:GetEmitterPos() + self.Entity:GetForward()*10)
	beam:SetAngles(self.Entity:GetAngles())
	beam:SetOwner(self.Entity:GetOwner())
	beam:SetVar("Owner", self.Entity:GetVar("Owner", nil))
	beam:SetKeyValue("texture", "cable/crystal_beam1.vmt")
	beam:SetKeyValue("LaserTarget", gateMarker:GetName())
	beam:SetKeyValue("renderamt", "0")
	beam:SetKeyValue("rendermode","1")
	beam:SetKeyValue("rendercolor", "255 50 50")
	beam:SetKeyValue("TextureScroll", "20")
	beam:SetKeyValue("width", "30")
	beam:SetKeyValue("damage", self.energyPerCycle)
	beam:SetKeyValue("dissolvetype", "0")

	beam:Spawn()
	beam:SetParent(self.Entity)
	beam:Fire("TurnOn", 1)
	 self.Entity:SetNetworkedEntity("SmallBeam", beam);

		timer.Simple(1.5, function() -- Spawn the beam after the effect finishes
		  if(self.remoteGate == nil) then
			 return
		  end

		inBeamInfo = EffectData()
			inBeamInfo:SetEntity(self.Entity)
		util.Effect("GateWeapon_beams", inBeamInfo)

		local energyBeam = ents.Create("energy_laser");
		energyBeam.Owner = self.Entity;
		energyBeam:SetPos(self.remoteGate.EventHorizon:GetPos());
		energyBeam:Spawn();
		energyBeam:Activate();
		energyBeam:SetOwner(self.Entity);
		energyBeam:Setup(self.remoteGate.EventHorizon, "GateWep");

		self.Outgoingbeam = energyBeam

		-- energyBeam.SoundPaths["active"] = Sound("weapons/asuran_beam.wav")

		end)

	self.Entity:SetNetworkedEntity("outBeam", energyBeam)

	beam.sound = CreateSound(self.Entity, beamSoundPath);

	if(beam.sound) then
		beam.sound:Play()
	end

	return beam
end

function ENT:DestroyBeam(beam)
	if(beam.sound) then
		beam.sound:Stop()
		beam.sound = nil
	end

	beam:Remove()
	if IsValid(self.Outgoingbeam)  then self.Outgoingbeam:Remove() end
end

-- Stops the overloader firing
-- Returns: whether it was possible to stop firing
function ENT:StopFiring()
	if(self.isFiring == false) then
		return false
	end

	if(self.beam && self.beam:IsValid()) then
		self:DestroyBeam(self.beam)
		self.beam = nil
	end

	-- Attempt to un-jam gates individually incase one of them has been destroyed

	if(self.remoteGate && self.remoteGate:IsValid()) then
		StarGate.UnJamGate(self.remoteGate)
		self.remoteGate:DeactivateStargate()
	end

	self.remoteGate = nil

	if(self.localGate && self.localGate:IsValid()) then
		StarGate.UnJamGate(self.localGate)
		self.localGate:DeactivateStargate()
	else
		self.localGate = nil
	end

	self:SetIsFiring(false)

	return true
end

function ENT:OnRemove()
	self:Disarm();
	self:StopFiring();
	if(self.beamSound) then
      self.beamSound:Stop()
   end

	StarGate.WireRD.OnRemove(self);
end
