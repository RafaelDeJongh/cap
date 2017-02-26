--[[
	DHD Code
	Copyright (C) 2011 Madman07
]]--

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "dhd_base"
ENT.PrintName = "DHD (Concept)"
ENT.Author = "aVoN, Madman07, Rafael De Jongh, MarkJaw, AlexALX"
list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"
ENT.IsDHD = true;
ENT.IsDHDSg1 = true;
ENT.IsConceptDHD = true;

ENT.Color = {
	chevron="200 65 0"
};

-- The directionvectors, relativly from the EntPos to to the chevrons pos - The numbers and chars behind it will aquire a human readable adress like 1B3D5F-Chevron7 - Chevron7 will always be "Â", because the gmod10 servers are on earth :D
ENT.ChevronPositionsGroup = {
	--
	[0] = Vector(48.5569, -30.4505, 56.1191),
	[1] = Vector(49.5642, -25.8098, 57.2148),
	[2] = Vector(50.2756, -20.8445, 57.9749),
	[3] = Vector(51.1915, -15.5731, 58.9647),
	[4] = Vector(51.6003, -10.4547, 59.4690),
	[5] = Vector(51.3220, 10.7452, 59.3014),
	[6] = Vector(50.9710, 15.6241, 58.9700),
	[7] = Vector(50.2451, 20.9936, 58.0682),
	[8] = Vector(49.0729, 25.9128, 56.8758),
	[9] = Vector(48.2129, 30.8747, 55.8424),
	--
	A = Vector(52.0142, -30.6008, 52.5906),
	B = Vector(53.1413, -25.6796, 53.6922),
	C = Vector(54.1025, -20.6430, 54.3428),
	D = Vector(55.0149, -15.5521, 55.1457),
	E = Vector(55.4167, -10.0641, 55.7302),
	F = Vector(54.9046, 10.6529, 55.7267),
	G = Vector(54.6106, 15.7367, 55.2937),
	H = Vector(53.8456, 20.8703, 54.5095),
	I = Vector(52.8774, 26.2914, 53.0632),
	J = Vector(51.9053, 30.6530, 52.2831),
	K = Vector(55.8152, -30.4803, 48.8467),
	L = Vector(56.9366, -25.8528, 49.7983),
	M = Vector(57.8356, -20.6021, 50.7556),
	N = Vector(58.5811, -15.5133, 51.5877),
	O = Vector(59.0638, -10.3743, 52.0215),
	P = Vector(58.6544, 10.5961, 51.8802),
	Q = Vector(58.3514, 15.6265, 51.5889),
	R = Vector(57.5330, 20.8074, 50.8435),
	S = Vector(56.6752, 26.1958, 49.4457),
	T = Vector(55.4500, 30.3079, 48.6428),
	U = Vector(59.7849, -30.4418, 44.8727),
	V = Vector(60.6485, -25.6816, 46.1295),
	W = Vector(61.4295, -20.4695, 47.1451),
	X = Vector(62.3360, -15.6191, 47.8105),
	Y = Vector(62.1660, 15.7282, 47.7411),
	Z = Vector(61.1725, 20.9851, 47.1436),
	--
	["@"] = Vector(60.2137, 25.9327, 46.1211),
	["*"] = Vector(59.2734, 30.8548, 44.7939),
	["#"] = Vector(52.1807, 0.0444, 59.7953),
	-- Engage
	DIAL = Vector(56.1807, 0.0444, 50.7953), -- The middle "enter" button ;)

}

ENT.ChevronPositionsGalaxy = {
	--
	["!"] = Vector(48.5569, -30.4505, 56.1191),
	[1] = Vector(49.5642, -25.8098, 57.2148),
	[2] = Vector(50.2756, -20.8445, 57.9749),
	[3] = Vector(51.1915, -15.5731, 58.9647),
	[4] = Vector(51.6003, -10.4547, 59.4690),
	[5] = Vector(51.3220, 10.7452, 59.3014),
	[6] = Vector(50.9710, 15.6241, 58.9700),
	[7] = Vector(50.2451, 20.9936, 58.0682),
	[8] = Vector(49.0729, 25.9128, 56.8758),
	[9] = Vector(48.2129, 30.8747, 55.8424),
	--
	A = Vector(52.0142, -30.6008, 52.5906),
	B = Vector(53.1413, -25.6796, 53.6922),
	C = Vector(54.1025, -20.6430, 54.3428),
	D = Vector(55.0149, -15.5521, 55.1457),
	E = Vector(55.4167, -10.0641, 55.7302),
	F = Vector(54.9046, 10.6529, 55.7267),
	G = Vector(54.6106, 15.7367, 55.2937),
	H = Vector(53.8456, 20.8703, 54.5095),
	I = Vector(52.8774, 26.2914, 53.0632),
	J = Vector(51.9053, 30.6530, 52.2831),
	K = Vector(55.8152, -30.4803, 48.8467),
	L = Vector(56.9366, -25.8528, 49.7983),
	M = Vector(57.8356, -20.6021, 50.7556),
	N = Vector(58.5811, -15.5133, 51.5877),
	O = Vector(59.0638, -10.3743, 52.0215),
	P = Vector(58.6544, 10.5961, 51.8802),
	Q = Vector(58.3514, 15.6265, 51.5889),
	R = Vector(57.5330, 20.8074, 50.8435),
	S = Vector(56.6752, 26.1958, 49.4457),
	T = Vector(55.4500, 30.3079, 48.6428),
	U = Vector(59.7849, -30.4418, 44.8727),
	V = Vector(60.6485, -25.6816, 46.1295),
	W = Vector(61.4295, -20.4695, 47.1451),
	X = Vector(62.3360, -15.6191, 47.8105),
	Y = Vector(62.1660, 15.7282, 47.7411),
	Z = Vector(61.1725, 20.9851, 47.1436),
	--
	["@"] = Vector(60.2137, 25.9327, 46.1211),
	["*"] = Vector(59.2734, 30.8548, 44.7939),
	["#"] = Vector(52.1807, 0.0444, 59.7953),
	-- Engage
	DIAL = Vector(56.1807, 0.0444, 50.7953), -- The middle "enter" button ;)

}

