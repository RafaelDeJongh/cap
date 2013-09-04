/*
	SGC ZPM Hub
	Copyright (C) 2010  Llapp
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Energy";
TOOL.Name=SGLanguage.GetMessage("stool_sgc_hub");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/micropro/zpmslot/zpm_slot.mdl";
TOOL.List = "SGCZPMHUB";
list.Set(TOOL.List,"models/micropro/zpmslot/zpm_slot.mdl",{Angle=Angle(0,180,0),Position=Vector(0,0,0)});
TOOL.Entity.Class = "sgc_zpm_hub";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = StarGate.CFG:Get("sgc_zpm_hub","limit",5);
TOOL.Topic["name"] = "SGC ZPM Hub Spawner";
TOOL.Topic["desc"] = "Creates a SGC ZPM Hub";
TOOL.Topic[0] = "Left click to spawn a SGC ZPM Hub";
TOOL.Language["Undone"] = "SGC ZPM Hub removed";
TOOL.Language["Cleanup"] = "SGC ZPM Hub";
TOOL.Language["Cleaned"] = "Removed all SGC ZPM Hubs";
TOOL.Language["SBoxLimit"] = "Hit the SGC ZPM Hub limit";

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
    Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"sgc_zpm_hub_autoweld");
	Panel:AddControl("Label", {Text = "\nThis is the Stargate Command ZPM Hub. This tool requires Life Support and Resource Distribution. If you don't have LS/RD, this ZPM Hub is quite useless to you.",})
end

TOOL:Register();