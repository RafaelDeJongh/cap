include('shared.lua')
ENT.Category = Language.GetMessage("stargate_category");
ENT.PrintName = Language.GetMessage("ring_panel_goauld");

ENT.ButtonPos = {
	[1] = Vector(2.55, -3.3, 12.1),
	[2] = Vector(2.55, 3.3, 12.1),
	[3] = Vector(2.55, -3.3, 9.1),
	[4] = Vector(2.55, 3.3, 9.1),
	[5] = Vector(2.55, -3.3, 6.1),
	[6] = Vector(2.55, 3.3, 6.1),
}

ENT.Middle = Vector(2.55, 0, 12.1);

ENT.ButtCount = 6;