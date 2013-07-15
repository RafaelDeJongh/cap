include("shared.lua")

function ENT:Initialize( )
	--self:SetShouldDrawInViewMode( true )
	self.FXEmitter = ParticleEmitter( self:GetPos())
	self.SoundsOn = {}
	if (self.Sounds.Engine) then
		self.EngineSound = self.EngineSound or CreateSound(self.Entity,self.Sounds.Engine);
	end
end

function SGVehBaseCalcView(Player, Origin, Angles, FieldOfView)
	local view = {}
	local p = Player
	local self = p:GetNetworkedEntity("ScriptedVehicle", NULL)

	if((self)and(self:IsValid()) and self.IsSGVehicle and not self.IsSGVehicleCustomView) then
		local pos = self:GetPos()+self:GetUp()*self.UDist+LocalPlayer():GetAimVector():GetNormal()*self.Dist
		local face = ( ( self:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle()
			view.origin = pos
			view.angles = face
		return view
	end
end
hook.Add("CalcView", "SGVehBaseCalcView", SGVehBaseCalcView)

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
	if (self.EngineSound) then
		self.EngineSound:Stop();
	end
end

function ENT:Think()

	local p = LocalPlayer()
	local IsDriver = (p:GetNetworkedEntity(self.Vehicle,NULL) == self.Entity);
	local IsFlying = p:GetNWBool("Flying"..self.Vehicle,false);

	--######### Handle engine sound
	if(IsFlying) then
		-- Normal behaviour for Pilot or people who stand outside
		self:StartClientsideSound("Engine");
		--#########  Now add Pitch etc
		local velo = self.Entity:GetVelocity();
		local pitch = self.Entity:GetVelocity():Length();
		local doppler = 0;
		-- For the Doppler-Effect!
		if(not IsDriver) then
			-- Does the vehicle fly to the player or away from him?
			local dir = (p:GetPos() - self.Entity:GetPos());
			doppler = velo:Dot(dir)/(150*dir:Length());
		end
		if(self.SoundsOn.Engine) then
			self.EngineSound:ChangePitch(math.Clamp(60 + pitch/25,75,100) + doppler,0);
		end
	else
		self:StopClientsideSound("Engine");
	end
end

--################# Starts a sound clientside @aVoN
function ENT:StartClientsideSound(mode)
	if(not self.SoundsOn[mode]) then
		if(mode == "Engine" and self.EngineSound) then
			self.EngineSound:Stop();
			self.EngineSound:SetSoundLevel(90);
			self.EngineSound:PlayEx(1,100);
		end
		self.SoundsOn[mode] = true;
	end
end

--################# Stops a sound clientside @aVoN
function ENT:StopClientsideSound(mode)
	if(self.SoundsOn[mode]) then
		if(mode == "Engine" and self.EngineSound) then
			self.EngineSound:FadeOut(2);
		end
		self.SoundsOn[mode] = nil;
	end
end