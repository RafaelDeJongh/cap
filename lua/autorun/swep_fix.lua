--[[
	SWEP Multiplayer Fix by aVoN
	
	This fixes the Clientside of a SWEP calling SWEP:PrimaryAttack or SWEP:SecondaryAttack multiple times until the server tells the client "Hey stop,
	NextPrimaryFire is in X seconds". This bug happens especially if your ping is higher than 40ms.
	
	And example video is here (Recoil increases MUCH!): 
		VIDEO http://www.youtube.com/watch?v=IWdnU4sR9pc
		COMPLETE EXPLAINATION: http://forums.facepunchstudios.com/showpost.php?p=9492119&postcount=366
		
	Sadly garry does not (want to?) fix it. Well here is the fix. it's licensed under the GPLv3 so do what you want with it <http://www.gnu.org/licenses/>.
--]]
local COMPENSATION = 7; -- Ammount of compensation for Ping. I'm not suggesting to put this at any other value than 7
if SERVER then AddCSLuaFile("autorun/swep_fix.lua") return end;
local meta = FindMetaTable("Weapon");
if not meta then return end;

--################### Backup of the original @aVoN
if not (meta.__SetNextPrimaryFire) then meta.__SetNextPrimaryFire = meta.SetNextPrimaryFire end;
if not (meta.__SetNextSecondaryFire) then meta.__SetNextSecondaryFire = meta.SetNextSecondaryFire end;
--################### The actual fix @aVoN
local function PrimaryAttack(self,...)
	if(self.__PrimaryAttack and (self.__NextPrimaryAttack or 0) < CurTime()) then
		return self:__PrimaryAttack(...) 
	end;
end
local function SecondaryAttack(self,...)
	if(self.__SecondaryAttack and (self.__NextSecondaryAttack or 0) < CurTime()) then return self:__SecondaryAttack(...) end;
end

--################### Overwrite SWEP:SetNextPrimaryFire to compensate lag @aVoN
function meta:SetNextPrimaryFire(delay)
	self:__SetNextPrimaryFire(delay); -- Even if this does not seem have an effect, I do not want to destroy scripts which are relying on this
	if(IsValid(self.Owner) and self.Owner:IsPlayer()) then
		local time = CurTime();
		-- The Clientside fixed "NextPrimaryAttack" - First we wait until the server should have told the client when he can shoot again. Then we use GMod's internals
		local delay = (delay or time) - time; -- SWEP's delay
		-- If the ping is greater than the delay, we add some extra compensation
		if((self.Owner:Ping() + COMPENSATION)/1000 > delay) then delay = delay + COMPENSATION/1000 end;
		self.__NextPrimaryAttack = delay + time;
		if(self.PrimaryAttack and not self.__PrimaryAttack) then
			self.__PrimaryAttack = self.PrimaryAttack; -- Store old
			self.PrimaryAttack = PrimaryAttack; -- Overwrite with fixed one
		end
	end
end

--################### Overwrite SWEP:SetNextSecondaryFire to compensate lag @aVoN
function meta:SetNextSecondaryFire(delay)
	self:__SetNextSecondaryFire(delay); -- Even if this does not seem have an effect, I do not want to destroy scripts which are relying on this
	if(IsValid(self.Owner) and self.Owner:IsPlayer()) then
		local time = CurTime();
		-- The Clientside fixed "NextSecondaryAttack" - First we wait until the server should have told the client when he can shoot again. Then we use GMod's internals
		local delay = (delay or time) - time; -- SWEP's delay
		-- If the ping is greater than the delay, we add some extra compensation
		if((self.Owner:Ping() + COMPENSATION)/1000 > delay) then delay = delay + COMPENSATION/1000 end;
		self.__NextSecondaryAttack = delay + time;
		if(self.SecondaryAttack and not self.__SecondaryAttack) then
			self.__SecondaryAttack = self.SecondaryAttack; -- Store old
			self.SecondaryAttack = SecondaryAttack; -- Overwrite with fixed one
		end
	end
end
