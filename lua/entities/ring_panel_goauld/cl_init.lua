include('shared.lua')
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("ring_panel_goauld");
end

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