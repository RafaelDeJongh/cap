
function ENT:ExitJumper() --################# Get out the jumper@RononDex
	if (IsValid(self.Pilot)) then
		StarGate.KeyBoard.ResetKeys(self.Pilot,"PuddleJumper");

		self.Pilot:UnSpectate()
		self.Pilot:DrawViewModel(true)
		self.Pilot:DrawWorldModel(true)
		self.Pilot:Spawn()
		self.Pilot:SetNetworkedBool("isFlyingjumper",false)
		self.Pilot:SetPos(self:GetPos()+self:GetForward()*15+self:GetUp()*-40)
		self.AllowActivation=false
		self.Pilot:SetHealth(self.health)
		self.Pilot:SetMoveType(MOVETYPE_WALK)
		self:EmitSound(self.Sounds.Shutdown,100,100)
		self:SetNetworkedEntity("jumper",NULL)
		--self.Pilot:SetScriptedVehicle(NULL)
		self.Pilot:SetNetworkedEntity("ScriptedVehicle", NULL)
		self.Pilot:SetViewEntity(NULL)
	end

	self.HoverPos = self:GetPos();

	self:RemoveDrones() -- Remove the drone props... SO MANY BUGS BECAUSE OF THESE THINGS!
	self.Roll=0
	self.LiftOff = false
	self.Inflight=false
	self.Accel.FWD = 0;
	self.Accel.RIGHT = 0;
	self.Accel.UP = 0;

	if (not self.Cloaked) then
		self:SpawnToggleButton();
	end
	self:SpawnBulkHeadDoor();
	self:SpawnBackDoor();

	self:ToggleRotorwash(false);

	for k,v in pairs(self.PWeapons) do
		self.Pilot:Give(tostring(v))
	end

	if(self.epodo) then
		self:TogglePods()
	end

	self.Pilot = nil;

	timer.Simple( 0.75, function()
		self.AllowActivation = true
	end)
end

function ENT:EnterJumper(ply) --############### Get in the jumper @ RononDex

	if(self.AllowActivation) then

		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():EnableMotion(true)
		self.Inflight = true
		self.Pilot = true
		self.Pilot=ply
		self.Roll=0
		if(self.BulkHead) then
			self:ToggleBulkHead()
		end

		if(not self.Cloaked) then
			self:ToggleRotorwash(true)
		end

		--ply:SetScriptedVehicle(self)
		ply:SetNetworkedEntity("ScriptedVehicle", self) -- still needed for event horizon
		ply:SetViewEntity(self)

		for _,v in pairs(ply:GetWeapons()) do
			table.insert(self.PWeapons, v:GetClass())
		end
		self.health=ply:Health()

		self.AllowActivation=false
		self.LiftOff = true
		self:EmitSound(self.Sounds.Startup, 100, 100)
		ply:SetMoveType(MOVETYPE_OBSERVER)
		ply:DrawViewModel(false)
		ply:DrawWorldModel(false)

		self.StartPos = self:GetPos()

		self:RemoveAll(); -- We need to remove all welded props in order to go through gates properly.

		ply:Spectate( OBS_MODE_CHASE )
		ply:StripWeapons()

		ply:SetNetworkedBool("isFlyingjumper",true)
		ply:SetNetworkedEntity("jumper",self)
	end
	self.Entered=true
	timer.Simple( 0.75, function()
		self.AllowActivation=true
		self.LiftOff=false
	end)
end