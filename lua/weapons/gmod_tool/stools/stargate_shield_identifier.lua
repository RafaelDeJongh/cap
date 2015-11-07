--################# Header
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("base") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");
TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("shieldid_title");

TOOL.ClientConVar["autoweld"] = 1;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/props_lab/reciever01b.mdl";
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "StargateShieldIdentModels"; -- The listname of garrys "List" Module we use for models
list.Set(TOOL.List,"models/props_lab/reciever01b.mdl",{});
list.Set(TOOL.List,"models/micropro/shield_gen.mdl",{}); -- Thanks micropro for this model!
list.Set(TOOL.List,"models/props_combine/weaponstripper.mdl",{Angle=Angle(-90,0,0),Position=Vector(15,0,-60)});
list.Set(TOOL.List,"models/props_docks/dock01_cleat01a.mdl",{});
list.Set(TOOL.List,"models/props_junk/plasticbucket001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{});
list.Set(TOOL.List,"models/props_trainstation/trashcan_indoor001a.mdl",{});
list.Set(TOOL.List,"models/props_c17/clock01.mdl",{});
if (file.Exists("models/props_c17/pottery08a.mdl","GAME")) then
	list.Set(TOOL.List,"models/props_c17/pottery08a.mdl",{});
end
list.Set(TOOL.List,"models/props_combine/breenclock.mdl",{});
list.Set(TOOL.List,"models/props_combine/breenglobe.mdl",{});
list.Set(TOOL.List,"models/props_junk/metal_paintcan001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{});

-- Information about the SENT to spawn
TOOL.Entity.Class = "shield_identifier";
TOOL.Entity.Keys = {"model"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 5; -- A person generally can spawn 1 shield
/*
-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_stargate_shield_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_stargate_shield_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_stargate_shield_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_stargate_shield_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_stargate_shield_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_stargate_shield_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_stargate_shield_limit");*/
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	--######## Spawn SENT
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return false;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model);
	--######## Weld things?
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,model)
	e:SetModel(model);
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="stargate_shield_identifier_model",Category="",Models=self.Models});
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"stargate_shield_autoweld");
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();