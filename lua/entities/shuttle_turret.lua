ENT.PrintName = "302 Turret"
ENT.Author = "Shadow"
ENT.Spawnable = false
ENT.Type = "anim"
ENT.Base = "base_anim"

if SERVER then

if (1==1) then return end -- this ent is disabled, because it isn't used anywhere

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
AddCSLuaFile()

ENT.Railgunsound = Sound("pulse_weapon/dexgun_flyby1.mp3")

function ENT:Initialize()

	self:SetModel("models/sandeno/naquadah_bottle.mdl")
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self.Firing=false
	self:SetColor(Color(255,255,255,0))

end

function ENT:Think()

	if(self.Firing) then
		self:Bullets()
		self:EmitSound(self.Railgunsound,100,100)
	end
end

function ENT:Bullets(p)

	local StargateTrace = StarGate.Trace:New(self:GetPos()+self:GetForward()*100,self:GetPos()+self:GetForward() * 10^14, self.Entity:GetOwner());

	bullet = ents.Create("energy_bullet");
	bullet.Factor = 5;
	bullet:SetColor(Color(255,255,math.random(75,125),255));
	bullet:SetOwner(self.Entity);
	bullet.Cannon = self.Entity;
	bullet:SetPos(self:GetPos());
	bullet.Ent = StargateTrace.Entity
	bullet.EndPos = StargateTrace.HitPos
	bullet:Spawn();

end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("shuttle_turret", SGLanguage.GetMessage("entity_dest_shuttle"))
end

end