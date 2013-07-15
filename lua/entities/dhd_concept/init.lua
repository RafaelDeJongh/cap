--[[
	DHD Code
	Copyright (C) 2011 Madman07
]]--

--################# HEADER #################
if (not StarGate.CheckModule("extra")) then return end

--################# Include
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

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