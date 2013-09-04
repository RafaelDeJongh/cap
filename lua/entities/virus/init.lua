/*
	Gate Virus
	Copyright (C) 2011 Llapp
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.Sounds={
	Cloak=Sound("stargate/cloak/shield_cloaking_on_01.wav"),
	Uncloak=Sound("stargate/cloak/shield_cloaking_off_01.wav"),
};

function ENT:Initialize()
	self.Entity:SetName("virus");
	self.Entity:SetModel("models/Assassin21/AGV/agv.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
	self.Virus = false;
	self.Gate = nil;
	self.RGB = self:GetColor();
	self.Init = false;
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+90) % 360;
	local pos = t.HitPos
	local e = ents.Create("virus");
	e:SetPos(pos);
	e:SetAngles(ang);
	e:DrawShadow(true);
	e:Spawn();
	e:Activate();
	e.Owner = p;
	return e;
end

function ENT:Think()
	if (not IsValid(self)) then return end
	self:FindVirus();
	local owner = self.Entity:GetVar("Owner");
	if(IsValid(owner))then
	  local dist = (self.Entity:GetPos() - owner:GetPos()):Length();
	  if(dist >= 80)then
	    if(not self.Init)then
	      self:CloakEnt(true);
		    self.Init = true;
		  end
	  else
	    if(self.Init)then
	      self:CloakEnt(false);
		    self.Init = false;
		  end
	  end
	end
end

function ENT:OnRemove()
    if(IsValid(self.Gate))then
        self.Gate:Viru(false);
		end
end

function ENT:FindVirus()
	local epos = self.Entity:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		local vpos = v:GetPos();
		local dist = (vpos - epos):Length();
		if(dist <= 500) then
			self.Gate = v;
		  v:Viru(true);
		end
	end
end

function ENT:Use(ply)
	ply:Give("v_virus");
	ply:SelectWeapon("v_virus");
	self.Entity:Remove()
end

function ENT:Enabled()
	return (self.Cloak and self.Cloak:IsValid());
end

function ENT:CloakEnt(b,nosound,alpha,s,owner,sound)
  local time = CurTime();
  owner = self.Entity:GetVar("Owner");
  s = 2;
  alpha = 0;
	if(b)then
 		if(owner and owner:IsValid() and owner:IsPlayer())then
        alpha = 100;
		end
		self.CollisionGroup = self:GetCollisionGroup();
		self:SetCollisionGroup(COLLISION_GROUP_WORLD);
		self.Cloak = time;
		if(not nosound) then
			sound = self.Sounds.Cloak;
		end
	else
	  alpha = self.RGB[4];
	  s = s*(-1);
	  self:SetCollisionGroup(self.CollisionGroup);
	  sound = self.Sounds.Uncloak;
  end
  local delay = math.Clamp(time - (self.Cloak or 0),0,2);
	local function reset(self)
		if(IsValid(self.Entity)) then
			self:SetRenderMode( RENDERMODE_TRANSALPHA )
			self:SetColor(Color(self.RGB.r,self.RGB.g,self.RGB.b,alpha));
		end
	end
	timer.Create("cloak",delay-0.1,1,function() reset(self) end);
	self:CloakingEffect(self.Entity,s)
	if(not nosound)then
		self:EmitSound(sound,60,math.random(180,200));
	end
end

function ENT:CloakingEffect(e,scale)
	local fx = EffectData();
	local pos = e:GetPos();
	fx:SetOrigin(pos);
	fx:SetStart(pos);
	fx:SetEntity(e);
	fx:SetScale(scale);
	util.Effect("cloaking",fx,true,true);
end