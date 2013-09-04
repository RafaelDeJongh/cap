ENT.Type = "anim"
ENT.Base = "stargate_base"
ENT.PrintName = "Stargate (SG1)"
ENT.Author = "aVoN, Madman07, Llapp, Boba Fett, AlexALX"
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"

ENT.WireDebugName = "Stargate SG1"
list.Set("CAP.Entity", ENT.PrintName, ENT);

properties.Add( "Stargate.SGCType.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_13"),
	Order		=	-150,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						local vg = {"stargate_movie","stargate_sg1","stargate_infinity"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActSGCT",false)) then return false end
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

						ent:TriggerInput("SGC Type",1);
					end

});

properties.Add( "Stargate.SGCType.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_13d"),
	Order		=	-150,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
                        local vg = {"stargate_movie","stargate_sg1","stargate_infinity"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActSGCT",false)) then return false end
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

						ent:TriggerInput("SGC Type",0);
					end

});

properties.Add( "Stargate.PoO.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_14"),
	Order		=	-140,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_tollan"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWInt("Point_of_Origin",0)!=0) then return false end
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

						ent:TriggerInput("Set Point of Origin",1);
					end

});

properties.Add( "Stargate.PoO.On2",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_14b"),
	Order		=	-140,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
						local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_tollan"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWInt("Point_of_Origin",0)!=1) then return false end
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

						ent:TriggerInput("Set Point of Origin",2);
					end

});

properties.Add( "Stargate.PoO.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_14d"),
	Order		=	-140,
	MenuIcon	=	"icon16/plugin_link.png",

	Filter		=	function( self, ent, ply )
                        local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_tollan"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWInt("Point_of_Origin",0)!=2) then return false end
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

						ent:TriggerInput("Set Point of Origin",0);
					end

});