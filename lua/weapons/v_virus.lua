/*
	Gate Virus
	Copyright (C) 2011 Llapp
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_virus");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end
SWEP.Author = "Llapp, Boba Fett, Assassin21";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Left Click = Activate Virus.";
SWEP.Base = "weapon_base";
SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/Assassin21/AGV/v_agv.mdl";
SWEP.WorldModel = "models/Assassin21/AGV/agv.mdl";
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
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

--################### Dummys for the client @ aVoN
function SWEP:PrimaryAttack() return false end
function SWEP:SecondaryAttack() return false end

-- to cancel out default reload function
function SWEP:Reload() return end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile();

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
	if(IsValid(tr.Entity))then
     ang = ang + tr.Entity:GetAngles();
	 ang.p = 0; ang.r = (ang.r+90) % 360; ang.y = (ang.y+180) % 360;
	end
	if(IsValid(tr.Entity) and not tr.Entity:GetClass():find("stargate_") or tr.StartPos:Distance(pos)>75)then
     return;
	end

	local PropLimit = GetConVar("CAP_agv_max"):GetInt()
	if(IsValid(p) and p:IsPlayer() and p:GetCount("CAP_agv")+1 > PropLimit) then
		p:SendLua("GAMEMODE:AddNotify(\"AGV limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return;
	end

	local ent = ents.Create("virus");
	ent:SetPos(pos);
	ent:SetAngles(ang);
	ent:SetModel("models/Assassin21/AGV/agv.mdl");
	ent:Spawn();
	ent:Activate();
	p:AddCount("CAP_agv", ent)
	ent.Owner = p;
	local phys = ent:GetPhysicsObject();
	if IsValid(phys) then phys:EnableMotion(false) end
	if(IsValid(tr.Entity))then
	    constraint.Weld(ent,tr.Entity,0,0,0,true);
	end
	p:SelectWeapon("weapon_physgun");
	self:Remove();
end

end

if CLIENT then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/virus.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/virus");
end

SWEP.Primary.Sound = "stargate/universe/kinoturnon.wav"
SWEP.Secondary.Sound = "stargate/universe/kinoturnon.wav"
SWEP.DrawAmmo	= false;
SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/virus")

--################### Positions the viewmodel correctly @aVoN
function SWEP:GetViewModelPosition(p,a)
	p = p - 8*a:Up() - 6*a:Forward() + 1*a:Right();
	a:RotateAroundAxis(a:Right(),30);
	a:RotateAroundAxis(a:Up(),5);
	return p,a;
end

end