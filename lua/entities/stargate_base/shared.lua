/*
	Stargate SENT for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end -- When you need to add LifeSupport and Wire capabilities, you NEED TO CALL this before anything else or it wont work!
--################# HEADER #################
ENT.Type = "anim";
ENT.Author = "aVoN, AlexALX";
ENT.PrintName = "stargate_base_entity";
ENT.Category = "Stargate Carter Addon Pack: Gates and Rings";

ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.WireDebugName = "Stargate";
ENT.IsStargate = true;
ENT.IsGroupStargate = true;

ENT.EventHorizonData = {
	OpeningDelay = 0.9,
	OpenTime = 2.2,
	Type = "sg1",
	Kawoosh = "sg1",
	NNFix = 0,
}

StarGate.RegisterEventHorizon("sg1",{
	ID=1,
	Name=SGLanguage.GetMessage("stargate_c_tool_21_sg1"),
	Material="",
	UnstableMaterial="sgorlin/effect_shock.vmt",
	LightColor={
		r = Vector(20,40),
		g = Vector(60,80),
		b = Vector(150,230),
		sync = false, -- sync random (for white), will be used only first value from this table (r)
	},
	Color=Color(255,255,255),
})

ENT.DialSlowDelay = 1.0
ENT.DialFastTime = 7.0

--################# SENT CODE ###############
--################# Defines
-- Stores the chevron positions for the dyn-lights
ENT.chev_pos = {
	Vector(2.1883,56.8480,117.1900), -- Chevron 1
	Vector(2.1906,84.8159,68.0387), -- 2
	Vector(2.1935,74.0602,7.2254), -- 3
	Vector(2.1952,-75.2123,8.8901), -- 4
	Vector(2.1949,-85.7819,66.1261), -- 5
	Vector(2.1921,-56.6188,118.2584), -- 6
	Vector(2.1837,-0.3143,138.8647), -- 7 (normal travel)
	Vector(2.1905,27.5605,-30.0398), -- 8 (intergalactic travel - later for server-to-server travel)
	Vector(2.1964,-32.0372,-28.7796), -- 9 The chevron 9, nobody knows, for what reason it is good for. Alternative universes?
}

ENT.GalaxyConsumption = 4;
ENT.GalaxyAdd = 50000;
ENT.SGUConsumption = 40;
ENT.SGUAdd = 800000;
ENT.ChevConsumption = 10;
ENT.ChevAdd = 2000;

properties.Add( "Stargate.AutoClose.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_03d"),
	Order		=	-109,
	MenuIcon	=	"icon16/plugin_delete.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent.IsStargateOrlin || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("DisAutoClose",false)) then return false end
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

						ent.DisAutoClose = true
						ent:SetNWBool("DisAutoClose",true);
					end

});

properties.Add( "Stargate.AutoClose.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_03"),
	Order		=	-109,
	MenuIcon	=	"icon16/plugin_add.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent.IsStargateOrlin || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("DisAutoClose",false)) then return false end
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

						ent.DisAutoClose = false
						ent:SetNWBool("DisAutoClose",false);
					end

});

properties.Add( "Stargate.DisableMenu.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_07d"),
	Order		=	-108,
	MenuIcon	=	"icon16/plugin_delete.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate and !ent.IsDHD || ent.IsStargateOrlin || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("DisMenu",false)) then return false end
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

						ent.DisMenu = true
						ent:SetNWBool("DisMenu",true);
					end

});

properties.Add( "Stargate.DisableMenu.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_07"),
	Order		=	-108,
	MenuIcon	=	"icon16/plugin_add.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate and !ent.IsDHD || ent.IsStargateOrlin || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("DisMenu",false)) then return false end
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

						ent.DisMenu = false
						ent:SetNWBool("DisMenu",false);
					end

});

properties.Add( "Stargate.ChevronLight.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_09"),
	Order		=	-111,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent.IsStargateOrlin || ent.IsSupergate || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActChevronsL",false)) then return false end
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

						if (ent:GetClass()=="stargate_universe") then
 							ent:TriggerInput("Activate Chevrons",1);
						else
							ent:TriggerInput("Activate chevron numbers","111111111");
						end
					end

});

properties.Add( "Stargate.ChevronLight.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_09d"),
	Order		=	-111,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent.IsStargateOrlin || ent.IsSupergate || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActChevronsL",false)) then return false end
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

						if (ent:GetClass()=="stargate_universe") then
 							ent:TriggerInput("Activate Chevrons",0);
						else
							ent:TriggerInput("Activate chevron numbers","");
						end
					end

});

properties.Add( "Stargate.RingRotate.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_11"),
	Order		=	-110,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !ent.StargateRingRotate || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActRotRingL",false)) then return false end
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

						ent:TriggerInput("Rotate Ring",1);
					end

});

properties.Add( "Stargate.RingRotate.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_11d"),
	Order		=	-110,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !ent.StargateRingRotate || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActRotRingL",false)) then return false end
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

						ent:TriggerInput("Rotate Ring",0);
					end

});

properties.Add( "Stargate.EHType",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_21"),
	Order		=	-107,
	MenuIcon	=	"icon16/images.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent.StargateNoEHSelect || ent:GetNWBool("GateSpawnerProtected",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
						return true

					end,

	MenuOpen = function( self, option, ent, tr )
		local submenu = option:AddSubMenu()
		local eh = ent:GetNWString("EventHorizonType","sg1");
		local types = {} -- fixed order
		for k,v in pairs(StarGate.EventHorizonTypes) do
			types[v.ID] = {k,v.Name}
		end
		
		for k,eht in pairs(types) do
			local option = submenu:AddOption(eht[2], function() self:SetEh( ent, eht[1] ) end )
			if ( eh == eht[1] ) then
				option:SetChecked( true )
			end
		end
	end,

	SetEh		=	function( self, ent, eht )

						self:MsgStart()
							net.WriteEntity(ent)
							net.WriteString(eht)
						self:MsgEnd()

					end,

	Action 		= 	function() end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:TriggerInput("Event Horizon Type",net.ReadString())
					end

});

properties.Add( "Stargate.EHColor",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_23"),
	Order		=	-106,
	MenuIcon	=	"icon16/color_wheel.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || ent:GetNWBool("GateSpawnerProtected",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "stargatemodify", ent ) ) then return false end
						return true

					end,

	Action 		= 	function(self, ent) 
		StarGate.ColorMenu(self,ent)
	end,
	
	SetCol		=	function( self, ent, color)
					if not IsValid(ent) then return end
						self:MsgStart()
							net.WriteEntity(ent)
							net.WriteVector(Vector(color.r,color.g,color.b))
						self:MsgEnd()

					end,
					
	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						local col = net.ReadVector();
						ent:TriggerInput("Event Horizon Color",col)
					end

});

properties.Add( "Stargate.SGCType.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_13"),
	Order		=	-150,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !ent.StargateHasSGCType || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("ActSGCT",false)) then return false end
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
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !ent.StargateHasSGCType || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("ActSGCT",false)) then return false end
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
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !ent.StargateTwoPoO || ent:GetNWBool("GateSpawnerProtected",false)) then return false end
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


properties.Add( "Stargate.Chev9Spec.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_24"),
	Order		=	-130,
	MenuIcon	=	"icon16/plugin_disabled.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !ent.StargateHas9ChevSpecial || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("Chev9Special",false)) then return false end
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

						ent:TriggerInput("9 Chevron Mode",1);
					end

});

properties.Add( "Stargate.Chev9Spec.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_24d"),
	Order		=	-130,
	MenuIcon	=	"icon16/plugin.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsStargate || !ent.StargateHas9ChevSpecial || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("Chev9Special",false)) then return false end
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

						ent:TriggerInput("9 Chevron Mode",0);
					end

});

if CLIENT then

function StarGate.ColorMenu(prop,ent)
	local Frame = vgui.Create( "DFrame" )
	Frame:SetSize( 330, 300 )
	Frame:Center()
	Frame:MakePopup()
	Frame:SetTitle("")
   	Frame:SetVisible( true )
   	Frame:SetDraggable( false )
   	Frame:ShowCloseButton( true )
	Frame.Paint = function(self,w,h)
        surface.SetDrawColor( 80, 80, 80, 185 )
        surface.DrawRect( 0, 0, w, h )
    end

  	local title = vgui.Create( "DLabel", Frame );
 	title:SetText(SGLanguage.GetMessage("stargate_c_tool_23"));
  	title:SetPos( 25, 0 );
 	title:SetSize( 310, 25 );
	
	local image = vgui.Create("DImage" , Frame);
    image:SetSize(16, 16);
    image:SetPos(5, 5);
    image:SetImage("gui/cap_logo");
	
	local Mixer = vgui.Create( "DColorMixer", Frame )
	Mixer:SetAlphaBar( false ) 	
	Mixer:SetPos( 10, 30 )
	Mixer:SetSize( 310, 235 )
	local col = ent:GetNWVector("EHColor",Vector(255,255,255))
	Mixer:SetColor(Color(col.x,col.y,col.z))
	
	local Save = vgui.Create( "DButton", Frame )
	Save:SetPos( 220, 270 )
	Save:SetSize( 100, 25 )
	Save:SetImage("icon16/disk.png")
	Save:SetText(SGLanguage.GetMessage("stargate_c_tool_23a"))
	Save.DoClick = function(self, val)
		prop:SetCol(ent,Mixer:GetColor())
		Frame:Close()
	end
	
	local Reset = vgui.Create( "DButton", Frame )
	Reset:SetPos( 90, 270 )
	Reset:SetSize( 100, 25 )
	Reset:SetImage("icon16/arrow_refresh.png")
	Reset:SetText(SGLanguage.GetMessage("stargate_c_tool_23r"))
	Reset:CenterHorizontal()
	Reset.DoClick = function(self, val)
		prop:SetCol(ent,Color(0,0,0))
		Frame:Close()
	end
	
	local Cancel = vgui.Create( "DButton", Frame )
	Cancel:SetPos( 10, 270 )
	Cancel:SetSize( 100, 25 )
	Cancel:SetImage("icon16/database_delete.png")
	Cancel:SetText(SGLanguage.GetMessage("stargate_c_tool_23c"))
	Cancel.DoClick = function(self, val)
		Frame:Close()
	end
end

end