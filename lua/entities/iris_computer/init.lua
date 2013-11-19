if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base")) then return end
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

function ENT:Initialize()
	self.Entity:SetModel("models/props_lab/reciever01b.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)

	self.code = 0
	self.autoclose = false
	self.didclose = false	--Without this, the iris would close within a half second of opening.
	self.donotautoopen = false	--Open automatically when a correct code comes in?
	self.CodeStatus = 0
	self.closetime = 0
	self.wireCode = 0;
	self.LockedGate = self.Entity
	self.LockedIris = self.Entity
	self.Codes = {};
	self.wireDesc = "";
	self.GDOStatus = 0;
	self.GDOText = "";

	self:CreateWireInputs("Iris Control", "GDO Status", "GDO Text [STRING]","Auto-close","Don't Auto-Open","Close time","Disable Menu Mode")
	self:CreateWireOutputs("Incoming Wormhole", "Code Status", "Gate Active", "Received Code", "Code Description [STRING]", "Iris Active")

end

local function AutoClose(EntTable)	--timer function
	local gate, iris
	if EntTable.LockedGate == EntTable.Entity then
		gate, iris = EntTable:FindGate()
	else
		gate, iris = EntTable.LockedGate, EntTable.LockedIris
	end
	if gate.IsOpen and not iris.IsActivated then
		iris:Toggle()
		EntTable.didclose = true
	end
	EntTable.wireCode = 0;
	EntTable.CodeStatus = 0
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("iris_computer");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos+Vector(0,0,20));
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

util.AddNetworkString("gdopc_sendinfo")

function ENT:Use(ply)
	if (self:GetWire("Disable Menu Mode",0)>=2) then return end
	if (self:GetWire("Disable Menu Mode",0)==1 and self.Owner!=ply) then return end
	net.Start("gdopc_sendinfo")
	net.WriteEntity(self)
	net.WriteInt(self.closetime,4)
	net.WriteBit(self.autoclose)
	net.WriteBit(self.donotautoopen)
	net.WriteInt(table.Count(self.Codes),8)
	for k,v in pairs(self.Codes) do
		net.WriteString(v)
		net.WriteString(k)
	end
	net.Send(ply)
end

function ENT:Touch(ent)
	if self.LockedGate == self.Entity then
		if (string.find(ent:GetClass(), "stargate")) then
			local gate = self:FindGate()
			if IsValid(gate) and gate==ent and not IsValid(gate.LockedIrisComp) then
				local iris = gate:GetIris();
				if iris:IsValid() then
					self.LockedGate = gate
					self.LockedIris = iris
					gate.LockedIrisComp = self;
					local ed = EffectData()
	 					ed:SetEntity( self.Entity )
	 				util.Effect( "propspawn", ed, true, true )
 				end
			end
		end
	end
end

function ENT:Think()

	local gate, iris
	if self.LockedGate == self.Entity then
		gate, iris = self:FindGate()
	else
		gate = self.LockedGate
		iris = self.LockedIris
	end
	if IsValid(gate) and IsValid(iris) then
		if not gate.Outbound and (gate.IsOpen or gate.NewActive) then
			if self.autoclose and not self.didclose then
				if not iris.IsActivated and (not iris:IsBusy() or gate.NoxDialingType) then
					iris:Toggle()
					self.didclose = true	--We won't close the iris again until then next time the gate is active
				end
			end
		else
			self.wireCode = 0;
			self.CodeStatus = 0
			self.wireDesc = "";
		end

		if not (gate.IsOpen or gate.NewActive) and self.didclose and iris.IsActivated then
			if (not iris:IsBusy()) then
				self.didclose = false	--Resetting so we can autoclose again
				iris:Toggle()		--Make this optional in the future?
			end
		end

		if self.didclose and not (gate.IsOpen or gate.NewActive) and not iris:IsBusy() then
			self.didclose = false
		end


			if gate.IsOpen or gate.NewActive then
				self:SetWire("Gate Active", 1)
				if not gate.Outbound then
					self:SetWire("Incoming Wormhole", 1)
				else
					self:SetWire("Incoming Wormhole", 0)
				end
			else
				self:SetWire("Gate Active", 0)
			end

			if iris.IsActivated then
				self:SetWire("Iris Active", 1)
			else
				self:SetWire("Iris Active", 0)
			end

			if self.donotautoopen and not gate.IsOpen then
				self.CodeStatus = 0
			end
			self:SetWire("Code Status", self.CodeStatus)

			self:SetWire("Received Code", self.wireCode)
			self:SetWire("Code Description", self.wireDesc)

	else
		self.LockedGate = self.Entity;
		self.LockedIris = self.Entity;
	end

	self.Entity:NextThink(CurTime()+0.5)
	return true
end

function ENT:TriggerInput(iname, value)
	local gate, iris
	if self.LockedGate == self.Entity then
		gate, iris = self:FindGate()
	else
		gate = self.LockedGate
		iris = self.LockedIris
	end
	if (iname == "Iris Control" and IsValid(iris)) then
		iris:Toggle()
		if value == 0 and self.closetime ~= 0 then
			timer.Simple(self.closetime, function() AutoClose(self) end)
		end
	elseif (iname == "GDO Status") then
		self.GDOStatus = value;
	elseif (iname == "GDO Text") then
		self.GDOText = value;
	elseif (iname == "Don't Auto-Open") then
		if value > 0 then
			self.donotautoopen = true;
		else
			self.donotautoopen = false;
		end
	elseif (iname == "Auto-close") then
		if value > 0 then
			self.autoclose = true;
		else
			self.autoclose = false;
		end
	elseif (iname == "Close time") then
		if value > 0 then
			self.closetime = value;
		else
			self.closetime = 0;
		end
	end
