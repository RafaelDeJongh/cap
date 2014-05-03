
TOOL.AddToMenu		= false
TOOL.ClientConVar[ "type" ]	= "0"
TOOL.ClientConVar[ "name" ]	= "0"
TOOL.ClientConVar[ "arg" ]	= "0"

if ( CLIENT ) then

	language.Add( "tool.cap_creator.name", language.GetPhrase("tool.creator.name") )
	language.Add( "tool.cap_creator.desc", language.GetPhrase("tool.creator.desc") )
	language.Add( "tool.cap_creator.0", language.GetPhrase("tool.creator.0") )

end

function TOOL:LeftClick( trace, attach )

	local type	= self:GetClientNumber(	"type",	0 )
	local name	= self:GetClientInfo( "name",	0 )
	local arg	= self:GetClientInfo( "arg",	0 )

	--
	-- type 0 = sent
	--
	if ( SERVER && type == 0 ) then
		CAP_Spawn_SENT( self:GetOwner(), name, trace )
	end

	--
	-- type 1 = vehicle
	--
	if ( SERVER && type == 1 ) then
		Spawn_Vehicle( self:GetOwner(), name, trace )
	end

	--
	-- type 2 = npc
	--
	if ( SERVER && type == 2 ) then
		CAP_Spawn_NPC( self:GetOwner(), name, arg, trace )
	end

	--
	-- type 3 = weapons
	--
	if ( SERVER && type == 3 ) then
		CAP_Spawn_Weapon( self:GetOwner(), name, trace )
	end

	return true;

end

