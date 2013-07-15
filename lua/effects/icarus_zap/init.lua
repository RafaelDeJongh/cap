/*   Copyright 2012 by AlexALX   */

local matBeam = Material( "sprites/bluelaser1" )

function EFFECT:Init(data)
	local e = data:GetEntity();
	self.Parent = e;
	self.Created = CurTime();
	self.LifeTime = 0.15;
	self.StartPos	= data:GetOrigin()
	self.EndPos	= data:GetStart()
	self.Length	= self.StartPos:Distance(self.EndPos)
	self.AimVector	= (self.EndPos-self.StartPos):GetNormal()
	local offset = 50*Vector(1,1,1);
	self.Entity:SetRenderBounds(-1*offset,offset);
	self.Rand = VectorRand()*4;
	timer.Simple(0.05,function() self.Rand = self.Rand*0.5; end)
	local rnd = math.random(50,75);
	self.Col = Color(rnd,rnd,255,255);
    sound.Play(Sound("ambient/energy/spark"..math.random(1,4)..".wav"),self.EndPos,67,math.random(90,110));
end

function EFFECT:Think( )
	return (CurTime() - self.Created < self.LifeTime);
end

function EFFECT:Render()
	render.SetMaterial(matBeam)
	for i=1,2 do
		render.StartBeam(4)
		render.AddBeam(self.StartPos, 8, 1, self.Col)

		local increment = self.Length/12

		render.AddBeam(self.StartPos+self.AimVector*4*increment+self.Rand, 6, 1, self.Col)
		render.AddBeam(self.StartPos+self.AimVector*8*increment+self.Rand*(-1), 6, 1, self.Col)

		render.AddBeam(self.EndPos, 6, 1, self.Col)
		render.EndBeam()
	end
	/* hm looks badly
	if (math.random(0,10)==1) then
		local fx = EffectData()
		fx:SetOrigin(self.EndPos)
		fx:SetNormal( Vector(0,0,0) )
		fx:SetMagnitude( 1 )
		fx:SetScale( 1 )
		fx:SetRadius( 1 )
	 	util.Effect("sparks", fx)
 	end*/
end