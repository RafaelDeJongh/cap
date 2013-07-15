--[[
	Horizon Missile
	Copyright (C) 2010 Madman07
]]--

if (not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Sounds = {
	Release = Sound("horizon/horizon_missle_release cap.wav"),
	LaunchSmall = Sound("horizon/horizon_missle_smallrockets.wav"),
	Fly = Sound("horizon/horizon_missle_fly.wav"),
}

ENT.WarHeadPos = {"Rocket01", "Rocket02", "Rocket03", "Rocket04", "Rocket05", "Rocket06", "Rocket07", "Rocket08", "Rocket09", "Rocket10"}

-----------------------------------INITIALISE----------------------------------

function ENT:Initialize()

	self.Entity:SetModel("models/Iziraider/Horizon/Horizon.mdl");

	self.Entity:SetName("Horizon Missile")
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then
		phys:Wake();
	end

	util.PrecacheModel("models/Iziraider/Horizon/warhead.mdl");

	self.Missile = {}
	self.Missiles = {}
	self.Covers = {}
	--self.CoversWeld = {}

	self.TrackTime = 1000000;
	self.MissileMaxVel=1000000000;

	self.MissileCount = 0;
	self.MaxMissiles = (4);
	self.MissilesFired=0

	self.WireFire = nil;
	self.WireRelease = nil;
	self.WireEngine = nil;
	self.WireHitPos = {}

	self.CanEngine = true;
	self.RemovedCovers = false;
	self.Fired = false;

	self.Entity:SetNetworkedBool("DrawEngines", false);

	--self.Entity:SpawnCovers()
	--self.Entity:SpawnMissiles()

	self.Inputs = WireLib.CreateInputs( self.Entity, {"Fire", "Release Covers", "Engine", "HitPos1 [VECTOR]", "HitPos2 [VECTOR]", "HitPos3 [VECTOR]", "HitPos4 [VECTOR]", "HitPos5 [VECTOR]", "HitPos6 [VECTOR]"});

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.HitPos ) then return end

	local PropLimit = GetConVar("CAP_horizon_max"):GetInt()
	if(ply:GetCount("CAP_horizon")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Horizon Platforms limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ent = ents.Create("horizon");
	ent:SetPos(tr.HitPos + Vector(0,0,80));
	ent:Spawn();
	ent:Activate();
	ent:SetVar("Owner",ply);

	ent.Owner = ply;

	ent:SpawnCovers()
	ent:SpawnMissiles()

	ply:AddCount("CAP_horizon", ent)
	return ent
end

function ENT:PreEntityCopy()

	local dupeInfo = {Covers={},Missile={}}

	for i=1,4 do
		if (IsValid(self.Covers[i])) then
			dupeInfo.Covers[i] = self.Covers[i]:EntIndex();
		end
	end

	for i=1,10 do
		if (IsValid(self.Missile[i])) then
			dupeInfo.Missile[i] = self.Missile[i]:EntIndex();
		end
	end

	duplicator.StoreEntityModifier(self, "HorizonDupe", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self)

end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods["HorizonDupe"] or {}

	if dupeInfo.Covers then
		for i=1,4 do
			self.Covers[i] = CreatedEntities[ dupeInfo.Covers[i] ];
			--self.Covers[i]:SetParent(self.Entity);
			--self.CoversWeld[i] = constraint.Weld(self.Covers[i],self.Entity,0,0,0,true);
		end
	end

	if dupeInfo.Missile then
		for i=1,10 do
			self.Missile[i] = CreatedEntities[ dupeInfo.Missile[i] ];
			--self.Missile[i]:SetParent(self.Entity);
		end
	end

	if (StarGate.NotSpawnable(self:GetClass(),ply)) then self.Entity:Remove(); return end

	local PropLimit = GetConVar("CAP_horizon_max"):GetInt()
	if(ply:GetCount("CAP_horizon")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Horizon Platforms limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end
	ply:AddCount("CAP_horizon", self.Entity)
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

-----------------------------------MISSILES----------------------------------

function ENT:SpawnMissiles()

	local ent;

	for i=1,10 do
		local data = self.Entity:GetAttachment(self.Entity:LookupAttachment(self.WarHeadPos[i]))
		if(not (data and data.Pos)) then return end

		ent = ents.Create("prop_physics");
		ent:SetModel("models/Iziraider/Horizon/warhead.mdl");
		ent:SetPos(data.Pos);
		ent:Spawn();
		ent:Activate();
		ent:SetOwner(self.Entity);
		--ent:SetParent(self.Entity);
		--ent:SetSolid(SOLID_NONE)
		self.Missile[i] = ent;
		constraint.Weld(ent,self.Entity,0,0,0,true);
	end

end

function ENT:FireMissile()

	self.Entity:EmitSound(self.Sounds.LaunchSmall,100,math.random(98,102));

	local ent;
	local decoy = false;

	for i=1,10 do
		local data = self.Entity:GetAttachment(self.Entity:LookupAttachment(self.WarHeadPos[i]))
		if(not (data and data.Pos)) then return end

		local pos = Vector(1,1,1);

		if (i>6) then
			decoy = true;
			pos = VectorRand()*10000; pos.z = 0;
		else
			decoy = false;
			if self.WireHitPos[i] then pos = self.WireHitPos[i];
			else pos = VectorRand()*10000; pos.z = 0; end
		end

		self.Missile[i]:Remove();



		ent = ents.Create("horizon_missile");
		ent.Parent = ent;
		ent.Track = true;
		ent.Target = pos;
		ent.IsDecoy = decoy;
		ent:SetPos(data.Pos);
		ent:SetAngles(self.Entity:GetAngles());
		ent:Spawn();
		ent:Activate();
		ent:SetVelocity(self:GetForward()*self.MissileMaxVel);
		ent.Owner = self.Owner;
		ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE);
		ent:SetOwner(self);
		self.MissileCount = self.MissileCount + 1;
		self.Missiles[ent] = true;
	end

end

-----------------------------------COVERS----------------------------------

function ENT:SpawnCovers()

	local ent;
	local model = {"models/Iziraider/Horizon/cover1.mdl", "models/Iziraider/Horizon/cover2.mdl", "models/Iziraider/Horizon/cover3.mdl", "models/Iziraider/Horizon/cover4.mdl"}

	for i=1,4 do
		ent = ents.Create("prop_physics");
		ent:SetModel(model[i]);
		ent:SetPos(self.Entity:GetPos());
		ent:Spawn();
		ent:Activate();
		ent:SetOwner(self.Entity);
		--ent:SetParent(self.Entity);
		self.Covers[i] = ent;
		--self.CoversWeld[i] = constraint.Weld(ent,self.Entity,0,0,0,true);
		constraint.Weld(ent,self.Entity,0,0,0,true);
	end

end

function ENT:RemoveCovers()
	self.Entity:EmitSound(self.Sounds.Release,100,math.random(98,102));
	for i=1,4 do
		/*if IsValid(self.CoversWeld[i]) then self.CoversWeld[i]:Remove() end */
		if IsValid(self.Covers[i]) then
			constraint.RemoveAll(self.Covers[i])
			local Cover = self.Covers[i]:GetPhysicsObject();
			if (Cover:IsValid()) then Cover:EnableMotion(true); end
		end
		timer.Simple( 10, function() if (IsValid(self) and IsValid(self.Covers[i])) then self.Covers[i]:Remove() end end);
	end
end

-----------------------------------OTHER CRAP----------------------------------

function ENT:OnRemove( )
	if IsValid(self.Entity) then self.Entity:Remove(); end
	for i=1,4 do
		if IsValid(self.Covers[i]) then self.Covers[i]:Remove() end
	end
	for i=1,10 do
		if IsValid(self.Missile[i]) then self.Missile[i]:Remove() end
	end
end

function ENT:TriggerInput(variable, value)
	if (variable == "Fire") then self.WireFire = value;
	elseif (variable == "Release Covers") then self.WireRelease = value;
	elseif (variable == "Engine") then self.WireEngine = value;
	elseif (variable == "HitPos1") then self.WireHitPos[1] = value;
	elseif (variable == "HitPos2") then self.WireHitPos[2] = value;
	elseif (variable == "HitPos3") then self.WireHitPos[3] = value;
	elseif (variable == "HitPos4") then self.WireHitPos[4] = value;
	elseif (variable == "HitPos5") then self.WireHitPos[5] = value;
	elseif (variable == "HitPos6") then self.WireHitPos[6] = value;
	end
end

-----------------------------------THINK----------------------------------

function ENT:Think(ply)

	if ((self.WireEngine == 1) and self.CanEngine) then
		self.Entity:SetNWBool("DrawEngines", true);
		self.Entity:EmitSound(self.Sounds.Fly,100,math.random(98,102));
		local Missile = self.Entity:GetPhysicsObject();
		Missile:Wake();
		local MissPhys = {
			secondstoarrive	= 1;
			pos = self.Entity:GetPos()+self.Entity:GetForward()*2000;
			maxspeed = 1000000;
			maxspeeddamp = 500000;
			dampfactor = 1;
			deltatime = 0.5;
		}
		Missile:ComputeShadowControl(MissPhys);
	else
		self.Entity:SetNWBool("DrawEngines", false);
		local Missile = self.Entity:GetPhysicsObject();
		Missile:Wake();
	end

	if ((self.WireRelease == 1) and not self.RemovedCovers) then
		self.RemovedCovers = true;
		self.Entity:RemoveCovers();
	end

	if ((self.WireFire == 1) and self.RemovedCovers and not self.Fired) then
		self.CanEngine = false;
		self.Fired = true;
		local Missile = self.Entity:GetPhysicsObject();
		Missile:Wake();
		Missile:AddVelocity(-1*self.Entity:GetForward()*10000)
		self.Entity:FireMissile();
		timer.Simple( 10, function() if (IsValid(self)) then self.Entity:OnRemove() end end);
	end

end