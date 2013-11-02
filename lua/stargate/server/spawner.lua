/*
	Stargate Auto-Spawner for GarrysMod10
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

if not SERVER then return end; -- Just to be sure

--##################################
--#### Spawning
--##################################

StarGate.GateSpawner = {};
StarGate.GateSpawner.Props = {}; -- Any props, attached to a stargate/ring
StarGate.GateSpawner.Gates = {}; -- Gates
StarGate.GateSpawner.DHDs = {}; -- DHDs
StarGate.GateSpawner.MDHDs = {}; -- Mobile DHDs
StarGate.GateSpawner.Ents = {};
StarGate.GateSpawner.RingBase = {}; -- Carter Stuff
StarGate.GateSpawner.RingPanel = {};
StarGate.GateSpawner.DestinyTimer = {};
StarGate.GateSpawner.SGULightUp = {};
StarGate.GateSpawner.FloorChev = {};
StarGate.GateSpawner.KinoDispenser = {};
StarGate.GateSpawner.DestinyConsole = {};
StarGate.GateSpawner.Ramp = {};
StarGate.GateSpawner.Brazier = {};
StarGate.GateSpawner.GravityController = {};
StarGate.GateSpawner.AtlantisTransporter = {};
StarGate.GateSpawner.Spawned = false;

-- ############### Load config @aVoN
function StarGate.GateSpawner.LoadConfig()
	local map = game.GetMap();
	local file = "lua/data/gatespawner_maps/"..map..".lua"
	if (GetConVar("stargate_group_system"):GetBool()) then
		file = "lua/data/gatespawner_group_maps/"..map..".lua"
	end
	local ini = INIParser:new(file,false,true);
	-- FIXME: Add config for Enabled/Disabled again
	if(ini) then
		StarGate.GateSpawner.Version = ((ini.gatespawner or {})[1] or {}).version; -- To determine the spawnheight
		StarGate.GateSpawner.Props = ini.prop_physics or {};
		StarGate.GateSpawner.Gates = ini.stargate or {};
		StarGate.GateSpawner.DHDs = ini.dhd or {};
		StarGate.GateSpawner.MDHDs = ini.mobile_dhd or {};
		StarGate.GateSpawner.DestinyTimer = ini.destiny_timer or {}; -- Carter Stuff
		StarGate.GateSpawner.DestinyConsole = ini.destiny_console or {};
		StarGate.GateSpawner.KinoDispenser = ini.kino_dispenser or {};
		StarGate.GateSpawner.RingBase = ini.ring_base or {};
		StarGate.GateSpawner.RingPanel = ini.ring_panel or {};
		StarGate.GateSpawner.SGULightUp = ini.sgu_stuff or {};
		StarGate.GateSpawner.FloorChev = ini.floorchevron or {};
		StarGate.GateSpawner.Ramp = ini.ramp or {};
		StarGate.GateSpawner.Brazier = ini.brazier or {};
		StarGate.GateSpawner.GravityController = ini.gravitycontroller or {};
		StarGate.GateSpawner.AtlantisTransporter = ini.atlantis_transporter or {};
		return true;
	end
	return false;
end

/* This code is for workshop, it is disabled.
local types = {
	base = {"stargate_sg1","stargate_atlantis","stargate_universe","dhd_sg1","dhd_atlantis","dhd_universe","dhd_city"},
}
local function GateSpawner_CheckModule(class,model)
	if (model and model!="" and not file.Exists("models/"..model,"GAME")) then return false end
	for k,v in pairs(types) do
		if (not StarGate.CheckModule(k)) then continue end
		for k2,v2 in pairs(v) do
			if (class:find(v2)) then return true end
		end
	end
	return false;
end  */

