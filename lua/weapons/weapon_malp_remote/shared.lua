if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_malp");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end
SWEP.Author = "RononDex"
SWEP.Purpose = "Control the MALP"
SWEP.Instructions = ""
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);
SWEP.Base = "weapon_base"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

-- Lol, without this we can't use this weapon in mp on gmod13...
if SERVER then
	AddCSLuaFile("shared.lua");
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
--[[
function SWEP:Initialize()

	self.MalpNum = 0
	self:FindMALP()

end

function SWEP:FindMALP()

	for _,v in pairs(ents.FindByClass("malp")) do
		if(IsValid(v)) then
			if(v.Owner==self.Owner) then
				malp = v
				self.MalpNum = self.MalpNum + 1
			end
		end
	end
	return malp
end

function SWEP:Think()

	umsg.Start("MALPSWEPDATA",self.Owner)
		umsg.Short(self.MalpNum)
	umsg.End()
end

--########### Loose control of the MALP @RononDex
function SWEP:SecondaryAttack()

	local malp = self:FindMALP()
	if(IsValid(malp)) then
		if(not(malp.Control)) then
			self.ShouldUseMALPNum = self.ShouldUseMALPNum + 1
		else
			malp:UnControl(self.Owner)
		end
	end
end





function SWEP:PrimaryAttack()

	local malp = self:FindMALP()
	if(IsValid(malp)) then
		if(malp.Control) then
			malp:StartControl(self.Owner)
		end
	end
end
]]--

--########## Take control of the MALP @RononDex
function SWEP:PrimaryAttack()

	for _,v in pairs(ents.FindByClass("malp")) do
		if(IsValid(v)) then
			if(v.Owner==self.Owner) then
				if(not(v.Control)) then
					v:StartControl(self.Owner)
				end
			end
		end
	end
end


--########### Loose control of the MALP @RononDex
function SWEP:SecondaryAttack()

	for _,v in pairs(ents.FindByClass("malp")) do
		if(IsValid(v)) then
			if(v.Owner==self.Owner) then
				if(v.Control) then
					v:UnControl(self.Owner)
				end
			end
		end
	end
end