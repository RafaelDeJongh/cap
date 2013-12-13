if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Naquadah Bottle"
ENT.Author = "JDM12989 and aVoN Edited by Dr.Mckay, AlexALX"
ENT.Contact = ""
ENT.WireDebugName = "Naquadah Bottle"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if SERVER then

--################# HEADER #################
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy")) then return end
AddCSLuaFile();
--################# SENT CODE ###############

--################# Init @JDM12989
function ENT:Initialize()
	self.Entity:SetModel("models/sandeno/naquadah_bottle.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.MaxEnergy = StarGate.CFG:Get("naquadah_bottle","capacity",30000);    --@meeces2911 WHAT is this energy ment to be, it was set to 500!? that it not very much energy ... ? Did you want 500 NE ?
	self.MaxStorage = StarGate.CFG:Get("naquadah_bottle","energy_capacity",10000);
	self.enabled = false;
	self.Naquadah = self.MaxEnergy; --Naquadah energy @Anorr
	self:AddResource("energy",self.MaxStorage); -- Maximum energy to store in a Naquadah Bottle is 800 units
	self:SupplyResource("energy",self.MaxStorage);
	self:CreateWireOutputs("Active","Naquadah %","Naquadah Energy");
	self:CreateWireInputs("Disable");
	self.health=50;

	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:Wake();
		phys:SetMass(5);
	end
end

--################# Spawn the SENT @JDM12989
function ENT:SpawnFunction(p,t)
	if(not t.Hit) then return end;
	local e = ents.Create("naquadah_bottle");
	e:SetPos(t.HitPos+Vector(0,0,10));
	e:Spawn();
	return e;
end

--################# Adds the annoying overlay speechbubble to this SENT @JDM12989
function ENT:ShowOutput(v,force)
	local add = "(Off)";
	if(self.enabled) then add = "(Active)" end;
	self:SetOverlayText("Naquadah Bottle "..add.."\n"..v.."%");
end

--################# Think @JDM12989
function ENT:Think()
	-- ok this code is buggy, maybe will fix later @AlexALX
	/*if (not self.enabled and self.Naquadah<=0 and energy>0) then
		if(not self.resfix) then
			if (energy<self.MaxEnergy) then
				self:ConsumeResource("energy",energy);
				self.Naquadah = energy;
			else
				self:ConsumeResource("energy",self.MaxEnergy);   -- This is to remove the excess energy stored in an energy cell, if ZPM is disabled.
				self.Naquadah = self.MaxEnergy;  -- This is adding the removed energy back into the ZPM
			end
			self.depleted = false;
		end
		self.resfix = true;
	end */
	if(self.depleted or not self.HasResourceDistribution) then self.Entity:NextThink(CurTime()+0.5); return true; end;
		local energy = self:GetResource("energy");
		local NE = self.Naquadah;
		local my_capacity = self:GetUnitCapacity("energy");
		local nw_capacity = self:GetNetworkCapacity("energy");
		local percent = (NE/self.MaxEnergy)*100;
		if(not self.disabled) then
			self.resfix = false;
			if(StarGate.WireRD.Connected(self)) then -- We are connected to a network - Enable Naquadah
				if(not self.enabled) then
					self.Entity:SetMaterial("models/sandeno/liquid.vmt");
					self.enabled = true;
				end
			else
				if(self.enabled) then
					self.Entity:SetMaterial("");
					self.enabled = false;
				end
			end
		else
			self.enabled = false;
		end
		-- No Naquadah Energy available anymore - We are depleted!
		if(NE <= 0) then
			self:AddResource("energy",0);
			timer.Simple(0.1,function() if IsValid(self) then self:SetMaterial("models/sandeno/base.vmt"); end end)
			self.depleted = true;
			self.enabled = false;
			self:SetOverlayText("Naquada Bottle\nDepleted");
		end
	-- Energy conversion when availeble storage @Anorr,aVoN
	if(self.enabled and not self.disabled and energy < nw_capacity) then
		local rate = (my_capacity+nw_capacity)/2; -- Two passes until it filled the full network
		rate = math.Clamp(rate,0,NE);
		rate = math.Clamp(rate,0,nw_capacity-energy);
		self:SupplyResource("energy",rate);
		self.Naquadah = self.Naquadah - rate;
	end
	if(self.depleted) then
		--Dev_Unlink_All(self.Entity);
		self:SetWire("Active",-1);
		self:SetWire("Naquadah Energy",0);
		self:SetWire("Naquadah %",0);
	else
		self:ShowOutput(percent);
		self:SetWire("Active",self.enabled);
		self:SetWire("Naquadah Energy",math.floor(NE));
		self:SetWire("Naquadah %",percent);
	end
	self.Entity:NextThink(CurTime()+0.5);
	return true;
end

--Using aVoN's Wire class thingy ??
function ENT:TriggerInput(name,value)
	if(name == "Disable") then
		if (value == 1) then
			self:SetWire("Disabled",1);
			self.disabled = true;
		else
			self:SetWire("Disabled",0);
			self.disabled = false;
		end
	end
end

function ENT:OnTakeDamage(dmg,attacker)

	self.health = self.health-dmg:GetDamage()

	if(self.health<1) then
		self:Boom()
	end
end

function ENT:Boom()
	local fx = EffectData()
		fx:SetOrigin(self:GetPos())
	util.Effect("Explosion",fx)
	self:Remove()
end

function ENT:Use(ply)
	if ply:IsPlayer() then
		if (self.Naquadah>0) then
			ply:GiveAmmo(50, "CombineCannon")
			ply:EmitSound("items/ammo_pickup.wav",100,100)
		end
		self:Remove()
	end
end

end

if CLIENT then

ENT.RenderGroup = RENDERGROUP_BOTH; -- This FUCKING THING avoids the clipping bug I have had for ages since stargate BETA 1.0. DAMN!
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("naquadah_bottle",SGLanguage.GetMessage("stool_naq_bottle"));
end

end