ENT.NextUse = {
	Shields = CurTime(),
	WepPods = CurTime(),
	BulkHead = CurTime(),
	Light = CurTime(),
	Door = CurTime(),
	EnginePods = CurTime(),
	Autopilot = CurTime(),
	Hover = CurTime(),
}

--########## Toggle the shield @RononDex
function ENT:ToggleShield()

	if(IsValid(self)) then
		if(self.CanShield) then
			if(self.NextUse.Shields < CurTime()) then
				if (IsValid(self.Shields)) then
					if(not(self.Shielded)) then
						if(not(self.Shields:Enabled())) then
							self.Shields:Status(true)
							self.Shielded=true
							self.CanCloak=false
						end
					else
						if(self.Shields:Enabled()) then
							self.Shields:Status(false)
							self.Shielded=false
							self.CanCloak=true
						end

					end
				end
				self.NextUse.Shields = CurTime() + 1;
			end
		end
	end
end

--########## Toggle the drone weapon pods @RononDex
function ENT:ToggleWeaponPods()

	if(self.epodo) then
		if(self.NextUse.WepPods < CurTime()) then
			if(self.CanWepPods) then
				if(not(self.WepPods)) then
					self.WepPodSeq = self:LookupSequence("wepo")
					self.WepPods=true
					self:RemoveDrones() -- Remove any invalid models
					timer.Simple(0.5, function()
						if(self.WepPods) then
							if(not(self.DronePropsMade)) then
								if(not(self.Cloaked)) then
									self:SpawnDroneProps()
								end
							end
						end
					end)
				else
					self.WepPodSeq = self:LookupSequence("wepc")
					self.WepPods=false
					self:RemoveDrones()
				end
				self.NextUse.WepPods = CurTime() + self:SequenceDuration(self.WepPodSeq);
				self:ResetSequence(self.WepPodSeq)
				self:SetPlaybackRate(1)
			end
			
		end
	end
	
end

--########## Toggle the bulk head doors @RononDex
function ENT:ToggleBulkHead()

	if(self.epodo) then
		self:TogglePods()
	end
	
	if(self.NextUse.BulkHead < CurTime()) then
		if(not(self.BulkHead)) then
			if(self.door) then
				self.BulkDoorSeq = self:LookupSequence("dobulko")
			else
				self.BulkDoorSeq = self:LookupSequence("dcbulko")
			end
			self.BulkHead=true
			if not self.Inflight then
				self.BulkDoor:SetSolid(SOLID_NONE)
			end
		else
			if(self.door) then
				self.BulkDoorSeq = self:LookupSequence("dobulkc")
			else
				self.BulkDoorSeq = self:LookupSequence("dcbulkc")
			end
			self.BulkHead=false
			if not self.Inflight then
				self.BulkDoor:SetSolid(SOLID_VPHYSICS);
			end
		end
		self:EmitSound(self.Sounds.BulkDoor,100,100)
		self:ResetSequence(self.BulkDoorSeq)
		self:SetPlaybackRate(0.80)
		self.NextUse.BulkHead = CurTime() + self:SequenceDuration(self.BulkDoorSeq);
	end
end

--######### Toggle the rotorwash effect @RononDex
function ENT:ToggleRotorwash(b)

	if(b) then
		local e = ents.Create("env_rotorwash_emitter")
		e:SetPos(self:GetPos())
		e:Spawn()
		e:Activate()
		e:SetParent(self)
		self.Rotorwash=e
	else
		if(IsValid(self.Rotorwash)) then
			self.Rotorwash:Remove()
		end
	end
end

ENT.Flashlight = {}
ENT.Flashlight[1] = NULL
ENT.Flashlight[2] = NULL
--######### Torches for dark places @RononDex
function ENT:ToggleLight()

	local PosTable = {
		self:GetPos()+self:GetForward()*150+self:GetRight()*-65+self:GetUp()*-25,
		self:GetPos()+self:GetForward()*150+self:GetRight()*65+self:GetUp()*-25,
	};

	if (self.NextUse.Light < CurTime()) then
		for i=1,2 do
			if not self.FlashOn then
				e = ents.Create( "env_projectedtexture" )
				e:SetParent( self.Entity )
				e:SetPos(PosTable[i])
				e:SetAngles(self:GetAngles())
				e:SetKeyValue( "enableshadows", 1 )
				e:SetKeyValue( "farz", 2048 )
				e:SetKeyValue( "nearz", 8 )
				e:SetKeyValue( "lightfov", 70 )
				e:SetKeyValue( "lightcolor", "255 255 255 255" )
				e:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
				e:Spawn()
				self.Flashlight[i] = e
				if i == 2 then
					self.FlashOn = true
				end
			else
				if IsValid(self.Flashlight[i]) then
					SafeRemoveEntity(self.Flashlight[i])
					if i == 2 then
						self.FlashOn = false;
						//return;
					end
				end
			end
		end
		self.NextUse.Light = CurTime() + 1;
	end
