if (not StarGate.CheckModule("weapon")) then return end

local HitImpact = function(attacker, tr, dmginfo)

	local hit = EffectData()
	hit:SetOrigin(tr.HitPos)
	hit:SetNormal(tr.HitNormal)
	hit:SetScale(20)
	util.Effect("effect_hit", hit)

	return true
end

if SERVER then

	SWEP.Weight 		= 5
	SWEP.AutoSwitchTo 		= false					-- Dont automatically switch to this weapon
	SWEP.AutoSwitchFrom 		= false				-- Dont automatically swith from this weapon to another weapon..

	function SWEP:UnDrawModel()

		self.Owner:DrawViewModel(false)
	end

	function SWEP:ReDrawModel()

		self.Owner:DrawViewModel(true)
	end
	AddCSLuaFile("shared.lua")

end

SWEP.PrintName = Language.GetMessage("weapon_p90");

if CLIENT then
	SWEP.Slot 			= 2
	SWEP.SlotPos 		= 1
	SWEP.IconLetter 		= "m"

	SWEP.DrawAmmo		= true
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 73			-- Y position of the weapon
	SWEP.ViewModelFlip	= true		-- Flippetty dippety the model
	SWEP.CSMuzzleFlashes	= true		-- Default CS:S Muzzle Flash, gotta love it alright..

	local font = {
		font = "HalfLife2",
		size = ScrW() / 60,
		weight = 500,
		antialias = true,
		additive = true,
	}
	surface.CreateFont("Firemode", font);		-- Lovely firing mode font

end

/*---------------------------------------------------------
Muzzle Effect - Perhaps in a later rev
---------------------------------------------------------
SWEP.MuzzleEffect			= "rg_muzzle_hmg" -- This is an extra muzzleflash effect
 --Available muzzle effects: rg_muzzle_grenade, rg_muzzle_highcal, rg_muzzle_hmg, rg_muzzle_pistol, rg_muzzle_rifle, rg_muzzle_silenced, none

SWEP.MuzzleAttachment		= "1" -- Should be "1" for CSS models or "muzzle" for hl2 models
*/


SWEP.Category = Language.GetMessage("weapon_cat");

SWEP.DrawWeaponInfoBox  	= true					-- Draw Weapon Info HUD

SWEP.Author 			= "The Art of War, Boba Fett"
SWEP.Contact 			= "info@sg-carterpack.com"
SWEP.Purpose 			= "Shoot them aliens up."

SWEP.Instructions 		= "Left click to fire. Right click to aim through the Red Dot Sight. Use + Right Click to change firing mode"

list.Set("CAP.Weapon", SWEP.PrintName, SWEP);
list.Add("NPCUsableWeapons", {class = "fnp90", title = SWEP.PrintName});

SWEP.ViewModel 			= "models/Boba_Fett/P90/v_smg_p90.mdl"				-- V model
SWEP.WorldModel 			= "models/Boba_Fett/P90/w_smg_p90.mdl"			-- W model

-- self.LaserEx = false

SWEP.FiresUnderwater = true

SWEP.Primary.Sound 		= Sound("weapons/p90/p90-1.wav")				-- P90 Firing sound
SWEP.Primary.Recoil 		= 0.275				-- Weapon recoil
SWEP.Primary.Damage 		= 20			    -- Weapon Damage
SWEP.Primary.NumShots 		= 1					-- Number of bullets fired
SWEP.Primary.Cone 		= 0.0135 				-- Bullet spread
SWEP.Primary.ClipSize 		= 50				-- Weapon maxclip size
SWEP.Primary.Delay 		= 0.066					-- Rate of fire
SWEP.Primary.DefaultClip 	= 300					-- Default ammo
SWEP.Primary.Automatic 		= true				-- Weapon is automatic
SWEP.Primary.Ammo 		= "pistol"				-- Weapon uses smg1 ammo

SWEP.Secondary.ClipSize 	= -1				-- No secondary attack
SWEP.Secondary.DefaultClip 	= -1				-- - snip -
SWEP.Secondary.Automatic 	= false				-- - snip -
SWEP.Secondary.Ammo 		= "none"			-- - snip -

