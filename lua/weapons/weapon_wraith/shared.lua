if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.Category = SGLanguage.GetMessage("weapon_cat");
SWEP.PrintName = SGLanguage.GetMessage("weapon_wraith");
end
SWEP.Author = "Ronon Dex"
SWEP.Contact = ""
SWEP.Purpose = "Feed"
SWEP.Instructions = ""
SWEP.Base = "weapon_base";
SWEP.Slot = 1;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= true;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/pg_props/pg_weapons/pg_wraith_hands.mdl";
SWEP.WorldModel = "models/Weapons/w_bugbait.mdl";

if SERVER then
	AddCSLuaFile("shared.lua");
end

if CLIENT then
	if(file.Exists("materials/VGUI/weapons/wraith_hands.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/wraith_hands.vmt")
	end
end

SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "none";

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

SWEP.Sounds = {feeling=Sound("weapons/wraith_feeding.wav"),SwingSound = Sound( "weapons/slam/throw.wav" ),HitSound=Sound("Flesh.ImpactHard")}

SWEP.HitDistance = 67

list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
list.Set("NPCWeapons","weapon_wraith",SGLanguage.GetMessage("weapon_wraith"));
end


function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
end

function SWEP:Holster()

	--Set the movement values back to default, when you holster.
	self.Owner:SetJumpPower(200);
	self.Owner:SetRunSpeed(500);

	return true;

end

function SWEP:Initialize()

	self.NextHit = 0;
	self.Hit = Sound( "player/pl_fallpain1.wav" );
	self:SetWeaponHoldType( "fist" )

end

function SWEP:PrimaryAttack()
	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 0.65 );

	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 );

	timer.Simple( 0.57, function() if (IsValid(self)) then self.Weapon:SendWeaponAnim( ACT_VM_IDLE ) end end)

    if (SERVER) then
   		self.Owner:EmitSound( self.Sounds.SwingSound )
   		self:DealDamage();
    end

end

function SWEP:SecondaryAttack()
	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 0.55 );
	timer.Simple( 0.47, function() if (IsValid(self)) then self.Weapon:SendWeaponAnim( ACT_VM_IDLE ) end end)
	timer.Simple(0.1, function()
		if (IsValid(self)) then
			self.Owner:SetAnimation( PLAYER_ATTACK1 );
			self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_2 );
			self.Weapon:SetNextSecondaryFire(CurTime()+0.5)
		end
	end);
end

function SWEP:DealDamage()
	local tr = util.TraceLine( {
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
		filter = self.Owner
	} )

	if ( !IsValid( tr.Entity ) ) then
		tr = util.TraceHull( {
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.HitDistance,
			filter = self.Owner,
			mins = self.Owner:OBBMins() / 3,
			maxs = self.Owner:OBBMaxs() / 3
		} )
	end

	if ( tr.Hit ) then self.Owner:EmitSound( self.Sounds.HitSound ) end

	if ( IsValid( tr.Entity ) ) then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage( 20 )
		dmginfo:SetDamageForce( self.Owner:GetRight() * 49125 + self.Owner:GetForward() * 99984 )
		dmginfo:SetInflictor( self )
		local attacker = self.Owner
		if ( !IsValid( attacker ) ) then attacker = self end
		dmginfo:SetAttacker( attacker )

		tr.Entity:TakeDamageInfo( dmginfo )
	end
end

if SERVER then

local col = 255;
function SWEP:Think()

	if self.Owner:KeyDown(IN_ATTACK2) then

		local eye_trace = self.Owner:GetEyeTrace();
		local e = eye_trace.Entity;
		local pos = self.Owner:GetPos();

		if IsValid(e) then
			local target_pos = e:GetPos();
			local dist = (pos - target_pos):Length();
			if dist < 100 then
				if self.Owner:Health() < 500 then
					if e:IsNPC() then
						local class = e:GetClass();
						if class == "npc_manhack" then return end;
						if class == "npc_rollermine" then return end;
						--e:SetHealth(e:Health()-1);
						e:TakeDamage(1,self.Owner);
						self.Owner:SetHealth(self.Owner:Health()+1);
						if col > 90 then
							col = col - 0.2;
						end
						--e:SetColor(Color(col,col,col,255));
						if (not self.Sound) then
							self.Owner:EmitSound(self.Sounds.feeling,100,100);
							self.Sound = true;
							self.SoundTime = CurTime()+2;
						end
					elseif e:IsPlayer() then
						--e:SetHealth(e:Health()-1);
						e:TakeDamage(1,self.Owner);
						if (not e.pShielded) then
							self.Owner:SetHealth(self.Owner:Health()+1);
						end
						if (not self.Sound) then
							self.Owner:EmitSound(self.Sounds.feeling,100,100);
							self.Sound = true;
							self.SoundTime = CurTime()+2;
						end
					end
				end
			end
		end
	else
		if (self.SoundTime and self.SoundTime<CurTime()) then
			self.Sound = false;
		end
	end

	if self.Owner:Health() > 200 then
		self.Owner:SetRunSpeed(750);
	elseif self.Owner:Health() > 300 then
		self.Owner:SetRunSpeed(850);
	elseif self.Owner:Health() > 400 then
		self.Owner:SetJumpPower(400);
	elseif self.Owner:Health() >= 500 then
		self.Owner:SetRunSpeed(1000);
		self.Owner:SetJumpPower(800);
	end
end

function SWEP:TestAnim()

	local vm = self.Owner:GetViewModel();
	local seq = vm:LookupSequence("attackRight");
	vm:SetSequence(seq)


end


end