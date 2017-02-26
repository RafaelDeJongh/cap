/*   Copyright (C) 2010 by Llapp   */
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Ramps";
TOOL.Name=SGLanguage.GetMessage("stool_nanim_ramps");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = StarGate.Ramps.NonAnimDefault;
TOOL.List = "RampModels";
for k,v in pairs(StarGate.Ramps.NonAnim) do
	if (v[1]&&v[2]) then
		list.Set(TOOL.List,k,{Position=v[1],Angle=v[2]});
	elseif (v[1]) then
		list.Set(TOOL.List,k,{Position=v[1]});
	else
		list.Set(TOOL.List,k,{});
	end
end

TOOL.Entity.Class = "ramp";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = 50;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_ramp_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_ramp_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_ramp_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_ramp_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_ramp_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_ramp_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_ramp_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model);
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="non_anim_ramps_model",Category="",Models=self.Models});
end

TOOL:Register();