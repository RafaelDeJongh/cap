ANIM.Model = "models/zup/stargate/sga_shield.mdl";
ANIM.Sounds = {
	Open=Sound("stargate/iris_atlantis_open.mp3"),
	Close=Sound("stargate/iris_atlantis_close.mp3"),
	Hit=Sound("stargate/iris_atlantis_hit.mp3"),
	Idle=Sound("stargate/iris_atlantis_loop.wav"),
	OpenEnergy=Sound("stargate/iris_open_atlantis.mp3"),
	Fail=Sound("buttons/button19.wav"),
}

--################# Init function - Do we need to do anything if we init? @aVoN
function ANIM:Init()
	self.Entity:SetNoDraw(true);
	local e = ents.Create("prop_dynamic_override");
	e:SetModel(self.Model);
	e:SetPos(self.Entity:GetPos());
	e:SetAngles(self.Entity:GetAngles());
	e:SetParent(self.Entity);
	e:DrawShadow(false);
	e:SetColor(Color(255,255,255,254)); -- Alpha need to be lowered a bit, so it's really translucent
	e:Spawn();
	e:Activate();
	e:SetDerive(self.Entity);
	self.Iris = e;
end

--################# Close the Shield (aka Activate) @aVoN
function ANIM:Close()
	self.Iris:SetNoDraw(false);
	local id = "ShieldSound."..self.Entity:EntIndex();
	self.Entity:EmitSound(self.Sounds.Close,90,math.random(98,103));
	if(self.IdleSound) then self.IdleSound:Stop() end;
	self.IdleSound = CreateSound(self.Entity,self.Sounds.Idle);
	local snd = self.IdleSound;
	local e = self.Entity;
	timer.Remove(id);
	timer.Create(id,1.5,1,
		function()
			if(IsValid(e)) then
				snd:PlayEx(90,math.random(98,103));
			end
		end
	);
	self:SetBusy(0.7);
end

--################# Open the Shield (aka Deactivate) @aVoN
function ANIM:Open(energy)
	self.Iris:SetNoDraw(true);
	if (energy) then
		self.Entity:EmitSound(self.Sounds.OpenEnergy,90,math.random(98,103));
	else
		self.Entity:EmitSound(self.Sounds.Open,90,math.random(98,103));
	end
	timer.Remove("ShieldSound."..self.Entity:EntIndex());
	if(self.IdleSound) then
		self.IdleSound:FadeOut(0.2);
		self.IdleSound = nil;
	end
	self:SetBusy(0.7);
end

--################# Iris got Hit - Do something @aVoN
function ANIM:Hit(e,pos,velo)
	self.Entity:EmitSound(self.Sounds.Hit,90,math.random(98,103));
end

--################# Called, if you remove this thing @aVoN
function ANIM:Remove()
	if(self.IdleSound) then self.IdleSound:Stop() end;
	for _,v in pairs(self.Sounds) do
		self.Entity:StopSound(v);
	end
end
