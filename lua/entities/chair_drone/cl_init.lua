include("shared.lua")

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