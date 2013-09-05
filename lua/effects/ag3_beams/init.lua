--[[
	AG3 Beams
	Copyright (C) 2011 Madman07
]]--

EFFECT.Line = Material("effects/beam_orange");
EFFECT.Sprite = Material("effects/sprite_orange");
EFFECT.Glow = Material("sprites/portalglow");

function EFFECT:Init(data)
	self.Main = data:GetEntity();
	self.Target =  data:GetStart();
	self.LifeTime = CurTime()+2.7;
	self.Size = 40;

	self.Satellite = {
		self.Main,
		self.Main:GetNetworkedEntity("Sat1", self.Main),
		self.Main:GetNWEntity("Sat2", self.Main),
		self.Main:GetNWEntity("Sat3", self.Main),
		self.Main:GetNWEntity("Sat4", self.Main),
		self.Main:GetNWEntity("Sat5", self.Main),
	}

	self:SetRenderBounds(-10000000*Vector(1,1,1), 10000000*Vector(1,1,1));
	self.ShouldDrawBeam = true;
	self.GlowScale = 0;

end

function EFFECT:Think()
	if (not IsValid(self.Main) or self.LifeTime < CurTime()) then
		self.ShouldDrawBeam = false;
	end
	if self.ShouldDrawBeam then
		self.GlowScale = math.Clamp(self.GlowScale+0.02, 0, 1);
	else
		self.GlowScale = math.Clamp(self.GlowScale-0.02, 0, 1);
		if (self.GlowScale < 0.03) then self:Remove(); end
	end
	return true
end

function EFFECT:Render()
	for _, sat in pairs(self.Satellite) do
		if (not IsValid(sat)) then continue end
		local data = sat:GetAttachment(sat:LookupAttachment("Fire"))
		if (not data) then data = {}; end
		if (not (data and data.Pos)) then data.Pos = sat:GetPos() + sat:GetForward()*20 end

		if self.ShouldDrawBeam then
			render.SetMaterial(self.Line);
			render.DrawBeam(data.Pos, self.Target, self.Size, 0, 1, Color(255,255,255,255));

			render.SetMaterial(self.Sprite);
			render.DrawSprite(data.Pos, self.Size, self.Size, Color(255,255,255,255));
			render.DrawSprite(data.Pos, self.Size+20, self.Size+20, Color(255,255,255,255));
		end

		render.SetMaterial(self.Glow)
		render.DrawSprite(data.Pos, self.GlowScale*self.Size*3, self.GlowScale*self.Size*3, Color(255,255,255,255))
		render.DrawSprite(data.Pos, self.GlowScale*self.Size*5, self.GlowScale*self.Size*5, Color(240,200,120,255))

	end

	if self.ShouldDrawBeam then
		render.SetMaterial(self.Sprite);
		render.DrawSprite(self.Target, self.Size, self.Size, Color(255,255,255,255));
		render.DrawSprite(self.Target, self.Size+20, self.Size+20, Color(255,255,255,255));
	end

	render.SetMaterial(self.Glow)
	render.DrawSprite(self.Target, self.GlowScale*self.Size*2, self.GlowScale*self.Size*2, Color(255,255,255,255))
	render.DrawSprite(self.Target, self.GlowScale*self.Size*4, self.GlowScale*self.Size*4, Color(240,200,120,255))
end