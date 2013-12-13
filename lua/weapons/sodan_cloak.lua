/*
	Sodan Cloaking Device for GarrysMod10
	Copyright (C) 2007  Catdaemon

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
SWEP.PrintName = SGLanguage.GetMessage("weapon_misc_sodan");
SWEP.Category = SGLanguage.GetMessage("weapon_misc_cat");
end
SWEP.Author = "Catdaemon"; -- And a slight modification by me (aVoN) - But it's still his code so I haven't added myself to it. Lua comment is sufficient :)
SWEP.Purpose = "Cloak yourself";
SWEP.Instructions = "Press primaryattack to cloak yourself and secondary to uncloak!";
SWEP.Base = "weapon_base";
SWEP.Slot = 3;
SWEP.SlotPos = 4;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/weapons/c_arms_animations.mdl";
SWEP.WorldModel = "models/roltzy/w_sodan.mdl";
SWEP.AnimPrefix = "melee";

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "none";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo = "none";

-- spawnables.
list.Set("CAP.Weapon", SWEP.PrintName, SWEP);

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile();

SWEP.Sounds = {Engage=Sound("tech/sodan_cloak_on.mp3"),Disengage=Sound("tech/sodan_cloak_off.mp3")};

--################### Set Holdtype @aVoN
function SWEP:Initialize()
	self:SetWeaponHoldType("melee");
end

--################### Primary Attack @Catdaemon
function SWEP:PrimaryAttack()
	if(not self.Owner:GetNetworkedBool("pCloaked",false)) then
		self.Owner:SetNetworkedBool("pCloaked",true);
		self.Owner:SetNoTarget(true);
		self.Owner:EmitSound(self.Sounds.Engage,90,math.random(97,103));
		self:DoCloakEffect();
		self.Weapon:SetNextSecondaryFire(CurTime()+0.8);
	end
	return true;
end

--################### Secondary Attack @Catdaemon
function SWEP:SecondaryAttack()
	if(self.Owner:GetNWBool("pCloaked",false)) then
		self.Owner:SetNWBool("pCloaked",false);
		self.Owner:SetNoTarget(false);
		self.Owner:EmitSound(self.Sounds.Disengage,90,math.random(97,103));
		self:DoCloakEffect();
		self.Weapon:SetNextPrimaryFire(CurTime()+0.8);
	end
	return true;
end

--################### Does the cloaking effect @aVoN
function SWEP:DoCloakEffect()
	local fx = EffectData();
	fx:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*10);
	fx:SetEntity(self.Owner);
	util.Effect("sodan_cloak",fx,true,true);
end

--################### Removes a bit health "due to the radiation" the cloak emits to get away phaseshifted insects,worms etc (which are the EVIL himself) @aVoN
-- No seriously, I added this so a person can't be cloaked infinite - http://mantis.39051.vs.webtropia.com/view.php?id=148
timer.Create("StarGate.SodanCloaking.DamagePlayerOverTime",1,0,
	function()
		for _,v in pairs(player.GetAll()) do
			if(IsValid(v) and v:GetNWBool("pCloaked",false)) then
				v.__Sodan = v.__Sodan or {};
				local t = v.__Sodan; -- Shorter code
				t.RandomHealthLossDelay = t.RandomHealthLossDelay or math.random(7,20);
				t.Activated = t.Activated or CurTime();
				if(t.Activated + t.RandomHealthLossDelay <= CurTime()) then
					v:TakeDamage(math.random(1,5),v,v);
					local hp = v:Health();
					if(hp > 0 and hp < 20) then
						v:SendLua("surface.PlaySound('hl1/fvox/radiation_detected.wav')");
					end
					-- For the next turn
					t.Activated = CurTime();
					t.RandomHealthLossDelay = math.random(7,20);
				end
			end
		end
	end
);

--################### PlayerDeath @aVoN
hook.Add("PlayerDeath","StarGate.SodanCloaking.PlayerDeath",
	function(p)
		if(IsValid(p)) then
			p:SetNWBool("pCloaked",false);
			timer.Simple(0.1,function()
				if (IsValid(p)) then
					p:SetNWBool("pCloaked",nil);
				end
			end)
			p:SetNoTarget(false);
		end
	end
);

end

if CLIENT then

-- Inventory Icon @aVoN
if(file.Exists("materials/VGUI/weapons/cloak_inventory.vmt","GAME")) then
	SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/cloak_inventory");
end

--################### Think @Catdaemon
-- code moved to arthur_mantle
/*
hook.Add("Think","StarGate.SodanCloaking.Think",
	function()
		local cloaked_self = LocalPlayer():GetNetworkedBool("pCloaked",false);
		for _,p in pairs(player.GetAll()) do
			local cloaked = p:GetNetworkedBool("pCloaked",NULL); -- If a player hasn't cloaked himself yet, we do not want to override color at all (It conflicted on my server
			if(cloaked ~= NULL) then
				local weapon = p:GetActiveWeapon();
				local color = p:GetColor();
				local r,g,b,a = color.r,color.g,color.b,color.a;
				if(cloaked_self) then
					if(cloaked) then a = 255 end;
				else
					if(cloaked) then
						/*if (p.__HasBeenCloaked==nil or p.__HasBeenCloaked==false) then
							if (p.__SGCloakMaterial and p.__SGCloakMaterial!="models/effects/vol_light001") then
								p.__SGCloakMaterial = p:GetMaterial();
							end
							p:SetMaterial("models/effects/vol_light001");
						end*
						a = 0;
						p.__HasBeenCloaked = true;
					elseif(a == 0 and p.__HasBeenCloaked) then -- If he is uncloaked but still at 0 alpha, make him visible back again (Failsafe) - But do this only, if WE have cloaked him
						a = 255;
						p.__HasBeenCloaked = false;
						--if (p.__SGCloakMaterial!=nil) then if (p.__SGCloakMaterial=="models/effects/vol_light001") then p:SetMaterial(""); else p:SetMaterial(p.__SGCloakMaterial); end end
					end
				end
				p:SetRenderMode( RENDERMODE_TRANSALPHA )
				p:SetColor(Color(r,g,b,a)); -- Cloak, lol
				if(IsValid(weapon)) then
					weapon:SetRenderMode( RENDERMODE_TRANSALPHA )
					weapon:SetColor(Color(255,255,255,a)); -- Cloak his weapon too
				end
			end
		end
	end
); */

