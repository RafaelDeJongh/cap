if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Gravity Controller"
ENT.Author = "WeltEnSTurm"
ENT.Category = "Stargate"
ENT.IsWire = true

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.WireDebugName = "GravityController"

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile();

function ENT:Initialize()
	math.randomseed(CurTime())
	if !self.ConTable or table.Count(self.ConTable)==0 then return end
	self.Entity:SetModel(self.ConTable["sModel"][2])
	self.Entity.Sound=CreateSound(self.Entity, self.ConTable["sSound"][2])
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.phys=self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:Wake()
		if self.Weight and self.Weight != 0 then
			self.phys:SetMass(math.Clamp(self.Weight, 1, 500))
		end
	end
	if (WireAddon) then
		self:CreateWireInputs("ZPos", "Hovermode", "Add to Z", "Activate", "AirbrakeX" , "AirbrakeY" , "AirbrakeZ" , "GlobalBrake","Disable Use")
		self:CreateWireOutputs("Activated")
	end
	self.CanUse = true
	self.IsGravcontroller = true
	self.PitchStartup = 0
	self.Active = false
	self.ConstrainedEntities = {}

	--Hoverball-like stuff
	self.ZPos = self:GetPos().z
	self.ZAddValue = 0
	self.ZAddByKey = 0
	self.HoverSpeed = 1
	self.ZAddMultiplicator = 10
	self.NextHMChange = 0
	self.NextCheckConstrained=0
	self.LastConstrained={}
	if (pewpew and pewpew.NeverEverList and not table.HasValue(pewpew.NeverEverList,self.Entity:GetClass())) then table.insert(pewpew.NeverEverList,self.Entity:GetClass()); end -- pewpew support
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end

function ENT:TriggerInput(iname, value)
	if(iname == "Activate") then
		if(value == 1) then
			self:ActivateIt(true)
		else
			self:ActivateIt(false)
		end
	end
	if(iname == "AirbrakeX") then
		if value > 100 then
			value = 100
		end
		self.AirbrakeX = value
	end
	if(iname == "AirbrakeY") then
		if value > 100 then
			value = 100
		end
		self.AirbrakeY = value
	end
	if(iname == "AirbrakeZ") then
		if value > 100 then
			value = 100
		end
		self.AirbrakeZ = value
	end
	if(iname == "GlobalBrake") then
		if value > 100 then
			value = 100
		end
		self.brakepercent = value
	end
	if(iname == "ZPos") then
		self.ZPos = value
	end
	if(iname == "Hovermode") then
		self:SetHoverMode(value)
	end
	if(iname == "Add to Z") then
		self.ZAddValue = value
	end
end

function ENT:ActivateIt(bool)
	if (!self.ConTable) then return end
	if !bool and self.Active then
		if (IsValid(self.phys)) then
			self.phys:Wake()
		end
		self:SetNetworkedBool("drawsprite", false)
		self.Active = false
		self:SetWire("Activated",false)
		for _,e in pairs(self.ConstrainedEntities) do
			if e.IsGravcontroller and e.Active and e != self.Entity then
				return
			end
		end
	elseif bool and !self.Active then
		if self.ConTable["bDrawSprite"][2] == 1 then self:SetNWBool("drawsprite",true) end
		self.Sound:Play()
		self.SoundPlaying = true
		self.Sound:ChangePitch(self.PitchStartup,0)
		self.Active = true
		self:SetWire("Activated",true)
	end
	self.ConstrainedEntities = constraint.GetAllConstrainedEntities(self.Entity)
	if self.ConTable["bBrakeOnly"] and self.ConTable["bBrakeOnly"][2] == 0 or self.ConTable["bSGAPowerNode"] and self.ConTable["bSGAPowerNode"][2]==1 then
		if self.ConTable["bSGAPowerNode"][2]==1 then
			self.TargetPos=self.Entity:GetPos()
		end
		for k, e in pairs(self.ConstrainedEntities or {}) do
			if bool and self.Active then
				self:SetEntGravity(e, true)
			elseif !bool and !self.Active then
				self:SetEntGravity(e, false)
			end
		end
	end
end

