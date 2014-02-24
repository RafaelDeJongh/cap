/*
	Tokra Shield Emmiter
	Copyright (C) 2011  Madman07
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_tshield");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/Madman07/tokra_shield/generator.mdl";

TOOL.Entity.Class = "tokra_emmiter";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = StarGate.CFG:Get("tokra_shield","limit",2);
TOOL.Topic["name"] = "Tokra Shield Emmiter Spawner";
TOOL.Topic["desc"] = "Creates a Tokra Shield Emmiter";
TOOL.Topic[0] = "Left click, to spawn Tokra Shield Emmiter";
TOOL.Language["Undone"] = "Tokra Shield Emmiter removed";
TOOL.Language["Cleanup"] = "Tokra Shield Emmiters";
TOOL.Language["Cleaned"] = "Removed all Tokra Shield Emmiters";
TOOL.Language["SBoxLimit"] = "Hit the Tokra Shield Emmiters limit";

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
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"tokra_shield_emmiter_autoweld");
end

TOOL:Register();