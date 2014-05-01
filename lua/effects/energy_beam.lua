--[[
	Energy Beam
	Copyright (C) 2011 Madman07
]]--

EFFECT.LineB = Material("effects/beam_blue_asgard");
EFFECT.LineO = Material("effects/beam_orange");
EFFECT.SpriteB = Material("effects/sprite_blue");
EFFECT.SpriteO = Material("effects/sprite_orange");

function EFFECT:Init(data)
	self.Parent = data:GetEntity();
	self.Eff = math.ceil(data:GetMagnitude());
	self.StartPos =  data:GetStart();
	self.EndPos = self.StartPos;
	self.Dir = data:GetNormal();
	self.Speed = data:GetRadius()/2.9;

	self.Length = 2;
	self.Time = CurTime();
	self.UpdateEnd = true;

	if (self.Eff == 1) then
		self.Size = 100
		self.Sprite = self.SpriteO;
		self.Line = self.LineO;
	else
		self.Size = 40;
		self.Sprite = self.SpriteB;
		self.Line = self.LineB;
	end

	self.StartTime = self.Parent:GetNetworkedInt("StartTime", 1) + CurTime();

	self:SetRenderBounds(-10000000*Vector(1,1,1), 10000000*Vector(1,1,1)	)
end

function EFFECT:Think()
	if not IsValid(self.Parent) then return false end
	if (self.Length <= 1) then self:Remove(); end

	if ((CurTime() - self.Time) > 0.03 )then
		self.Time = CurTime();
		self.StargateTrace = self.LastStargateTrace or StarGate.Trace:New(self.EndPos,self.Dir*self.Speed,{self.Entity, self.Parent});

		if (self.StartTime < CurTime()) then self:UpdateStartPos(); end
		if self.UpdateEnd then self:UpdateEndPos(); end
	end
	return true
end

function EFFECT:Render()
	render.SetMaterial(self.Line);
	render.DrawBeam(self.StartPos, self.EndPos, self.Size, 0, 1, Color(255,255,255,255));

	render.SetMaterial(self.Sprite);
	render.DrawSprite(self.StartPos, self.Size, self.Size, Color(255,255,255,255));
	render.DrawSprite(self.EndPos, self.Size, self.Size, Color(255,255,255,255));
	render.DrawSprite(self.StartPos, self.Size+20, self.Size+20, Color(255,255,255,255));
	render.DrawSprite(self.EndPos, self.Size+20, self.Size+20, Color(255,255,255,255));
end

function EFFECT:UpdateEndPos()
	if not (self.StargateTrace.HitSky) then
		if self.StargateTrace.Hit then
			local dist = self.StargateTrace.HitPos:Distance(self.EndPos);
			if dist < self.Speed then
				local ent = self.StargateTrace.Entity;

				if IsValid(ent) then
					local class = ent:GetClass();
					if (class == "shield" or class == "shield_core_buble" or class == "ship_shield" or class=="event_horizon") then
						self.LastStargateTrace = self.StargateTrace;
					end
				end

				self.EndPos = self.StargateTrace.HitPos;
				self.Length = self.Length + dist;
			else
				self.EndPos = self.EndPos + self.Dir*self.Speed;
				self.Length = self.Length + self.Speed;
			end
		else
			self.EndPos = self.EndPos + self.Dir*self.Speed;
			self.Length = self.Length + self.Speed;
		end
	end
end

function EFFECT:UpdateStartPos()
	self.StartPos = self.StartPos + self.Dir*self.Speed;
	self.Length = self.Length - self.Speed;
end