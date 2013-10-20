/*
	SGC ZPM Device for GarrysMod 10
	Copyright (C) 2010 Llapp, cooldudetb, model by micropro
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy")) then return end
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds = {
	PowerUp=Sound("zpmhub/zpm_power_up.wav"),
	SlideIn=Sound("zpmhub/zpm_hub_slide_in.wav"),
	SlideOut=Sound("zpmhub/zpm_hub_slide_out.wav"),
	Idle=Sound("zpmhub/zpm_hub_idle.wav"),
}

function ENT:Initialize()
	self.Entity:SetModel("models/micropro/zpmslot/zpm_slot.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	local phys = self.Entity:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableMotion(false);
		phys:SetMass(1000);
	end
	self:CreateWireInputs("Deactivate ZPM","Eject ZPM");
	self:CreateWireOutputs("Active","ZPM Hub %","ZPM Hub Energy");

	self.CanEject = true;

	self.HaveRD3 = false;
	if (CAF and CAF.GetAddon("Resource Distribution")) then self.HaveRD3 = true end

	if self.HaveRD3 then -- Make us a node!
		self.netid = CAF.GetAddon("Resource Distribution").CreateNetwork(self);
		self:SetNetworkedInt( "netid", self.netid );
		self.range = 2048;
		self:SetNetworkedInt( "range", self.range );

		self.RDEnt = CAF.GetAddon("Resource Distribution");
	elseif ( RES_DISTRIB == 2 ) then
		self:AddResource("energy",1)
	end

	self.ZPM = {On=false,Ent=nil,IsValid=false,Dir=1,Dist=1,Eject=0,Type="ZPH",SoundIn=0,SoundOut=0};
	self.Position = {R=0,F=0};
	self.Active = false;

	self.IdleSound = self.IdleSound or CreateSound(self.Entity,self.Sounds.Idle);
	self.IdleS = false;

	self:Skins();
end

function ENT:SpawnFunction(p,t)
	if (not t.Hit) then return end
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+90) % 360;
	local pos = t.HitPos+Vector(0,0,0);
	local e = ents.Create("sgc_zpm_hub");
	e:SetPos(pos);
	e:SetAngles(ang);
	e:DrawShadow(true);
	e:SetVar("Owner",p);
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:UseZPM()
	if (self.ZPM.Dist == 1) then
		self.ZPM.Eject = self.ZPM.Eject+1;
		timer.Simple(0.1,function()
			if(IsValid(self.Entity) and self.ZPM.Eject >= 1)then
				self.ZPM.Eject = self.ZPM.Eject-1;
			end
		end);
	else
		self.ZPM.Dir = 1;
	end
end

function ENT:Touch(ent)
	local pos = self.Entity:GetPos();
	local ang = self.Entity:GetAngles();
	if (self.CanEject == true and ent.IsZPM and ent ~= self.ZPM.Ent) then
		if (not self.ZPM.IsValid and self.ZPM.Eject == 0) then
			self.ZPM.Ent = ent;
			self.ZPM.Dist = 1;
			self.ZPM.Dir = 1;
			self.ZPM.Type = "ZPH";
			self.ZPM.IsValid = true;
			ent:SetUseType(SIMPLE_USE);
			ent.Use = function()
				local constr = constraint.FindConstraint(self,"Weld");
				if (constr) then
					constr.Entity[1].Entity:UseZPM();
				end
			end
			constraint.RemoveAll(ent);
			ent:SetPos(pos + self.Entity:GetRight()*(self.Position.R) + self.Entity:GetUp()*(29.1+10) + self.Entity:GetForward()*(self.Position.F));
			ent:SetAngles(ang);
			constraint.Weld(self.Entity,ent,0,0,0,true);
		end
	end
end

function ENT:TriggerInput(variable, value)
	if (variable == "Deactivate ZPM") then
		self.ZPM.Dir = value;
	elseif (variable == "Eject ZPM") then
		self.ZPM.Eject = value;
	end
end

function ENT:Skins()
	if(self.Active) then
		self.Entity:SetSkin(2);
    else
		self.Entity:SetSkin(1);
	end
end

function ENT:Think()
	if self.HaveRD3 then
		local nettable = CAF.GetAddon("Resource Distribution").GetNetTable(self.netid)
		if table.Count(nettable) > 0 then
			local entities = nettable.entities
			if table.Count(entities) > 0 then
				for k, ent in pairs(entities) do
					if ent and IsValid(ent) then
						local pos = ent:GetPos()
						if pos:Distance(self:GetPos()) > self.range then
							self:HubUnlink(ent)
							self:EmitSound("physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav", 500)
							ent:EmitSound("physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav", 500)
						end
					end
				end
			end
			local cons = nettable.cons
			if table.Count(cons) > 0 then
				for k, v in pairs(cons) do
					local tab = CAF.GetAddon("Resource Distribution").GetNetTable(v)
					if tab and table.Count(tab) > 0 then
						local ent = tab.nodeent
						if ent and IsValid(ent) then
							local pos = ent:GetPos()
							local range = pos:Distance(self:GetPos())
							if range > self.range and range > ent.range then
								CAF.GetAddon("Resource Distribution").UnlinkNodes(self.netid, ent.netid)
								self:EmitSound("physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav", 500)
								ent:EmitSound("physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav", 500)
							end
						end
					end
				end
			end
		end
	end

	local zpmi = {En=0,Per=0,Max=0}

	self.Active = false;

	local ZPH = 0;
	local percent = 0;

	self.ZPM.IsValid = (self.ZPM.Ent and self.ZPM.Ent:IsValid());
	if (self.ZPM.IsValid) then
		self.ZPM.On = ((self.ZPM.Ent.Connected and not self.ZPM.Ent.Empty) or self.ZPM.Ent.enabled == true);
		if self.ZPM.On then
			if (self.ZPM.Type == "ZPH") then
				zpmi.En = self.ZPM.Ent.Energy;
				zpmi.Max = self.ZPM.Ent.MaxEnergy;
			else
				zpmi.En = self.ZPM.Ent:GetResource(self.ZPM.Type);
				zpmi.Max = self.ZPM.Ent.MaxEnergy;
			end
			zpmi.Per = (zpmi.En/zpmi.Max)*100;
			if(zpmi.Per <= 0)then
				zpmi.Per = 0;
			end
			ZPH = ZPH+zpmi.En;
			percent = percent+zpmi.Max;
		end
		local v = self.ZPM
		self.ZPM.Ok = (not util.tobool(v.Dist)) and ( v.Ent.Connected or v.Ent.empty )
		local constr = constraint.FindConstraint(self.ZPM.Ent,"Weld");
		if (self.ZPM.Dist == 1 and (self.ZPM.Eject == 1 or not constr or constr.Entity[1].Entity ~= self.Entity)) then
			self:EjectZPM();
		elseif (self.ZPM.Dist == 0 and self.ZPM.On) then
			self.Active = true;
		end
	end

	self:ZPMsMovement();

	self:SoundIdle(self.Active);
	self:Skins();

	self:SoundSetup();

    self:SetWire("Active",self.Active);

	if percent > 0 then
		percent = (ZPH/percent)*100;
	else
		percent = 0;
	end
	if (self.ZPM.IsValid == false) then
		percent = 0;
	end

	if (self.IdleS) then
		self.IdleSound:ChangePitch(85,0);
		self.IdleSound:SetSoundLevel(70);
		self.IdleSound:PlayEx(1,86);
	else
		self.IdleSound:Stop()
	end

	if IsValid(self.ZPM.Ent) and self.ZPM.Dist == 0 then
		self:SetWire("ZPM Hub %",self.ZPM.Ok and percent or -1);
	else
		self:SetWire("ZPM Hub %",-1);
	end

	timer.Simple(0.1,function()
	    if(IsValid(self.Entity))then
		    self.Entity:SetNetworkedInt("Percents",percent);
		end
	end);
    self:SetWire("Active",self.Active);
    self:SetWire("ZPM Hub Energy",math.floor(ZPH));
	self:Output(percent,ZPH);

	self.Entity:SetNetworkedEntity("ZPM",self.ZPM.Ent);

	self.Entity:NextThink(CurTime()+0.01);
	return true;
end

function ENT:Output(perc,eng)
	local add = "Inactive";
	if(self.Active)then add = "Active" end;
	self.Entity:SetNWString("add",add);
	self.Entity:SetNWString("perc",perc);
	self.Entity:SetNWString("eng",math.floor(eng));
end

function ENT:ZPMsMovement()
	local pos = self.Entity:GetPos();
	local ang = self.Entity:GetAngles();
	local spd = 0.015;
	if (self.ZPM.IsValid and self.ZPM.Dist ~= self.ZPM.Dir) then
		if (self.ZPM.Dist < 0) then
			self.ZPM.Dist = 0;
		elseif (self.ZPM.Dist> 1) then
			self.ZPM.Dist = 1;
		end

		if (self.ZPM.Dir < self.ZPM.Dist) then
			self.ZPM.Dist = self.ZPM.Dist-spd;
			if(self.ZPM.SoundIn==1) then
				self.Entity:EmitSound(self.Sounds.SlideIn,60,100);
				self.ZPM.SoundIn = 2;
			end
			if(self.ZPM.SoundOut==2) then
				self.ZPM.SoundOut = 0;
			end
		elseif (self.ZPM.Dir > self.ZPM.Dist) then
			self.ZPM.Dist = self.ZPM.Dist+spd;
			if(self.ZPM.SoundOut==1) then
				self.Entity:EmitSound(self.Sounds.SlideOut,60,100);
				self.ZPM.SoundOut = 2;
			end
			if(self.ZPM.SoundIn==2) then
				self.ZPM.SoundIn = 0;
			end
		end
		constraint.RemoveAll(self.ZPM.Ent);
		self.ZPM.Ent:SetAngles(self.Entity:GetAngles());
		self.ZPM.Ent:SetPos(pos + self.Entity:GetRight()*(self.Position.R) + self.Entity:GetUp()*(29.1+10*self.ZPM.Dist) + self.Entity:GetForward()*(self.Position.F));
		constraint.Weld(self.Entity,self.ZPM.Ent,0,0,math.floor(self.ZPM.Dist)*5000,true);
		if (self.ZPM.Dir == 0 and self.ZPM.Dist == 0) then
			self:HubLink(self.ZPM.Ent);
		elseif (self.ZPM.Dir == 1) then
			self:HubUnlink(self.ZPM.Ent);
		end
	end
end

function ENT:SoundSetup()
	if(self.ZPM.Dir == 0) then
		if(self.ZPM.SoundIn==0) then
			self.ZPM.SoundIn = 1;
		end
	elseif(self.ZPM.Dir == 1) then
		if(self.ZPM.SoundOut==0) then
			self.ZPM.SoundOut = 1;
		end
	end
end

function ENT:SoundIdle(idle)
    if(idle) then
        self.IdleS = true;
	else
	    self.IdleS = false;
	end
end

function ENT:HubLink(ent)
	if self.HaveRD3 then
		CAF.GetAddon("Resource Distribution").Link(ent,self.netid);
	elseif Environments then
		ent:Link(self.node);
		if (self.node) then
			self.node:Link(ent);
		end
	elseif ( RES_DISTRIB == 2 ) then
		Dev_Link(ent,self, nil, nil, nil, nil, nil);
	end
end
function ENT:HubUnlink(ent)
	if self.HaveRD3 then
		CAF.GetAddon("Resource Distribution").Unlink(ent);
	elseif Environments then
		ent:Unlink();
	elseif ( RES_DISTRIB == 2 ) then
		Dev_Unlink_All(ent);
	end
end

 function ENT:Use()
    local val = false;
    if((self.ZPM.IsValid and self.ZPM.Dist == 1)) then
		val = true;
	end

	if (val)then
		timer.Simple(1,function()
			if (IsValid(self.Entity)) then
				self.ZPM.Dir = 0;
  			end
		end);
	else
		timer.Simple(1,function()
			if (IsValid(self.Entity)) then
				self.ZPM.Dir = 1;
			end
		end);
	end
end


function ENT:SetCustomNodeName(name)
end

function ENT:EjectZPM()
	if (self.ZPM.Ent) then
		self.ZPM.Ent.Use = function() end;
		self:HubUnlink(self.ZPM.Ent);
		local phys = self.ZPM.Ent:GetPhysicsObject();
		if(phys:IsValid()) then
			constraint.RemoveAll(self.ZPM.Ent);
		end
		local mul = 3.2;
		self.CanEject = false;
		timer.Simple(1,function()
			if(IsValid(self.Entity))then
				self.CanEject = true;
			end
		end);
		local pos = self.Entity:GetPos();
		self.ZPM.Ent:SetPos(pos + self.Entity:GetRight()*(self.Position.R*mul) + self.Entity:GetUp()*(29.1+12) + self.Entity:GetForward()*(self.Position.F*mul));
	end
	self.ZPM.Ent = nil;
	self.ZPM.IsValid = false;
	self.ZPM.On = false;
end

function ENT:Repair()
end

function ENT:SetRange(range)
end

function ENT:OnRemove()
	if (self.ZPM.IsValid) then
		self:EjectZPM();
	end

	self.IdleSound:Stop()

	StarGate.WireRD.OnRemove(self);
end

function ENT:PreEntityCopy()
	local dupeInfo = {};
	dupeInfo.ZPM = self.ZPM;
	if (IsValid(self.ZPM.Ent)) then
		dupeInfo.ZPMid = self.ZPM.Ent:EntIndex();
	else
		dupeInfo.ZPMid = -1;
	end
	duplicator.StoreEntityModifier(self, "ZPMs", dupeInfo);
	StarGate.WireRD.PreEntityCopy(self)
end

function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
	self.ZPM = Ent.EntityMods.ZPMs.ZPM;
	if (Ent.EntityMods.ZPMs.ZPMid!=-1) then
		self.ZPM.Ent = CreatedEntities[Ent.EntityMods.ZPMs.ZPMid]
		self.ZPM.Ent:SetUseType(SIMPLE_USE);
		self.ZPM.Ent.Use = function()
			local constr = constraint.FindConstraint(self,"Weld");
			constr.Entity[1].Entity:UseZPM(i);
		end
	end
	StarGate.WireRD.PostEntityPaste(self,Player,Ent,CreatedEntities)
end

if (Environments) then
		ENT.Link = function(self, ent, delay)
			if self.node and IsValid(self.node) then
				self:Unlink()
				if (IsValid(self.ZPM.Ent) and self.ZPM.Dist == 0 and self.ZPM.Ent.node and IsValid(self.ZPM.Ent.node)) then
					self.ZPM.Ent:Unlink()
				end
			end
			if ent and ent:IsValid() then
				if (IsValid(self.ZPM.Ent) and self.ZPM.Dist == 0) then
					self.ZPM.Ent:Link(ent)
					ent:Link(self.ZPM.Ent)
				end
				self.node = ent

				if delay then
					timer.Simple(0.1, function()
						umsg.Start("Env_SetNodeOnEnt")
							umsg.Short(self:EntIndex())
							umsg.Short(ent:EntIndex())
						umsg.End()
					end)
				else
					umsg.Start("Env_SetNodeOnEnt")
						umsg.Short(self:EntIndex())
						umsg.Short(ent:EntIndex())
					umsg.End()
				end
				--self:SetNWEntity("node", ent)
			end
		end
	ENT.Unlink = function(self)
		if self.node then
			if (IsValid(self.ZPM.Ent) and self.ZPM.Dist == 0 and self.ZPM.Ent.node and IsValid(self.ZPM.Ent.node)) then
				self.ZPM.Ent:Unlink()
			end
			self.node:Unlink(self)
			self.node = nil
			umsg.Start("Env_SetNodeOnEnt")
				umsg.Short(self:EntIndex())
				umsg.Short(0)
			umsg.End()
		end
	end
end