/*
	Stargate Base Tool for GarrysMod10
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
--################# Header
-- Failsafes - Sometimes, the StarGate lib is loader after the stools <=> will cause some problems
if(StarGate==nil) then include("autorun/stargate.lua") end;
if(SGLanguage==nil or SGLanguage.GetMessage==nil) then include("autorun/language_lib.lua") end;
if (TOOL==nil) then return end -- wtf?
TOOL.Tab="Stargate";
TOOL.AddToMenu = false; -- Tell gmod not to add it. We will do it manually later!
TOOL.Command=nil;
TOOL.ConfigName="";

TOOL.Entity = {
	Angle=Angle(0,0,0), -- Angle offset?
	Keys={}, -- These keys will be saved by the duplicator on a copy
	Class="prop_physics", -- Default SENT to spawn
	Limit=1000, -- Limits? - With the words of catdaemon: Lol, wut?
};
TOOL.Topic = {};
TOOL.Language = {};
TOOL.Models = {};
TOOL.GhostExceptions = {}; -- Add your entity class to this, to stop drawing the GhostPreview on this

--################# Registers the STOOL to the stargate code @aVoN
function TOOL:Register()
	-- Retrieve a "list" and allocate it's contents to self.Models (for backwards compatibility) - You can either use the "list" module of garry or TOOL.Models. Not both at once!
	if(self.List) then
		self.Models = list.GetForEdit(self.List);
	end
	-- Register language clientside
	local class = self.Entity.Class; -- Quick reference
	if(self.Language["Cleanup"]) then
		cleanup.Register(class or self.Mode);
	end
	list.Set("CAP.Tool",self.Mode,self);
	if CLIENT then
		local d = ".";
		for k,v in pairs(self.Topic) do
			language.Add("Tool"..d..self.Mode..d..k,v);
		end
		for k,v in pairs(self.Language) do
			language.Add(k.."_"..(class or self.Mode),v);
		end
		if(self.ControlsPanel) then
			self.BuildCPanel = function(Panel)
				if (StarGate.CFG:Get("cap_disabled_tool",self.Mode,false)) then
					Panel:Help(SGLanguage.GetMessage("stool_disabled_tool"));
					return
				end
				-- Add the HELP, if Internet is applied!
				if(StarGate.HasInternet and self.Mode) then
					local VGUI = vgui.Create("SHelpButton",Panel);
					VGUI:SetHelp("stools/#"..self.Mode);
					VGUI:SetTopic("Help: Tools - "..(self.Name or class));
					Panel:AddPanel(VGUI);
				end
				self.ControlsPanel(self,Panel); -- Run our Controls Panel Hook!
			end
		end
	end
	-- Add the SG Spawner code to the ToolObject
	if SERVER then	
		if(class) then
			CreateConVar("sbox_max"..class,self.Entity.Limit);
			if (self.Entity.Limits) then
				for k,v in pairs(self.Entity.Limits) do
					CreateConVar("sbox_max"..k,v);
				end
			end
			-- First, we register the SENT to the stargate spawning code
			if (StarGate.TOOL and not self.CustomSpawnCode) then StarGate.TOOL.CreateSpawner(class,unpack(self.Entity.Keys or {})); end -- Creates the spawner
			self.SpawnSENT = function(self,p,trace,...)
				if (StarGate_Group and StarGate_Group.Error == true) then StarGate_Group.ShowError(p); return
				elseif (StarGate_Group==nil or StarGate_Group.Error==nil) then
					Msg("Carter Addon Pack - Unknown Error\n");
					p:SendLua("Msg(\"Carter Addon Pack - Unknown Error\\n\")");
					p:SendLua("GAMEMODE:AddNotify(\"Carter Addon Pack: Unknown Error\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
					return;
				end
				if (StarGate.NotSpawnable(self.Mode,p,"tool") ) then return end
				-- Now, spawn the SENT
				if (StarGate.TOOL) then
					local e = StarGate.TOOL.Entities[class].func(p,Angle(),trace.HitPos,...);
					self:SetPositionAndAngles(e,trace);
					-- Eyecandy for your suckers
					if(DoPropSpawnedEffect) then
						DoPropSpawnedEffect(e);
					end
					return e;
				else
					return NULL;
				end
			end
			-- We have a PreEntitySpawn function - Register it to the StarGate SentSpawn class
			if(self.PreEntitySpawn and StarGate.TOOL) then
				StarGate.TOOL.Entities[class].PreEntitySpawn = function(p,e,...)
					if (StarGate_Group and StarGate_Group.Error == true) then StarGate_Group.ShowError(p); return
					elseif (StarGate_Group==nil or StarGate_Group.Error==nil) then
						Msg("Carter Addon Pack - Unknown Error\n");
						p:SendLua("Msg(\"Carter Addon Pack - Unknown Error\\n\")");
						p:SendLua("GAMEMODE:AddNotify(\"Carter Addon Pack: Unknown Error\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
						e:Remove();
						return;
					end
					if (StarGate.NotSpawnable(self.Mode,p,"tool") ) then e:Remove(); return end
					self.PreEntitySpawn(self,p,e,...);
				end
			end
			-- We have a PostEntitySpawn function - Register it to the StarGate SentSpawn class
			if(self.PostEntitySpawn and StarGate.TOOL) then
				StarGate.TOOL.Entities[class].PostEntitySpawn = function(p,e,...)
					self.PostEntitySpawn(self,p,e,...);
				end
			end
		end
	end
end

--################# Returns all setting's Names in TOOL.ClientConVar @aVoN
function TOOL:GetSettingsNames()
	local t = {};
	for k,_ in pairs(self.ClientConVar) do
		table.insert(t,self.Mode.."_"..k);
	end
	return t;
end

--################# Gets all default settings by key and value
function TOOL:GetDefaultSettings()
	local t = {};
	for k,v in pairs(self.ClientConVar) do
		t[self.Mode.."_"..k] = v;
	end
	return t;
end

--#########################################
--						Cleanups and Limits
--#########################################

--################# Adds an undo event @aVoN
function TOOL:AddUndo(p,...)
	undo.Create(self.Entity.Class or self.Mode);
	for k,v in pairs({...}) do
		if(k ~= "n") then
			undo.AddEntity(v)
		end
	end
	undo.SetPlayer(p);
	undo.Finish();
end

--################# Adds entities to cleanup @aVoN
function TOOL:AddCleanup(p,...)
	for k,v in pairs({...}) do
		if(k ~= "n") then
			p:AddCleanup(self.Entity.Class or self.Mode,v);
		end
	end
end

--################# Quick reference for CheckLimit @aVoN
function TOOL:CheckLimit()
	return self:GetSWEP():CheckLimit(self.Entity.Class);
end

--################# First is the new SENT, second the one we shot. Last one means "weld" (true) or "dont weld" (false) @aVoN
function TOOL:Weld(e,e2,weld)
	if(not IsValid(e)) then return end;
	if(weld and IsValid(e2)) then
		--if(not IsValid(e2)) then e2 = game.GetWorld() end;
		local c = constraint.Weld(e,e2,0,0,0,true);
		if(IsValid(e2)) then e2:DeleteOnRemove(e) end;
		return c;
	end
	local phys = e:GetPhysicsObject();
	if(phys:IsValid()) then
		phys:EnableMotion(false);
	end
end

--#########################################
--						Resource Distribution
--#########################################

--################# Automatically links two SENTs, when they use Resource Distribution if installed @aVoN
function TOOL:AutoLink(e1,e2)
	if(not StarGate.HasResourceDistribution) then return end
	-- Is resource distribution installed?
	if(e1 and e2 and e1:IsValid() and e2:IsValid() and e1 ~= e2) then
		if (Dev_Link) then
			-- First is for RD1, second for RD2
			local e1_res = e1.resources or e1.resources2;
			local e2_res = e2.resources or e2.resources2;
			if(e1_res and e2_res) then
				-- Devices needs that power?
				local match = false;
				for _,res1 in pairs(e1_res) do
					for _,res2 in pairs(e2_res) do
						if (res1.res_ID == res2.res_ID) then
							match = true;
							break;
						end
					end
					if(match) then break end;
				end
				if(not match) then return end;
				-- Devide already linked with that (Normally not, but just to be sure)?
				for _,res in pairs(e1_res) do
					for _,v in pairs(res.links) do
						if (e2 == v.ent) then
							return;
						end
					end
				end
				-- Create an invisible link
				Dev_Link(e1,e2,e1:GetPos(),e2:GetPos(),"cable/cable2",Color(0,0,0,0),0);
			end
		elseif (CAF and CAF.GetAddon("Resource Distribution")) then
			local RD = CAF.GetAddon("Resource Distribution");
			if (RD and e2.IsNode) then
				RD.Link(e1,e2.netid);
			end
		elseif (Environments) then
			if (e2.IsNode) then
				e1:Link(e2);
				e2:Link(e1);
			end
		end
	end
end

--#########################################
--						Ghost entities
--#########################################

--################# Sets position and angles using the trace we got @aVoN
function TOOL:SetPositionAndAngles(e,trace)
	local mdl = self:GetClientInfo("model"):gsub("[\\]","/");
	local ang = trace.HitNormal:Angle()+self.Entity.Angle;
	ang.p = (ang.p+90) % 360; -- Correct this little default Anglepitch!
	-- Special Angle Offset? Do this first
	if(self.Models[mdl] and self.Models[mdl].Angle) then
		ang = ang+self.Models[mdl].Angle;
	end
	-- Now, rotate the prop around the surface normal (but only do this, if we hit some "ground" (not a on a wall - this looks strange and sometimes sucks!)
	if(math.abs(trace.HitNormal:Dot(Vector(0,0,1))) >= 1/math.sqrt(2)) then -- angle is smaller than 45° degree
		ang:RotateAroundAxis(trace.HitNormal,self:GetOwner():GetAimVector():Angle().y + 180);
	end
	e:SetAngles(ang);
	e:SetPos(trace.HitPos-trace.HitNormal*e:OBBMins().z);
	-- Add offset (if required by the model)
	if(self.Models[mdl] and self.Models[mdl].Position) then
		e:SetPos(e:LocalToWorld(self.Models[mdl].Position));
	end
end

--################# Updates the GhostPreview for the SENT @aVoN
function TOOL:UpdateGhostSENT(e,p)
	if(not (self.Entity.Class and IsValid(e))) then return end;
	local trace = util.TraceLine(util.GetPlayerTrace(p,p:GetAimVector()))
	if(not trace.Hit) then return end;
	self:SetPositionAndAngles(e,trace);
	if(IsValid(trace.Entity)) then
		local class = trace.Entity:GetClass();
		if(trace.Entity:IsPlayer() or (class == self.Entity.Class or table.HasValue(self.GhostExceptions,class))) then
			e:SetNoDraw(true);
		end
		return;
	end
	e:SetNoDraw(false);
end

--################# Draws the GhostEntity @aVoN
function TOOL:DrawGhostEntity()
	local mdl = self:GetClientInfo("model");
	if(IsValid(self.GhostEntity)) then
		if(self.GhostEntity:GetModel() ~= mdl) then
			self:MakeGhostEntity(mdl,Vector(0,0,0),Angle(0,0,0));
		end
	else
		if(mdl and mdl ~= "") then
			self:MakeGhostEntity(mdl,Vector(0,0,0),Angle(0,0,0));
		end
	end
	self:UpdateGhostSENT(self.GhostEntity,self:GetOwner());
end
function TOOL:Think() self:DrawGhostEntity() end;
