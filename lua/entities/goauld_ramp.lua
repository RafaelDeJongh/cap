/*   Copyright 2010 by Llapp   */
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "2010 Ramp"
ENT.Author = "Llapp, Boba Fett"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile();

function ENT:Initialize()
	self.Entity:SetModel("models/boba_fett/ramps/ramp8.mdl");
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) ;
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
		phys:SetMass(5000);
	end
	self.Gate=nil;
	self.Act = "20";
	self.On = false;
	self:Fire1()
	self:Fire2()
end

function ENT:Fire1()
    local fire = ents.Create("env_fire")
	fire:SetKeyValue("health","5")
    fire:SetKeyValue("firesize",self.Act)
    fire:SetKeyValue("fireattack","1")
    fire:SetKeyValue("damagescale","5")
    fire:SetKeyValue("spawnflags","159")
	fire:SetPos(self.Entity:GetPos() + self.Entity:GetUp()*(180) + self.Entity:GetRight()*200)
    fire:Spawn()
    fire:Activate()
	fire:SetParent(self.Entity);
	fire:Fire("StartFire","",0)
    self.Fir1 = fire;
end

function ENT:Fire2()
    local fire2 = ents.Create("env_fire")
	fire2:SetKeyValue("health","5")
    fire2:SetKeyValue("firesize",self.Act)
    fire2:SetKeyValue("fireattack","1")
    fire2:SetKeyValue("damagescale","5")
    fire2:SetKeyValue("spawnflags","159")
	fire2:SetPos(self.Entity:GetPos() + self.Entity:GetUp()*(180) + self.Entity:GetRight()*(-200))
    fire2:Spawn()
    fire2:Activate()
	fire2:SetParent(self.Entity);
	fire2:Fire("StartFire","",0)
    self.Fir2 = fire2;
end

function ENT:SpawnFunction(p,t)
	if(not t.Hit) then return end;
	local e = ents.Create("goauld_ramp");
	e:SetPos(t.HitPos+Vector(0,0,0));
	e:DrawShadow(true);
	e:Spawn();
	e:Activate()
	return e;
end

function ENT:Think()
	if IsValid(self.Gate) then
        if(self.Gate.NewActive and not self.On)then
			self.Act = "80";
			self.Entity:OnRemove()
			self:Fire1()
			self:Fire2()
			self.On = true;
	    elseif(not self.Gate.NewActive and self.On)then
			self.Act = "20";
			self.Entity:OnRemove()
			self:Fire1()
			self:Fire2()
			self.On = false;
	    end
	else
		self:GateFinder();
	end
end

function ENT:OnRemove()
    if IsValid(self.Fir1) then
	    self.Fir1:Remove()
	end
	if IsValid(self.Fir2) then
		self.Fir2:Remove()
	end
end

function ENT:GateFinder()
	for _,v in pairs(StarGate.GetConstrainedEnts(self.Entity,2) or {}) do
		if(IsValid(v) and v:GetClass():find("stargate_*")) then
		    self.Gate = v;
		end
	end
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable("anim_ramps",ply,"tool") ) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("sbox_maxanim_ramps"):GetInt()
	if(IsValid(ply) and ply:GetCount("CAP_anim_ramps")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Anim ramps limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end
	if (IsValid(ply)) then
		ply:AddCount("CAP_anim_ramps", self.Entity)
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "goauld_ramp", StarGate.CAP_GmodDuplicator, "Data" )
end

end