/*
	ZPM MK III Spawn Tool for GarrysMod10
	Copyright (C) 2010 Llapp
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Energy";
TOOL.Name=SGLanguage.GetMessage("stool_zpm_mk3");

TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["capacity"] = 100;
TOOL.ClientConVar["model"] = "models/pg_props/pg_zpm/pg_zpm.mdl";
TOOL.Entity.Class = "zpm_mk3";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = StarGate.CFG:Get("zpm_mk3","limit",6);
TOOL.Topic["name"] = "ZPM MK III Spawner";
TOOL.Topic["desc"] = "Creates a Zero Point Module";
TOOL.Topic[0] = "Left click, to spawn a ZPM MK III";
TOOL.Language["Undone"] = "Zero Point Module removed";
TOOL.Language["Cleanup"] = "Zero Point Modules";
TOOL.Language["Cleaned"] = "Removed all Zero Point Modules";
TOOL.Language["SBoxLimit"] = "Hit the Zero Point Module limit";

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model);
	local weld = util.tobool(self:GetClientNumber("autoweld"));
	if(SERVER and t.Entity and t.Entity.ZPMHub) then
		t.Entity:Touch(e);
		weld = false;
	elseif(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity);
	end
	local c = self:Weld(e,t.Entity,weld);
	local capacity = self:GetClientInfo("capacity");
	e.Energy = (e.Energy / 100) * capacity
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("Slider",{Label="Capacity:",Type="Integer",Min=1,Max=100,Command="zpm_mk3_capacity"});
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"zpm_mk3_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"zpm_mk3_autolink"):SetToolTip("Autolink this to resource using Entities?");
	end
	Panel:AddControl("Label", {Text = "\nThis is the Zpm MK3, this tool is in use for LifeSupport and Resource Distribution. If you don't got LS/RD this Zpm MK3 is quite useless for you.",})
end

TOOL:Register();