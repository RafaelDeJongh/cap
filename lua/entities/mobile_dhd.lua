/*
	DHD SENT for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "DHD (Mobile)"
ENT.Author = "aVoN / AlexALX"
ENT.WireDebugName = "Mobile DHD"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
--################# Include
AddCSLuaFile();

--################# SENT CODE #################

--################# Init @aVoN
function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self.Range = StarGate.CFG:Get("mobile_dhd","range",3000);
	--################# Wire!
	self:CreateWireInputs("Dial Address","Dial String [STRING]","Dial Mode","Transmit [STRING]","Start String Dial","Close","Disable Autoclose");
	self:CreateWireOutputs("Active","Open","Inbound","Chevron","Chevron Locked","Chevrons [STRING]","Dialing Address [STRING]","Dialing Mode","Dialing Symbol [STRING]","Dialed Symbol [STRING]","Received [STRING]");
	--################# Set physic and entity properties
	local phys = self:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
		phys:SetMass(10);
	end
	self.LockedGate = NULL;
end

--################# Find nearest stargate @aVoN
-- FIXME: Add this to the stargate lib!
function ENT:FindGate()
	if (IsValid(self.LockedGate)) then return self.LockedGate; end
	local gate;
	local dist = self.Range;
	local pos = self:GetPos();
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and not v.IsSupergate and (not IsValid(v.LockedMDHD) or v.LockedMDHD==self)) then
			local sg_dist = (pos - v:GetPos()):Length();
			if(dist >= sg_dist) then
				dist = sg_dist;
				gate = v;
			end
		end
	end
	return gate;
end

function ENT:Touch(ent)
	if not IsValid(self.LockedGate) then
		if (string.find(ent:GetClass(), "stargate")) then
			local gate = self:FindGate()
			if IsValid(gate) and gate==ent and not IsValid(gate.LockedMDHD) then
				self.LockedGate = gate;
				self:SetNWEntity("LockedGate",gate);
				gate.LockedMDHD = self;
				gate:SetNWEntity("LockedMDHD",self);
				local ed = EffectData()
 					ed:SetEntity( self )
 				util.Effect( "propspawn", ed, true, true )
			end
		end
	end
end

--################# Update the speech bubbles @aVoN
function ENT:Think()
	self:SetOverlayText("Mobile DHD");
	self:NextThink(CurTime() + 5);
	return true;
end

--################# Use @aVoN
function ENT:Use(p)
	self:OpenMenu(p);
end

--################# Open the menue @aVoN
function ENT:OpenMenu(p)
	if(not IsValid(p)) then return end;
	local e = self:FindGate();
	if(not IsValid(e)) then return end;
	if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,e) == false) then return end;
	net.Start("StarGate.VGUI.Menu");
	net.WriteEntity(e);
	net.WriteInt(1,8);
	net.Send(p);
end

--################# Wire input - Relay to the gate @aVoN
function ENT:TriggerInput(k,v)
	local gate = self:FindGate();
	if(IsValid(gate)) then
		gate:TriggerInput(k,v,true,self);
	end
end

function ENT:OnRemove()
	if (IsValid(self.LockedGate)) then
		self.LockedGate.LockedMDHD = nil;
		self.LockedGate:SetNWEntity("LockedMDHD",NULL);
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {};

	if (IsValid(self.LockedGate)) then
		dupeInfo.LockedGate = self.LockedGate:EntIndex();
	end

    duplicator.StoreEntityModifier(self, "StarGateMDHDInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self);
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	local dupeInfo = Ent.EntityMods.StarGateMDHDInfo
	if (dupeInfo and dupeInfo.LockedGate and CreatedEntities[dupeInfo.LockedGate]) then
		self.LockedGate = CreatedEntities[dupeInfo.LockedGate];
		self:SetNWEntity("LockedGate",self.LockedGate);
		CreatedEntities[dupeInfo.LockedGate].LockedMDHD = self.Entity;
		CreatedEntities[dupeInfo.LockedGate]:SetNWEntity("LockedMDHD",self.Entity);
	end

	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

end