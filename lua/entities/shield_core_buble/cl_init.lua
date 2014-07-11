--[[
	Shield Core Buble
	Copyright (C) 2011 Madman07
]]--

include('shared.lua');
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("shield_core_buble",SGLanguage.GetMessage("ship_core_buble"));
end

include("modules/sphere.lua")
include("modules/box.lua")
include("modules/atlantis.lua")
include("modules/bullets.lua");

if (StarGate==nil or StarGate.Trace==nil) then return end

StarGate.Trace:Add("shield_core_buble",
	function(e,values,trace,in_box)
		if(not e:GetNetworkedBool("depleted",false) and e:GetNWBool("Enabled",false)) then
			-- local own = e;
			-- if (type(values[3]) == "table") then
				-- own = values[3][1]:GetNWEntity("SC_Owner", e); // readed from serverside
			-- else
				-- own = values[3]:GetNWEntity("SC_Owner", e);
			-- end
			-- if not (IsValid(own) and own:IsPlayer()) then return true end

			-- local nocollide = string.Explode(" ", e:GetNWString("NoCollideID", ""));
			-- if (table.HasValue(nocollide, own:EntIndex()) or (e:GetNWBool("Immunity",false) and e:SetNetworkedEntity("Own",e) == own)) then
				-- return false
			-- else
				-- return true
			-- end

			return true // Fix it!
		else
			return false
		end
		return true
	end
);


StarGate.Trace:Add("shield_core_buble",
	function(e,values,trace,in_box)
		if(not e.Depleted and e.Enabled) then
			local own = e;
			if (type(values[3]) == "table") then
				own = StarGate.GetMultipleOwner(values[3][1]);
				values[3][1]:SetNWEntity("SC_Owner", own); // for clientside prediction
			else
				own = StarGate.GetMultipleOwner(values[3]);
				values[3]:SetNWEntity("SC_Owner", own);
			end
			if not (IsValid(own) and own:IsPlayer()) then return true end

			if (table.HasValue(e.nocollide, own) or (e.Parent.Immunity and e.Parent.Owner == own)) then
				return false
			else
				return true
			end
		else
			return false
		end
	end
);

function ENT:Initialize()
	self.Created = false;
	self.RayModel = {};
	self:SetCustomCollisionCheck(true);
end

function ENT:Think()
	if (self:GetNWBool("DoPhysicClientside", false) and not self.Created) then
		self.Created = true
		self:SetCollisionScale()
	end
end

function ENT:SetCollisionScale()
	local model = self:GetNWInt("PhysicModel", 1);
	local size = self:GetNWVector("PhysicScale", Vector(1,1,1));

	local vect, vec;
	local convex = {}
	local i = 0;
	local ShieldModel;

	if (model == 1) then ShieldModel = SphereModel;
	elseif (model == 2) then ShieldModel = BoxModel;
	elseif (model == 3) then ShieldModel = AtlantisModel; end

	for _, vertex in pairs(ShieldModel) do
		vec = Vector(vertex.x*size.x,vertex.y*size.y,vertex.z*size.z);
		vect = Vertex(vec, 1, 1, Vector( 0, 0, 1 ) )
		table.insert(convex, vect);
		table.insert(self.RayModel, vec);
	end

	if (table.getn(convex) == 0) then return end //safefail

	self.Entity:PhysicsFromMesh(convex);

	self.ShShap = model;
	self.Size = size;
end