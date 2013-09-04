--[[
	Satellite Blast Wave
	Copyright (C) 2010 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds={
	Shoot=Sound("weapons/ag3_explosion_wave_effect.wav"),
}

function ENT:Initialize()

	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.Entity:SetRenderMode(RENDERMODE_NONE)
	self.Entity:SetMoveType(MOVETYPE_NONE);
	self.Entity:SetSolid(SOLID_NONE);
	self.Entity:DrawShadow(false);

	self.Radius = 5;
	self.SplodePos = self.Entity:GetPos()+Vector(0,0,4)
	timer.Simple( 8, function() if IsValid(self) then self.Entity:Remove(); end end);

	self.Entity:EmitSound(self.Sounds.Shoot,100,math.random(98,102));

	self.Entity:SetNetworkedInt("blast_radius", 0);
	self.Entities = {}

	local shake = ents.Create("env_shake")
	shake:SetKeyValue("amplitude", "16")
	shake:SetKeyValue("duration", 8)
	shake:SetKeyValue("radius", 15000)
	shake:SetKeyValue("frequency", 230)
	shake:SetPos(self.Entity:GetPos())
	shake:Spawn()
	shake:Fire("StartShake","","0.6")
	shake:Fire("kill","","8")

	--shatter glass
	for k,v in pairs(ents.FindByClass("func_breakable*")) do
		local dist = (v:GetPos() - self.SplodePos):Length()
		if dist < 7*2300 then
			v:Fire("Shatter","",dist/17e3)
		end
	end

	-- General big damage thing.
	util.BlastDamage(self.Entity, self.Entity, self.SplodePos, 2300, 4100)

end

function ENT:Think()

	self.Radius = self.Radius + 100;
	self.Entity:SetNetworkedInt("blast_radius", self.Radius);

	for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(), self.Radius )) do
		if IsValid(v) then
			local zrange = v:GetPos().z - self.Entity:GetPos().z;
			if (zrange < 500 and zrange > -500) then

			local class	= v:GetClass()

			if string.find(class,"prop") ~= nil then
				v:Fire("enablemotion","",0)
				constraint.RemoveAll(v)
			end

			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				local pos = v:LocalToWorld(v:OBBCenter());
				local dir = (pos-self.Entity:GetPos()):GetNormal();
				phys:ApplyForceCenter(dir*40000*phys:GetMass());
			end

			if not table.HasValue(self.Entities, v) then
				table.insert(self.Entities, v)

				if v:IsNPC() then
					v:Fire("kill","","0.1")
				elseif v:IsPlayer() then
					if (v:Alive()) then
						v:SetModel("models/player/charple01.mdl")
						v:Kill()
					end
				elseif class == "npc_strider" then
					v:Fire("break","","0.3")
				elseif class == "shield" or class == "ship_shield" or class == "shaped_shield" then
					v.Parent.Strength = v.Parent.Strength - 100;
				end

				for f,c in pairs(ents.FindByClass("func_breakable*")) do
					local dist = (c:GetPos() - self.Entity:GetPos()):Length()
					local range = dist - self.Radius;
					if (range < 200 and range > - 200) then
						v:Fire("Shatter","",range/17e3)
					end
				end

			end
			end

		end
	end

	self.Entity:DamageShields();

   self.Entity:NextThink(CurTime()+0.1);
   return true
end

function ENT:DamageShields()
	for k,v in pairs(StarGate.FindEntInsideSphere(self.SplodePos, self.Radius, "shield"))	do
		local dmgmul = 1/(self.SplodePos:Distance(v:GetPos())*50/100)^2
		v:Hit(self.Entity, self.SplodePos, 1e7*(20-self.Radius/100)*dmgmul)
	end
end