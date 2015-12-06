/*
	Stargate Shield for GarrysMod10
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
ENT.PrintName = "Shield Generator"
ENT.Author = "aVoN"
ENT.WireDebugName = "Shield Generator"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile();

ENT.Sounds={
	Engage=Sound("shields/shield_engage.mp3"),
	Disengage=Sound("shields/shield_disengage.mp3"),
	Fail={Sound("buttons/button19.wav"),Sound("buttons/combine_button2.wav")},
};

--################# SENT CODE ###############

--################# Init @aVoN
function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.StrengthMultiplier = {1,1,1}; -- The first argument is the strength multiplier, the second is the regeneration multiplier. The third value is the "raw" value n, set by SetMultiplier(n) This will get set by the TOOL
	self.Strength = 100; -- Start with 100% Strength by default
	self.EngageEnergy = StarGate.CFG:Get("shield","engage_energy",500); -- This energy will be needed to engage the shield. You will get it back, when the shield collapses
	self.ConsumeMultiplier = StarGate.CFG:Get("shield","consume_multiplier",1); -- As higher this is, as more energy it will take when enabled
	self.RestoreMultiplier = StarGate.CFG:Get("shield","restore_multiplier",1); -- How fast can it restore it's health?
	self.StrengthConfigMultiplier = StarGate.CFG:Get("shield","strength_multiplier",1); -- Doing this value higher will make the shiels stronger (look at the config)
	self.MaxSize = StarGate.CFG:Get("shield","max_size",2048)
	self.Size = 80;
	self.RestoreThresold = StarGate.CFG:Get("shield","restore_thresold",15); -- Which powerlevel has the shield to reach again until it works again?
	self:AddResource("energy",1);
	self:CreateWireInputs("Activate","Strength","Disable Use","Disable Sound","Allowed Players [ARRAY]","Frequency","Fire Frequency");
	self:CreateWireOutputs("Active","Strength","Players Allowed [ARRAY]");
	self:SetWire("Strength",self.Strength);
	self.AllowedPlayers = {};
	self.Entity:SetUseType(SIMPLE_USE);
	self.Phys = self.Entity:GetPhysicsObject();
	self.SndDisable=0 --variable for Disabling sound @KvasirSG
	self.Frequency=0;
	self.FireFrequency = 0;
	if(self.Phys:IsValid()) then
		self.Phys:Wake();
		self.Phys:SetMass(10);
	end
end

--################# Prevent PVS bug/drop of all networkes vars (Let's hope, it works) @aVoN
function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end;

--################# Sets some NW Floats for the shield color @aVoN
function ENT:SetShieldColor(r,g,b)
	self.ShieldColor = Vector(r or 1,g or 1,b or 1);
	self:SetNetworkedVector("shield_color",self.ShieldColor);
end

--################# Avoids crashing a server with to huge size @aVoN
function ENT:SetSize(size)
	self.Size = math.Clamp(size,1,self.MaxSize);
end

--################# Is the shield enabled? @aVoN
function ENT:Enabled()
	return (self.Shield and self.Shield:IsValid());
end

function ENT:SetNoCollideWithAllowedPlayers()
	if(self.AllowedPlayers ~= {}) then
		for _,ply in pairs(self.AllowedPlayers) do
			if IsValid(ply) and ply:IsPlayer() then
				if not self.Shield:IsContainment() then
					self.Shield.nocollide[ply] = true;
				else
					self.Shield.nocollide[ply] = false;
				end
			end
		end
	end
end

function ENT:RemoveNoCollideWithAllowedPlayers()
	for _,ply in pairs(self.AllowedPlayers) do
		self.Shield.nocollide[ply] = false;
	end
end

function ENT:GetFrequency()
	return self.Frequency;
end

function ENT:SetFrequency(value)
	if value < 0 then value = 0 end;
	if value > 1500 then value = 1500 end;
	self.Frequency = value;
end

function ENT:SetFireFrequency(value)
	if value < 0 then value = 0 end;
	if value > 1000 then value = 1000 end;
	self.FireFrequency = value;
end

function ENT:GetFireFrequency()
	return self.FireFrequency;
end
--################# Activates or deactivates the shield @aVoN
function ENT:Status(b,nosound)
	if(b) then
		if(not self:Enabled()) then
			local energy = self:GetResource("energy",self.EngageEnergy);
			self.ConsumeAmmount = math.ceil(((self.Size)^2*math.pi*4)/1000000); -- Instead of doing this calculation very second, do it here
			self.ExtraConsume = math.exp(math.Clamp(self.StrengthMultiplier[3]*1.3,0.2,600));
			if((not self.Depleted or (self.Strength >= self.RestoreThresold)) and self.Strength > 0 and energy >= self.EngageEnergy) then
				-- Taking the enagage energy, you will get back later (when turning off the shield)
				self:ConsumeResource("energy",self.EngageEnergy);
				local e = ents.Create("shield");
				e.Size = self.Size;
				e:SetPos(self.Entity:GetPos());
				e:SetAngles(self.Entity:GetAngles());
				e:SetParent(self.Entity);
				e:Spawn();
				e:SetNWVector("shield_color",self.ShieldColor); -- Necessary for the effects!
				e:SetNWBool("containment",self.Containment); -- For the clientside traceline class
				if(e and e:IsValid() and not e.Disable) then -- When our new shield mentioned, that there is already a shield
					self.Shield = e;
					self:SetNoCollideWithAllowedPlayers();
					self:SetWire("Players Allowed",self.AllowedPlayers);
					self:ShowOutput(true);
					if(not nosound) then
						if(self.SndDisable==0) then
							self:EmitSound(self.Sounds.Engage,90,math.random(90,110));
						end
					end
					return;
				end
			end
		end
	else
		if(self:Enabled()) then
			-- Give back the energy, we took when it was enagaged
			self:SupplyResource("energy",self.EngageEnergy);
			self.Shield:Remove();
			self.Shield = nil;
			self:ShowOutput(false);
			if(not nosound and not self.Depleted) then
				if(self.SndDisable==0) then
					self:EmitSound(self.Sounds.Disengage,90,math.random(90,110));
				end
			end
		end
		return;
	end
	if(self.SndDisable==0) then
		-- Fail animation
		self:EmitSound(self.Sounds.Fail[1],90,math.random(90,110));
		self:EmitSound(self.Sounds.Fail[2],90,math.random(90,110));
	end
end

--################# Think @aVoN
function ENT:Think()
	local enabled = self:Enabled();
	self:Regenerate(enabled);
	if(self.Depleted) then
		-- Reenable shielt - It was depleted before (But alter the Thresold, so people wont have it up so fast again or need to wait ages)
		if(self.Strength >= math.Clamp(self.RestoreThresold/self.StrengthMultiplier[2],3,40)) then
			self.Depleted = nil;
			if(enabled) then
				if(self.SndDisable==0) then
					self:EmitSound(self.Sounds.Engage,90,math.random(90,110));
				end
				-- Add new entities to the shield, which "entered the shield" while it was offline!
				for _,v in pairs(ents.FindInSphere(self.Shield:GetPos(),self.Shield.Size)) do
					self.Shield.nocollide[v] = true;
				end
				self.Shield:DrawBubbleEffect(); -- Draw shield effect when shield reengaged
				self.Shield:SetTrigger(true);
				self.Shield:SetNWBool("depleted",false); -- For the traceline class - Clientside
				self.Shield:AddAthmosphere();
			end
		end
	elseif(enabled and self.HasResourceDistribution and self.ConsumeMultiplier ~= 0) then
		-- Consume energy
		local energy = self:GetResource("energy");
		-- Make the shield consume more power depending on it's strength
		local take_energy = (self.ConsumeAmmount or 1)*(self.ExtraConsume or 1)*self.ConsumeMultiplier
		self:ConsumeResource("energy",math.Clamp(take_energy,1,energy));
		if(energy <= take_energy) then
			self:Status(false);
			return;
		end
	end
	self:SetWire("Strength",self.Strength);
	self:ShowOutput(enabled);
	self.Entity:NextThink(CurTime()+0.5);
	return true;
end

--#################  Updates the overlay text @aVoN
function ENT:ShowOutput(enabled)
	local add = "Off";
	if(enabled) then
		add = "On";
	end
	self:SetWire("Active",enabled);
	if(self.Depleted) then
		add = "Depleted";
	end
	self:SetOverlayText("Shield ("..add..")\n"..math.floor(self.Strength).."%\nSize: "..self.Size);
end

--################# Set's the strengthg multiplier which is necessary for the shields regeneration time and strength @aVoN
function ENT:SetMultiplier(n)
	local n = math.Clamp(n or 0,-5,5); -- Backwarts compatibility and idiot-proof
	if(n > 0) then
		n = 1 + n;
		self.StrengthMultiplier[1] = n
		self.StrengthMultiplier[2] = n^1.5
	else
		n = 1/(1 - n);
		self.StrengthMultiplier[1] = n^1.5;
		self.StrengthMultiplier[2] = n;
	end
	self.Strength = math.Clamp((self.StrengthMultiplier[3]/n)*self.Strength,0,100); -- This avoids cheating
	self.StrengthMultiplier[3] = n;
end

--################# Shield got hit - Take strength @aVoN
function ENT:Hit(strength,normal,pos,fireFrequency)
	-- Calculate strenght-taking multiplier: Are we a shield, which is not moving? If so, we are many times stronger than a shield of a ship which is moving.
	local divisor = 1;
	if(self.Entity:GetVelocity():Length() < 5) then
		divisor = StarGate.CFG:Get("shield","stationary_shield_multiplier",10);
	end

	if (fireFrequency) then
		--if (self:GetFireFrequency() ~= 0) then
			local GetFrequency = self:GetFireFrequency() - fireFrequency or 0;
			if GetFrequency < 50 and GetFrequency > -50 then
				divisor = 5;
			else
				divisor = 0.25;
			end
		--end
	end
	-- Take strength
	self.Strength = math.Clamp(self.Strength-2*math.Clamp(strength,1,20)/(self.StrengthMultiplier[1]*self.StrengthConfigMultiplier*divisor),0,100);
	if(StarGate.CFG:Get("shield","apply_force",false)) then
		-- Make us bounce around
		self.Phys:ApplyForceOffset(-1*normal*strength*100*self.Phys:GetMass()/self.StrengthMultiplier[1],pos);
	end
end

--################# Reset it's strength @aVoN
function ENT:Regenerate(enabled)
	if(type(self.Strength) ~= "number") then self.Strength = 0 end; -- Somewhere the duplicator is setting self.Strength to a fucking bool. I dont know why. But it came with my new "save strength in adv dupe" system
	if(self.Strength < 100) then
		local multiplier = 1;
		-- Disabled shields can regenrate 2 times faster!
		if(not (enabled or self.Depleted)) then
			multiplier = multiplier*2.5;
		end
		-- Consume energy when restoring the strength
		if(StarGate.HasResourceDistribution) then
			local energy = self:GetResource("energy");
			local speed = math.Clamp(energy/5000,1,4); -- Can make up to 4 times faster to regenerate with enough power connected (ZPMs, resource Caches etc)
			multiplier = math.floor(multiplier*speed);
			local take_energy = multiplier*20
			if(take_energy > energy) then return end;
			self:ConsumeResource("energy",take_energy);
		else
			-- For those without lifesupport: Make the shield regenerate a bit faster (Due to request)
			multiplier = multiplier*2;
		end
		multiplier = multiplier*(self.RestoreMultiplier/self.StrengthMultiplier[2]); -- Multiplier from the config and with the StrengthMultiplier
		self.Strength = math.Clamp(self.Strength+multiplier,0,100);
		self:SetWire("Strength",math.floor(self.Strength));
		self:ShowOutput(enabled);
	end
end

--################# Wire input @aVoN
function ENT:TriggerInput(k,v)
	if(k=="Activate") then
		if((v or 0) >= 1) then
			self:Status(true);
		else
			self:Status(false);
		end
	elseif(k=="Strength") then
		self:SetMultiplier(math.Clamp(v,-5,5));
	elseif(k=="Disable Sound") then
		if(v>0) then
			self.SndDisable=1
		else
			self.SndDisable=0
		end
	elseif(k=="Allowed Players") then
		if (self:Enabled() and self.AllowedPlayers ~= {}) then
			self:RemoveNoCollideWithAllowedPlayers();
		end
		if (v~={}) then
			self.AllowedPlayers = v;
			if (self:Enabled()) then self:SetNoCollideWithAllowedPlayers(); end
		end
	elseif(k=="Frequency") then
		self:SetFrequency(v);
	elseif(k=="Fire Frequency") then
		self:SetFireFrequency(v);
	end
end

--#################  Claok @aVoN
function ENT:Use(p)
	if (self:GetWire("Disable Use")>0) then return end
	if(self:Enabled()) then
		self:Status(false);
	else
		self:Status(true);
	end
end

local function cap_shield_nuke(ent)
	if (not IsValid(ent)) then return end
	if (StarGate.IsInShield(ent)) then return false end
end

hook.Add("StarGate.GateNuke.DamageEnt","CAP.Shield.Nuke",cap_shield_nuke);
hook.Add("StarGate.GateNuke.KillPlayer","CAP.Shield.Nuke",cap_shield_nuke);
hook.Add("StarGate.SatBlast.DamageEnt","CAP.Shield.Nuke",cap_shield_nuke);

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_OPAQUE; -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!

end