SWEP.data 				= {}
SWEP.mode 				= "auto" 					-- Default firing mode
SWEP.data.ironsights		= 1

SWEP.data.semi 			= {}				-- Semi-automatic firing mode
SWEP.data.semi.FireMode		= "p"

SWEP.data.auto 			= {}				-- Automatic firing mode
SWEP.data.auto.FireMode		= "ppppp"

function SWEP.data.semi.Init(self)

	self.Primary.Automatic = false
	self.Weapon:EmitSound("weapons/smg1/switch_single.wav")
	self.Weapon:SetNetworkedInt("firemode", 3)
end

function SWEP.data.auto.Init(self)

	self.Primary.Automatic = true
	self.Weapon:EmitSound("weapons/smg1/switch_burst.wav")
	self.Weapon:SetNetworkedInt("firemode", 1)
end

---------------------------
-- Red Dot Sight --
---------------------------


SWEP.IronSightsPos 			= Vector (4.5658, -10.4639, 2.0097)
SWEP.IronSightsAng 			= Vector (0, 0, 0)
SWEP.IronSightZoom			= 1.2
SWEP.UseScope				= true -- Use a sight instead of ironsights.
SWEP.ScopeScale 				= 0.4 -- The scale of the scope's reticle in relation to the player's screen size.
SWEP.ScopeZooms				= {2} -- The possible magnification levels of the sight.
SWEP.DrawParabolicSights		= false -- N0p

function SWEP:ResetVars()

	self.NextSecondaryAttack = 0

	self.bLastIron = false
	self.Weapon:SetNetworkedBool("Ironsights", false)

	if self.UseScope then
		self.CurScopeZoom = 1
		self.fLastScopeZoom = 1
		self.bLastScope = false
		self.Weapon:SetNetworkedBool("Scope", false)
		self.Weapon:SetNetworkedBool("ScopeZoom", self.ScopeZooms[1])
	end

	if self.Owner then
		self.OwnerIsNPC = self.Owner:IsNPC() -- This ought to be better than getting it every time we fire
	end

end

-- We need to call ResetVars() on these functions so we don't whip out a weapon with scope mode or insane recoil right of the bat or whatnot
function SWEP:Holster(wep) 		self:ResetVars() return true end
function SWEP:Equip(NewOwner) 	self:ResetVars() return true end
function SWEP:OnRemove() 		self:ResetVars() return true end
function SWEP:OnDrop() 			self:ResetVars() return true end
function SWEP:OwnerChanged() 	self:ResetVars() return true end
function SWEP:OnRestore() 		self:ResetVars() return true end


function SWEP:IronSight()

	if ( !self.Owner:IsPlayer() ) then return end

	if !self.Owner:KeyDown(IN_USE) then
	-- If the key E (Use Key) is not pressed, then

		if self.Owner:KeyPressed(IN_ATTACK2) then
		-- When the right click is pressed, then

			self:SetIronsights(true, self.Owner)

			if CLIENT then return end
 		end
	end

	if !self.Owner:KeyDown(IN_ATTACK2) then
	-- If the right click is released, then

		self:SetIronsights(false, self.Owner)

		if CLIENT then return end
	end
end

function SWEP:Think()

	if CLIENT then

		if self.Weapon:GetNetworkedBool("Scope") then
			self.MouseSensitivity = self.Owner:GetFOV() / 60 -- scale sensitivity
			self.Owner.Crosshair = false
		else
			self.Owner.Crosshair = true
			self.MouseSensitivity = 1
		end
	end

	self:IronSight()
end

/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/

local sndZoomIn = Sound("Weapon_AR2.Special1")
local sndZoomOut = Sound("Weapon_AR2.Special2")

