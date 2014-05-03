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
TOOL.Entity.Limit = 1;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_tokra_shield_key_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_tokra_shield_key_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_tokra_shield_key_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_tokra_shield_key_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_tokra_shield_key_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_tokra_shield_key_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_tokra_shield_key_limit");

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