/*
	Console
	Copyright (C) 2011  Madman07
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_console");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/MarkJaw/ancient_console/console.mdl";
TOOL.List = "ConsoleModels";
list.Set(TOOL.List,"models/MarkJaw/atlantis_console/console.mdl",{});
list.Set(TOOL.List,"models/ZsDaniel/atlantis_console/console.mdl",{});

TOOL.Entity.Class = "cap_console";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 50;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_cappanel_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_cappanel_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_cappanel_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_cappanel_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_cappanel_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_cappanel_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_cappanel_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model);
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model,toggle)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="cappanel_model",Category="",Models=self.Models});
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"cappanel_autoweld");
end

TOOL:Register();