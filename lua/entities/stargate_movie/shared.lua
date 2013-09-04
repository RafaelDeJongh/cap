ENT.Type = "anim"
ENT.Base = "stargate_base"
ENT.PrintName = "Stargate (Movie)"
ENT.Author = "aVoN, Madman07, Llapp, Boba Fett, AlexALX"
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"

list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.WireDebugName = "Stargate Movie"

properties.Add( "Stargate.MChevL.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_16"),
	Order		=	-145,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_movie" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActMChevL",false)) then return false end
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

						ent:TriggerInput("Chevron Light",1);
					end

});

properties.Add( "Stargate.MChevL.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_16d"),
	Order		=	-145,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_movie" || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActMChevL",false)) then return false end
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

						ent:TriggerInput("Chevron Light",0);
					end

});

properties.Add( "Stargate.MCl.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_15"),
	Order		=	-144,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_movie" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActMCl",false)) then return false end
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

						ent:TriggerInput("Classic Mode",1);
					end

});

properties.Add( "Stargate.MCl.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_15d"),
	Order		=	-144,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
                        local vg = {"stargate_movie","stargate_sg1","stargate_infinity"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_movie" || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActMCl",false)) then return false end
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

						ent:TriggerInput("Classic Mode",0);
					end

});