--[[
	Shaped Charge
	Copyright (C) 2010 Madman07
]]--

if (not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds = {
	Tick = Sound("tech/bomb_tick.wav"),
	Explode = Sound("weapons/dir_nuke.wav"),
}

-----------------------------------INIT----------------------------------

function ENT:Initialize()
	self.Entity:SetModel("models/Madman07/directional_nuke/directional_nuke.mdl");

	self.Entity:SetName("Shaped Charge");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self:SetNetworkedInt("Timer",0);
	self:SetNWBool("ShouldCount",false);
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_dirn_max"):GetInt()
	if(ply:GetCount("CAP_dirn")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Shaped Charge limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("directional_nuke");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos+Vector(0,0,20));
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAP_dirn", ent)
	return ent
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("CAP_dirn_max"):GetInt()
	if(ply:GetCount("CAP_dirn")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Shaped Charge limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:Remove();
		return
	end
	ply:AddCount("CAP_dirn", self.Entity)
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

-----------------------------------USE----------------------------------

function ENT:Use(ply)
	if (self.Owner == ply) then
		umsg.Start("DirectTimer",ply)
		umsg.Entity(self.Entity);
		umsg.End()
		if timer.Exists("Count"..self:EntIndex()) then timer.Destroy("Count"..self:EntIndex()); end
		if timer.Exists("Tick"..self:EntIndex()) then timer.Destroy("Tick"..self:EntIndex()); end
		self:SetNWBool("ShouldCount",false);
	end
end

-----------------------------------OTHER CRAP----------------------------------

function ENT:Think(ply)
	concommand.Add("DN_Set"..self:EntIndex(),function(ply,cmd,args)
		self:SetNWBool("ShouldCount",false);
		local time = tonumber(args[1]);
		self:SetNWInt("Timer",time+1);
		self:SetNWBool("ShouldCount",true);
		if timer.Exists("Count"..self:EntIndex()) then timer.Destroy("Count"..self:EntIndex()); end
		timer.Create( "Count"..self:EntIndex(), time, 1, function()
			self:SetNWBool("ShouldCount",false);
			if IsValid(self) then self:DoExplosion(); end
		end);
		if timer.Exists("Tick"..self:EntIndex()) then timer.Destroy("Tick"..self:EntIndex()); end
		if (time > 1) then
			timer.Create( "Tick"..self:EntIndex(), 1, time-1, function()
				self:EmitSound(self.Sounds.Tick,100,100);
			end);
		end
		self:EmitSound(self.Sounds.Tick,100,100);
    end);
end

function ENT:DoExplosion()
	local a  = StarGate.FindGate(self, 600)
	if IsValid(a) then a:WormHoleJump(true) end

	self:EmitSound(self.Sounds.Explode,100,100);

	local b = self:GetAttachment(self:LookupAttachment("Front"))
	if(not (b and b.Pos)) then return end
	local attacker,owner = StarGate.GetAttackerAndOwner(self.Entity);
	util.ScreenShake(b.Pos,2,2.5,1,700);
	util.BlastDamage(owner, attacker, b.Pos, 250, 250)

	local effectdata = EffectData()
		effectdata:SetStart(b.Pos) // not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin(b.Pos)
		effectdata:SetScale( 1 )
	util.Effect( "HelicopterMegaBomb", effectdata )
	self.Entity:Remove();
end

function ENT:OnRemove()
	if timer.Exists("Count"..self:EntIndex()) then timer.Destroy("Count"..self:EntIndex()); end
	if timer.Exists("Tick"..self:EntIndex()) then timer.Destroy("Tick"..self:EntIndex()); end
end