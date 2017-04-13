ENT.Type = "anim"
ENT.Base = "stargate_base"
ENT.PrintName = "Supergate"
ENT.Author = "assassin21, Madman07, Iziraider, Rafael De Jongh, AlexALX"
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"

list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.WireDebugName = "Supergate"

ENT.IsGroupStargate = false;
ENT.IsSuper = true;
ENT.IsSupergate = true;

ENT.EventHorizonData = {
	OpeningDelay = 0.8,
	OpenTime = 5.3,
	NNFix = 0,
	Model = "models/iziraider/supergate/eh.mdl",
	Kawoosh = "supergate",
}

ENT.StargateNoEHSelect = true