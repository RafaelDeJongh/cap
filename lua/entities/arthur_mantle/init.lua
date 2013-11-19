--[[
	Arthurs Mantle
	Copyright (C) 2010 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds={
	Enter=Sound("tech/mantle_exit_enter.wav"),
	Exit=Sound("tech/mantle_exit_enter.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/MarkJaw/merlin_device.mdl");

	self.Entity:SetName("Arthurs Mantle");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.Entity:SetUseType(SIMPLE_USE);

	self.Entity:Fire("skin",1);

	self.Entity:SetNetworkedEntity("Arthur",self.Entity);
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if (!tr.Hit) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("arthur_mantle");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then
		phys:EnableMotion(false);
	end

	return ent;
end

-----------------------------------USE----------------------------------

function ENT:Use(ply)

	if IsValid(ply) then
		if (ply:GetNetworkedBool("ArthurCloaked", false)) then -- uncloack

			ply:SetNetworkedBool("ArthurCloaked",false);

			ply:SetCollisionGroup(COLLISION_GROUP_PLAYER);
			ply:SetNoTarget(false)
			self.Entity:EmitSound(self.Sounds.Enter,90,math.random(97,103));
			--self.Entity:Fire("skin",1);

			local fx = EffectData();
				fx:SetOrigin(ply:GetShootPos()+ply:GetAimVector()*10);
				fx:SetEntity(ply);
			util.Effect("arthur_cloak",fx,true,true);

			local fx2 = EffectData();
				fx2:SetEntity(ply);
			util.Effect("arthur_cloak_light",fx2,true,true);

			local fx3 = EffectData();
				fx3:SetEntity(self.Entity);
			util.Effect("arthur_cloak_light",fx3,true,true);

		else -- cloack

			ply:SetNetworkedBool("ArthurCloaked",true);

			ply:SetCollisionGroup(COLLISION_GROUP_WORLD);
			ply:SetNoTarget(true)
			self.Entity:EmitSound(self.Sounds.Enter,90,math.random(97,103));
			--self.Entity:Fire("skin",0);

			local fx = EffectData();
				fx:SetOrigin(ply:GetShootPos()+ply:GetAimVector()*10);
				fx:SetEntity(ply);
			util.Effect("arthur_cloak",fx,true,true);

			local fx2 = EffectData();
				fx2:SetEntity(ply);
			util.Effect("arthur_cloak_light",fx2,true,true);

			local fx3 = EffectData();
				fx3:SetEntity(self.Entity);
			util.Effect("arthur_cloak_light",fx3,true,true);

		end

	end

end

local function playerDies( victim, weapon, killer )
	if (victim:GetNetworkedBool("ArthurCloaked", false)) then
		victim:SetNetworkedBool("ArthurCloaked",false);
		timer.Simple(0.1,function()
			if (IsValid(p)) then
				victim:SetNWBool("ArthurCloaked",nil);
			end
		end)
		victim:SetNoTarget(false);
	end
end
hook.Add( "PlayerDeath", "StarGate.Arthur", playerDies )

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	duplicator.StoreEntityModifier(self, "MantleDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "MantleDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.MantleDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.Owner = ply;
end

-- function Arthur_SpawnedProp(ply, model, ent)
	-- local shut = self.Entity:GetNetworkedEntity("Arthur");
	-- if table.HasValue(shut.CloackedPlayers, ply:EntIndex()) then
		-- ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
		-- table.insert(shut.CloackedProps, ent:EntIndex());
	-- end
-- end
-- hook.Add("PlayerSpawnedProp", "Arthur_SpawnedProp", Arthur_SpawnedProp)

-- function Arthur_SpawnedSENT(ply, ent)
	-- local shut = self.Entity:GetNWEntity("Arthur");
	-- if table.HasValue(shut.CloackedPlayers, ply:EntIndex()) then
		-- ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
		-- table.insert(shut.CloackedProps, ent:EntIndex());
	-- end
-- end
-- hook.Add( "PlayerSpawnedSENT", "Arthur_SpawnedSENT", Arthur_SpawnedSENT );