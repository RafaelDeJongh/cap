/*   Copyright (C) 2010 by Llapp   */
if (not StarGate.CheckModule("extra")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Ramps";
TOOL.Name=Language.GetMessage("stool_ring_ramps");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = StarGate.Ramps.RingDefault;
TOOL.List = "RingRampModels";
for k,v in pairs(StarGate.Ramps.Ring) do
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
TOOL.Entity.Limit = StarGate.CFG:Get("ramp","limit",50);
TOOL.Topic["name"] = "RingRamp Spawner";
TOOL.Topic["desc"] = "Creates a RingRamp";
TOOL.Topic[0] = "Left click, to spawn a RingRamp";
TOOL.Language["Undone"] = "RingRamp removed";
TOOL.Language["Cleanup"] = "RingRamp";
TOOL.Language["Cleaned"] = "Removed all Ramps";
TOOL.Language["SBoxLimit"] = "Hit the RingRamp limit";

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
	if (not IsValid(e)) then return end
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label="Model",ConVar="ring_ramps_model",Category="",Models=self.Models});
end

TOOL:Register();