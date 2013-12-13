ENT.Type = "anim"

ENT.PrintName        = "Dakara Energy Wave"
ENT.Author           = "PyroSpirit, Madman07 (recoded for cap)"
ENT.Contact		      = "forums.facepunchstudios.com"

ENT.Spawnable        = false
ENT.AdminSpawnable   = false

ENT.RenderGroup = RENDERGROUP_BOTH

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("dakara_wave", SGLanguage.GetMessage("dakara_energy_kill"))
end

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile();

ENT.CAP_NotSave = true;

local Planets = {}

for _, logicEnt in pairs(ents.FindByClass("logic_case")) do
   if(logicEnt:GetKeyValues()["Case01"] == "planet") then
      table.insert(Planets, logicEnt)
   end
end

ENT.immuneEnts = {}
ENT.radius = 0
ENT.cycleInterval = 0.1
ENT.CanPropagate = false;
ENT.ExpansionRate = 100;
ENT.MaxRadius = 20000;
ENT.SafeZoneRadius = 2000;
ENT.IsShieldPiercing = false;
ENT.Sounds = {}

function ENT:Initialize()
	self.Entity:SetModel("models/zup/shields/1024_shield.mdl")
	self:SetColor(Color(0,0,0,0));
	self:SetRenderMode(RENDERMODE_TRANSALPHA);
	self:DrawShadow(false)
    self.disintegrator = ents.Create("env_entity_dissolver")
    self.disintegrator:SetKeyValue("magnitude", "1")
    self.disintegrator:SetKeyValue("dissolvetype", "0")
    self.disintegrator:SetPos(self:GetPos())
    self.disintegrator:Spawn()
    self.disintegrator:Activate()
	timer.Create("WaveExpanding"..self:EntIndex(),self.cycleInterval,0,function()
		if IsValid(self) then self.radius = self.radius + self.ExpansionRate end
	end);
	local effectInfo = EffectData();
		effectInfo:SetEntity(self.Entity);
		effectInfo:SetMagnitude(self.MaxRadius/1000);
    util.Effect("dakara_wave", effectInfo);
end

function ENT:Setup(centre, immuneEnts, target, propagate, maxradius)
   self.Target = target;
   self:SetPos(centre)
   self.immuneEnts = immuneEnts or {}
   self.CanPropagate = propagate;
   self.MaxRadius = maxradius;
end

function ENT:ExpandWave()
   if(self.radius > self.MaxRadius) then
      self:End()
      return false
   end

   self:DisintegrateTargets()
   self:HitShields()

   return true
end

function ENT:DisintegrateTargets()
   for _, entity in pairs(ents.FindInSphere(self:GetPos(), self.radius)) do
      local isValidTarget = (self:IsValidTarget(entity) && entity:GetPhysicsObject():IsValid()) -- So it doesn't dissolve stuff like info player start.

      if isValidTarget then
         for _, immuneEnt in pairs(self.immuneEnts) do
            if (entity == immuneEnt) then
               isValidTarget = false
               break
            end
         end

         local isProtectedByShield = self.IsShieldPiercin == false &&
                                     StargateExtras:IsEntityShielded(entity) == true

         if(isProtectedByShield == false) then
            if(isValidTarget && self:IsEntityATarget(entity)) then
               Msg("dakara_wave: destroying ", entity, "\n")

               if(entity.Rep_AI_Disassemble) then
                  entity:Rep_AI_Disassemble()
               elseif(entity:IsPlayer()) then
                  entity:Kill()
               else
                  self.disintegrator:SetPos(entity:GetPos())
                  entity:SetName(tostring(entity))
                  self.disintegrator:Fire("Dissolve", entity:GetName(), 0)
               end
            elseif (entity.IsStargate and self.CanPropagate) then self:PropagateThroughGate(entity)
            end
         end

         if(entity:GetClass() ~= "shield" || self.IsShieldPiercing == true) then
            entity.isHitByDakaraWave = true

            local waveDuration = ((self.MaxRadius - self.radius) /
                                  self.ExpansionRate) *
                                 self.cycleInterval

            timer.Simple(waveDuration,
                         function()
                         	if (IsValid(entity)) then
                            	entity.isHitByDakaraWave = false
                            end
                         end)
         end
      end
   end
end

function ENT:PropagateThroughGate(gate)
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and v!=gate and v:GetClass() != "stargate_supergate" and v:GetClass() != "stargate_orlin" and v:GetClass() != "stargate_universe" and not v.GateGalaxy) then
			local wave = ents.Create("dakara_wave")
			wave:Setup(v:GetPos(), self.immuneEnts, self.Target, false, self.MaxRadius)
			wave:Spawn()
			wave:Activate()
		end
	end
end

function ENT:HitShields()
   for _, entity in pairs(ents.FindInSphere(self:GetPos(), self.radius)) do
      if(entity.isHitByDakaraWave ~= true) then
         if(self.IsShieldPiercing == false && entity:GetClass() == "shield") then
            local distanceToEnt = (entity:GetPos() - self:GetPos()):Length()
            local waveRadiusNeededToEncompassShield = distanceToEnt + entity.Size

            if(self.radius >= waveRadiusNeededToEncompassShield) then
               local waveDuration = (self.MaxRadius / self.ExpansionRate) *
                                    self.cycleInterval

               entity.Parent.Strength = 0
               entity.isHitByDakaraWave = true

               timer.Simple(waveDuration,
                            function()
                               entity.isHitByDakaraWave = false
                            end)
            else
               entity.Parent.Strength = math.ceil(entity.Parent.Strength / 2)
            end

            entity:Hit(self.Entity, entity:NearestPoint(self:GetPos()))
         end
      end
   end
end

function ENT:IsEntityATarget(entity)
   local entityClass = entity:GetClass()

	for _, targetType in pairs(self.Target) do
		if(string.find(entityClass, targetType)) then return true end
	end

   return false
end

function ENT:IsValidTarget(entity)
   local entDistance = entity:GetPos():Distance(self:GetPos())
   local isAtEdgeOfWave = entDistance >= self.radius - (self.ExpansionRate * 2)
   local isInSafeZone = entDistance <= self.SafeZoneRadius
   local hasParent = IsValid(entity:GetParent())

   return isAtEdgeOfWave == true &&
          isInSafeZone == false &&
          entity.isHitByDakaraWave ~= true &&
          entity:IsWorld() == false &&
          hasParent == false &&
          self:IsPlanet(entity) == false
end

function ENT:IsPlanet(entity)
   for _, planet in pairs(Planets) do
      if(planet:GetPos() == entity:GetPos()) then
         return true
      end
   end

   return false
end

function ENT:End()
	if timer.Exists("WaveExpanding"..self:EntIndex()) then timer.Destroy("WaveExpanding"..self:EntIndex()) end

	for _, entity in pairs(ents.FindInSphere(self:GetPos(), self.radius)) do
		entity.isHitByDakaraWave = false
	end

   self.radius = 0

   if(self.Sounds["ambient"]) then
      self.Sounds["ambient"]:Stop()
   end

   return true
end

function ENT:Think()
   self:NextThink(CurTime() + self.cycleInterval)

   local isWaveExpanding = self:ExpandWave()

   if(isWaveExpanding) then
      return true
   else
      self:Remove()
      return false
   end
end

function ENT:OnRemove()
   self:End()
   if IsValid(self.disintegrator) then self.disintegrator:Remove() end
end

end