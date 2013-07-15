--[[
	Tokra Shield flash effect
	Copyright (C) 2011 Madman07
]]--

EFFECT.Materiala = Material("effects/shielda");
EFFECT.Materialb = Material("effects/shieldb");

function EFFECT:Init(data)
	local e = data:GetEntity();
	self.Length = data:GetScale();
	self.Entity:SetModel(Model("models/Madman07/tokra_shield/shield.mdl"));
	self.Entity:SetPos(e:GetPos());
	self.Entity:SetAngles(e:GetAngles());
	self.Entity:SetColor(Color(170,185,255,140));
	self.Entity:SetRenderBounds(-Vector(1,1,1)*100000000,Vector(1,1,1)*100000000);
	self.Parent = e;
	self.Draw = true;
end

function EFFECT:Think()
	if self.Parent:GetNetworkedBool("Kill", false) then
		self.Draw = false;
		return false
	end
	return true
end

function EFFECT:Render()
	if self.Draw then
		render.MaterialOverride(self.Materiala);
		self.Entity:SetModelScale(Vector(2*self.Length,1,1));
		local mat = Matrix()
		mat:Scale(Vector(2*self.Length,1,1))
		self.Entity:EnableMatrix( "RenderMultiply", mat )
		self.Entity:DrawModel();
		render.MaterialOverride(self.Materialb);
		local mat = Matrix()
		mat:Scale(Vector(2*self.Length,1,1))
		self.Entity:EnableMatrix( "RenderMultiply", mat )
		self.Entity:DrawModel();
		render.MaterialOverride(nil);
	end
end