function SWEP:Initialize()

	if SERVER then self:SetWeaponHoldType("ar2") end	-- Hold type of the 3rd person animation

	if CLIENT then
		/* local ply = LocalPlayer()
		self.VM = ply:GetViewModel()
		local attachmentIndex = self.VM:LookupAttachment("LaserEx")
		if attachmentIndex == 0 then attachmentIndex = self.VM:LookupAttachment("1") end
		self.Attach = attachmentIndex */

		-- We need to get these so we can scale everything to the player's current resolution.
		local iScreenWidth = surface.ScreenWidth()
		local iScreenHeight = surface.ScreenHeight()

		-- These tables are used to draw things like scopes and crosshairs to the HUD.
		self.ScopeTable = {}
		self.ScopeTable.l = iScreenHeight*self.ScopeScale
		self.ScopeTable.x1 = 0.5*(iScreenWidth + self.ScopeTable.l)
		self.ScopeTable.y1 = 0.5*(iScreenHeight - self.ScopeTable.l)
		self.ScopeTable.x2 = self.ScopeTable.x1
		self.ScopeTable.y2 = 0.5*(iScreenHeight + self.ScopeTable.l)
		self.ScopeTable.x3 = 0.5*(iScreenWidth - self.ScopeTable.l)
		self.ScopeTable.y3 = self.ScopeTable.y2
		self.ScopeTable.x4 = self.ScopeTable.x3
		self.ScopeTable.y4 = self.ScopeTable.y1

		self.ParaScopeTable = {}
		self.ParaScopeTable.x = 0.5*iScreenWidth - self.ScopeTable.l
		self.ParaScopeTable.y = 0.5*iScreenHeight - self.ScopeTable.l
		self.ParaScopeTable.w = 2*self.ScopeTable.l
		self.ParaScopeTable.h = 2*self.ScopeTable.l

		self.ScopeTable.l = (iScreenHeight + 1)*self.ScopeScale -- I don't know why this works, but it does.

		self.QuadTable = {}
		self.QuadTable.x1 = 0
		self.QuadTable.y1 = 0
		self.QuadTable.w1 = iScreenWidth
		self.QuadTable.h1 = 0.5*iScreenHeight - self.ScopeTable.l
		self.QuadTable.x2 = 0
		self.QuadTable.y2 = 0.5*iScreenHeight + self.ScopeTable.l
		self.QuadTable.w2 = self.QuadTable.w1
		self.QuadTable.h2 = self.QuadTable.h1
		self.QuadTable.x3 = 0
		self.QuadTable.y3 = 0
		self.QuadTable.w3 = 0.5*iScreenWidth - self.ScopeTable.l
		self.QuadTable.h3 = iScreenHeight
		self.QuadTable.x4 = 0.5*iScreenWidth + self.ScopeTable.l
		self.QuadTable.y4 = 0
		self.QuadTable.w4 = self.QuadTable.w3
		self.QuadTable.h4 = self.QuadTable.h3

		self.LensTable = {}
		self.LensTable.x = self.QuadTable.w3
		self.LensTable.y = self.QuadTable.h1
		self.LensTable.w = 2*self.ScopeTable.l
		self.LensTable.h = 2*self.ScopeTable.l

		self.CrossHairTable = {}
		self.CrossHairTable.x11 = 0
		self.CrossHairTable.y11 = 0.5*iScreenHeight
		self.CrossHairTable.x12 = iScreenWidth
		self.CrossHairTable.y12 = self.CrossHairTable.y11
		self.CrossHairTable.x21 = 0.5*iScreenWidth
		self.CrossHairTable.y21 = 0
		self.CrossHairTable.x22 = 0.5*iScreenWidth
		self.CrossHairTable.y22 = iScreenHeight
	end

	self.ScopeZooms 		= self.ScopeZooms or {5}
	if self.UseScope then
		self.CurScopeZoom	= 1 -- Another index, this time for ScopeZooms
	end

	self.NextSecondaryAttack = CurTime() + 0.3
	self:ResetVars()
	self.Weapon:SetNetworkedBool("Ironsights", false)

	self.data[self.mode].Init(self)
end

if CLIENT then
	if(file.Exists("materials/VGUI/weapons/P90_inventory.vmt","GAME")) then
		SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/P90_inventory.vmt")
	end
end
/*---------------------------------------------------------
Sensibility
---------------------------------------------------------*/
local LastViewAng = false

