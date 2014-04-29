if (StarGate.MiscLoaded) then return end -- prevent calling this file twice or more times

StarGate.MiscLoaded = true;

-- Materials
if (file.Exists("materials/boba_fett/textures/atlantisfloor.vmt","GAME")) then -- just once, if player will have it, then probably all others too.
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantisfloor" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantisfloor_dark" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantisfloor_grunge" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantisfloor_triangle" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantisfloor_tile" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantisfloor_purple" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantisfloor_white" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantiswall_red" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantiswall_green" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantiswall_blue" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantiswall_red_simple" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantiswall_red_dark_simple" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantiswall_coridor" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/atlantiswall_stair" )

	list.Add( "OverrideMaterials", "Boba_Fett/textures/destiny" )

	list.Add( "OverrideMaterials", "Zup/ramps/ramp_metal" )
	list.Add( "OverrideMaterials", "Boba_Fett/textures/catwalk_metal" )

	list.Add( "OverrideMaterials", "pyro_overloader/diffuse" )

	list.Add( "OverrideMaterials", "Iziraider/artifacts/quantum_mirror" )
	list.Add( "OverrideMaterials", "Iziraider/dakara/stone" )
	list.Add( "OverrideMaterials", "Iziraider/dakara/dark_stone" )
end

-- Buttons
list.Set( "ButtonModels", "models/Iziraider/destinybutton/destinybutton.mdl", {} )
list.Set( "ButtonModels", "models/Boba_Fett/props/buttons/atlantis_button.mdl", {} )
list.Set( "ButtonModels", "models/Iziraider/artifacts/asgard_stone.mdl", {} )

-- Add wire buttons
list.Set( "Wire_button_Models", "models/Iziraider/destinybutton/destinybutton.mdl", {} )
list.Set( "Wire_button_Models", "models/Boba_Fett/props/buttons/atlantis_button.mdl", {} )
list.Set( "Wire_button_Models", "models/Iziraider/artifacts/asgard_stone.mdl", {} )

-- Player models and NPCs
if (StarGate.CheckModule("npc")) then
local NPC =
{
	Name = SGLanguage.GetMessage("npc_wraith"),
	Class = "npc_metropolice",
	KeyValues = {},
	Model = "models/pg_props/pg_charaktere/pg_wraith_test.mdl",
	Health = "300",
	Category = SGLanguage.GetMessage("npc_cat"),
	Author = "ProgSys",
	Weapons = {"wraith_blaster"}
}

local NPC2 =
{
	Name = SGLanguage.GetMessage("npc_prior"),
	Class = "npc_metropolice",
	KeyValues = {},
	Model = "models/tiny/Playermodels/Prior_PM.mdl",
	Health = "200",
	Category = SGLanguage.GetMessage("npc_cat"),
	Author = "Tiny",
	Weapons = {"ori_staff_weapon"}
}

local NPC3 =
{
	Name = SGLanguage.GetMessage("npc_goauld"),
	Class = "npc_metropolice",
	KeyValues = {},
	Model = "models/ViktorK/player/anubis.mdl",
	Health = "200",
	Category = SGLanguage.GetMessage("npc_cat"),
	Author = "ViktorK",
	Weapons = {"weapon_staff"}
}

local NPC4 =
{
	Name = SGLanguage.GetMessage("npc_soldier"),
	Class = "npc_citizen",
	KeyValues =	{ citizentype = 4 },
	Model = "models/ViktorK/player/scout_tau.mdl",
	Health = "200",
	Category = SGLanguage.GetMessage("npc_cat"),
	Author = "ViktorK",
	Weapons = {"fnp90"}
}

-- needed or npc won't spawn + for add in stargate tab
list.Set( "CAP.NPC", "npc_wraith", NPC )
list.Set( "CAP.NPC", "npc_prior", NPC2 )
list.Set( "CAP.NPC", "npc_goauld", NPC3 )
list.Set( "CAP.NPC", "npc_sg_soldier", NPC4 )

list.Set( "PlayerOptionsModel",  "#pm_wraith", "models/pg_props/pg_charaktere/pg_wraith_player.mdl" )
list.Set( "PlayerOptionsModel",  "#pm_prior", "models/tiny/Playermodels/Prior_PM.mdl" )
list.Set( "PlayerOptionsModel",  "#pm_goauld", "models/ViktorK/player/anubis.mdl" )
list.Set( "PlayerOptionsModel",  "#pm_sg_soldier", "models/ViktorK/player/scout_tau.mdl" )

