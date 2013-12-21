/*
	Stargate Wire/RD Lib for GarrysMod10
	Copyright (C) 2007-2009  aVoN

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

--################# Adds LifeSupport,ResourceDistribution and WireSupport to an entity when getting called - HAS TO BE CALLED BEFORE ANY OTHERTHING IS DONE IN A SENT (like includes) @aVoN
-- My suggestion is to put this on the really top of the shared.lua
StarGate.WireRD = {};
function StarGate.LifeSupportAndWire(ENT)
	ENT.WireDebugName = ENT.WireDebugName or "No Name";
	ENT.HasWire = StarGate.HasWire;
	ENT.HasResourceDistribution = StarGate.HasResourceDistribution;
	ENT.HasRD = StarGate.HasResourceDistribution; -- Quick reference

	-- General handlers
	ENT.OnRemove = StarGate.WireRD.OnRemove;
	ENT.OnRestore = StarGate.WireRD.OnRestore;

	-- Wire Handlers
	ENT.CreateWireOutputs = StarGate.WireRD.CreateWireOutputs;
	ENT.CreateWireInputs = StarGate.WireRD.CreateWireInputs;
	ENT.SetWire = StarGate.WireRD.SetWire;
	ENT.GetWire = StarGate.WireRD.GetWire;

	-- RD Handling
	ENT.AddResource = StarGate.WireRD.AddResource;
	ENT.GetResource = StarGate.WireRD.GetResource;
	ENT.ConsumeResource = StarGate.WireRD.ConsumeResource;
	ENT.SupplyResource = StarGate.WireRD.SupplyResource;
	ENT.GetUnitCapacity = StarGate.WireRD.GetUnitCapacity;
	ENT.GetNetworkCapacity = StarGate.WireRD.GetNetworkCapacity;

	-- For LifeSupport and Resource Distribution and Wire - Makes all connections savable with Duplicator
	ENT.PreEntityCopy = StarGate.WireRD.PreEntityCopy;
	ENT.PostEntityPaste = StarGate.WireRD.PostEntityPaste;

	if (Environments) then
		ENT.Link = function(self, ent, delay)
			if self.node and IsValid(self.node) then
				self:Unlink()
			end
			if ent and ent:IsValid() then
				self.node = ent

				if delay then
					timer.Simple(0.1, function()
						umsg.Start("Env_SetNodeOnEnt")
							--umsg.Entity(self)
							--umsg.Entity(ent)
							umsg.Short(self:EntIndex())
							umsg.Short(ent:EntIndex())
						umsg.End()
					end)
				else
					umsg.Start("Env_SetNodeOnEnt")
						--umsg.Entity(self)
						--umsg.Entity(ent)
						umsg.Short(self:EntIndex())
						umsg.Short(ent:EntIndex())
					umsg.End()
				end
				--self:SetNetworkedEntity("node", ent)
			end
		end
		ENT.GetResourceAmount = function(self,resource)
			if self.node then
				if self.node.resources[resource] then
					return self.node.resources[resource].value
				else
					return 0
				end
			else
				return 0
			end
		end
		ENT.Unlink = function(self)
			if self.node then
				self.resources = self.resources or {}
				if self.maxresources then
					for k,v in pairs(self.maxresources) do
						--print("Resource: "..k, "Amount: "..v)
						local amt = self:GetResourceAmount(k)
						if amt > v then
							amt = v
						end
						if self.node.resources[k] then
							self.node.resources[k].value = self.node.resources[k].value - amt
						end
						--print("Recovered: "..amt)
						self.resources[k] = amt
						--self:UpdateStorage(k)
					end
				end
				self.node.updated = true
				self.node:Unlink(self)
				self.node = nil
				self.client_updated = false

				umsg.Start("Env_SetNodeOnEnt")
					--umsg.Entity(self)
					--umsg.Entity(NullEntity())
					umsg.Short(self:EntIndex())
					umsg.Short(0)
				umsg.End()
			end
		end
	end
end

--################# What version is installed? @aVoN
local RD; -- QuickIndex
local IsThree;
function StarGate.RDThree()
	if(IsThree ~= nil) then return IsThree end;
	if(CAF and CAF.GetAddon("Resource Distribution")) then
		IsThree = true;
		RD = CAF.GetAddon("Resource Distribution");
		return true;
	end
	IsThree = false;
	return false;
end

local IsEnv;
function StarGate.RDEnv()
	if(IsEnv ~= nil) then return IsEnv end;
	if(Environments) then
		IsEnv = true;
		RD = Environments;
		return true;
	end
	IsEnv = false;
	return false;
end

-- Added by AlexALX for fix an error when installed broken rd2 or other energy addon
local IsTwo;
function StarGate.RDTwo()
	if(IsTwo ~= nil) then return IsTwo end;
	if(RD_AddResource!=nil) then
		IsTwo = true;
		return true;
	end
	-- update sents for prevent errors
	StarGate.HasResourceDistribution = false;
	for k,v in pairs(scripted_ents.GetList()) do
		if (v.HasRD) then
			v.HasRD = false;
			v.HasResourceDistribution = false;
		end
	end
	IsTwo = false;
	return false;
end

--################# OnRemove @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.OnRemove(self,only_rd,only_wire)
	if(self.HasRD and not only_wire) then
		if(StarGate.RDThree()) then
			if (self.IsNode) then
				RD.UnlinkAllFromNode(self.netid);
			else
				RD.Unlink(self.Entity); -- Lol, why someone not added this? Fix by AlexALX
			end
			RD.RemoveRDEntity(self.Entity);
		elseif(StarGate.RDEnv()) then
			self:Unlink()
		elseif(Dev_Unlink_All and self.resources2links) then
			Dev_Unlink_All(self.Entity);
		end
	end
	if(not only_rd and WireAddon and (self.Outputs or self.Inputs)) then
		Wire_Remove(self.Entity);
	end
end

--################# OnRestore @aVoN
function StarGate.WireRD.OnRestore(self)
	if(WireAddon) then
		Wire_Restored(self.Entity);
	end
end

--##############################
-- Wire handling
--##############################

--################# Creates Wire Outputs @aVoN
-- Allows special datatypes now. Valid are NORMAL,VECTOR,ANGLE,COLOR,ENTITY,STRING,TABLE,ANY,BIDIRTABLE,HOVERDATAPORT
function StarGate.WireRD.CreateWireOutputs(self,...)
	if(WireAddon) then
		local data = {};
		local types = {};
		for k,v in pairs({...}) do
			if(type(v) == "table") then
				types[k] = v.Type;
				data[k] = v.Name;
			else
				data[k] = v;
			end
		end
		--self.Outputs = Wire_CreateOutputs(self.Entity,{...}); -- Old way, kept if I need to revert
		self.Outputs = WireLib.CreateSpecialOutputs(self.Entity,data,types);
	end
end

--################# Creates Wire Inputs @aVoN
-- Allows special datatypes now. Valid are NORMAL,VECTOR,ANGLE,COLOR,ENTITY,STRING,TABLE,ANY,BIDIRTABLE,HOVERDATAPORT
function StarGate.WireRD.CreateWireInputs(self,...)
	if(WireAddon) then
		local data = {};
		local types = {};
		for k,v in pairs({...}) do
			if(type(v) == "table") then
				types[k] = v.Type;
				data[k] = v.Name;
			else
				data[k] = v;
			end
		end
		--self.Inputs = Wire_CreateInputs(self.Entity,{...}); -- Old way, kept if I need to revert
		self.Inputs = WireLib.CreateSpecialInputs(self.Entity,data,types);
	end
end

--################# Sets a Wire value @aVoN
function StarGate.WireRD.SetWire(self,key,value,inp)
	if(WireAddon) then
		if (inp) then
			-- Special interaction to modify datatypes
			if(self.Inputs and self.Inputs[key]) then
				local datatype = self.Inputs[key].Type;
				if(datatype == "NORMAL") then
					-- Supports bools and converts them to numbers
					if(value == true) then
						value = 1;
					elseif(value == false) then
						value = 0;
					end
					-- If still not a number, make it a num now!
					value = tonumber(value);
				elseif(datatype == "STRING") then
					value = tostring(value);
				end
			end
			if(value ~= nil) then
				WireLib.TriggerInput(self.Entity,key,value);
			end
		else
			-- Special interaction to modify datatypes
			if(self.Outputs and self.Outputs[key]) then
				local datatype = self.Outputs[key].Type;
				if(datatype == "NORMAL") then
					-- Supports bools and converts them to numbers
					if(value == true) then
						value = 1;
					elseif(value == false) then
						value = 0;
					end
					-- If still not a number, make it a num now!
					value = tonumber(value);
				elseif(datatype == "STRING") then
					value = tostring(value);
				end
			end
			if(value ~= nil) then
				WireLib.TriggerOutput(self.Entity,key,value);
				if(self.WireOutput) then
					self:WireOutput(key,value);
				end
			end
		end
	end
end

--################# Gets a Wire value @aVoN
function StarGate.WireRD.GetWire(self,key,default,out)
	if(WireAddon) then
		if (out) then
			if(self.Outputs and self.Outputs[key] and self.Outputs[key].Value) then
				return self.Outputs[key].Value or default or WireLib.DT[self.Outputs[key].Type].Zero;
			end
		else
			if(self.Inputs and self.Inputs[key] and self.Inputs[key].Value) then
				return self.Inputs[key].Value or default or WireLib.DT[self.Inputs[key].Type].Zero;
			end
		end
	end
	return default or 0; -- Error. Either wire is not installed or the input is not SET. Return the default value instead
end

--##############################
--  Resource Distribution Handling
--##############################

--################# Register a Resource @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.AddResource(self,resource,maximum,default)
	if(self.HasRD) then
		if(StarGate.RDThree()) then
			RD.AddResource(self.Entity,resource,maximum or 0,default or 0);
			--FIXME: Add LS3 registering here.
		elseif(StarGate.RDEnv()) then
			if not self.maxresources then self.maxresources = {} end
			if not self.resources then self.resources = {} end
			if (self.node) then
				if self.maxresources then
					for k,v in pairs(self.maxresources) do
						if (self.maxresources[k]>maximum) then
							--print("Resource: "..k, "Amount: "..v)
							local amt = self:GetResourceAmount(k)
							if amt > v then
								amt = v
							end
							if self.node.resources[k] then
								self.node.resources[k].value = self.node.resources[k].value - amt
							end
							--print("Recovered: "..amt)
							self.resources[k] = amt
							--self:UpdateStorage(k)
						end
					end
				end
				self.node.updated = true
			end
			self.maxresources[resource] = maximum or 0
			self.resources[resource] = default or 0
		elseif(StarGate.RDTwo()) then
			if(LS_RegisterEnt) then -- Register to life support
				if(not self.__RegisteredToLS) then
					self.__RegisteredToLS = true;
					LS_RegisterEnt(self.Entity,"Generator"); -- Always register this as a generator
				end
			end
			RD_AddResource(self.Entity,resource,maximum or 0);
		end
	end
end

--################# Get a Resource's ammount @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.GetResource(self,resource,default)
	if(self.HasRD) then
		if(StarGate.RDThree()) then
			return RD.GetResourceAmount(self.Entity,resource) or default or 0;
		elseif(StarGate.RDEnv()) then
			if self.node then
				if self.node.resources and self.node.resources[resource] then
					return self.node.resources[resource].value or default or 0;
				else
					return default or 0
				end
			else
				if self.resources then
					return self.resources[resource] or default or 0;
				end
				return default or 0
			end
		elseif(StarGate.RDTwo()) then
			return RD_GetResourceAmount(self.Entity,resource) or default or 0;
		end
	end
	return default or 0;
end

--################# Consume some of this resource @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.ConsumeResource(self,resource,ammount)
	if(self.HasRD) then
		if(StarGate.RDThree()) then
			return RD.ConsumeResource(self.Entity,resource,ammount or 0);
		elseif(StarGate.RDEnv()) then
			if self.node then
				return self.node:ConsumeResource(resource, ammount or 0);
			end
		elseif(StarGate.RDTwo()) then
			return RD_ConsumeResource(self.Entity,resource,ammount or 0);
		end
	end
end

--################# Supply a specific ammount to this resource @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.SupplyResource(self,resource,ammount)
	if(self.HasRD) then
		if(StarGate.RDThree()) then
			RD.SupplyResource(self.Entity,resource,ammount or 0);
		elseif(StarGate.RDEnv()) then
			ammount = math.ceil(ammount or 0) or 0
			if self.node then
				return self.node:GenerateResource(resource, ammount or 0)
			else
				if self.resources then
					self.resources[resource] = self.resources[resource] + ammount or 0
				end
			end
		elseif(StarGate.RDTwo()) then
			RD_SupplyResource(self.Entity,resource,ammount or 0);
		end
	end
end

--################# This units capacity @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.GetUnitCapacity(self,resource,default)
	if(self.HasRD) then
		if(StarGate.RDThree()) then
			return RD.GetUnitCapacity(self.Entity,resource) or default or 0;
		elseif(StarGate.RDEnv()) then
			return self.maxresources[resource] or default or 0;
		elseif(StarGate.RDTwo()) then
			return RD_GetUnitCapacity(self.Entity,resource) or default or 0;
		end
	end
	return default or 0;
end

--################# This networks capacity @aVoN
--added compatiblity with RD3 @JDM12989
function StarGate.WireRD.GetNetworkCapacity(self,resource,default)
	if(self.HasRD) then
		if(StarGate.RDThree()) then
			return RD.GetNetworkCapacity(self.Entity,resource) or default or 0;
		elseif(StarGate.RDEnv()) then
			if self.node then
				return self.node.maxresources[resource] or default or 0
			else
				if self.maxresources then
					return self.maxresources[resource]
				end
			end
			return default or 0
		elseif(StarGate.RDTwo()) then
			return RD_GetNetworkCapacity(self.Entity,resource) or default or 0;
		end
	end
	return default or 0;
end

-- Added by AlexALX for zpm hubs etc
function StarGate.WireRD.GetEntListTable(ent)
	if (not IsValid(ent)) then return {}; end
	if (StarGate.HasResourceDistribution) then
		if(StarGate.RDThree()) then
			local entTable = RD.GetEntityTable(ent);
			local netTable = RD.GetNetTable(entTable["network"]);
			return netTable["entities"] or {};
		elseif(StarGate.RDEnv()) then
			if (ent.node and ent.node.connected) then
				return ent.node.connected or {};
			end
			return {ent.Entity};
		elseif(StarGate.RDTwo()) then
			if (ent.resources2links==nil) then return {}; end
			local entTable = ent.resources2links or {};
			for k, v in pairs(entTable) do
				if IsValid(v) and v.resources2links then
					return v.resources2links or {};
				end
			end
			return {ent.Entity}; -- for single connections
		end
	end
	return {};
end

-- correct connected status displaying by AlexALX
function StarGate.WireRD.Connected(ent)
	if (not IsValid(ent)) then return false; end
	if (StarGate.HasResourceDistribution) then
		if(StarGate.RDThree()) then
			local entTable = RD.GetEntityTable(ent);
			if (entTable["network"] and entTable["network"]>0) then
				return true;
			end
		elseif(StarGate.RDEnv()) then
			if (ent.node and IsValid(ent.node)) then
				return true;
			end
		elseif(StarGate.RDTwo()) then
			if (ent.resources2links and table.Count(ent.resources2links)>0) then
				return true;
			end
		end
	end
	return false;
end

--##############################
--  Duplicator handling
--##############################

local function Environments_ApplyDupeInfo( ent, CreatedEntities, Player ) --add duping for cables
	if ent.EntityMods and ent.EntityMods.EnvDupeInfo then
		if ent.AdminOnly and !Player:IsAdmin() then //stops people from pasting admin only stuff
			ent:Remove()
			Player:ChatPrint("This device is admin only!")
		else
			local DupeInfo = ent.EntityMods.EnvDupeInfo
			--Environments.MakeFunc(ent) --yay
			if DupeInfo.Node then
				local node = CreatedEntities[DupeInfo.Node]
				if (IsValid(node)) then
					ent:Link(node, true)
					node:Link(ent, true)
				end
			end

			ent.env_extra = DupeInfo.extra

			local mat = DupeInfo.LinkMat
			local pos = DupeInfo.LinkPos
			local forward = DupeInfo.LinkForw
			local color = DupeInfo.LinkColor
			if mat and pos and forward then
				Environments.Create_Beam(ent, pos, forward, mat, color) --make work
			end
			ent.EntityMods.EnvDupeInfo = nil

			//set the player/owner
			--ent:SetPlayer(Player)
		end
	end
end

--################# Store Entity modifiers @aVoN
function StarGate.WireRD.PreEntityCopy(self)
	if(RD_BuildDupeInfo) then RD_BuildDupeInfo(self.Entity) end;
	if(RD and RD.BuildDupeInfo) then RD.BuildDupeInfo(self.Entity) end;
	if(WireAddon) then
		local data = WireLib.BuildDupeInfo(self.Entity);
		if(data) then
			duplicator.StoreEntityModifier(self.Entity,"WireDupeInfo",data);
		end
	end
end

--################# Restore entity modifiers @aVoN
function StarGate.WireRD.PostEntityPaste(self,Player,Ent,CreatedEntities)
	if(RD_ApplyDupeInfo) then RD_ApplyDupeInfo(Ent,CreatedEntities) end;
	if(not Environments and RD and RD.ApplyDupeInfo) then RD.ApplyDupeInfo(Ent,CreatedEntities) end;
	if(Environments) then Environments_ApplyDupeInfo(Ent,CreatedEntities,Player); end
	if(WireAddon) then
		if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
			WireLib.ApplyDupeInfo(Player,Ent,Ent.EntityMods.WireDupeInfo,function(id) return CreatedEntities[id] end);
		end
	end
end