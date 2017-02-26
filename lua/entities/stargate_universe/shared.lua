ENT.Type = "anim"
ENT.Base = "stargate_base"
ENT.PrintName = "Stargate (Universe)"
ENT.Author = "Madman07, Llapp, Rafael De Jongh, TheSniper9, AlexALX"
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"

list.Set("CAP.Entity", ENT.PrintName, ENT);
ENT.WireDebugName = "Stargate Universe"

ENT.IsNewSlowDial = true; // this gate use new slow dial (with chevron lock on symbol)
ENT.IsUniverseGate = true;

ENT.EventHorizonData = {
	OpeningDelay = 0.8,
	OpenTime = 2.2,
	Type = "universe",
	NNFix = 0,
}
       
StarGate.RegisterEventHorizon("universe",{
	ID=3,
	Name=SGLanguage.GetMessage("stargate_c_tool_21_universe"),
	Material="sgu/effect_02.vmt",
	UnstableMaterial="sgu/effect_shock.vmt",
	LightColor={
		r = Vector(200,230),
		sync = true, -- sync random (for white), will be used only first value from this table (r)
	},
	Color=Color(255,255,255),
})
		
ENT.DialSlowDelay = 1.0
ENT.DialFastTime = 7.4

function ENT:GetRingAng()
	if not IsValid(self.EntRing) then self.EntRing=self:GetNWEntity("EntRing") if not IsValid(self.EntRing) then return end end   -- Use this trick beacause NWVars hooks not works yet...
	local angle = tonumber(math.NormalizeAngle(self.EntRing:GetLocalAngles().r));
	return (angle<0) and angle+360 or angle
end

properties.Add( "Stargate.Uni.SymLight.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_10"),
	Order		=	-200,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_universe" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActSymsAL",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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

						ent:TriggerInput("Activate All Symbols",1);
					end

});

properties.Add( "Stargate.Uni.SymLight.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_10d"),
	Order		=	-200,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_universe" || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActSymsAL",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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

						ent:TriggerInput("Activate All Symbols",0);
					end

});

properties.Add( "Stargate.Uni.SymInc.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_12"),
	Order		=	-199,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetClass()!="stargate_universe" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWInt("ActSymsI",0)!=0) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
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