/*   Copyright (C) 2010 by Llapp   */
if (not StarGate.CheckModule("extra")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Ramps";
TOOL.Name=Language.GetMessage("stool_anim_ramps");
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar['model'] = StarGate.Ramps.AnimDefault[1];
local entityName = "anim_ramps"
TOOL.Entity.Class = "anim_ramps";
TOOL.Entity.Limit = StarGate.CFG:Get("anim_ramps","limit",10);

TOOL.Topic["name"] = "Ramp Spawner";
TOOL.Topic["desc"] = "Creates a Ramp";
TOOL.Topic[0] = "Left click, to spawn a Ramp";
TOOL.Language["Undone"] = "Ramp removed";
TOOL.Language["Cleanup"] = "Ramp";
TOOL.Language["Cleaned"] = "Removed all Ramps";
TOOL.Language["SBoxLimit"] = "Hit the Ramp limit";

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	if(p:GetCount("CAP_anim_ramps")>=GetConVar("sbox_maxanim_ramps"):GetInt()) then
		p:SendLua("GAMEMODE:AddNotify(\"Anim ramp limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end
	local ang = p:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360
	local model = self:GetClientInfo("model");
	local e = self:MakeEntity(p, t.HitPos, ang, model)
	if (not IsValid(e)) then return end
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	p:AddCount("CAP_anim_ramps", e)
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
		if (StarGate.NotSpawnable("anim_ramps",ply,"tool")) then return end

        local class = "";
		local pos = Vector(0,0,0);
        if(StarGate.Ramps.Anim[model])then
           class = StarGate.Ramps.Anim[model][1];
           if (StarGate.Ramps.Anim[model][2]) then
            pos = StarGate.Ramps.Anim[model][2];
		   end
           if (StarGate.Ramps.Anim[model][3]) then
            angle = angle + StarGate.Ramps.Anim[model][3];
		   end
        else
         	class = StarGate.Ramps.AnimDefault[2];
	        if (StarGate.Ramps.AnimDefault[3]) then
         	 pos = StarGate.Ramps.AnimDefault[3];
			end
        	if (StarGate.Ramps.AnimDefault[4]) then
        	 angle = angle + StarGate.Ramps.AnimDefault[4];
			end
        end
        local entity;
        entity = ents.Create(class)
        entity:SetAngles(angle)
        entity:SetPos(position+pos)
        entity:SetVar("Owner", ply)
        entity:SetModel(model)
        entity:Spawn()
        ply:AddCount("CAP_anim_ramps", entity);
        return entity
    end
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header",
   {
      Text = "#Tool_"..entityName.."_name",
      Description = "#Tool."..entityName..".desc"
   })

   for model, _ in pairs(StarGate.Ramps.Anim) do
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
end

TOOL:Register();
