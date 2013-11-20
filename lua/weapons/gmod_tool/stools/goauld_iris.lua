/*
	Goauld Iris
	Copyright (C) 2010  Madman07
*/
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_giris");
TOOL.ClientConVar["toggle"] = 3;
TOOL.ClientConVar["activate"] = 12;
TOOL.ClientConVar["deactivate"] = 13;

TOOL.Entity.Class = "goauld_iris";
TOOL.Entity.Keys = {"toggle","activate","deactivate","IsActivated"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = StarGate.CFG:Get("goauld_iris","limit",5);
TOOL.Topic["name"] = "Goauld Iris Spawner";
TOOL.Topic["desc"] = "Creates a Goauld Iris";
TOOL.Topic[0] = "Left click, to spawn or update a Goauld Iris";
TOOL.Language["Undone"] = "Goauld Iris removed";
TOOL.Language["Cleanup"] = "Goauld Iris";
TOOL.Language["Cleaned"] = "Removed all Goauld Irises";
TOOL.Language["SBoxLimit"] = "Hit the Goauld Iris limit";

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if not IsValid(t.Entity) then return end
	if (not t.Entity:GetClass():find("stargate_")) then return end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	local toggle = self:GetClientNumber("toggle");
	local activate = self:GetClientNumber("activate");
	local deactivate = self:GetClientNumber("deactivate");
	if not IsValid(t.Entity) then return end
	if (not t.Entity:GetClass():find("stargate_")) then return end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local e = self:SpawnSENT(p,t,toggle,activate,deactivate);
	if (not IsValid(e)) then return end
	local stargate = false;
	if(IsValid(t.Entity) and t.Entity.IsStargate) then
		for _,v in pairs(ents.FindInSphere(t.Entity:GetPos(),10)) do
			if(v.IsIris and v ~= e) then
				v:Remove(); -- Remove old, existing iri's (replace them with this new one)
			end
		end
	end
	e.GateLink = t.Entity;
	if (t.Entity.GateSpawnerSpawned) then
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
		Label="Toggle:",
		Command="goauld_iris_toggle",
	});
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label="Activate:",
		Command="goauld_iris_activate",
		Label2="Deactivate:",
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