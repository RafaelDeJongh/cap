include('shared.lua')
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("ring_panel_ori");
end

ENT.ButtonPos = {
	[1] = Vector(1.40, -9.97, 3.31),
	[2] = Vector(1.36, -8.98, 5.82),
	[3] = Vector(1.38, -7.46, 7.76),
	[4] = Vector(1.42, -5.17, 9.24),
	[5] = Vector(1.46, -2.95, 10.12),
	[6] = Vector(2.15, 0.09, 2.25),
}

ENT.Middle = Vector(2.15, 0.09, 2.25);

ENT.ButtCount = 6;