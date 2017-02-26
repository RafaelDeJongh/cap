ENT.Type = "anim"
ENT.Base = "stargate_base"
ENT.PrintName = "Stargate (SG1)"
ENT.Author = "aVoN, Madman07, Llapp, Rafael De Jongh, AlexALX"
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings"

ENT.WireDebugName = "Stargate SG1"
list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.IsNewSlowDial = true; // this gate use new slow dial (with chevron lock on symbol)

ENT.EventHorizonData = {
	OpeningDelay = 1.5,
	OpenTime = 2.2,
	NNFix = 1,
}

ENT.DialSlowDelay = 2.0

function ENT:GetRingAng()
	if not IsValid(self.EntRing) then self.EntRing=self:GetNWEntity("EntRing") if not IsValid(self.EntRing) then return end end   -- Use this trick beacause NWVars hooks not works yet...
	local angle = tonumber(math.NormalizeAngle(self.EntRing:GetLocalAngles().r));
	return (angle<0) and angle+360 or angle
end

properties.Add( "Stargate.SGCType.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_13"),
	Order		=	-150,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						local vg = {"stargate_movie","stargate_sg1","stargate_infinity"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActSGCT",false)) then return false end
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

						ent:TriggerInput("SGC Type",0);
					end

});

properties.Add( "Stargate.PoO",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_14"),
	Order		=	-170,
	MenuIcon	=	"icon16/plugin_link.png",

	Filter		=	function( self, ent, ply )
						local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_tollan"}
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !table.HasValue(vg,ent:GetClass()) || ent:GetNWBool("GateSpawnerProtected",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
						return true

					end,

	MenuOpen = function( self, option, ent, tr )
		local submenu = option:AddSubMenu()
		local poo = ent:GetNWInt("Point_of_Origin",0);
		for i=0,2 do
			local option = submenu:AddOption( SGLanguage.GetMessage("stargate_c_tool_14_"..i+1), function() self:SetPoo( ent, i ) end )
			if ( poo == i ) then
				option:SetChecked( true )
			end
		end
	end,

	SetPoo		=	function( self, ent, i )

						self:MsgStart()
							net.WriteEntity( ent )
							net.WriteInt(i,8)
						self:MsgEnd()

					end,

	Action 		= 	function() end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:TriggerInput("Set Point of Origin",net.ReadInt(8));
					end

});