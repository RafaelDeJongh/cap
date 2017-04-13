--[[
	DHD Code
	Copyright (C) 2011 Madman07
]]--

ENT.Type = "anim"
ENT.Base = "dhd_base"
ENT.PrintName = "DHD (SG1)"
ENT.Author = "aVoN, Madman07, Llapp, Rafael De Jongh, MarkJaw, AlexALX"
ENT.Category = 	"Stargate Carter Addon Pack: Gates and Rings"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.Color = {
	chevron="200 65 0"
};

ENT.IsDHDSg1 = true

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
--################# Include
AddCSLuaFile();
ENT.PlorkSound = "stargate/dhd_sg1.mp3"; -- The old sound
ENT.ChevSounds = {
	Sound("stargate/dhd/sg1/press.mp3"),
	Sound("stargate/dhd/sg1/press_2.mp3"),
	Sound("stargate/dhd/sg1/press_3.mp3"),
	Sound("stargate/dhd/sg1/press_4.mp3"),
	Sound("stargate/dhd/sg1/press_5.mp3"),
	Sound("stargate/dhd/sg1/press_6.mp3"),
	Sound("stargate/dhd/sg1/press_7.mp3")
}
ENT.SkinNumber = 0;

--################# SpawnFunction
function ENT:SpawnFunction(p,tr)
	if (not tr.Hit) then return end;
	local pos = tr.HitPos - Vector(0,0,7.8 + 7);
	local e = ents.Create("dhd_sg1");
	e:SetPos(pos);
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 15; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	e:CartersRampsDHD(tr);
	return e;
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "dhd_sg1", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_BOTH -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
-- Damn u aVoN. It need to be setted to BOTH. I spend many hours on trying to fix Z-index issue. @Mad

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("dhd_sg1");
end

end