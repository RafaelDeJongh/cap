--[[
	Energy Beam
	Copyright (C) 2011 Madman07
]]--

EFFECT.LineB = Material("effects/beam_blue");
EFFECT.LineO = Material("effects/beam_orange");
EFFECT.SpriteB = Material("effects/sprite_blue");
EFFECT.SpriteO = Material("effects/sprite_orange");

function EFFECT:Init(data)
	self.Parent = data:GetEntity();

	self.Ent1 = self.Parent:GetNetworkedEntity("Ent1", self.Entity);
	self.Ent2 = self.Parent:GetNWEntity("Ent2", self.Entity);
	self.LocPos1 = self.Parent:GetNWVector("Loc1", Vector(0,0,0));
	self.LocPos2 = self.Parent:GetNWVector("Loc2", Vector(0,0,0));

	if (self.Eff == 1) then
		self.Size = 100
		self.Sprite = self.SpriteO;
		self.Line = self.LineO;
	else
		self.Size = 40;
		self.Sprite = self.SpriteB;
		self.Line = self.LineB;
	end

	self:SetRenderBounds(-10000000*Vector(1,1,1), 10000000*Vector(1,1,1))
end

function EFFECT:Think()
	if not IsValid(self.Parent) then return false end
	return true
end

function EFFECT:Render()
	local pos1 = self.Ent1:LocalToWorld(self.LocPos1);
	local pos2 = self.Ent2:LocalToWorld(self.LocPos2);

	render.SetMaterial(self.Line);
	render.DrawBeam(pos1, pos2, self.Size, 0, 1, Color(255,255,255,255));

	render.SetMaterial(self.Sprite);
	render.DrawSprite(pos1, self.Size, self.Size, Color(255,255,255,255));
	render.DrawSprite(pos2, self.Size, self.Size, Color(255,255,255,255));
	render.DrawSprite(pos1, self.Size+20, self.Size+20, Color(255,255,255,255));
	render.DrawSprite(pos2, self.Size+20, self.Size+20, Color(255,255,255,255));
end