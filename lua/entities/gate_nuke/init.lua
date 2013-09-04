--[[
This is based off TetaBonita's "sent_nuke" it has been stripped bare and heavily re-written
although i large portion of the original code still exists. So 50% of credit to Teta and 50% to
DrFattyJr(Me)...


	This is how to spawn this entity!!!

	local nuke = ents.Create("gate_nuke")
		nuke:Setup(pos, scale)
		nuke:Spawn()
		nuke:Activate()

	pos is where you want it explode, scale is how powerfull it is, i wouldn't turn it up past 100.
	For some reason beyond my knowledge this is the only way it seems to spawn correctly.

	Do NOT set the position of this Entity.
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Setup(pos, scale) -- THIS MUST BE CALLED BEFORE IT'S SPAWNED
	self.Scale = scale
	self.SplodePos = pos+Vector(0,0,4)
end

function ENT:Initialize()

	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
	self:DrawShadow(false);

	-- Set Up main varibles
	self.Scale = (self.Scale or 100)
	self.SplodePos = (self.SplodePos or Vector(0,0,0))


	--Tell the client where the nuke is.
	local rp = RecipientFilter()
		rp:AddAllPlayers()

	umsg.Start("NukeSunBeamsInfoXD", rp)
		umsg.Vector(self.SplodePos)
		umsg.Float(self.Scale)
	umsg.End()

	util.PrecacheModel("models/player/charple01.mdl")

	--remove this ent after awhile
	self.Entity:Fire("kill","",20)

	-- Set Up the effect
	local ang = Angle(math.Rand(115,255), math.random(0,360), 0)
	local fx = EffectData()
		fx:SetMagnitude(self.Scale)
		fx:SetAngles(ang)
		fx:SetOrigin(self.SplodePos)
	util.Effect( "Gate_Nuke_Explosion", fx)

	local blastradius = 23*self.Scale

	-- Find people and npcs and kill them.
	for k,v in pairs(ents.FindInSphere(self.SplodePos,blastradius)) do
		if v:IsValid() then
			if v:IsNPC() then
				v:Fire("kill","","0.1")
			elseif v:IsPlayer() then
				if v:Alive() then
					v:SetModel("models/player/charple01.mdl")
					v:Kill()
				end
			end
		end
	end

	--earthquake
	local shake = ents.Create("env_shake")
	shake:SetKeyValue("amplitude", "0.16*self.Scale")
	shake:SetKeyValue("duration", 6)
	shake:SetKeyValue("radius", 163.84*self.Scale)
	shake:SetKeyValue("frequency", 2.3*self.Scale)
	shake:SetPos(self.SplodePos)
	shake:Spawn()
	shake:Fire("StartShake","","0.6")
	shake:Fire("kill","","8")


	--Spawn the Vaporise rings thigno
	local rings = ents.Create("gate_nuke_rings")
	rings:Setup(self.SplodePos, ang, self.Scale)
	rings:Spawn()
	rings:Activate()

	--shatter glass
	for k,v in pairs(ents.FindByClass("func_breakable*")) do
		local dist = (v:GetPos() - self.SplodePos):Length()
		if dist < 7*blastradius then
			v:Fire("Shatter","",dist/17e3)
		end
	end

	-- General big damage thing.
	util.BlastDamage(self.Entity, self.Entity, self.SplodePos, blastradius, 41*self.Scale)

	-- Set up some final Varibles
	self.Time = CurTime()
	self.SplodeDist = self.Scale
	self.BaseDamage = 1.5e9*self.Scale
	self.BlastSpeed = 40*self.Scale
	self.MaxDist = 120*self.Scale
	self.Rel = 0
	self.Init = self.Time
	self.LastDamagedShields = 0
end

ENT.GateList = {
	"stargate_sg1",
	"stargate_atlantis",
	"stargate_universe",
	"stargate_orlin",
	"stargate_movie",
	"stargate_tollan",
	"stargate_infinity",
}
ENT.DHDList = {
	"dhd_sg1",
	"dhd_atlantis",
	"dhd_universe",
	"dhd_infinity",
}

function ENT:Think()
	self.Time = CurTime()
	self.Rel = self.Time - self.Init
	self.SplodeDist = self.BlastSpeed*self.Rel
	if self.SplodeDist > self.MaxDist then
		self.SplodeDist = self.MaxDist
	end

	if self.Rel > 20 then return end

	local ent = {}
	local entpos = {}

	-- Find some ents.
	for k,v in pairs(ents.FindInSphere(self.SplodePos,self.SplodeDist)) do
		if v:IsValid() then
			table.insert(ent, v)
			table.insert(entpos, v:LocalToWorld(v:OBBCenter())) --more accurate than getpos
		end
	end

	-- Check if we can push them
	ent,entpos = StarGate.LOS(self.Entity, ent, entpos)

	for k,v in pairs(ent) do
		local dir	= entpos[k]-self.SplodePos
		local vecang	= dir:GetNormal()
		local Damage	= self.BaseDamage/(4*math.pi*self.SplodeDist^2)
		local class	= v:GetClass()

		if self.Rel < 5 then
			if Damage >= 250  then
				if v:IsPlayer() then --if we've hit a Player
					v:SetModel("models/player/charple01.mdl") --burn it
					v:SetHealth(1)
				elseif table.HasValue(self.GateList, class) then
					if self.Scale > 30 then v:Remove();
					elseif (self.Scale > 20 and self.Scale < 30) then v:WormHoleJump()
					end
				elseif class == "stargate_supergate" then -- i hope it will shut down gate
					if self.Scale > 80 then
						self:ReSpawnSupergate(v);
						v:Remove()
					end
				elseif table.HasValue(self.DHDList, class) then
					if self.Scale > 30 then v:Remove();
					else v:DestroyEffect()
					end
				elseif class == "npc_strider" then --if we've hit a strider...
					v:Fire("break","","0.3")
				elseif class == "black_hole_power" then
					v.blackHoleMass = v.blackHoleMass + Damage*2
					local size = v.blackHoleMass/1000;
					v:SetCollisionBounds(Vector(-size,-size,-size),Vector(size,size,size))
					v:PhysicsInitSphere(size, "metal_bouncy" )
					local phys = v:GetPhysicsObject()
						if (phys:IsValid()) then
						phys:Wake()
						phys:EnableGravity(false)
						phys:EnableDrag(false)
						phys:EnableCollisions(false)
					end
				end
			end

			if string.find(class,"prop") ~= nil then
				v:Fire("enablemotion","",0) --bye bye fort that took you 4 hours to make
				constraint.RemoveAll(v)
			end

			local phys = v:GetPhysicsObject()

			-- Push stuff, dont push black hole
			if (phys:IsValid() and not class == "black_hole_power") then
				phys:ApplyForceCenter(vecang*(40*phys:GetMass()*self.Scale))
			end
		end

		-- Do general damage to the area
		dmgmul = (dir:Length()*100/self.Scale)^-2
		util.BlastDamage(self.Entity, self.Entity, entpos[k], 8, 2e6*(20-self.Rel)*dmgmul)
	end

	if self.Rel-self.LastDamagedShields > 0.2 then
		self.LastDamagedShields = self.Rel
		self:DamageShields()
	end
end

function ENT:ReSpawnSupergate(gate)
	local pos = gate:GetPos()+Vector(0,0,0);
	local ang = gate:GetAngles();
	local f = gate:GetForward();
	local u = gate:GetUp();
	local r = gate:GetRight();

	local block;
	local radius = 2375;
	local x;
	local y;

	for i=1,72 do

		x = math.sin(math.rad(i*5))*radius;
		y = math.cos(math.rad(i*5))*radius;

		block = ents.Create("prop_physics");
		block:SetAngles(ang + Angle(0,0,5*i));
		block:SetPos(pos + f*10 + u*y + r*x);
		block:SetModel("models/Iziraider/supergate/segment.mdl");
		block:Spawn();
		block:Activate();

	end
end

function ENT:DamageShields()
	for k,v in pairs(StarGate.FindEntInsideSphere(self.SplodePos, self.SplodeDist, "shield"))	do
		local dmgmul = 1/(self.SplodePos:Distance(v:GetPos())*50/self.Scale)^2
		v:Hit(self.Entity, self.SplodePos, 1e7*(20-self.Rel)*dmgmul)
	end

	for k,v in pairs(StarGate.FindEntInsideSphere(self.SplodePos, self.SplodeDist, "shield_core_buble"))	do
		local dmgmul = 1/(self.SplodePos:Distance(v:GetPos())*50/self.Scale)^2
		v:Hit(self.Entity, self.SplodePos, 1e7*(20-self.Rel)*dmgmul)
	end
end