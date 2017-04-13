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
TOOL.Name=SGLanguage.GetMessage("stool_staff");

-- The keys for the numpad. 1 is shoot, 2 is explode all current shots
TOOL.ClientConVar["shoot"] = KEY_PAD_0;
TOOL.ClientConVar["explode"] = KEY_PAD_1;
TOOL.ClientConVar["autolink"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["shaft"] = 1;
TOOL.ClientConVar["explosion"] = 1;
TOOL.ClientConVar["explosion_colorize"] = 0;
TOOL.ClientConVar["r"] = 255;
TOOL.ClientConVar["g"] = 200;
TOOL.ClientConVar["b"] = 120;
TOOL.ClientConVar["add_cannon_velocity"] = 0;
-- The default model for the GhostPreview
TOOL.ClientConVar["model"] = "models/votekick/s_turret.mdl";
-- Holds modles for a selection in the tooltab and allows individual Angle and Position offsets {Angle=Angle(1,2,3),Position=Vector(1,2,3} for the GhostPreview
TOOL.List = "StaffWeaponModels"; -- The listname of garrys "List" Module we use for models
list.Set(TOOL.List,"models/votekick/s_turret.mdl",{});
list.Set(TOOL.List,"models/props_combine/combine_binocular01.mdl",{Angle=Angle(180,0,0)});
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
TOOL.Entity.Class = "staff_weapon_glider";
TOOL.Entity.Keys = {"shoot","explode","model","r","g","b","shaft","explosion","explosion_colorize","add_cannon_velocity"}; -- These keys will get saved from the duplicator
TOOL.Entity.Limit = 2;

-- Add the topic texts, you see in the upper left corner
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_staff_weapon_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_staff_weapon_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_staff_weapon_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_staff_weapon_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_staff_weapon_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_staff_weapon_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_staff_weapon_limit");
--################# Code

--################# LeftClick Toolaction @aVoN
function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(CLIENT) then return true end;
	local r = self:GetClientNumber("r");
	local g = self:GetClientNumber("g");
	local b = self:GetClientNumber("b");
	local shaft = self:GetClientNumber("shaft");
	local explosion = self:GetClientNumber("explosion");
	local explosion_colorize = self:GetClientNumber("explosion_colorize");
	local add_cannon_velocity = self:GetClientNumber("add_cannon_velocity");
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then
		t.Entity.Color = Color(r,g,b,255);
		t.Entity:SetNetworkedBool("shaft",util.tobool(shaft));
		t.Entity.DrawExplosion = util.tobool(explosion);
		t.Entity.ColorizeExplosion = util.tobool(explosion_colorize);
		t.Entity.AddCannonVelocity = util.tobool(add_cannon_velocity);
		-- THIS FUNCTIONS SAVES THE MODIFIED KEYS TO THE SENT, SO THEY ARE AVAILABLE WHEN COPIED WITH DUPLICATOR!
		t.Entity:UpdateKeys(_,_,_,r,g,b,shaft,explosion,explosion_colorize,add_cannon_velocity);
		return true;
	end
	if(not self:CheckLimit()) then return false end;
	local p = self:GetOwner();
	local shoot = self:GetClientNumber("shoot");
	local explode = self:GetClientNumber("explode");
	local model = self:GetClientInfo("model");
	--######## Spawn SENT
	local e = self:SpawnSENT(p,t,shoot,explode,model,r,g,b,shaft,explosion,explosion_colorize,add_cannon_velocity);
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
function TOOL:PreEntitySpawn(p,e,shoot,explode,model,r,g,b,shaft,explosion,explosion_colorize,add_cannon_velocity)
	local model = model or self.ClientConVar["model"];
	e:SetModel(model);
end

--################# The PostEntitySpawn function is called after a SENT got spawned. Either by the duplicator or with the stool.@aVoN
function TOOL:PostEntitySpawn(p,e,shoot,explode,model,r,g,b,shaft,explosion,explosion_colorize,add_cannon_velocity)
	if(shoot) then
		numpad.OnDown(p,shoot,"StaffOn",e);
		numpad.OnUp(p,shoot,"StaffOff",e);
	end
	if(explode) then
		numpad.OnDown(p,explode,"StaffExplode",e);
	end
	if(r and g and b) then
		e.Color = Color(r,g,b,255);
	end
	/*if(shaft) then
		e:SetNWBool("shaft",util.tobool(shaft));
	end
	e.DrawExplosion = true; */
	if(explosion) then
		e.Explosion = util.tobool(explosion);
	end      /*
	e.AddCannonVelocity = util.tobool(add_cannon_velocity);
	e.ColorizeExplosion = util.tobool(explosion_colorize);*/
	-- Little workaround for that special model - It is turned upside down by 180°, so we need to alter the shoot position and direction with "this"
	if(e:GetModel():find("combine_binocular01.mdl")) then
		e.ShootDirection = -1;
	end
end

--################# Controlpanel @aVoN
function TOOL:ControlsPanel(Panel)
	Panel:AddControl("ComboBox",{
		Label="Presets",
		MenuButton=1,
		Folder="staff_weapon",
		Options={
			Default=self:GetDefaultSettings(),
			["Goa'uld"] = {
				staff_weapon_r = 255,
				staff_weapon_g = 128,
				staff_weapon_b = 0,
				staff_weapon_shaft = 1,
				staff_weapon_explosion = 1,
				staff_weapon_explosion_colorize = 0,
			},
			["Bird of Prey"] = {
				staff_weapon_r = 0,
				staff_weapon_g = 255,
				staff_weapon_b = 100,
				staff_weapon_shaft = 1,
				staff_weapon_explosion = 1,
				staff_weapon_explosion_colorize = 1,
			},
			["Tuned Staff"] = {
				staff_weapon_r = 255,
				staff_weapon_g = 114,
				staff_weapon_b = 72,
				staff_weapon_shaft = 1,
				staff_weapon_explosion = 1,
				staff_weapon_explosion_colorize = 1,
			},
			["Quantum Torpedo"] = {
				staff_weapon_r = 108,
				staff_weapon_g = 255,
				staff_weapon_b = 228,
				staff_weapon_shaft = 0,
				staff_weapon_explosion = 0,
				staff_weapon_explosion_colorize = 0,
			},
		},
		CVars=self:GetSettingsNames(),
	});
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_staff_weapon_shoot"),
		Command="staff_weapon_shoot",
		Label2=SGLanguage.GetMessage("stool_staff_weapon_explode"),
		Command2="staff_weapon_explode",
	});
	Panel:AddControl("Color",{
		Label = SGLanguage.GetMessage("stool_staff_weapon_color"),
		Red = "staff_weapon_r",
		Green = "staff_weapon_g",
		Blue = "staff_weapon_b",
		ShowAlpha = 0,
		ShowHSV = 1,
		ShowRGB = 1,
		Multiplier = 255,
	});
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="staff_weapon_model",Category="",Models=self.Models});
	--Panel:CheckBox("Add Cannon's Velocity","staff_weapon_add_cannon_velocity"):SetToolTip("This will add the velocity of the cannon to the shot");
	--Panel:CheckBox("Draw Shaft","staff_weapon_shaft");
	Panel:CheckBox(SGLanguage.GetMessage("stool_staff_weapon_explosion"),"staff_weapon_explosion");
	--Panel:CheckBox("Colorize Explosion","staff_weapon_explosion_colorize");
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"staff_weapon_autoweld");
	if(StarGate.HasResourceDistribution) then
		Panel:CheckBox(SGLanguage.GetMessage("stool_autolink"),"staff_weapon_autolink"):SetToolTip(SGLanguage.GetMessage("stool_autolink_desc"));
	end
end

--################# Numpad shoot bindings - Only for the server
if SERVER then
	numpad.Register("StaffOn",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:TriggerInput("Fire",1);
		end
	);
	numpad.Register("StaffOff",
		function(p,e)
			if(not e:IsValid()) then return end;
			e:TriggerInput("Fire",0);
		end
	);
	numpad.Register("StaffExplode",
		function(p,e)
			if(not e:IsValid()) then return false end
			e:ExplodeShots();
		end
	);
end

--################# Register Stargate hooks. Needs to be called after all functions are loaded!
TOOL:Register();