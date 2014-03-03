/*
	Arthur's Mantle Light
	Copyright (C) 2010 Madman07
*/

if (StarGate==nil or StarGate.MaterialFromVMT==nil) then return end

EFFECT.BearingSprite = StarGate.MaterialFromVMT(
	"BearingSprite",
	[["Sprite"
	{
		"$spriteorientation" "vp_parallel"
		"$spriteorigin" "[ 0.50 0.50 ]"
		"$basetexture" "sprites/glow04"
		"$spriterendermode" 5
	}]]
);

function EFFECT:Init(data)

	if(not IsValid(self.Parent)) then return end;

	self.Parent = data:GetEntity();
	self.Created = CurTime();
	self.LifeTime = 1.7;
	local offset = 500*Vector(1,1,1);
	self.Parent:SetRenderBounds(-1*offset,offset);

	local dynlight = DynamicLight(math.Rand(0,1000));
	dynlight.Pos = self.Parent:GetPos()+self.Parent:GetUp()*2;
	dynlight.Size = 500;
	dynlight.Decay = 500;
	dynlight.R = 255;
	dynlight.G = 255;
	dynlight.B = 255;
	dynlight.DieTime = CurTime()+5;
end

function EFFECT:Think( )
	return (CurTime() - self.Created < self.LifeTime);
end

function EFFECT:Render()
	if(not IsValid(self.Parent)) then return end
	local multiply = (CurTime() - self.Created)/self.LifeTime;
	local time = CurTime() - self.Created;

	if(multiply > 0) then

		if self.Parent:IsPlayer() then

			if (LocalPlayer() == self.Parent) then

				local size = 0;
				if (time < 0.8) then
					size = time;
				else
					size = (1.7-time);
				end

				local tab = {}
				tab[ "$pp_colour_addr" ] = 0
				tab[ "$pp_colour_addg" ] = 0
				tab[ "$pp_colour_addb" ] = 0
				tab[ "$pp_colour_brightness" ] = size/2
				tab[ "$pp_colour_contrast" ] = 1+size/2
				tab[ "$pp_colour_colour" ] = 1
				tab[ "$pp_colour_mulr" ] = 1
				tab[ "$pp_colour_mulg" ] = 1
				tab[ "$pp_colour_mulb" ] = 1
				DrawColorModify( tab )

			end

		else

			local pos = self.Parent:GetPos()+self.Entity:GetUp()*2;
			local size = 0;
			if (time < 0.8) then
				size = time*400;
			else
				size = (1.7-time)*400;
			end

			render.SetMaterial(self.BearingSprite);
			render.DrawSprite(pos, size, size, Color(255,255,255));

		end

	end
end