-- ############### Spawning function @aVoN
function StarGate.GateSpawner.Spawn(v,protect,k)
	if(v.position and v.classname) then
		if (StarGate_Group and StarGate_Group.Error == true or StarGate_Group==nil or StarGate_Group.Error==nil) then return end
		--if (not GateSpawner_CheckModule(v.classname,v.model)) then return end
		if (StarGate.CFG:Get("cap_disabled_ent",v.classname,false)) then return end
		local e = ents.Create(v.classname);
		if (not IsValid(e)) then return nil end
		e.GateSpawnerSpawned = true;
		e:SetNetworkedBool("GateSpawnerSpawned",true);
		e.GateSpawnerProtected = protect;
		e:SetNetworkedBool("GateSpawnerProtected",protect);
		local pos = Vector(unpack(v.position:TrimExplode(" ")));
		local IsGate = v.classname:find("stargate_");
		local IsGroupGate = (v.classname:find("stargate_") and v.classname != "stargate_supergate");
		local IsDHD = v.classname:find("dhd_");

		local IsRing = v.classname:find("ring_base_");
		local IsRingP = v.classname:find("ring_panel_");
		local IsRingAncient = v.classname:find("ring_base_ancient");
		local IsRingOri = v.classname:find("ring_base_ori");
		local IsRingGoauld = v.classname:find("ring_base_goauld");
		local IsGravityController = string.lower(v.classname):find("gravitycontroller");
		local IsAtlantisTransporter = string.lower(v.classname):find("atlantis_transporter");

		local IsSGULightUp = v.classname:find("bearing") or v.classname:find("floorchevron");

		if(not StarGate.GateSpawner.Version and IsGate) then
			pos = pos + Vector(0,0,87); -- Or gate would stuck in the ground
		end
		e.CDSIgnore = true; -- Fixes Combat Damage System destroying Ramps - http://mantis.39051.vs.webtropia.com/view.php?id=45
		e:SetPos(pos);
		-- Set model (if not a gate and valid key exists)
		if(not IsGate and v.model) then
			e:SetModel(v.model);
		end

		-- Enable gravity controllers
		if(IsGravityController) then
			local convtable={
				["iActivateKey"]		= {0, 0},
				["fAirbrakeX"]		= {0, 15},
				["fAirbrakeY"]		= {0, 15},
				["fAirbrakeZ"]		= {0, 15},
				["fBrakePercent"]		= {0, 10},
				["sModel"]			= {1, v.model},
				["sSound"]			= {1, v.sound},
				["bAngularBrake"]		= {2, 0},
				["bGlobalBrake"]		= {2, 1},
				["bDrawSprite"]		= {0, 1},
				["bAlwaysBrake"]		= {0, 0},
				["bBrakeOnly"]		= {0, 0},
				["iKeyUp"]			= {0, 7},
				["iKeyDown"]			= {0, 4},
				["iKeyHover"]		= {0, 1},
				["fHoverSpeed"]		= {0, 1},
				["bSHHoverDesc"]	= {2, 1},
				["bSHLocalDesc"]		= {2, 1},
				["fAngBrakePerc"]		= {0, 20},
				["fWeight"]			= {0, 0},
				["bRelativeToGrnd"]	= {2, 0},
				["fHeightAboveGrnd"]	= {0, 30},
				["bSGAPowerNode"]	= {2, 1},
				["bLiveGravity"]		={0,0},
			}
			e.ConTable=table.Copy(convtable)
		end

		-- Need to set some stuff for rings, just like with stargates
		if(IsRingAncient) then
			e:SetModel("models/Madman07/ancient_rings/cover.mdl");
			e.RingModel = "models/Madman07/ancient_rings/ring.mdl";
			e.BaseModel = "models/Madman07/ancient_rings/cover.mdl";
			e.OriFix = 0;
		end
		if(IsRingOri) then
			e:SetModel("models/Boba_Fett/rings/ori_base.mdl");
			e.RingModel = "models/Boba_Fett/rings/ori_ring.mdl";
			e.BaseModel = "models/Boba_Fett/rings/ori_base.mdl";
			e.OriFix = 1;
		end
		if(IsRingGoauld) then
			e:SetModel("models/Madman07/ancient_rings/ring.mdl");
			e.RingModel = "models/Madman07/ancient_rings/ring.mdl";
			e.BaseModel = "models/Madman07/ancient_rings/ring.mdl";
			e.OriFix = 0;
		end
		if(IsGateBearing) then
			e:SetModel("models/Iziraider/gatebearing/bearing.mdl");
		end

		-- Spawn the gate a bit later. And we need to spawn it before anyone sets the angles, or it will look weird
		timer.Simple(0.1*k,
			function()
				if(not IsValid(e)) then return end; -- WHY DID THIS HAPPEN? SHOULD NEVER!
				e:Spawn();
				-- Set angles only AFTER we spawned the prop to avoid chevrons being added incorrectly
				if(v.angles) then
					local p,y,r = unpack(v.angles:TrimExplode(" "));
					e:SetAngles(Angle(tonumber(p),tonumber(y),tonumber(r)));
				end
				-- freeze stuff now
				local phys = e:GetPhysicsObject();
				if(phys:IsValid()) then phys:EnableMotion(false); end
				-- Set the address of a gate
				if (IsGate) then
					if(v.address and v.address ~= "") then
						e:SetGateAddress(v.address:upper());
					end
					if (IsGroupGate and GetConVar("stargate_group_system"):GetBool()) then
						if(v.group and v.group ~= "") then
							e:SetGateGroup(string.Replace(v.group:upper(),"!","#"));
						end
						if(v.locale ~= nil and v.locale ~= "") then
							e:SetLocale(util.tobool(v.locale));
						end
					elseif (IsGroupGate) then
						if(v.galaxy ~= nil and v.galaxy ~= "") then
							e:SetGalaxy(util.tobool(v.galaxy));
						end
					end
					if(v.name and v.name ~= "") then
						e:SetGateName(v.name);
					end
					if(v.private ~= nil and v.private ~= "") then
						e:SetPrivate(util.tobool(v.private));
					end
					if(v.blocked ~= nil and v.blocked ~= "") then
						e:SetBlocked(util.tobool(v.blocked));
					end
					e:CheckRamp();
					if(v.chevdestroyed ~= nil and v.chevdestroyed ~= "" and v.chevdestroyed) then
						e.ChevDestroyed = util.tobool(v.chevdestroyed);
					end
					-- damn, i should make it manualy...
					if(v.chevdestroyed1 ~= nil and v.chevdestroyed1 ~= "" and v.chevdestroyed1) then
						e.chev_destroyed[1] = util.tobool(v.chevdestroyed1);
						e.Chevron[1]:Remove();
					end
					if(v.chevdestroyed2 ~= nil and v.chevdestroyed2 ~= "" and v.chevdestroyed2) then
						e.chev_destroyed[2] = util.tobool(v.chevdestroyed2);
						e.Chevron[2]:Remove();
					end
					if(v.chevdestroyed3 ~= nil and v.chevdestroyed3 ~= "" and v.chevdestroyed3) then
						e.chev_destroyed[3] = util.tobool(v.chevdestroyed3);
						e.Chevron[3]:Remove();
					end
					if(v.chevdestroyed4 ~= nil and v.chevdestroyed4 ~= "" and v.chevdestroyed4) then
						e.chev_destroyed[4] = util.tobool(v.chevdestroyed4);
						e.Chevron[4]:Remove();
					end
					if(v.chevdestroyed5 ~= nil and v.chevdestroyed5 ~= "" and v.chevdestroyed5) then
						e.chev_destroyed[5] = util.tobool(v.chevdestroyed5);
						e.Chevron[5]:Remove();
					end
					if(v.chevdestroyed6 ~= nil and v.chevdestroyed6 ~= "" and v.chevdestroyed6) then
						e.chev_destroyed[6] = util.tobool(v.chevdestroyed6);
						e.Chevron[6]:Remove();
					end
					if(v.chevdestroyed7 ~= nil and v.chevdestroyed7 ~= "" and v.chevdestroyed7) then
						e.chev_destroyed[7] = util.tobool(v.chevdestroyed7);
						e.Chevron[7]:Remove();
					end
					if(v.chevdestroyed8 ~= nil and v.chevdestroyed8 ~= "" and v.chevdestroyed8) then
						e.chev_destroyed[8] = util.tobool(v.chevdestroyed8);
						e.Chevron[8]:Remove();
					end
					if(v.chevdestroyed9 ~= nil and v.chevdestroyed9 ~= "" and v.chevdestroyed9) then
						e.chev_destroyed[9] = util.tobool(v.chevdestroyed9);
						e.Chevron[9]:Remove();
					end
					if (v.sgctype ~= nil and v.sgctype~="") then
						e.RingInbound = true;
						e:SetNWBool("ActSGCT",true);
					end
					if (v.classname=="stargate_infinity" and v.sg1eh ~= nil and v.sg1eh~="") then
						e.InfDefaultEH = true;
						e:SetNWBool("ActInf_SG1_EH",true);
					end
					if (v.chevlight ~= nil and v.chevlight ~="") then
						e.ChevLight = true;
						e:SetNWBool("ActMChevL",true);
					end
					if (v.classic ~= nil and v.classic ~="") then
						e.Classic = true;
						e:SetNWBool("ActMCl",true);
					end
				elseif (IsDHD) then
					if(v.destroyed ~= nil and v.destroyed ~= "" and util.tobool(v.destroyed)==true and e:GetClass() != "dhd_concept" and e:GetClass() != "dhd_city") then
						e.Healthh = 0;
						e:DestroyEffect(true);
					end
					if (v.slowmode ~= nil and v.slowmode ~= "" and util.tobool(v.slowmode)==true and (e:GetClass()=="dhd_city" or e:GetClass()=="dhd_atlantis")) then
						e.DisRingRotate = true;
						e:SetNWBool("DisRingRotate",true);
					end
					if (v.disablering ~= nil and v.disablering ~= "" and util.tobool(v.disablering)==true and e:GetClass()!="dhd_city" and e:GetClass()!="dhd_atlantis" and e:GetClass()!="dhd_universe") then
						e.DisRingRotate = true;
						e:SetNWBool("DisRingRotate",true);
					end
				elseif (IsRingAncient or IsRingOri or IsRingGoauld) then
					e:CheckRamp();
					-- And rings Rings
					if(v.address and v.address ~= "") then
						e.Address = v.address;
						e:SetNetworkedString("address",v.address);
					end
				elseif (IsSGULightUp) then -- Weld sgu stuff to nearest gates
					for _,v in pairs(ents.FindInSphere(pos, 200)) do
						if (IsValid(v) and v.IsStargate and v:GetClass() == "stargate_universe") then
							local const=constraint.Weld(e, v,0, 0, 0, sgu_weld_manager);
						end
					end
				elseif(IsGravityController) then
					local phys = e:GetPhysicsObject(); -- hey, unfreeze me!
					if IsValid(phys) then phys:SetMass(200); phys:EnableMotion(true); end

					// weld to the gates
					for _,sg in pairs(ents.FindInSphere(pos, 200)) do
						if (IsValid(sg) and sg.IsStargate) then
							local const=constraint.Weld(e, sg, 0, 0, 0, systemmanager)
							local nocollide=constraint.NoCollide( e, sg, 0, 0)
							-- fix by AlexALX
							sg.GateSpawnerGrav = sg.GateSpawnerGrav or {};
							table.insert(sg.GateSpawnerGrav,e);
							if (table.Count(sg.GateSpawnerGrav)==3) then
								local phys = sg:GetPhysicsObject();
								if IsValid(phys) then phys:EnableMotion(true); end
								for _,grav in pairs(sg.GateSpawnerGrav) do
									if (IsValid(grav)) then
										grav:ActivateIt(true);
									end
								end
								sg.GateSpawnerGrav = nil;
							end
						end
					end
				elseif(IsAtlantisTransporter) then
					e:CreateDoors(true,protect);
					if (v.name ~= nil and v.name ~="") then
                		e:SetAtlName(v.name,true);
                	end
					if (v.private ~= nil and v.private ~="" and util.tobool(v.private)==true) then
                		e:SetAtlPrivate(v.private);
                	end
					if (v.onlyclosed ~= nil and v.onlyclosed ~="" and util.tobool(v.onlyclosed)==true) then
                		e.OnlyClosed = true;
                	end
					if (v.autoopen ~= nil and v.autoopen ~="" and util.tobool(v.autoopen)==false) then
                		e.NoAutoOpen = true;
                	end
					if (v.autoclose ~= nil and v.autoclose ~="" and util.tobool(v.autoclose)==false) then
                		e.NoAutoClose = true;
                	end
				end
				if (v.__id and e:GetClass()=="prop_physics") then
					for _,vv in pairs(ents.FindByClass("stargate_*")) do
						if(vv.__id == v.__id) then
							constraint.Weld(e,vv,0,0,0,true);
							break;
						end
					end
					for _,vv in pairs(ents.FindByClass("ring_base_*")) do
						if(vv.__id == v.__id) then
							constraint.Weld(e,vv,0,0,0,true);
							break;
						end
					end
					for _,vv in pairs(ents.FindByClass("ring_panel_*")) do
						if(vv.__id == v.__id) then
							constraint.Weld(e,vv,0,0,0,true);
							break;
						end
					end
				elseif(v.__id and (IsGate or IsRing or IsRingP)) then
					e.__id = v.__id;
				end
			end
		);
		return e;
	end
	return nil;
