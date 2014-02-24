/*
	Naquada Bomb
	Copyright (C) 2010  Madman07, Stargate Extras
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Weapons";
TOOL.Name= SGLanguage.GetMessage("entity_asgard_ashen_def");

TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["model"] = "models/Madman07/ashen_defence/ashen_defence.mdl";
TOOL.Entity.Class = "ashen_defence";
TOOL.Entity.Keys = {"autoweld"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = StarGate.CFG:Get("ashen_defence","limit",10);
TOOL.Topic["name"] = "Ashen Defence System Spawner";
TOOL.Topic["desc"] = "Creates an Ashen Defence System";
TOOL.Topic[0] = "Left click to create the system";
TOOL.Language["Undone"] = "Ashen Defence System Undone";
TOOL.Language["Cleanup"] = "Ashen Defence Systems";
TOOL.Language["Cleaned"] = "Removed all Ashen Defence Systems";
TOOL.Language["SBoxLimit"] = "Maximum number of Ashen Defence Systems created";



function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model);
	local weld = util.tobool(self:GetClientNumber("autoweld"));
	local c = self:Weld(e,t.Entity,weld);
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end
/*
function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end
*/
function TOOL:ControlsPanel(Panel)
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"ashen_weapon_autoweld");
end

TOOL:Register();