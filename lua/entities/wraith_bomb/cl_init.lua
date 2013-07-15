include("shared.lua");

function ENT:Draw() self:DrawModel() end;

--Calculate the player's view when they are stunned.
local function CalcView( ply, pos, angles, fov )
	if ply.Stunned then
		local Ragdoll = ply:GetNetworkedEntity( "StunRagdoll" )
		if IsValid( Ragdoll ) then
			local EyesID = Ragdoll:LookupAttachment( "eyes" )
			local Eyes = Ragdoll:GetAttachment( EyesID )

			return {
				origin = Eyes.Pos,
				angles = Eyes.Ang,
				fov = fov
			}
		else
			return {
				orgin = pos,
				angles = angles,
				fov = fov
			}
		end
	end
end
hook.Add( "CalcView", "WraithStun", CalcView )