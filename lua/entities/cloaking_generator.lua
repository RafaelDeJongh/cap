/*
	Cloaking for GarrysMod10
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
ENT.PrintName = "Cloaking Generator"
ENT.Author = "aVoN"
ENT.WireDebugName = "Cloaking Generator"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.RenderGroup = RENDERGROUP_OPAQUE; -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end

--################# HEADER #################
AddCSLuaFile();

ENT.Sounds={
	Fail={Sound("buttons/button19.wav"),Sound("buttons/combine_button2.wav")},
	Cloak=Sound("npc/strider/striderx_alert4.wav"),
	Uncloak=Sound("npc/turret_floor/die.wav"),
};

--################# SENT CODE ###############

--################# Init @aVoN
function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.ConsumeAmmount = StarGate.CFG:Get("cloaking","energy",300); -- Energy needed for cloaking (per second)
	self.MaxSize = StarGate.CFG:Get("cloaking","max_size",1024);
	self:AddResource("energy",1);
	self:CreateWireInputs("Activate");
	self:CreateWireOutputs("Active");
	self.Entity:SetUseType(SIMPLE_USE);
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
		phys:SetMass(10);
	end
end

--################# Prevent PVS bug/drop of all networkes vars (Let's hope, it works) @aVoN
function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end;

--################# Anti-Crash @aVoN
function ENT:SetSize(size)
	self.Size = math.Clamp(size,1,self.MaxSize);
end

--################# Wire input @aVoN
function ENT:TriggerInput(k,v)
	if(k=="Activate") then
		if((v or 0) >= 1) then
			self:Status(true);
		else
			self:Status(false);
		end
	end
end

--#################  Claok @aVoN
function ENT:Use(p)
	if(self:Enabled()) then
		self:Status(false);
	else
		self:Status(true);
	end
end

--################# Is the shield enabled? @aVoN
function ENT:Enabled()
	return (self.Cloak and self.Cloak:IsValid());
end

--################# Activates or deactivates the shield @aVoN
function ENT:Status(b,nosound)
	if(b) then
		if(not self:Enabled()) then
			local energy = self:GetResource("energy",self.ConsumeAmmount);
			if(energy >= self.ConsumeAmmount) then
				local e = ents.Create("cloaking");
				e.Size = self.Size;
				e:SetPos(self.Entity:GetPos());
				e:SetAngles(self.Entity:GetAngles());
				e:SetParent(self.Entity);
				e:Spawn();
				if(not nosound) then
					self:EmitSound(self.Sounds.Cloak,80,math.random(80,100));
				end
				if(e and e:IsValid() and not e.Disable) then -- When our new cloak mentioned, that there is already a cloak
					self.Cloak = e;
					self:ShowOutput(true);
					return;
				end
			end
		end
	else
		if(self:Enabled()) then
			-- Give back the energy, we took when it was enagaged
			self.Cloak:Remove();
			self.Cloak = nil;
			self:ShowOutput(false);
			if(not nosound) then
				self:EmitSound(self.Sounds.Uncloak,80,math.random(90,110));
			end
		end
		return;
	end
	-- Fail animation
	self:EmitSound(self.Sounds.Fail[1],90,math.random(90,110));
	self:EmitSound(self.Sounds.Fail[2],90,math.random(90,110));
end

--################# Think @aVoN
function ENT:Think()
	local enabled = self:Enabled();
	if(enabled) then
		-- Consume energy
		local energy = self:GetResource("energy",self.ConsumeAmmount);
		-- Make the shield consume more power depending on it's strength
		self:ConsumeResource("energy",math.Clamp(self.ConsumeAmmount,1,energy));
		if(energy < self.ConsumeAmmount) then
			self:Status(false);
			return;
		end
	end
	self:ShowOutput(enabled);
	self.Entity:NextThink(CurTime()+1);
	return true;
end

--#################  Updates the overlay text @aVoN
function ENT:ShowOutput(enabled)
	local add = "Off";
	if(enabled) then
		add = "On";
	end
	self:SetWire("Active",enabled);
	self:SetOverlayText("Cloaking Generator ("..add..")\nSize: "..self.Size);
end

end