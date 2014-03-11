if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_asuran");
SWEP.Category = SGLanguage.GetMessage("weapon_cat");
end
SWEP.Author = "RononDex"
SWEP.Purpose = "Kill People"
SWEP.Instructions = "Shoot First, ask questions later"
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);
list.Add("NPCUsableWeapons", {class = "weapon_asura", title = SWEP.PrintName or ""});
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/micropro/Asuragun/v_asugun/v_asugun.mdl"
SWEP.WorldModel = "models/micropro/Asuragun/w_asugun/w_asugun.mdl"

-- Lol, without this we can't use this weapon in mp on gmod13...
if SERVER then
	AddCSLuaFile();
end

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 100;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo	= "HelicopterGun";

-- secondary
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

function SWEP:Initialize()

	self:SetWeaponHoldType("pistol");

end

if CLIENT then
	-- Inventory Icon
	if(file.Exists("materials/VGUI/weapons/asuran_inventory.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/asuran_inventory");
	end
end

function SWEP:EquipAmmo()
    if (self.Owner.GiveAmmo) then
		self.Owner:GiveAmmo(100,"HelicopterGun");
  	end
end

function SWEP:Deploy()
	if (not IsValid(self) or not IsValid(self.Owner)) then return end
	self.Owner:EmitSound(Sound("pulse_weapon/asuran_hand_deploy.wav"),75,math.random(75,125))

end

function SWEP:Effects() --###### Energy Muzzle and Recoil Effect @RononDex,aVoN

	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	-- Muzzle
	local fx = EffectData();
		fx:SetScale(0);
		fx:SetOrigin(self.Owner:GetShootPos());
		fx:SetEntity(self.Owner);
		fx:SetAngles(Angle(255,50,50));
		fx:SetRadius(64);
	util.Effect("energy_muzzle_asuran",fx,true);
	-- Shot
	self.Weapon:SetNextPrimaryFire(CurTime()+0.2);
	return true;
end

function SWEP:PrimaryAttack() --###### Shoot @Ronondex, aVoN

	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;
	self:Effects()


	if(SERVER) then
		local p = self.Owner;
		local multiply = 3; -- Default inaccuracy multiplier
		local aimvector = p:GetAimVector();
		local shootpos = p:GetShootPos();
		local vel = p:GetVelocity();
		local filter = {self.Owner,self.Weapon};

		-- Add inaccuracy for players!
		if(p:IsPlayer()) then
			local right = aimvector:Angle():Right();
			local up = aimvector:Angle():Up();
			-- Check, how far we can go to right (avoids exploding shots on the wall right next to you)
			local max = util.QuickTrace(shootpos,right*100,filter).Fraction*100 - 10;
			local trans = right:DotProduct(vel)*right/25
			if(p:Crouching()) then
				multiply = 0.3; -- We are in crouch - Make it really accurate!
				-- We need to adjust shootpos or it will look strange
				shootpos = shootpos + math.Clamp(15,-10,max)*right - 4*up + trans;
			else
				-- He stands
				shootpos = shootpos + math.Clamp(23,-10,max)*right - 15*up + trans;
			end
			multiply = multiply*math.Clamp(vel:Length()/500,0.3,3); -- We are moving - Make it inaccurate depending on the velocity
		else -- It's an NPC
			multiply = 0;
		end
		-- Now, we need to correct the velocity depending on the changed shootpos above.
		local trace = util.QuickTrace(p:GetShootPos(),16*1024*aimvector,filter);
		if(trace.Hit) then
			aimvector = (trace.HitPos-shootpos):GetNormalized();
		end
		local e = ents.Create("energy_pulse")
		e:SetPos(shootpos)
		e:PrepareBullet(aimvector, multiply, 8000, 1);
		e:SetOwner(p);
		e.Owner = p;
		e.Damage = 100;
		e:Spawn();
		e:Activate();
		e:SetColor(Color(119,176,255,215))
		p:EmitSound(Sound("pulse_weapon/asuran_hand_fire.wav"),90,math.random(97,103));
		if(self.Owner:IsPlayer()) then self:TakePrimaryAmmo(1) end; -- Take one Ammo
	end
end