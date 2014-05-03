/*
	Jamming Device
	Copyright (C) 2010  Madman07
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_tolland");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["immunity"] = 0;
TOOL.ClientConVar["size"] = 100;
TOOL.ClientConVar["toggle"] = 3;

TOOL.ClientConVar["model"] = "models/Iziraider/disabler/disabler.mdl";
TOOL.List = "DisablerModels";
list.Set(TOOL.List,"models/Iziraider/disabler/disabler.mdl",{});
list.Set(TOOL.List,"models/micropro/shield_gen.mdl",{});
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

TOOL.Entity.Class = "tollan_disabler";
TOOL.Entity.Keys = {"model","toggle","size","immunity"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 2;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_tollan_disabler_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_tollan_disabler_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_tollan_disabler_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_tollan_disabler_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_tollan_disabler_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_tollan_disabler_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_tollan_disabler_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local model = self:GetClientInfo("model");
	local toggle = self:GetClientNumber("toggle");
	local size = self:GetClientNumber("size");
	local immunity = self:GetClientNumber("immunity");
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		t.Entity:Setup(size, util.tobool(immunity));
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,model,toggle, size, immunity);
	if (not IsValid(e)) then return end
	e:Setup(size, util.tobool(immunity));
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PreEntitySpawn(p,e,model,toggle, size, immunity)
	e:SetModel(model);
end

function TOOL:PostEntitySpawn(p,e,model,toggle, size, immunity)
	e:Setup(size or 100, util.tobool(immunity));
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleDisabler",e);
	end
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="tollan_disabler_model",Category="",Models=self.Models});
	Panel:NumSlider(SGLanguage.GetMessage("stool_size"),"tollan_disabler_size",100,1024,0);
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_toggle"),
		Command="tollan_disabler_toggle",
	});
	Panel:CheckBox(SGLanguage.GetMessage("stool_immunity"),"tollan_disabler_immunity"):SetToolTip(SGLanguage.GetMessage("stool_tollan_disabler_imm"));
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"tollan_disabler_autoweld");
end

if SERVER then
	numpad.Register("ToggleDisabler",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(e.IsEnabled) then
				e.IsEnabled = false;
			else
				e.IsEnabled = true;
			end
		end
	);
end

TOOL:Register();