end

-- ############### Reset gatespawner by AlexALX
function StarGate.GateSpawner.Reset()
	StarGate.GateSpawner.Props = {};
	StarGate.GateSpawner.Gates = {}; -- Gates
	StarGate.GateSpawner.DHDs = {}; -- DHDs
	StarGate.GateSpawner.MDHDs = {}; -- Mobile DHDs
	StarGate.GateSpawner.Ents = {};
	StarGate.GateSpawner.RingBase = {}; -- Carter Stuff
	StarGate.GateSpawner.RingPanel = {};
	StarGate.GateSpawner.DestinyTimer = {};
	StarGate.GateSpawner.SGULightUp = {};
	StarGate.GateSpawner.FloorChev = {};
	StarGate.GateSpawner.KinoDispenser = {};
	StarGate.GateSpawner.DestinyConsole = {};
	StarGate.GateSpawner.Ramp = {};
	StarGate.GateSpawner.Brazier = {};
	StarGate.GateSpawner.GravityController = {};
	StarGate.GateSpawner.AtlantisTransporter = {};
	StarGate.GateSpawner.Spawned = false;
end

-- ############### Initial spawn handling @aVoN
function StarGate.GateSpawner.InitialSpawn(reload)
	-- First, remove all previous gate_spawner gates.
	local remove = {
		ents.FindByClass("stargate_*"),
		ents.FindByClass("dhd_*"),
		ents.FindByClass("mobile_dhd"),
		ents.FindByClass("ring_*"),
		ents.FindByClass("bearing"),
		ents.FindByClass("brazier"),
		ents.FindByClass("floorchevron"),
		ents.FindByClass("destiny_timer"),
		ents.FindByClass("destiny_console"),
		ents.FindByClass("kino_dispenser"),
		ents.FindByClass("ramp"),
		ents.FindByClass("ramp_2"),
		ents.FindByClass("future_ramp"),
		ents.FindByClass("sgc_ramp"),
		ents.FindByClass("sgu_ramp"),
		ents.FindByClass("goauld_ramp"),
		ents.FindByClass("gravitycontroller"),
		ents.FindByClass("atlantis_transporter"),
		ents.FindByClass("prop_physics"),
	};
	for _,v in pairs(remove) do
		for _,e in pairs(v) do
			if(e.GateSpawnerSpawned) then
				e:Remove();
			end
		end
	end
	if(not StarGate.GateSpawner.Spawned or reload) then
		if (reload) then StarGate.GateSpawner.Reset(); end
		if (GetConVar("stargate_gatespawner_enabled"):GetBool() and StarGate.GateSpawner.LoadConfig()) then
			-- FIXME: Add config for enabled/disabled again
			-- sorry old or wrong gatespawner
			StarGate.GateSpawner.Spawned = true;
			local groupsystem = GetConVar("stargate_group_system"):GetBool();
			if (StarGate.GateSpawner.Version == "3" and groupsystem) then
				ErrorNoHalt("StarGate GateSpawner Error:\nYour gatespawner file is for Galaxy System, it is not compatible with Group System.\nPlease create new gatespawner or switch to Galaxy System.\n"); return
			elseif (StarGate.GateSpawner.Version == "3 Group" and not groupsystem) then
				ErrorNoHalt("StarGate GateSpawner Error:\nYour gatespawner file is for Group System, it is not compatible with Galaxy System.\nPlease create new gatespawner or switch to Group System.\n"); return
			elseif (StarGate.GateSpawner.Version == "2" or StarGate.GateSpawner.Version == "1") then
				ErrorNoHalt("StarGate GateSpawner Error:\nYour gatespawner file is for old aVoN stargate addon, it is not compatible with CAP.\nPlease create new gatespawner.\n"); return
			elseif (StarGate.GateSpawner.Version != "3" and StarGate.GateSpawner.Version != "3 Group") then
				ErrorNoHalt("StarGate GateSpawner Error:\nYour gatespawner file is invalid.\nPlease create new gatespawner.\n"); return
			end

			local protect = GetConVar("stargate_gatespawner_protect"):GetBool();
			local i = 0; -- For delayed spawning

			for _,v in pairs(StarGate.GateSpawner.Ramp) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.Gates) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.DHDs) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.MDHDs) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.DestinyTimer) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.DestinyConsole) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.KinoDispenser) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.RingBase) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.RingPanel) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.Brazier) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.SGULightUp) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.GravityController) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.AtlantisTransporter) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end
			for _,v in pairs(StarGate.GateSpawner.Props) do
				table.insert(StarGate.GateSpawner.Ents,{Entity=StarGate.GateSpawner.Spawn(v,protect,i),SpawnData=v});
				i = i + 1;
			end

			StarGate.GateSpawner.Spawned = true;
		end
	end
