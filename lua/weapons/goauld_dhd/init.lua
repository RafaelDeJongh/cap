--[[
	Goauld DHD
	Copyright (C) 2010 Madman07
]]--

if (not StarGate.CheckModule("extra")) then return end

AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");
include("shared.lua");

SWEP.Sounds = {

}

SWEP.AttackMode = 1;
SWEP.Delay = 5;

function SWEP:Initialize()
	self:SetWeaponHoldType("slam");
end

function SWEP:PrimaryAttack(fast)
	local delay = 0;
	self.Weapon:SetNextPrimaryFire(CurTime()+0.5);
	local e = self.Weapon;
	timer.Simple(delay,
		function()
			if(IsValid(e) and IsValid(e.Owner)) then
				e:SpawnProp();
				--self:OpenMenu(e.Owner);
				--self:EmitSound(self.Sounds.SwitchMode1, 150);
			end
		end
	);
	return true;
end

function SWEP:SpawnProp()
	local p = self.Owner;

	local pos;
	local ang;

	tr = util.TraceLine(util.GetPlayerTrace(p));

	if not IsValid(tr.Entity) then return end
	if not tr.Entity:GetClass():find("stargate") then return end

	if (p:GetPos():Distance(tr.HitPos) > 150) then return end


	pos = tr.HitPos;
	ang = tr.HitNormal:Angle();
	ang.Pitch = ang.Pitch+90;

	local ent = ents.Create("goauld_dhd_prop");
	ent:SetPos(pos);
	ent:SetAngles(ang);
	ent:SetModel("models/Boba_Fett/portable_dhd/portable_dhd.mdl");
	ent:Spawn();
	ent:Activate();
	ent.Owner = p;
	ent.Gates = tr.Entity;
	ent:DialMenu();

	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then phys:EnableMotion(false) end
	constraint.Weld(ent,tr.Entity,0,0,0,true)

	p:SelectWeapon("weapon_physgun");
	self:Remove();

end