--################### Color override @Catdaemon
local BlurEdges = Material("bluredges");
hook.Add("RenderScreenspaceEffects","StarGate.SodanCloaking.RenderScreenspaceEffects",
	function()
		if(LocalPlayer():GetNWBool("pCloaked",false)) then
			-- Color Modify - The "Bluish" overlay
			DrawColorModify(
				{
					["$pp_colour_addr"] = 0,
					["$pp_colour_addg"] = 0.56,
					["$pp_colour_addb"] = 0.96,
					["$pp_colour_brightness"] = -0.6,
					["$pp_colour_contrast"] = 0.93,
					["$pp_colour_colour"] = 0.19,
					["$pp_colour_mulr"] = 0,
					["$pp_colour_mulg"] = 0,
					["$pp_colour_mulb"] = 0,
				}
			);
			-- Makes view blurry
			DrawMotionBlur(0.2,0.7,0);
			-- Draw blurred edges @aVoN
			render.SetMaterial(BlurEdges);
			render.UpdateScreenEffectTexture();
			render.DrawScreenQuad();
		end
	end
);

--################### Footsteps sound? (Hopefully comes along the next update) @aVoN
hook.Add("PlayerFootstep","StarGate.SodanCloaking.PlayerFootStep",
	function(p)
		if(IsValid(p) and p:IsPlayer()) then
			if(p:GetNWBool("pCloaked",false) and not LocalPlayer():GetNWBool("pCloaked",false)) then
				return true;
			end
		end
	end
);

-- HACKY HACKY HACKY HACKY HACKY @aVoN
-- Stops making players "recognizeable" if they are cloaked (E.g. by looking at them - Before you e.g. saw "Catdaemon - Health 100" if you lookaed at a cloaked player. Now, you dont see anything if he is cloaked
if(util._Sodan_TraceLine) then return end;
util._Sodan_TraceLine = util.TraceLine;
function util.TraceLine(...)
	local t = util._Sodan_TraceLine(...);
	if(t and IsValid(t.Entity)) then
		if(t.Entity:IsPlayer()) then
			if(not LocalPlayer():GetNetworkedBool("pCloaked",false) and t.Entity:GetNWBool("pCloaked",false)) then t.Entity = NULL end;
		end
	end
	return t;
end

end