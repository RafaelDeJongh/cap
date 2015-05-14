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
TOOL.Name=SGLanguage.GetMessage("stool_light");

TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["brightness"] = StarGate.CFG:Get("atlantis_light","max_brightness",5);
TOOL.ClientConVar["size"] = StarGate.CFG:Get("atlantis_light","max_size",400);
TOOL.ClientConVar["r"] = 255;
TOOL.ClientConVar["g"] = 255;
TOOL.ClientConVar["b"] = 255;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/Madman07/wall_decoration/decoration1.mdl";
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "StargateAtlantisLights"; -- The listname of garrys "List" Module we use for models
list.Set(TOOL.List,"models/Madman07/wall_decoration/decoration1.mdl",{}); -- Thanks micropro for this model!
list.Set(TOOL.List,"models/Madman07/wall_decoration/decoration2.mdl",{});
list.Set(TOOL.List,"models/Madman07/wall_decoration/decoration3.mdl",{});

-- Information about the SENT to spawn
TOOL.Entity.Class = "atlantis_light";
TOOL.Entity.Keys = {"brightness","model","r","g","b","size"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 10; -- A person generally can spawn 1 shield

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_atlantis_light_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_atlantis_light_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_atlantis_light_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_atlantis_light_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_atlantis_light_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_atlantis_light_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_atlantis_light_limit");
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();

	local model = self:GetClientInfo("model");
	local brightness = self:GetClientNumber("brightness");
	local size = self:GetClientNumber("size");
	local r = self:GetClientNumber("r");
	local g = self:GetClientNumber("g");
	local b = self:GetClientNumber("b");

	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then

		t.Entity:SetLightColour(r,g,b);
		t.Entity:SetBrightness(brightness);
		t.Entity:SetLightSize(size);
		-- THIS FUNCTIONS SAVES THE MODIFIED KEYS TO THE SENT, SO THEY ARE AVAILABLE WHEN COPIED WITH DUPLICATOR!
		t.Entity:UpdateKeys(_,_,brightness,model,r,g,b,size);
		return true;
	end

	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,brightness,model,r,g,b,size);
	--######## Spawn SENT

	--######## Weld things?
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,brightness,model,r,g,b,size)
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,brightness,model,r,g,b,size)
	
	e:SetBrightness(brightness);
	e:SetLightColour(r,g,b);
	e:SetLightSize(size);
	
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	
	Panel:NumSlider(SGLanguage.GetMessage("stool_brightness"),"atlantis_light_brightness",1,StarGate.CFG:Get("atlantis_light","max_brightness",5),0);
	Panel:NumSlider(SGLanguage.GetMessage("stool_size"),"atlantis_light_size",10,StarGate.CFG:Get("atlantis_light","max_size",1000),0);

	Panel:AddControl("Color",{
		Label = SGLanguage.GetMessage("stool_atlantis_light_colour"),
		Red = "atlantis_light_r",
		Green = "atlantis_light_g",
		Blue = "atlantis_light_b",
		ShowAlpha = 0,
		ShowHSV = 1,
		ShowRGB = 1,
		Multiplier = 255,
	});
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="atlantis_light_model",Category="",Models=self.Models});
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"atlantis_light_autoweld");

end


--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();