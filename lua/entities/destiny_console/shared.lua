if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Destiny Console"
ENT.Author = "assassin21, aVoN, Madman07, Rafael De Jongh"
ENT.Category = "Stargate Carter Addon Pack"
ENT.WireDebugName = "Destiny Console"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.ButtonPos = {

	[1] = Vector(7.5, -38.4, 33.9),
	[2] = Vector(6.1, -35.6, 33.9),
	[3] = Vector(4.8, -32.9, 33.9),
	[4] = Vector(3.5, -30.3, 33.9),
	[5] = Vector(9.5, -37.8, 33.9),
	[6] = Vector(8.1, -35.1, 33.9),
	[7] = Vector(6.8, -32.4, 33.9),
	[8] = Vector(5.4, -29.7, 33.9),

	[9] = Vector(10.8, -35.3, 33.9),// A
	[10] = Vector(8.7, -31.2, 33.9),
	[11] = Vector(-1.8, -21.7, 34.2),
	[12] = Vector(-0.5, -20.7, 34.2),

	[13] = Vector(-0.2, 27.6, 33.9), // S
	[14] = Vector(2.6, 26.4, 33.9),
	[15] = Vector(5.5, 25.2, 33.9),
	[16] = Vector(8.3, 24.0, 33.9),

	[17] = Vector(7.4, 32.8, 33.8), // DHD

	[18] = Vector(-7.8, -1.4, 43.7) // Settings

}

function ENT:GetAimingButton(p)
	local e = self.Entity;
	local c = self.ButtonPos;
	local t = p:GetEyeTrace();
	local cv = self.Entity:WorldToLocal(t.HitPos)
	local btn = nil;
	local lastd = 5;
	for k,v in pairs(c) do
		da = (cv - c[k]):Length()
		if(da < 2) then
			if(da < lastd) then
				lastd = da;
				btn = k;
			end
		end
	end
	return btn;
end