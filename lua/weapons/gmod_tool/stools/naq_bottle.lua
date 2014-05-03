/*
	ZPM MK III Spawn Tool for GarrysMod10
	Copyright (C) 2010 Llapp
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Energy";
if (SGLanguage and SGLanguage.GetMessage) then
	TOOL.Name=SGLanguage.GetMessage("stool_naq_bottle");
end

TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["model"] = "models/sandeno/naquadah_bottle.mdl";
TOOL.Entity.Class = "naquadah_bottle";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = 5;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_naq_bottle_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_naq_bottle_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_naq_bottle_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_naq_bottle_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_naq_bottle_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_naq_bottle_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_naq_bottle_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model);
	local weld = util.tobool(self:GetClientNumber("autoweld"));
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity);
	end
	local c = self:Weld(e,t.Entity,weld);
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"naq_bottle_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"naq_bottle_autolink"):SetToolTip(SGLanguage.GetMessage("stool_autolink_desc"));
	end
	Panel:AddControl("Label", {Text = SGLanguage.GetMessage("stool_naq_bottle_fulldesc"),})
end

TOOL:Register();