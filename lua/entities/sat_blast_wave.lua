--[[
	Satellite Blast Wave
	Copyright (C) 2010 Madman07

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

ENT.Type = "anim";
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.DoNotDuplicate = true 

function ENT:GetEntRadius()
   return self.Entity:GetNetworkedInt("blast_radius", 5);
end

function ENT:GetEntPos()
   return self:GetPos();
end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile()

ENT.CAP_NotSave = true

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
	--util.BlastDamage(self.Entity, self.Entity, self.SplodePos, 2300, 4100)
	-- this creating bugs that kill player in shield, we still have damage in think function so...

end

function ENT:Think()

	self.Radius = self.Radius + 100;
	self.Entity:SetNetworkedInt("blast_radius", self.Radius);

	for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(), self.Radius )) do
		if IsValid(v) then

			local allow = hook.Call("StarGate.SatBlast.DamageEnt",nil,v);
			if (allow==false) then continue end

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
					if (v:Alive() and not v:HasGodMode()) then
						v:SetModel("models/player/charple.mdl")
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

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("sat_blast_wave",SGLanguage.GetMessage("sat_blask_wave"));
end

function ENT:Initialize()

	self.Relative = 0
	self.StartPos = self:GetEntPos()
	self.Emitter = ParticleEmitter(self.StartPos)

end

function ENT:Draw()
end

function ENT:Think()

	self.Relative = self:GetEntRadius()/1000;

	if self.Relative > 15 then return end

	if (self.Relative < 6) then
		local num = self.Relative*25
		local ang = Angle(90, 0, 0)
		local fw = ang:Up()
		local ri = ang:Right()
		local spawn = {}

		for i=1,num do
			local Ang = i*math.pi*2/num
			spawn[i] = self.StartPos+self.Relative*1000*(math.sin(Ang)*ri+math.cos(Ang)*fw)
		end


		for i=1,num do

			local part = self.Emitter:Add("sprites/gmdm_pickups/light", spawn[i])
			part:SetVelocity(Vector(0,0,0))
			part:SetDieTime(0.5)
			part:SetStartAlpha(255)
			part:SetEndAlpha(0)
			part:SetStartSize(math.random(600,680))
			part:SetEndSize(math.random(520,600))
			part:SetRoll(math.Rand(20, 80))
			part:SetRollDelta(math.random(-1, 1))
			part:SetColor(255,math.random(100,200),math.random(50,100))

			local part2 = self.Emitter:Add("sprites/gmdm_pickups/light", self.StartPos)
			part2:SetVelocity(Vector(0,0,0))
			part2:SetDieTime(0.5)
			part2:SetStartAlpha(255)
			part2:SetEndAlpha(0)
			part2:SetStartSize(math.random(600,680))
			part2:SetEndSize(math.random(520,600))
			part2:SetRoll(math.Rand(20, 80))
			part2:SetRollDelta(math.random(-1, 1))
			part2:SetColor(255,math.random(100,200),math.random(50,100))

		end

	end

end

end