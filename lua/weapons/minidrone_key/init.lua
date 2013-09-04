if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

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

