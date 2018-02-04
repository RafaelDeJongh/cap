if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_lucian_door_opener");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
SWEP.Instructions = SGLanguage.GetMessage("weapon_misc_lucian_door_opener_desc");
end
SWEP.Author = "Gmod4phun / AlexALX"
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);
SWEP.Base = "weapon_base"
SWEP.Slot = 3
SWEP.SlotPos = 3
SWEP.DrawAmmo	= false
SWEP.DrawCrosshair = true
SWEP.UseHands = true
SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/gmod4phun/c_lucian_door_opener.mdl";
SWEP.WorldModel = "models/gmod4phun/lucian_door_opener.mdl";
SWEP.HoldType = "slam"

-- Lol, without this we can't use this weapon in mp on gmod13...
if SERVER then
	AddCSLuaFile();
end

-- primary.
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo	= "none"

-- secondary
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:DelayedAnim(time,anim)
	timer.Simple(time, function() if !self:IsValid() then return end
		self:SendWeaponAnim(anim)
	end)
end

--################### Deploy @aVoN
function SWEP:Deploy()

	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime()+0.8)
	self:SetNextSecondaryFire(CurTime()+0.8)
	self:SetHolsterDelay(0.55)
	self:DelayedAnim(0.5,ACT_VM_IDLE)
	
	return true;
end

function SWEP:SpawnLucian()
	local p = self.Owner;
	
	--p:SelectWeapon("weapon_physgun");
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	
	timer.Simple(0.8, function() if not IsValid(self) then return end
	
		tr = util.TraceLine(util.GetPlayerTrace(p));
		local pos = tr.HitPos;
		local ang = p:GetAimVector():Angle();
		ang.p = 0; ang.r = 0; ang.y = (ang.y+90) % 360;
		
		if(IsValid(tr.Entity))then
	--		 ang = ang + tr.Entity:GetAngles();
	--		 ang.p = 0; ang.r = (ang.r+90) % 360; ang.y = (ang.y+180) % 360;
			ang = tr.HitNormal:Angle();
			ang.p = ang.p+90;
		end

		if(IsValid(tr.Entity) and not tr.Entity:GetClass() == "cap_doors" or tr.StartPos:Distance(pos)>75 or not IsValid(tr.Entity))then
			self:SendWeaponAnim(ACT_VM_IDLE)
			return;
		end
		
		if not SERVER then return end -- damn have you tested this in multiplayer? @ AlexALX
		
		if IsValid(tr.Entity) and tr.Entity.Attached then self:SendWeaponAnim(ACT_VM_IDLE) return end -- dont attach it again
		if IsValid(tr.Entity) and IsValid(tr.Entity.Door) and tr.Entity.Door.Attached then self:SendWeaponAnim(ACT_VM_IDLE) return end -- dont attach it again
		
		if tr.Entity:GetClass() == "cap_doors" and tr.Entity:GetModel() == "models/madman07/doors/dest_door.mdl" then
			local ent = ents.Create("lucian_door_opener");
			ent:SetPos(tr.Entity:LocalToWorld(Vector(0,0,0)))
			ent:SetAngles(tr.Entity:LocalToWorldAngles(Angle(90,0,0)))
			ent:Spawn();
			ent:Activate();
			ent.Owner = p;
			ent:Touch(tr.Entity)
			
			local phys = ent:GetPhysicsObject();
			if IsValid(phys) then
				phys:EnableMotion(true)
			end
			
			--self:Remove()
			
			self.Owner:ConCommand("lastinv")
			self.Owner:StripWeapon(self:GetClass())
			
		elseif tr.Entity:GetClass() == "cap_doors_frame" and tr.Entity:GetModel() == "models/madman07/doors/dest_frame.mdl" then
			if !IsValid(tr.Entity.Door) then return end
			local ent = ents.Create("lucian_door_opener");
			ent:SetPos(tr.Entity.Door:LocalToWorld(Vector(0,0,0)))
			ent:SetAngles(tr.Entity.Door:LocalToWorldAngles(Angle(90,0,0)))
			ent:Spawn();
			ent:Activate();
			ent.Owner = p;
			ent:Touch(tr.Entity.Door)
			
			local phys = ent:GetPhysicsObject();
			if IsValid(phys) then
				phys:EnableMotion(true)
			end
			
			--self:Remove()
			self.Owner:ConCommand("lastinv")
			self.Owner:StripWeapon(self:GetClass())
		
		end
		
	end)

end

--########## Take control of the MALP @RononDex
function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire(CurTime() + (1))
	self:SpawnLucian()

end


--########### Loose control of the MALP @RononDex
function SWEP:SecondaryAttack()

end

--################### Holster @aVoN
function SWEP:SetHolsterDelay(time)
	self.CanHolster = false
	timer.Simple(time, function() if !self:IsValid() then return end
	self.CanHolster = true
	end)
end

function SWEP:Holster(wep)
	if self == wep then
		return
	end
	
	if !self.CanHolster then
		return false
	end
	
	if self.Status == "holster_end" then
		self.Status = "idle"
		return true
	end
	
	if IsValid(wep) and self.Status != "holster_start" then
		CT = CurTime()

		self:SetNextPrimaryFire(CT + (0.75))
		self:SetNextSecondaryFire(CT + (0.75))
		
		self.ChosenWeapon = wep:GetClass()
		
		if self.Status != "holster_end" then
			timer.Simple((0.7), function()
				if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
					self.Status = "holster_end"
					self.Owner:ConCommand("use " .. self.ChosenWeapon)
				end
			end)
		end
		
		self.Status = "holster_start"
		self:SendWeaponAnim(ACT_VM_HOLSTER); -- Animation
		self:SetNextPrimaryFire(CT + (1))
		self:SetNextSecondaryFire(CT + (1))
		--if SERVER then self.Owner:EmitSound(self.Sounds.Holster,90) end
	end

	return false
end