if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("weapons")) then return end

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	SWEP.PrintName = SGLanguage.GetMessage("weapon_tac");
	SWEP.Category = SGLanguage.GetMessage("weapon_cat");
end
SWEP.Author = "Ronon Dex, Boba Fett";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Throw with Left Click, Change Mode with Right Click";
SWEP.Base = "weapon_base";
SWEP.Slot = 4;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel 		= "models/boba_fett/tac/tac.mdl";
SWEP.WorldModel 	= "models/boba_fett/tac/w_tac.mdl";
SWEP.ViewModelFOV = 60;

SWEP.Primary.ClipSize = 5;
SWEP.Primary.DefaultClip = 3;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo	= "none";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "none";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName or "", SWEP);

if SERVER then

SWEP.CanThrow = true;
SWEP.WepMode = 1;
--self:SetNWInt("Mode",self.WepMode);
SWEP.NextUse = CurTime();
SWEP.Kill = true;
SWEP.Stun = false;
SWEP.Smoke = false;


function SWEP:PrimaryAttack()

	if(IsValid(self)) then
		if(self.CanThrow) then
			self:SendWeaponAnim(ACT_VM_PULLPIN)

			timer.Simple(1,function()
				if(IsValid(self)) then -- Since we're doing this inside a timer we need to make sure we are still valid
					self:SendWeaponAnim(ACT_VM_THROW);

					local tr = util.TraceLine(util.GetPlayerTrace(self.Owner));

					local e = ents.Create("tac_bomb");
					e:SetPos(tr.StartPos+Vector(10,10,10));
					e:SetModel("models/boba_fett/tac/w_tac.mdl");
					e:Spawn();
					e:Activate();

					local p = e:GetPhysicsObject()
					if (IsValid(p)) then
						p:Wake()
						p:AddAngleVelocity(Vector(100,50,200))
						p:SetVelocity(self.Owner:GetAimVector()*Vector(250,250,0));
					end
					e.IsThrownTac = true;
					self.CanThrow = false;
					self.ThrownTac = true;
					self.Tac = e;
					e.Owner = self.Owner;

					if(self.Kill) then
						e.Kill = true;
					elseif(self.Stun) then
						e.Stun = true;
					elseif(self.Smoke) then
						e.Smoke = true;
					end

					timer.Simple(1,function()
						self:SendWeaponAnim(ACT_VM_IDLE) end);
				end
			end);
		else
			if(self.ThrownTac) then
				if(not self.Tac.Smoke) then
					self.Tac:Destroy();
				else
					self.Tac:StartSmoke();
				end
			end
		end
		self:SetNextPrimaryFire(CurTime()+1);

	end
end

--[[
function SWEP:SecondaryAttack()

	if(IsValid(self)) then
		if(self.ThrownTac) then

			self.Tac:Destroy();
			self.CanThrow = true;
			self.ThrownTac = false;
			self.Tac = NULL;

		end
	end
end
]]

SWEP.NextUse = CurTime()
function SWEP:SecondaryAttack()
	local p = self.Owner;
	if (not IsValid(p)) then return end
	if self.NextUse < CurTime() then
		if self.WepMode == 1 then
			self.Kill = false;
			self.Stun = true;
			self.Smoke = false
			self.WepMode = 2;
		elseif(self.WepMode == 2) then
			self.Kill = false;
			self.Stun = false;
			self.Smoke = true;
			self.WepMode = 3;
		elseif(self.WepMode == 3) then
			self.Kill = true;
			self.Stun = false;
			self.Smoke = false;
			self.WepMode = 1;
		end
		self:SetNWInt("Mode",self.WepMode);
		self.NextUse = CurTime() + 1;
	end
end

end

if CLIENT then

function SWEP:DrawHUD()
	local mode = "Kill";
	local int = self:GetNetworkedInt("Mode");
	if int == 1 then
		mode = "Kill";
	elseif int == 2 then
		mode = "Stun";
	elseif int == 3 then
		mode = "Smoke";
	end
	draw.WordBox(8,ScrW()-188,ScrH()-120,"Mode: "..mode,"Default",Color(0,0,0,80),Color(255,220,0,220));
end

end
