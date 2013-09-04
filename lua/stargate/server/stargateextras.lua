-- Registers an entity with the system
function StarGate.RegisterWithDamageSystem(entity)
   if(CombatDamageSystem) then
      CDS_Spawned(entity)
      return true
   elseif(gcombat) then
      gcombat.registerent(entity, entity:Health())
      return true
   else
      return false
   end
end

function StarGate.Think()

end

function StarGate.DrawGateHeatEffects(gate)
   StarGate.TintGate(gate)

   if(gate.excessPower) then
      -- The amount of excess power required to destabalise the stargate
      local destabalisingExcessPower = 3 * (gate.excessPowerLimit / 4)

      if(gate.excessPower >= destabalisingExcessPower) then
         -- Chance of the gates flickering if excessPower is at least 3/4 of the limit
         if(math.random(0, gate.excessPower) >= destabalisingExcessPower) then
            if(gate.malfunction) then
               gate.malfunction:Fire("DoSpark","",0)
            end

            StarGate.MakeGateFlicker(gate)
         end
      end
   end
end

function StarGate.MakeGateFlicker(gate)
   local remoteGate = StarGate.GetRemoteStargate(gate)

   if(remoteGate == nil || remoteGate:IsValid() == false) then
      return false
   end

   if(gate.Flicker) then
      gate:Flicker()
      remoteGate:Flicker()
   elseif(gate.EventHorizon) then
      gate.EventHorizon:SetColor(Color(150, 150, 150, 255))
      remoteGate.EventHorizon:SetColor(Color(150, 150, 150, 255))

      local function resetColour(entity)
         if(entity && entity:IsValid()) then
            entity:SetColor(Color(255, 255, 255, 255))
         end
      end

      timer.Simple(0.5, function() resetColour(gate.EventHorizon) end)
      timer.Simple(0.5, function() resetColour(remoteGate.EventHorizon) end)
   end
end

function StarGate.StopUpdateGateTemperatures(gate)
	if timer.Exists("UpdateGateTemp"..gate:EntIndex()) then timer.Destroy("UpdateGateTemp"..gate:EntIndex()) end
end

function StarGate.UpdateGateTemperatures(gate)
	 timer.Create("UpdateGateTemp"..gate:EntIndex(), StarGate.CYCLE_INTERVAL, 0, function()
   -- for _, gate in pairs(ents.FindByClass("stargate*")) do
      local shouldCoolGate = true

      for _, overloader in pairs(ents.FindByClass("gate_overloader")) do
         if(overloader.remoteGate == gate) then
            shouldCoolGate = false
         end
      end

      if(shouldCoolGate) then
         StarGate.CoolGate(gate)
      end

      StarGate.DrawGateHeatEffects(gate)
      StarGate.CauseHeatDamage(gate)
   end);
end

function StarGate.CoolGate(gate)
   if(gate == nil) then
      Msg("Gate passed to CoolGate(gate) cannot be nil.\n")
      return flase
   elseif(gate.excessPower == nil || gate.excessPower <= 0) then
      return false
   end

   -- The amount of energy lost as the gate cools
   local energyDissipated = math.min(StarGate.COOLING_PER_CYCLE, gate.excessPower)

   -- Dissipate some of the excess power
   gate.excessPower = gate.excessPower - energyDissipated

   if(StarGate.HasResourceDistribution) then
      -- Reduce the amount of energy the gate can store by the amount dissipated
      -- This will result in the gate returning to its original energy capacity once it has completely cooled
      StarGate.WireRD.AddResource(gate, "energy", StarGate.GetStargateEnergyCapacity(gate) - energyDissipated)
   end

   return true
end

