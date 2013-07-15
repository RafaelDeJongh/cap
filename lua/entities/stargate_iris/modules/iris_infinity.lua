ANIM.Model = "models/cos/stargate/iris.mdl";
ANIM.Sounds = {
	Open=Sound("stargate/iris_open.mp3"),
	Close=Sound("stargate/iris_close.mp3"),
	Hit=Sound("stargate/iris_hit.mp3"),
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
	e:Spawn();
	e:Activate();
	e:SetDerive(self.Entity);
	self.Iris = e;
end

--################# Close the Iris @aVoN
function ANIM:Close()
	self.Iris:SetNoDraw(false);
	timer.Remove("Iris.Open."..self.Entity:EntIndex());
	self.Iris:Fire("SetAnimation","iris_close",0.2); -- Delay it to make it synced with the sound
	self.Entity:EmitSound(self.Sounds.Close,90,math.random(98,103));
	self:SetBusy(3.8);
end

--################# Open the Iris @aVoN
function ANIM:Open()
	self.Iris:Fire("SetAnimation","iris_open",0);
	self.Entity:EmitSound(self.Sounds.Open,90,math.random(98,103));
	local id = "Iris.Open."..self.Entity:EntIndex();
	local iris = self.Iris;
	timer.Remove(id);
	timer.Create("Iris.Open."..self.Entity:EntIndex(),3.6,1,
		function()
			if(IsValid(iris)) then iris:SetNoDraw(true) end;
		end
	);
	self:SetBusy(3.6);
end

--################# Iris got Hit - Do something @aVoN
function ANIM:Hit(e,pos,velo)
	self.Entity:EmitSound(self.Sounds.Hit,90,math.random(98,103));
end

--################# Called, if you remove this thing @aVoN
function ANIM:Remove()
	for _,v in pairs(self.Sounds) do
		self.Entity:StopSound(v);
	end
end
