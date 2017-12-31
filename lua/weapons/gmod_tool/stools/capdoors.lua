/*
	Doors
	Copyright (C) 2010  Madman07
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_door");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["toggle"] = KEY_PAD_2;
TOOL.ClientConVar["diff_text"] = 0;
TOOL.ClientConVar["model"] = "models/cryptalchemy_models/destiny/bridge_door/bridge_door.mdl";
TOOL.ClientConVar["doormodel"] = "";

TOOL.List = "DoorsModels";
list.Set(TOOL.List,"models/madman07/doors/dest_door.mdl",{});
list.Set(TOOL.List,"models/cryptalchemy_models/destiny/bridge_door/bridge_door.mdl",{});
list.Set(TOOL.List,"models/madman07/doors/atl_door1.mdl",{});
list.Set(TOOL.List,"models/madman07/doors/atl_door2.mdl",{});
list.Set(TOOL.List,"models/madman07/doors/atl_door3.mdl",{});

TOOL.Entity.Class = "cap_doors_frame";
TOOL.Entity.Keys = {"model","toggle", "diff_text", "doormodel"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 10;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_cap_doors_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_cap_doors_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_cap_doors_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_cap_doors_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_cap_doors_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_cap_doors_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_cap_doors_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model"):lower();
	local toggle = self:GetClientNumber("toggle");
	local diff_text = util.tobool(self:GetClientNumber("diff_text"));
	local doormodel = model;
	if (model == "models/madman07/doors/dest_door.mdl") then model = "models/madman07/doors/dest_frame.mdl";
	elseif (model == "models/cryptalchemy_models/destiny/bridge_door/bridge_door.mdl") then model = "models/cryptalchemy_models/destiny/bridge_door/bridge_door_frame.mdl";
	elseif (model == "models/madman07/doors/atl_door3.mdl") then model = "models/gmod4phun/atl_frame3.mdl"; -- New door and frame
	else model = "models/madman07/doors/atl_frame.mdl"; end

	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model,toggle, diff_text, doormodel);
	if (not IsValid(e)) then return end
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);

	e.DoorModel = doormodel;
	if (IsValid(e.Door)) then e.Door:SetAngles(e:GetAngles()) end -- fix
	if (model == "models/madman07/doors/atl_frame.mdl") then
		if diff_text then e:SetMaterial("madman07/doors/atlwall_red"); end
	end
	if (model == "models/madman07/doors/dest_frame.mdl") then e:SoundType(1);
	elseif (model == "models/cryptalchemy_models/destiny/bridge_door/bridge_door_frame.mdl") then e:SoundType(3);
	else e:SoundType(2); end

	return true;
end

function TOOL:PreEntitySpawn(p,e,model,toggle, diff_text, doormodel)
	e:SetModel(model);
	e.DoorModel = doormodel;
	e.Owner = p;
end

function TOOL:PostEntitySpawn(p,e,model,toggle, diff_text, doormodel)
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleDoors",e);
	end
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="capdoors_model",Category="",Models=self.Models});
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_toggle"),
		Command="capdoors_toggle",
	});
	Panel:CheckBox(SGLanguage.GetMessage("stool_cap_doors_redt"),"capdoors_diff_text");
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"capdoors_autoweld");
end

if SERVER then
	numpad.Register("ToggleDoors",
		function(p,e)
			if (IsValid(e)) then
				e:Toggle();
			end
		end
	);
end

TOOL:Register();
