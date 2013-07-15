--[[
	Minidrone Platform
	Copyright (C) 2010 Madman07
]]--

if (not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds = {
	Enable = Sound("weapons/minidrone_turnon.wav"),
}
-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Minidrone Platform");
	self.Entity:SetModel("models/Madman07/minidrone_platform/platform.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
	self.LastFire = CurTime();
	self.Target = Vector(0,0,0);
	self.SoundPlayed = false;
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_minidrone_max"):GetInt()
	if(ply:GetCount("CAP_minidrone")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Minidrone Platform limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("minidrone_platform");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAO_minidrone", ent)
	return ent
end


-----------------------------------USE----------------------------------

function ENT:Use(ply)
	if (self.Owner == ply) then
		ply.MiniDronePlatform = self;
		ply:SetNetworkedEntity("DronePlatform", self);
		ply:Give("minidrone_key");
		ply:SelectWeapon("minidrone_key");
	end
end

function ENT:Think(ply)
	local pos = self:GetPos();
	local shouldlight = false;
	for _,v in pairs(player.GetAll()) do
		if (v.CanMinidroneControll and v.MiniDronePlatform == self) then
			if((pos - v:GetPos()):Length() < 500) then
				shouldlight = true;
			end
		end
	end

	if shouldlight then
		if not self.SoundPlayed then
			self.SoundPlayed = true;
			self.Entity:EmitSound(self.Sounds.Enable,100,math.random(98,102));
		end
		self:SetSkin(1);
	else
		self.SoundPlayed = false;
		self:SetSkin(0);
	end
end

-----------------------------------OTHER CRAP----------------------------------

function ENT:FireDrones(ply)
	local aimvector = Vector(0,0,1);
	local multiply = 10;

	local data = self:GetAttachment(self:LookupAttachment("Fire"))
	if(not (data and data.Pos)) then return end

	local e = ents.Create("mini_drone");
	e:SetPos(data.Pos);
	e:SetAngles(Angle(-90,0,0));
	e.Ply = ply;
	e:Spawn();
	e:SetVelocity(aimvector*800+VectorRand()*multiply); -- Velocity and "randomness"
	e:SetOwner(self);

	--self:EmitSound(self.Sounds.Shot[math.random(1,#self.Sounds.Shot)],90,math.random(97,103));
end

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if self.HaveCore then return end // dupe it by clicking on apple core u dumb

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	duplicator.StoreEntityModifier(self, "MiniDroneDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "MiniDroneDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local dupeInfo = Ent.EntityMods.MiniDroneDupeInfo

	local PropLimit = GetConVar("CAP_minidrone_max"):GetInt();
	if(ply:GetCount("CAP_minidrone")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Minidrone Platform limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return false
	end

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	self.Owner = ply;
	ply:AddCount("CAP_minidrone", self.Entity)

end