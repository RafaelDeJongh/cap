/*   Copyright 2010 by Llapp   */

include('shared.lua') ;
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_weapon_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_asuran_satellite");
end

--[[ENT.RenderGroup = RENDERGROUP_BOTH;

function ENT:Initialize()
    --self:SetShouldDrawInViewMode( true );
end

function ENT:CalcView(Player, Origin, Angles, FieldOfView)
	local view={};
	local pos = Vector(0,0,0);
	local face = Angle(0,0,0);

    pos = self.Entity:GetPos()+self.Entity:GetForward()*52+Player:GetAimVector():GetNormal();--self.Entity:GetPos()+self.Entity:GetForward()*23
    face = (self.Entity:GetPos()+Vector(0,180,0)):Angle(); --Player:GetAimVector()     + Vector( 0, 0, 0 )
	view.origin = pos;
    --view.angles = face;
	--view.fov = FieldOfView;
    return view;
end

function ENT:Draw()
	self:DrawModel();
end]]--

--[[ENT.RenderGroup 	= RENDERGROUP_BOTH

ENT.Sounds={
	Beam=Sound("stargate/asuran/asurane_beam.wav"),
}

function ENT:Initialize()
	self.BeamSound = self.BeamSound or CreateSound(self.Entity,self.Sounds.Beam);
	self.BeamSoundOn = false;
	self:StartClientsideSound()
	self.Entity:GetNetworkedEntity("beamsound",false)
end

function ENT:OnRemove()
	self.BeamSound:Stop();
end

function ENT:StartClientsideSound()
	self.BeamSound:SetSoundLevel(100);
	self.BeamSound:PlayEx(1,60);
	--self.BeamSoundOn = false;
end

function ENT:Think()
	local velo = self.Entity:GetVelocity()*10;
	local pitch = self.Entity:GetVelocity():Length();
	local doppler = 0;

	local dir = (LocalPlayer():GetPos() - self.Entity:GetPos());
	doppler = velo:Dot(dir)/(160*dir:Length());


	if(self.Entity:GetNetworkedEntity("beamsound",true)) then
		self.BeamSound:ChangePitch(math.Clamp(150 + pitch,150,150) + doppler,0);
	end
end]]--