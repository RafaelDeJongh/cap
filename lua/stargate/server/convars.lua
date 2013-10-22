--################################ DON'T EDIT THIS FILE YOU CAN MAKE CHANGES IN THE GAME!!!!!!!!!!!!!

	local limits = {
		{"Destiny Small Turret", "destsmall", 4},
		{"Destiny Medium Turret", "destmedium", 2},
		{"Destiny MainWeapon", "destmain", 1},
		{"Tollana Ion Cannon", "ioncannon", 6},
		{"Ship Railgun", "shiprail", 6},
		{"Stationary Railgun", "statrail", 2},
		--{"Ashend Defence System", "ashen", 20},
		{"Drone Launcher", "launchdrone", 2},
		{"MiniDrone Platform", "minidrone", 2},
		{"Asgard Turret", "asgbeam", 2},
		{"AG-3 Sattelites", "ag3", 6},
		{"Gate Overloader", "overloader", 1},
		{"Asuran Gate Weapon", "asuran_beam", 1},
		{"Ori Beam Weapon", "ori_beam", 2},
		{"Dakara Device", "dakara", 1},
		{"Shaped Charge", "dirn", 1},
		{"Horizon Platform", "horizon", 1},
		{"Ori Sattelite", "ori", 1},
		{"Staff Stationary", "staffstat", 2},
		{"KINO Dispenser", "dispenser", 1},
		{"Destiny Console", "destcon", 5},
		{"Destiny Apple Core", "applecore", 1},
		{"Lantean Holo Device", "lantholo", 1},
		{"Shield Core", "shieldcore",1},
		{"Sodan Obelisk", "sod_obelisk", 4},
		{"Ancient Obelisk", "anc_obelisk", 4},
		{"MCD", "mcd", 1}
	}
	local wepssett = {
		{"AG-3 Charge Time", "ag3_weapon", 60},
		{"AG-3 Health", "ag3_health", 500},
		{"Ori Satelitte Shield Time", "ori_shield", 120},
		{"Ori Satelitte Charge Time", "ori_weapon", 60},
		{"Ori Satelitte Helath", "ori_health", 500},
		{"Ship Railgun Damage", "shiprail_damage", 10},
		{"Stationary Railgun Damage", "statrail_damage", 10},
		{"Atlantis Shield Energy Consumption", "shieldcore_atlfrac", 50},
	}

	local miscsett = {
		{"Enable Ship Shields", "CAP_shipshield", 1},
		{"Allow Drop Weapons", "cap_drop_weapons", 1},
		{"Ashend Defence Require Energy", "cap_ashen_en", 1}
	}

	for _,val in pairs(limits) do
		CreateConVar("CAP_"..val[2].."_max", tostring(val[3]), {FCVAR_NEVER_AS_STRING})
	end

	for _,val in pairs(wepssett) do
		CreateConVar("CAP_"..val[2], tostring(val[3]), {FCVAR_NEVER_AS_STRING})
	end

	for _,val in pairs(miscsett) do
		CreateConVar(val[2], tostring(val[3]), {FCVAR_NEVER_AS_STRING})
	end

	-- From stargate group system by AlexALX

	-- Convars
	CreateConVar( "stargate_candial_groups_dhd", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_candial_groups_menu", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_candial_groups_wire", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_sgu_find_range", "16000", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_energy_dial", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_energy_dial_spawner", "0", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_dhd_protect", "0", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_dhd_protect_spawner", "0", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_dhd_destroyed_energy", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_dhd_close_incoming", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_show_inbound_address", "2", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_protect", "0", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_protect_spawner", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_block_address", "2", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_dhd_letters", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_energy_target", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_vgui_glyphs", "2", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_dhd_menu", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_atlantis_override", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_dhd_ring", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_different_dial_menu", "0", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_gatespawner_enabled", "1", {FCVAR_ARCHIVE} )
	local count = cvars.GetConVarCallbacks("stargate_gatespawner_enabled") or {}; -- add callback only once
	if (table.Count(count)==0) then
		cvars.AddChangeCallback("stargate_gatespawner_enabled", function(CVar, PreviousValue, NewValue)
			if (util.tobool(tonumber(PreviousValue))==util.tobool(tonumber(NewValue)) or not (StarGate and StarGate.GateSpawner and StarGate.GateSpawner.InitialSpawn)) then return end
			timer.Remove("stargate_gatespawner_reload");
			timer.Create("stargate_gatespawner_reload",0.5,1,function() StarGate.GateSpawner.InitialSpawn(true) end);
		end);
	end
	CreateConVar( "stargate_gatespawner_protect", "1", {FCVAR_ARCHIVE} )
	local count = cvars.GetConVarCallbacks("stargate_gatespawner_protect") or {}; -- add callback only once
	if (table.Count(count)==0) then
		cvars.AddChangeCallback("stargate_gatespawner_protect", function(CVar, PreviousValue, NewValue)
			if (util.tobool(tonumber(PreviousValue))==util.tobool(tonumber(NewValue))) then return end
			if (StarGate and StarGate.GateSpawner and StarGate.GateSpawner.Spawned) then
				local protect = util.tobool(tonumber(NewValue));
				for k,v in pairs(StarGate.GateSpawner.Ents) do
					if(v.Entity and IsValid(v.Entity)) then
						v.Entity.GateSpawnerProtected = protect;
						v.Entity:SetNetworkedBool("GateSpawnerProtected",protect);
					end
				end
			end
		end);
	end
	CreateConVar( "stargate_physics_clipping", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_model_clipping", "1", {FCVAR_ARCHIVE} )
	CreateConVar( "stargate_open_effect", "1", {FCVAR_ARCHIVE} )

	CreateConVar( "stargate_group_system", "1", { FCVAR_NOTIFY, FCVAR_GAMEDLL, FCVAR_ARCHIVE } )
	local count = cvars.GetConVarCallbacks("stargate_group_system") or {}; -- add callback only once
	if (table.Count(count)==0) then
		cvars.AddChangeCallback("stargate_group_system", function(CVar, PreviousValue, NewValue)
			net.Start("stargate_systemtype");
			net.WriteBit(util.tobool(NewValue));
			net.Broadcast();
		end);
	end
	util.AddNetworkString( "stargate_systemtype" )

	-- send system type to client
	local function FirstSpawn( ply )
		net.Start("stargate_systemtype");
		net.WriteBit(util.tobool(GetConVarNumber("stargate_group_system")));
		net.Send(ply);
	end
	hook.Add("PlayerInitialSpawn", "StarGate.SystemType", FirstSpawn)