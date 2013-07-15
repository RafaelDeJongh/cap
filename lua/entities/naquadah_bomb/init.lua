if (not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.SoundPaths = {}
ENT.SoundPaths["charge_start"] = Sound("weapons/overloader_charge.wav")
ENT.SoundPaths["charge_ambient"] = Sound("dakara/dakara_background.wav")
ENT.SoundPaths["code_accepted"] = Sound("buttons/button9.wav")
ENT.SoundPaths["code_rejected"] = Sound("buttons/button8.wav")

ENT.Sounds = {}

function ENT:Initialize()
  -- Bomb starts disarmed
  self:SetNetworkedInt("State", 1) --  1 = Idle ,  2 = Armed,  3 = Charging
  self.charge = 0

  -- Set up physics for entity
  local thisPhysics = self.Entity:GetPhysicsObject()

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

   -- Set up wire inputs and outputs
	if(self.HasWire) then
		self:CreateWireInputs("Detonate", "Abort", "Detonation Code [STRING]", "Abort Code [STRING]", "Time to Destruct")
		self:CreateWireOutputs("Charging", "Charge", "Countdown Timer")
	end

	self.Sounds["ambient"] = CreateSound(self.Entity, self.SoundPaths["charge_ambient"])
end

function ENT:Setup(detonationCode, abortCode,  yield, chargeTime, hud, cart)

	if(self.charging) then return false end;

	--DebugMsg("Setup detCode: "..tostring(detonationCode).." Abort: "..tostring(abortCode).."\n")
	self.detonationCode = detonationCode or "1"
	self.abortCode = abortCode or "2"
	self.yield = math.Clamp(yield, 10, 100)
	self.chargeTime = math.max(chargeTime, 10)

	if(self.HasWire) then
		self:SetWire("Charging", 0)
		self:SetWire("Charge", 0)
		self:SetWire("Countdown Timer", 0)
	end

	self:SetNWBool("Hud", hud)
	if cart and not IsValid(self.Cart) then
		if(self:GetModel()==("models/markjaw/gate_buster.mdl")) then
			local ent = ents.Create("prop_physics");
			ent:SetModel("models/MarkJaw/gate_buster_cart.mdl");
			ent:SetAngles(self.Entity:GetAngles());
			ent:SetPos(self.Entity:GetPos()-Vector(0,0,25));
			ent:Spawn();
			ent:Activate();
			constraint.Weld(self.Entity,ent,0,0,0,true)
			self.Cart = ent;
		end
   end

   return true
end

function ENT:TriggerInput(inputName, inputValue)
    --if(self.malfunctioning ~= true) then
        if(inputName == "Detonate" and inputValue >= 1) then
            self:StartDetonation(self:GetWire("Detonation Code",""))
        elseif(inputName == "Abort" and inputValue >= 1) then
            self:AbortDetonation(self:GetWire("Abort Code",""))
        elseif(not self.charging and inputName == "Time to Destruct" and inputValue >= 1) then
            self.chargeTime = math.max(inputValue, 10)
        end
   -- end
end

function ENT:StartDetonation(code)
   if(self:GetNetworkedInt("State", 1) == 3) then
		return true
   end

   if( not self:IsDetonationCode(code)) then
      return false
   end

      self:SetNWInt("State", 3)

      if(self.HasWire) then
         self:SetWire("Charging", 1)
      end

      self.Entity:EmitSound(self.SoundPaths["charge_start"])
      self.Sounds["ambient"]:Play()

      return true
end

function ENT:AbortDetonation(code)
	if(self:GetNWInt("State", 1) ~= 3) then
		return true
   end

   if( not self:IsAbortCode(code)) then
      return false
   end

	--if(not self.malfunctioning) then
      self:SetNWInt("State", 2)
      self.charge = 0
	  self.Entity:SetNetworkedInt("BombOverlayTime",0)

      if(self.HasWire) then
         self:SetWire("Charging", 0)
         self:SetWire("Charge", self.charge)
         self:SetWire("Countdown Timer", 0)
      end

      self.Entity:StopSound(self.SoundPaths["charge_start"])
      self.Sounds["ambient"]:Stop()

      return true
   --end
end

function ENT:IsDetonationCode(code)
   if(code == self.detonationCode) then
      self.Entity:EmitSound(self.SoundPaths["code_accepted"])
      return true
   else
      self.Entity:EmitSound(self.SoundPaths["code_rejected"])
      return false
   end
end

function ENT:IsAbortCode(code)
	if(code == self.abortCode) then
		self.Entity:EmitSound(self.SoundPaths["code_accepted"])
		return true
	else
		self.Entity:EmitSound(self.SoundPaths["code_rejected"])
		return false
	end
end

-- Make local to avoid overriding any identically named functions in other scripts
local function ReceiveDetonationCommand(Player, command, args)
   local bomb = ents.GetByIndex(args[1])

   --DebugMsg("naquadah_bomb: Received Detonation Code: "..args[2].."\n")
   if(bomb and bomb.StartDetonation) then
      bomb:StartDetonation(args[2])
   end
end

concommand.Add("StartDetonation", ReceiveDetonationCommand)

-- Make local to avoid overriding any identically named functions in other scripts
local function ReceiveAbortCommand(Player, command, args)
   local bomb = ents.GetByIndex(args[1])

   --DebugMsg("naquadah_bomb: Received Abort Code: "..args[2].."\n")
   if(bomb and bomb.AbortDetonation) then
      bomb:AbortDetonation(args[2])
   end
end

concommand.Add("AbortDetonation", ReceiveAbortCommand)

function ENT:OnTakeDamage(damageInfo)
    if self:GetNWInt("State", 1) == 4 then return end
	self.Entity:SetHealth(self.Entity:Health() - damageInfo:GetDamage())

    if(self.Entity:Health() <= 0) then
        self:Destruct()
    end
end

function ENT:Damage()
   local effectInfo = EffectData()
   effectInfo:SetStart(self.Entity:GetPos())

   util.Effect("StunstickImpact", effectInfo)
end

function ENT:Repair()
    self.Entity:SetHealth(self.Entity:GetMaxHealth())
end

-- Destroy bomb (without detonating warhead)
function ENT:Destruct()
   -- Make bomb explode (without warhead detonation)
	self:SetNWInt("State", 4)

	self.Entity:Remove()
	if IsValid(self.Cart) then self.Cart:Remove(); end
	destructEffect = EffectData()
	destructEffect:SetOrigin(self.Entity:GetPos())
	destructEffect:SetScale(1 + (self.charge / 100))
	destructEffect:SetMagnitude(50 + self.charge)
	util.Effect("Explosion", destructEffect, true, true)

	local bombOwner = self.Entity:GetVar("Owner", self.Entity)
	local blastRadius = 100 + (self.charge * 5)
	local blastDamage = 50 + self.charge
	util.BlastDamage(self.Entity, bombOwner, self.Entity:GetPos(), blastRadius, blastDamage)
end

-- Detonate warhead
function ENT:Detonate()
   local warhead = ents.Create("gate_nuke")

   if(warhead ~= nil and warhead:IsValid()) then
      warhead:Setup(self.Entity:GetPos(), self.yield)
      warhead:SetVar("owner",self.Owner)
      warhead:Spawn()
      warhead:Activate()
   end

   self.Entity:Remove()
   if IsValid(self.Cart) then self.Cart:Remove(); end
end

function ENT:ShakeCamera(strength, duration, radius)
   local shake = ents.Create("env_shake")

   shake:SetKeyValue("amplitude", strength)
	shake:SetKeyValue("duration", duration)
	shake:SetKeyValue("radius", radius)
	shake:SetKeyValue("frequency", "240")
	shake:SetPos(self.Entity:GetPos())

	shake:Spawn()
	shake:Fire("StartShake","","0")
	shake:Fire("kill", "", duration + 2)
end

function ENT:OnRemove()
  self.Sounds["ambient"]:Stop()
    if IsValid(self.Cart) then self.Cart:Remove(); end
  StarGate.WireRD.OnRemove(self)
end

function ENT:Think()

   if(self:GetNWInt("State", 1) == 3) then
		self.Entity:SetNetworkedString("BombOverlay","Charging!")
		self:Charge()
		local explodetime = self.chargeTime * ((100-self.charge)/100)+1;
		self.Entity:SetNetworkedInt("BombOverlayTime",explodetime)
   elseif(self.malfunctioned) then
      self:StartDetonation()
   else
	  self.Entity:SetNetworkedString("BombOverlay","Armed")
   end

   if(self.Entity:Health() < self.Entity:GetMaxHealth()) then
      if(self.Entity:Health() <= 0) then
         self:Destruct()
      elseif(math.random(1, self.Entity:Health()) == 1) then
         self.malfunctioned = true
      end

      -- Display damage effects
      self:Damage()
   end

	self.Entity:NextThink(CurTime() + 1)
   return true
end

function ENT:Charge()
   if(self.charge >= 100) then
      self:Detonate()
      return
   end

   self.charge = self.charge + (100 / self.chargeTime)

   if(self.HasWire) then
		self:SetWire("Charge", self.charge)
		self:SetWire("Countdown Timer", self.chargeTime * ((100-self.charge)/100)+1)
   end

   self:ShakeCamera(16 * (self.charge / 100),
                    1,
                    (self.yield * 50) * (self.charge / 100))

   return true
end

function ENT:AcceptInput(inputType, activator, caller)
	if(inputType == "Use" &&
      caller:IsPlayer() &&
      caller:KeyDownLast(IN_USE) == false) then

      umsg.Start("naquadah_bomb", caller)
      umsg.Entity(self.Entity)
      umsg.Bool(true)
      umsg.End()
	end
end
