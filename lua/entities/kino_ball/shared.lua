ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Kino"
ENT.WireDebugName = "Kino"
ENT.Author = "Madman07, Boba Fett"
ENT.Instructions= ""
ENT.Contact = "madman097@gmail.com"
ENT.Category = "Stargate Carter Addon Pack"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true


function ENT:SetOn( _in_ )
	self:SetNetworkedBool( "Enabled", _in_ )
end

function ENT:GetOn()
	return self:GetNetworkedVar( "Enabled", true )
end