if (CLIENT) then
	language.Add("pm_wraith",SGLanguage.GetMessage("npc_wraith"))
	language.Add("pm_prior",SGLanguage.GetMessage("npc_prior"))
	language.Add("pm_goauld",SGLanguage.GetMessage("npc_goauld"))
	language.Add("pm_sg_soldier",SGLanguage.GetMessage("npc_soldier"))
end

player_manager.AddValidModel( "#pm_wraith", "models/pg_props/pg_charaktere/pg_wraith_player.mdl" )
player_manager.AddValidModel( "#pm_prior", "models/tiny/Playermodels/Prior_PM.mdl" )
player_manager.AddValidModel( "#pm_goauld", "models/ViktorK/player/anubis.mdl" )
player_manager.AddValidModel( "#pm_sg_soldier", "models/ViktorK/player/scout_tau.mdl" )
end

-- For prop tabs (spawnlists)
StarGate.SpawnList = {};

StarGate.SpawnList.Misc = {
	"models/Iziraider/destinytimer/timer.mdl",
	"models/Iziraider/destinybutton/destinybutton.mdl",
	"models/Boba_Fett/kino/kino.mdl",
	"models/Iziraider/kinodispenser/kinodispenser.mdl",
	"models/Iziraider/kinoremote/w_kinoremote.mdl",
	"models/Assassin21/apple_core/core.mdl",
	"models/Iziraider/gatebearing/bearing.mdl",
	"models/Iziraider/shuttle/shuttle.mdl",
	"models/Iziraider/asuransat/asuran_sat.mdl",
	"models/Iziraider/ori_sat/ori_sat.mdl",
	"models/Iziraider/minigate/minigate.mdl",
	"models/Iziraider/Deathglider/deathglider.mdl",
	"models/Iziraider/gateglider/gateglider.mdl",
	"models/Iziraider/jumper/jumper.mdl",
	"models/Iziraider/remote/w_remote.mdl",
	"models/Iziraider/disabler/disabler.mdl",
	"models/Iziraider/gateweapon/gateweapon.mdl",
	"models/Iziraider/supergate/segment.mdl",
	"models/Madman07/anti_priest/anti_priest.mdl",
	"models/Madman07/asgard_turret/asgard_turret.mdl",
	"models/Madman07/ashen_defence/ashen_defence.mdl",
	"models/Madman07/ashen_defence/ashen_defence_gib.mdl",
	"models/Madman07/drone_launcher/drone_launcher.mdl",
	"models/Madman07/ori_main/ori_main.mdl",
	"models/Madman07/overped/overped.mdl",
	"models/Madman07/wraith_dart/wraith_dart.mdl",
	"models/Madman07/telchak/telchak.mdl",
	"models/Madman07/ring_panel/ancient_panel.mdl",
	"models/Madman07/ring_panel/goauld_panel.mdl",
	"models/Madman07/ancient_rings/cover.mdl",
	"models/Madman07/ancient_rings/ring.mdl",
	"models/Madman07/doors/atl_door1.mdl",
	"models/Madman07/doors/atl_door2.mdl",
	"models/Madman07/doors/atl_frame.mdl",
	"models/Madman07/doors/dest_door.mdl",
	"models/Madman07/doors/dest_frame.mdl",
	"models/Madman07/ag_3/ag_3.mdl",
	"models/MarkJaw/gate_buster.mdl",
	"models/MarkJaw/gate_buster_cart.mdl",
	"models/MarkJaw/merlin_device.mdl",
	"models/MarkJaw/atlantis_console/console.mdl",
	"models/MarkJaw/mcd/mcd.mdl",
	"models/MarkJaw/drone_chair/chair.mdl",
	"models/MarkJaw/drone_chair/chair_base.mdl",
	"models/MarkJaw/table/table.mdl",
	"models/MarkJaw/naquadah_generator.mdl",
	"models/naquada-reactor.mdl",
	"models/MarkJaw/dhd/dhd.mdl",
	"models/MarkJaw/dhd_new/dhd.mdl",
	"models/MarkJaw/dhd_new/dhd_base.mdl",
	"models/MarkJaw/dhd_new/dhd_open.mdl",
	"models/MarkJaw/sgc_starmap/sgc_starmap.mdl",
	"models/Boba_Fett/ramps/sgu_ramp/floor_chev.mdl",
	"models/AlexALX/Stargate_Cebt/sgtbase.mdl",
	"models/pyro_overloader/overloader.mdl",
	"models/SGW/Hatak/sgw_hatak.mdl",
	"models/James/teltac/teltac.mdl",
	"models/Madman07/daedalus/daedalus.mdl",
	"models/madjawa/malp/malp.mdl",
	"models/madjawa/malp/malpwheel.mdl",
	"models/ZsDaniel/ancient-obelisk/obelisk.mdl",
	"models/ZsDaniel/atlantis-dhd/dhd.mdl",
	"models/Boba_Fett/props/asgard_console/asgard_console.mdl",
	"models/Iziraider/artifacts/ancient_pallet.mdl",
	"models/Iziraider/artifacts/asgard_stone.mdl",
	"models/Iziraider/artifacts/eye_ra.mdl",
	"models/Iziraider/artifacts/quantum_mirror.mdl",
	"models/Boba_Fett/portable_dhd/portable_dhd.mdl",
	"models/Boba_Fett/props/brazier.mdl",
	"models/Boba_Fett/props/brazier2.mdl",
	"models/Boba_Fett/props/jaffa_brazier.mdl",
	"models/Boba_Fett/props/nq_brick.mdl",
	"models/Boba_Fett/props/obelisk.mdl",
	"models/Boba_Fett/props/obelisk2.mdl",
	"models/Boba_Fett/props/orb.mdl",
	"models/Boba_Fett/props/orb_pedestal.mdl",
	"models/Boba_Fett/props/sodan_ring.mdl",
	"models/Boba_Fett/props/ori_brazier.mdl",
	"models/Boba_Fett/props/ori_brazier2.mdl",
	"models/Boba_Fett/ori_staff/w_ori_staff.mdl",
	"models/Boba_Fett/rings/ori_ring.mdl",
	"models/Boba_Fett/rings/ori_base.mdl",
	"models/ZsDaniel/ori-ringpanel/panel.mdl",
	"models/Boba_Fett/TK-427/models/hide_block.mdl",
	"models/Boba_Fett/props/lucian_bomb/lucian_bomb.mdl",
	"models/ZsDaniel/atlantis_console/dhd.mdl",
	"models/ZsDaniel/atlantis_console/console.mdl",
	"models/Madman07/com_device/device.mdl",
	"models/Madman07/com_device/stone.mdl",
	"models/Madman07/destiny_emmiter/destiny_emmiter.mdl",
	"models/Madman07/directional_nuke/directional_nuke.mdl",
	"models/Madman07/wall_decoration/decoration1.mdl",
	"models/Madman07/wall_decoration/decoration2.mdl",
	"models/Madman07/wall_decoration/decoration3.mdl",
	"models/pg_props/pg_stargate/pg_zpm.mdl",
	"models/pg_props/pg_zpm/pg_zpm.mdl",
	"models/pg_props/pg_zpm/pg_zpm_hub.mdl",
	"models/pg_props/pg_charaktere/pg_wraith_test.mdl",
	"models/Tiny/Playermodels/prior_pm.mdl",
	"models/ViktorK/player/scout_tau.mdl",
	"models/ViktorK/player/anubis.mdl",
}

