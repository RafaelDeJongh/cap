/*
	Door Controller
	Copyright (C) 2011  Madman07
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_door_c");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/Iziraider/destinybutton/destinybutton.mdl";
TOOL.List = "ControllerModels";
list.Set(TOOL.List,"models/Iziraider/destinybutton/destinybutton.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/buttons/atlantis_button.mdl",{});

TOOL.Entity.Class = "cap_doors_contr";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = StarGate.CFG:Get("cap_doors_controller","limit",10);
TOOL.Topic["name"] = "Door Controller Spawner";
TOOL.Topic["desc"] = "Creates a Door Controller";
TOOL.Topic[0] = "Left click, to spawn or update a Door Controller";
TOOL.Language["Undone"] = "Door Controller removed";
TOOL.Language["Cleanup"] = "Door Controllers";
TOOL.Language["Cleaned"] = "Removed all Door Controllers";
TOOL.Language["SBoxLimit"] = "Hit the Door Controllers limit";

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

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label="Model",ConVar="cap_door_contr_model",Category="",Models=self.Models});
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"cap_door_contr_autoweld");
end

TOOL:Register();