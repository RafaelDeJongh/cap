/*
	Goauld Iris
	Copyright (C) 2010  Madman07
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_giris");
TOOL.ClientConVar["toggle"] = 3;
TOOL.ClientConVar["activate"] = 12;
TOOL.ClientConVar["deactivate"] = StarGate.KeyEnter;

TOOL.Entity.Class = "goauld_iris";
TOOL.Entity.Keys = {"toggle","activate","deactivate","IsActivated"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 5;
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_goauld_iris_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_goauld_iris_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_goauld_iris_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_goauld_iris_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_goauld_iris_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_goauld_iris_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_goauld_iris_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local toggle = self:GetClientNumber("toggle");
	local activate = self:GetClientNumber("activate");
	local deactivate = self:GetClientNumber("deactivate");
	if(not IsValid(t.Entity) or not t.Entity.IsStargate) then
	    p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_stargate_iris_err\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	    return
	end
	if(t.Entity.IsSupergate or t.Entity:GetClass()=="stargate_orlin") then
	    p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_stargate_iris_err2\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
	    return
	end
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return true;
	end
	if (t.Entity.GateSpawnerSpawned and StarGate.CFG and not StarGate.CFG:Get("stargate_iris","gatespawner",true)) then
	    p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_stargate_iris_err3\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,toggle,activate,deactivate);
	if (not IsValid(e)) then return end
	local stargate = false;
	if(IsValid(t.Entity) and t.Entity.IsStargate) then
		for _,v in pairs(ents.FindInSphere(t.Entity:GetPos(),10)) do
			if(v.IsIris and v ~= e) then
				if (v.GateSpawnerSpawned) then
					e:Remove();
					p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"iris_gatespawner\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
					return
				else
					v:Remove(); -- Remove old, existing iri's (replace them with this new one)
				end
			end
		end
	end
	e.GateLink = t.Entity;
	if (t.Entity.GateSpawnerSpawned) then
		p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"iris_protection\"), NOTIFY_GENERIC, 5); surface.PlaySound( \"buttons/button9.wav\" )");
		e:IrisProtection();
	end
	e:SetPos(t.Entity:GetPos());
	e:SetAngles(t.Entity:GetAngles());
	e.NextAction = CurTime()
	if(not e.IsActivated)then
		e:Toggle(true);
	end
	local c = self:Weld(e,t.Entity,true);
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

function TOOL:PostEntitySpawn(p,e,toggle,activate,deactivate,IsActivated)
	if(toggle) then
		numpad.OnDown(p,toggle,"ToggleIris",e);
	end
	if(activate) then
		numpad.OnDown(p,activate,"ActivateIris",e);
	end
	if(deactivate) then
		numpad.OnDown(p,deactivate,"DeActivateIris",e);
	end
	if((IsActivated and not e.IsActivated) or (not IsActivated and e.IsActivated)) then
		e:Toggle();
	end
end

function TOOL:ControlsPanel(Panel)
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_toggle"),
		Command="goauld_iris_toggle",
	});
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_activate"),
		Command="goauld_iris_activate",
		Label2=SGLanguage.GetMessage("stool_deactivate"),
		Command2="goauld_iris_deactivate",
	});
end

if SERVER then
	numpad.Register("ToggleIris",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:Toggle();
		end
	);
	numpad.Register("ActivateIris",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(not e.IsActivated) then e:Toggle() end;
		end
	);
	numpad.Register("DeActivateIris",
		function(p,e)
			if(not e:IsValid()) then return end;
			if(e.IsActivated) then e:Toggle() end;
		end
	);
end

TOOL:Register();