/*   Copyright (C) 2010 by Llapp   */
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("energy") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Energy";
TOOL.Name=SGLanguage.GetMessage("stool_naq_gen");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["autolink"] = 1;
local models =
{
   "models/naquada-reactor.mdl",
   "models/MarkJaw/naquadah_generator.mdl"
}
TOOL.ClientConVar['model'] = models[2]
local entityName = "naq_gen_mks"
TOOL.Entity.Class = "naq_gen_mks";
TOOL.Entity.Limit = StarGate.CFG:Get("naq_gen_mks","limit",10);

TOOL.Topic["name"] = "Naquada Generator Spawner";
TOOL.Topic["desc"] = "Creates a Naquada Generator";
TOOL.Topic[0] = "Left click, to spawn a Naquada Generator. Right lick - refill 25% (once in 30 seconds).";
TOOL.Language["Undone"] = "Naquada Generator removed";
TOOL.Language["Cleanup"] = "Naquada Generator";
TOOL.Language["Cleaned"] = "Removed all Naquada Generators";
TOOL.Language["SBoxLimit"] = "Hit the Naquada Generator limit";

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and (t.Entity:GetClass() == self.Entity.Class or t.Entity:GetClass()=="naquadah_generator" or t.Entity:GetClass()=="naq_gen_mk2")) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	if(p:GetCount("naq_gen_mks")>=GetConVar("sbox_maxnaq_gen_mks"):GetInt()) then
		p:SendLua("GAMEMODE:AddNotify(\"Naquadah generator limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	local model = self:GetClientInfo("model");
	local e = self:MakeEntity(p, t.HitPos, ang, model)
	if (not IsValid(e)) then return end
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity);
	end
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:RightClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and (t.Entity:GetClass()!="naquadah_generator" and t.Entity:GetClass()!="naq_gen_mk2")) then return false end;
	if(CLIENT) then return true end;
	t.Entity.LastRefill = t.Entity.LastRefill or 0;
	if (t.Entity:GetClass()=="naquadah_generator") then
		if (t.Entity.Energy<t.Entity.MaxEnergy and t.Entity.LastRefill<CurTime()) then
			t.Entity.Energy = math.Clamp((t.Entity.Energy + t.Entity.MaxEnergy*0.25),0,t.Entity.MaxEnergy);
			t.Entity.LastRefill = CurTime()+30;
			t.Entity.depleted = false;
			t.Entity:AddResource("energy",StarGate.CFG:Get("naq_gen_mk1","energy",10000));
		end
	else
		if (t.Entity.Naquadah<t.Entity.MaxEnergy and t.Entity.LastRefill<CurTime()) then
			t.Entity.Naquadah = math.Clamp((t.Entity.Naquadah + t.Entity.MaxEnergy*0.25),0,t.Entity.MaxEnergy);
			t.Entity.LastRefill = CurTime()+30;
			t.Entity.depleted = false;
			t.Entity:AddResource("energy",StarGate.CFG:Get("naq_gen_mk2","energy",10000));
		end
	end
	return true;
end

if(SERVER) then
    function TOOL:MakeEntity(ply, position, angle, model)
		if (StarGate_Group and StarGate_Group.Error == true) then StarGate_Group.ShowError(ply); return
		elseif (StarGate_Group==nil or StarGate_Group.Error==nil) then
			Msg("Carter Addon Pack - Unknown Error\n");
			ply:SendLua("Msg(\"Carter Addon Pack - Unknown Error\\n\")");
			ply:SendLua("GAMEMODE:AddNotify(\"Carter Addon Pack: Unknown Error\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			return;
		end
		if (StarGate.NotSpawnable("naq_gen_mks",ply,"tool") ) then return end

        local class = "naquadah_generator";
		local pos = Vector(0,0,0);
        if(model=="models/naquada-reactor.mdl")then
           class = "naquadah_generator"
		   pos = Vector(0,0,0);
        elseif(model=="models/markjaw/naquadah_generator.mdl")then
            class = "naq_gen_mk2"
			pos = Vector(0,0,0);
	    end
        local entity;
        entity = ents.Create(class)
        entity:SetAngles(angle)
        entity:SetPos(position+pos)
        entity:SetVar("Owner", ply)
        entity:SetModel(model)
        entity:Spawn()
        entity.Owner = ply
        ply:AddCount("naq_gen_mks", entity);
        return entity
    end
end

function TOOL.BuildCPanel(panel)

	if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("stools/#naq_gen_mks");
		VGUI:SetTopic("Help: Tools - "..SGLanguage.GetMessage("stool_naq_gen"));
		panel:AddPanel(VGUI);
	end

    panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"naq_gen_mks_autoweld");
	if(StarGate.HasResourceDistribution) then
		panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"naq_gen_mks_autolink"):SetToolTip("Autolink this to resource using Entities?");
	end
	panel:AddControl("Header",
   {
      Text = "#Tool_"..entityName.."_name",
      Description = "#Tool."..entityName..".desc"
   })

   for _, model in pairs(models) do
      if(file.Exists(model,"GAME")) then
         list.Set(entityName.."Models", model, {})
      end
   end

   panel:AddControl("PropSelect",
   {
		Label = "Model:",
		ConVar = entityName.."_model",
		Category = "Stargate",
		Models = list.Get(entityName.."Models")
   })

   panel:AddControl("Label", {Text = "\nThis tool is the Naquadah Generator tool. The tool will provide you with a Mark 1 or Mark 2 Naquadah Generator, beacuse the MK1 got less power than the MK2 its still useful. This tool is in use for LifeSupport and Resource Distribution. If you don't got LS/RD this Zpm Hub is quite useless for you.",})
end
--[[
function TOOL:ControlsPanel(Panel)
    Panel:CheckBox("Autoweld","zpm_mk3_autoweld");
	Panel:AddControl("Label", {Text = "\nThis tool is the Naquadah Generator tool. The tool will provide you with a Mark 1 or Mark 2 Naquadah Generator, beacuse the MK1 got less power than the MK2 its still useful. This tool is in use for LifeSupport and Resource Distribution. If you don't got LS/RD this Zpm Hub is quite useless for you.",})
end]]

TOOL:Register();
