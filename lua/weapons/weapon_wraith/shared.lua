if (not StarGate.CheckModule("weapon")) then return end
SWEP.Category = Language.GetMessage("weapon_cat");
SWEP.PrintName = Language.GetMessage("weapon_wraith");
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

SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "none";

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

SWEP.Sounds = {feeling=Sound("weapons/wraith_feeding.wav")}

list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

list.Set("NPCWeapons","weapon_wraith",Language.GetMessage("weapon_wraith"));


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

end

function SWEP:PrimaryAttack()
	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 0.6 );

	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 );

 	local tr = self.Owner:GetEyeTrace();
	if tr.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then

	    if (SERVER) then
	   		self.Owner:EmitSound(self.Hit);
	    end

		self:Hurt(20);

	end
end

function SWEP:SecondaryAttack()
	if( CurTime() < self.NextHit ) then return end
	self.NextHit = ( CurTime() + 0.5 );
	timer.Simple(0.1, function()
		if (IsValid(self)) then
			self.Owner:SetAnimation( PLAYER_ATTACK1 );
			self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_2 );
			self.Weapon:SetNextSecondaryFire(CurTime()+0.5)
		end
	end);
end

function SWEP:Hurt(damage)
	bullet = {}
	bullet.Num    = 1
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(0.1, 0.1, 0)
	bullet.Tracer = 0
	bullet.Force  = 10
	bullet.Damage = damage
	self.Owner:FireBullets(bullet)
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
						e:SetHealth(e:Health()-1);
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
						e:SetHealth(e:Health()-1);
						self.Owner:SetHealth(self.Owner:Health()+1);
						if (not self.Sound) then
							self.Owner:EmitSound(self.Sounds.feeling,100,100);
							self.Sound = true;
							self.SoundTime = CurTime()+2;
						end
					end
				end
			end
			if e:Health() < 1 then
				if e:IsNPC() then
					e:SetNPCState(NPC_STATE_DEAD);
					timer.Simple(30, function()
						if IsValid(e) then
							e:Remove(); -- Remove corpse after 30 seconds
						end
					end);
				elseif e:IsPlayer() then
					e:Kill();
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