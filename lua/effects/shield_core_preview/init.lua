--[[
	Shield Core preview effect
	Copyright (C) 2011 Madman07
]]--

EFFECT.Materiala = Material("effects/shielda");
EFFECT.Materialb = Material("effects/shieldb");

function EFFECT:Init(data)
	local e = data:GetEntity();
	self.Entity:SetModel(Model("models/Madman07/shields/sphere.mdl"));
	self.Entity:SetPos(e:GetPos());
	self.Entity:SetColor(Color(170,185,255,140));
	self.Entity:SetRenderBounds(-Vector(1,1,1)*100000000,Vector(1,1,1)*100000000);
	self.Parent = e;
	self.Draw = false;
end

function EFFECT:Think()
	if self.Parent:GetNetworkedBool("Kill", false) then return false end
	local Siz = self.Parent:GetNWVector("Size", Vector(100,100,100));
	local Ang = self.Parent:GetNWAngle("Ang", Angle(0,0,0));
	local Pos = self.Parent:GetNWVector("Pos", Vector(0,0,0));
	local Col = self.Parent:GetNWVector("Col", Vector(170,185,255));
	local Mod = self.Parent:GetNWString("Mod");
	self.Entity:SetModel(Model(Mod));
	self.Entity:SetAngles(self.Parent:GetAngles() + Ang);
	self.Entity:SetPos(self.Parent:LocalToWorld(Pos));
	self.Entity:SetColor(Color(Col.x,Col.y,Col.z,140));
	local mat = Matrix()
	mat:Scale(Siz/512)
	self.Entity:EnableMatrix( "RenderMultiply", mat )
	self.Draw = true;
	return true
end

function EFFECT:Render()
	if self.Draw then
		render.MaterialOverride(self.Materiala);
		self.Entity:DrawModel();
		render.MaterialOverride(self.Materialb);
		self.Entity:DrawModel();
		render.MaterialOverride(nil);
	end
end