/*
	Atlantis ZPM Hub
	Copyright (C) 2010  Llapp
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Energy";
TOOL.Name=SGLanguage.GetMessage("stool_atlantis_hub");
TOOL.ClientConVar["autoweld"] = 1;

TOOL.ClientConVar["model"] = "models/pg_props/pg_zpm/pg_zpm_hub.mdl";
TOOL.List = "ATLANTISZPMHUB";
list.Set(TOOL.List,"models/pg_props/pg_zpm/pg_zpm_hub.mdl",{Angle=Angle(0,30%360,0),Position=Vector(0,0,0)});
TOOL.Entity.Class = "zpmhub";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = 5;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_atlantis_zpm_hub_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_atlantis_zpm_hub_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_atlantis_zpm_hub_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_atlantis_zpm_hub_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_atlantis_zpm_hub_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_atlantis_zpm_hub_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_atlantis_zpm_hub_limit");

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
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+90) % 360;
	local pos = t.HitPos+Vector(0,0,0);
	e:SetAngles(ang)
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
	Panel:AddControl("Label", {Text = SGLanguage.GetMessage("stool_atlantis_zpm_hub_fulldesc")})
end

TOOL:Register();