local function SimilarizeAngles (ang1, ang2)

	ang1.y = math.fmod (ang1.y, 360)
	ang2.y = math.fmod (ang2.y, 360)

	if math.abs (ang1.y - ang2.y) > 180 then
		if ang1.y - ang2.y < 0 then
			ang1.y = ang1.y + 360
		else
			ang1.y = ang1.y - 360
		end
	end
end

local function ReduceScopeSensitivity (uCmd)

	if LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():IsValid() then
		local newAng = uCmd:GetViewAngles()
			if LastViewAng then
				SimilarizeAngles (LastViewAng, newAng)

				local diff = newAng - LastViewAng

				diff = diff * (LocalPlayer():GetActiveWeapon().MouseSensitivity or 1)
				uCmd:SetViewAngles (LastViewAng + diff)
			end
	end
	LastViewAng = uCmd:GetViewAngles()
end

hook.Add ("CreateMove", "RSS", ReduceScopeSensitivity)

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()

	if ( self.Reloadaftershoot > CurTime() ) then return end

	self.Weapon:DefaultReload( ACT_VM_RELOAD )

	if ( self.Weapon:Clip1() < self.Primary.ClipSize ) and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self:SetIronsights(false, self.Owner)

		self:SetScope(false, self.Owner)

		self.MouseSensitivity = 1

		if not CLIENT then
			self.Owner:DrawViewModel(true)
		end
	end

	return true
end

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW ) -- Anims

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)

	self:SetIronsights(false, self.Owner) -- Remove sight

	self.Reloadaftershoot = CurTime() + 1 -- Reload delay after deploy...
	return true
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

		/* if ( self.Owner:KeyDown(IN_USE) ) then
			self.Weapon:SetNetworkedBool("Active", self.Weapon.LaserEx)
			if ( !self.Weapon:GetNetworkedBool("Active") ) then
				Wire_TriggerOutput(self.Weapon,"Active",1)
			else
				Wire_TriggerOutput(self.Weapon,"Active",0)
			end
		self.Weapon:EmitSound("weapons/smg1/switch_single.wav")
		return end */

	if ( self.Weapon:Clip1() == 0 ) then
		self:Reload()
	end

	if not self:CanPrimaryAttack() then return end

	self.Reloadaftershoot = CurTime() + self.Primary.Delay

	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	-- Set next secondary fire after firing delay

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	-- Set next primary fire after firing delay

	self.Weapon:EmitSound(self.Primary.Sound)

	self:RecoilPower()

	self:TakePrimaryAmmo(1)

	if ((game.SinglePlayer() and SERVER) or SERVER) then
	self.Weapon:SetNetworkedFloat("LastShootTime", CurTime())
	end
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	if self.NextSecondaryAttack > CurTime() or self.OwnerIsNPC then return end
	self.NextSecondaryAttack = CurTime() + 0.3

	if self.Owner:KeyDown(IN_USE) then
		if self.mode == "auto" then
			self.mode = "semi"
			self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
		elseif self.mode == "semi" then
			self.mode = "auto"
		end
		self.data[self.mode].Init(self)

		if self.mode == "auto" then
			self.Weapon:SetNetworkedInt("csef",1)
		elseif self.mode == "semi" then
			self.Weapon:SetNetworkedInt("csef",3)
		end

	elseif self.IronSightsPos then

		local NumberOfScopeZooms = table.getn(self.ScopeZooms)

		if self.UseScope and self.Weapon:GetNetworkedBool("Scope", false) then

			self.CurScopeZoom = self.CurScopeZoom + 1
			if self.CurScopeZoom <= NumberOfScopeZooms then
				self:SetIronsights(false,self.Owner)
			end

		else

			local bIronsights = not self.Weapon:GetNetworkedBool("Ironsights", false)
			self:SetIronsights(bIronsights,self.Owner)

		end
	end
end
function SWEP:CanPrimaryAttack()

	if ( self.Weapon:Clip1() <= 0 ) and self.Primary.ClipSize > -1 then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		self.Weapon:EmitSound("weapons/p90/clipempty_pistol.wav")
		return false
	end
	return true
end

SWEP.CrossHairScale = 1

