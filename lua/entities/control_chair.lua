if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Control Chair"
ENT.Author = "RononDex, Markjaw"
ENT.Category = "Stargate Carter Addon Pack: Ships"

list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.AutomaticFrameAdvance=true

if CLIENT then

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_ships_cat");
ENT.PrintName = SGLanguage.GetMessage("entity_control_chair");
end

function ENT:Initialize()

	self.Dist = -200
	self.UDist = 100
	self.NextUse=CurTime()

	--self:SetShouldDrawInViewMode(true)

end

function ENT:Draw()

	local p = LocalPlayer();
	local Controlling = p:GetNetworkedBool("Control")

	self:DrawModel()

	if(Controlling) then
		self:DynLight(true)
	elseif((not(Controlling))) then
		self:DynLight(false)
	end
end

local function Data(um)
	local p = LocalPlayer()
	p.Controlling = um:ReadBool()
	p.Enabled=um:ReadBool()
	p.DroneCount=um:ReadShort()
	p.Chair=um:ReadEntity()
end
usermessage.Hook("ControlChair",Data)

function ControlCHCalcView(Player, Origin, Angles, FieldOfView)
	local view = {}
	local p = Player
	local self = p:GetNetworkedEntity( "ScriptedVehicle", NULL );
	local chair = p:GetNWEntity("chair")
	if(not IsValid(chair) or self:GetClass()!="control_chair") then return end;

	if IsValid(self) then
		local pos = chair:GetPos()+chair:GetUp()*self.UDist+chair:GetRight()*self.Dist
		local face = chair:GetAngles()+Angle(0,-90,0)
			view.origin = pos
			view.angles = face
		return view
	end
end
hook.Add("CalcView", "ControlCHCalcView", ControlCHCalcView)

function ENT:DynLight()

	local p = LocalPlayer()
	local pos = self:GetPos()+self:GetUp()*80
	local Controlling = p:GetNWBool("Control")

	if(IsValid(self)) then
		if(Controlling) then
			if(StarGate.VisualsMisc("cl_chair_dynlights")) then
				local dynlight = DynamicLight(self:EntIndex() + 4096);
				dynlight.Pos = pos;
				dynlight.Brightness = 5;
				dynlight.Size = 184;
				dynlight.Decay = 1024;
				dynlight.R = 25;
				dynlight.G = 255;
				dynlight.B = 255;
				dynlight.DieTime = CurTime()+1;
			end
		end
	end
end

end

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end

AddCSLuaFile()

ENT.Models ={
	Base = Model("models/MarkJaw/drone_chair/chair_base.mdl"),
	Chair = Model("models/MarkJaw/drone_chair/chair.mdl"),
	}

ENT.Sounds = {
	Activate = Sound("tech/chair2.wav"),
	}

function ENT:SpawnFunction(pl, tr)
	if (!tr.HitWorld) then return end
	local e = ents.Create("control_chair")
	e:SetPos(tr.HitPos + Vector(0,0,10))
	local ang = pl:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = ang.y % 360 - 90;
	e:SetAngles(ang);
	e:Spawn()
	e:Activate()
	e:AddChair(pl)
	self.Owner=pl
	return e
end

function ENT:Initialize()

	self:SetModel(self.Models.Base)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self.ActiveTime=0
	--self:AddChair()
	self:CreateWireInputs("X","Y","Z","Start X","Start Y","Start Z","Entity [ENTITY]","Vector [VECTOR]");
	self:CreateWireOutputs("X","Y","Z","Vector [VECTOR]")

	--############ Drone vars
	self.Target = Vector(0,0,0);
	self.DroneMaxSpeed = (8000);
	self.AllowAutoTrack = (true);
	self.AllowEyeTrack = (false);
	self.TrackTime = 1000000;
	self.Drones = {};
	self.DroneCount = 0;

	--###### Energy Vars
	self:AddResource("energy",1)
	if(self.HasRD) then
		self.ShouldConsume=true
	else
		self.ShouldConsume=false
	end
	self.CanActivate=true
	self.NextUse=CurTime()

	self.FirePos = Vector(0,0,0)
	self.StartPos = self:GetPos()+self:GetForward()*-150

	self.LastSwitch=CurTime()

	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:SetMass(10000)
		phys:Wake()
	end
end

function ENT:OnRemove()

	if(self.Controlling) then
		self:DeactivateChair()
	end

	StarGate.WireRD.OnRemove(self);

	self:Remove()

end

function ENT:AddChair(p)

	local e = ents.Create("prop_physics")
	e:SetModel(self.Models.Chair)
	e:SetPos(self:GetPos()+self:GetUp()*15)
	e:SetAngles(self:GetAngles())
	e:Spawn()
	e:Activate()
	e:SetParent(self)
	--chair=e
	self.Chair = e
	self:SetNetworkedEntity("Chair",self.Chair)
	if CPPI and IsValid(p) and e.CPPISetOwner then e:CPPISetOwner(p) end

