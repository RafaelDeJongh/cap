/*   Copyright (C) 2010 by Llapp   */
if (not StarGate.CheckModule("extra")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=Language.GetMessage("stool_bearing");
TOOL.ClientConVar["model"] = "models/Iziraider/gatebearing/bearing.mdl";
TOOL.ClientConVar["autoweld"] = 1;
TOOL.List = "BearingModels";
list.Set(TOOL.List,"models/Iziraider/gatebearing/bearing.mdl",{});
TOOL.Entity.Class = "bearing";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = StarGate.CFG:Get("bearing","limit",10);
TOOL.Topic["name"] = "Bearing Spawner";
TOOL.Topic["desc"] = "Creates a Bearing";
TOOL.Topic[0] = "Left click, to spawn a Bearing";
TOOL.Language["Undone"] = "Bearing removed";
TOOL.Language["Cleanup"] = "Bearing";
TOOL.Language["Cleaned"] = "Removed all Bearings";
TOOL.Language["SBoxLimit"] = "Hit the Bearing limit";

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
	    p:SendLua("GAMEMODE:AddNotify(\"Target is not a Stargate Universe!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	    return
	end
	for _,v in pairs(StarGate.GetConstrainedEnts(t.Entity,2) or {}) do
		if(IsValid(v) and v:GetClass():find("bearing")) then
		   p:SendLua("GAMEMODE:AddNotify(\"Bearing is exist on this Stargate!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
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
	Panel:AddControl("Label", {Text = "\nDiscription:\n\nThe Gate bearing hangs from the ceiling of the gate room aboard the Destiny. The bearing lights up with each glyph dialed on the Stargate, serving a similar function to that of the chevrons on the Milky Way and Pegasus Stargate designs.",})
end

TOOL:Register();