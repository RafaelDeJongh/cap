--[[
	Goauld DHD
	Copyright (C) 2010 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_gdhd");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end
SWEP.Author = "Madman07, Boba Fett";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Left Click = Open dial menu and plant the DHD.";
SWEP.Base = "weapon_base";
SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/Boba_Fett/portable_dhd/v_portable_dhd.mdl";
SWEP.WorldModel = "models/Boba_Fett/portable_dhd/portable_dhd.mdl";
SWEP.ViewModelFOV = 90

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "none";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "none";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);

--################### Dummys for the client @ aVoN
function SWEP:PrimaryAttack() return false end
function SWEP:SecondaryAttack() return false end

-- to cancel out default reload function
function SWEP:Reload() return end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile();

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

end

if CLIENT then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/pdd_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/pdd_inventory");
end

SWEP.Primary.Sound = "stargate/universe/kinoturnon.wav"
SWEP.Secondary.Sound = "stargate/universe/kinoturnon.wav"
SWEP.DrawAmmo	= false;
SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/pdd_inventory")

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - 10*a:Up() - 6*a:Forward() + 1*a:Right();
	a:RotateAroundAxis(a:Right(),30);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end

end