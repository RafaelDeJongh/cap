--[[
	Shield Core flash effect
	Copyright (C) 2011 Madman07
]]--

EFFECT.Materiala = Material("effects/shielda");
EFFECT.Materialb = Material("effects/shieldb");

function EFFECT:Init(data)
	if(not StarGate.VisualsMisc("cl_shield_bubble")) then return end;
	local e = data:GetEntity();
    if (not IsValid(e)) then return end

	self.Siz = e:GetNetworkedVector("Size", Vector(100,100,100))/512;
	self.Col = e:GetNWVector("Col", Vector(170,185,255));
	self.Mod = e:GetNWString("Mod");
	self.Ang = e:GetNWAngle("Ang", Angle(0,0,0));
	self.Pos = e:GetNWVector("Pos", Vector(0,0,0));

	self.Entity:SetModel(Model(self.Mod));
	self.Entity:SetPos(e:LocalToWorld(self.Pos));
	self.Entity:SetAngles(e:GetAngles()+self.Ang);
	self.Entity:SetColor(Color(self.Col.x,self.Col.y,self.Col.z,1));
	self.Entity:SetRenderBounds(-Vector(1,1,1)*100000000,Vector(1,1,1)*100000000);
	self.Entity:SetRenderMode( RENDERMODE_TRANSALPHA );

	local magnitude = math.ceil(data:GetMagnitude());
	local hit = false;
	if(magnitude == 2) then hit = true end;
	if(magnitude == 1) then self.TurnOff = true end;

	local shield = e.ShieldBubble;
	if(IsValid(shield)) then
		if(self.TurnOff) then
			shield:Remove();
		elseif(hit) then
			if((CurTime()-shield.Created)/shield.LifeTime > 0.04) then
				shield.StartWithFullAlpha = true; -- Start at full alpha instead to avoid ugly side effects
			end
			shield.Created = CurTime();
			self:Remove();
			return;
		end
	end
	e.ShieldBubble = self.Entity;

	self.Created = CurTime();
	self.LifeTime = 1;
	self.Parent = e;
	self.Alpha = 0;
	self.Draw = true;
end

function EFFECT:Think()
	return (self.Draw and self.Created + self.LifeTime > CurTime());
end

function EFFECT:Render()
	if not IsValid(self.Parent) then self.Draw = nil end
	if not self.Draw then return end

	self.Entity:SetPos(self.Parent:LocalToWorld(self.Pos));
	self.Entity:SetAngles(self.Parent:GetAngles()+self.Ang);

	local multiply = (CurTime()-self.Created)/self.LifeTime;
	if(multiply >= 0) then
		if(self.StartWithFullAlpha and multiply < 0.5) then
			multiply = 0.5;
		end
		local alpha = math.Clamp(math.Clamp(math.sin(multiply*math.pi)*1.3,0,1)*70,1,70);
		local factor = 1;
		if(self.TurnOff) then
			-- When the shield collapes, we will add a shrinking effect
			factor = factor*((1-multiply)^5);
			alpha = math.Clamp(140*(1-multiply)^10,1,120);
		end
		self.Entity:SetColor(Color(self.Col.x,self.Col.y,self.Col.z,alpha*2));
		local mat = Matrix()
		mat:Scale(self.Siz*factor)
		self.Entity:EnableMatrix( "RenderMultiply", mat )

		render.MaterialOverride(self.Materiala);
		self.Entity:DrawModel();
		render.MaterialOverride(self.Materialb);
		self.Entity:DrawModel();
		render.MaterialOverride(nil);
	end
end