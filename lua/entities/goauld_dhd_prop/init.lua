--[[
	Goauld DHD
	Copyright (C) 2010 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	util.PrecacheModel("models/Boba_Fett/portable_dhd/portable_dhd.mdl")
	self.Entity:SetModel("models/Boba_Fett/portable_dhd/portable_dhd.mdl");

	self.Entity:SetName("Goa'uld DHD");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	-- now its wrong, zpms have new code for energy and this thing not work anymore, also all this shit not work with Environments addon
	-- and like i remember it can dial only 7 chevrons, so goauld_dhd_pros is like dhd and this code not needed.
	/*self.MaxEnergy = StarGate.CFG:Get("zpm","capacity",10000000);
	self:AddResource("ZPE",self.MaxEnergy); --ZeroPoint energy @Anorr
	self:SupplyResource("ZPE",self.MaxEnergy);
	self:AddResource("energy",StarGate.CFG:Get("zpm","energy_capacity",5000)); -- Maximum energy to store in a ZPM is 5000 units   */


end

-----------------------------------USE----------------------------------

function ENT:Use(ply)
	ply:Give("goauld_dhd");
	ply:SelectWeapon("goauld_dhd");
	self.Entity:Remove()
end

function ENT:DialMenu()
	//if(self.HasRD) then self.Entity:Power(); end
	if (self.Gates.IsGroupStargate) then
		umsg.Start("StarGate.OpenDialMenuDHD_Group",self.Owner);
	else
		umsg.Start("StarGate.OpenDialMenuDHD",self.Owner);
	end
	umsg.Entity(self.Gates);
	umsg.End();
end

       /*
--This is from aVoN's wire_rd detection but
--################# What version is installed? @aVoN
local RD; -- QuickIndex
local IsThree;
local function RDThree()
	if(IsThree ~= nil) then return IsThree end;
	if(CAF and CAF.GetAddon("Resource Distribution")) then
		IsThree = true;
		RD = CAF.GetAddon("Resource Distribution");
		return true;
	end
	IsThree = false;
	return false;
end

function ENT:Power()

	if(RDThree()) then
		RD.Link(self.Entity,self.Gates)
	else
		Dev_Link(self.Entity,self.Gates)
	end
end*/