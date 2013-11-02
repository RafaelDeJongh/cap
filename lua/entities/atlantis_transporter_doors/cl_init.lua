include("shared.lua")

function ENT:Initialize()
	--self:SetRenderClipPlaneEnabled(true)
end

function ENT:Draw()
	/* old code
	local ent=self.Entity
	local normal = ent:GetRight()*50
	local distance = normal:Dot(ent:GetPos()-normal)

	local normal2 = ent:GetRight()*50*(-1)
	local distance2 = normal2:Dot(ent:GetPos()-normal2)

	--render.EnableClipping( true )
	render.PushCustomClipPlane( normal, distance );
	render.PushCustomClipPlane( normal2, distance2 );
	self:DrawModel()
	render.PopCustomClipPlane();
	--render.EnableClipping( false )  */

	if (self.ClipEnabled) then
		local norm = self:GetForward()*(-50);
		self:SetRenderClipPlane(norm, norm:Dot(self:GetPos()-norm));
	end
	self:DrawModel()
end

usermessage.Hook("StarGate.AtlantisTP.ClipStart", function(um)
	local e = um:ReadEntity();
	if (not IsValid(e)) then return end
	local norm = e:GetForward()*(-50);
	e.ClipEnabled = true;
	e:SetRenderClipPlaneEnabled(true);
	e:SetRenderClipPlane(norm, norm:Dot(e:GetPos()-norm));
end)

usermessage.Hook( "StarGate.AtlantisTP.ClipStop", function(um)
	local e = um:ReadEntity();
	if (not IsValid(e)) then return end
	e.ClipEnabled = nil;
	e:SetRenderClipPlaneEnabled(false);
end)