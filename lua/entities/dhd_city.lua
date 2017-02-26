--[[
	DHD Code
	Copyright (C) 2011 Madman07
]]--

--################# Include
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "dhd_base"
ENT.PrintName = "DHD (City)"
ENT.Author = "aVoN, Madman07, ZsDaniel, Rafael De Jongh, AlexALX"
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"
ENT.WireDebugName = "DHD (City)"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.IsDHD = true;
ENT.IsGroupDHD = true;
ENT.IsDHDAtl = true;
ENT.IsCityDHD = true;

ENT.Color = {
	chevron="200 1 1"
};

-- The directionvectors, relativly from the EntPos to to the chevrons pos - The numbers and chars behind it will aquire a human readable adress like 1B3D5F-Chevron7 - Chevron7 will always be "Â", because the gmod10 servers are on earth :D
ENT.ChevronPositionsGroup2 = {
	["*"] = Vector(-9.13, 20.55, 37.84),    -- Both changed for galaxy and universe, using crystal for it
	["@"] = Vector(-4.07, 20.52, 37.85),    -- # is included with DIAL
	[0] = Vector(14.292, 2.177, 37.8),  -- Random dialing
	IRIS = Vector(9.45, -22.05, 35.56), -- Toggle iris, crystal

	[1] = Vector(8.403, -11.959, 37.8),
	[2] = Vector(8.403, -8.425, 37.8),
	[3] = Vector(8.403, -4.893, 37.8),
	[4] = Vector(8.403, -1.358, 37.8),
	[5] = Vector(8.403, 2.177, 37.8),
	[6] = Vector(8.403, 5.711, 37.8),
	[7] = Vector(8.403, 9.246, 37.8),
	[8] = Vector(8.403, 12.784, 37.8),
	[9] = Vector(8.403, 16.314, 37.8),

	A = Vector(-7.7, -4.893, 37.8),
	B = Vector(-7.7, -1.358, 37.8),
	C = Vector(-7.7, 2.177, 37.8),
	D = Vector(-7.7, 5.711, 37.8),
	E = Vector(-7.7, 9.246, 37.8),

	F = Vector(-2.488, -8.425, 37.8),
	G = Vector(-2.488, -4.893, 37.8),
	H = Vector(-2.488, -1.358, 37.8),
	I = Vector(-2.488, 2.177, 37.8),
	J = Vector(-2.488, 5.711, 37.8),
	K = Vector(-2.488, 9.246, 37.8),
	L = Vector(-2.488, 12.784, 37.8),

	M = Vector(3.467, -11.959, 37.8),
	N = Vector(3.467, -8.425, 37.8),
	O = Vector(3.467, -4.893, 37.8),
	P = Vector(3.467, -1.358, 37.8),
	Q = Vector(3.467, 5.711, 37.8),
	R = Vector(3.467, 9.246, 37.8),
	S = Vector(3.467, 12.784, 37.8),
	T = Vector(3.467, 16.314, 37.8),

	U = Vector(14.292, -8.425, 37.8),
	V = Vector(14.292, -4.893, 37.8),
	W = Vector(14.292, -1.358, 37.8),

	X = Vector(14.292, 5.711, 37.8),
	Y = Vector(14.292, 9.246, 37.8),
	Z = Vector(14.292, 12.784, 37.8),

	DIAL = Vector(3.467, 2.177, 37.8), -- The middle button + #
};

ENT.ChevronPositionsGalaxy2 = {
	["!"] = Vector(-9.13, 20.55, 37.84),    -- Both changed for galaxy and universe, using lights for it
	["@"] = Vector(-4.07, 20.52, 37.85),    -- # is included with DIAL
	["*"] = Vector(14.292, 2.177, 37.8),  -- Random dialing
	IRIS = Vector(9.45, -22.05, 35.56), -- Toggle iris, crystal

	[1] = Vector(8.403, -11.959, 37.8),
	[2] = Vector(8.403, -8.425, 37.8),
	[3] = Vector(8.403, -4.893, 37.8),
	[4] = Vector(8.403, -1.358, 37.8),
	[5] = Vector(8.403, 2.177, 37.8),
	[6] = Vector(8.403, 5.711, 37.8),
	[7] = Vector(8.403, 9.246, 37.8),
	[8] = Vector(8.403, 12.784, 37.8),
	[9] = Vector(8.403, 16.314, 37.8),

	A = Vector(-7.7, -4.893, 37.8),
	B = Vector(-7.7, -1.358, 37.8),
	C = Vector(-7.7, 2.177, 37.8),
	D = Vector(-7.7, 5.711, 37.8),
	E = Vector(-7.7, 9.246, 37.8),

	F = Vector(-2.488, -8.425, 37.8),
	G = Vector(-2.488, -4.893, 37.8),
	H = Vector(-2.488, -1.358, 37.8),
	I = Vector(-2.488, 2.177, 37.8),
	J = Vector(-2.488, 5.711, 37.8),
	K = Vector(-2.488, 9.246, 37.8),
	L = Vector(-2.488, 12.784, 37.8),

	M = Vector(3.467, -11.959, 37.8),
	N = Vector(3.467, -8.425, 37.8),
	O = Vector(3.467, -4.893, 37.8),
	P = Vector(3.467, -1.358, 37.8),
	Q = Vector(3.467, 5.711, 37.8),
	R = Vector(3.467, 9.246, 37.8),
	S = Vector(3.467, 12.784, 37.8),
	T = Vector(3.467, 16.314, 37.8),

	U = Vector(14.292, -8.425, 37.8),
	V = Vector(14.292, -4.893, 37.8),
	W = Vector(14.292, -1.358, 37.8),

	X = Vector(14.292, 5.711, 37.8),
	Y = Vector(14.292, 9.246, 37.8),
	Z = Vector(14.292, 12.784, 37.8),

	DIAL = Vector(3.467, 2.177, 37.8), -- The middle button + #
};

