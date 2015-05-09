if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.Category = SGLanguage.GetMessage("weapon_cat");
SWEP.PrintName = SGLanguage.GetMessage("weapon_wraith_grenade");
end
SWEP.Author = "Ronon Dex"
SWEP.Contact = ""
SWEP.Purpose = "Blow Stuff Up."
SWEP.Instructions = ""
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= true;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/pg_props/pg_weapons/pg_wraith_hands_granate.mdl";
SWEP.WorldModel = "models/Weapons/w_bugbait.mdl";

if SERVER then
	AddCSLuaFile();
end

if CLIENT then
	if(file.Exists("materials/VGUI/weapons/wraith_hands.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/wraith_hands.vmt")
	end
end

SWEP.Primary.ClipSize = 1;
SWEP.Primary.DefaultClip = 3;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "grenade";

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

SWEP.Sounds = {feeling=Sound("weapons/wraith_feeding.wav"),SwingSound = Sound( "weapons/slam/throw.wav" ),HitSound=Sound("Flesh.ImpactHard")}

SWEP.HitDistance = 67

list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
end


function SWEP:PrimaryAttack()
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

	timer.Simple(1, function()
		local tr = util.TraceLine(util.GetPlayerTrace(self.Owner));

		local e = ents.Create("wraiths_grenade");
		e:SetPos(tr.StartPos+Vector(20,-10,10));
		e:Spawn();
		e:Activate();
		e.Owner = self.Owner;
		e.Mine = false;
		local p = e:GetPhysicsObject()
		if (IsValid(p)) then
			p:Wake()
			p:AddAngleVelocity(Vector(100,50,200))
			p:SetVelocity(self.Owner:GetAimVector()*Vector(250,250,0));
		end
	end);
	self:SetNextPrimaryFire(CurTime()+1);
end

function SWEP:SecondaryAttack()
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK);
	timer.Simple(1, function()

		local e = ents.Create("wraiths_grenade");
		e:SetPos(self.Owner:GetPos()+Vector(20,0,10));
		e:Spawn();
		e:Activate();
		e.Owner = self.Owner;
		e.Mine = true;
		e.CanExplode = CurTime() + 1;
		local p = e:GetPhysicsObject()
		if (IsValid(p)) then
			p:Wake()
			//p:AddAngleVelocity(Vector(100,50,200))
			//p:SetVelocity(self.Owner:GetAimVector()*Vector(250,250,0));
		end
	end);
	self:SetNextSecondaryFire(CurTime()+1);
end