end

-- ############### Auto Respawner @aVoN
function StarGate.GateSpawner.AutoRespawn()
	-- FIXME: Add config for enabled/disabled again
	if(DEBUG) then return end;
	--if(StarGate.spawner_enabled and StarGate.spawner_autorespawn) then
	if (StarGate.GateSpawner.Spawned) then
		local add = {};
		local i = 0; -- For delayed spawning
		for k,v in pairs(StarGate.GateSpawner.Ents) do
			local protect = GetConVar("stargate_gatespawner_protect"):GetBool();
			if(not v.Entity or not v.Entity:IsValid()) then
				table.insert(add,{Entity=StarGate.GateSpawner.Spawn(v.SpawnData,protect,i),SpawnData=v.SpawnData});
				i = i + 1;
				StarGate.GateSpawner.Ents[k] = nil;
			end
		end
		for _,v in pairs(add) do
			table.insert(StarGate.GateSpawner.Ents,v);
		end
	end
end

-- ############### Init @aVoN
timer.Simple(2,function() StarGate.GateSpawner.InitialSpawn() end); -- Spawn them, 2 seconds after the map start
timer.Create("StarGate.GateSpawner.AutoRespawn",3,0,function() StarGate.GateSpawner.AutoRespawn() end); -- Check for existance every 3 seconds

