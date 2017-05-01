--###### Spawn the shield @RononDex
function ENT:SpawnShieldGen(p)

	if(IsValid(self)) then
		local e = ents.Create("ship_shield_generator")
		e:SetPos(self:GetPos()+self:GetForward()*-125)
		e:SetAngles(self:GetAngles())
		e:SetParent(self)
		e:Spawn()
		e:Activate()
		e:AddFlags(FL_DONTTOUCH);
		e:SetSolid(SOLID_NONE)
		e:SetColor(Color(255,255,255,0))
		e:SetRenderMode( RENDERMODE_TRANSALPHA );
		e.JumperPart = true;
		self.Shields=e
		e.StrengthMultiplier={0.1,0.5,-5}
		e:SetShieldColor(1,0.98,0.94)
		if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end
	end
end

--###### Spawn the solid doors @RononDex
function ENT:SpawnBackDoor(ent,p)

	local e = ent or ents.Create("prop_physics")
	e:SetModel(self.Gibs.Gib1)
	e:SetPos(self:GetPos())
	e:SetAngles(self:GetAngles())
	e:Spawn()
	e:Activate()
	e:AddFlags(FL_DONTTOUCH);
	e:SetColor(Color(255,255,255,0))
	e:SetRenderMode(RENDERMODE_TRANSALPHA);
	e.JumperPart = true;
	if (not ent) then constraint.Weld(e,self,0,0,0,true) end
	self.Door = e
	if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end

end

function ENT:SpawnBulkHeadDoor(ent,p)

	local e = ent or ents.Create("prop_physics")
	e:SetModel(self.Gibs.Gib3)
	e:SetPos(self:GetPos())
	e:SetAngles(self:GetAngles())
	e:Spawn()
	e:Activate()
	e:AddFlags(FL_DONTTOUCH);
	e:SetRenderMode(RENDERMODE_TRANSALPHA);
	e:SetColor(Color(255,255,255,0))
	e.JumperPart = true;
	if (not ent) then constraint.Weld(e,self,0,0,0,true) end
	self.BulkDoor = e
	if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end

end

--############# Cloak @ aVoN
function ENT:Status(b,nosound)
	if(b) then
		if(not(self:Enabled())) then
			local e = ents.Create("cloaking")
			e.Size = 80
			e:SetPos(self:GetPos()+self:GetForward()*-100)
			e:SetAngles(self:GetAngles())
			e:SetParent(self)
			e:Spawn()
			self:EmitSound(self.Sounds.Cloak,100,math.random(80,100))
			if(e and e:IsValid() and not e.Disable) then -- When our new cloak mentioned, that there is already a cloak
				self.Cloak = e
				self.Cloaked = e
				return
			end
		end
	else
		if(self:Enabled()) then
			self.Cloak:Remove()
			self.Cloak = nil
			self:EmitSound(self.Sounds.Uncloak,80,math.random(90,110))
		end
	end
	return
end

function ENT:SpawnToggleButton(p)

	local e = {};
	for i=1,4 do
		e[i] = ents.Create("jumper_button");
		e[i]:Spawn();
		e[i]:Activate();
		e[i]:SetParent(self);
		e[i]:AddFlags(FL_DONTTOUCH);
		if(not self.Cloaked) then
			e[i]:SetColor(Color(64,65,48,127.5));
		else
			e[i]:SetColor(Color(255,255,255,0));
		end
		e[i]:SetRenderMode(RENDERMODE_TRANSALPHA);
		e[i].Parent = self;
		//constraint.Weld(e[i],self,0,0,0,true);
		e[i].JumperPart = true;
		self.Buttons[i] = e[i]
		if(i==1) then
			e[i].RearDoor = true;
			e[i].Bulkhead = false;
			e[i]:SetPos(self:GetPos() - self:GetForward()*238 + self:GetRight()*38 + self:GetUp()*12)
			e[i]:SetAngles(self:GetAngles()+Angle(47.535 ,47 ,39.105))
		elseif(i==2) then
			e[i].RearDoor = true;
			e[i].Bulkhead = false;
			e[i]:SetPos(self:GetPos() - self:GetForward()*224 + self:GetRight()*-38 + self:GetUp()*8)
			e[i]:SetAngles(self:GetAngles()+Angle(47.535 ,47 ,39.105))
		elseif(i==3) then
			e[i].RearDoor = false;
			e[i].Bulkhead = true;
			e[i]:SetPos(self:GetPos() - self:GetForward()*40 + self:GetRight()*29 + self:GetUp()*12)
			e[i]:SetAngles(self:GetAngles()+Angle(90 ,0 ,0))
		elseif(i==4) then
			e[i].RearDoor = false;
			e[i].Bulkhead = true;
			e[i]:SetPos(self:GetPos() - self:GetForward()*32 + self:GetRight()*-29 + self:GetUp()*12)
			e[i]:SetAngles(self:GetAngles()+Angle(90 ,0 ,0))
		end
		if CPPI and IsValid(p) and e[i].CPPISetOwner then e[i]:CPPISetOwner(p) end
	end
