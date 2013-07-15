/*
	Tampered ZPM
	Copyright (C) 2010  Llapp
*/
if (not StarGate.CheckModule("energy")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Weapons";
TOOL.Name=Language.GetMessage("stool_tzpm");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["model"] = "models/pg_props/pg_zpm/pg_zpm.mdl";
TOOL.Entity.Class = "tampered_zpm";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = StarGate.CFG:Get("tampered_zpm","limit",3);
TOOL.Topic["name"] = "Tampered ZPM Spawner";
TOOL.Topic["desc"] = "Creates a Tampered ZPM";
TOOL.Topic[0] = "Left click, to spawn a Tampered ZPM";
TOOL.Language["Undone"] = "Tampered ZPM removed";
TOOL.Language["Cleanup"] = "Tampered ZPM";
TOOL.Language["Cleaned"] = "Removed all Tampered ZPMs";
TOOL.Language["SBoxLimit"] = "Hit the Tampered ZPM limit";

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model);
	if(SERVER and t.Entity and t.Entity.ZPMHub) then
		t.Entity:Touch(e);
		weld = false;
	elseif(util.tobool(self:GetClientNumber("autolink"))) then
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
	Panel:CheckBox(Language.GetMessage("stool_autoweld"),"tampered_zpm_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(Language.GetMessage("stool_autolink"),"tampered_zpm_autolink"):SetToolTip("Autolink this to resouce using Entities?");
	end
	Panel:AddControl("Label", {Text = "\nThis is the Tampered Zpm, this tool is in use for LifeSupport and Resource Distribution. If you don't got LS/RD this Tampered Zpm is quite useless for you.",})
	Panel:AddControl("Label", {Text = "\nDiscription:\n\nCamulus discovered a ZPM in an Ancient outpost. Unable to use it himself, he coated it with a volatile compound that would react explosively to an electrical charge. He led the Tau'ri to it in the hopes that they would destroy themselves. Bill Lee discovered the compound by mistake when it became necessary to flood the base with gamma radiation. The estimated blast radius of the ZPM, which held a roughly 50% charge, could have possibly encompassed the entire solar system, and at the very least would have completely destroyed Earth. (SG1: \"Zero Hour\") Efforts were made to remove the compound, but the first test of the ZPM destroyed it and the planet it was on.",})
end

TOOL:Register();