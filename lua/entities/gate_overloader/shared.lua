-- Use the Stargate addon to add LS, RD and Wire support to this entity
if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type             = "anim"
ENT.Base             = "base_anim"

ENT.PrintName        = "Gate Overloader"
ENT.WireDebugName    = "Gate Overloader"
ENT.Author           = "PyroSpirit, Madman07"
ENT.Contact		      = "forums.facepunchstudios.com"
ENT.Category 		 = "Stargate Carter Addon Pack: Weapons"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.AutomaticFrameAdvance = true

ENT.energyPerSecond       = 2500
ENT.energyPerCycle        = 500
ENT.coolingPerCycle       = 300

-- Get the position of the beam emitter on the overloader
function ENT:GetEmitterPos()
	local emitter = self.Entity:GetAttachment(self.Entity:LookupAttachment("emitter0"));
	if emitter and emitter.Pos then
		return emitter.Pos
	else
		return self.Entity:GetPos() + self.Entity:GetForward()*100
	end
end

function ENT:GetSubBeamPos(beam)
	local beams = {}
	local attachmentIDs =
	{
		self.Entity:LookupAttachment("emitter1"),
		self.Entity:LookupAttachment("emitter2"),
		self.Entity:LookupAttachment("emitter3"),
		self.Entity:LookupAttachment("emitter4"),
		self.Entity:LookupAttachment("emitter5"),
		self.Entity:LookupAttachment("emitter6")
	}

	local emitter = self.Entity:GetAttachment(attachmentIDs[beam])
	if emitter and emitter.Pos then
		return emitter.Pos
	else
		return self.Entity:GetPos() + self.Entity:GetForward()*10
	end
end

function ENT:IsActive()
   return self.Entity:GetNetworkedBool("isActive", self.isActive == true)
end

function ENT:IsFiring()
   return self.Entity:GetNetworkedBool("isFiring", self.isFiring == true)
end

function ENT:GetBeamColour()
	return "200 200 255"
end

function ENT:GetLocalGate()
   return self.Entity:GetNetworkedEntity("localGate", nil)
end

function ENT:GetRemoteGate()
   return self.Entity:GetNetworkedEntity("remoteGate", nil)
end
