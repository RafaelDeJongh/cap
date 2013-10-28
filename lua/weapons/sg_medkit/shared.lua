if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_atl_medkit");
	SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end

list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

if (SERVER) then
	AddCSLuaFile("shared.lua");
end

if CLIENT then
	if(file.Exists("materials/VGUI/weapons/sg_medkit.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/sg_medkit.vmt")
	end
end

SWEP.Author 		= "Gmod4phun, Progsys, AlexALX"
SWEP.Purpose		= "Give medical supplies to your friends."
SWEP.Instructions	= "Left click to heal yourself. Right click to throw Adrenaline."

SWEP.AdminSpawnable = false
SWEP.Spawnable 		= false

SWEP.ViewModelFOV 	= 64
SWEP.ViewModel 		= "models/pg_props/pg_weapons/pg_healthkit_v.mdl"
SWEP.WorldModel 	= "models/pg_props/pg_weapons/pg_healthkit_w.mdl"

SWEP.AutoSwitchTo 	= false
SWEP.AutoSwitchFrom = true

SWEP.Slot 			= 1
SWEP.SlotPos = 1

SWEP.HoldType = "slam"

SWEP.FiresUnderwater = true

SWEP.Weight = 5

SWEP.DrawCrosshair = false

SWEP.DrawAmmo = true

SWEP.ReloadSound = ""

SWEP.base = "weapon_base"

SWEP.Primary.Damage = 0
SWEP.Primary.ClipSize = -1
SWEP.Primary.Ammo = ""
SWEP.Primary.DefaultClip = -1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 2
SWEP.Primary.Cone = 0

SWEP.Secondary.NumberofShots = 0
SWEP.Secondary.Force = 0
SWEP.Secondary.Spread = 0
SWEP.Secondary.Sound = ""
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.Secondary.Recoil = 0
SWEP.Secondary.Delay = 2
SWEP.Secondary.TakeAmmo = 0
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.Damage = 0

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextPrimaryFire(CurTime()+0.8)
	self:SetNextSecondaryFire(CurTime()+0.8)

	timer.Simple(0.4, function()
		if (IsValid(self)) then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)
	return true
end

function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:SetNextPrimaryFire(CurTime()+4)
	self:SetNextSecondaryFire(CurTime()+4)

	if (SERVER) then
		timer.Simple(3, function()
			if (IsValid(self) and IsValid(self.Owner)) then
				if (self.Owner:Health()<120) then
					self.Owner:SetHealth(120)
				else
					if (self.Owner:Health()<165) then
						self.Owner:SetHealth(165)
					else
						if (self.Owner:Health()<200) then
							self.Owner:SetHealth(200)
							local ply = self.Owner;
							timer.Create("SGAdrenaline.Kill"..ply:EntIndex(),15.0,1,function()
								if (IsValid(ply) and ply:Health()>=180) then
									ply:Kill();
								end
							end);
						else
							self.Owner:Kill();
						end
					end
					if (self.Owner:Alive()) then
						self.Owner:SetNWBool("SGAdrenaline_Heal", true);
					end
				end
			end
		end)
	end

	timer.Simple(3.7, function()
		if (IsValid(self)) then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)

	timer.Simple(2.6, function()
		if (IsValid(self)) then
			self:EmitSound("weapons/slam/mine_mode.wav", 100, 100)
		end
	end)

	timer.Simple(0.8, function()
		if (IsValid(self)) then
			self:EmitSound("doors/door1_move.wav", 100, 200)
		end
	end)

	timer.Simple(2.2, function()
		if (IsValid(self)) then
			self:EmitSound("doors/wood_stop1.wav", 100, 200)
		end
	end)

	timer.Simple(2.2, function()
		if (IsValid(self)) then
			self:EmitSound("weapons/p90/p90_clipout.wav", 40, 170)
		end
	end)

	timer.Simple(1.6, function()
		if (IsValid(self)) then
			self:EmitSound("npc/combine_soldier/gear6.wav", 80, 120)
		end
	end)
end

function SWEP:SecondaryAttack()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_2 )
	self:SetNextPrimaryFire(CurTime()+4)
	self:SetNextSecondaryFire(CurTime()+4)

	if (SERVER) then
		timer.Simple(2.8, function()
			if (IsValid(self) and IsValid(self.Owner)) then
				local ply = self.Owner;
				local tr = ply:GetEyeTraceNoCursor();
	   			local ent = ents.Create("sg_adrenaline_thrown");
		   		ent:SetPos(tr.StartPos+ply:GetAimVector()-Vector(0,0,15))
		   		ent:SetAngles(Angle(0,ply:EyeAngles().y,0))
		   		ent:Spawn()
		   		ent:Activate()
				ent:PhysicsInit(SOLID_VPHYSICS)
				ent:SetMoveType(MOVETYPE_VPHYSICS)
				ent:SetSolid(SOLID_VPHYSICS);
				ent:SetOwner(ply);
		   		local phys = ent:GetPhysicsObject()
		   		if (IsValid(phys)) then
		   			timer.Simple(0.2, function() if (IsValid(ent)) then ent:SetOwner(NULL) end end);
		   			phys:Wake()
		   			phys:AddAngleVelocity(Vector(100,50,100))
		   			phys:SetVelocity(ply:GetAimVector()*Vector(250,250,0));
		   		else
		   			ent:Remove();
		   		end
		  	end
		end)
	end

	timer.Simple(3.48, function()
		if (IsValid(self)) then
			self:SendWeaponAnim(ACT_VM_IDLE)
		end
	end)

	timer.Simple(0.8, function()
		if (IsValid(self)) then
			self:EmitSound("doors/door1_move.wav", 100, 200)
		end
	end)

	timer.Simple(2.2, function()
		if (IsValid(self)) then
			self:EmitSound("doors/wood_stop1.wav", 100, 200)
		end
	end)

	timer.Simple(1.6, function()
		if (IsValid(self)) then
			self:EmitSound("npc/combine_soldier/gear6.wav", 80, 120)
		end
	end)

	timer.Simple(2.7, function()
		if (IsValid(self)) then
			self:EmitSound("physics/cardboard/cardboard_box_break3.wav", 80, 180)
		end
	end)

end

function SWEP:Reload()
end