function StarGate.TintGate(gate)
   if(gate == nil || gate:IsValid() == false) then
      Msg("Gate passed to StarGate.TintGate was not valid.\n")
      return
   elseif(gate.excessPower == nil) then
      return
   end

   if(gate.excessPower < 0) then
      gate.excessPower = 0
   end

   local tintAmount = 255 * (gate.excessPower / gate.excessPowerLimit)

   -- fix for universe stargate by AlexALX
   if (gate:GetClass()=="stargate_universe" and IsValid(gate.Gate) and IsValid(gate.Chevron)) then
		gate.Gate:SetColor(Color(255, 255 - tintAmount, 255 - tintAmount, 255))
		gate.Chevron:SetColor(Color(255, 255 - tintAmount, 255 - tintAmount, 255))
	    for i=1,45 do
		    local c = gate.Symbols[i]:GetColor();
		    gate.ColR[i] = 255;
			gate.ColG[i] = 255 - tintAmount;
			gate.ColB[i] = 255 - tintAmount;
		    if(c.g != 40 and c.b != 40)then
		        gate.Symbols[i]:SetColor(Color(255, 255 - tintAmount, 255 - tintAmount, 255));
          	end
		end
   elseif (gate:GetClass()!="stargate_universe") then
      gate:SetColor(Color(255, 255 - tintAmount, 255 - tintAmount, 255))
   end

   if(gate.chevron7) then
      gate.chevron7:SetColor(Color(255, 255 - tintAmount, 255 - tintAmount, 255))
   end

   local iris = StarGate.GetIris(gate)

   if(StarGate.IsEntityValid(iris)) then
      tintAmount = math.min(tintAmount * 2, 128)

      --Msg("Setting ", iris, " colour(255, ", 255 - tintAmount, ", ", 255 - tintAmount, ")\n")
      iris:SetColor(Color(255, 255 - tintAmount, 255 - tintAmount, 255))
   end
end

function StarGate.EmitHeat(pos, damage, radius, inflictor)
   if(CombatDamageSystem) then
      cds_heatpos(pos, damage, radius)
      return true
   elseif(gcombat) then
      gcombat.emitheat(pos, radius, damage, inflictor)
      return true
   else
      return false
   end
end

function StarGate.HeatEntity(entity, damage, radius, inflictor)
   if(StarGate.EmitHeat(entity:GetPos(), damage, radius, inflictor)) then
      return true
   else
      if(entity.burnInflictor == nil) then
         local burnInflictor = ents.Create("point_hurt")
         burnInflictor:SetOwner(inflictor)
         burnInflictor:SetPos(StarGate.GetEntityCentre(entity))
         burnInflictor:SetKeyValue("DamageDelay", 0.2)
         burnInflictor:SetKeyValue("DamageType", 8) -- Burn damage

         burnInflictor:Spawn()
         burnInflictor:Activate()
         burnInflictor:SetParent(entity)

         entity.burnInflictor = burnInflictor
      end

      entity.burnInflictor:SetKeyValue("DamageRadius", radius)
      entity.burnInflictor:SetKeyValue("Damage", damage)
   end
end

function StarGate.CoolEntity(entity)
   if(entity.burnInflictor) then
      entity.burnInflictor:Remove()
      entity.burnInflictor = nil
   end
end

function StarGate.CauseHeatDamage(gate)
   if(gate == nil) then
      Msg("Gate passed to CauseHeatDamage(gate) cannot be nil.\n")
      return false
   elseif(gate.excessPower == nil) then
      return false
   end

   if(gate.excessPower > gate.excessPowerLimit / 2 and IsValid(gate.overloader)) then
      -- Make gate cause damage to nearby players due to extreme heat
      local heatDamage = math.Round(2 * (gate.excessPower / gate.excessPowerLimit))
      local heatRadius = 500 * (gate.excessPower / gate.excessPowerLimit)
      local overloaderOwner = gate.overloader:GetVar("Owner", gate.overloader:GetOwner())

      StarGate.HeatEntity(gate, heatDamage, heatRadius, overloaderOwner)

      if(gate.excessPower > 3 * (gate.excessPowerLimit / 4)) then
         for _, entity in pairs(ents.FindInSphere(StarGate.GetEntityCentre(gate), heatRadius)) do
            if(entity ~= gate) then
               entity:Ignite(2, 25)
            end
         end
      end

      return true
   else
      StarGate.CoolEntity(gate)
      return false
   end
end

