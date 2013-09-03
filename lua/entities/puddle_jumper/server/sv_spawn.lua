--###### Spawn the shield @RononDex
function ENT:SpawnShieldGen()

	if(IsValid(self)) then
		local e = ents.Create("ship_shield_generator")
		e:SetPos(self:GetPos()+self:GetForward()*-125)
		e:SetAngles(self:GetAngles())
		e:SetParent(self)
		e:Spawn()
		e:Activate()
		e:SetSolid(SOLID_NONE)
		e:SetColor(Color(255,255,255,0))
		e:SetRenderMode( RENDERMODE_TRANSALPHA );
		self.Shields=e
		e.StrengthMultiplier={0.1,0.5,-5}
		e:SetShieldColor(1,0.98,0.94)
	end
end

--###### Spawn the solid doors @RononDex
function ENT:SpawnBackDoor(ent)

	local e = ent or ents.Create("prop_physics")
	e:SetModel(self.Gibs.Gib1)
	e:SetPos(self:GetPos())
	e:SetAngles(self:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetColor(Color(255,255,255,0))
	e:SetRenderMode(RENDERMODE_TRANSALPHA);
	e.JumperPart = true;
	if (not ent) then constraint.Weld(e,self,0,0,0,true) end
	self.Door = e

end

function ENT:SpawnBulkHeadDoor(ent)

	local e = ent or ents.Create("prop_physics")
	e:SetModel(self.Gibs.Gib3)
	e:SetPos(self:GetPos())
	e:SetAngles(self:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetRenderMode(RENDERMODE_TRANSALPHA);
	e:SetColor(Color(255,255,255,0))
	e.JumperPart = true;
	if (not ent) then constraint.Weld(e,self,0,0,0,true) end
	self.BulkDoor = e

end

--############# Cloak @ aVoN
function ENT:Status(b,nosound)
	if(b) then
		if(not(self:Enabled())) then
			local e = ents.Create("cloaking")
			e.Size = 150
			e:SetPos(self:GetPos()+self:GetForward()*-50)
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

function ENT:SpawnToggleButton()

	local e = ents.Create("jumper_button");
	e:SetPos(self:GetPos() - self:GetForward()*238 + self:GetRight()*38 + self:GetUp()*12)
	e:SetAngles(self:GetAngles()+Angle(47.535 ,47 ,39.105))
	e:Spawn()
	e:Activate()
	e:SetParent(self.Entity)
	e:SetColor(Color(64,65,48,127.5))
	e:SetRenderMode(RENDERMODE_TRANSALPHA);
	e.JumperPart = true;
	e.Parent = self.Entity
	e.RearDoor = true;
	e.Bulkhead = false;
	constraint.Weld(e,self,0,0,0,true)

	local e2 = ents.Create("jumper_button");
	e2:SetPos(self:GetPos() - self:GetForward()*224 + self:GetRight()*-38 + self:GetUp()*8)
	e2:SetAngles(self:GetAngles()+Angle(47.535 ,47 ,39.105))
	e2:Spawn()
	e2:Activate()
	e2:SetParent(self.Entity)
	e2:SetColor(Color(64,65,48,127.5))
	e2:SetRenderMode(RENDERMODE_TRANSALPHA);
	e2.JumperPart = true;
	e2.Parent = self.Entity
	e2.RearDoor = true;
	e2.Bulkhead = false;
	constraint.Weld(e2,self,0,0,0,true)

	local e3 = ents.Create("jumper_button");
	e3:SetPos(self:GetPos() - self:GetForward()*40 + self:GetRight()*29 + self:GetUp()*12)
	e3:SetAngles(self:GetAngles()+Angle(90 ,0 ,0))
	e3:Spawn()
	e3:Activate()
	e3:SetParent(self.Entity)
	e3:SetColor(Color(64,65,48,127.5))
	e3:SetRenderMode(RENDERMODE_TRANSALPHA);
	e3.JumperPart = true;
	e3.Parent = self.Entity
	e3.RearDoor = false;
	e3.Bulkhead = true;
	constraint.Weld(e3,self,0,0,0,true)

	local e4 = ents.Create("jumper_button");
	e4:SetPos(self:GetPos() - self:GetForward()*32 + self:GetRight()*-29 + self:GetUp()*12)
	e4:SetAngles(self:GetAngles()+Angle(90 ,0 ,0))
	e4:Spawn()
	e4:Activate()
	e4:SetParent(self.Entity)
	e4:SetColor(Color(64,65,48,127.5))
	e4:SetRenderMode(RENDERMODE_TRANSALPHA);
	e4.JumperPart = true;
	e4.Parent = self.Entity
	e4.RearDoor = false;
	e4.Bulkhead = true;
	constraint.Weld(e4,self,0,0,0,true)

	self.Buttons = {
		B1 = e,
		B2 = e2,
		B3 = e3,
		B4 = e4,
	}

end

function ENT:RemoveAll()

	for _,v in pairs(self.Buttons or {}) do
		if IsValid(v) then
			v:Remove();
		end
	end

	if IsValid(self.Door or {}) then
		self.Door:Remove();
	end

	if IsValid(self.BulkDoor or {}) then
		self.BulkDoor:Remove();
	end
end