function ENT:Use(a, c)
	if (self:GetWire("Disable Use")>0) then return end
	if !a:KeyPressed(IN_USE) then return false end
	if !(a == self.Owner) then return end
	if self.Active and self.CanUse then
		self:ActivateIt(false)
	elseif !self.Active and self.CanUse then
		self:ActivateIt(true)
	end
	return false
end

local NULLVEC=Vector(0,0,0)
function ENT:PhysicsUpdate(phys)
	if !phys:IsValid() then return end
	local actvel = phys:GetVelocity()
	local vel = NULLVEC
	local pos = self.Entity:GetPos()
	if self.ConTable["bSGAPowerNode"][2] != 1 then
		if self.ConTable["bRelativeToGrnd"][2] == 0 and self.HoverMode then
			if self.ZAddValue != 0 then
				self.ZPos = self.ZPos + self.ZAddValue
			end
			if !self.ZAddByKey then self.ZAddByKey = 0 end
			if self.ZAddByKey != 0 then
				self.ZPos = self.ZPos + self.ZAddByKey
			end
		elseif self.HoverMode then
			local trd={
				start=pos,
				endpos=self:LocalToWorld(self.StartVector*self.ConTable["fHeightAboveGrnd"][2]),
				filter=self.Entity,
				mask=MASK_SHOT_HULL+MASK_WATER,
			}
			local tr = util.TraceLine(trd)
			if tr.Hit then
				vel = vel-(trd.endpos-tr.HitPos)*self.ConTable["fHoverSpeed"][2]
			end
		end
		if(self.ConTable["bGlobalBrake"][2] == 0 and !self.ActiveSPC and (self.Active or self.ConTable["bAlwaysBrake"][2] == 1)) then
			local veladd = self.Entity:WorldToLocal(self.Entity:GetVelocity()+pos)
			veladd.x = veladd.x - veladd.x*self.ConTable["fAirbrakeX"][2]/100
			veladd.y = veladd.y - veladd.y*self.ConTable["fAirbrakeY"][2]/100
			veladd.z = veladd.z - veladd.z*self.ConTable["fAirbrakeZ"][2]/100
			vel = vel + self.Entity:LocalToWorld(veladd)-pos
		elseif(self.ConTable["bGlobalBrake"][2] == 1 and (self.Active or self.ConTable["bAlwaysBrake"][2] == 1)) then
			vel = vel + actvel*((100.0 - self.ConTable["fBrakePercent"][2])/100.0)
		end
		if self.HoverMode and self.ConTable["bRelativeToGrnd"][2] == 0 then
			if (self.ZPos and self.ZPos != 0) then
				vel = vel + Vector(0,0, self.ZPos - pos.z)*self.ConTable["fHoverSpeed"][2]/3
			end
		end
		if (self.ConTable["bAngularBrake"][2] == 1 and (self.Active or self.ConTable["bAlwaysBrake"][2] == 1)) then
			local avel = phys:GetAngleVelocity()
			if self.ConTable["fAngBrakePerc"][2] > 100 then self.ConTable["fAngBrakePerc"][2] = 100 end
			self.VeloC = (Angle(0,0,0) - avel)
			phys:AddAngleVelocity((self.ConTable["fAngBrakePerc"][2]/100)*self.VeloC)
		end
	elseif self.Active and self.TargetPos then
		vel = self.TargetPos-pos-actvel/2
	end
	if self.PitchStartup == 100 then
		local soundvel = self.Entity:GetVelocity():Length()
		if soundvel > 900 then soundvel = 900  end
		self.Sound:ChangePitch(100+(soundvel/6),0)
	end
	if vel != NULLVEC then
		phys:SetVelocity(vel)
	end
end

function ENT:SetHoverMode(b)
	local crt = CurTime()
	if self.NextHMChange > crt then return end
	local adp = 0
	local div = 0
	self.ConstrainedEntities.GravControllers = {}
	for _,e in pairs(self.ConstrainedEntities) do
		if e.IsGravcontroller then
			adp = adp + e:GetPos().z
			div = div + 1
			table.insert(self.ConstrainedEntities.GravControllers, e)
		end
	end
	for _,gc in pairs(self.ConstrainedEntities.GravControllers) do
		gc.ZPos = adp/div
		gc.NextHMChange = crt + 1
		if !b or b == 0 then
			gc.HoverMode = false
		else
			gc.HoverMode = true
		end
	end
