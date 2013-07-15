/*
	Control Panel
	Copyright (C) 2012 by AlexALX
*/
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.MiddleGoauld = Vector(2.55, 0, 12.1);
ENT.MiddleOri = Vector(2.15, 0.09, 2.25);
ENT.MiddleAncient = Vector(1.53, 0, 11.98);

function ENT:Middle()
	if (self.MiddleVal) then return self.MiddleVal; end
	if (self.Entity:GetModel()=="models/zsdaniel/ori-ringpanel/panel.mdl") then
		self.MiddleVal = self.MiddleOri;
		return self.MiddleVal;
	elseif (self.Entity:GetModel()=="models/madman07/ring_panel/ancient_panel.mdl") then
		self.MiddleVal = self.MiddleAncient;
		return self.MiddleVal;
	end
	self.MiddleVal = self.MiddleGoauld;
	return self.MiddleVal;
end

function ENT:Draw()
	self.Entity:DrawModel();
	if (not self.Entity:GetNetworkedBool("Draw",true)) then return end
	local address = self.Entity:GetNWString("ADDRESS","");
	local eye = self.Entity:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos)
	local len = (eye - self.Entity:Middle()):Length()

	if (len <= 20 or address != "") then

		local restalpha = 0;
		if (len <= 20) then restalpha = 50; end

		local ang = self.Entity:GetAngles();
		ang:RotateAroundAxis(ang:Up(), -90);
		ang:RotateAroundAxis(ang:Up(), 180);
		ang:RotateAroundAxis(ang:Forward(), 90);

		local button = 0;
		button = self:GetAimingButton(LocalPlayer())
		local btns = self.Entity:ButtonPos();
		for k,v in pairs(btns) do

			local pos = self.Entity:LocalToWorld(v);

			local alpha = restalpha;
			if(address==tostring(k) or button == k) then
				alpha = 200;
			end
			local a = Color(255,255,255,alpha)

			local txt = tostring(k);

			cam.Start3D2D(pos,ang,0.1);
				draw.SimpleText(txt,"OldDefaultSmall",0,0,a,1,1);
			cam.End3D2D();

		end

	end

end