function SWEP:DrawHUD()

	local mode = self.Weapon:GetNetworkedInt("firemode")

	if mode == 1 then
		self.mode = "auto"
	elseif mode == 3 then
		self.mode = "semi"
	else
		self.mode = "auto"
	end

	surface.SetFont("Firemode")
	surface.SetTextPos(surface.ScreenWidth() * .9225, surface.ScreenHeight() * .9125)
	surface.SetTextColor(255,220,0,100)

	surface.DrawText(self.data[self.mode].FireMode)

	if ( CLIENT) then

		local iScreenWidth = surface.ScreenWidth()
		local iScreenHeight = surface.ScreenHeight()

		local SCOPEFADE_TIME = 0.4

		if self.UseScope then

			local bScope = self.Weapon:GetNetworkedBool("Scope")
			if bScope ~= self.bLastScope then

				self.bLastScope = bScope
				self.fScopeTime = CurTime()

			elseif 	bScope then

				local fScopeZoom = self.Weapon:GetNetworkedFloat("ScopeZoom")
				if fScopeZoom ~= self.fLastScopeZoom then

					self.fLastScopeZoom = fScopeZoom
					self.fScopeTime = CurTime()
				end
			end

			local fScopeTime = self.fScopeTime or 0

			if fScopeTime > CurTime() - SCOPEFADE_TIME then

				local Mul = 1.0
				Mul = 1 - math.Clamp((CurTime() - fScopeTime)/SCOPEFADE_TIME, 0, 1)

				surface.SetDrawColor(0, 0, 0, 255*Mul)
				surface.DrawRect(0,0,iScreenWidth,iScreenHeight)
			end

			if bScope then

				surface.SetDrawColor(0,0,0,255)
				surface.SetTexture(surface.GetTextureID("Boba_Fett/P90/scope.vmt"))
				surface.DrawTexturedRect(self.LensTable.x, self.LensTable.y, self.LensTable.w, self.LensTable.h)

				surface.SetDrawColor(0,0,0,255)
				surface.DrawRect(self.QuadTable.x1 - 2.5, self.QuadTable.y1 - 2.5, self.QuadTable.w1 + 5, self.QuadTable.h1 + 5)
				surface.DrawRect(self.QuadTable.x2 - 2.5, self.QuadTable.y2 - 2.5, self.QuadTable.w2 + 5, self.QuadTable.h2 + 5)
				surface.DrawRect(self.QuadTable.x3 - 2.5, self.QuadTable.y3 - 2.5, self.QuadTable.w3 + 5, self.QuadTable.h3 + 5)
				surface.DrawRect(self.QuadTable.x4 - 2.5, self.QuadTable.y4 - 2.5, self.QuadTable.w4 + 5, self.QuadTable.h4 + 5)
			end
		end
		local mode = self.Weapon:GetNetworkedInt("firemode")

		if mode == 1 then
			self.mode = "auto"
		elseif mode == 3 then
			self.mode = "semi"
		else
			self.mode = "semi"
		end
		surface.SetFont("Firemode")
		surface.SetTextPos(surface.ScreenWidth() * .9225, surface.ScreenHeight() * .9125)
		surface.SetTextColor(255,220,0,100)

		surface.DrawText(self.data[self.mode].FireMode)
	end
	// No crosshair when ironsights is on
	if ( !self.Owner.Crosshair ) then return end

	local x, y

	// If we're drawing the local player, draw the crosshair where theyre aiming,
	// instead of in the center of the screen.
	if ( self.Owner == LocalPlayer() && self.Owner:ShouldDrawLocalPlayer() ) then

	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )

	local coords = trace.HitPos:ToScreen()
	x, y = coords.x, coords.y

	else
		x, y = ScrW() / 2.0, ScrH() / 2.0
	end

	local scale = 10 * self.Primary.Cone

	// Scale the size of the crosshair according to how long ago we fired our weapon
	local LastShootTime = self.Weapon:GetNetworkedFloat( "LastShootTime", 0 )
	scale = scale * (2 - math.Clamp( (CurTime() - LastShootTime) * 5, 0.0, 1.0 ))

	surface.SetDrawColor( 0, 255, 0, 255 )

	// Draw an awesome crosshair
	local gap = 40 * scale
	local length = gap + 20 * scale
	surface.DrawLine( x - length, y, x - gap, y )
	surface.DrawLine( x + length, y, x + gap, y )
	surface.DrawLine( x, y - length, x, y - gap )
	surface.DrawLine( x, y + length, x, y + gap )
