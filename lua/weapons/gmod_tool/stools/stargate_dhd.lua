/*
	Shield Spawner for GarrysMod10
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
TOOL.Name=SGLanguage.GetMessage("stool_mdhd");

--TOOL.ClientConVar["autolink"] = 1; -- No lifesupport added yet
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["toggle"] = KEY_PAD_6;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/props_c17/clock01.mdl";
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "MobileDHDModels"; -- The listname of garrys "List" Module we use for models
list.Set(TOOL.List,"models/props_docks/dock01_cleat01a.mdl",{});
list.Set(TOOL.List,"models/props_junk/plasticbucket001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{});
list.Set(TOOL.List,"models/props_c17/clock01.mdl",{});
list.Set(TOOL.List,"models/props_combine/breenclock.mdl",{});
list.Set(TOOL.List,"models/props_combine/breenglobe.mdl",{});
list.Set(TOOL.List,"models/props_interiors/pot01a.mdl",{});
list.Set(TOOL.List,"models/props_junk/metal_paintcan001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{});
list.Set(TOOL.List,"models/props_c17/computer01_keyboard.mdl",{});
list.Set(TOOL.List,"models/props_lab/keypad.mdl",{Angle=Angle(-90,0,0),Position=Vector(-5,0,0)});
list.Set(TOOL.List,"models/props_combine/breenconsole.mdl",{Angle=Angle(0,90,0)});
list.Set(TOOL.List,"models/zsdaniel/atlantis-dhd/dhd.mdl",{});
--list.Set(TOOL.List,"models/micropro/atlantisdhd/atlantis_dhd.mdl",{});
list.Set(TOOL.List,"models/iziraider/kinoremote/w_kinoremote.mdl",{});

-- Information about the SENT to spawn
TOOL.Entity.Class = "mobile_dhd";
TOOL.Entity.Keys = {"toggle","model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 3; -- A person generally can spawn 1 mobile dhd

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_stargate_dhd_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_stargate_dhd_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_stargate_dhd_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_stargate_dhd_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_stargate_dhd_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_stargate_dhd_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_stargate_dhd_limit");
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local toggle = self:GetClientNumber("toggle");
	local model = self:GetClientInfo("model");
	--######## Spawn SENT
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return true; -- We have nothing to update a mobile DHD
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,toggle,model);
	--[[ -- No life support added yet
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity); -- Link to that energy system, if valid
	end
	--]]
	--######## Weld things?
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,toggle,model)
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,toggle,model)
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleDHDMenu",e);
	end
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	/*Panel:AddControl("ComboBox",{
		Label="Presets",
		MenuButton=1,
		Folder="stargate_dhd",
		Options={
			Default=self:GetDefaultSettings(),
		},
		CVars=self:GetSettingsNames(),
	});*/
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_toggle"),
		Command="stargate_dhd_toggle",
	});
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="stargate_dhd_model",Category="",Models=self.Models});
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"stargate_dhd_autoweld");
	--[[ -- No LifeSupport added yet
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"stargate_dhd_autolink"):SetToolTip(SGLanguage.GetMessage("stool_autolink_desc"));
	end
	--]]
end

--################# Numpad bindings
if SERVER then
	numpad.Register("ToggleDHDMenu",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:OpenMenu(p);
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();