/*   Copyright 2010 by Llapp   */
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Ramps"
ENT.Author = "Llapp"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IsRamp = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile();

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) ;
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
	    phys:EnableMotion(true);
		phys:Wake();
		phys:SetMass(5000);
	end
end

function ENT:SpawnFunction(p,t)   --############ @  Llapp
	if (!t.HitWorld) then return end;
	e = ents.Create("ramp") ;
	e:SetPos(t.HitPos + Vector(0,0,-10));
	ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;
	e:SetAngles(ang);
	e:DrawShadow(false);
	self.Sat = e;
	e:Spawn();
	e:Activate();
	return e;
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "ramp", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("ramp",SGLanguage.GetMessage("ramp_kill"));
end

ENT.RenderGroup = RENDERGROUP_BOTH

end