--################# Gets the button, a player is aiming at @aVoN
function ENT:GetCurrentButton(p,multi)
	local e = self.Entity;
	if (self.Entity:GetNetworkedBool("SG_GROUP_SYSTEM")) then
		self.ChevronPositions2 = self.ChevronPositionsGroup2;
	else
		self.ChevronPositions2 = self.ChevronPositionsGalaxy2;
	end
	local c = self.ChevronPositions2;
	local t = p:GetEyeTrace();
	-- damn you garry... GetEyeTrace in gmod13 return always same value when some menu is open
	if (CLIENT and gui.MousePos()!=0) then
		t = util.TraceLine( util.GetPlayerTrace( p, gui.ScreenToVector(gui.MousePos()) ) )
	end
	local cv = self.Entity:WorldToLocal(t.HitPos)
	cv:Normalize();
	local btn -- Possible chevron;
	if(multi) then
		btn = {};
	end
	local lastd = 1337; -- Last distance
	for k,v in pairs(c) do
		local da = math.deg(math.acos(v:DotProduct(cv)/v:Length())); -- The differangle
		if(k == "DIAL" and not multi) then
			if(da < 5) then
				btn = k;
				break;
			end
		else
			if(multi) then
				if(da < multi) then
					table.insert(btn,{button=k,angle=da});
				end
			else
				if(da < 5) then
					if(da < lastd) then
						lastd = da;
						btn = k;
					end
				end
			end
		end
	end
	return btn;
end

if SERVER then
AddCSLuaFile();

ENT.PlorkSound = "stargate/dhd_atlantis.mp3";
ENT.LockSound = "stargate/chevron_lock_atlantis_incoming.mp3";
ENT.Model = "models/ZsDaniel/atlantis_console/dhd.mdl"

ENT.ChevronModel = {}
-- make code shorter
for i=1,37 do
	table.insert(ENT.ChevronModel,"models/ZsDaniel/atlantis_console/buttons/b"..i..".mdl")
end
table.insert(ENT.ChevronModel,"") -- empty ones...
table.insert(ENT.ChevronModel,"")

ENT.ChevronNumber = {

	A = 1,
	B = 2,
	C = 3,
	D = 4,
	E = 5,
	F = 6,
	G = 7,
	H = 8,
	I = 9,
	J = 10,
	K = 11,
	L = 12,
	M = 13,
	N = 14,
	O = 15,
	P = 16,
	["DIAL"] = 37,
	Q = 17,
	R = 18,
	S = 19,
	T = 20,

	[1] = 21,
	["1"] = 21,
	[2] = 22,
	["2"] = 22,
	[3] = 23,
	["3"] = 23,
	[4] = 24,
	["4"] = 24,
	[5] = 25,
	["5"] = 25,
	[6] = 26,
	["6"] = 26,
	[7] = 27,
	["7"] = 27,
	[8] = 28,
	["8"] = 28,
	[9] = 29,
	["9"] = 29,

	U = 30,
	V = 31,
	W = 32,
	[0] = 33,
	["0"] = 33,
	["!"] = 33,
	X = 34,
	Y = 35,
	Z = 36,

	["@"] = 0,
	["#"] = 0,
	["*"] = 0,
}

--################# SpawnFunction
function ENT:SpawnFunction(p,tr)
	if (not tr.Hit) then return end;
	local pos = tr.HitPos;
	local e = ents.Create("dhd_city");
	e:SetPos(pos);
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	return e;
end

function ENT:LightThink()
	if (not IsValid(self.Entity)) then return end
	local ply = StarGate.FindPlayer(self.Entity:GetPos(), 300);

	if (ply and not self.Light and self:GetNWBool("HasEnergy",false)) then
		self.Light = true;
		self.Entity:SetSkin(1);
	elseif (not ply and self.Light or self.Light and not self:GetNWBool("HasEnergy",false)) then
		self.Light = false;
		self.Entity:SetSkin(0);
	end
end

function ENT:EnergyThink()
	if (not IsValid(self.Entity)) then return end

	local e = self:FindGate();
	if (IsValid(e) and e:CheckEnergy(true,true) or self.ButtonsMode) then
		self:SetNWBool("HasEnergy",true);
	else
		self:SetNWBool("HasEnergy",false);
	end
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "dhd_city", StarGate.CAP_GmodDuplicator, "Data" )
end

else -- CLIENT

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	ENT.Category = SGLanguage.GetMessage("stargate_category");
	ENT.PrintName = SGLanguage.GetMessage("dhd_city");
end

end