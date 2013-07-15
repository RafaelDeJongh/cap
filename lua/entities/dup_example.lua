-----------------------------------DUPLICATOR----------------------------------
/*
function ENT:PreEntityCopy()
	local dupeInfo = {}

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end
		
	duplicator.StoreEntityModifier(self, "DupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "DupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	
	local dupeInfo = Ent.EntityMods.DupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.DupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.DupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	local PropLimit = GetConVar("_max"):GetInt();
	if(ply:GetCount("")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\" limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		self.Entity:OnRemove();
		return
	end

	local phys = self.Entity:GetPhysicsObject();
	if IsValid(phys) then phys:EnableGravity(false) end

	self.Owner = ply;
	ply:AddCount("", self.Entity)

end*/