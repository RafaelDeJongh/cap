/*
	Naquada Bomb
	Copyright (C) 2010  Madman07, Stargate Extras
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Weapons";
TOOL.Name=SGLanguage.GetMessage("stool_naq_bomb");
TOOL.ClientConVar["detonationCode"] = "";
TOOL.ClientConVar["abortCode"] = "";
TOOL.ClientConVar["yield"] = 100;
TOOL.ClientConVar["chargeTime"] = 4;
TOOL.ClientConVar["model"] = "models/MarkJaw/gate_buster.mdl";

TOOL.List = "BombModels";
list.Set(TOOL.List,"models/Boba_Fett/props/lucian_bomb/lucian_bomb.mdl",{});
list.Set(TOOL.List,"models/Boba_Fett/props/goauldbomb/goauldbomb.mdl",{});
list.Set(TOOL.List,"models/MarkJaw/gate_buster.mdl",{});

TOOL.ClientConVar["autoweld"] = 0;
TOOL.ClientConVar["hud"] = 0;
TOOL.ClientConVar["cart"] = 1;
TOOL.Entity.Class = "naquadah_bomb";
TOOL.Entity.Keys = {"model","detonationCode","abortCode","chargeTime","yield", "hud", "cart", "autoweld"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 1;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_naqbomb_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_naqbomb_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_naqbomb_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_naqbomb_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_naqbomb_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_naqbomb_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_naqbomb_limit");



function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	if(not self:CheckLimit()) then return false end;

	local model = self:GetClientInfo("model");
	local detcode = self:GetClientInfo("detonationCode")
	local abcode = self:GetClientInfo("abortCode")
	local time = self:GetClientNumber("chargeTime")
	local yield = self:GetClientNumber("yield")
	local hud = util.tobool(self:GetClientNumber("hud"))
	local cart = util.tobool(self:GetClientNumber("cart"))
	local weld = util.tobool(self:GetClientNumber("autoweld"))

	if not p:IsAdmin() then
		yield = math.Clamp(yield, 10, 15)
	end

	local e = self:SpawnSENT(p,t,model,detcode,abcode,time,yield, hud, cart, autoweld);
	if (not IsValid(e)) then return end
	if (cart) then e:SetPos(e:GetPos()+Vector(0,0,25)) end
	e:Setup(detcode, abcode, yield, time, hud, cart, p)

	if (weld and not cart) then local c = self:Weld(e,t.Entity,true);
	else local c = self:Weld(e,t.Entity,false); end

	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true
end

function TOOL:PreEntitySpawn(p,e,model,detcode,abcode,time,yield, hud, cart, autoweld)
	e:SetModel(model);
end

function TOOL:PostEntitySpawn(p,e,model,detcode,abcode,time,yield, hud, cart, autoweld)
	if IsValid(p) and not p:IsAdmin() then
		yield = math.Clamp(yield, 10, 15)
	end
	e:Setup(detcode, abcode, yield, time, hud, cart, p)
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="naqbomb_model",Category="",Models=self.Models});
	Panel:AddControl("TextBox",
   {
		Label = SGLanguage.GetMessage("naq_bomb_menu_02"),
		Description = SGLanguage.GetMessage("naq_stool_menu_code"),
		Command = "naqbomb_detonationCode",
	})
	Panel:AddControl("TextBox",
   {
		Label = SGLanguage.GetMessage("naq_bomb_menu_02a"),
		Description = SGLanguage.GetMessage("naq_stool_menu_abort"),
		Command = "naqbomb_abortCode",
	})
	Panel:NumSlider(SGLanguage.GetMessage("naq_stool_menu_y"),"naqbomb_yield",10,100,0);
	Panel:NumSlider(SGLanguage.GetMessage("naq_stool_menu_d"),"naqbomb_chargeTime",10,300,0);
   	Panel:CheckBox(SGLanguage.GetMessage("naq_stool_menu_h"),"naqbomb_hud"):SetToolTip(SGLanguage.GetMessage("naq_stool_menu_h_d"));
	Panel:CheckBox(SGLanguage.GetMessage("naq_stool_menu_c"),"naqbomb_cart"):SetToolTip(SGLanguage.GetMessage("naq_stool_menu_c_d"));
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"naqbomb_autoweld"):SetToolTip(SGLanguage.GetMessage("naq_stool_menu_a_d"));
end

TOOL:Register();