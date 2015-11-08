if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	SWEP.Category = SGLanguage.GetMessage("weapon_cat");
	SWEP.PrintName = SGLanguage.GetMessage("weapon_wraith_grenade");
end
SWEP.Author = "Ronon Dex, AlexALX"
SWEP.Contact = ""
SWEP.Purpose = "Blow Stuff Up."
SWEP.Instructions = ""
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/pg_props/pg_weapons/pg_wraith_hands_granate.mdl";
SWEP.WorldModel = "models/pg_props/pg_weapons/pg_wraith_hands_granate_w.mdl";
SWEP.ViewModelFOV = 65;

if SERVER then
	AddCSLuaFile();
end

if CLIENT then
	if(file.Exists("materials/VGUI/weapons/wraith_hands.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/wraith_hands.vmt")
	end
end

SWEP.HoldType = "grenade";

SWEP.Primary.ClipSize = 1;
SWEP.Primary.DefaultClip = 3;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "none";

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

SWEP.Sounds = {feeling=Sound("weapons/wraith_feeding.wav"),SwingSound = Sound( "weapons/slam/throw.wav" ),HitSound=Sound("Flesh.ImpactHard")}

--SWEP.HitDistance = 67

list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);

SWEP.Ammo = 3;

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType);
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
end

if SERVER then
local GRENADE_RADIUS	= 4.0;

-- Thanks to swep-bases code
function SWEP:CheckThrowPosition( pPlayer, vecEye, vecSrc )
	local tr;

	tr = {}
	tr.start = vecEye
	tr.endpos = vecSrc
	tr.mins = -Vector(GRENADE_RADIUS+2,GRENADE_RADIUS+2,GRENADE_RADIUS+2)
	tr.maxs = Vector(GRENADE_RADIUS+2,GRENADE_RADIUS+2,GRENADE_RADIUS+2)
	tr.mask = MASK_PLAYERSOLID
	tr.filter = pPlayer
	tr.collision = pPlayer:GetCollisionGroup()
	local trace = util.TraceHull( tr );

	if ( trace.Hit ) then
		vecSrc = tr.endpos;
	end

	return vecSrc
end

function SWEP:ThrowGrenade()
	if (not IsValid(self) or not IsValid(self.Owner)) then return end
	local pPlayer = self.Owner;

	local	vecEye = pPlayer:EyePos();
	local	vForward, vRight;

	vForward = pPlayer:GetForward();
	vRight = pPlayer:GetRight();
	local vecSrc = vecEye + vForward * 18.0 + vRight * 8.0;
	vecSrc = self:CheckThrowPosition( pPlayer, vecEye, vecSrc );
//	vForward.x = vForward.x + 0.1;
//	vForward.y = vForward.y + 0.1;

	local vecThrow;
	vecThrow = pPlayer:GetVelocity();
	vecThrow = vecThrow + vForward * 1200;
	local pGrenade = ents.Create( "wraiths_grenade" );
	pGrenade:SetOwner( pPlayer );
	--pGrenade:Fire( "SetTimer", GRENADE_TIMER );
	pGrenade:SetPos( vecSrc );
	pGrenade:SetAngles( Angle() );
	pGrenade:Spawn()
	pGrenade:GetPhysicsObject():SetVelocity( vecThrow );
	pGrenade:GetPhysicsObject():AddAngleVelocity( Vector(600,math.random(-1200,1200),0) );

	if ( pGrenade ) then
		if ( pPlayer && !pPlayer:Alive() ) then
			vecThrow = pPlayer:GetVelocity();

			local pPhysicsObject = pGrenade:GetPhysicsObject();
			if ( pPhysicsObject ) then
				vecThrow = pPhysicsObject:SetVelocity();
			end
		end

		pGrenade.m_flDamage = self.Primary.Damage;
		pGrenade.m_DmgRadius = GRENADE_DAMAGE_RADIUS;
	end
end

function SWEP:Think()
	if (self.Throw and self.Throw<CurTime()) then
		self:ThrowGrenade();
		self.Throw = false;
		--self.Owner:RemoveAmmo( 1, self.Primary.Ammo );
		self.Ammo = self.Ammo - 1;
		self.Owner:EmitSound( self.Sounds.SwingSound, 75, math.random(80, 120) );
		if (self.Ammo<=0) then
			--self.Owner:StripWeapon(self:GetClass());
			self:Remove();
		else
			timer.Simple(0.6,function()
				if (IsValid(self.Weapon)) then
					self.Weapon:SendWeaponAnim( ACT_VM_IDLE );
				end
			end);
		end
	end
end
end

function SWEP:PrimaryAttack()
	--self.Owner:SetAnimation( PLAYER_ATTACK1 );
	if SERVER then 
		timer.Simple(0.5, function() 
			if (IsValid(self.Owner)) then 
				self.Owner:SetAnimation( PLAYER_ATTACK1 ); 
			end 
		end); 
	end
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );

	if SERVER then
		self.Throw = CurTime()+1.0;
	end
	
	self:SetNextPrimaryFire(CurTime()+1.75);
end

function SWEP:SecondaryAttack()
	self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK);
	if SERVER then
		timer.Simple(1, function()
			if (!IsValid(self) or !IsValid(self.Owner)) then return end

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
			--if(IsValid(self.Owner) and self.Owner:IsPlayer()) then self:TakePrimaryAmmo(1) end; -- Take one Ammo
			self.Ammo = self.Ammo - 1;
			--self.Owner:EmitSound( Sound("WeaponFrag.Roll"), 75, math.random(80, 120) );
			if (self.Ammo<=0) then 
				self:Remove();
			else
				timer.Simple(1.3,function()
					if (IsValid(self.Weapon)) then
						self.Weapon:SendWeaponAnim( ACT_VM_IDLE );
					end
				end);
			end
		end);
	end
	self:SetNextSecondaryFire(CurTime()+2.5);
end
