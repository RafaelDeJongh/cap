if (not StarGate.CheckModule("ship")) then return end

include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.Railgunsound = Sound("f302/f302_railgun.wav")

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

function ENT:Bullets()
	bullet = {}
	bullet.Src		= self:GetPos()
	bullet.Attacker = self
	bullet.Dir		= self:GetAngles():Forward()
	bullet.Spread		= Vector(0.01,0.01,0.01)
	bullet.Num		= 3
	bullet.Damage		= 60
	bullet.Force		= 55
	bullet.Tracer		= 4
	bullet.TracerName	= "AR2Tracer"

	self:FireBullets(bullet)
end