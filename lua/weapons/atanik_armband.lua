--[[
	Atanik Armband
	Copyright (C) 2012 Llapp
]]--
if SERVER then
	if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
	AddCSLuaFile();
end

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_atanik");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
else
SWEP.PrintName = "Atanik Armband";
SWEP.Category = "Carter Addon Pack";
end
SWEP.Author = "Llapp"
SWEP.Contact = "llapp612@googlemail.com"
SWEP.Purpose = "Atanik Armband"
SWEP.Instructions = "Makes you stronger and faster."
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 5;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/Weapons/V_hands.mdl";
SWEP.WorldModel = "models/weapons/w_bugbait.mdl";
SWEP.ViewModelFOV = 90
SWEP.AnimPrefix = "melee"
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);


SWEP.Primary.Delay			= 0.9
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic   	= true
SWEP.Primary.Ammo         	= "none"

SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

function SWEP:Initialize()
	self:SetWeaponHoldType( "fist" )
	self.Hit = Sound( "player/pl_fallpain1.wav" );
	self.NextHit = 0;
	if (not IsValid(self.OldOwner)) then self.OldOwner = self.Owner; end
end

function SWEP:PrimaryAttack()
	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 0.4 );
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
 	local tr = self.Owner:GetEyeTrace();
	if tr.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
	    local ent = tr.Entity
	 	-- thats prevent double playing sound in mp
	    if (SERVER) then
	   		self.Owner:EmitSound(self.Hit);
	    end
	    self:Hurt(55); -- And why this not working on dedicated server?!
	end
end

function SWEP:SecondaryAttack()
	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 1 );
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
 	local tr = self.Owner:GetEyeTrace();
	if tr.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
		local ent = tr.Entity
		-- thats prevent double playing sound in mp
		if (SERVER) then
        	self.Owner:EmitSound(self.Hit);
        end
	    self:Hurt(200); -- And why this not working on dedicated server?!
	end
end

function SWEP:Hurt(damage)
	local bullet = {}
	bullet.Num    = 1
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(0.1, 0.1, 0)
	bullet.Tracer = 0
	bullet.Force  = 10
	bullet.Damage = damage
	self.Owner:FireBullets(bullet)
end

--################### Tell a player how to use this @aVoN
function SWEP:DrawHUD()
	draw.WordBox(8,ScrW()-315,ScrH()-50,"Melee mode: You are stronger and faster.","Default",Color(0,0,0,80),Color(255,220,0,220));
end

if SERVER then

function SWEP:OnDrop()
	self:SetNWBool("WorldNoDraw",false);
	if (IsValid(self.OldOwner) and self.OldOwner.CAP_Atanik) then
		self.OldOwner:SetRunSpeed(500)
		self.OldOwner:SetJumpPower(200)
		self.OldOwner:SetArmor(0)
		self.OldOwner.CAP_Atanik = nil
		self.OldOwner = NULL
	end
	return true;
end

function SWEP:Equip()
	self:SetNWBool("WorldNoDraw",true);
	return true;
end

function SWEP:OwnerChanged()
	self.OldOwner = self.Owner;
end

end

if CLIENT then

-- Inventory Icon
if(file.Exists("materials/VGUI/weapons/atanik_inventory.vmt","GAME")) then
   SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/atanik_inventory");
end

function SWEP:DrawWorldModel()
	if (not self:GetNWBool("WorldNoDraw")) then
		self:DrawModel();
	end
end

function SWEP:GetViewModelPosition(p,a)
	p = p - a:Up() - 10*a:Forward() + 1*a:Right();
	return p,a;
end

end