-- Use the Stargate addon to add LS, RD and Wire support to this entity
if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type             = "anim"
ENT.Base             = "base_anim"

ENT.PrintName        = "Gate Overloader"
ENT.WireDebugName    = "Gate Overloader"
ENT.Author           = "PyroSpirit, Madman07"
ENT.Contact		      = "forums.facepunchstudios.com"
ENT.Category 		 = "Stargate Carter Addon Pack: Weapons"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.AutomaticFrameAdvance = true

ENT.energyPerSecond       = 2500
ENT.energyPerCycle        = 500
ENT.coolingPerCycle       = 300

-- Get the position of the beam emitter on the overloader
function ENT:GetEmitterPos()
	local emitter = self.Entity:GetAttachment(self.Entity:LookupAttachment("emitter0"));
	if emitter and emitter.Pos then
		return emitter.Pos
	else
		return self.Entity:GetPos() + self.Entity:GetForward()*100
	end
end

function ENT:GetSubBeamPos(beam)
	local beams = {}
	local attachmentIDs =
	{
		self.Entity:LookupAttachment("emitter1"),
		self.Entity:LookupAttachment("emitter2"),
		self.Entity:LookupAttachment("emitter3"),
		self.Entity:LookupAttachment("emitter4"),
		self.Entity:LookupAttachment("emitter5"),
		self.Entity:LookupAttachment("emitter6")
	}

	local emitter = self.Entity:GetAttachment(attachmentIDs[beam])
	if emitter and emitter.Pos then
		return emitter.Pos
	else
		return self.Entity:GetPos() + self.Entity:GetForward()*10
	end
end

function ENT:IsActive()
   return self.Entity:GetNetworkedBool("isActive", self.isActive == true)
end

function ENT:IsFiring()
   return self.Entity:GetNetworkedBool("isFiring", self.isFiring == true)
end

function ENT:GetBeamColour()
	return "200 200 255"
end

function ENT:GetLocalGate()
   return self.Entity:GetNetworkedEntity("localGate", nil)
end

function ENT:GetRemoteGate()
   return self.Entity:GetNetworkedEntity("remoteGate", nil)
end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile()

-- Sound when firing begins
local fireSoundPath = Sound("weapons/overloader_charge.wav")
-- Ambient sound while firing
local beamSoundPath = Sound("weapons/overloader_loop.wav")
-- Sound when a valid target gate is detected and the overloader prepares to fire
local startupSoundPath  = Sound("NPC_FloorTurret.Deploy")
-- Sound when the overloader shuts down (no longer able to fire)
local shutdownSoundPath = Sound("NPC_FloorTurret.Retire")

--local defaultModel = "models/pyro_overloader/overloader.mdl"

-- Animation names
local startupAnimName = "open"
local shutdownAnimName = "idle"
local firingAnimName = "firing"

-- A multiplier for the amount of energy needed to destroy a stargate.
-- i.e. energyNeeded = gate.capacity * energyMultiplier
local energyMultiplier = 5

local MAX_GATE_DISTANCE = 2000
local MIN_ENERGY_USAGE = 400
local MAX_ENERGY_USAGE = 4000

-- The numbe of seconds between each Think() call
ENT.cycleInterval = 0.2

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
-- Whether the weapon is exploding
ENT.isDestructing = false
-- Whether the beam should come out of the other end of the wormhole (as with the Asuran satellite weapon)
--ENT.isBeamCoherent = false

-- The stargate overloader is immune to EMP, as seen in the series
ENT.CDSEmp_Ignore = true

