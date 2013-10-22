if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Sounds = {
	Loop = Sound("tech/background_loop.wav"),
}

function ENT:SpawnFunction(ply, tr)
	if(!tr.Hit) then return end
	local ent = ents.Create("black_hole_power")
	ent:SetPos(tr.HitPos + (tr.HitNormal * 16))
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel("models/zup/shields/200_shield.mdl")
	self.Entity:PhysicsInitSphere( 10, "metal_bouncy" )
	self.Entity:SetColor(Color(0, 0, 0, 255))

	self.MaxAmount = StarGate.CFG:Get("black_hole","amount",500000);
	self.Resources = {};
	for _,v in pairs(StarGate.CFG:Get("black_hole","resources",""):TrimExplode(",")) do
		table.insert(self.Resources,v);
	end

	self.Disallow = {}
	for _,v in pairs(StarGate.CFG:Get("black_hole","disallow",""):TrimExplode(",")) do
		table.insert(self.Disallow,v);
	end

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableCollisions(false)
	end

	self.Entity:DrawShadow(false)  -- hm...? i think black hole shouln't draw shadow... because it looks ugly
	self.Entity:SetTrigger(true)

	local size = 10;
	self.Entity:SetCollisionBounds(Vector(-size,-size,-size),Vector(size,size,size))

	if self.HasRD then
		for k, res in pairs(self.Resources) do
			self:AddResource(res, self.MaxAmount)
		end
	end

	if(WireAddon != nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self.Entity, {"Resource Amount"})
		Wire_TriggerOutput(self.Entity, "Resource Amount", self.MaxAmount)
	end

	self.Sounds.LoopSound = CreateSound(self.Entity, self.Sounds.Loop);
	if self.Sounds.LoopSound then
		self.Sounds.LoopSound:Play();
		self.Sounds.LoopSound:SetSoundLevel(140);
	end
end

function ENT:Think()
	if (not IsValid(self)) then return false end;
	if self.HasRD then
		for k, res in pairs(self.Resources) do
			if(self:GetResource(res) < self.MaxAmount) then
				self:SupplyResource(res, self.MaxAmount)
			end
		end
	end

	local x = self.blackHoleMass/500;
	local phys = self.Entity:GetPhysicsObject()
	phys:ApplyForceCenter( Vector(0,0,0) )
	self:SetNetworkedInt("mass", x);

	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
	StarGate.WireRD.OnRemove(self);
	if self.Sounds.LoopSound then
		self.Sounds.LoopSound:Stop();
	end
end


function ENT:StartTouch(ent)
	if IsValid(ent) then
		if (ent:GetClass() == "black_hole_power") then return end
		local phys = ent:GetPhysicsObject()
		if(phys:IsValid()) then
			local mass = phys:GetMass()

			if (ent:IsPlayer()) then
				ent:Kill()
			elseif (ent:IsNPC()) then
				ent:SetNPCState(NPC_STATE_DEAD);
			else
				if (not ent:CreatedByMap() and not ent.GateSpawnerSpawned) then
					ent:Remove()
				else
					return false;
				end
			end

			self.blackHoleMass = self.blackHoleMass + mass;

			local size = self.blackHoleMass/1000;
			self.Entity:SetCollisionBounds(Vector(-size,-size,-size),Vector(size,size,size))

			self.Entity:PhysicsInitSphere(size, "metal_bouncy" )
			local phys = self.Entity:GetPhysicsObject()
			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableGravity(false)
				phys:EnableDrag(false)
				phys:EnableCollisions(false)
			end
		end
	end
end

function ENT:PhysicsUpdate()
	local myPosition = self.Entity:GetPos()

	local halfVector = ( self.Range / 2 ) * Vector(1, 1, 1)
	local lowRange = myPosition - halfVector
	local highRange = myPosition + halfVector

	local inRange = ents.FindInBox( lowRange, highRange )

	for entKey,entVal in pairs(inRange) do
		if(not table.HasValue(self.Disallow,entVal:GetClass())) then
			local entLocation = entVal:GetPos()

			local difference = myPosition - entLocation
			local objRange = difference:Length()

			if(objRange < self.Range) then
				local phys = entVal:GetPhysicsObject()
				if(phys:IsValid()) then
					difference:Normalize()
					local sqrRange = ( 1 / objRange )
					local fApplied = difference * sqrRange * self.blackHoleMass * phys:GetMass()
					phys:ApplyForceCenter( fApplied )
				end
			end
		end
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end