end

function SWEP:TranslateFOV(current_fov)

	if CLIENT then

		local fScopeZoom = self.Weapon:GetNetworkedFloat("ScopeZoom")
		if self.Weapon:GetNetworkedBool("Scope") then return current_fov/fScopeZoom end

		local bIron = self.Weapon:GetNetworkedBool("Ironsights")
		if bIron ~= self.bLastIron then

			self.bLastIron = bIron
			self.fIronTime = CurTime()
		end

		local fIronTime = self.fIronTime or 0

		if not bIron and (fIronTime < CurTime() - IRONSIGHT_TIME) then
			return current_fov
		end

		local Mul = 1.0

		if fIronTime > CurTime() - IRONSIGHT_TIME then

			Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)
			if not bIron then Mul = 1 - Mul end

		end

		current_fov = current_fov*(1 + Mul/self.IronSightZoom - Mul)

		return current_fov
	end
end

IRONSIGHT_TIME = 0.15

function SWEP:GetViewModelPosition(pos, ang)

	if (not self.IronSightsPos) then return pos, ang end

	local bIron = self.Weapon:GetNetworkedBool("Ironsights")

	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()

		-- if ( !bIron ) then
		--	self.SwayScale 	= 0.7
		--	self.BobScale 	= 0.7
	    -- end
	end

	local fIronTime = self.fIronTime or 0

	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end

	local Mul = 1.0

	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end

	local Offset = self.IronSightsPos

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end

function SWEP:GetIronsights()

	return self.Weapon:GetNWBool("Ironsights")
end

function SWEP:SetIronsights(b, player)

if CLIENT then return end

	-- Send the ironsight state to the client, so it can adjust the player's FOV/Viewmodel pos accordingly
	self.Weapon:SetNetworkedBool("Ironsights", b)

	if self.UseScope then -- If we have a scope, use it instead of ironsights
		if b then
			timer.Simple(IRONSIGHT_TIME, function() self:SetScope(true, player) end)
		else
			self:SetScope(false, player)

		end
	end
end

function SWEP:SetScope(b, player)

if CLIENT then return end

	local PlaySound = b ~= self.Weapon:GetNetworkedBool("Scope", not b)
	self.CurScopeZoom = 1
	self.Weapon:SetNetworkedFloat("ScopeZoom", self.ScopeZooms[self.CurScopeZoom])

	if b then
		if PlaySound then
			self.Weapon:EmitSound(sndZoomIn)

			self:UnDrawModel()
		end
	else
		if PlaySound then
			self.Weapon:EmitSound(sndZoomOut)

			self:ReDrawModel()
		end
	end

	-- Send the scope state to the client, so it can adjust the player's fov/HUD accordingly
	self.Weapon:SetNetworkedBool("Scope", b)
end

