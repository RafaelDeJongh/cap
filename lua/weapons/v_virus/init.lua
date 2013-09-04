/*
	Gate Virus
	Copyright (C) 2011 Llapp
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");
include("shared.lua");

SWEP.Delay = 5;

function SWEP:PrimaryAttack(fast)
	local delay = 0;
	self.Weapon:SetNextPrimaryFire(CurTime()+0.5);
	local e = self.Weapon;
	timer.Simple(delay,
		function()
			if(IsValid(e) and IsValid(e.Owner)) then
				e:SpawnProp();
			end
		end
	);
	return true;
end

function SWEP:SpawnProp()
	local p = self.Owner;
	tr = util.TraceLine(util.GetPlayerTrace(p));
	local pos = tr.HitPos;
  local ang = p:GetAimVector():Angle();
  ang.p = 0; ang.r = 0; ang.y = (ang.y+90) % 360;
 	local ent = ents.Create("virus");
	if(IsValid(tr.Entity))then
      ang = ang + tr.Entity:GetAngles();
	   ang.p = 0; ang.r = (ang.r-90) % 360; ang.y = (ang.y+180) % 360;
	end
	if(IsValid(tr.Entity) and not tr.Entity:GetClass():find("stargate_"))then
     return;
	end
	ent:SetPos(pos);
	ent:SetAngles(ang);
	ent:SetModel("models/Assassin21/AGV/agv.mdl");
	ent:Spawn();
	ent:Activate();
	ent.Owner = p;
	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then phys:EnableMotion(false) end
	if(IsValid(tr.Entity))then
	    constraint.Weld(ent,tr.Entity,0,0,0,true);
	end
	p:SelectWeapon("weapon_physgun");
	self:Remove();
end