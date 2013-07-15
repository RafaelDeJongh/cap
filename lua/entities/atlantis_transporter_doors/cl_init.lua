include("shared.lua")

function ENT:Initialize()
	self:SetRenderClipPlaneEnabled(true)
end

function ENT:Draw()
	local ent=self.Entity
	local normal = ent:GetRight()*50
	local distance = normal:Dot(ent:GetPos()-normal)

	local normal2 = ent:GetRight()*50*(-1)
	local distance2 = normal2:Dot(ent:GetPos()-normal2)

	-- no needed anymore? fix for eh
	--render.EnableClipping( true )
	render.PushCustomClipPlane( normal, distance );
	render.PushCustomClipPlane( normal2, distance2 );
	self:DrawModel()
	render.PopCustomClipPlane();
	--render.EnableClipping( false )
end