StarGate.SpawnList.CapBuild = {
	"models/Iziraider/capbuild/building1.mdl",
	"models/Iziraider/capbuild/building2.mdl",
	"models/Iziraider/capbuild/bulding_l.mdl",
	"models/Iziraider/capbuild/bulding_t.mdl",
	"models/Iziraider/capbuild/bulding_x.mdl",
	"models/Iziraider/capbuild/capc.mdl",
	"models/Iziraider/capbuild/capo.mdl",
	"models/Iziraider/capbuild/end.mdl",
	"models/Iziraider/capbuild/hangar.mdl",
	"models/Iziraider/capbuild/hangardoor.mdl",
	"models/Iziraider/capbuild/runway1.mdl",
	"models/Iziraider/capbuild/runway2.mdl",
	"models/Iziraider/capbuild/runway3.mdl",
	"models/Iziraider/capbuild/runway4.mdl",
	"models/Iziraider/capbuild/runway_t.mdl",
	"models/Iziraider/capbuild/runway_x.mdl",
	"models/Iziraider/capbuild/runway_end.mdl",
	"models/Iziraider/capbuild/pipe.mdl",
	"models/Iziraider/capbuild/railguntower.mdl",
}

StarGate.SpawnList.CatWalkBuild = {
	"models/Boba_Fett/catwalk_build/catwalk_short.mdl",
	"models/Boba_Fett/catwalk_build/catwalk_med.mdl",
	"models/Boba_Fett/catwalk_build/catwalk_long.mdl",
	"models/Boba_Fett/catwalk_build/catwalk_corner.mdl",
	"models/Boba_Fett/catwalk_build/catwalk_t.mdl",
	"models/Boba_Fett/catwalk_build/catwalk_x.mdl",
	"models/Boba_Fett/catwalk_build/catwalk_x_big.mdl",
	"models/Boba_Fett/catwalk_build/catwalk_end.mdl",
	"models/Boba_Fett/catwalk_build/gate_platform.mdl",
	"models/Boba_Fett/catwalk_build/nanog_end.mdl",
	"models/Boba_Fett/catwalk_build/nanog_mid.mdl",
	"models/Boba_Fett/catwalk_build/nanog_big.mdl",
	"models/Boba_Fett/catwalk_build/landing_platform.mdl",
	"models/Boba_Fett/catwalk_build/hover_ramp.mdl",
	"models/Iziraider/sga_ramp/sga_ramp.mdl",
	"models/Boba_Fett/catwalk_build/bunker_platform.mdl",
	"models/Boba_Fett/catwalk_build/bunker.mdl",
	"models/Boba_Fett/catwalk_build/hide_block.mdl",
	"models/Boba_Fett/catwalk_build/catwalk_light.mdl",
	"models/Boba_Fett/catwalk_build/hiding_circle_half.mdl",
	"models/Boba_Fett/catwalk_build/hiding_circle.mdl",
	"models/Boba_Fett/catwalk_build/hiding_circle_rings.mdl",
}

