/*   Copyright (C) 2011 by Llapp   */
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_fchev");
TOOL.ClientConVar["model"] = "models/The_Sniper_9/Universe/Stargate/floorchevron.mdl";
TOOL.ClientConVar["autoweld"] = 1;
TOOL.List = "FloorChevronModels";
list.Set(TOOL.List,"models/The_Sniper_9/Universe/Stargate/floorchevron.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/ramps/sgu_ramp/floor_chev.mdl",{});
TOOL.Entity.Class = "floorchevron";
TOOL.Entity.Keys = {"model"};
TOOL.Entity.Limit = StarGate.CFG:Get("floorchevron","limit",10);
TOOL.Topic["name"] = "Floor Chevron Spawner";
TOOL.Topic["desc"] = "Creates a Floor Chevron";
TOOL.Topic[0] = "Left click, to spawn a Floor Chevron";
TOOL.Language["Undone"] = "Floor Chevron removed";
TOOL.Language["Cleanup"] = "Floor Chevron";
TOOL.Language["Cleaned"] = "Removed all Floor Chevrons";
TOOL.Language["SBoxLimit"] = "Hit the Floor Chevron limit";

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
		if(IsValid(v) and v:GetClass():find("floorchevron")) then
		   p:SendLua("GAMEMODE:AddNotify(\"Floor Chevron is exist on this Stargate!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		   return
		end
	end
	local e = self:SpawnSENT(p,t,model);
	if (not IsValid(e)) then return end
	local ang = t.Entity:GetAngles(); ang.y = ang.y+180;
	local vec = Vector(40,0,-90); if(model == models[2])then vec = Vector(40,0,0) end;
	e:SetPos(t.Entity:LocalToWorld(vec))
	e:SetAngles(ang);
    local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

function TOOL:ControlsPanel(Panel)
    Panel:AddControl("PropSelect",{Label="Model",ConVar="floorchevron_model",Category="",Models=self.Models});
	Panel:AddControl("Label", {Text = "\nDiscription:\n\nChevron on the Floor that turns on when the last Symbol has locked and then the Gate kawooshes.",})
end

TOOL:Register();