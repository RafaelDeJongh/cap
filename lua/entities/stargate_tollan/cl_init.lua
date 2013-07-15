include("shared.lua");
ENT.ChevronColor = Color(30,135,180);
ENT.Category = Language.GetMessage("stargate_category");
ENT.PrintName = Language.GetMessage("stargate_tollan");

ENT.LightPositions = {
	Vector(4.0449, 72.9496, 86.4997),
	Vector(4.0425, 111.3255, 19.6062),
	Vector(4.0450, 96.8318, -55.8982),
	Vector(4.0448, -97.6934, -56.3638),
	Vector(4.0449, -111.6171, 19.7085),
	Vector(4.0439, -72.7159, 86.5669),
	Vector(4.0449, -0.1033, 113.0031),
	Vector(4.0450, 38.3674, -105.9060),
	Vector(4.0450, -38.3754, -105.8053),
}
ENT.SpritePositions = {
	Vector(4.0449, 72.9496, 86.4997),
	Vector(4.0425, 111.3255, 19.6062),
	Vector(4.0450, 96.8318, -55.8982),
	Vector(4.0448, -97.6934, -56.3638),
	Vector(4.0449, -111.6171, 19.7085),
	Vector(4.0439, -72.7159, 86.5669),
	Vector(4.0449, -0.1033, 113.0031),
	Vector(4.0450, 38.3674, -105.9060),
	Vector(4.0450, -38.3754, -105.8053),
}

function ENT:Draw()
	self.Entity:DrawModel();
	if(not self.ChevronColor) then return end;
	render.SetMaterial(self.ChevronSprite);
	local col = Color(self.ChevronColor.r,self.ChevronColor.g,self.ChevronColor.b,100); -- Decent please -> Less alpha
	for i=1,9 do
		if(self.Entity:GetNetworkedBool("chevron"..i,false)) then
			local endpos = self.Entity:LocalToWorld(self.SpritePositions[i]);
			if StarGate.LOSVector(EyePos(), endpos, LocalPlayer(), 5) then
				render.DrawSprite(endpos,24,24,col);
			end
		end
	end
end