-- old list, not used anymore, all ramps already in stools.
StarGate.SpawnList.Ramps = {
	"models/Boba_Fett/rings/ring_platform.mdl",
	"models/Boba_Fett/ramps/ring_ramps/ring_ramp.mdl",
	"models/Boba_Fett/ramps/ring_ramps/ring_ramp2.mdl",
	"models/Boba_Fett/ramps/ring_ramps/ring_ramp3.mdl",
	"models/Madman07/spawn_ramp/spawn_ring.mdl",
	"models/Iziraider/ramp1/ramp1.mdl",
	"models/Iziraider/ramp2/ramp2.mdl",
	"models/Iziraider/ramp3/ramp3.mdl",
	"models/Iziraider/ramp4/ramp4.mdl",
	"models/MarkJaw/sgu_ramp.mdl",
	"models/MarkJaw/2010_ramp.mdl",
	"models/Zup/ramps/brick_01.mdl",
	"models/Zup/ramps/sgc_ramp.mdl",
	"models/MarkJaw/midway/midway.mdl",
	"models/ZsDaniel/ramp/ramp.mdl",
	"models/ZsDaniel/icarus_ramp/icarus_ramp.mdl",
	"models/Boba_Fett/ramps/icarus_front_ramp/icarus_front_ramp.mdl",
	"models/Madman07/ori_ramp/ori_ramp.mdl",
	"models/Boba_Fett/ramps/sgu_ramp/sgu_ramp.mdl",
	"models/Boba_Fett/ramps/sgu_ramp/sgu_ramp_old.mdl",
	"models/Boba_Fett/ramps/sgu_ramp/sgu_ramp_small.mdl",
	"models/Boba_Fett/ramps/moebius_ramp/moebius_ramp.mdl",
	"models/Iziraider/sga_ramp/sga_ramp.mdl",
	"models/Boba_Fett/catwalk_build/hover_ramp.mdl",
	"models/Boba_Fett/ramps/ramp.mdl",
	"models/Boba_Fett/ramps/ramp2.mdl",
	"models/Boba_Fett/ramps/ramp3.mdl",
	"models/Boba_Fett/ramps/ramp4.mdl",
	"models/Boba_Fett/ramps/ramp5.mdl",
	"models/Boba_Fett/ramps/ramp6.mdl",
	"models/Boba_Fett/ramps/ramp7.mdl",
	"models/Boba_Fett/ramps/ramp8.mdl",
	"models/Boba_Fett/ramps/ramp9.mdl",
	"models/Boba_Fett/ramps/ramp10.mdl",
	"models/Boba_Fett/ramps/ramp11.mdl",
	"models/Boba_Fett/ramps/ramp12.mdl",
	"models/MarkJaw/midway/midway.mdl",
}