-- Jams the given gate, preventing it from closing the current connection
-- Also overrides USE key behaviour on the gate so that this key instead toggles the iris
-- Returns: whether the gate could be jammed
function StarGate.JamRemoteGate(gate)
   if(gate == nil || gate:IsValid() == false) then
      Msg("The stargate passed to JamRemoteGate(gate) is not valid.\n")
      return false
   elseif(StarGate.IsStargateOpen(gate) == false ||
          StarGate.IsStargateOutbound(gate)) then
      Msg("The stargate passed to JamRemoteGate(gate) does not have an outbound wormhole open.\n")
      return false
   elseif(gate.jammed == true) then
      return true
   end

   function DummyFunction(...)
      return false
   end

   -- Override remote gate's functions to prevent shutdown

   gate.backups = {}

   gate.backups.AcceptInput = gate.AcceptInput
   gate.AcceptInput = DummyFunction

   -- Do not simply disable pressing the 'use' key on a gate - instead make this toggle the iris (the one function of the remote gate that should not be disabled)
   /*gate.backups.Use = gate.Use
   gate.Use = function()
      if(gate.Iris) then -- If new iris exists on gate
         gate.Iris:Toggle()
      elseif(gate.irisclosed == true) then -- If old gate and iris is closed
         gate:OpenIris(true)
      elseif(gate.irisclosed == false) then -- If old gate and iris is open
         gate:OpenIris(false)
      end
   end */

   gate.backups.EmergencyShutdown = gate.EmergencyShutdown
   gate.EmergencyShutdown = DummyFunction

   gate.backups.DeactivateStargate = gate.DeactivateStargate
   gate.DeactivateStargate = DummyFunction

   gate.backups.Close = gate.Close
   gate.Close = DummyFunction

   gate.backups.ActivateStargate = gate.ActivateStargate
   gate.ActivateStargate = DummyFunction

   gate.backups.Open = gate.Open
   gate.Open = DummyFunction

   gate.backups.auto_close = gate.auto_close
   gate.auto_close = false

   gate.jammed = true

   local localGate = StarGate.GetRemoteStargate(gate)

   localGate.backups = {}

   -- Override local gate's functions to un-jam the remote gate when the connection is closed locally

   localGate.backups.AcceptInput = localGate.AcceptInput
   localGate.AcceptInput = function(name, activator, caller)
      if(activator == "Use" || name == nil) then
         return
      end

      StarGate.UnJamGate(localGate)
      localGate:AcceptInput(name, activator, caller)
   end

   -- For compatibility with UnJamGate
   --localGate.backups.Use = localGate.Use

   localGate.backups.EmergencyShutdown = localGate.EmergencyShutdown
   localGate.EmergencyShutdown = DummyFunction

   localGate.backups.DeactivateStargate = localGate.DeactivateStargate
   localGate.DeactivateStargate = DummyFunction

   localGate.backups.ActivateStargate = localGate.ActivateStargate
   localGate.ActivateStargate = function(inbound, fast)
      StarGate.UnJamGate(StarGate.GetRemoteStargate(localGate))
      localGate:ActivateStargate(inbound, fast)
   end

   localGate.backups.Open = localGate.Open
   localGate.Open = DummyFunction

   localGate.backups.Close = localGate.Close
   localGate.Close = DummyFunction

   localGate.backups.auto_close = localGate.auto_close
   localGate.auto_close = false

   localGate.jammed = true

   return true
end

function StarGate.UnJamGate(gate)
   if(gate == nil) then
      Msg("The stargate passed to UnJamGate(gate) cannot be nil.\n")
      return false
   elseif(gate:IsValid() == false) then
      return false
   elseif(gate.jammed ~= true || gate.backups == nil) then
      return true
   end

   gate.AcceptInput = gate.backups.AcceptInput
   --gate.Use = gate.backups.Use -- create crash now when activate gate after UnJamGate, havn't ideas why
   gate.EmergencyShutdown = gate.backups.EmergencyShutdown
   gate.DeactivateStargate = gate.backups.DeactivateStargate
   gate.Close = gate.backups.Close
   gate.ActivateStargate = gate.backups.ActivateStargate
   gate.Open = gate.backups.Open
   gate.auto_close = gate.backups.auto_close

   gate.jammed = false

   return StarGate.UnJamGate(StarGate.GetRemoteStargate(gate))
end

function StarGate.JamDHD(dhd, duration)
   if(dhd == nil) then
      Msg("The DHD passed to JamDHD(dhd) cannot be nil.\n")
      return false
   elseif(dhd:IsValid() == false) then
      return false
   end

   if(dhd.SetBusy) then
      dhd:SetBusy(duration)
   else
      dhd.busy = true
   end

   return true
end

function StarGate.UnJamDHD(dhd)
   if(dhd == nil) then
      Msg("The DHD passed to UnJamDHD(dhd) cannot be nil.\n")
      return false
   elseif(dhd:IsValid() == false) then
      return false
   end

   dhd.busy = false
   return true
end

function StarGate.GetGateMarker(gate)
   if(gate == nil) then
      Msg("Gate passed to GetGateMarker(gate) cannot be nil.\n")
      return
   end

   if(gate.centreMarker == nil) then
      gate.centreMarker = ents.Create("info_target")
      gate.centreMarker:SetPos(StarGate.GetEntityCentre(gate))
      gate.centreMarker:SetName("GateMarker"..gate:EntIndex())
      gate.centreMarker:Spawn()
      gate.centreMarker:SetParent(gate)
   end

   return gate.centreMarker
