ENT.Type             = "anim"
ENT.Base             = "base_entity"

ENT.PrintName        = "Energy Beam"
ENT.Author           = "PyroSpirit"
ENT.Contact		      = "forums.facepunchstudios.com"

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile()

ENT.CAP_NotSave = true;

local cycleInterval = 0.25

-- Comment out the contents of this function to disable debugging messages
function ENT:DebugMsg(...)
	--Msg("energy_beam ", self:EntIndex(), ": ", ..., "\n")
end

function IsValid2(X)
	if (X && X:IsValid()) then
		return true
	else
		return false
	end
end

-- Beam --

ENT.speed = 1000
ENT.radius = 5
ENT.forward = Vector(0,0,0)
ENT.vector = Vector(0,0,0)
ENT.trace = nil
ENT.Laser = nil
ENT.colour = "255 255 255"
ENT.effect = nil

-- Beam Source --

ENT.Source = {}
ENT.Source.Entity = nil

-- Beam Start --

ENT.Start = {}
ENT.Start.offset = Vector(0,0,0)
ENT.Start.angle = Angle(0,0,0)
ENT.Start.Entity = nil

function ENT.Start:GetPos()
   if(IsValid2(self.Entity)) then
      local pos = self.Entity:GetPos()

      if(self.offset) then
         pos = pos + self.offset
      end

      return pos
   else
      error("energy_beam.Start.GetPos: Start entity is not valid.\n")
   end
end

function ENT.Start:GetForward()
   if(IsValid2(self.Entity)) then
      local forward = self.Entity:GetForward()

      if(self.angle) then
         forward = (forward:Angle() + self.angle):Forward()
      end

      return forward
   else
      error("energy_beam.Start.GetForward: Start entity is not valid.\n")
   end
end

function ENT.Start:IsValid()
   if(IsValid2(self.Entity)) then
      if(self.Entity:GetClass() ~= "event_horizon") then
         return true
      else
         local startGate = self.Entity:GetParent()

         return StarGate:IsIrisClosed(startGate) == false
      end
   else
      return false
   end
end

-- Beam End --

ENT.End = {}
ENT.End.Entity = nil

function ENT.End:GetPos()
   if(IsValid2(self.Entity)) then
      return self.Entity:GetPos()
   else
      return nil
   end
end

-- Damage --

ENT.Damage = {}
ENT.Damage.amount = 5
ENT.Damage.radius = 100

-- Sounds --

ENT.SoundPaths = {}
ENT.SoundPaths["active"] = Sound("StarGate/OutBeamLoop.wav")

ENT.Sounds = {}

-- Other --

-- Was the start entity valid last cycle?
ENT.wasStartValid = true
-- Is this entity immune from teleportation by stargate teleporters? (gates, rings, etc.)
ENT.NotTeleportable = true

function ENT:Initialize()
   if(self.Start.Entity == nil) then
      error(self:GetClass().." must have a start entity set.")
   elseif(self.Source.Entity == nil) then
      error(self:GetClass().." must have a source entity set.")
   end

   self.Entity:SetSolid(SOLID_NONE)
   self.Entity:SetNotSolid(true)
   self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
   self.Entity:SetGravity(0)
   self.Entity:DrawShadow(false)
   self.Entity:SetColor(Color(0, 0, 0, 0))
   self.LastThink = CurTime()
   self.Ftime = 0
end

