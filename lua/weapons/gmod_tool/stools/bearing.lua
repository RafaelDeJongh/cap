/*   Copyright (C) 2010 by Llapp   */
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_bearing");
TOOL.ClientConVar["model"] = "models/Iziraider/gatebearing/bearing.mdl";
TOOL.ClientConVar["autoweld"] = 1;
TOOL.List = "BearingModels";
list.Set(TOOL.List,"models/Iziraider/gatebearing/bearing.mdl",{});
TOOL.Entity.Class = "bearing";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = 10;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_bearing_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_bearing_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_bearing_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_bearing_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_bearing_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_bearing_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_bearing_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	if(not IsValid(t.Entity) or not t.Entity:GetClass():find("stargate_universe")) then
	    p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_bearing_err\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	    return
	end
	for _,v in pairs(StarGate.GetConstrainedEnts(t.Entity,2) or {}) do
		if(IsValid(v) and v:GetClass():find("bearing")) then
		   p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_bearing_exs\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		   return
		end
	end
	local e = self:SpawnSENT(p,t,model);
	if (not IsValid(e)) then return end
	e:SetAngles(t.Entity:GetAngles());
    e:SetPos(t.Entity:LocalToWorld(Vector(2,0,136)))
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("Label", {Text = "\n"..SGLanguage.GetMessage("stool_desc").."\n\n"..SGLanguage.GetMessage("stool_bearing_fulldesc")})
end

TOOL:Register();