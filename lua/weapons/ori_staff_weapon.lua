if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_ori_staff");
SWEP.Category = SGLanguage.GetMessage("weapon_cat");
end
SWEP.Author = "RononDex, Boba Fett"
SWEP.Purpose = "Kill the non believers"
SWEP.Instructions = "Shoot the Non Believers"
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);
list.Add("NPCUsableWeapons", {class = "ori_staff_weapon", title = SWEP.PrintName});
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/Boba_Fett/ori_staff/v_ori_staff.mdl"
SWEP.WorldModel = "models/Boba_Fett/ori_staff/w_ori_staff.mdl"

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

-- Add weapon for NPCs
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
list.Set("NPCWeapons","ori_staff_weapon",SGLanguage.GetMessage("weapon_ori_staff"));
end

function SWEP:Initialize()

	self:SetWeaponHoldType("shotgun");

end

function SWEP:Effects() --###### Energy Muzzle and Recoil Effect @RononDex,aVoN

	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	-- Shot
	self.Weapon:SetNextPrimaryFire(CurTime()+0.5);
--	return true;
end

if CLIENT then
	-- Inventory Icon
	if(file.Exists("materials/VGUI/weapons/ori_staff_weapon_inventory.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/ori_staff_weapon_inventory");
	end
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
		e:SetPos(shootpos + p:GetForward()*94 + p:GetRight()*-15 + p:GetUp()*5)
		e:PrepareBullet(aimvector, multiply, 8000, 2);
		e:SetOwner(p);
		e.Owner = p;
		e.Damage = 100;
		e:Spawn();
		e:Activate();
		e:SetColor(Color(119,176,255,215))
		p:EmitSound(Sound("pulse_weapon/ori_staff.wav"),90,math.random(90,110));
		if(self.Owner:IsPlayer()) then self:TakePrimaryAmmo(1) end; -- Take one Ammo
	end
end