if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapon")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_shield");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end
SWEP.Author = "DrFattyJr"
SWEP.Purpose = "Shield yourself"
SWEP.Instructions = "Press primary attack to shield yourself and secondary to unshield!"
SWEP.Base = "weapon_base"
SWEP.Slot = 3
SWEP.SlotPos = 5
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/c_arms_animations.mdl"
SWEP.WorldModel = "models/roltzy/w_sodan.mdl"
SWEP.AnimPrefix = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo	= "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

if SERVER then return end

if CLIENT then
	-- Inventory Icon
	if(file.Exists("materials/VGUI/weapons/personal_shield.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/personal_shield");
	end
end

local function PersonalShieldDrawHUD()
	local ply = LocalPlayer()
	if not( ply:IsValid() and ply:GetNetworkedBool("Has.A.pShield", false)) then return end

	local strength = math.Clamp(ply:GetNWFloat("pShieldStrength", 12), 12, 100)
	local a = 150

	if strength < 20 then
		a = 112.5+math.sin(CurTime()*6)*112.5
	end

	draw.RoundedBox(8, ScrW()/8, ScrH()/2-160,20,160, Color(255,0,0,a))
	draw.RoundedBox(8, ScrW()/8, ScrH()/2-1.6*strength,20,1.6*strength, Color(255,255,255,a*1.7))
end

hook.Add("HUDPaint", "PersonalShieldDrawHUD", PersonalShieldDrawHUD)