end


function ENT:ToggleDoor() --############# Toggle Door @ RononDex

	if(self.epodo) then
		self:TogglePods()
	end
	
	if(self.NextUse.Door < CurTime()) then
		if(not(self.door)) then
			if(self.BulkHead) then
				self.doorseq = self:LookupSequence("bodooro")
			else
				self.doorseq = self:LookupSequence("bcdooro")
			end
			self.door=true
			if not self.Inflight then
				if (IsValid(self.Door)) then
					self.Door:SetSolid(SOLID_NONE)
				end
				if(self.HoverAlways and IsValid(self.OpenedDoor)) then
					self.OpenedDoor:SetSolid(SOLID_VPHYSICS);
				end
			end
		else
			if(self.BulkHead) then
				self.doorseq = self:LookupSequence("bodoorc")
			else
				self.doorseq = self:LookupSequence("bcdoorc")
			end
			self.door=false
			if not self.Inflight then
				if(self.HoverAlways and IsValid(self.OpenedDoor)) then
					self.OpenedDoor:SetSolid(SOLID_NONE);
				end
				if (IsValid(self.Door)) then
					self.Door:SetSolid(SOLID_VPHYSICS)
				end
			end
		end
		self.NextUse.Door = CurTime() + self:SequenceDuration(self.doorseq);
	end
	self:ResetSequence(self.doorseq)
	self:SetPlaybackRate(0.675)
	self:EmitSound(self.Sounds.Door,100,100)
end

function ENT:ToggleCloak() --############# Toggle Cloak @ RononDex

	if(self.CanCloak)then
		if(self.CanDoCloak)then
			if(self.Cloaked)then
				if(not game.SinglePlayer()) then
					self:Status(false)
				else
					self:EmitSound(self.Sounds.Uncloak,80,math.random(90,110))
					local fx = EffectData();
						local pos = self:GetPos();
						fx:SetOrigin(pos);
						fx:SetStart(pos);
						fx:SetEntity(self);
						fx:SetScale(-2);
					util.Effect("cloaking",fx,true,true);
				end
				
				if(self.Inflight)then
					self:ToggleRotorwash(true)
				end
				if(self.WepPods) then
					if(not(self.DronePropsMade)) then
						self:SpawnDroneProps()
					end
				end
				self.AnimCloaked = false;
				self.CanDoCloak=false
				self.CanShield=true

				if IsValid(self.Pilot) then self.Pilot:SetNoTarget(false); end
				timer.Simple( 1.75, function()
					self.CanDoCloak=true;
					self.Cloaked = false;
					self:SetNetworkedBool("Cloaked",false);
				end);
			else
				if(not game.SinglePlayer()) then
					self:Status(true)
				else
					self:EmitSound(self.Sounds.Cloak,100,math.random(80,100))
					local fx = EffectData();
					local pos = self:GetPos();
					fx:SetOrigin(pos);
					fx:SetStart(pos);
					fx:SetEntity(self);
					fx:SetScale(2);
					util.Effect("cloaking",fx,true,true);
				end

				if IsValid(self.Pilot) then self.Pilot:SetNoTarget(true); end
				self.Cloaked = true
				if(self.WepPods) then
					if(self.DronePropsMade) then
						self:RemoveDrones()
					end
				end
				if(self.Inflight) then
					self:ToggleRotorwash(false)
				end
				self.AnimCloaked = true;
				self.CanShield=false
				self:SetNetworkedBool("Cloaked",true)
				self.CanDoCloak=false
				timer.Simple( 2, function() self.CanDoCloak=true end)
			end
		end
	end

end

function ENT:TogglePods() --############# Toggle Engine Pods @ RononDex

	if(self.door) then
		self:ToggleDoor()
	end

	if(self.BulkHead) then
		self:ToggleBulkHead()
	end

	if(self.CanOpenPods) then
		if(self.NextUse.EnginePods < CurTime()) then
			if(not(self.epodo)) then
				self.sequence = self:LookupSequence("epodo") -- Open the drive pods
				self.epodo = true
				self:EmitSound(self.Sounds.EnginePodOpen,100,100)
				self.CanDoPods=false
				self.CloakPods = true;
			else
				self.CanDoPods=false
				self.sequence = self:LookupSequence("epodc")
				self:EmitSound(self.Sounds.EnginePodClose,100,100)
				self.Roll=0
				if(self.WepPods) then
					self:ToggleWeaponPods()
				end
				self:RemoveDrones()
				self.CloakPods = false;
				timer.Simple( 1, function()
					self.epodo = false
				end)
			end
			self:ResetSequence(self.sequence)
			self:SetPlaybackRate(0.9)
			self.NextUse.EnginePods = CurTime() + self:SequenceDuration(self.sequence);
		end
	end
end
