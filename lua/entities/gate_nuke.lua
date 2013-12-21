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

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName		= "Nuke"
ENT.Author			= "Teta_Bonita(Re-written by DrFattyJr)"
ENT.Spawnable			= false
ENT.AdminSpawnable		= false

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end

AddCSLuaFile()

ENT.CAP_NotSave = true;

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

	util.PrecacheModel("models/player/charple.mdl")

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
				if v:Alive() and not v:HasGodMode() then
					local allow = hook.Call("StarGate.GateNuke.KillPlayer",nil,v);
					if (allow==nil or allow) then
						v:SetModel("models/player/charple.mdl")
						v:Kill()
					end
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
	--util.BlastDamage(self.Entity, self.Entity, self.SplodePos, blastradius, 41*self.Scale)
	-- this creating bugs that kill player in shield, we still have damage in think function so...

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

		local allow = hook.Call("StarGate.GateNuke.DamageEnt",nil,v);
		if (allow==false) then continue end

		if self.Rel < 5 then
			if Damage >= 250  then
				if v:IsPlayer() then --if we've hit a Player
					if (not v:HasGodMode()) then
						v:SetModel("models/player/charple.mdl") --burn it
						v:SetHealth(1)
					end
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

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("gate_nuke", SGLanguage.GetMessage("gate_nuke"))
end

info = {
	Pos = Vector(0,0,0),
	Scale = 100,
}

function ENT:NukeSunBeams() -- All Credits for this goes to Jinto :}) -- Moustache
	if not render.SupportsPixelShaders_2_0() then return end
	if not StarGate.VisualsWeapons("cl_gate_nuke_sunbeams") then return end

	local pos = info.Pos
	local viewdiff = (pos-EyePos())
	local viewdir = viewdiff:GetNormal()
	local viewdist = viewdiff:Length()
	local eyedir = EyeAngles():Forward()

	-- Calculate the dot product of our view.
	local dot = (viewdir:Dot(EyeVector())-0.8)*5

	-- Die percent
	local dp = math.Clamp(2-self.Rel/10, 0, 1)

	-- Multiply
	dot = dot*dp*info.Scale/100

	-- Sun beams
	local screenpos = (EyePos()+viewdir*viewdist*0.5):ToScreen()

	if dot > 0 then

		DrawSunbeams(
		        0.95,
		        0.5*dot,
		        0.075,
		        screenpos.x/ScrW(),
		        screenpos.y/ScrH()
		)
	end
	return true
end

local function NukeSunBeamInfo(Info) -- I could just do this with network varibles but there sent the same way soo... meh.
	local pos = Info:ReadVector()
	local scale = Info:ReadFloat()
	info = {Pos = pos, Scale = scale}
end

usermessage.Hook("NukeSunBeamsInfoXD", NukeSunBeamInfo)

--###################### EVERYTHING BELOW IS TETABONITA'S

local sndWaveBlast = Sound("ambient/levels/streetwar/city_battle11.wav")
local sndWaveIncoming = Sound("ambient/levels/labs/teleport_preblast_suckin1.wav")
local sndSplode = Sound("ambient/explosions/explode_6.wav")
local sndRumble = Sound("ambient/explosions/exp1.wav")
local sndPop = Sound("weapons/pistol/pistol_fire3.wav")

function ENT:Initialize()
	self.SplodeDist = 1000
	self.BlastSpeed = 4000
	self.SplodeDist = 0
	self.Time = CurTime()
	self.Init = self.Time
	self.Rel  = 0
	self.HPIS = false
	self.HPSS = false
	self.HPBS = false

	hook.Add("RenderScreenspaceEffects", "NukeSunBeams", function() self:NukeSunBeams() end)
	surface.PlaySound(sndRumble)
end

function ENT:Think()
	self.Time = CurTime()
	self.Rel = self.Time-self.Init

	if self.Rel > 20  then return end

	self.SplodeDist = self.BlastSpeed*self.Rel

	local EntPos = self.Entity:GetPos()
	local CurDist = (EntPos-LocalPlayer():GetPos()):Length()

	if CurDist < 900 + self.BlastSpeed then
		self.HPIS = true
	end

	if not self.HPSS then
		timer.Simple(CurDist/18e3,function() PlaySplodeSound(7e5/CurDist) end)
		self.HPSS = true
	end

	if self.Rel < 7 then
		if (not self.HPIS) and self.SplodeDist + self.BlastSpeed*1.6 > CurDist then
			surface.PlaySound(sndWaveIncoming)
			self.HPIS = true
		end

		if (not self.HPBS) and self.SplodeDist + self.BlastSpeed*0.2 > CurDist then
			surface.PlaySound(sndWaveBlast)
			self.HPBS = true
		end
	end

end

function PlaySplodeSound(volume)

	if volume > 400 then
		surface.PlaySound(sndSplode)
		return
	end

	if volume < 60 then volume = 60 end

	LocalPlayer():EmitSound(sndSplode,volume,100)
end

function PlayPopSound(ent)
	ent:EmitSound(sndPop,500,100)
end

function ENT:Draw()
end

function ENT:OnRemove()
	hook.Remove("RenderScreenspaceEffects", "NukeSunBeams")
end

end