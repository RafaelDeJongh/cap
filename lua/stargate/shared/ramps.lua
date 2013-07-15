/*
	##################################
	Ramp Offset/List file, idea by AlexALX
	##################################
	Also you can write stargate_reload (not lua_reloadents) to update ramp offsets (much faster).
	But for reload stools you still need to write restart.
	All models paths must be in LOWER case.
*/

-- ################### For stools ###################
-- For reloading the stools require writen restart.
-- All models paths must be in LOWER case.

StarGate.Ramps = {} -- Remove old array if reload, idk if this needed, just added to be sure

-- For anim ramps stool
StarGate.Ramps.AnimDefault = {"models/markjaw/2010_ramp.mdl","future_ramp",Vector(0,0,145)};
StarGate.Ramps.Anim = {
	["models/markjaw/2010_ramp.mdl"] = {"future_ramp",Vector(0,0,145)},
	["models/markjaw/sgu_ramp.mdl"] = {"sgu_ramp",Vector(0,0,150)},
	["models/iziraider/sguramp/sgu_ramp.mdl"] = {"sgu_ramp",Vector(0,0,41)},
	["models/iziraider/ramp2/ramp2.mdl"] = {"ramp_2",Vector(0,0,-5)},
	["models/zup/ramps/sgc_ramp.mdl"] = {"sgc_ramp",Vector(0,0,148)},
	["models/zsdaniel/icarus_ramp/icarus_ramp.mdl"] = {"icarus_ramp",Vector(0,0,41)},
	["models/boba_fett/ramps/ramp8.mdl"] = {"goauld_ramp"},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp.mdl"] = {"sgu_ramp"},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_old.mdl"] = {"sgu_ramp"},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_small.mdl"] = {"sgu_ramp"},
}

-- For non-anim ramps stool
StarGate.Ramps.NonAnimDefault = "models/iziraider/ramp1/ramp1.mdl";
StarGate.Ramps.NonAnim = {
	["models/iziraider/ramp1/ramp1.mdl"] = {},
	["models/iziraider/ramp2/ramp2.mdl"] = {},
	["models/iziraider/ramp3/ramp3.mdl"] = {Vector(0,0,0),Angle(0,270,0)},
	["models/iziraider/ramp4/ramp4.mdl"] = {},
	["models/iziraider/sguramp/sgu_ramp.mdl"] = {},
	["models/iziraider/sga_ramp/sga_ramp.mdl"] = {},
	["models/zup/ramps/sgc_ramp.mdl"] = {},
	["models/zup/ramps/brick_01.mdl"] = {},
	["models/markjaw/sgu_ramp.mdl"] = {},
	["models/zsdaniel/ramp/ramp.mdl"] = {},
	["models/zsdaniel/icarus_ramp/icarus_ramp.mdl"] = {},
	["models/madman07/ori_ramp/ori_ramp.mdl"] = {},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp.mdl"] = {},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_old.mdl"] = {},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_small.mdl"] = {},
	["models/boba_fett/ramps/moebius_ramp/moebius_ramp.mdl"] = {},
	["models/boba_fett/catwalk_build/hover_ramp.mdl"] = {},
	["models/boba_fett/ramps/ramp.mdl"] = {},
	["models/boba_fett/ramps/ramp2.mdl"] = {},
	["models/boba_fett/ramps/ramp3.mdl"] = {},
	["models/boba_fett/ramps/ramp4.mdl"] = {},
	["models/boba_fett/ramps/ramp5.mdl"] = {},
	["models/boba_fett/ramps/ramp6.mdl"] = {},
	["models/boba_fett/ramps/ramp7.mdl"] = {},
	["models/boba_fett/ramps/ramp9.mdl"] = {},
	["models/boba_fett/ramps/ramp10.mdl"] = {},
	["models/boba_fett/ramps/ramp11.mdl"] = {},
	["models/boba_fett/ramps/ramp12.mdl"] = {},
	["models/markjaw/midway/midway.mdl"] = {},
}

-- For ring ramps stool
StarGate.Ramps.RingDefault = "models/madman07/spawn_ramp/spawn_ring.mdl";
StarGate.Ramps.Ring = {
	["models/madman07/spawn_ramp/spawn_ring.mdl"] = {},
	["models/boba_fett/rings/ring_platform.mdl"] = {},
	["models/boba_fett/ramps/ring_ramps/ring_ramp.mdl"] = {},
	["models/boba_fett/ramps/ring_ramps/ring_ramp2.mdl"] = {},
	["models/boba_fett/ramps/ring_ramps/ring_ramp3.mdl"] = {},
}

-- ################### Offsets ###################
-- You can write stargate_reload (not lua_reloadents) to update ramp offsets (much faster).
-- All model paths must be in LOWER case.

-- Offsets for "InRamp"-Spawning

StarGate.RampOffset = {} -- Remove old array if reload, idk if this needed, just added to be sure

