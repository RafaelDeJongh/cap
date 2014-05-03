/*
	Wraith Harveserfor GarrysMod10
	Copyright (C) 2007  Catdaemon

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

-- The original Warithharvester spawntool code has been replaced with this version which has fully stargatepack support.

--################# Header
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_harvester");

-- CliebtConVars
TOOL.ClientConVar["spit"] = 2;
TOOL.ClientConVar["suck"] = 1;
TOOL.ClientConVar["always_down"] = 0;
TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
-- The default model for the GhostPreview
if (file.Exists("models/props_c17/pottery03a.mdl","GAME")) then
	TOOL.ClientConVar["model"] = "models/props_c17/pottery03a.mdl";
else
	TOOL.ClientConVar["model"] = "models/props_c17/lampshade001a.mdl";
end
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "StargateHarvesterModels"; -- The listname of garrys "List" Module we use for models
if (file.Exists("models/props_c17/pottery03a.mdl","GAME")) then
	list.Set(TOOL.List,"models/props_c17/pottery03a.mdl",{});
end
if (file.Exists("models/props_c17/pottery05a.mdl","GAME")) then
	list.Set(TOOL.List,"models/props_c17/pottery05a.mdl",{});
end
list.Set(TOOL.List,"models/combine_helicopter/helicopter_bomb01.mdl",{});
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{});
list.Set(TOOL.List,"models/props_c17/lampshade001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/metalbucket02a.mdl",{});
list.Set(TOOL.List,"models/props_junk/sawblade001a.mdl",{});
list.Set(TOOL.List,"models/props_trainstation/trainstation_clock001.mdl",{});

-- Information about the SENT to spawn
TOOL.Entity.Class = "wraith_harvester";
TOOL.Entity.Keys = {"spit","suck","always_down","model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 1; -- Spawnlimit

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_wraith_harvester_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_wraith_harvester_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_wraith_harvester_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_wraith_harvester_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_wraith_harvester_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_wraith_harvester_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_wraith_harvester_limit");
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local always_down = self:GetClientNumber("always_down");
	-- Update!
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		t.Entity:SetNetworkedBool("always_down",util.tobool(always_down));
		-- THIS FUNCTIONS SAVES THE MODIFIED KEYS TO THE SENT, SO THEY ARE AVAILABLE WHEN COPIED WITH DUPLICATOR!
		t.Entity:UpdateKeys(_,_,always_down,_);
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local suck = self:GetClientNumber("suck");
	local spit = self:GetClientNumber("spit");
	local model = self:GetClientInfo("model");
	--######## Spawn SENT
	local e = self:SpawnSENT(p,t,suck,spit,always_down,model);
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity); -- Link to that energy system, if valid
	end
	--######## Weld things?
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,suck,spit,always_down,model)
	local model = model or self.ClientConVar["model"]; -- Failsafe for older saves by the Duplicator - model selection just have been recently added
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,suck,spit,always_down,model)
	-- For some reasons, Catdaemons harvester seems to switch suck an spit, even when it's in the same order saved with adv dupe
	-- Lets correct this here (no model KV given means, it's from Catdaemon)
	if(not model) then
		local old_suck = suck;
		suck = spit;
		spit = old_suck;
	end
	if(suck) then
		numpad.OnDown(p,suck,"HarvSuckOn",e);
		numpad.OnUp(p,suck,"HarvSuckOff",e);
	end
	if(spit) then
		numpad.OnDown(p,spit,"HarvSpit",e);
	end
	e:SetNWBool("always_down",util.tobool(always_down));
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_wraith_harvester_suck"),
		Command="wraith_harvester_suck",
		Label2=SGLanguage.GetMessage("stool_wraith_harvester_spit"),
		Command2="wraith_harvester_spit",
	});
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="wraith_harvester_model",Category="",Models=self.Models});
	Panel:CheckBox(SGLanguage.GetMessage("stool_wraith_harvester_beam"),"wraith_harvester_always_down");
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"wraith_harvester_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"wraith_harvester_autolink"):SetToolTip(SGLanguage.GetMessage("stool_autolink_desc"));
	end
end

--################# Numpad shoot bindings - Only for the server
if SERVER then
	numpad.Register("HarvSuckOn",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:AcceptInput("on"); -- I need to keep this for compatibility reasons, when someone has Catdaemons original SENT installed
		end
	);
	numpad.Register("HarvSuckOff",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:AcceptInput("off"); -- I need to keep this for compatibility reasons, when someone has Catdaemons original SENT installed
		end
	);
	numpad.Register("HarvSpit",
		function(p,e)
			if(not e:IsValid()) then return false end
			e:Spit();
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();