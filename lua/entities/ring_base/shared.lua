StarGate.LifeSupportAndWire(ENT); -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
ENT.Type 			= "anim"

ENT.PrintName	= "Ringtransporter"
ENT.Author	= "Catdaemon"
ENT.Contact	= ""
ENT.Purpose	= ""
ENT.Instructions= "Place where desired, USE to set its address."

ENT.Category		= "Stargate"

ENT.Spawnable	= false
ENT.AdminSpawnable = false

ENT.IsRings = true;

properties.Add( "Stargate.Ring.Unusable.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_04"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin_delete.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsRings || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("Busy",false)) then return false end
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

						ent.Busy = true
						ent:SetNWBool("Busy",true);
					end

});

properties.Add( "Stargate.Unusable.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_04d"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin_add.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsRings || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("Busy",false)) then return false end
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

						ent.Busy = false
						ent:SetNWBool("Busy",false);
					end

});

properties.Add( "Stargate.Ring.DialClosest",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_05"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin_go.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsRings || ent:GetNWBool("Busy",false)) then return false end
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

						ent:Dial("");
					end

});

properties.Add( "Stargate.Ring.DialMenu",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_06"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsRings || ent:GetNWBool("Busy",false)) then return false end
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

						umsg.Start("RingTransporterShowWindowCap", player)
						umsg.End()
						player.RingDialEnt = ent;
					end

});