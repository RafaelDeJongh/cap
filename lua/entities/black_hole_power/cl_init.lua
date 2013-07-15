include('shared.lua')
ENT.Category = Language.GetMessage("entity_main_cat");
ENT.PrintName = Language.GetMessage("entity_black_hole");

function ENT:Initialize()
	self.Color = Color( 0, 0, 0, 255 );
end

function ENT:Draw()
	local pos = self.Entity:GetPos()
	local mass = self:GetNetworkedInt("mass", 10);

	render.SetMaterial( Material( "models/effects/portalrift_sheet" ) )
	render.DrawSprite( pos, mass, mass, self.Color )
	local mat = Matrix()
	mat:Scale(Vector(1,1,1)*mass)
	self.Entity:EnableMatrix( "RenderMultiply", mat )
end