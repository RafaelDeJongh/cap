StarGate.LifeSupportAndWire(ENT)
ENT.Type = "anim"
ENT.PrintName = "Control Panel"
ENT.Author	= "AlexALX"
ENT.Contact	= ""
ENT.Purpose	= ""
ENT.Instructions = "Use this with wiremod."
ENT.Category = "Stargate"
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.ButtonPosGoauld = {
	[1] = Vector(2.55, -3.3, 12.1),
	[2] = Vector(2.55, 3.3, 12.1),
	[3] = Vector(2.55, -3.3, 9.1),
	[4] = Vector(2.55, 3.3, 9.1),
	[5] = Vector(2.55, -3.3, 6.1),
	[6] = Vector(2.55, 3.3, 6.1),
}

ENT.ButtonPosOri = {
	[1] = Vector(1.40, -9.97, 3.31),
	[2] = Vector(1.36, -8.98, 5.82),
	[3] = Vector(1.38, -7.46, 7.76),
	[4] = Vector(1.42, -5.17, 9.24),
	[5] = Vector(1.46, -2.95, 10.12),
	[0] = Vector(2.15, 0.09, 2.25),
}

ENT.ButtonPosAncient = {
	[1] = Vector(1.53, -1.5, 19.38),
	[2] = Vector(1.53, 1.5, 19.38),
	[3] = Vector(1.53, 0, 15.68),
	[4] = Vector(1.53, -1.5, 11.98),
	[5] = Vector(1.53, 1.5, 11.98),
	[7] = Vector(1.53, -2.5, 4.57),
	[8] = Vector(1.53, 0, 4.57),
	[9] = Vector(1.53, 2.5, 4.57),
	[6] = Vector(1.53, 0, 8.28),
}

function ENT:ButtonPos(butt)
	if (self.ButtonPosVal) then
		if (butt!=nil) then
			return self.ButtonPosVal[butt];
		else
			return self.ButtonPosVal;
		end
	end
	if (self.Entity:GetModel()=="models/zsdaniel/ori-ringpanel/panel.mdl") then
		self.ButtonPosVal = self.ButtonPosOri;
		if (butt!=nil) then
			return self.ButtonPosVal[butt];
		else
			return self.ButtonPosVal;
		end
	elseif (self.Entity:GetModel()=="models/madman07/ring_panel/ancient_panel.mdl") then
		self.ButtonPosVal = self.ButtonPosAncient;
		if (butt!=nil) then
			return self.ButtonPosVal[butt];
		else
			return self.ButtonPosVal;
		end
	end
	self.ButtonPosVal = self.ButtonPosGoauld;
	if (butt!=nil) then
		return self.ButtonPosVal[butt];
	else
		return self.ButtonPosVal;
	end
end

function ENT:GetAimingButton(p)
	local e = self.Entity;
	local c = e:ButtonPos();
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
