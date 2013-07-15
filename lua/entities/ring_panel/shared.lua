ENT.Type 			= "anim"

ENT.PrintName	= "Ring Control Panel"
ENT.Author	= "Catdaemon"
ENT.Contact	= ""
ENT.Purpose	= ""
ENT.Instructions= "Touch once to a Ring Transporter Base to pair, USE to begin."
ENT.Category		= "Stargate"

ENT.Spawnable	= false
ENT.AdminSpawnable = false

ENT.IsRingPanel = true;

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
