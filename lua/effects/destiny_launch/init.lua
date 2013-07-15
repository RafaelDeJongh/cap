--[[
	Destiny Launch
	Copyright (C) 2010 Madman07
]]--

function EFFECT:Init( data )
	self.Start 	 = data:GetStart();
	self.Normal     = data:GetNormal();
	self.Entity:SetRenderBoundsWS( self.Start, self.Start )

	self.Size = 20;

	local pos = data:GetOrigin();
	local e = data:GetEntity();
	local vel = Vector(0,0,0);
	if(e and e:IsValid()) then
		vel = e:GetVelocity();
	end
	local color = data:GetAngles();
	self.Color = Color(255,200,120);
	if(color ~= Angle(0,0,0)) then
		self.Color = Color(color.p,color.y,color.r);
	end
	local norm = data:GetNormal();
	local em = ParticleEmitter(pos);

	for i=-5,16 do
		local pt2 = em:Add("sprites/gmdm_pickups/light",pos+self.Normal*5*i);
		pt2:SetDieTime(1);
		pt2:SetStartAlpha(15);
		pt2:SetEndAlpha(0);
		pt2:SetStartSize(40);
		pt2:SetEndSize(40);
		pt2:SetColor(self.Color.r,self.Color.g,self.Color.b);
	end
	for i=17,25 do
		local pt2 = em:Add("sprites/gmdm_pickups/light",pos+self.Normal*5*i);
		pt2:SetDieTime(1);
		pt2:SetStartAlpha(15-i*0.6);
		pt2:SetEndAlpha(0);
		pt2:SetStartSize(40);
		pt2:SetEndSize(40);
		pt2:SetColor(self.Color.r,self.Color.g,self.Color.b);
	end
	for i=-2,15 do
		local pt = em:Add("particles/smokey",pos+self.Normal*10*i);
		pt:SetDieTime(5);
		pt:SetStartAlpha(20);
		pt:SetStartSize(20);
		pt:SetEndSize(20);
		pt:SetRoll(0);
		pt:SetColor(150,150,150);

		local dynlight = DynamicLight(0);
		dynlight.Pos = pos+self.Normal*25*i;
		dynlight.Size = 300;
		dynlight.Decay = 300;
		dynlight.R = self.Color.r;
		dynlight.G = self.Color.g;
		dynlight.B = self.Color.b;
		dynlight.DieTime = CurTime()+0.1;
	end

	em:Finish();

end

function EFFECT:Think() return false end; -- damn you madman with true it never remove it
function EFFECT:Render() end