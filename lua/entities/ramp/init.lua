if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

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