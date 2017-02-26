ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Eventhorizon"
ENT.Author = "aVoN"
ENT.WireDebugName = "Eventhorizon"

ENT.Spawnable = false
ENT.AdminSpawnable = false

--################# EH Types @ AlexALX ###############

ENT.KawooshTypes = {
	["sg1"] = {
		ID = 1,
		KawooshDmg = {(1/3),12,1.5}, -- {radius_mul,kawoosh_hurt_times,kawoosh_hurt_destroy_time}
		KawooshData = {
			Time=1.6, -- Time to draw the vortex
			Size=4, -- Base or startsize
			GrowCoefficient=3.5, -- Size multiplier, how much bigger particles at the end of the kawoosh are compaired to the base
			Length=500, --Units long? 385.826 inches/second is gravity
			Density=500, -- Amount of particles
			Radius=55, --Radius of the kawooshes cyclinder... how "fat" the kawoosh is overall.. if that makes any sense
			Roll=0, --Roll, how much roll each particle has at start
			RollS=1.0, --Roll Speed
		},
	}, 
	["movie"] = {
		ID = 2,
		BackKawooshTime = 2.0,
		KawooshDmg = {(1/3),16,2.0},
		KawooshData = {
			Time=2.1, -- Time to draw the vortex
			Size=4, -- Base or startsize
			GrowCoefficient=3.5, -- Size multiplier, how much bigger particles at the end of the kawoosh are compaired to the base
			Length=350, --Units long? 385.826 inches/second is gravity
			Density=500, -- Amount of particles
			Radius=55, --Radius of the kawooshes cyclinder... how "fat" the kawoosh is overall.. if that makes any sense
			Roll=0, --Roll, how much roll each particle has at start
			RollS=1.0, --Roll Speed
		},
	},
	["supergate"] = {
		ID = 3,
		KawooshDmg = {0.6,36,4.4},
		KawooshData = {
			Time=4.6, -- Time to draw the vortex
			Size=35, -- Base or startsize
			GrowCoefficient=4, -- Size multiplier, how much bigger particles at the end of the kawoosh are compaired to the base
			Length=3600, --Units long? 385.826 inches/second is gravity
			Density=1800, -- Amount of particles
			Radius=1600, --Radius of the kawooshes cyclinder... how "fat" the kawoosh is overall.. if that makes any sense
			Roll=0, --Roll, how much roll each particle has at start
			RollS=1.0, --Roll Speed
		}
	},
	["orlin"] = {
		ID = 4,
		KawooshDmg = {(1/6),12,1.5},
		KawooshData = {
			Time=1.6, -- Time to draw the vortex
			Size=2, -- Base or startsize
			GrowCoefficient=3.5, -- Size multiplier, how much bigger particles at the end of the kawoosh are compaired to the base
			Length=200, --Units long? 385.826 inches/second is gravity
			Density=500, -- Amount of particles
			Radius=18, --Radius of the kawooshes cyclinder... how "fat" the kawoosh is overall.. if that makes any sense
			Roll=0, --Roll, how much roll each particle has at start
			RollS=1.0, --Roll Speed
		}
	},
}

ENT.KawooshTypesFX = {"sg1","movie","supergate","orlin"}