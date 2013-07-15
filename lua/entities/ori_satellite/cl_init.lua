include('shared.lua');
ENT.Category = Language.GetMessage("entity_weapon_cat");
ENT.PrintName = Language.GetMessage("entity_ori_satellite");

ENT.GlowSprite = Material("effects/multi_purpose_noz"); //MaterialFromVMT doesn't support changing render mode of sprities! @Mad
ENT.Col = Color(255,85,0,50);

function ENT:Draw()
	self.Entity:DrawModel();
	render.SetMaterial(self.GlowSprite);
	local endpos = self.Entity:LocalToWorld(Vector(0,0,67.5));
	if StarGate.LOSVector(EyePos(), endpos, {LocalPlayer(), self.Entity}, 50) then
		render.DrawSprite(endpos,250,250,self.Col);
	end
	local endpos = self.Entity:LocalToWorld(Vector(0,0,-120));
	if StarGate.LOSVector(EyePos(), endpos, {LocalPlayer(), self.Entity}, 50) then
		render.DrawSprite(endpos,250,250,self.Col);
	end
end