ENT.Type="anim"
ENT.Base="base_anim"
ENT.PrintName = "Sodan Obelisk"
ENT.Author = "RononDex, Madman07, Boba Fett"
ENT.Category = "Stargate Carter Addon Pack"
list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.ButtonPos = {
	[1] = Vector(22.53, -3.98, 94.35),
	[2] = Vector(22.53, 4.63, 94.35),
	[3] = Vector(22.53, -3.98, 81.5),
	[4] = Vector(22.53, 4.63, 81.5),
	[5] = Vector(22.53, -3.98, 69.45),
	[6] = Vector(22.53, 4.63, 69.45),
	PASS = Vector(22.53, 4.63, 43.4);
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
			if(da < 1.5) then
				if(da < lastd) then
				lastd = da;
				btn = k;
			end
		end
	end
	return btn;
end