/*
	Cloaking Spawner for GarrysMod10
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
TOOL.Category="Tech"
TOOL.Name=SGLanguage.GetMessage("stool_cloak");

TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["immunity"] = 0;
TOOL.ClientConVar["size"] = 1;
TOOL.ClientConVar["attached"] = 1;
TOOL.ClientConVar["toggle"] = 3;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/props_c17/clock01.mdl";
TOOL.ClientConVar["phase_shift"] = 0;
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "StargateCloakModels"; -- The listname of garrys "List" Module we use for models
list.Set(TOOL.List,"models/props_combine/weaponstripper.mdl",{Angle=Angle(-90,0,0),Position=Vector(15,0,-60)});
list.Set(TOOL.List,"models/props_docks/dock01_cleat01a.mdl",{});
list.Set(TOOL.List,"models/props_junk/plasticbucket001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{});
list.Set(TOOL.List,"models/props_trainstation/trashcan_indoor001a.mdl",{});
list.Set(TOOL.List,"models/props_c17/clock01.mdl",{});
if (file.Exists("models/props_c17/pottery08a.mdl","GAME")) then
	list.Set(TOOL.List,"models/props_c17/pottery08a.mdl",{});
end
list.Set(TOOL.List,"models/props_combine/breenclock.mdl",{});
list.Set(TOOL.List,"models/props_combine/breenglobe.mdl",{});
list.Set(TOOL.List,"models/props_interiors/pot01a.mdl",{});
list.Set(TOOL.List,"models/props_junk/metal_paintcan001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{});

-- Information about the SENT to spawn
TOOL.Entity.Class = "cloaking_generator";
TOOL.Entity.Keys = {"toggle_cloak","model","size","immunity","phase_shift","attached"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 1;

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_stargate_cloaking_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_stargate_cloaking_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_stargate_cloaking_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_stargate_cloaking_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_stargate_cloaking_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_stargate_cloaking_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_stargate_cloaking_limit");
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local toggle = self:GetClientNumber("toggle");
	local model = self:GetClientInfo("model");
	local size = self:GetClientNumber("size");
	local immunity = self:GetClientNumber("immunity");
	local phase_shift = self:GetClientNumber("phase_shift");
	local attached = util.tobool(self:GetClientNumber("attached"));
	--######## Spawn SENT
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		t.Entity:SetSize(size);
		t.Entity.CloakAttached = util.tobool(attached);
		t.Entity.ImmuneOwner = false;
		t.Entity.PhaseShifting = util.tobool(phase_shift);
		if(util.tobool(immunity)) then
			t.Entity.ImmuneOwner = true;
		end
		-- Make changes take effect immediately, when shield is turned on
		if(t.Entity:Enabled()) then
			t.Entity:Status(false,true);
			local e = t.Entity;
			timer.Simple(0.3,
				function()
					if(e and e:IsValid()) then
						e:Status(true,true);
					end
				end
			);
		end
		-- THIS FUNCTIONS SAVES THE MODIFIED KEYS TO THE SENT, SO THEY ARE AVAILABLE WHEN COPIED WITH DUPLICATOR!
		t.Entity:UpdateKeys(_,_,size,immunity,phase_shift,attached);
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,toggle,model,size,immunity,phase_shift,attached);
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
function TOOL:PreEntitySpawn(p,e,toggle,model,size,immunity,phase_shift,attached)
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,toggle,model,size,immunity,phase_shift,attached)
	if(util.tobool(immunity)) then
		e.ImmuneOwner = true;
	end
	if(attached == nil) then
		e.CloakAttached = true;
	else
		e.CloakAttached = attached;
	end
	e.PhaseShifting = util.tobool(phase_shift);
	e:SetSize(size or 80);
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleCloaking",e);
	end
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	Panel:AddControl("Slider",{Label=SGLanguage.GetMessage("stool_size"),Type="Integer",Min=1,Max=1000,Command="stargate_cloaking_size"});
	Panel:AddControl("Label",{Text=SGLanguage.GetMessage("stool_stargate_cloaking_note")});
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_toggle"),
		Command="stargate_cloaking_toggle",
	});
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="stargate_cloaking_model",Category="",Models=self.Models});
	Panel:CheckBox(SGLanguage.GetMessage("stool_stargate_cloaking_ow"),"stargate_cloaking_immunity"):SetToolTip(SGLanguage.GetMessage("stool_stargate_cloaking_ow_desc"));
	Panel:CheckBox(SGLanguage.GetMessage("stool_stargate_cloaking_nc"),"stargate_cloaking_phase_shift"):SetToolTip(SGLanguage.GetMessage("stool_stargate_cloaking_nc_desc"));
	Panel:CheckBox(SGLanguage.GetMessage("stool_stargate_cloaking_ca"),"stargate_cloaking_attached"):SetToolTip(SGLanguage.GetMessage("stool_stargate_cloaking_ca_desc"))
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"stargate_cloaking_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"stargate_cloaking_autolink"):SetToolTip(SGLanguage.GetMessage("stool_autolink_desc"));
	end
end

--################# Numpad bindings
if SERVER then
	numpad.Register("ToggleCloaking",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(e:Enabled()) then
				e:Status(false);
			else
				e:Status(true);
			end
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();