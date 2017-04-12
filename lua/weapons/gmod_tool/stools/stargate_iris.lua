/*
	Iris Spawn Tool for GarrysMod10
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
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");
TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_iris");

--TOOL.ClientConVar["autolink"] = 1;
--TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["toggle"] = 9;
TOOL.ClientConVar["activate"] = 12;
TOOL.ClientConVar["deactivate"] = StarGate.KeyEnter;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/zup/Stargate/iris.mdl";
TOOL.GhostExceptions = {"stargate_atlantis","stargate_sg1","stargate_tollan","stargate_infinity","stargate_universe","stargate_ori"}; -- Add your entity class to this, to stop drawing the GhostPreview on this
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "StargateIrisModels"; -- The listname of garrys "List" Module we use for models
list.Set(TOOL.List,"models/zup/Stargate/iris.mdl",{});
list.Set(TOOL.List,"models/zup/Stargate/sga_shield.mdl",{}); -- I hexed the Eventhorizon model to use a new material
if (file.Exists("models/cos/Stargate/iris.mdl","GAME")) then
	list.Set(TOOL.List,"models/cos/Stargate/iris.mdl",{});
end

-- Information about the SENT to spawn
TOOL.Entity.Class = "stargate_iris";
TOOL.Entity.Keys = {"model","toogle","activate","deactivate","IsActivated"}; -- These keys will get saved from the duplicator
-- The default offset Angle, the sent should additional rotated - For Ghostpreview, when something looks strange
-- Optionally you can also do this for special models in TOOL.Models. E.g. ["my_model"] = {Angle=Angle(1,2,3)},
TOOL.Entity.Limit = 10;

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_stargate_iris_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_stargate_iris_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_stargate_iris_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_stargate_iris_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_stargate_iris_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_stargate_iris_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_stargate_iris_limit");
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	if(not IsValid(t.Entity) or not t.Entity.IsStargate) then
	    p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_stargate_iris_err\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	    return
	end
	if(t.Entity.IsSupergate or t.Entity:GetClass()=="stargate_orlin") then
	    p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_stargate_iris_err2\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	    return
	end
	if (t.Entity.GateSpawnerSpawned and StarGate.CFG and not StarGate.CFG:Get("stargate_iris","gatespawner",true)) then
	    p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_stargate_iris_err3\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end
	--######## Spawn SENT
	local toggle = self:GetClientNumber("toggle");
	local activate = self:GetClientNumber("activate");
	local deactivate = self:GetClientNumber("deactivate");
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model,toggle,activate,deactivate);
	if (not IsValid(e)) then return end
	if(IsValid(t.Entity) and t.Entity.IsStargate) then
		for _,v in pairs(ents.FindInSphere(t.Entity:GetPos(),10)) do
			if(v.IsIris and v ~= e) then
				if (v.GateSpawnerSpawned) then
					e:Remove();
					p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"iris_gatespawner\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
					return
				else
					v:Remove(); -- Remove old, existing iri's (replace them with this new one)
				end
			end
		end
		e:SetPos(t.Entity:GetPos()+t.Entity:GetForward()*0.4); -- A little offset, or you can see the EH through iris/shield (ugly!)
		e:SetAngles(t.Entity:GetAngles());
	end
	e.GateLink = t.Entity;
	if (t.Entity.GateSpawnerSpawned) then
		p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"iris_protection\"), NOTIFY_GENERIC, 5); surface.PlaySound( \"buttons/button9.wav\" )");
		e:IrisProtection();
	end
	e:Toggle(true); -- Always spawn an iris/shield closed! (true means close no matter if we have not enough energy)
	--[[
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity); -- Link to that energy system, if valid
	end
	--]]
	--######## Weld things?
	local c = self:Weld(e,t.Entity,true);
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,model,toggle,activate,deactivate,IsActivated)
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,model,toggle,activate,deactivate,IsActivated)
	if(not IsValid(e)) then return end;
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleIris",e);
	end
	if(activate) then
		numpad.OnDown(p,activate,"ActivateIris",e);
	end
	if(deactivate) then
		numpad.OnDown(p,deactivate,"DeActivateIris",e);
	end
	if((IsActivated and not e.IsActivated) or (not IsActivated and e.IsActivated)) then
		e:Toggle();
	end
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_toggle"),
		Command="stargate_iris_toggle",
	});
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_activate"),
		Command="stargate_iris_activate",
		Label2=SGLanguage.GetMessage("stool_deactivate"),
		Command2="stargate_iris_deactivate",
	});
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="stargate_iris_model",Category="",Models=self.Models});
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"stargate_iris_autoweld");
	--[[
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"stargate_iris_autolink"):SetToolTip(SGLanguage.GetMessage("stool_autolink_desc"));
	end
	--]]
end

--################# Numpad bindings
if SERVER then
	numpad.Register("ToggleIris",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:Toggle();
		end
	);
	numpad.Register("ActivateIris",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(not e.IsActivated) then e:Toggle() end;
		end
	);
	numpad.Register("DeActivateIris",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(e.IsActivated) then e:Toggle() end;
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();