function SWEP:RecoilPower()
	if (not IsValid(self.Owner) or not self.Owner:IsPlayer()) then return end
	if not self.Owner:IsOnGround() then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil * 1.7, self.Primary.NumShots, self.Primary.Cone)

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil * 1.7), math.Rand(-1,1) * (self.Primary.Recoil / 1.7), 0))
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)
			-- Recoil * 2.5

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil * 2.5), math.Rand(-1,1) * (self.Primary.Recoil * 2.5), 0))
			-- Punch the screen * 2.5
		end

	elseif self.Owner:IsPlayer() and self.Owner:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 1.5, self.Primary.NumShots, self.Primary.Cone)
			-- Recoil split by 2 while in the red dot sight

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil / 1.5), math.Rand(-1,1) * (self.Primary.Recoil / 5), 0))
			-- Punch the screen 1.5x less while aiming through the red dot sight
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone)

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * self.Primary.Recoil, math.Rand(-1,1) * (self.Primary.Recoil * 1.5), 0))
		end

	elseif self.Owner:IsPlayer() and self.Owner:Crouching() then
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 4, self.Primary.NumShots, self.Primary.Cone)
			-- Put lesser recoil while aiming through teh red dot sight

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil / 4), math.Rand(-1,1) * (self.Primary.Recoil / 10), 0))
			-- Punch the screen 4 times less while aiming through the red dot sight
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 3.0, self.Primary.NumShots, self.Primary.Cone)
			-- Recoil / 3

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil / 3), math.Rand(-1,1) * (self.Primary.Recoil / 2), 0))
			-- Screenpunch / 3
		end
	else
		if (self:GetIronsights() == true) then
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 3.5, self.Primary.NumShots, self.Primary.Cone)
			-- Put recoil / 4 when you're in ironsight mod

			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil / 3.5), math.Rand(-1,1) * (self.Primary.Recoil / 6), 0))
			-- Punch the screen 6x less hard when you're in ironsight mod
		else
			self:CSShootBullet(self.Primary.Damage, self.Primary.Recoil / 2.5, self.Primary.NumShots, self.Primary.Cone)
			-- Put normal recoil when you're not in ironsight mod

			if (self.Owner:IsPlayer()) then
				self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * self.Primary.Recoil / 2.5, math.Rand(-1,1) *self.Primary.Recoil, 0))
			end
			-- Punch the screen
		end
	end
end

/*---------------------------------------------------------
ShootBullet
---------------------------------------------------------*/
function SWEP:CSShootBullet(dmg, recoil, numbul, cone)

	numbul 		= numbul or 1
	cone 			= cone or 0.01

	local bullet 	= {}
	bullet.Num  	= numbul
	bullet.Src 		= self.Owner:GetShootPos()       					-- Bullet Source (start pos)
	bullet.Dir 		= self.Owner:GetAimVector()      					-- Vector/direction of the bullet
	bullet.Spread 	= Vector(cone, cone, 0)     						-- Bullet Spread
	bullet.Tracer 	= 1       									-- Tracers per bullet
	bullet.Force 	= 0.65 * dmg     								-- Amount of force to apply to physical objects.
	bullet.Damage 	= dmg										-- Amount of bullet damage
	bullet.Callback 	= HitImpact
 	-- bullet.Callback	= function ( a, b, c ) BulletPenetration( 0, a, b, c ) end


	self.Owner:FireBullets(bullet)					-- Fire the round

	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)   	-- View model animation

	self.Owner:MuzzleFlash()        					-- Default Muzzle flash

	self.Owner:SetAnimation(PLAYER_ATTACK1)       			-- World animation (3rd person)


	if ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT)) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		if (self.Owner:IsPlayer()) then
			self.Owner:SetEyeAngles(eyeang)
		end
	end
end
-- This should be recoded to use real entity bullets, for later then..
/* function BulletPenetration( hitNum, attacker, tr, dmginfo )

 	local DoDefaultEffect = true;
 	if ( !tr.HitWorld ) then DoDefaultEffect = true end
	if ( tr.HitWorld or tr.Entity:IsPlayer() or tr.Entity:IsNPC() ) then return end

 	if ( CLIENT ) then return end
 	if ( hitNum > 6 ) then return end

 	local bullet =
 	{
 		Num 		= 1,
 		Src 		= tr.HitPos + attacker:GetAimVector() * 4,
 		Dir 		= attacker:GetAimVector(),
 		Spread 	= Vector( 0.005, 0.005, 0 ),
 		Tracer	= 1,
 		TracerName 	= "effect_trace_bulletpenetration",
 		Force		= 0,
 		Damage	= 15,
 		AmmoType 	= "smg1"
 	}

	if (SERVER) then
 		bullet.Callback    = function( a, b, c ) BulletPenetration( hitNum + 1, a, b, c ) end
 	end
 	timer.Simple( 0.01 * hitNum, function() attacker:FireBullets(bullet) end )
 	return { damage = true, effects = DoDefaultEffect }
end */