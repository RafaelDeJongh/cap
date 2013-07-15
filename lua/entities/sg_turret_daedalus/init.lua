--[[
	Daedalus Turret
	Copyright (C) 2011 Madman07

]]--

if (not StarGate.CheckModule("ship")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Speed = 0.5;
ENT.DownClamp = 0;
ENT.UpClamp = 60;

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Daedalus Turret");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Pitch = 0;
	self.Yaw = 0;
	self.CanFire = true;
end

-----------------------------------PHYS----------------------------------



function ENT:Aim(target)
	// calculate local angles for target
	local ShootAngle = (target - self:GetPos()):Angle();
	ShootAngle = self:WorldToLocalAngles(ShootAngle);

	local new_p = math.NormalizeAngle(ShootAngle.Pitch);
	local new_y = math.NormalizeAngle(ShootAngle.Yaw);

	self.Pitch = math.ApproachAngle(self.Pitch, new_p, self.Speed);
	self.Yaw = math.ApproachAngle(self.Yaw, new_y, self.Speed);

	local newpitch = math.Clamp(self.Pitch, self.DownClamp, self.UpClamp);
	self:SetPoseParameter("turret_pitch", newpitch)
	self:SetPoseParameter("turret_yaw", self.Yaw)
end

-----------------------------------SHOOT----------------------------------

function ENT:DoShoot()
	if self.CanFire then
		self:Shoot(1);
		self:Shoot(2);
	end
end

function ENT:Shoot(cann)
	self.CanFire = false;
	local att = {
		"Fire1",
		"Fire2"
	}

	local data = self:GetAttachment(self:LookupAttachment(att[cann]))
	if(not (data and data.Pos and data.Ang)) then return end

	self.StargateTrace = StarGate.Trace:New(data.Pos+data.Ang:Forward()*100,data.Pos+data.Ang:Forward() * 10^14);

	local mat = self.StargateTrace.MatType;
	local smoke = 1;
	if (self.StargateTrace.HitSky or (mat == MAT_FLESH) or (mat == MAT_METAL) or (mat == MAT_GLASS)) then smoke = 0 end

	local fx = EffectData();
		fx:SetStart(data.Pos);
		fx:SetOrigin(self.StargateTrace.HitPos);
		fx:SetMagnitude(smoke);
		fx:SetRadius(1);
	util.Effect("Bullet_tracer",fx);

	local effectdata = EffectData()
		effectdata:SetOrigin(data.Pos)
		effectdata:SetAngles(data.Ang)
		effectdata:SetScale( 2 )
	util.Effect( "MuzzleEffect", effectdata )

	local damage = GetConVar("CAP_shiprail_damage"):GetInt();
	bullet = {}
	bullet.Src		= data.Pos;
	bullet.Attacker = self.Parent;
	bullet.Dir		= data.Ang;
	bullet.Spread	= Vector(0.01,0.01,0);
	bullet.Num		= 1;
	bullet.Damage	= damage;
	bullet.Force	= damage;
	bullet.Tracer	= 0;
	self:FireBullets(bullet);

	-- self:EmitSound(self.Sounds.Shoot,100,math.random(98,102));
	util.ScreenShake(data.Pos,1,2.5,0.5,500)

	timer.Simple(0.03, function() self.CanFire = true; end);
end
