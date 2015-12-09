if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapons")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	SWEP.PrintName = SGLanguage.GetMessage("weapon_tac");
	SWEP.Category = SGLanguage.GetMessage("weapon_cat");
end
SWEP.Author = "Ronon Dex, Boba Fett, AlexALX";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Throw with Left Click, Change Mode with Right Click";
SWEP.Base = "weapon_base";
SWEP.Slot = 4;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/boba_fett/tac/tac.mdl";
SWEP.WorldModel = "models/boba_fett/tac/w_tac.mdl";
SWEP.ViewModelFOV = 60;

SWEP.Primary.ClipSize = 1;
SWEP.Primary.DefaultClip = 3;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo	= "none";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "none";

SWEP.HoldType = "grenade";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType);
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
end

SWEP.Sounds = {SwingSound = Sound( "weapons/slam/throw.wav" ), SwitchMode=Sound("buttons/button5.wav")}

if SERVER then

AddCSLuaFile();

SWEP.CanThrow = true;
SWEP.WepMode = 1;
//self:SetNWInt("Mode",self.WepMode);
SWEP.NextUse = CurTime();
SWEP.Kill = true;
SWEP.Stun = false;
SWEP.Smoke = false;

SWEP.Ammo = 3;

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
	local pGrenade = ents.Create( "tac_bomb" );
	--pGrenade:SetOwner( pPlayer );
	--pGrenade:SetModel("models/boba_fett/tac/w_tac.mdl");
	pGrenade:SetPos( vecSrc );
	pGrenade:SetAngles( Angle() );
	pGrenade:Spawn()
	pGrenade:Activate();
	pGrenade:GetPhysicsObject():SetVelocity( vecThrow );
	pGrenade:GetPhysicsObject():AddAngleVelocity( Vector(600,math.random(-1200,1200),0) );

	if ( pGrenade ) then
	
		pGrenade.IsThrownTac = true;
		self.CanThrow = false;
		self:SetNWBool("CanThrow",false);
		self.ThrownTac = true;
		self.Tac = pGrenade;
		pGrenade.Owner = self.Owner;

		if(self.Kill) then
			pGrenade.Kill = true;
		elseif(self.Stun) then
			pGrenade.Stun = true;
		elseif(self.Smoke) then
			pGrenade.Smoke = true;
		end
	
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
		--if (self.Ammo<=0) then
			--self.Owner:StripWeapon(self:GetClass());
			--self:Remove();
		--end
	end
end
end

function SWEP:PrimaryAttack()
	if (not IsValid(self)) then return end
	if(self:GetNWBool("CanThrow",true)) then
		self.Weapon:SendWeaponAnim( ACT_VM_PULLPIN );
		timer.Simple(1.0,function()
			if (IsValid(self.Weapon)) then
				self.Weapon:SendWeaponAnim( ACT_VM_THROW );
				timer.Simple(1,function()
					if (IsValid(self.Weapon)) then
						self.Weapon:SendWeaponAnim( ACT_VM_IDLE );
					end
				end);
			end
		end)
	end

	if (SERVER) then
		timer.Simple(0.5, function() 
			if (IsValid(self) and IsValid(self.Owner)) then 
				self.Owner:SetAnimation( PLAYER_ATTACK1 ); 
			end 
		end); 
		if(self.CanThrow) then
			self.Throw = CurTime()+1;
		else
			if(self.ThrownTac) then
				if(not self.Tac.Smoke) then
					self.Tac:Destroy();
				else
					self.Tac:StartSmoke();
				end
			end
		end
	end
	
	self:SetNextPrimaryFire(CurTime()+2);
end

/*
function SWEP:SecondaryAttack()

	if(IsValid(self)) then
		if(self.ThrownTac) then

			self.Tac:Destroy();
			self.CanThrow = true;
			self.ThrownTac = false;
			self.Tac = NULL;

		end
	end
end
*/

if (SERVER) then
SWEP.NextUse = CurTime()
function SWEP:SecondaryAttack()
	local p = self.Owner;
	if (not IsValid(p)) then return end
	if self.NextUse < CurTime() then
		if self.WepMode == 1 then
			self.Kill = false;
			self.Stun = true;
			self.Smoke = false
			self.WepMode = 2;
		elseif(self.WepMode == 2) then
			self.Kill = false;
			self.Stun = false;
			self.Smoke = true;
			self.WepMode = 3;
		elseif(self.WepMode == 3) then
			self.Kill = true;
			self.Stun = false;
			self.Smoke = false;
			self.WepMode = 1;
		end
		self:SetNWInt("Mode",self.WepMode);
		self:EmitSound(self.Sounds.SwitchMode);
		self.NextUse = CurTime() + 0.1;
	end
end

end

if CLIENT then

function SWEP:DrawHUD()
	local mode = "Kill";
	local int = self:GetNetworkedInt("Mode");
	if int == 1 then
		mode = "Kill";
	elseif int == 2 then
		mode = "Stun";
	elseif int == 3 then
		mode = "Smoke";
	end
	draw.WordBox(8,ScrW()-188,ScrH()-120,"Mode: "..mode,"Default",Color(0,0,0,80),Color(255,220,0,220));
end

end