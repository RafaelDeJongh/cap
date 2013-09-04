--[[
	Shield Core Buble
	Copyright (C) 2011 Madman07
]]--

include('shared.lua');
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("tokra_shield",SGLanguage.GetMessage("tshield_desc"));
end
include("box.lua")
include("bullets.lua");

StarGate.Trace:Add("tokra_shield",
	function(e,values,trace,in_box)
		return true;
	end
);

function ENT:Initialize()
	self.Created = false;
	self.RayModel = {};
	self.DrawMesh = false;
end

function ENT:Think()
	if (self:GetNetworkedBool("DoClientSide", false) and not self.Created) then
		self.Created = true
		self:DoCollision();
	end
end

function ENT:DoCollision()
	convex = {}
	local length = self.Entity:GetNWInt("Len", 300);

	for _, vertex in pairs(TokraBoxModel) do
		local vec = Vector(vertex.x*length,vertex.y,vertex.z);
		table.insert(convex, Vertex(vec, 1, 1, Vector( 0, 0, 1 )));
	end
	if (table.getn(convex) == 0) then return end //safefail

	self.Entity:PhysicsFromMesh(convex);
end
