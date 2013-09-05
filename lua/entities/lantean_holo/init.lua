--[[
	Holo
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

ENT.Sounds = {
	Idle=Sound("tech/asgard_holo.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetName("Lantean Holo Device");
	self.Entity:SetModel("models/MarkJaw/atlantis_holo/holo.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.Touching = 0;
	self.SoundLoop = CreateSound(self,self.Sounds.Idle);
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr)
	if ( !tr.Hit ) then return end
	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local PropLimit = GetConVar("CAP_lantholo_max"):GetInt()
	if(ply:GetCount("CAP_lantholo")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Lantean Holo limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ent = ents.Create("lantean_holo");
	ent:SetPos(tr.HitPos);
	ent:SetAngles(ang);
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAP_lantholo", ent)
	return ent
end

-----------------------------------TOUCH----------------------------------

function ENT:StartTouch(ent)
	if ent:IsPlayer() then
		self.SoundLoop:Play();
		self.SoundLoop:SetSoundLevel(85);
		self.Touching = self.Touching+1;
		if (self.Touching == 1) then self:SetNetworkedBool("Display", true); end
		if timer.Exists(self.Entity:EntIndex().."NotTouch") then timer.Destroy(self.Entity:EntIndex().."NotTouch"); end
	end
end

function ENT:EndTouch(ent)
	if ent:IsPlayer() then
		self.Touching = self.Touching-1;
		timer.Create( self.Entity:EntIndex().."NotTouch", 1, 1, function()
			if IsValid(self.Entity) then
				if (self.Touching == 0) then self:SetNWBool("Display", false); end
				self.SoundLoop:FadeOut(1);
			end
		end);
	end
end

function ENT:OnRemove()
	self.SoundLoop:Stop();
end

function ENT:PreEntityCopy()
	local dupeInfo = {}
	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end

	duplicator.StoreEntityModifier(self, "DestConDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "DestConDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	if (IsValid(ply)) then
		local PropLimit = GetConVar("CAP_lantholo_max"):GetInt();
		if(ply:GetCount("CAP_lantholo")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Lantean Holo limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return;
		end
	end

	local dupeInfo = Ent.EntityMods.DestConDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if (IsValid(ply)) then
		self.Owner = ply;
		ply:AddCount("CAP_lantholo", self.Entity)
	end

end