--##################################
--#### Creating of spawnfils
--##################################


-- This script works the following way: Spawn your gates and DHDs, set the addrese and run this script by console with the following command: stargate_creategatespawner_file
-- Now, a new file called <the name of the map>.txt has been created in garrysmod/data/
-- Copy this file to garrysmod/addons/stargate/data/gatespawner_group_maps and remove the .txt extension so it only looks up like <the name of the map>.ini
-- Now your gates will autospawn on that specific map
-- YOU NEED TO BE ADMIN TO PERFORM THIS COMMAND!

-- ############### Gatespawner creation command @aVoN
concommand.Add("stargate_gatespawner_createfile",
	function(p)
		if(not IsValid(p) or p:IsAdmin()) then
			local f = "[gatespawner]\nversion = 3\n\n\n";
			local gatefolder = "gatespawner_maps";
			local groupsystem = false;
			if (GetConVar("stargate_group_system"):GetBool()) then
				f = "[gatespawner]\nversion = 3 Group\n\n\n";
				gatefolder = "gatespawner_group_maps";
				groupsystem = true;
			end
			-- Gates and Attachments
			local already_added = {};

			local props = "";

			-- Gates
			for _,v in pairs(ents.FindByClass("stargate_*")) do
				if(v.IsStargate) then
					local blocked = "";
					if (v:GetBlocked()) then blocked="blocked=true\n"; end
					if (v.IsGroupStargate and groupsystem) then
						f = f .. "[stargate]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\naddress="..v:GetGateAddress().."\ngroup="..string.Replace(v:GetGateGroup(),"#","!").."\nname="..v:GetGateName().."\nprivate="..tostring(v:GetPrivate()).."\nlocale="..tostring(v:GetLocale()).."\n"..blocked;
						if (v.ChevDestroyed) then f = f .. "chevdestroyed="..tostring(v.ChevDestroyed).."\n"; end
						for i=1,9 do
							if (v.chev_destroyed and v.chev_destroyed[i]) then
								f = f .. "chevdestroyed"..i.."="..tostring(v.chev_destroyed[i]).."\n";
							end
						end
					elseif (v.IsGroupStargate) then
						f = f .. "[stargate]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\naddress="..v:GetGateAddress().."\nname="..v:GetGateName().."\nprivate="..tostring(v:GetPrivate()).."\ngalaxy="..tostring(v:GetGalaxy()).."\n"..blocked;
						if (v.ChevDestroyed) then f = f .. "chevdestroyed="..tostring(v.ChevDestroyed).."\n"; end
						for i=1,9 do
							if (v.chev_destroyed and v.chev_destroyed[i]) then
								f = f .. "chevdestroyed"..i.."="..tostring(v.chev_destroyed[i]).."\n";
							end
						end
					else
						f = f .. "[stargate]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\naddress="..v:GetGateAddress().."\nname="..v:GetGateName().."\nprivate="..tostring(v:GetPrivate()).."\n";
					end
					if (v.IsStargate) then
						local gate = v;
						local first = true
						for _,v in pairs(StarGate.GetConstrainedEnts(v,2) or {}) do
							if(v ~= gate and v:GetClass() == "prop_physics" and IsValid(v)) then
								if (first) then
									f = f .."__id="..gate:EntIndex().."\n"
									first = false
								end
								already_added[v] = true;
								props = props.."[prop_physics]\nclassname=prop_physics\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..v:GetModel().."\n__id="..gate:EntIndex().."\n";
							end
						end
					end
					if (v.RingInbound) then
						f = f .. "sgctype=true\n";
					end
					if (v:GetClass()=="stargate_infinity" and v.InfDefaultEH) then
						f = f .. "sg1eh=true\n";
					end
					if (v.ChevLight or v.SpChevLight) then
						f = f .. "chevlight=true\n";
					end
					if (v.Classic or v.SpClassic) then
						f = f .. "classic=true\n";
					end
				end
			end
			for _,v in pairs(ents.FindByClass("dhd_*")) do
				if (v:GetClass()!="dhd_city" and v:GetClass()!="dhd_concept") then
					f = f .. "[dhd]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\ndestroyed="..tostring(v.Destroyed).."\n";
				else
					f = f .. "[dhd]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
				end
				if (v.DisRingRotate) then
					if (v:GetClass()=="dhd_city" or v:GetClass()=="dhd_atlantis") then
						f = f .. "slowmode=true\n"
					else
						f = f .. "disablering=true\n"
					end
				end
			end

			-- Mobile DHDs
			for _,v in pairs(ents.FindByClass("mobile_dhd")) do
				f = f .. "[mobile_dhd]\nclassname=mobile_dhd\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
			end

			-- Carter Stuff
			for _,v in pairs(ents.FindByClass("bearing")) do
				f = f .. "[sgu_stuff]\nclassname=bearing\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
			end
			for _,v in pairs(ents.FindByClass("floorchevron")) do
				f = f .. "[sgu_stuff]\nclassname=floorchevron\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
			end
			for _,v in pairs(ents.FindByClass("destiny_timer")) do
				f = f .. "[destiny_timer]\nclassname=destiny_timer\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
			end
			for _,v in pairs(ents.FindByClass("destiny_console")) do
				f = f .. "[destiny_console]\nclassname=destiny_console\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
			end
			for _,v in pairs(ents.FindByClass("kino_dispenser")) do
				f = f .. "[kino_dispenser]\nclassname=kino_dispenser\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
			end

			-- Rings
			for _,v in pairs(ents.FindByClass("ring_panel_*")) do
				f = f .. "[ring_panel]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
				local ringp = v;
				local first = true
				for _,v in pairs(StarGate.GetConstrainedEnts(v,2) or {}) do
					if(v ~= ringp and v:GetClass() == "prop_physics" and IsValid(v)) then
						if (first) then
							f = f .."__id="..ringp:EntIndex().."\n"
							first = false
						end
						already_added[v] = true;
						props = props.."[prop_physics]\nclassname=prop_physics\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..v:GetModel().."\n__id="..ringp:EntIndex().."\n";
					end
				end
			end
			for _,v in pairs(ents.FindByClass("ring_base_*")) do
				f = f .. "[ring_base]\nclassname="..v:GetClass().."\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\naddress="..(v.Address or "").."\n";
				local ring = v;
				local first = true
				for _,v in pairs(StarGate.GetConstrainedEnts(v,2) or {}) do
					if(v ~= ring and v:GetClass() == "prop_physics" and IsValid(v)) then
						if (first) then
							f = f .."__id="..ring:EntIndex().."\n"
							first = false
						end
						already_added[v] = true;
						props = props.."[prop_physics]\nclassname=prop_physics\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..v:GetModel().."\n__id="..ring:EntIndex().."\n";
					end
				end
			end

			for _,v in pairs(ents.FindByClass("brazier")) do
				f = f .. "[brazier]\nclassname=brazier\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
			end

			-- Ramps
			for _,v in pairs(ents.FindByClass("ramp")) do
				f = f .. "[ramp]\nclassname=ramp\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
			end
			for _,v in pairs(ents.FindByClass("ramp_2")) do
				f = f .. "[ramp]\nclassname=ramp_2\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
			end
			for _,v in pairs(ents.FindByClass("sgu_ramp")) do
				f = f .. "[ramp]\nclassname=sgu_ramp\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\n";
			end
			for _,v in pairs(ents.FindByClass("sgc_ramp")) do
				f = f .. "[ramp]\nclassname=sgc_ramp\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
			end
			for _,v in pairs(ents.FindByClass("future_ramp")) do
				f = f .. "[ramp]\nclassname=future_ramp\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
			end
			for _,v in pairs(ents.FindByClass("goauld_ramp")) do
				f = f .. "[ramp]\nclassname=goauld_ramp\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\n";
			end
			for _,v in pairs(ents.FindByClass("gravitycontroller")) do
				if v.ConTable["bSGAPowerNode"][2]==1 then //only nodes with SGAPowerNode Type
					f = f .. "[gravitycontroller]\nclassname=gravitycontroller\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nmodel="..tostring(v:GetModel()).."\nsound="..tostring(v.ConTable["sSound"][2]).."\n";
				end
			end
			for _,v in pairs(ents.FindByClass("atlantis_transporter")) do
				f = f .. "[atlantis_transporter]\nclassname=atlantis_transporter\nposition="..tostring(v:GetPos()).."\nangles="..tostring(v:GetAngles()).."\nname="..v.TName.."\n".."private="..tostring(v.TPrivate).."\n";
				if (v.OnlyClosed) then
               		f = f .. "onlyclosed=true\n";
               	end
				if (v.NoAutoOpen) then
               		f = f .. "autoopen=false\n";
               	end
				if (v.NoAutoClose) then
               		f = f .. "autoclose=false\n";
               	end
			end
			f = f .. props

			file.Write(game.GetMap():lower()..".txt",f);
			MsgN("=======================");
			MsgN("Gatespawner successfully created!");
			MsgN("File: garrysmod\\data\\"..game.GetMap():lower()..".txt");
			MsgN("Rename this file to "..game.GetMap():lower()..".lua and move it to garrysmod\\lua\\data\\"..gatefolder.." to make it work.");
			MsgN("Do not forget to reload the gatespawner or restart the map to have it take effect!");
			MsgN("=======================");
			if (IsValid(p)) then
				net.Start("CAP_GATESPAWNER");
				net.WriteString(game.GetMap():lower());
				net.WriteString(gatefolder);
				net.Send(p);
			end
		end
	end
);

util.AddNetworkString("CAP_GATESPAWNER");

concommand.Add("stargate_gatespawner_reload",
	function(p)
		if(not IsValid(p) or game.SinglePlayer() or p:IsAdmin()) then
			timer.Remove("stargate_gatespawner_reload");
			timer.Create("stargate_gatespawner_reload",0.5,1,function() StarGate.GateSpawner.InitialSpawn(true) end);
		end
	end
);