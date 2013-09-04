include("shared.lua")
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