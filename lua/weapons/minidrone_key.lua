SWEP.Category = "Stargate Carter Addon Pack: Misc"
SWEP.PrintName = "Minidrone Platform Key";
SWEP.Author = "Madman07";
SWEP.Contact = "";
SWEP.Purpose = "";
SWEP.Instructions = "Left Click = Fire Drones \nRight Click = Track Drones";
SWEP.Base = "weapon_base";
SWEP.Slot = 3;
SWEP.SlotPos = 3;
SWEP.DrawAmmo	= false;
SWEP.DrawCrosshair = true;
SWEP.ViewModel = "models/Madman07/minidrone_platform/key_v.mdl";
SWEP.WorldModel = "models/Madman07/minidrone_platform/key_w.mdl";
SWEP.ViewModelFOV = 90

-- primary.
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = -1;
SWEP.Primary.Automatic = true;
SWEP.Primary.Ammo	= "none";

-- secondary
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "none";

-- spawnables.
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;

function SWEP:PrimaryAttack() return false end
function SWEP:SecondaryAttack() return false end
function SWEP:Reload() return end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile();

function SWEP:Initialize()
	self.Owner.CanMinidroneControll = false;
	self.ReloadingTime = CurTime();
end

function SWEP:Think()
	local p = self.Owner;
	local tr = util.GetPlayerTrace(p)
	local trace=util.TraceLine(tr)
	p.Target = trace.HitPos;

	if IsValid(p.MiniDronePlatform) then
		local len = (p:GetPos() - p.MiniDronePlatform:GetPos()):Length();
		if (len < 500) then
			p.CanMinidroneControll = true;
		else
			p.CanMinidroneControll = false;
		end
	end
end

function SWEP:PrimaryAttack()
	local p = self.Owner;
	if (p.CanMinidroneControll and IsValid(p.MiniDronePlatform)) then
		p.MiniDronePlatform:FireDrones(p);
	end

	self.Weapon:SetNextPrimaryFire(CurTime()+0.15);
end

function SWEP:Reload()
	if (self.ReloadingTime and CurTime() <= self.ReloadingTime) then return end
	self.ReloadingTime = CurTime() + 1;

	local p = self.Owner;
	local tr = util.GetPlayerTrace(p)
	local trace = util.TraceLine(tr)

	local aimvector = p:GetAimVector():GetNormal();
	local shootpos = p:GetPos() + Vector(0,0,55);

	debugoverlay.Line(shootpos, shootpos+aimvector*100, 60, Color(255,255,255), true);

	local e = ents.Create("minidrone_key_ent");
	e:SetPos(shootpos+aimvector*10);
	e:Spawn();
	e:Activate();
	e:PhysWake();
	e:SetVelocity(aimvector*10);

	e.MiniDronePlatform = p.MiniDronePlatform;
	p.MiniDronePlatform = nil;
	p.CanMinidroneControll = nil;
	p:SetNetworkedEntity("DronePlatform", NULL);

	p:SelectWeapon("weapon_crowbar");
	self:Remove();
end

end

if CLIENT then

-- Inventory Icon
-- if(file.Exists("materials/VGUI/weapons/kino_inventory.vmt"),"GAME") then
	-- SWEP.WepSelectIcon = surface.GetTextureID("VGUI/weapons/kino_inventory");
-- end
-- Kill Icon
-- if(file.Exists("materials/VGUI/weapons/kino_inventory.vmt"),"GAME") then
	-- killicon.Add("KRD","VGUI/weapons/kino_inventory",Color(255,255,255));
-- end

local default = Material("madman07/minidrone_platform/key");
local noglow = Material("madman07/minidrone_platform/key_off");
local glow = Material("madman07/minidrone_platform/key_on");

function SWEP:Think()
	local p = self.Owner;
	local platform = p:GetNetworkedEntity("DronePlatform", NULL);
	if IsValid(platform) then
		local len = (p:GetPos() - platform:GetPos()):Length();
		if (len < 500) then
			default:SetTexture( "$basetexture", glow:GetTexture("$basetexture"));
			default:SetInt( "$selfillum", 1);
		else
			default:SetTexture( "$basetexture", noglow:GetTexture("$basetexture"));
			default:SetInt( "$selfillum", 0);
		end
	else
		default:SetTexture( "$basetexture", noglow:GetTexture("$basetexture"));
		default:SetInt( "$selfillum", 0);
	end
end

end