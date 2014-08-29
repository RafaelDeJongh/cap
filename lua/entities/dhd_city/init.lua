--[[
	DHD Code
	Copyright (C) 2011 Madman07
]]--

--################# Include
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.PlorkSound = "stargate/dhd_atlantis.mp3";
ENT.LockSound = "stargate/chevron_lock_atlantis_incoming.mp3";
ENT.Model = "models/ZsDaniel/atlantis_console/dhd.mdl"

ENT.ChevronModel = {
	"models/ZsDaniel/atlantis_console/buttons/b1.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b2.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b3.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b4.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b5.mdl",

	"models/ZsDaniel/atlantis_console/buttons/b6.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b7.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b8.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b9.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b10.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b11.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b12.mdl",

	"models/ZsDaniel/atlantis_console/buttons/b13.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b14.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b15.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b16.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b17.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b18.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b19.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b20.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b21.mdl",

	"models/ZsDaniel/atlantis_console/buttons/b22.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b23.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b24.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b25.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b26.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b27.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b28.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b29.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b30.mdl",

	"models/ZsDaniel/atlantis_console/buttons/b31.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b32.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b33.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b34.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b35.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b36.mdl",
	"models/ZsDaniel/atlantis_console/buttons/b37.mdl",

	"", -- empty ones...
	"",
}

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

--################# Initialize @aVoN
function ENT:Initialize()
	self.DialledAddress = {}; -- The address, the DHD shall dial
	self.busy = false;
	util.PrecacheSound(self.PlorkSound);
	self.Entity:SetModel(self.Model)
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
	self:CreateWireInputs("Press Button","Disable Menu","Slow Mode","Disable Iris Toggle");
	self.Range = StarGate.CFG:Get("dhd","range",1000);
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableMotion(false);
	end
	self.Entity:SpawnChevron()
	-- Now, check for near active gates and light up this DHD with the recently called address on this gate
	local e = self:FindGate();
	if(IsValid(e) and (e.IsOpen or e.Dialling) and e.DialledAddress) then
		for i=1,11 do
			local chev = e.DialledAddress[i];
			if(not e:GetNetworkedBool("chevron"..i) and chev ~= "DIAL") then break end;
			self:AddChevron(chev,true);
		end
	end
	self:Fire("SetBodyGroup",1);
	self.Light = false;
	self.WireNoIris = false;
	timer.Create("LightThink"..self:EntIndex(), 0.5, 0, function() if IsValid(self.Entity) then self:LightThink() end end);
	timer.Create("EnergyThink"..self:EntIndex(), 3.0, 0, function() if IsValid(self.Entity) then self:EnergyThink() end end);
	self:EnergyThink();
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
	if (IsValid(e) and e:CheckEnergy(true,true)) then
		self:SetNWBool("HasEnergy",true);
	else
		self:SetNWBool("HasEnergy",false);
	end
end

--################# Call address @aVoN
function ENT:Use(p)
	--Player is calling the gate and it is not busy
	if (IsValid(p) and p:IsPlayer() and not self.busy) then
		local e = self:FindGate();
		if(not IsValid(e)) then return end; -- Just necessary to make the hook below not being called if no gate is here to get dialled
		if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,e) == false) then return end;
		self.LastPlayer = p;
		local btn = self:GetCurrentButton(p);
		if (btn and btn != "IRIS") then self:PressButton(btn); end
	end
	if (IsValid(p) and p:IsPlayer()) then -- small override for IRIS, to let it press even, if gate are activated
		local btn = self:GetCurrentButton(p);
		if (btn and btn == "IRIS" and not self.WireNoIris) then
			local iris = StarGate.FindIris(self:FindGate());
			if IsValid(iris) then iris:Toggle(); end
		end
	end
	return false;
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "dhd_city", StarGate.CAP_GmodDuplicator, "Data" )
end