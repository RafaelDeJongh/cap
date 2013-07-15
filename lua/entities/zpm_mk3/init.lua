/*
	ZPM MK III for GarrysMod 10
	Copyright (C) 2010 Llapp
*/

if (not StarGate.CheckModule("energy")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

function ENT:Initialize()
	self.Entity:SetModel("models/pg_props/pg_zpm/pg_zpm.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableMotion(false);
		phys:SetMass(10);
	end
	--self:AddResource("ZPMs",1);
	--self:SupplyResource("ZPMs",1);
	--self:AddResource("ZPMO",10000000);
	self:AddResource("energy",StarGate.CFG:Get("zpm_mk3","energy_capacity",1000000));
	self:SupplyResource("energy",StarGate.CFG:Get("zpm_mk3","energy_capacity",1000000))
	self.MaxEnergy = StarGate.CFG:Get("zpm_mk3","capacity",88000000);
	self.Energy = StarGate.CFG:Get("zpm_mk3","capacity",88000000);
	self:CreateWireOutputs("Active","ZPM %","ZPM Energy");
	self:Skin(2);
	self.empty = false;
	self.Connected = false;
	self.Flow = 0;
	self.isZPM = 1;
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local e = ents.Create("zpm_mk3");
	e:SetPos(t.HitPos+Vector(0,0,0));
	e:DrawShadow(true);
	e:SetVar("Owner",p)
	e:Spawn();
	e:Activate();
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	e:SetAngles(ang);
	self.Zpm = e;
	return e;
end

function ENT:Skin(a)
    if(a==1)then
		self.Entity:SetSkin(1);
		self.Entity:SetNetworkedInt("zpmyellowlightalpha",155);
	elseif(a==2)then
        self.Entity:SetSkin(0);
		self.Entity:SetNWInt("zpmyellowlightalpha",1);
	end
end

function ENT:Think()
    if(self.empty or not self.HasResourceDistribution)then return end;
	if(self.Entity:SetNetworkedEntity("ZPM",self.Zpm)==NULL)then
	    self.Entity:SetNetworkedEntity("ZPM",self.Zpm)
	end

	local energy = self:GetResource("energy");

	if (self.Flow == 0) then
		/*local entTable = RD.GetEntityTable(self);
		local netTable = RD.GetNetTable(entTable["network"]);
		local entities = netTable["entities"]; */
		local entities = StarGate.WireRD.GetEntListTable(self);

		if (entities != nil) then
			zpms = 0;
			local zpmsarray = {};
			for k, v in pairs(entities) do
				if IsValid(v) then
					if (v.isZPM != NULL) then
						zpms = zpms+1;
						zpmsarray[zpms] = v;
					end
				end
			end

			local nw_capacity = self:GetNetworkCapacity("energy");
			local rate = (nw_capacity-energy)/zpms;

			for k, v in pairs(zpmsarray) do
				v.Flow = rate;
			end
		end
	end

	local active = 1;
	--local my_capacity = self:GetUnitCapacity("energy");
    --local nw_capacity = self:GetNetworkCapacity("energy");
	--if(my_capacity ~= nw_capacity)then
	if (StarGate.WireRD.Connected(self.Entity)) then
		if(not self.Connected) then
			self:Skin(1);
			self.Connected = true;
		end
	else
		if(self.Connected) then
			self:Skin(2);
			self.Connected = false;
		end
	end
	if(self.Energy > 0)then
   	    local my_capacity = self:GetUnitCapacity("energy");
        local nw_capacity = self:GetNetworkCapacity("energy");
        percent = (self.Energy/self.MaxEnergy)*100;
   	    if(energy < nw_capacity)then
       	    --local rate = (my_capacity+nw_capacity)/2;
       	    local rate = self.Flow;
   	        rate = math.Clamp(rate,0,self.Energy);
   	        rate = math.Clamp(rate,0,nw_capacity-energy);
            self:SupplyResource("energy",rate);
            self.Energy = self.Energy-rate;
        end
	else
	    percent = 0;
		self.Energy = 0;
		active = 0;
		self.empty = true;
		self:Skin(2);
		--if (self.HasRD) then StarGate.WireRD.OnRemove(self,true) end;
		self:AddResource("energy",0);
		self.Connected = false;
	end

	self.Flow = 0;

    self:SetWire("Active",active);
    self:SetWire("ZPM Energy",math.floor(self.Energy));
    self:SetWire("ZPM %",percent);
	self:Output(percent,self.Energy);
	self.Entity:NextThink(CurTime()+0.01);
	return true;
end

function ENT:Output(perc,eng)
	local add = "Disconnected";
	if(self.Connected)then add = "Connected" end;
	if (self.Energy<=0) then add = "Depleted" end;
	self.Entity:SetNWString("add",add);
	self.Entity:SetNWString("perc",perc);
	self.Entity:SetNWString("eng",math.floor(eng));
end