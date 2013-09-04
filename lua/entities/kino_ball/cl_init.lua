include('shared.lua');
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("kino_ball", SGLanguage.GetMessage("entity_kino"))
end

ENT.RenderGroup 	= RENDERGROUP_BOTH

ENT.Sounds={
	Fly=Sound("kino/kino_fly.wav"),
}

function ENT:Initialize()
	self.FlySound = self.FlySound or CreateSound(self.Entity,self.Sounds.Fly);
	self.FlySoundOn = false;
	self:StartClientsideSound()
end

function ENT:OnRemove()
	self.FlySound:Stop();
end

function ENT:StartClientsideSound()
	self.FlySound:SetSoundLevel(80);
	self.FlySound:PlayEx(1,80);
	self.FlySoundOn = true;
end

function ENT:Think()

	local velo = self.Entity:GetVelocity()*10;
	local pitch = -1*self.Entity:GetVelocity():Length();
	local doppler = 0;

	local dir = (LocalPlayer():GetPos() - self.Entity:GetPos());
	doppler = velo:Dot(dir)/(150*dir:Length());


	if(self.FlySoundOn) then
		self.FlySound:ChangePitch(math.Clamp(60 + pitch/25,75,100),0.1);-- + doppler,0);
	end

end