end

function ENT:Use(p)

	if(IsValid(self)and(not(self.Controlling))) then
		self:ActivateChair(p)
	end
end

function ENT:ActivateChair(p)

	if(self.ShouldConsume) then
		if(self:GetResource("energy"))>500 then
			self.CanActivate=true
		else
			self.CanActivate=false
		end
	end

	if(self.CanActivate) then
		if(self.NextUse<CurTime()) then
			p:Spectate(OBS_MODE_CHASE)
			p:DrawWorldModel(false)
			p:DrawViewModel(false)
			p:StripWeapons()
			-- Garry broke this function
			/*if(not(game.SinglePlayer())) then
				p:SetClientsideVehicle(self)
			end*/
			self.Pilot=p
--			self:SpawnRagdoll()
			--p:SetScriptedVehicle(self)
			p:SetNetworkedEntity("ScriptedVehicle", self)
			p:SetViewEntity(self)
			p:SetEyeAngles(self.Chair:GetAngles())
			p:SetNWBool("Control",true)
			p:SetNWEntity("chair",self.Chair)
			self:EmitSound(self.Sounds.Activate,100,100)
			self.Chair:SetSkin(1)
			self:ConsumeResource("energy",500)
			self.Controlling = true
			self:SetSkin(1)
			self.ActiveTime=0
			self.NextUse=CurTime()+1
			self.Nextthink=true
		end
	end
end

function ENT:DeactivateChair(p)

	self.Pilot:UnSpectate()
	self.Pilot:DrawWorldModel(true)
	self.Pilot:DrawViewModel(true)
	-- Garry broke this function
	/*if(not(game.SinglePlayer())) then
		self.Pilot:SetClientsideVehicle(NULL)
	end*/
	--self.Pilot:SetScriptedVehicle(NULL)
	self.Pilot:SetNetworkedEntity("ScriptedVehicle", NULL)
	self.Pilot:SetViewEntity(NULL)
	self.Pilot:Spawn()
	self.Pilot:SetParent()
	self.Pilot:SetPos(self:GetPos()+self:GetRight()*30+self:GetUp()*10)
	if (IsValid(self.Chair)) then
		self.Chair:SetSkin(0)
	end
	self.Pilot:SetParent()
	self.Pilot:SetNWBool("Control",false)
	self.Pilot:SetNWEntity("chair",NULL)
	self:SupplyResource("energy",500)
--	self.Ragdoll:Remove()
	self.Controlling=false
	self.NextUse=CurTime()+1
	self.Nextthink=false
	self.Enabled = false;
end

function ENT:StartTouch(hitEnt)


	if(IsValid(hitEnt)and(hitEnt:IsPlayer())) then
		if(self.ShouldConsume) then
			if(self:GetResource("energy")<200) then
				return
			end
		end

		self:SetSkin(1)
		self.ChairActive=true
		self.Touching=true
	end
end

function ENT:EndTouch()	self.Touching = false end

function ENT:Think()
	if (IsValid(self.Pilot)) then
		umsg.Start("ControlChair",self.Pilot)
			umsg.Bool(self.Controlling)
			umsg.Bool(self.Enabled)
			umsg.Short(self.DroneCount)
			umsg.Entity(self.Chair)
		umsg.End()
	end

	if(self.Controlling) then
		if(self.Enabled) then
			self.Chair:SetAngles(Angle(self:GetAngles().Pitch,self.Pilot:GetAimVector():Angle().Yaw,self:GetAngles().Roll))
		end
	end

	if(self.Controlling and IsValid(self.Pilot)) then
		if(self.Pilot:KeyDown(IN_FORWARD)) then
			if(self.Enabled) then
				self:Anims("open")
			end
		elseif(self.Pilot:KeyDown(IN_BACK)) then
			if(not(self.Enabled)) then
				self:Anims("close")
			end
		end
	end

	if(self.ShouldConsume) then
		if(self:GetResource("energy")<500) then
			if(self.Controlling) then
				self:Anims("open")
				self:DeactivateChair(self.Pilot)
				self:SetSkin(0)
			end
		end
	end

	if(self.ChairActive) then
		if(not(self.Controlling)) then
			self.ActiveTime=math.Approach(self.ActiveTime,250,10)
		end
	end

	if(self.Controlling) then
		self:ConsumeResource("energy",25)
		if(self:GetSkin()< 1) then
			self:SetSkin(1)
		end
	end

	if(self.Controlling and IsValid(self.Pilot)) then
		if(self.Pilot:KeyDown(IN_USE)) then
			if(self.NextUse<CurTime()) then
				if self.Enabled then
					self:Anims("open")
				end
				self:DeactivateChair(self.Pilot)
			end
		end
	end

	if(self.ActiveTime) >= 250 then
		if((not(self.Touching))and(not(self.Controlling))) then
			if(not(self.Controlling)) then
				self:SetSkin(0)
				self.ChairActive=false
				self.ActiveTime=0
			end
		end
	end

	if(IsValid(self.Pilot)) then
		if(self.Controlling) then
			if(self.Pilot:KeyDown(IN_ATTACK)) then
				self:FireDrones()
				self:ConsumeResource("energy",20)
			end

			if(self.Pilot:KeyDown(IN_ATTACK2)) then
				self.Track = true
			else
				self.Track = false
			end
		end
	end
	self.FirePos = Vector(self.StartPos.X,self.StartPos.Y,self.StartPos.Z)
	if(self.Nextthink) then
		self:NextThink(CurTime())
		return true
	end
	self:SetWire("X",self.Target.x)
	self:SetWire("Y",self.Target.y)
	self:SetWire("Z",self.Target.z)
	self:SetWire("Vector",self.Target)
