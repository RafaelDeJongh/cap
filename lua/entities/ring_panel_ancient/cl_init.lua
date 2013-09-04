include('shared.lua')
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("ring_panel_ancient");
end

ENT.ButtonPos = {
	[1] = Vector(1.53, -1.5, 19.38),
	[2] = Vector(1.53, 1.5, 19.38),
	[3] = Vector(1.53, 0, 15.68),
	[4] = Vector(1.53, -1.5, 11.98),
	[5] = Vector(1.53, 1.5, 11.98),
	[6] = Vector(1.53, -2.5, 4.57),
	[7] = Vector(1.53, 0, 4.57),
	[8] = Vector(1.53, 2.5, 4.57),
	[9] = Vector(1.53, 0, 8.28),
}

ENT.Middle = Vector(1.53, 0, 11.98);

ENT.ButtCount = 9;