-- For StarGates
StarGate.RampOffset.Gates = {
	["models/zup/ramps/sgc_ramp.mdl"] = {Vector(0,0,0)},
	["models/zup/ramps/brick_01.mdl"] = {Vector(0,0,-10)},
	["models/iziraider/sguramp/sgu_ramp.mdl"] = {Vector(-105,0,96)},
	["models/iziraider/ramp1/ramp1.mdl"] = {Vector(-240,0,128)},
	["models/iziraider/ramp2/ramp2.mdl"] = {Vector(-270,0,138)},
	["models/iziraider/ramp3/ramp3.mdl"] = {Vector(0,-120,124.5),Angle(0,90,0)},
	["models/iziraider/ramp4/ramp4.mdl"] = {Vector(-270,0,171)},
	["models/iziraider/sga_ramp/sga_ramp.mdl"] = {Vector(-234,0,87)},
	["models/madman07/ori_ramp/ori_ramp.mdl"] = {Vector(-338,0,143)},
	["models/markjaw/2010_ramp.mdl"] = {Vector(0,0,0)},
	["models/markjaw/sgu_ramp.mdl"] = {Vector(-2,0,-1)},
	["models/zsdaniel/ramp/ramp.mdl"] = {Vector(0,0,140)},
	["models/zsdaniel/icarus_ramp/icarus_ramp.mdl"] = {Vector(-192,0,97.5)},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp.mdl"] = {Vector(-109,0,135)},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_old.mdl"] = {Vector(-109,0,135)},
	["models/boba_fett/ramps/sgu_ramp/sgu_ramp_small.mdl"] = {Vector(-92.2,0,142)},
	["models/boba_fett/ramps/moebius_ramp/moebius_ramp.mdl"] = {Vector(0,0,149)},
	["models/boba_fett/catwalk_build/hover_ramp.mdl"] = {Vector(-400,0,195)},
	["models/boba_fett/catwalk_build/gate_platform.mdl"] = {Vector(0,0,-2.5),Angle(-90,0,0)},
	["models/boba_fett/ramps/ramp.mdl"] = {Vector(-85,0,159)},
	["models/boba_fett/ramps/ramp2.mdl"] = {Vector(-65,0,145)},
	["models/boba_fett/ramps/ramp3.mdl"] = {Vector(-67,0,225)},
	["models/boba_fett/ramps/ramp4.mdl"] = {Vector(0,0,90)},
	["models/boba_fett/ramps/ramp5.mdl"] = {Vector(0,0,219)},
	["models/boba_fett/ramps/ramp6.mdl"] = {Vector(-38,0,159)},
	["models/boba_fett/ramps/ramp7.mdl"] = {Vector(0,0,110)},
	["models/boba_fett/ramps/ramp8.mdl"] = {Vector(0,0,146)},
	["models/boba_fett/ramps/ramp9.mdl"] = {Vector(-198,0,142)},
	["models/boba_fett/ramps/ramp10.mdl"] = {Vector(-184,0,133)},
	["models/boba_fett/ramps/ramp11.mdl"] = {Vector(-180,0,126)},
	["models/boba_fett/ramps/ramp12.mdl"] = {Vector(-50,0,137)},
	["models/markjaw/midway/midway.mdl"] = {Vector(675,0,0),Angle(0,-180,0),Vector(-672,0,0)}
}

-- For DHD's
StarGate.RampOffset.DHD = {
	["models/iziraider/ramp1/ramp1.mdl"] = {Vector(300,0,5),Angle(15,0,0)},
	["models/iziraider/ramp2/ramp2.mdl"] = {Vector(318,0,30),Angle(15,180,0)},
	["models/iziraider/ramp3/ramp3.mdl"] = {Vector(0,165,13),Angle(0,90,0)}, --,Angle(15,90,0)},
	["models/iziraider/ramp4/ramp4.mdl"] = {Vector(95,5,11),Angle(15,0,0)},
	["models/iziraider/sga_ramp/sga_ramp.mdl"] = {Vector(-160,-163,-7),Angle(15,35,0)},
	["models/madman07/ori_ramp/ori_ramp.mdl"] = {Vector(100,0,39),Angle(15,0,0)},
	["models/boba_fett/ramps/ramp10.mdl"] = {Vector(-10,-110,56),Angle(15,35,0)},
	["models/boba_fett/catwalk_build/hover_ramp.mdl"] = {Vector(-290,-140,97),Angle(15,35,0)},
}

-- For Concept DHD's
StarGate.RampOffset.DHDC = {
	["models/boba_fett/ramps/ramp9.mdl"] = {Vector(20,0,20)},
}

-- For Rings
StarGate.RampOffset.Ring = {
	["models/madman07/spawn_ramp/spawn_ring.mdl"] = {Vector(8,0,12)},
	["models/boba_fett/rings/ring_platform.mdl"] = {Vector(0,0,20)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp.mdl"] = {Vector(0,0,23)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp2.mdl"] = {Vector(0,0,20)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp3.mdl"] = {Vector(0,0,14)},
	["models/boba_fett/catwalk_build/hover_ramp.mdl"] = {Vector(270,0,112.5)},
	["models/boba_fett/catwalk_build/hiding_circle_rings.mdl"] = {Vector(0,0,0)},
}

-- For Ring Panels
StarGate.RampOffset.RingP = {
	["models/madman07/spawn_ramp/spawn_ring.mdl"] = {Vector(-98,0,57.5)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp.mdl"] = {Vector(0,-96.5,69),Angle(0,90,0)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp2.mdl"] = {Vector(-98.5,0,58)},
	["models/boba_fett/ramps/ring_ramps/ring_ramp3.mdl"] = {Vector(-88.5,0,47)},
	["models/boba_fett/catwalk_build/hover_ramp.mdl"] = {Vector(369.5,0,162.5),Angle(0,180,0)},
	["models/boba_fett/catwalk_build/hiding_circle_rings.mdl"] = {Vector(88,0,21),Angle(0,180,0)},
}