--[[
	DHD Code
	Copyright (C) 2011 Madman07
]]--

if (not StarGate.CheckModule("base")) then return end

--################# HEADER #################
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
ENT.PlorkSound = "stargate/dhd_atlantis.mp3";
ENT.LockSound = "stargate/chevron_lock_atlantis_incoming.mp3";
ENT.SkinNumber = 2;

--################# SpawnFunction
function ENT:SpawnFunction(p,tr)
	if (not tr.Hit) then return end;
	local pos = tr.HitPos - Vector(0,0,7.8 + 7);
	local e = ents.Create("dhd_atlantis");
	e:SetPos(pos);
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 15; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	e:Fire("skin",1);
	e:CartersRampsDHD(tr);
	return e;
end