end

function ENT:OnRemove()
	self:ActivateIt(false)
	if (self.Sound) then
		self.Sound:Stop()
	end
end

function ENT:SetEntGravity(e, b)
	if !e.phys then
		e.phys = e:GetPhysicsObject()
	end
	if e.phys and e.phys:IsValid() then
		local gb=e.phys:IsGravityEnabled()
		if !b and !gb then
			if !(e.environment and (e.environment.IsSpace and e.environment:IsSpace() or e.environment.IsStar and e.environment:IsStar())) then
				e.phys:EnableGravity(true)
			end
			e.IgnoreGravity = false
		elseif b and gb then
			e.phys:EnableGravity(false)
			e.IgnoreGravity = true
		end
	end
end

function ENT:Think()
	if !self.ConTable or table.Count(self.ConTable)==0 then self:Remove() return end
	local crt = CurTime()
	if crt>self.NextCheckConstrained and self.ConTable["bLiveGravity"]==1 and self.ConTable["bBrakeOnly"][2] == 0 or self.ConTable["bSGAPowerNode"][2]==1 then
		local t=constraint.GetAllConstrainedEntities(self.Entity)
			for _,e in pairs(t) do
				if e.phys and IsValid(e.Phys) and e.phys:IsGravityEnabled() == self.Active then
					self:SetEntGravity(e, self.Active)
				end
			end
		self.NextCheckConstrained=crt+1
	end
	self.PitchStartup=math.Clamp(self.PitchStartup+(self.Active and 1 or -1),0,100)
	if !self.Active and self.PitchStartup == 0 and self.SoundPlaying then
		self.Sound:Stop()
		self.SoundPlaying = false
	end
	if self.SoundPlaying then
		self.Sound:ChangePitch(self.PitchStartup,0)
	end
	if self.PitchStartup < 100 then
		self:NextThink(crt)
		return true
	end
end

local function GoUp(p, e)
	if !e or !e:IsValid() then return end
	e.ZAddByKey = e.ConTable["fHoverSpeed"][2]
end
numpad.Register("GoUp", GoUp)

local function GoDown(p, e)
	if !e or !e:IsValid() then return end
	e.ZAddByKey = -e.ConTable["fHoverSpeed"][2]
end
numpad.Register("GoDown", GoDown)

local function GoStop(p, e)
	if !e or !e:IsValid() then return end
	e.ZAddByKey = 0
end
numpad.Register("GoStop", GoStop)

local function ToggleHovermode(p, e)
	if !e or !e:IsValid() then return end
	if !e.HoverMode then
		e:SetHoverMode(1)
	else
		e:SetHoverMode(0)
	end
end
numpad.Register("ToggleHoverMode", ToggleHovermode)

local function FireGravitycontroller(ply, ent)
	if !ent:IsValid() then return false end
	if ent.Active then
		ent:ActivateIt(false)
	else
		ent:ActivateIt(true)
	end
end
numpad.Register("FireGravitycontroller", FireGravitycontroller)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	self.Owner = ply;
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

end

if CLIENT then

function ENT:Initialize()
	self.Glow = Material("sprites/light_glow02_add")
end

function ENT:Draw()
	local drawsprite = self:GetNetworkedBool("drawsprite")
	self.Entity:DrawModel()
	if drawsprite then
		local vel = self.Entity:GetVelocity():Length()
		local rad = self.Entity:BoundingRadius()
		local pos = (self.Entity:GetPos() --[[+ self.Entity:GetUp()*rad/2]])
		vel = vel / 700 + 0.2
		if vel > 1 then vel = 1 end
		render.SetMaterial(self.Glow)
		local color = Color(70*vel, 180*vel, 255*vel, 255)
		render.DrawSprite(pos, rad*2, rad*2, color)
		render.DrawSprite(pos, rad*3, rad*3, color)
		render.DrawSprite(pos, rad*4, rad*4, color)
	end
end

end