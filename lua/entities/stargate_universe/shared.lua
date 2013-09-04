ENT.Type = "anim"
ENT.Base = "stargate_base"
ENT.PrintName = "Stargate (Universe)"
ENT.Author = "Madman07, Llapp, Boba Fett, TheSniper9, AlexALX"
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"

list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.WireDebugName = "Stargate Universe"

properties.Add( "Stargate.Uni.SymLight.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_10"),
	Order		=	-200,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_universe" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActSymsL",false)) then return false end
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

						ent:TriggerInput("Activate Symbols",1);
					end

});

properties.Add( "Stargate.Uni.SymLight.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_10d"),
	Order		=	-200,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_universe" || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActSymsL",false)) then return false end
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

						ent:TriggerInput("Activate Symbols",0);
					end

});

properties.Add( "Stargate.Uni.SymInc.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_12"),
	Order		=	-199,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_universe" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWInt("ActSymsI",0)!=0) then return false end
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

						ent:TriggerInput("Inbound Symbols",1);
					end

});

properties.Add( "Stargate.Uni.SymInc.On2",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_12b"),
	Order		=	-199,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_universe" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWInt("ActSymsI",0)!=1) then return false end
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

						ent:TriggerInput("Inbound Symbols",2);
					end

});

properties.Add( "Stargate.Uni.SymInc.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_12d"),
	Order		=	-199,
	MenuIcon	=	"icon16/plugin_link.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_universe" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWInt("ActSymsI",0)!=2) then return false end
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

						ent:TriggerInput("Inbound Symbols",0);
					end

});