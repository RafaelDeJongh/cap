/*
	Naquada Bomb
	Copyright (C) 2010  Madman07, Stargate Extras
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Weapons";
TOOL.Name=SGLanguage.GetMessage("stool_wh_bomb");
TOOL.ClientConVar["power"] = 5;
TOOL.ClientConVar["yield"] = 500;
TOOL.ClientConVar["timer"] = 5;
TOOL.ClientConVar["model"] = "models/Assassin21/wraith_bomb/stunner_bomb.mdl";
TOOL.ClientConVar["autoweld"] = 0;

TOOL.Entity.Class = "wraith_bomb";
TOOL.Entity.Keys = {"model","power","yield", "timer","autoweld"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = StarGate.CFG:Get("wraith_bomb","limit",1);
TOOL.Topic["name"] = "Wraith Bomb Spawner";
TOOL.Topic["desc"] = "Creates a Wraith Stun Bomb";
TOOL.Topic[0] = "Left click to create the bomb";
TOOL.Language["Undone"] = "Wraith Bomb Undone";
TOOL.Language["Cleanup"] = "Wraith Bombs";
TOOL.Language["Cleaned"] = "Removed all Wraith Bombs";
TOOL.Language["SBoxLimit"] = "Maximum number of Wraith Bombs created";

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	if(not self:CheckLimit()) then return false end;

	local model = self:GetClientInfo("model");
	local power = self:GetClientInfo("power")
	local time = self:GetClientNumber("timer")
	local yield = self:GetClientNumber("yield")
	local weld = util.tobool(self:GetClientNumber("autoweld"))

	if not p:IsAdmin() then
		yield = math.Clamp(yield, 100, 500)
	end

	local e = self:SpawnSENT(p,t,model,power,time,yield,autoweld);
	if (not IsValid(e)) then return end
	e.Timer = time
	e.Yield = yield
	e.Power = power

	local c = self:Weld(e,t.Entity,true);


	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true
end

function TOOL:PreEntitySpawn(p,e,model,power,time,yield,autoweld)
	e:SetModel(model);
end

function TOOL:PostEntitySpawn(p,e,model,power,time,yield,autoweld)
	e.Timer = time
	e.Yield = yield
	e.Power = power
end

function TOOL:ControlsPanel(Panel)
	Panel:NumSlider("Yield","wraith_bomb_yield",100,1000,0);
	Panel:NumSlider("Timer","wraith_bomb_timer",5,60,0);
	Panel:NumSlider("Power","wraith_bomb_power",5,30,0);
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"wraith_bomb_autoweld"):SetToolTip("Autoweld");
end

TOOL:Register();