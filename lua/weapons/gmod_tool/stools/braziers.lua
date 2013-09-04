/*
	Braziers
	Copyright (C) 2010  Madman07
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_brazier");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/Boba_Fett/props/brazier.mdl";
TOOL.List = "BrazierModels";
list.Set(TOOL.List,"models/Boba_Fett/props/brazier.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/brazier2.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/goauld_brazier.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/jaffa_brazier.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/ori_brazier.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/ori_brazier2.mdl",{});

TOOL.Entity.Class = "brazier";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = StarGate.CFG:Get("brazier","limit",50);
TOOL.Topic["name"] = "Braziers Spawner";
TOOL.Topic["desc"] = "Creates a Brazier";
TOOL.Topic[0] = "Left click, to spawn or update a Brazier";
TOOL.Language["Undone"] = "Brazier removed";
TOOL.Language["Cleanup"] = "Braziers";
TOOL.Language["Cleaned"] = "Removed all Braziers";
TOOL.Language["SBoxLimit"] = "Hit the Braziers limit";

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
	Panel:AddControl("PropSelect",{Label="Model",ConVar="braziers_model",Category="",Models=self.Models});
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"braziers_autoweld");
end

TOOL:Register();