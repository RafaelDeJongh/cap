--[[
	Apple Core
	Copyright (C) 2011 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

-----------------------------------INIT----------------------------------

function ENT:Initialize()

	self.Entity:SetName("Apple Core");
	self.Entity:SetModel("models/Assassin21/apple_core/core.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);

	self.HaveRD3 = false;
	if (CAF and CAF.GetAddon("Resource Distribution")) then self.HaveRD3 = true end --RD3 needed!

	if self.HaveRD3 then -- Life Support
		if (WireAddon) then
			self.Outputs = WireLib.CreateOutputs( self.Entity, {"Water","Steam","Energy","ZPH","Oxygen"});
		end

		self.netid = CAF.GetAddon("Resource Distribution").CreateNetwork(self);
		self:SetNetworkedInt( "netid", self.netid );
		self.range = 2048;
		self:SetNetworkedInt( "range", self.range );

		self.RDEnt = CAF.GetAddon("Resource Distribution");
	end

end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnConsole()
	local data = self:GetAttachment(self:LookupAttachment("Console"))
	if(not (data and data.Pos and data.Ang)) then return end

	local ent = ents.Create("destiny_console");
	ent:SetAngles(data.Ang-Angle(0,90,0));
	ent:SetPos(data.Pos);
	ent:SetParent(self.Entity);
	ent:Spawn();
	ent:SetModel("models/Iziraider/destiny_dhd/body2.mdl");
	ent.Core = self;
	ent.HaveCore = true;
	ent.Owner = self.Owner;
	self.Console = ent;
	self:SetNetworkedEntity("Console", self.Console);
	ent:SetNWBool("Core", true);
	constraint.Weld(ent,self,0,0,0,true)
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_applecore_max"):GetInt()
	if(ply:GetCount("CAP_applecore")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Apple Core limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y-60) % 360;

	local ent = ents.Create("apple_core");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos);
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	ent:SpawnConsole();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAP_applecore", ent)
	return ent
end

-----------------------------------RESOURCE DISTRIBUTION----------------------------------

function ENT:Think()
	if self.HaveRD3 and self.RDEnt.GetNetTable then
		local nettable = self.RDEnt.GetNetTable(self.netid);
		if nettable.resources then
			if nettable.resources.water then
				Wire_TriggerOutput(self.Entity, "Water", nettable.resources.water.value)
			end
			if nettable.resources.steam then
				Wire_TriggerOutput(self.Entity, "Steam", nettable.resources.steam.value)
			end
			if nettable.resources.energy then
				Wire_TriggerOutput(self.Entity, "Energy", nettable.resources.energy.value)
			end
			if nettable.resources.ZPH then
				Wire_TriggerOutput(self.Entity, "ZPH", nettable.resources.ZPH.value)
			end
			if nettable.resources.oxygen then
				Wire_TriggerOutput(self.Entity, "Oxygen", nettable.resources.oxygen.value)
			end
		end

	local nettable = CAF.GetAddon("Resource Distribution").GetNetTable(self.netid)
	if table.Count(nettable) > 0 then
		local entities = nettable.entities
		if table.Count(entities) > 0 then
			for k, ent in pairs(entities) do
				if ent and IsValid(ent) then
					local pos = ent:GetPos()
					if pos:Distance(self:GetPos()) > self.range then
						CAF.GetAddon("Resource Distribution").Unlink(ent)
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

	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
	if IsValid(self.Console) then self.Console:Remove(); end

	if IsValid(self.Light) then
		self.Light:Fire("TurnOn","","0");
		self.Light:Remove();
		self.Light = nil;
	end

	if self.HaveRD3 and CAF then
		CAF.GetAddon("Resource Distribution").UnlinkAllFromNode(self.netid)
		CAF.GetAddon("Resource Distribution").RemoveRDEntity(self)
		if not (WireAddon == nil) then Wire_Remove(self.Entity) end
	end

	if (IsValid(self.Console)) then
		self.Console:Remove();
	end

	self:Remove();
end

function ENT:SetCustomNodeName(name)
end

function ENT:SetActive( value, caller )
end

function ENT:Repair()
end

function ENT:SetRange(range)
end

function ENT:OnRestore()
	if not (WireAddon == nil) then Wire_Restored(self.Entity) end
end
/* why only rd3? its calling from wire_rd
function ENT:PreEntityCopy()
	if self.HaveRD3 then
		local RD = CAF.GetAddon("Resource Distribution")
		RD.BuildDupeInfo(self.Entity)
		if not (WireAddon == nil) then
			local DupeInfo = WireLib.BuildDupeInfo(self.Entity)
			if DupeInfo then
				duplicator.StoreEntityModifier( self.Entity, "WireDupeInfo", DupeInfo )
			end
		end
	end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if self.HaveRD3 then
		local RD = CAF.GetAddon("Resource Distribution")
		RD.ApplyDupeInfo(Ent, CreatedEntities)
		if not (WireAddon == nil) and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
			WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
		end
	end
end*/

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex();
	end

	if IsValid(self.Console) then
		dupeInfo.Console = self.Console:EntIndex();
	end
	/*
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Console )
	end*/

	dupeInfo.ScreenTextA = self.Console.ScreenTextA;
	dupeInfo.ScreenTextB = self.Console.ScreenTextB;
	dupeInfo.ScreenTextC = self.Console.ScreenTextC;
	dupeInfo.ScreenTextD = self.Console.ScreenTextD;
	dupeInfo.ScreenTextE = self.Console.ScreenTextE;
	dupeInfo.ScreenTextF = self.Console.ScreenTextF;
	dupeInfo.ScreenTextG = self.Console.ScreenTextG;
	dupeInfo.ScreenTextH = self.Console.ScreenTextH;
    /*
	if self.HaveRD3 then
		local RD = CAF.GetAddon("Resource Distribution")
		RD.BuildDupeInfo(self.Entity)
	end */

	duplicator.StoreEntityModifier(self, "APDupeInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self)
end
duplicator.RegisterEntityModifier( "APDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)

	local dupeInfo = Ent.EntityMods.APDupeInfo

	if dupeInfo.Console then
		self.Console = CreatedEntities[dupeInfo.Console];
		self:SetNWEntity("Console",self.Console)
		self.Console.Core = self;
		self.Console.HaveCore = true;
		self.Console.Owner = self.Owner;
		self:SetNetworkedEntity("Console", self.Console);
		self.Console:SetNWBool("Core", true);
	end

	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:OnRemove(); return end
	local PropLimit = GetConVar("CAP_applecore_max"):GetInt();
	if (IsValid(ply)) then
		if(ply:GetCount("CAP_applecore")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Apple Core limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:OnRemove();
			return
		end
	end

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end
    /*
	if(Ent.EntityMods and Ent.EntityMods.APDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.APDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	if self.HaveRD3 then
		local RD = CAF.GetAddon("Resource Distribution")
		RD.ApplyDupeInfo(Ent, CreatedEntities)
	end */

	self.Console:SetNetworkedString("NameA",dupeInfo.ScreenTextA);
	self.Console:SetNetworkedString("NameB",dupeInfo.ScreenTextB);
	self.Console:SetNetworkedString("NameC",dupeInfo.ScreenTextC);
	self.Console:SetNetworkedString("NameD",dupeInfo.ScreenTextD);
	self.Console:SetNetworkedString("NameE",dupeInfo.ScreenTextE);
	self.Console:SetNetworkedString("NameF",dupeInfo.ScreenTextF);
	self.Console:SetNetworkedString("NameG",dupeInfo.ScreenTextG);
	self.Console:SetNetworkedString("NameH",dupeInfo.ScreenTextH);

	if (IsValid(ply)) then
		self.Owner = ply;
		ply:AddCount("CAP_applecore", self.Entity)
	end
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)

end