if SERVER then

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

--################# Include
AddCSLuaFile();

--################# SENT CODE #################
ENT.Model = "models/MarkJaw/dhd/dhd_base.mdl"
ENT.ModelBroken = "models/MarkJaw/dhd/dhd_base.mdl"
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

ENT.ChevronModel = {
	"models/MarkJaw/dhd/buttons/b1.mdl",
	"models/MarkJaw/dhd/buttons/b2.mdl",
	"models/MarkJaw/dhd/buttons/b3.mdl",
	"models/MarkJaw/dhd/buttons/b4.mdl",
	"models/MarkJaw/dhd/buttons/b5.mdl",
	"models/MarkJaw/dhd/buttons/b6.mdl",
	"models/MarkJaw/dhd/buttons/b7.mdl",
	"models/MarkJaw/dhd/buttons/b8.mdl",
	"models/MarkJaw/dhd/buttons/b9.mdl",
	"models/MarkJaw/dhd/buttons/b10.mdl",
	"models/MarkJaw/dhd/buttons/b11.mdl",
	"models/MarkJaw/dhd/buttons/b12.mdl",
	"models/MarkJaw/dhd/buttons/b13.mdl",
	"models/MarkJaw/dhd/buttons/b14.mdl",
	"models/MarkJaw/dhd/buttons/b15.mdl",
	"models/MarkJaw/dhd/buttons/b16.mdl",
	"models/MarkJaw/dhd/buttons/b17.mdl",
	"models/MarkJaw/dhd/buttons/b18.mdl",
	"models/MarkJaw/dhd/buttons/b19.mdl",
	"models/MarkJaw/dhd/buttons/b20.mdl",
	"models/MarkJaw/dhd/buttons/b21.mdl",
	"models/MarkJaw/dhd/buttons/b22.mdl",
	"models/MarkJaw/dhd/buttons/b23.mdl",
	"models/MarkJaw/dhd/buttons/b24.mdl",
	"models/MarkJaw/dhd/buttons/b25.mdl",
	"models/MarkJaw/dhd/buttons/b26.mdl",
	"models/MarkJaw/dhd/buttons/b27.mdl",
	"models/MarkJaw/dhd/buttons/b28.mdl",
	"models/MarkJaw/dhd/buttons/b29.mdl",
	"models/MarkJaw/dhd/buttons/b30.mdl",
	"models/MarkJaw/dhd/buttons/b31.mdl",
	"models/MarkJaw/dhd/buttons/b32.mdl",
	"models/MarkJaw/dhd/buttons/b33.mdl",
	"models/MarkJaw/dhd/buttons/b34.mdl",
	"models/MarkJaw/dhd/buttons/b35.mdl",
	"models/MarkJaw/dhd/buttons/b36.mdl",
	"models/MarkJaw/dhd/buttons/b37.mdl",
	"models/MarkJaw/dhd/buttons/b38.mdl",
	"models/MarkJaw/dhd/buttons/b39.mdl",
	"models/MarkJaw/dhd/buttons/chev.mdl",
}

ENT.ChevronNumber = {
	[0] = 1,
	["0"] = 1,
	[1] = 2,
	["1"] = 2,
	[2] = 3,
	["2"] = 3,
	[3] = 4,
	["3"] = 4,
	[4] = 5,
	["4"] = 5,
	[5] = 6,
	["5"] = 6,
	[6] = 7,
	["6"] = 7,
	[7] = 8,
	["7"] = 8,
	[8] = 9,
	["8"] = 9,
	[9] = 10,
	["9"] = 10,
	A = 11,
	B = 12,
	C = 13,
	D = 14,
	E = 15,
	F = 16,
	G = 17,
	H = 18,
	I = 19,
	J = 20,
	K = 21,
	L = 22,
	M = 23,
	N = 24,
	O = 25,
	P = 26,
	Q = 27,
	R = 28,
	S = 29,
	T = 30,
	U = 31,
	V = 32,
	W = 33,
	X = 34,
	Y = 35,
	Z = 36,
	["@"] = 37,
	["*"] = 38,
	["#"] = 39,
	["DIAL"] = 40,
}

--################# SpawnFunction
function ENT:SpawnFunction(p,tr)
	if (not tr.Hit) then return end;
	local pos = tr.HitPos;
	local e = ents.Create("dhd_concept");
	e:SetPos(pos);
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	e:CartersRampsDHD(tr);
	return e;
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "dhd_concept", StarGate.CAP_GmodDuplicator, "Data" )
end

end

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("dhd_concept");
end

end