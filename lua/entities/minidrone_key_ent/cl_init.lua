include("shared.lua")

local default = Material("madman07/minidrone_platform/key");
local noglow = Material("madman07/minidrone_platform/key"):GetTexture("$basetexture");

function ENT:Initialize() //shutdown old effect if needed
	default:SetTexture( "$basetexture", noglow);
	default:SetInt( "$selfillum", 0);
end

function ENT:Draw()
	local mat = Matrix()
	mat:Scale(Vector(2,2,2))
	self.Entity:EnableMatrix( "RenderMultiply", mat )
	self.Entity:DrawModel();
end