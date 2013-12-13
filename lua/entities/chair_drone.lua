ENT.Type = "vehicle"
ENT.Base = "base_anim"

ENT.PrintName = "Flyable Drone"
ENT.Author = "RononDex"

ENT.Spawnable = false

if CLIENT then

function ENT:Initialize()
	--self:SetShouldDrawInViewMode(true)
end

               /*
function ChDroneCalcView(Player, Origin, Angles, FieldOfView)
	local view = {};
	local p = LocalPlayer()
	local self = p:GetNetworkedEntity("Drone",p)

	if(IsValid(self)) then
		local pos = shut:GetPos()+shut:GetUp()*100+Player:GetAimVector():GetNormal()*-250;
		local face = ( ( self.Entity:GetPos() + Vector( 0, 0, 100 ) ) - pos ):Angle();
			view.origin = pos;
			view.angles = face;
		return view;
	end
end
hook.Add("CalcView", "ChDroneCalcView", ChDroneCalcView)*/
-- code seems to be broken

end

if SERVER then

if (1==1) then return end -- this ent is disabled, because it isn't used anywhere

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("ship")) then return end

AddCSLuaFile()

function ENT:SpawnFunction(pl, tr)
	if (!tr.HitWorld) then return end
	local e = ents.Create("chair_drone")
	e:Spawn()
	e:Activate()
	return e
end

function ENT:Initialize()

	self:SetModel("models/Zup/Drone/drone.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSkin(1)
	self:SetNetworkedEntity("Drone",self)
	self.DroneCount=0

end

function ENT:PhysicsSimulate( phys, deltatime )--############## Flight code@ RononDex, aVoN

	local FWD = self:GetForward()

	if(IsValid(self.Drone)) then
		if(self.FlyIt) then

			self.Parent.Pilot:Spectate(OBS_MODE_FIXED)

			self.Accel.FWD=math.Approach(self.Accel.FWD,2250,9)

			phys:Wake()
			if(not(self.Hover)) then
				if self.Accel.FWD>-200 and self.Accel.FWD < 200 then return end
			end

		self.DronePhys={
			secondstoarrive	= 1;
			pos = self:GetPos()+(FWD*self.Accel.FWD);
			maxangular		= 9000;
			maxangulardamp	= 1000;
			maxspeed			= 1000000;
			maxspeeddamp		= 500000;
			dampfactor		= 1;
			teleportdistance	= 5000;
			}
			local ang = self.Pilot:GetAimVector():Angle()
			local pos = self:GetPos()

			self.DronePhys.angle			= ang --+ Vector(90 0, 0)
			self.DronePhys.deltatime		= deltatime

			self.Pilot:SetPos(pos);

			phys:ComputeShadowControl(self.DronePhys)
		end
	end
end

function ENT:Touch()

	if(IsValid(self)) then
		self:Explode()
		self.FlyIt=false
	end
end

function ENT:Explode()

	local fx = EffectData()
		fx:SetOrigin(self:GetPos())
	util.Effect("Explosion",fx)

	self:Remove()
	self:SetNWEntity("Drone",NULL)
	self.DroneCount = 0
end

end