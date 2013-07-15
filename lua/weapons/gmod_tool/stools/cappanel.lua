/*
	Console
	Copyright (C) 2011  Madman07
*/
if (not StarGate.CheckModule("devices")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=Language.GetMessage("stool_console");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/MarkJaw/ancient_console/console.mdl";
TOOL.List = "ConsoleModels";
list.Set(TOOL.List,"models/MarkJaw/atlantis_console/console.mdl",{});
list.Set(TOOL.List,"models/ZsDaniel/atlantis_console/console.mdl",{});

TOOL.Entity.Class = "cap_console";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = StarGate.CFG:Get("cap_console","limit",50);
TOOL.Topic["name"] = "Console Spawner";
TOOL.Topic["desc"] = "Creates a Console";
TOOL.Topic[0] = "Left click, to spawn or update a Console";
TOOL.Language["Undone"] = "Console removed";
TOOL.Language["Cleanup"] = "Consoles";
TOOL.Language["Cleaned"] = "Removed all Consoles";
TOOL.Language["SBoxLimit"] = "Hit the Consoles limit";

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
	Panel:AddControl("PropSelect",{Label="Model",ConVar="cappanel_model",Category="",Models=self.Models});
	Panel:CheckBox(Language.GetMessage("stool_autoweld"),"cappanel_autoweld");
end

TOOL:Register();