function ENT:Think()

   local time = CurTime()
   self.Ftime = time-self.LastThink
   self.LastThink = time
   self.Entity:NextThink(time+0.2)

   local isSourceValid = self:IsSourceValid()
   local isStartValid = self.Start:IsValid()

   if(self:GetLength() > 0 ||
      (isSourceValid && isStartValid)) then

      self:Extend()
   end

   -- Stop beam continuity if source is no longer supplying the beam
   if(isSourceValid == false) then
      self.Source.Entity = nil

      self:DebugMsg("shrinking (source not valid)")
      self:Shrink()

      -- If beam has been shrunk down to length 0, destroy this entity
      if(self:GetLength() <= 0) then
         self:DebugMsg("removing (length 0)")
         self:Remove()
         return false
      end
   else
      -- If the beam's start entity is no longer valid, shrink the beam
      if(isStartValid == false) then
         self:DebugMsg("shrinking (start not valid)")
         self:Shrink()

         self.wasStartValid = false

         -- If the beam is completely gone, but the start entity still exists, do no more until the start entity becomes valid again
         -- If the start entity no longer exists, destroy the beam
         if(self:GetLength() <= 0) then
            if(IsValid2(self.Start.Entity) == false) then
               self:DebugMsg("removing (length 0 and start entity no longer exists)")
               self:Remove()
               return false
            end
         end
      elseif(self.wasStartValid == false) then
         self:Shrink()
         self:DebugMsg("shrinking (start was previously not valid)")

         local newBeam = ents.Create("energy_beam")
         newBeam:Setup(self.Source.Entity,
                       table.Copy(self.Start),
                       self.Damage,
                       self.speed,
                       self.colour,
                       self.effect)

         newBeam:Spawn()
         newBeam:Activate()

         -- Set the start entity to nil so that this code never runs again (we don't want to create multiple replacement beams)
         self.Start.Entity = nil
      else
         self:UpdateStartPos()

         self.wasStartValid = true
      end
   end

   return true
end

-- Sets up the energy beam.
-- source: The entity that created this beam (must have a trace variable or IsFiring function)
function ENT:Setup(source, Start, Damage, beamSpeed, beamColour, effectName, radius)
   local errHeader = "Error in "..self:GetClass()..":Setup, "

   local startEnt = Start.Entity or source

   self.Source.Entity = source or error(errHeader.."No source given.\n")

   self.Start.Entity = startEnt
   self.Start.offset = Start.offset or Vector(0,0,0)
   self.Start.angle = Start.angle or Angle(0,0,0)
   self.Entity:SetNetworkedEntity("startEnt", startEnt)

   self.forward = self.Start:GetForward()

   self.speed = beamSpeed or error(errHeader.."No speed given.\n")

   self.Damage = Damage or error(errHeader.."No damage table passed.\n")

   self.colour = beamColour or error(errHeader.."No beam colour given.\n")

   self.effect = effectName

   self.radius = radius or 5

   self:SetOwner(startEnt)
   self:SetVar("Owner", source:GetVar("Owner", source))

   self:UpdateStartPos()
end

-- Beam Functions --

function ENT:CreateLaser(owner)
   if(self.Start:IsValid() == false) then
      error("Start entity of energy_beam is not valid - cannot create env_laser.\n")
   end

   if(IsValid2(self.Laser)) then
      self:RemoveLaser()
   end

   local startPos = self.Start:GetPos()

   local beam = ents.Create("env_laser")
   self.Laser = beam

   beam:SetOwner(owner)
   beam:SetVar("Owner", owner)
   beam:SetKeyValue("texture", "cable/crystal_beam1.vmt")

   if(self.effect ~= nil) then
     beam:SetKeyValue("renderamt", "0")
   end

   beam:SetKeyValue("rendercolor", self.colour)
   beam:SetKeyValue("TextureScroll", "20")
   beam:SetKeyValue("width", self.radius * 2)
   beam:SetKeyValue("damage", self.Damage.amount)
   beam:SetKeyValue("dissolvetype", "2")

   self:UpdateStartPos()
   self:SetEndPos(startPos + self.Start:GetForward())

   --beam:SetParent(nil)
   beam:Spawn()
   --beam:SetParent(self.Start.Entity)

   beam:Fire("TurnOn", 1)

   if(self.effect ~= nil) then
      local beamInfo = EffectData()
	    beamInfo:SetOrigin(startPos)
      beamInfo:SetMagnitude(self.speed)
      beamInfo:SetNormal(self.forward)
      beamInfo:SetEntity(self.Entity)

      util.Effect(self.effect, beamInfo)
   end

   self.Sounds["active"] = CreateSound(self.Laser, self.SoundPaths["active"])

   if(self.Sounds["active"]) then
      self.Sounds["active"]:Play()
   end

   self:DebugMsg("created env_laser")
end

function ENT:RemoveLaser()
   if(self.Sounds["active"]) then
      self.Sounds["active"]:Stop()

      self:DebugMsg("stopped sound")
   end

   if(IsValid2(self.Laser)) then
      self.Laser:Fire("TurnOff", 1)
      self.Laser:Remove()
      self.Laser = nil

      self:DebugMsg("removed env_laser")
   end

   if(IsValid2(self.End.Entity)) then
      self.End.Entity:Remove()
      self.End.Entity = nil
   end
end

function ENT:SendPosToClient()
   if(IsValid2(self.Laser) == false || IsValid2(self.End.Entity) == false) then
      return
   end

   local startPos = self.Laser:GetPos()
   local endPos = self.End:GetPos()

   --umsg.Start("energy_beam_pos")
   --umsg.Vector(startPos)
   --umsg.Vector(endPos)
   --umsg.End()
end

function ENT:UpdateStartPos()
   if(self.Start:IsValid() == false) then
      return false
   end

   local startEnt = self.Start.Entity
   local currentStartPos = nil

   if(IsValid2(self.Laser)) then
      currentStartPos = self.Laser:GetPos()
   end

   local newStartPos = self.Start:GetPos()

   if(currentStartPos ~= newStartPos) then
      if(IsValid2(self.Laser)) then
        -- Add code here to offset newStartPos by self.radius in a direction
        -- derived from the current time. This will cause the laser to form a
        -- cylinder over a short period of time, which should adequately
        -- emulate a laser of the required radius.
        self.Laser:SetPos(newStartPos)
      end

      self.Entity:SetNetworkedVector("start", newStartPos)
      self:SendPosToClient()
   end

   self.forward = self.Start:GetForward()

   if(IsValid2(self.Laser)) then
      self.Laser:SetAngles(self.forward:Angle())
      self.Laser:SetParent(startEnt)
   end

   self:DebugMsg("updating start position to ", newStartPos)
   return true
end

function ENT:SetEndPos(pos)
   if(IsValid2(self.End.Entity) == false) then
      self.End.Entity = ents.Create("info_target")
      self.End.Entity:SetName("EnergyBeamEndpoint"..self.Entity:EntIndex())
      self.End.Entity:Spawn()
      self.End.Entity:Activate()
   end

  -- Add code here to offset pos by self.radius in a direction
  -- derived from the current time. This will cause the laser to form a
  -- cylinder over a short period of time, which should adequately
  -- emulate a laser of the required radius.

   if(pos ~= self.End.Entity:GetPos()) then
      self.End.Entity:SetPos(pos)

      self.Entity:SetNetworkedVector("end", pos)
      self:SendPosToClient()
   end

   local startPos = nil

   if(IsValid2(self.Laser)) then
      startPos = self.Laser:GetPos()
   elseif(IsValid2(self.Start.Entity)) then
      startPos = self.Start:GetPos()
   else
      error("energy_beam: cannot determine start position.\n")
   end

   self.vector = (pos - startPos)
   self.forward = self.vector:GetNormal()

   if(IsValid2(self.Laser)) then
      self.Laser:SetKeyValue("LaserTarget", self.End.Entity:GetName())
   end

   self:DebugMsg("updating end position to ", pos)
end

function ENT:GetLength()
   if(IsValid2(self.End.Entity) == false || IsValid2(self.Laser) == false) then
      return 0
   else
      return math.Round(self.End:GetPos():Distance(self.Laser:GetPos()))
   end
end

function ENT:IsSourceValid()
   local sourceEnt = self.Source.Entity

   if(IsValid2(sourceEnt)) then
      local canSourceFire = sourceEnt.IsFiring ~= nil
      local isSourceFiring = nil

      -- If the source entity isn't firing, then it isn't valid
      if(canSourceFire) then
         isSourceFiring = sourceEnt:IsFiring()

         if(isSourceFiring == false) then
            self:DebugMsg("source invalid - it is not firing")
            return false
         end
      end

      -- If the source entity has not yet started targetting, it is still valid
      if(sourceEnt.trace == nil && isSourceFiring == true) then
         return true
      elseif(sourceEnt.trace) then
         local traceEnt = sourceEnt.trace.Entity

         -- If the trace isn't aimed at an entity, return false, otherwise check whether the entity is this beam's source
         if(IsValid2(traceEnt)) then
            -- If source is firing into the EH that is linked to the EH this beam is coming from, return true, ELSE
            -- If source is firing at where this beam starts, return true, ELSE
            -- Return false if source is not aimed at a valid starting entity for this beam

            if(traceEnt:GetClass() == "event_horizon") then
               local remoteEH = traceEnt.Target

               if(remoteEH == self.Start.Entity) then
                  return true
               end
            elseif(traceEnt == self.Start.Entity) then
               return true
            else
               self:DebugMsg("source invalid - it is not aimed at a valid start entity")
               return false
            end
         else
            self:DebugMsg("source invalid - it is not aimed at anything")
            return false
         end
      else
         self:DebugMsg("source invalid - cannot determine if source is firing")
         return false
      end
   else
      self:DebugMsg("source invalid - it does not exist")
      return false
   end
end

function ENT:Extend()
   if(IsValid2(self.Laser) == false) then
      self:CreateLaser()
   end

   local newLength = self:GetLength() + (self.speed * self.Ftime)
   local beamVector = self.forward * newLength

   self:DebugMsg("extending beam length from ", self:GetLength(), " to ", newLength)

   local ignorableEntities = { self.Entity }
   local startEnt = self.Start.Entity

   if(IsValid2(startEnt)) then
      ignorableEntities = { self.Entity, startEnt, startEnt.EventHorizon }
   end

   local startPos = self.Laser:GetPos()
   local owner = self.Entity:GetVar("Owner", self.Entity)
   if not IsValid(owner) then return end

   -- self.trace = StarGate:ShieldTrace(startPos,
                                           -- beamVector,
                                           -- ignorableEntities,
                                           -- true)

	self.trace = StarGate.Trace:New(startPos,beamVector,ignorableEntities);

   local hitEnt = self.trace.Entity
   local hitPos = self.trace.HitPos

   self:SetEndPos(hitPos)

   StarGate:EmitHeat(hitPos,
                           (self.Damage.amount / 50) * self.Ftime,
                           self.Damage.radius,
                           owner)

   if(IsValid2(hitEnt)) then
      self:DebugMsg("has hit entity ", hitEnt)

      if(hitEnt:GetClass() == "shield" or hitEnt:GetClass() == "ship_shield") then
         hitEnt:Hit(self.Entity, hitPos, self.Damage.amount * self.Ftime, self.trace.Normal * -1)
	  elseif(hitEnt:GetClass() == "shield_core_buble") then
         hitEnt:Hit(self.Entity, hitPos, self.Damage.amount * self.Ftime, self.trace.Normal * -1)
      elseif(hitEnt:GetClass() == "event_horizon") then
         local remoteEH = hitEnt.Target

         if(startEnt ~= remoteEH && remoteEH ~= nil) then
            self:OnHitEventHorizon(hitEnt, hitPos)
         end
      elseif(CombatDamageSystem) then
         cds_disintigratepos(hitPos, 1, owner)
      elseif(gcombat) then
         gcombat.nrghit(hitEnt, self.Damage.amount * self.Ftime, self.Damage.amount, hitPos, hitPos)
      else
         hitEnt:TakeDamage(self.Damage.amount * self.Ftime, owner, self.Entity)
      end
   else
		if IsValid2(self.Entity) then
			util.BlastDamage(self.Entity,
                       owner,
                       hitPos,
                       self.Damage.radius,
                       self.Damage.amount * self.Ftime)
		end
   end
end

function ENT:OnHitEventHorizon(eventHorizon, hitPos)
  local remoteEH = eventHorizon.Target

  if remoteEH == nil then
    error("energy_beam hit an event horizon that has no endpoint - should be impossible!")
  end

  local teleportedPos, teleportedForward = StarGate:GetTeleportedVector(eventHorizon, remoteEH, hitPos, self.forward)

  local Start = {}
  Start.Entity = remoteEH
  Start.offset = teleportedPos - remoteEH:GetPos()
  Start.forwardOffset = teleportedForward:Angle() - remoteEH:GetForward():Angle()

  if(IsValid2(self.RemoteGateBeam) == false ||
     self.RemoteGateBeam.Start.Entity ~= remoteEH) then
     self.RemoteGateBeam = ents.Create("energy_beam")

    self.RemoteGateBeam:Setup(self,
                              Start,
                              self.Damage,
                              self.speed,
                              self.colour)
  else
    self.RemoteGateBeam.Start = Start
  end

  self:DebugMsg("has entered event horizon")
end

function ENT:Shrink()
   if(IsValid2(self.Laser) == false) then
      return false
   end

   local beamLength = self:GetLength()
   local speedPerCycle = self.speed*self.Ftime

   if(beamLength <= 0) then
      self:RemoveLaser()
      return false
   elseif(speedPerCycle > beamLength) then
      speedPerCycle = beamLength
   end

   local forward = self.vector:GetNormal()
   local newStartPos = self.Laser:GetPos() + (forward * speedPerCycle)

   self.Laser:SetParent(nil)
   self.Laser:SetPos(newStartPos)
   self.Entity:SetNetworkedVector("start", newStartPos)

   local newLength = self:GetLength()

   self:DebugMsg("shrinking beam length from ", beamLength, " to ", newLength)

   if(newLength <= 0) then
      self:RemoveLaser()
   end

   return true
end

function ENT:OnTakeDamage(DmgInfo)
   DmgInfo:SetDamage(0)
end

function ENT:OnRemove()
   self:RemoveLaser()
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("energy_beam", SGLanguage.GetMessage("energy_beam_kill"))
end

function ENT:GetStartEntity()
   return self.Entity:GetNetworkedEntity("startEnt", nil)
end

function ENT:GetStartPos()
   return self.Entity:GetNetworkedVector("start", self.Entity:GetPos())
end

function ENT:GetEndPos()
   return self.Entity:GetNetworkedVector("end", self:GetStartPos())
end

end