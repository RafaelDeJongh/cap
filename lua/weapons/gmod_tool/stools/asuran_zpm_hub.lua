/*
	SGC ZPM Hub
	Copyright (C) 2010  Llapp
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Energy";
TOOL.Name=SGLanguage.GetMessage("stool_asuran_hub");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/pg_props/pg_stargate/pg_asuran_hub.mdl";
TOOL.List = "ASURANZPMHUB";
list.Set(TOOL.List,"models/pg_props/pg_stargate/pg_asuran_hub.mdl",{Angle=Angle(0,0,0),Position=Vector(0,0,0)});
TOOL.Entity.Class = "asuran_zpm_hub";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = StarGate.CFG:Get("asuran_zpm_hub","limit",5);
TOOL.Topic["name"] = "Asuran ZPM Hub Spawner";
TOOL.Topic["desc"] = "Creates an Asuran ZPM Hub";
TOOL.Topic[0] = "Left click to spawn an Asuran ZPM Hub";
TOOL.Language["Undone"] = "Asuran ZPM Hub removed";
TOOL.Language["Cleanup"] = "Asuran ZPM Hub";
TOOL.Language["Cleaned"] = "Removed all Asuran ZPM Hubs";
TOOL.Language["SBoxLimit"] = "Hit the Asuran ZPM Hub limit";

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return false;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model);
	if (not IsValid(e)) then return end
	local pos = t.HitPos+Vector(0,0,0);
	e:SetPos(pos)
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
    Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"asuran_zpm_hub_autoweld");
	Panel:AddControl("Label", {Text = "\nThis is the Asuran ZPM Hub. This tool requires Life Support and Resource Distribution. If you don't have LS/RD, this ZPM Hub is quite useless to you.",})
end

TOOL:Register();