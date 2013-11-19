ENT.Type = "anim";
ENT.Base = "stargate_base";
ENT.PrintName = "Stargate (Atlantis)";
ENT.Author = "aVoN, Madman07, Llapp, Boba Fett, AlexALX";
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"

list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.WireDebugName = "Stargate Atlantis"

properties.Add( "Stargate.Atl.RingLight.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_08"),
	Order		=	-120,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_atlantis" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActRingL",false)) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:TriggerInput("Turn on ring light",2);
					end

});

properties.Add( "Stargate.Atl.RingLight.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_08d"),
	Order		=	-120,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_atlantis" || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActRingL",false)) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:TriggerInput("Turn on ring light",0);
					end

});

properties.Add( "Stargate.Atl.AtlType.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_19"),
	Order		=	-125,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_atlantis" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("AtlType",false)) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:TriggerInput("Atlantis Type",1);
					end

});

properties.Add( "Stargate.Atl.AtlType.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_19d"),
	Order		=	-125,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_atlantis" || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("AtlType",false)) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:TriggerInput("Atlantis Type",0);
					end

});