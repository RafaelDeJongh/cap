if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_jumper");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end
SWEP.Author = "RononDex, Boba Fett"
SWEP.Purpose = "Use features of Jumper"
SWEP.Instructions = "Primary: Cloak \n Secondary: Door \n Reload: Selfdestruct"
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);
SWEP.Base = "weapon_base"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/Iziraider/remote/v_remote.mdl";
SWEP.WorldModel = "models/Iziraider/remote/w_remote.mdl";

-- Lol, without this we can't use this weapon in mp on gmod13...
if SERVER then
	AddCSLuaFile();
end

-- primary.
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo	= "none"

-- secondary
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

SWEP.Delay = 0.5;

--########## Toggle Cloak @RononDex
function SWEP:PrimaryAttack()

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	timer.Simple(self.Delay, function()
	for _,v in pairs(ents.FindByClass("puddle_jumper")) do
		if(IsValid(v) and IsValid(self.Owner)) then
			if(v.Owner==self.Owner) then
				if(not(self.Owner:KeyDown(IN_USE))) then
					if (IsValid(v.Shields) and v.Shields:Enabled()) then
                        v:ToggleShield()
					else
						v:ToggleCloak()
					end
				end
			end
		end
	end
	end);
end

if CLIENT then
	-- Inventory Icon
	if(file.Exists("materials/VGUI/weapons/remote_inventory.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/remote_inventory");
	end
end

--########## Toggle Door @RononDex
function SWEP:SecondaryAttack()

	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	timer.Simple(self.Delay, function()
	for _,v in pairs(ents.FindByClass("puddle_jumper")) do
		if(IsValid(v) and IsValid(self) and IsValid(v.Owner) and IsValid(self.Owner)) then
			if(v.Owner==self.Owner) then
				if(not(self.Owner:KeyDown(IN_USE))) then
					v:ToggleDoor()
				end
			end
		end
	end
	end);
end

--########## Go BOOM!!! @RononDex
function SWEP:Reload()

	self:SendWeaponAnim( ACT_VM_RELOAD )
	timer.Simple(self.Delay, function()
	for _,v in pairs(ents.FindByClass("puddle_jumper")) do
		if(IsValid(v) and IsValid(v.Owner) and IsValid(self.Owner)) then
			if(v.Owner==self.Owner) then
				if(not(self.Owner:KeyDown(IN_USE))) then
					v:DoKill()
					self.Owner:SelectWeapon( "weapon_crowbar" )
				end
			end
		end
	end
	end);
end

--######### Repair Function & Shield Activation@RononDex
function SWEP:Think()

	if(self.Owner:KeyDown(IN_USE)) then
		/* No Longer Included in The Jumper
		if(self.Owner:KeyDown(IN_ATTACK2)) then
			timer.Simple(self.Delay, function()
				for _,v in pairs(ents.FindByClass("puddle_jumper")) do
					if(v.Owner==self.Owner) then
						if(not(v.Done)) then
							v:Repair()
						end
					end
				end
			end);
		end
		*/
		if(self.Owner:KeyDown(IN_ATTACK)) then
			timer.Simple(self.Delay, function()
				for _,v in pairs(ents.FindByClass("puddle_jumper")) do
					if(v.Owner==self.Owner) then
						v:ToggleShield()
					end
				end
			end);
		end
	end
end
