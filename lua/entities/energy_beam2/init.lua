--[[
	Energy Beam
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	self:DrawShadow(false);

	self.EndEntity = self.Entity:SpawnTarget()
	self.StartEntity = self.Entity:SpawnBeam()
	self.StartPos = Vector(1,1,1);
	self.Dir = Vector(1,1,1);
	self.EndPos = Vector(1,1,1);

	self.UpdateStart = false;
	self.UpdateEnd = false;
	self.BlastCreated = false;

	self.Length = 0;
end

function ENT:SpawnTarget()
	local ent = ents.Create("info_target");
    ent:SetName("BeamEndPos"..self.Entity:EntIndex());
    ent:Spawn();
    ent:Activate();
	ent:SetPos(Vector(0,0,0));
	return ent;
end

function ENT:SpawnBeam()
	local beam = ents.Create("env_laser");
	beam:SetPos(Vector(0,0,0));
	beam:SetAngles(self.Entity:GetAngles())
	beam:SetOwner(self.Entity:GetOwner());
	beam:SetVar("Owner", self.Entity:GetVar("Owner", nil));
	beam:SetKeyValue("width", "50");
	beam:SetKeyValue("damage", 10000);
	beam:SetKeyValue("dissolvetype", "0");
	beam:Spawn();
	beam:SetTrigger(true)
	beam:SetParent(self.Entity);
	return beam;
end

function ENT:Setup(start, dir, speed, time, effect)
	self.Entity:SetNetworkedInt("StartTime", time)
	self.Dir = dir;
	self.StartPos = start;
	self.EndPos = start;
	self.Speed = speed;
	self.Effect = effect;
	self.Time = CurTime();
	self.UpdateEnd = true;

	local fx = EffectData();
		fx:SetEntity(self.Entity);
		fx:SetNormal(self.Dir)
		fx:SetStart(self.StartPos)
		fx:SetRadius(self.Speed)
		if effect then
			if (effect == "Ori" or effect == "AG3") then
				fx:SetMagnitude(1);
			elseif effect == "Asgard" then
				fx:SetMagnitude(2);
			end
		end
	util.Effect("energy_beam",fx, true, true);

	timer.Create(self.Entity:EntIndex().."Start", time, 1, function() self.UpdateStart = true; end);
	timer.Create(self.Entity:EntIndex().."Remove", 20, 1, function()
		if IsValid(self.Entity) then self:Remove(); end
	end);
end

function ENT:OnRemove()
	if IsValid(self.EndEntity) then self.EndEntity:Remove(); end
	if IsValid(self.StartEntity) then self.StartEntity:Remove(); end
end

function ENT:Think()
	self.StargateTrace = self.LastStargateTrace or StarGate.Trace:New(self.EndPos,self.Dir*self.Speed,{self.Entity, self.Owner, self.EndEntity, self.StartEntity,});

	if (self.UpdateStart == true) then self:UpdateStartPos(); end
	if (self.UpdateEnd == true) then self:UpdateEndPos(); end
	self:UpdateLaser()

	self.Entity:NextThink(CurTime()+0.1);
	return true
end

function ENT:UpdateEndPos()

	if not (self.StargateTrace.HitSky) then
		if self.StargateTrace.Hit then
			local dist = self.StargateTrace.HitPos:Distance(self.EndPos);
			if dist < self.Speed then
				local ent = self.StargateTrace.Entity;

				if IsValid(ent) then
					local class = ent:GetClass();
					if (class == "shield" or class == "shield_core_buble" or class == "ship_shield") then
						ent:Hit(self.Entity, self.StargateTrace.HitPos, 3, self.StargateTrace.HitNormal);
						self:DoUsualHit();
						self:SetNWVector("EndPos",self.StargateTrace.HitPos);
						self.LastStargateTrace = self.StargateTrace;
					elseif (class == "event_horizon") then
						local remoteEH = ent.Target;
						if IsValid(remoteEH) then
							self:OnHitEventHorizon(ent, self.StargateTrace.HitPos);
							self.WillGoTroughtGates = true;
							self:SetNWVector("EndPos",self.StargateTrace.HitPos);
							self.LastStargateTrace = self.StargateTrace;
						end
					elseif(CombatDamageSystem) then
						cds_disintigratepos(self.StargateTrace.HitPos, 1, self:GetOwner());
						self:DoUsualHit();
					elseif(gcombat) then
						gcombat.nrghit(ent, 50, 50, self.StargateTrace.HitPos, self.StargateTrace.HitPos);
						self:DoUsualHit();
					else
						ent:TakeDamage(10, self:GetOwner(), self.Entity);
						self:DoUsualHit();
					end
				else
					self:DoUsualHit();
				end

				self.EndPos = self.StargateTrace.HitPos;
				self.Length = self.Length + dist;

				if (not self.WillGoTroughtGates) then
					util.BlastDamage(self.Entity, self.Entity, self.EndPos, 250, 50);
				end
			else
				self.EndPos = self.EndPos + self.Dir*self.Speed;
				self.Length = self.Length + self.Speed;
			end
		else
			self.EndPos = self.EndPos + self.Dir*self.Speed;
			self.Length = self.Length + self.Speed;
		end
	end

end

function ENT:DoUsualHit()
	if self.WillGoTroughtGates then return end
	local smoke = true;
	if (self.StargateTrace.HitNormal == 0) then smoke = false; end;
	if (self.StargateTrace.MatType == MAT_FLESH or self.StargateTrace.MatType == MAT_METAL or self.StargateTrace.MatType == MAT_GLASS) then smoke = false; end
	if self.StargateTrace.HitSky then smoke = false; end

	if (self.Effect == "AG3") then
		if not self.BlastCreated then
			local ent = ents.Create("sat_blast_wave");
			ent:SetPos(self.StargateTrace.HitPos+Vector(0,0,300));
			ent:Spawn();
			ent:Activate();
			ent:SetOwner(self.Entity);
			self.BlastCreated = true;
		end
	elseif (self.Effect == "Ori") then
		local fx = EffectData();
			fx:SetOrigin(self.StargateTrace.HitPos);
			fx:SetNormal(self.StargateTrace.HitNormal);
			fx:SetEntity(self.Entity);
			if(not smoke) then
				fx:SetScale(-1);
			else
				fx:SetScale(1);
			end
			fx:SetMagnitude(30);
			fx:SetAngles(Angle(240,200,120));
		util.Effect("energy_impact",fx,true,true);
	else
		local fx = EffectData();
			fx:SetOrigin(self.StargateTrace.HitPos);
			fx:SetNormal(self.StargateTrace.HitNormal);
			fx:SetEntity(self.Entity);
			if(not smoke) then
				fx:SetScale(-1);
			else
				fx:SetScale(1);
			end
			fx:SetMagnitude(5);
			fx:SetAngles(Angle(120,175,255));
		util.Effect("energy_impact",fx,true,true);
	end
end

function ENT:OnHitEventHorizon(eventHorizon, hitPos)
	if (self.AlreadyHitEH) then return end
	local remoteEH = eventHorizon.Target

	if (eventHorizon:GetForward():DotProduct((hitPos-eventHorizon:GetPos()):GetNormalized()) < 0) then self.AlreadyHitEH = true; return end

	if (IsValid(remoteEH) and IsValid(remoteEH:GetParent()) and remoteEH:GetParent():IsBlocked()) then self.AlreadyHitEH = true; if IsValid(remoteEH:GetParent().Iris) then remoteEH:GetParent().Iris:EmitSound(remoteEH:GetParent().Iris.Sounds.Hit,90,math.random(98,103)); end return end

	local teleportedPos, teleportedForward = StarGate.GetTeleportedVector2(eventHorizon, remoteEH, hitPos, self.Dir);

   	local ent = ents.Create("energy_beam2");
	ent.Owner = self.Owner;
	ent:SetPos(teleportedPos);
	ent:Spawn();
	ent:Activate();
	ent:SetOwner(self.Entity:GetOwner());
	ent:Setup(teleportedPos, teleportedForward, self.Speed, 1.5, self.Effect);
	self.AlreadyHitEH = true;
end

function ENT:UpdateStartPos()
	self.StartPos = self.StartPos + self.Dir*self.Speed;
	self.Length = self.Length - self.Speed;
	if (self.Length <= 1) then self:Remove(); end
end

function ENT:UpdateLaser()
	self.EndEntity:SetPos(self.EndPos);
	self.Entity:SetPos(self.StartPos);
	self.StartEntity:SetKeyValue("LaserTarget", self.EndEntity:GetName());
	self.StartEntity:Fire("TurnOn", 1);
end