end

---------------------------------------------
-- Server/Client crossover stuff
---------------------------------------------

local function ReceiveCodes(len, player)
	local ent = net.ReadEntity()
	if (not IsValid(ent)) then return end
	if (util.tobool(net.ReadBit())) then
		local gate, iris
		if ent.LockedGate == ent then
			gate, iris = ent:FindGate()
		else
			iris = ent.LockedIris
		end
		if IsValid(iris) then iris:Toggle() end
	else
		ent.closetime = net.ReadInt(4)
		ent.autoclose = util.tobool(net.ReadBit())
		ent.donotautoopen = util.tobool(net.ReadBit())
		local count = net.ReadInt(8)
		local codes = {}
		for i=1,count do
			local k,v = net.ReadString(),net.ReadString();
			if (k!="" and v!="") then
        		codes[k] = v
        	end
		end
		ent.Codes = codes;
	end
end
net.Receive("gdopc_sendinfo", ReceiveCodes)

---------------------------------------------
-- Gate Stuff
---------------------------------------------

function ENT:FindGate()  -- from aVoN's DHD
	local gate
	local iris
	local dist = 1000
	local pos = self.Entity:GetPos()
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		if(v.IsStargate and (not IsValid(v.LockedIrisComp) or v.LockedIrisComp==self)) then
			local sg_dist = (pos - v:GetPos()):Length()
			if(dist >= sg_dist) then
				dist = sg_dist
				gate = v
				local ir = v:GetIris();
				if (IsValid(ir)) then
					iris = ir;
				end
			end
		end
	end
	return gate, iris
end

function ENT:RecieveIrisCode(code)
	local gate, iris
	if self.LockedGate == self.Entity then
		gate, iris = self:FindGate()
	else
		gate = self.LockedGate
		iris = self.LockedIris
	end
	local ret = 0
	self.wireCode = code
	self:SetWire("Received Code", self.wireCode)
		for v,k in pairs(self.Codes) do
			if code == v then
				self.wireDesc = k;
				self:SetWire("Code Description", self.wireDesc)
				if IsValid(iris) and iris.IsActivated then
					if not self.donotautoopen then
						iris:Toggle()
						ret = 1
						if self.closetime ~= 0 then
							timer.Simple(self.closetime, function() AutoClose(self) end)
						end
					else
						ret = 2
						self.CodeStatus = 1
					end
				else
					ret = 1; self.CodeStatus = 1;
				end
			end
		end
		if (self.GDOStatus>0) then
			self.CodeStatus = 1; ret = 1;
			if IsValid(iris) and iris.IsActivated then
				if not self.donotautoopen then
					iris:Toggle()
					if self.closetime ~= 0 then
						timer.Simple(self.closetime, function() AutoClose(self) end)
					end
				else
					ret = 2
					self.CodeStatus = 1
				end
			end
		end
		if (self.GDOText!="") then
			ret = self.GDOText;
		end
		if self.CodeStatus == 0 and self.donotautoopen then	-- if no code was found, this'll be 0 still
			self.CodeStatus = 2			-- so, that means the code was wrong
		end
	timer.Remove("_sgiriscode"..self:EntIndex())
	timer.Create("_sgiriscode"..self:EntIndex(), 4.0, 0 , function()
		if (IsValid(self)) then
			self.wireCode = 0;
			self.wireDesc = "";
			self.CodeStatus = 0;
		end
	end)

	return ret
end

function ENT:OnRemove()
	if (self.LockedGate!=self) then
		self.LockedGate.LockedIrisComp = nil;
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {};

	dupeInfo.Codes = self.Codes or {};

	dupeInfo.closetime = self.closetime;
	dupeInfo.autoclose = self.autoclose;
	dupeInfo.donotautoopen = self.donotautoopen;
	dupeInfo.LockedIris = self.LockedIris:EntIndex();
	dupeInfo.LockedGate = self.LockedGate:EntIndex();

    duplicator.StoreEntityModifier(self, "StarGateIrisCompInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self);
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end

	local dupeInfo = Ent.EntityMods.StarGateIrisCompInfo
	if (dupeInfo.Codes) then
		self.Codes = dupeInfo.Codes;
	end
	if (dupeInfo.closetime) then
		self.closetime = dupeInfo.closetime;
	end
	if (dupeInfo.autoclose) then
		self.autoclose = dupeInfo.autoclose;
	end
	if (dupeInfo.donotautoopen) then
		self.donotautoopen = dupeInfo.donotautoopen;
	end
	if (dupeInfo.LockedIris) then
		self.LockedIris = CreatedEntities[dupeInfo.LockedIris];
	end
	if (dupeInfo.LockedGate and CreatedEntities[dupeInfo.LockedGate]) then
		self.LockedGate = CreatedEntities[dupeInfo.LockedGate];
		CreatedEntities[dupeInfo.LockedGate].LockedIrisComp = self;
	end
	if (IsValid(ply)) then
		self.Owner = ply;
	end

	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end