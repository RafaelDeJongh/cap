if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.Category = SGLanguage.GetMessage("weapon_cat");
SWEP.PrintName = SGLanguage.GetMessage("weapon_wraith_blaster");
end

-- Lol, without this we can't use this weapon in mp on gmod13...
if SERVER then
	if (StarGate and StarGate.CFG and StarGate.CFG:Get("cap_disabled_swep","weapon_blaster",false)) then return end
	AddCSLuaFile();
end

SWEP.Author = "Ronon Dex"
SWEP.Contact = ""
SWEP.Purpose = "Stun"
SWEP.Instructions = "Aim, Fire and Stun"
SWEP.Base = "weapon_base";
SWEP.Slot = 2;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= true;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/pg_props/pg_weapons/pg_wraithblaster_viewmodel.mdl";
SWEP.WorldModel = "models/pg_props/pg_weapons/pg_test_weapon_w.mdl";

if CLIENT then
	if(file.Exists("materials/VGUI/weapons/wraith_blaster.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/wraith_blaster.vmt")
	end
end

SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 100;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo	= "HelicopterGun";

SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

list.Set("CAP.Weapon", SWEP.PrintName, SWEP);
list.Add("NPCUsableWeapons", {class = "weapon_blaster", title = SWEP.PrintName});

SWEP.Sounds = Sound("weapons/wraith_stunner.wav");

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
list.Set("NPCWeapons","weapon_blaster",SGLanguage.GetMessage("weapon_wraith_blaster"));
end

function SWEP:Initialize()

	if CLIENT then
		local mat = Matrix()
		mat:Scale(Vector(0.2,0.2,0.2))
		self:EnableMatrix( "RenderMultiply", mat )
	end
	self:SetWeaponHoldType("shotgun");
end

if CLIENT then

function SWEP:Effects() --###### Energy Muzzle and Recoil Effect @RononDex,aVoN

	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;
	--self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK);
	-- Muzzle
	local fx = EffectData();
		fx:SetScale(0);
		fx:SetOrigin(self:GetPos());
		fx:SetEntity(self.Owner);
		fx:SetAngles(Angle(255,50,50));
		fx:SetRadius(64);
	util.Effect("energy_muzzle_asuran",fx,true);
	-- Shot


end

end

function SWEP:PrimaryAttack() --###### Shoot @Ronondex, aVoN

	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;

	if CLIENT then self:Effects() end;

	if(SERVER) then

		self.Weapon:SetNextPrimaryFire(CurTime()+0.4);


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
		-- Add some randomness to the velocity
		local e = ents.Create("energy_pulse");
		e:PrepareBullet(aimvector, multiply, 8000, 1);
		e:SetPos(shootpos);
		e:SetOwner(p);
		e.Owner = p;
		e:Spawn();
		e:Activate();
		e:SetColor(Color(119,176,255,215));
		e:EmitSound(self.Sounds,math.random(90,110),math.random(90,110));
		if(self.Owner:IsPlayer()) then self:TakePrimaryAmmo(1) end; -- Take one Ammo
	end
end

function SWEP:SecondaryAttack() --###### Shoot @Ronondex, aVoN

	if(not IsValid(self.Owner) or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0)) then return end;

	if CLIENT then self:Effects() end;


	if(SERVER) then

		self.Weapon:SetNextSecondaryFire(CurTime()+0.5);

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
		-- Add some randomness to the velocity
		local e = ents.Create("energy_pulse_stun");
		e:PrepareBullet(aimvector, multiply, 8000, 1);
		e:SetPos(shootpos);
		e:SetOwner(p);
		e.Owner = p;
		e:Spawn();
		e:Activate();
		e:SetColor(Color(119,176,255,215));
		e:EmitSound(self.Sounds,math.random(90,110),math.random(90,110));
		if(self.Owner:IsPlayer()) then self:TakePrimaryAmmo(1) end; -- Take one Ammo
	end
end