--[[
	Nox Hands
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
if SERVER then
	AddCSLuaFile("shared.lua");
else
	-- Inventory Icon
	if(file.Exists("materials/VGUI/weapons/nox_hands.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/nox_hands.vmt")
	end
	-- Kill Icon
	if(file.Exists("materials/weapons/ring_killicon.vmt","GAME")) then
		killicon.Add("ring_ring","weapons/ring_killicon",Color(255,255,255));
		killicon.Add("ring_base","weapons/ring_killicon",Color(255,255,255));
		killicon.Add("ring_panel","weapons/ring_killicon",Color(255,255,255));
	end
end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_nox");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
SWEP.Instructions = SGLanguage.GetMessage("weapon_misc_nox_desc")
end
SWEP.Author = "Madman07"
SWEP.Contact = "madman097@gmail.com"
SWEP.Purpose = "Nox Hands"
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 5;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/weapons/c_arms_animations.mdl";
SWEP.WorldModel = "models/Weapons/w_bugbait.mdl";

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo	= "none";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = true;
SWEP.Secondary.Ammo	= "none";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

function SWEP:Initialize()
	self:SetWeaponHoldType("pistol")
end

--################### Open Gate dialogue and overwrite default method @Madman07
function SWEP:PrimaryAttack()
	if(CLIENT) then return end;

	local p = self.Owner;
	local gate = StarGate.FindGate(p, 1000)
	if not IsValid(gate) then return end;

	if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,gate) == false) then return end;

	umsg.Start("StarGate.OpenDialMenuDHDNox",p);
	umsg.Entity(gate);
	umsg.End();

	self.Weapon:SetNextPrimaryFire(CurTime()+1);
end

--################### Heal @Mad
function SWEP:SecondaryAttack()
	if(CLIENT) then return end;

	local tr = self.Owner:GetEyeTrace();
	if (IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.HitPos:Distance(self.Owner:GetShootPos()) <= 500) then
		tr.Entity:SetHealth(math.Clamp(tr.Entity:Health()+1, 0, 150));
	end
	self:SetNextSecondaryFire(CurTime()+0.1);
end

--################### Tell a player how to use this @aVoN
function SWEP:DrawHUD()
	draw.WordBox(8,ScrW()-315,ScrH()-50,"Primary: Open Stargate dial menu    Secondary: Heal friend","Default",Color(0,0,0,80),Color(255,220,0,220));
end
