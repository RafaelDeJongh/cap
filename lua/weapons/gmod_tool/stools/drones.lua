/*
	Stargate Staff Weapon Tool for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

--################# Header
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("entweapon") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Weapons";
TOOL.Name=SGLanguage.GetMessage("stool_drones");

-- The keys for the numpad. 1 is shoot, 2 is explode all current shots
TOOL.ClientConVar["explode"] = KEY_PAD_MINUS;
TOOL.ClientConVar["shoot"] = KEY_PAD_0;
TOOL.ClientConVar["track"] = KEY_PAD_1;
TOOL.ClientConVar["eye_track"] = KEY_PAD_2;
TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/props_trainstation/trashcan_indoor001b.mdl";
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "DroneLauncherModels"; -- The listname of garrys "List" Module we use for models
list.Set(TOOL.List,"models/props_borealis/bluebarrel001.mdl",{});
list.Set(TOOL.List,"models/props_c17/furnitureboiler001a.mdl",{});
list.Set(TOOL.List,"models/props_c17/canister_propane01a.mdl",{});
list.Set(TOOL.List,"models/props_c17/canister01a.mdl",{});
list.Set(TOOL.List,"models/props_c17/canister02a.mdl",{});
list.Set(TOOL.List,"models/combine_helicopter/helicopter_bomb01.mdl",{});
list.Set(TOOL.List,"models/props_junk/propane_tank001a.mdl",{});
list.Set(TOOL.List,"models/props_junk/propanecanister001a.mdl",{});
list.Set(TOOL.List,"models/props_trainstation/trashcan_indoor001b.mdl",{});
list.Set(TOOL.List,"models/props_wasteland/buoy01.mdl",{});
if (file.Exists("models/props_c17/pottery05a.mdl","GAME")) then
	list.Set(TOOL.List,"models/props_c17/pottery05a.mdl",{});
end
list.Set(TOOL.List,"models/props_junk/popcan01a.mdl",{});

-- Information about the SENT to spawn
TOOL.Entity.Class = "drone_launcher";
TOOL.Entity.Keys = {"shoot","explode","track","model","eye_track"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 2;

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_drones_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_drones_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_drones_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_drones_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_drones_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_drones_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_drones_limit");
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local shoot = self:GetClientNumber("shoot");
	local explode = self:GetClientNumber("explode");
	local track = self:GetClientNumber("track");
	local model = self:GetClientInfo("model");
	local eye_track = self:GetClientNumber("eye_track");
	--######## Spawn SENT
	local e = self:SpawnSENT(p,t,shoot,explode,track,model,eye_track);
	if(util.tobool(self:GetClientNumber("autolink"))) then
		self:AutoLink(e,t.Entity); -- Link to that energy system, if valid
	end
	--######## Weld things?
	local c = self:Weld(e,t.Entity,util.tobool(self:GetClientNumber("autoweld")));
	--######## Cleanup and undo register
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	return true;
end

--################# The PreEntitySpawn function is called before a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PreEntitySpawn(p,e,shoot,explode,track,model,eye_track)
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,shoot,explode,track,model,eye_track)
	if(shoot) then
		numpad.OnDown(p,shoot,"DroneOn",e);
		numpad.OnUp(p,shoot,"DroneOff",e);
	end
	if(explode) then
		numpad.OnDown(p,explode,"DroneExplode",e);
	end
	-- Track (Wire or Players)
	if(track) then
		numpad.OnDown(p,track,"DroneTrackOn",e);
		numpad.OnUp(p,track,"DroneTrackOff",e);
	end
	-- Track by EyeTrace
	if(eye_track) then
		numpad.OnDown(p,eye_track,"DroneEyeOn",e);
		numpad.OnUp(p,eye_track,"DroneEyeOff",e);
	end
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_drones_shoot"),
		Command="drones_shoot",
		Label2=SGLanguage.GetMessage("stool_drones_kill"),
		Command2="drones_explode",
	});
	local auto_track = StarGate.CFG:Get("drone","auto_track");
	local eye_track = StarGate.CFG:Get("drone","eye_track");
	if((StarGate.HasWire or auto_track) and eye_track) then
		-- Allow both tracking
		Panel:AddControl("Numpad",{
			ButtonSize=22,
			Label=SGLanguage.GetMessage("stool_drones_track"),
			Command="drones_track",
			Label2=SGLanguage.GetMessage("stool_drones_eye_track"),
			Command2="drones_eye_track",
		});
	elseif(auto_track) then
		-- Only autotrack
		Panel:AddControl("Numpad",{
			ButtonSize=22,
			Label=SGLanguage.GetMessage("stool_drones_track"),
			Command="drones_track",
		});
	elseif(eye_track) then
		-- Only eye track
		Panel:AddControl("Numpad",{
			ButtonSize=22,
			Label=SGLanguage.GetMessage("stool_drones_eye_track"),
			Command="drones_eye_track",
		});
	end
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="drones_model",Category="",Models=self.Models});
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"drones_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"drones_autolink"):SetToolTip(SGLanguage.GetMessage("stool_autolink_desc"));
	end
end

--################# Numpad shoot bindings - Only for the server
if SERVER then
	numpad.Register("DroneOn",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:TriggerInput("Launch",1);
		end
	);
	numpad.Register("DroneOff",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:TriggerInput("Launch",0);
		end
	);
	numpad.Register("DroneExplode",
		function(p,e)
			if(not e:IsValid()) then return false end
			e:KillDrones();
		end
	);
	numpad.Register("DroneTrackOn",
		function(p,e)
			if(not (StarGate.CFG:Get("drone","auto_track") or StarGate.HasWire)) then return end;
			if(not e:IsValid()) then return end;
			e.HasTrackedBefore = e.Track;
			e.Track = true;
			e:ShowOutput();
		end
	);
	numpad.Register("DroneTrackOff",
		function(p,e)
			if(not (StarGate.CFG:Get("drone","auto_track") or StarGate.HasWire)) then return end;
			if(not e:IsValid()) then return end;
			if(not e.HasTrackedBefore) then
				e.Track = false;
				e:ShowOutput();
			end
		end
	);
	numpad.Register("DroneEyeOn",
		function(p,e)
			if(not StarGate.CFG:Get("drone","eye_track")) then return end;
			if(not e:IsValid()) then return end;
			e.HasTrackedBefore = e.Track;
			e.EyeTrack = true;
			e.Track = true;
			e:ShowOutput();
		end
	);
	numpad.Register("DroneEyeOff",
		function(p,e)
			if(not StarGate.CFG:Get("drone","eye_track")) then return end;
			if(not e:IsValid()) then return end;
			e.EyeTrack = false;
			if(not e.HasTrackedBefore) then
				e.Track = false;
				e:ShowOutput();
			end
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();