end

function StarGate.GetStargateEnergyCapacity(gate)
   if(StarGate.HasResourceDistribution && (gate.resources || gate.resources2)) then
      return StarGate.WireRD.GetUnitCapacity(gate, "energy")
   else
      return gate.capacity
   end
end

function StarGate.SetStargateEnergyCapacity(gate, capacity)
   if(StarGate.HasResourceDistribution) then
      StarGate.WireRD.AddResource(gate, "energy", capacity)
   end

   gate.capacity = capacity
end

function StarGate.MakeStargateUseEnergy(gate)
   if(gate.IsStargate ~= true) then
      return
   end

   local gateCapacity = StarGate.STARGATE_DEFAULT_ENERGY_CAPACITY
   local energyDrain = StarGate.STARGATE_DEFAULT_ENERGY_DRAIN
   local rechargeTime = 300

   StarGate.SetStargateEnergyCapacity(gate, gateCapacity)

   gate.backups.Think = gate.Think
   gate.Think = function()
      if(StarGate.IsStargateOutbound(gate)) then
         local energyConsumed = 0

         if(StarGate.HasResourceDistribution) then
            energyConsumed = StarGate.WireRD.ConsumeResource(gate, "energy", energyDrain)
         else
            energyConsumed = math.min(energyDrain, gate.energy)
            gate.energy = gate.energy - energyConsumed
         end

         if(energyConsumed < energyDrain) then
            gate:DeactivateStargate()
         end
      elseif(!StarGate.HasResourceDistribution) then
         gate.energy = math.min(gate.energy + (gateCapacity * StarGate.CYCLE_INTERVAL / rechargeTime), gateCapacity)
      end

      gate.backups.Think(gate)
      gate:SetNextThink(CurTime() + StarGate.CYCLE_INTERVAL)
   end

   gate.backups.ActivateStargate = gate.ActivateStargate
   gate.ActivateStargate = function(...)
      gate.backups.ActivateStargate(gate, ...)

      if((StarGate.HasResourceDistribution && StarGate.WireRD.GetResource(gate, "energy") <= 0) ||
         (gate.energy && gate.energy <= 0)) then
         if (IsValid(gate.overloader)) then
         	gate.overloader:StopFiring();
         end
         gate:EmergencyShutdown()
      end
   end
end

-- Credit to aVoN for this function originally
-- Has since been cleaned up and modified to work with both old and new gates
function StarGate.DestroyStargate(gate)
	if(!StarGate.IsStargateDialling(gate) &&
      (gate.last_vaporize == nil || gate.last_vaporize + 10 < CurTime())) then
		gate.last_vaporize = CurTime()

		if(gate.use_nuke == nil || gate.use_nuke == true) then
         local nuke = ents.Create("gate_nuke")

         if(nuke and nuke:IsValid()) then
            nuke:Setup(StarGate.GetEntityCentre(gate), 100)
            nuke:Spawn()
            nuke:Activate()
         end
      else
			local gatePos = StarGate.GetEntityCentre(gate)

         local fx = EffectData()
   		fx:SetOrigin(gatePos)
   		util.Effect("Unstable_Explosion", fx)

         util.BlastDamage(gate.Entity, gate, gatePos, 2048, 1000)
		end

    StarGate.UnJamGate(gate)
    if (IsValid(StarGate.GetRemoteStargate(gate))) then
   		StarGate.GetRemoteStargate(gate):DeactivateStargate(true)
    end
		gate:DeactivateStargate(true)

		if(StarGate.IsProtectedByGateSpawner(gate) == false) then
			for _, dhd in pairs(gate:FindDHD(true)) do
				if(StarGate.IsProtectedByGateSpawner(dhd) == false) then
					dhd:Remove()
				end
			end

         timer.Simple(1, function() if (IsValid(gate)) then gate:Remove() end end, nil)
		else
         gate.excessPower = 0
         gate.isOverloading = false -- Reset this so that the gate can be overloaded again in the future
		end
	end
end

function StarGate.GetIris(gate)
   if(gate.iris) then
      return gate.iris
   elseif(StarGate.IsEntityValid(gate.Iris)) then
      return gate.Iris
   end

   for _, entity in pairs(ents.FindInSphere(gate:GetPos(), 10)) do
      if(entity.IsIris) then
         return entity
      end
   end

   return nil
end

function StarGate.IsIrisClosed(gate)
   return gate.irisclosed == true || (gate.IsBlocked && gate:IsBlocked(true) == true)
end