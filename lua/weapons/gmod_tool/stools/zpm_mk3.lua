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
TOOL.Entity.Limit = 6;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_zpm_mk3_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_zpm_mk3_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_zpm_mk3_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_zpm_mk3_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_zpm_mk3_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_zpm_mk3_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_zpm_mk3_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local e = self:SpawnSENT(p,t,model);
	if (not IsValid(e)) then return false end
	local weld = util.tobool(self:GetClientNumber("autoweld"));
	if(SERVER and t.Entity and t.Entity.ZPMHub) then
		t.Entity:Touch(e);
		weld = false;
	elseif(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity);
	end
	local c = self:Weld(e,t.Entity,weld);
	local capacity = tonumber(self:GetClientInfo("capacity"));
	e.Energy = (e.Energy / 100) * math.Clamp(capacity,1,100)
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:NumSlider(SGLanguage.GetMessage("stool_zpm_mk3_capacity"),"zpm_mk3_capacity",1,100,0);
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"zpm_mk3_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"zpm_mk3_autolink"):SetToolTip(SGLanguage.GetMessage("stool_autolink_desc"));
	end
	Panel:AddControl("Label", {Text = SGLanguage.GetMessage("stool_zpm_mk3_fulldesc")})
end

TOOL:Register();