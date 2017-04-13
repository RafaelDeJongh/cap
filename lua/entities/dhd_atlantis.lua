--[[
	DHD Code
	Copyright (C) 2011 Madman07
]]--

ENT.Type = "anim"
ENT.Base = "dhd_base"
ENT.PrintName = "DHD (Atlantis)"
ENT.Author = "aVoN, Madman07, Llapp, Rafael De Jongh, MarkJaw, AlexALX"
ENT.Category = 	"Stargate Carter Addon Pack: Gates and Rings"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.Color = {
	chevron="30 135 180"
};

ENT.IsDHDAtl = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end

--################# HEADER #################
AddCSLuaFile()

ENT.PlorkSound = "stargate/dhd_atlantis.mp3";
ENT.LockSound = "stargate/chevron_lock_atlantis_incoming.mp3";
ENT.SkinNumber = 2;
ENT.SkinBase = 1;

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
	e:CartersRampsDHD(tr);
	return e;
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "dhd_atlantis", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_BOTH -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
-- Damn u aVoN. It need to be setted to BOTH. I spend many hours on trying to fix Z-index issue. @Mad

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("dhd_atlantis");
end

end