-- Spawns a gate overloader for the given player
function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_overloader_max"):GetInt()
		if(ply:GetCount("CAP_overloader")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Gate Overloader limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return
		end
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = ang.y % 360;

	local ent = ents.Create("gate_overloader");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();

	if IsValid(tr.Entity) then
		local model = tr.Entity:GetModel()
		if (model == "models/madman07/overped/overped.mdl") then
			ent:SetPos(tr.Entity:GetPos() + Vector(0,0,30));
			ent:SetAngles(tr.Entity:GetAngles());
			constraint.Weld(ent,tr.Entity,0,0,0,true)
			local phys = tr.Entity:GetPhysicsObject()
			if IsValid(phys) then phys:EnableMotion(false) end
		end
	else
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then phys:EnableMotion(false) end
	end

	if (IsValid(ply)) then
		ply:AddCount("CAP_overloader", ent)
	end
	return ent
end

function ENT:StartTouch(ent)
	if IsValid(ent) then
		local model = ent:GetModel()
		if (model == "models/madman07/overped/overped.mdl") then
			self.Entity:SetPos(ent:GetPos() + Vector(0,0,30));
			self.Entity:SetAngles(ent:GetAngles());
			constraint.Weld(ent,self.Entity,0,0,0,true)
			local fx = EffectData();
				fx:SetEntity(self.Entity);
			util.Effect("propspawn",fx);
		end
	end
end

function ENT:PostEntityPaste(player, Ent,CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("CAP_overloader_max"):GetInt()
	if(IsValid(player) and player:IsPlayer() and player:GetCount("CAP_overloader")+1 > PropLimit) then
		player:SendLua("GAMEMODE:AddNotify(\"Gate Overloader limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end
	if (IsValid(player)) then
		player:AddCount("CAP_overloader", self.Entity)
	end
	StarGate.WireRD.PostEntityPaste(self,player,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "gate_overloader", StarGate.CAP_GmodDuplicator, "Data" )
end

-- Sets the gate overloader's model, physics, health, resources, wire inputs/outputs, etc.
function ENT:Initialize()

	self.Entity:SetModel("models/pyro_overloader/overloader.mdl")
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)

   -- Round up energy requirement
   self:SetEnergyUsage(math.ceil(self.energyPerSecond))

   -- Set health
   self.Entity:SetMaxHealth(300)
   self.Entity:SetHealth(300)

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
		self:CreateWireOutputs("Active", "Percent", "Energy", "Time")
	end

	-- The time when the USE key was last pressed on this entity
	self.lastUseTime = 0

      --self.isBeamCoherent = false
   --self.Entity:SetNetworkedBool("isBeamCoherent", self.isBeamCoherent)
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

      -- If there isn't enough energy left to power the beam for another second, stop firing
      if(energyAvailable < self.energyPerSecond) then
         self:StopFiring()
      end
   end

	self.Entity:NextThink(CurTime() + self.cycleInterval)
	return true
end

-- Updates all wire output values
function ENT:UpdateWireOutputs()
   if(!self.HasWire) then
      return
   end

   if(self.isFiring and self.remoteGate.excessPowerLimit and self.remoteGate.excessPower) then
      local energyRequired = self.remoteGate.excessPowerLimit -
                             self.remoteGate.excessPower
      local timeLeft = (energyRequired / self.energyPerSecond)
      if(StarGate.IsIrisClosed(self.remoteGate)) then
      	timeLeft = timeLeft * 2;
	  end
      local perc = (self.remoteGate.excessPower/self.remoteGate.excessPowerLimit)*100;
      self:SetWire("Energy", energyRequired)
      self:SetWire("Percent", perc)
      self:SetWire("Time", timeLeft)
      self:SetWire("Active", 1)
   else
   	  self:SetWire("Energy", 0)
   	  self:SetWire("Percent", 0)
      self:SetWire("Active", 0)
      self:SetWire("Time", -1)
   end
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

   if(self.HasRD) then
      -- Allow the overloader to store the energy it needs for one second of fire
      --self:AddResource("energy", self.energyPerSecond)
   end

   self:SetIsActive(true)

   return true
end

-- Returns: whether the overloader could be shutdown
function ENT:Shutdown()
   if(self.isActive == false) then
      return true
   end

   self:StopFiring()

   if(self.HasRD) then
      -- Remove energy storage while the device is not active
      --self:AddResource("energy", 1)
   end

   self.Entity:EmitSound(shutdownSoundPath, 100, 100)

   local idleAnimation = self.Entity:LookupSequence(shutdownAnimName)

   if(idleAnimation ~= -1) then
      self.Entity:SetSequence(idleAnimation)
   end

   self:SetIsActive(false)

   self:UpdateWireOutputs()

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

   self:UpdateWireOutputs()

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

   self:HeatGate(self.remoteGate)
   self:UpdateWireOutputs()

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

   if(StarGate.GetStargateEnergyCapacity(self.remoteGate) == nil) then
      StarGate.SetStargateEnergyCapacity(self.remoteGate, StarGate.STARGATE_DEFAULT_ENERGY_CAPACITY)
   end

   if(self.remoteGate.excessPowerLimit == nil) then
      self.remoteGate.excessPowerLimit = StarGate.GetStargateEnergyCapacity(self.remoteGate) * energyMultiplier
   end
   -- fix for rd2
   if (self.remoteGate.excessPowerLimit<StarGate.STARGATE_DEFAULT_ENERGY_CAPACITY) then
	  self.remoteGate.excessPowerLimit = StarGate.STARGATE_DEFAULT_ENERGY_CAPACITY;
   end

   self.remoteGate.overloader = self.Entity
   self.Entity:SetNetworkedEntity("remoteGate", self.remoteGate)
end

function ENT:SetIsActive(isActive)
   self.isActive = util.tobool(isActive)
   self.Entity:SetNetworkedBool("isActive", self.isActive)
end

function ENT:SetIsFiring(isFiring)
   self.isFiring = util.tobool(isFiring)
   self.Entity:SetNetworkedBool("isFiring", self.isFiring)
end

function ENT:CreateBeam()
   inBeamInfo = EffectData()
	 inBeamInfo:SetEntity(self.Entity)
	 util.Effect("InBeam", inBeamInfo,true,true)

   local gateMarker = StarGate.GetGateMarker(self.localGate)

   local beam = ents.Create("env_laser")
   beam:SetPos(self:GetEmitterPos())
   beam:SetAngles(self.Entity:GetAngles())
   beam:SetOwner(self.Entity:GetOwner())
   beam:SetVar("Owner", self.Entity:GetVar("Owner", nil))
   beam:SetKeyValue("texture", "cable/crystal_beam1.vmt")
   beam:SetKeyValue("LaserTarget", gateMarker:GetName())
   beam:SetKeyValue("renderamt", "0")
   beam:SetKeyValue("rendermode","1")
   beam:SetKeyValue("rendercolor", self:GetBeamColour())
   beam:SetKeyValue("TextureScroll", "20")
   beam:SetKeyValue("width", "30")
   beam:SetKeyValue("damage", self.energyPerCycle)
   beam:SetKeyValue("dissolvetype", "2")

   beam:Spawn()
   beam:SetParent(self.Entity)
   beam:Fire("TurnOn", 1)

   beam.subBeams = self:CreateSubBeams()

   beam.sound = CreateSound(beam, beamSoundPath)

   if(beam.sound) then
      beam.sound:Play()
   end

   return beam
end

function ENT:DestroyBeam(beam)
   self:DestroySubBeams(beam.subBeams)

   if(beam.sound) then
      beam.sound:Stop()
      beam.sound = nil
   end

   beam:Remove()
end

function ENT:CreateSubBeams()
   if(self.emitterMarker == nil || self.emitterMarker:IsValid() == false) then
      self.emitterMarker = ents.Create("info_target")
      self.emitterMarker:SetPos(self:GetEmitterPos())
      self.emitterMarker:SetName("EmitterMarker"..self.Entity:EntIndex())
      self.emitterMarker:Spawn()
      self.emitterMarker:SetParent(self.Entity)
   end

   local beams = {}

   for attachmentNum = 1, 6 do

      local beam = ents.Create("env_laser")
      beam:SetPos(self:GetSubBeamPos(attachmentNum))
      beam:SetOwner(self.Entity:GetOwner())
      beam:SetVar("Owner", self.Entity:GetVar("Owner", nil))
      beam:SetKeyValue("texture", "cable/crystal_beam1.vmt")
      beam:SetKeyValue("rendercolor", self:GetBeamColour())
      beam:SetKeyValue("renderamt", "0")
      beam:SetKeyValue("rendermode","1")
      beam:SetKeyValue("TextureScroll", "20")
      beam:SetKeyValue("width", "5")
      beam:SetKeyValue("damage", self.energyPerCycle / 6)
      beam:SetKeyValue("dissolvetype", "2")
      beam:SetKeyValue("LaserTarget", self.emitterMarker:GetName())

      beam:Spawn()
      beam:SetParent(self.Entity)
      beam:Fire("TurnOn", 1)

      table.insert(beams, beam)
   end

   return beams
end

function ENT:DestroySubBeams(subBeams)
   for _, beam in pairs(subBeams) do
      beam:Remove()
   end

   if(self.emitterMarker && self.emitterMarker:IsValid()) then
      self.emitterMarker:Remove()
      self.emitterMarker = nil
   end
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
      self.remoteGate:DeactivateStargate(true)
   end

   self.remoteGate = nil

   if(self.localGate && self.localGate:IsValid()) then
      StarGate.UnJamGate(self.localGate)
      self.localGate:DeactivateStargate(true)
   else
      self.localGate = nil
   end

   self:SetIsFiring(false)
   --self.Entity:SetOverlayText("")

   return true
end

function ENT:HeatGate(gate)
   if(gate == nil) then
      error("The gate passed to HeatGate(gate) cannot be nil.\n")
      return false
   elseif(gate:IsValid() == false) then
      error("The gate passed to HeatGate(gate) was not a valid entity.\n")
      return false
   elseif(self.energyPerCycle <= 0) then
      return true
   elseif(gate.isOverloading == true) then
      return true
   end

   local addedEnergy = 0

   if(self.HasRD) then
   	  self:ConsumeResource("energy", self.energyPerCycle*100)
      addedEnergy = self.energyPerCycle
   else
      addedEnergy = self.energyPerCycle
   end

   -- If the remote gate has its iris closed, it will absorb only half as much energy
   if(StarGate.IsIrisClosed(gate)) then
      addedEnergy = addedEnergy / 2
   end

   -- If the beam is coming out of the remote gate, only a quarter of its energy should build up in the gate
   -- if(self:IsBeamCoherent()) then
      -- addedEnergy = addedEnergy / 4
   -- end

   if(gate.excessPower == nil) then
      gate.excessPower = 0
   end

   addedEnergy = math.ceil(addedEnergy)
   gate.excessPower = gate.excessPower + addedEnergy
      /*
   if(self.HasRD) then
      -- Increase the energy capacity of the gate so that it can hold the additional energy build-up
      self:AddResource("energy", StarGate.GetStargateEnergyCapacity(gate) + addedEnergy)
      -- Supply the energy from the beam to the gate
      --self:SupplyResource("energy", addedEnergy)
   end  */

   -- If the gate can no longer hold any more energy, make it explode
   if(gate.excessPower and gate.excessPowerLimit and gate.excessPower >= gate.excessPowerLimit/* && not self:FindAsuran(gate)*/) then
      gate.isOverloading = true

      local overloadEffect = EffectData()
      overloadEffect:SetEntity(self.Entity)
      util.Effect("Unstable", overloadEffect)

      timer.Simple(30, function() if IsValid(gate) then StarGate.DestroyStargate(gate) end end)
   end

   return true
end
   /*
function ENT:FindAsuran(gat)
	if (not IsValid(gat)) then return end
	local pos = gat:GetPos();
	for _,e in pairs(ents.FindByClass("asuran_gate_weapon")) do
		if(IsValid(e)) then
			local e_pos = e:GetPos();
			local dist = (e_pos - pos):Length();
		 	if (dist <= gat.DHDRange) then
				local add = true;
				for _,gate in pairs(gat:GetAllGates()) do
					if(gate ~= self.Entity and (gate:GetPos() - e_pos):Length() < dist) then
						add = false;
						break;
					end
				end
				if(add) then
					return true;
				end
			end
		end
	end
	return false;
end     */

-- Causes the gate overloader to take the given damage
function ENT:OnTakeDamage(damageInfo)
	if(damageInfo:GetInflictor():GetClass() == "env_laser" && IsValid(self.beam)) then
      for _, beam in pairs(self.beam.subBeams) do
         if(damageInfo:GetInflictor() == beam) then
            damageInfo:SetDamage(0)
            return
         end
      end
   end

   if(self.isDestructing == false && self.isCombatSystemEnabled ~= true) then
      self.Entity:TakePhysicsDamage(damageInfo)

      self.Entity:SetHealth(self.Entity:Health() - damageInfo:GetDamage())

      if(self.Entity:Health() <= 0) then
         self:Destruct()
      end
   end
end

-- Destroys the gate overloader
function ENT:Destruct()
   if(self.isDestructing) then
      return
   end

   self.isDestructing = true

   local blastRadius = 200
   local blastDamage = self.energyPerSecond / 50

   destructEffect = EffectData()
	destructEffect:SetOrigin(self.Entity:GetPos())
   destructEffect:SetRadius(blastRadius / 2)
	destructEffect:SetMagnitude(self.energyPerSecond / 10)
	util.Effect("Explosion", destructEffect, true, true)

   local owner = self.Entity:GetVar("Owner", self.Entity)
   util.BlastDamage(self.Entity, owner, self.Entity:GetPos(), blastRadius, blastDamage)

	self.Entity:Remove()
end

-- Does cleanup if the gate overloader is being removed
function ENT:OnRemove()
	self:Disarm()
	self:StopFiring();
	if(self.beamSound) then
      self.beamSound:Stop()
   end

  --StarGate.UnregisterEntity(self)
  StarGate.WireRD.OnRemove(self)
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_weapon_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_overloader");
end

end