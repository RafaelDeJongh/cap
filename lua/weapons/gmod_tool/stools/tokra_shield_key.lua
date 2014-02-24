/*
	Tokra Shield Controller
	Copyright (C) 2012  Madman07
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_tshieldc");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/Madman07/tokra_shield/controller.mdl";

TOOL.Entity.Class = "tokra_key";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = StarGate.CFG:Get("tokra_shield_key","limit",1);
TOOL.Topic["name"] = "Tokra Shield Controller Spawner";
TOOL.Topic["desc"] = "Creates a Tokra Shield Controller";
TOOL.Topic[0] = "Left click, to spawn Tokra Shield Controller";
TOOL.Language["Undone"] = "Tokra Shield Controller removed";
TOOL.Language["Cleanup"] = "Tokra Shield Controllers";
TOOL.Language["Cleaned"] = "Removed all Tokra Shield Controllers";
TOOL.Language["SBoxLimit"] = "Hit the Tokra Shield Controllers limit";

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
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"tokra_shield_key_autoweld");
end

TOOL:Register();