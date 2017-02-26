ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName		= "Nuke Rings"
ENT.Author			= "DrFattyJr"
ENT.Spawnable			= false
ENT.AdminSpawnable		= false
ENT.DoNotDuplicate = true 

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile()

ENT.CAP_NotSave = true;

function ENT:Setup(pos, ang, scale) -- THIS MUST BE CALLED BEFORE IT'S SPAWNED!
	self.StartPos = pos
	self.ANG = ang
	self.Scale = scale
end

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	self:DrawShadow(false);

	self.StartPos 	= (self.StartPos or self:GetPos())
	self.ANG	= (self.ANG or Angle(90,90,0))
	self.Scale	= (self.Scale or 100)

	self.Rad	= 0
	self.WaveSpeed 	= 10*self.Scale
	self.Time 	= CurTime()
	self.Init 	= self.Time
	self.Rel 	= 0
end

function ENT:Think()
	self.Time = CurTime()
	self.Rel = self.Time-self.Init
	if self.Rel > 10 then self:Remove() return end

	self.Rad = self.Rel*self.WaveSpeed

	local offset = Vector(self.Rad, self.Rad, self.Scale*2)
	local Ents = {}
	local EntsPos = {}

	-- Find ents in a box around us.
	for k,v in pairs (ents.FindInBox(self.StartPos+offset, self.StartPos-offset)) do
		if v:IsValid() then
			if v:GetPhysicsObject():IsValid() then
				table.insert(Ents, v)
				table.insert(EntsPos, v:GetPos())
			end
		end
	end

	-- Find ents in a rotated box around us.
	for k,v in pairs (StarGate.FindInsideRotatedBox(self.StartPos, -1*offset, offset, self.ANG)) do
		if v:IsValid() then
			if v:GetPhysicsObject():IsValid() then
				table.insert(Ents, v)
				table.insert(EntsPos, v:GetPos())
			end
		end
	end

	-- Check is the points are shielded.
	local IsInShield = StarGate.ArePointsInsideAShield(EntsPos)

	for k,v in pairs(IsInShield) do
		if not v then
			local e = Ents[k]

			if(e:IsWorld() == false) then
				local dis = EntsPos[k]:Distance(self.StartPos)
				if (dis < self.Rad+150) and (dis > self.Rad-150) then
					if e:IsPlayer() then
						if e:Alive() and not e:HasGodMode() then
							local allow = hook.Call("StarGate.GateNuke.KillPlayer",nil,e);
							if (allow==nil or allow) then
								e:SetModel("models/player/charple.mdl")
								e:Kill()
							end
						end
					else
						if(CombatDamageSystem) then
							cds_disintigratepos(EntsPos[k], 1, self.Entity)
						elseif(gcombat) then
							gcombat.nrghit(e, 100000, 100000, EntsPos[k], EntsPos[k])
						else
							e:TakeDamage(100000, self.Entity, self.Entity)
						end
					end
				end
			end
		end
	end
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	language.Add("gate_nuke_rings", SGLanguage.GetMessage("gate_nuke"))
end

function ENT:Draw()
end

end