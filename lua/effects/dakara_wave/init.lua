EFFECT.Dakara = Material("effects/dakara");

function EFFECT:Init(data)
	self.Ent 	= data:GetEntity();
	self.End	= data:GetMagnitude();
	self.Init 	= CurTime();
	self.Time 	= self.Init;
	self.Rad	= 0;
	self.Rel	= 0;
	self.cycleInterval = 0.1;
	self.ExpansionRate = 100;
	self.Fraction = (self.ExpansionRate/self.cycleInterval)/512;

	self.Entity:SetModel(Model("models/Madman07/shields/sphere.mdl"));
	self.Entity:SetPos(self.Ent:GetPos());

	self.Entity:SetRenderBounds(-Vector(1,1,1)*100000000,Vector(1,1,1)*100000000);
end

function EFFECT:Think()
	self.Time = CurTime()
	self.Rel = self.Time-self.Init
	self.Rad = self.Rel+math.Clamp(0.2*self.Rel^2-1, -1 ,2.2) -- This should account for the lag, but it will make it look better rather than just adding 1.5 to it.
	if self.Rel > self.End then return end
	return true
end

function EFFECT:Render()
	local rad = self.Rad*self.Fraction;
	render.MaterialOverride(self.Dakara)
	local mat = Matrix()
	mat:Scale(Vector(1,1,1)*(rad-0.1))
	self.Entity:EnableMatrix( "RenderMultiply", mat )
	self.Entity:DrawModel()
	render.MaterialOverride(nil)
end