end


function ENT:FireDrones() --######### Fire aVoN's type of drones @RononDex

	if(self.DroneCount<10) then
		local vel = self:GetVelocity()
		--calculate the drone's position offset. Otherwise it might collide with the launcher
		local e = ents.Create("drone")
		e.Parent = self
		e:SetPos(self.FirePos)
		e:SetAngles(Angle(-90,0,0))
		e:SetOwner(self) -- Don't collide with this thing here please
		e.Owner = self.Owner
		e:Spawn()
		e:SetVelocity(vel)
		self.DroneCount = self.DroneCount + 1
		self.Drones[e] = true
		self.Drone=e
	end
end

function ENT:ShowOutput() --###### Dummy function for drones
end

function ENT:TriggerInput(k,v) --#########Add the wire inputs @ RononDex

	if(not self.EyeTrack and k == "X") then
		self.PositionSet = true;
		self.Target.x = v;
	elseif(not self.EyeTrack and k == "Y") then
		self.PositionSet = true;
		self.Target.y = v;
	elseif(not self.EyeTrack and k == "Z") then
		self.PositionSet = true;
		self.Target.z = v;
	end

	if(k=="Vector [VECTOR]") then
		self.Target=v
	end

	if(k=="Start X") then
		self.StartPos.X = v
	elseif(k=="Start Y") then
		self.StartPos.Y = v
	elseif(k=="Start Z") then
		self.StartPos.Z = v
	end
end

function ENT:Anims(anim)

	if(IsValid(self) and IsValid(self.Chair)) then
		self.Anim = self.Chair:LookupSequence(anim)
		self:SetPlaybackRate(0.005)
		self.Chair:ResetSequence(self.Anim)
		if(anim=="close") then
			self.Enabled=true
		elseif(anim=="open") then
			self.Enabled=false
		end
	end
end


--[[
--####### Spawn the ragdoll @RononDex
function ENT:SpawnRagdoll()

	if(IsValid(self)) then
		if(IsValid(self.Pilot)) then
			local e = ents.Create("prop_ragdoll")
			e:SetModel(self.Pilot:GetModel())
			e:SetPos(self.Chair:GetPos())
			e:SetAngles(self.Chair:GetAngles()+Angle(0,-90,0))
			e:Spawn()
			e:Activate()
			e:SetParent(self)
			e:GetPhysicsObject():EnableMotion(false)
			constraint.Weld(e,self.Chair,0,0,0,true)
			self.Ragdoll=e
			self:RagdollPose()
		end
	end
end

--############## This is what puts the ragdoll into the right pose @RononDex
function ENT:RagdollPose()

	local chest = self.Ragdoll:GetPhysicsObjectNum(1)
	chest:EnableMotion(false)
	chest:SetPos(self.Chair:GetPos()+self.Chair:GetUp()*160)
	--chest:SetAngles(self:GetAngles()+Angle(0,-45,0))

	local pelvis = self.Ragdoll:GetPhysicsObjectNum(0)
	pelvis:EnableMotion(false)
	pelvis:SetPos(self.Chair:GetPos())

	local lthigh = self.Ragdoll:GetPhysicsObjectNum(11)
	lthigh:EnableMotion(false)
	lthigh:SetPos(self.Chair:GetPos()+self:GetRight()*-10+self:GetUp()*25)

	local lfoot = self.Ragdoll:GetPhysicsObjectNum(13)
	lfoot:EnableMotion(false)
	lfoot:SetPos(self.Chair:GetPos()+self.Chair:GetForward()*25+self.Chair:GetRight()*-10)

	local rfoot = self.Ragdoll:GetPhysicsObjectNum(14)
	rfoot:EnableMotion(false)
	rfoot:SetPos(self.Chair:GetPos()+self.Chair:GetForward()*25+self.Chair:GetRight()*10)

end

function ENT:LookupBones()

	local bones = self.Ragdoll:LookupBone("ValveBiped.Bip01_L_Foot")

	print(bones)

end
]]--

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	self:AddChair(ply)
	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "control_chair", StarGate.CAP_GmodDuplicator, "Data" )
end

end