/*
	Doors
	Copyright (C) 2010  Madman07
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("devices") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_door");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["toggle"] = 3;
TOOL.ClientConVar["diff_text"] = 0;
TOOL.ClientConVar["model"] = "models/Madman07/doors/dest_door.mdl";
TOOL.ClientConVar["doormodel"] = "";

TOOL.List = "DoorsModels";
list.Set(TOOL.List,"models/Madman07/doors/dest_door.mdl",{});
list.Set(TOOL.List,"models/Madman07/doors/atl_door1.mdl",{});
list.Set(TOOL.List,"models/Madman07/doors/atl_door2.mdl",{});

TOOL.Entity.Class = "cap_doors_frame";
TOOL.Entity.Keys = {"model","toggle", "diff_text", "doormodel"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = StarGate.CFG:Get("cap_doors","limit",10);
TOOL.Topic["name"] = "Doors Spawner";
TOOL.Topic["desc"] = "Creates a Doors";
TOOL.Topic[0] = "Left click, to spawn or update a Doors";
TOOL.Language["Undone"] = "Doors removed";
TOOL.Language["Cleanup"] = "Doors";
TOOL.Language["Cleaned"] = "Removed all Doors";
TOOL.Language["SBoxLimit"] = "Hit the Doors limit";

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local toggle = self:GetClientNumber("toggle");
	local diff_text = util.tobool(self:GetClientNumber("diff_text"));
	local doormodel = model:lower();
	if (model == "models/madman07/doors/dest_door.mdl") then model = "models/madman07/doors/dest_frame.mdl";
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
	else e:SoundType(2); end

	return true;
end

function TOOL:PreEntitySpawn(p,e,model,toggle, diff_text, doormodel)
	e:SetModel(model);
	e.DoorModel = doormodel;
end

function TOOL:PostEntitySpawn(p,e,model,toggle, diff_text, doormodel)
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleDoors",e);
	end
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label="Model",ConVar="cap_doors_model",Category="",Models=self.Models});
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label="Toggle:",
		Command="cap_doors_toggle",
	});
	Panel:CheckBox("Red Texture on Atlantis frame","cap_doors_diff_text");
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"cap_doors_autoweld");
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