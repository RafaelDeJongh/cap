--[[
	Energy Laser
	Copyright (C) 2011 Madman07
]]--

ENT.Type = "anim";
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile()

ENT.CAP_NotSave = true;

ENT.Sounds={
	Loop = Sound("weapons/asuran_beam.wav"),
}

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	self:DrawShadow(false);

	self.EndEntity = self.Entity:SpawnTarget()
	self.StartEntity = self.Entity:SpawnBeam()
	self.EndPos = Vector(1,1,1);
end

function ENT:SpawnTarget()
	local ent = ents.Create("info_target");
    ent:SetName("LaserEndPos"..self.Entity:EntIndex());
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
	beam:SetKeyValue("width", "5000");
	beam:SetKeyValue("damage", 10000);
	beam:SetKeyValue("dissolvetype", "0");
	beam:Spawn();
	beam:SetParent(self.Entity);
	beam:SetTrigger(true)
	return beam;
end

function ENT:Setup(startent, effect, up)
	self.Parent = startent;
	self.Entity:SetPos(startent:GetPos()+startent:GetForward()*10);
	self.Entity:SetAngles(startent:GetAngles());
	self.Entity:SetParent(startent);
	self.GoUp = up or false;

	self.Sounds.LoopSound = CreateSound(self.Entity, self.Sounds.Loop);
	if self.Sounds.LoopSound then self.Sounds.LoopSound:Play(); end

	if (effect == "GateWep") then
		local fx = EffectData();
			fx:SetOrigin(startent:GetPos());
			fx:SetEntity(self.Entity);
		util.Effect("GateWeapon_Out",fx, true, true);
	elseif (effect == "ONeill") then
		local fx = EffectData();
			fx:SetOrigin(startent:GetPos());
			fx:SetEntity(self.Entity);
		util.Effect("ONeillBeam",fx, true, true);
	end
end

function ENT:OnRemove()
	if self.Sounds.LoopSound then
		self.Sounds.LoopSound:Stop();
		self.Sounds.LoopSound = nil;
	end
	if IsValid(self.EndEntity) then self.EndEntity:Remove(); end
	if IsValid(self.StartEntity) then self.StartEntity:Remove(); end
end

function ENT:Think()
	if not IsValid(self.Parent) then self.Entity:Remove() end

	local endpos = Vector(0,0,0);
	local startpos = self.Parent:GetPos();
	if self.GoUp then
		startpos = self.Parent:GetPos()+self.Parent:GetUp()*20;
		endpos = self.Parent:GetPos()+self.Parent:GetUp()*10^14;
	else
		startpos = self.Parent:GetPos()+self.Parent:GetForward()*10;
		endpos = self.Parent:GetPos()+self.Parent:GetForward()*10^14;
	end
	self.StargateTrace = StarGate.Trace:New(startpos,endpos,{self.Entity, self.Owner, self.Parent});

	local gate = self.Parent:GetParent();
	if IsValid(gate) then
		if StarGate.IsIrisClosed(gate) then
			self.StargateTrace.Entity = NULL;
			self.StargateTrace.HitPos = gate:GetPos();
		end
	end

	self:UpdateEndPos();
	self:UpdateLaser();

	self.Entity:NextThink(CurTime()+0.1);
	return true
end

function ENT:UpdateEndPos()
	if self.StargateTrace.Hit then
		local ent = self.StargateTrace.Entity;

		if (IsValid(ent) and (ent:GetClass() == "shield" or ent:GetClass() == "shield_core_buble")) then
			ent:Hit(self.Entity,self.StargateTrace.HitPos, 3, self.StargateTrace.HitNormal);
		end

		self.EndPos = self.StargateTrace.HitPos;
		util.BlastDamage(self.Entity, self.Entity, self.EndPos, 250, 50);
	end
end

function ENT:UpdateLaser()
	self.EndEntity:SetPos(self.EndPos);
	self.StartEntity:SetKeyValue("LaserTarget", self.EndEntity:GetName());
	self.StartEntity:Fire("TurnOn", 1);
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("energy_laser",SGLanguage.GetMessage("energy_laser_kill"));
end

function ENT:Draw()
end

end