end


function ENT:SpawnOpenedDoor(p)

	local d = ents.Create("prop_physics");
	d:SetPos(self:GetPos()-self:GetForward()*145+self:GetUp()*140);
	d:SetModel("models/Iziraider/jumper/gibs/backdoor.mdl");
	d:SetAngles(self:GetAngles()-Angle(60,0,0));
	d:SetParent(self);
	d.JumperPart = true;
	d:Spawn();
	d:Activate();
	d:AddFlags(FL_DONTTOUCH);
	d:SetRenderMode(RENDERMODE_TRANSALPHA)
	d:SetSolid(SOLID_NONE);
	d:SetColor(Color(255,255,255,0));
	d:DrawShadow(false);
	if CPPI and IsValid(p) and d.CPPISetOwner then d:CPPISetOwner(p) end

	constraint.Weld(d,self,0,0,0,true)
	self.OpenedDoor = d;
end

function ENT:SpawnSeats(p)
	local e ={}
	self.Seats = {}
	for i=1,9 do
		e[i] = ents.Create("prop_vehicle_prisoner_pod");
		e[i]:SetAngles(self:GetAngles());
		if(i==1) then
			e[i]:SetPos(self:GetPos()+self:GetRight()*40+self:GetForward()*-60+self:GetUp()*-30);
		elseif(i==2) then
			self:SetAngles(self:GetAngles()+Angle(0,180,0));
			e[i]:SetPos(self:GetPos()+self:GetRight()*-40+self:GetForward()*-60+self:GetUp()*-30);
		elseif(i==3) then
			e[i]:SetPos(self:GetPos()+self:GetRight()*40+self:GetForward()*-95+self:GetUp()*-30);
		elseif(i==4) then
			self:SetAngles(self:GetAngles()+Angle(0,180,0));
			e[i]:SetPos(self:GetPos()+self:GetRight()*-40+self:GetForward()*-95+self:GetUp()*-30);
		elseif(i==5) then
			e[i]:SetPos(self:GetPos()+self:GetRight()*40+self:GetForward()*-132+self:GetUp()*-30);
		elseif(i==6) then
			self:SetAngles(self:GetAngles()+Angle(0,180,0));
			e[i]:SetPos(self:GetPos()+self:GetRight()*-40+self:GetForward()*-132+self:GetUp()*-30);
		elseif(i==7) then
			e[i]:SetPos(self:GetPos()+self:GetRight()*40+self:GetForward()*-165+self:GetUp()*-30);
		elseif(i==8) then
			self:SetAngles(self:GetAngles()+Angle(0,180,0));
			e[i]:SetPos(self:GetPos()+self:GetRight()*-40+self:GetForward()*-165+self:GetUp()*-30);
		elseif(i==9) then
			e[i]:SetAngles(self:GetAngles()+Angle(0,-90,0));
			e[i]:SetPos(self:GetPos()+self:GetRight()*30+self:GetUp()*-25+self:GetForward()*50);
			e[i].FrontSeat = true;
			self.FrontSeat = e[i];
		end
		e[i]:SetModel("models/nova/airboat_seat.mdl");
		e[i]:SetRenderMode(RENDERMODE_TRANSALPHA);
		e[i]:SetColor(Color(255,255,255,0));
		e[i]:Spawn();
		e[i]:Activate();
		e[i]:SetParent(self);
		e[i]:AddFlags(FL_DONTTOUCH);
		e[i].IsJumperSeat = true;
		e[i].Jumper = self;
		e[i].CloakNoDraw = true;
		self.Seats[i] = e[i];
		if CPPI and IsValid(p) and e[i].CPPISetOwner then e[i]:CPPISetOwner(p) end
	end

end

function ENT:SpawnPilot(pos)

	if(IsValid(self.Pilot)) then
		local e = ents.Create("prop_physics");
		e:SetModel(self.Pilot:GetModel());
		e:SetPos(pos)
		local ang = self:GetAngles();
		if(self.PilotAngle) then
			ang = self:GetAngles() + self.PilotAngle;
		end
		e:SetAngles(ang)
		e:SetParent(self);
		e:Spawn();
		e:Activate();
		
		local anim = "sit_rollercoaster";
		if(self.PilotAnim) then	
			anim = self.PilotAnim;
		end
		e:SetSequence(e:LookupSequence(anim));
		
		self.PilotAvatar = e;
		self:SetNWEntity("PilotAvatar",e);
	end
end

function ENT:RemoveAll()

	for _,v in pairs(self.Buttons or {}) do
		if IsValid(v) then
			v:Remove();
		end
	end


	if(IsValid(self.OpenedDoor)) then
		self.OpenedDoor:Remove();
	end


	if IsValid(self.Door) then
		self.Door:Remove();
	end
    
    if(IsValid(self.PilotAvatar)) then
        self.PilotAvatar:Remove();
    end

	if IsValid(self.BulkDoor) then
		self.BulkDoor:Remove();
	end
end