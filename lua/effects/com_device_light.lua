/*
	Comunication Device Light
	Copyright (C) 2011 Madman07
*/

function EFFECT:Init(data)
	self.Parent = data:GetEntity();
	self.Alpha = 1;
end

function EFFECT:Think( )
	if (self.Alpha < 0.1) then return false
	else return true end
end

function EFFECT:Render()
	if not IsValid(self.Parent) then return end
	self.Alpha = self.Alpha-self.Alpha/15;
	
	if (LocalPlayer() == self.Parent) then
	
		DrawColorModify(
			{
				["$pp_colour_addr"] = self.Alpha,
				["$pp_colour_addg"] = self.Alpha,
				["$pp_colour_addb"] = self.Alpha,
				["$pp_colour_brightness"] = 0,
				["$pp_colour_contrast"] = 1,
				["$pp_colour_colour"] = 1,
				["$pp_colour_mulr"] = 0,
				["$pp_colour_mulg"] = 0,
				["$pp_colour_mulb"] = 0,
			}
		);

	end
end
