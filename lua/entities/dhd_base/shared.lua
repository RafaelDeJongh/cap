/*
	DHD SENT for GarrysMod10
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
ENT.Type = "anim";
ENT.PrintName = "DHD_base";
ENT.Author = "aVoN, RononDex, AlexALX";
ENT.Category = 	"Stargate Carter Addon Pack: Gates and Rings";
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.IsDHD = true;
ENT.IsGroupDHD = true;

-- The directionvectors, relativly from the EntPos to to the chevrons pos - The numbers and chars behind it will aquire a human readable adress like 1B3D5F-Chevron7 - Chevron7 will always be "Â", because the gmod10 servers are on earth :D
ENT.ChevronPositionsGroup = {
	-- Inner Ring
	[0] = Vector(-5.9916, -1.4400, 52.5765),
	[1] = Vector(-6.4918, -4.1860, 52.6422),
	[2] = Vector(-7.6213, -6.9628, 53.0274),
	[3] = Vector(-9.6784, -8.9852, 53.4759),
	[4] = Vector(-12.1340, -10.2172, 53.9685),
	[5] = Vector(-15.1579, -10.5651, 54.4846),
	[6] = Vector(-17.9682, -9.5000, 55.0545),
	[7] = Vector(-19.8674, -7.9478, 55.6510),
	[8] = Vector(-21.7267, -5.5587, 55.9205),
	[9] = Vector(-22.7824, -2.8374, 55.7549),
	A = Vector(-23.0255, -0.2087, 55.6288),
	B = Vector(-22.2049, 2.4517, 55.3056),
	C = Vector(-20.6056, 4.6577, 54.9203),
	D = Vector(-18.2240, 6.5121, 54.5925),
	E = Vector(-15.2521, 7.2384, 54.4391),
	F = Vector(-12.3034, 6.8182, 54.0971),
	G = Vector(-9.6883, 5.9373, 53.4027),
	H = Vector(-7.4578, 3.9120, 52.9060),
	I = Vector(-6.1105, 1.3894, 52.6246),
	-- Outer Ring
	J = Vector(-0.3310, -1.5342, 49.6508),
	K = Vector(-0.9333, -6.2703, 49.6297),
	L = Vector(-3.1289, -10.9383, 50.3840),
	M = Vector(-6.8106, -13.9513, 51.2794),
	N = Vector(-10.9387, -15.9653, 52.1221),
	O = Vector(-15.4151, -15.9868, 53.1347),
	["#"] = Vector(-20.3015, -15.0339, 53.8717),
	P = Vector(-24.1817, -11.9662, 54.8636),
	Q = Vector(-26.1737, -7.9137, 55.6503),
	R = Vector(-28.2183, -3.7876, 55.5180),
	S = Vector(-28.2080, 0.8877, 55.3551),
	T = Vector(-27.1768, 5.2839, 54.8367),
	U = Vector(-24.7437, 9.5472, 54.0941),
	V = Vector(-20.3043, 11.6017, 53.7054),
	W = Vector(-15.2821, 12.6006, 53.2243),
	X = Vector(-10.7024, 12.3530, 52.2391),
	Y = Vector(-6.5012, 10.6867, 51.2069),
	Z = Vector(-3.0627, 7.6676, 50.3809),
	["@"] = Vector(-0.8726, 3.1943, 49.9209),
	-- Engage
	DIAL = Vector(-15.0280, -1.5217, 55.1249), -- The middle "enter" button ;)
}

ENT.ChevronPositionsGalaxy = {
	-- Inner Ring
	["!"] = Vector(-5.9916, -1.4400, 52.5765),
	[1] = Vector(-6.4918, -4.1860, 52.6422),
	[2] = Vector(-7.6213, -6.9628, 53.0274),
	[3] = Vector(-9.6784, -8.9852, 53.4759),
	[4] = Vector(-12.1340, -10.2172, 53.9685),
	[5] = Vector(-15.1579, -10.5651, 54.4846),
	[6] = Vector(-17.9682, -9.5000, 55.0545),
	[7] = Vector(-19.8674, -7.9478, 55.6510),
	[8] = Vector(-21.7267, -5.5587, 55.9205),
	[9] = Vector(-22.7824, -2.8374, 55.7549),
	A = Vector(-23.0255, -0.2087, 55.6288),
	B = Vector(-22.2049, 2.4517, 55.3056),
	C = Vector(-20.6056, 4.6577, 54.9203),
	D = Vector(-18.2240, 6.5121, 54.5925),
	E = Vector(-15.2521, 7.2384, 54.4391),
	F = Vector(-12.3034, 6.8182, 54.0971),
	G = Vector(-9.6883, 5.9373, 53.4027),
	H = Vector(-7.4578, 3.9120, 52.9060),
	I = Vector(-6.1105, 1.3894, 52.6246),
	-- Outer Ring
	J = Vector(-0.3310, -1.5342, 49.6508),
	K = Vector(-0.9333, -6.2703, 49.6297),
	L = Vector(-3.1289, -10.9383, 50.3840),
	M = Vector(-6.8106, -13.9513, 51.2794),
	N = Vector(-10.9387, -15.9653, 52.1221),
	O = Vector(-15.4151, -15.9868, 53.1347),
	["#"] = Vector(-20.3015, -15.0339, 53.8717),
	P = Vector(-24.1817, -11.9662, 54.8636),
	Q = Vector(-26.1737, -7.9137, 55.6503),
	R = Vector(-28.2183, -3.7876, 55.5180),
	S = Vector(-28.2080, 0.8877, 55.3551),
	T = Vector(-27.1768, 5.2839, 54.8367),
	U = Vector(-24.7437, 9.5472, 54.0941),
	V = Vector(-20.3043, 11.6017, 53.7054),
	W = Vector(-15.2821, 12.6006, 53.2243),
	X = Vector(-10.7024, 12.3530, 52.2391),
	Y = Vector(-6.5012, 10.6867, 51.2069),
	Z = Vector(-3.0627, 7.6676, 50.3809),
	["@"] = Vector(-0.8726, 3.1943, 49.9209),
	-- Engage
	DIAL = Vector(-15.0280, -1.5217, 55.1249), -- The middle "enter" button ;)
}

--################# Gets the button, a player is aiming at @aVoN
function ENT:GetCurrentButton(p,multi)
	local e = self.Entity;
	if (self.Entity:GetNetworkedBool("SG_GROUP_SYSTEM")) then
		self.ChevronPositions = self.ChevronPositionsGroup;
	else
		self.ChevronPositions = self.ChevronPositionsGalaxy;
	end
	local c = self.ChevronPositions;
	local t = p:GetEyeTrace();
	-- damn you garry... GetEyeTrace in gmod13 return always same value when some menu is open
	if (CLIENT and gui.MousePos()!=0) then
		t = util.TraceLine( util.GetPlayerTrace( p, gui.ScreenToVector(gui.MousePos()) ) )
	end
	local cv = self.Entity:WorldToLocal(t.HitPos)
	cv:Normalize();
	local btn -- Possible chevron;
	if(multi) then
		btn = {};
	end
	local lastd = 1337; -- Last distance
	for k,v in pairs(c) do
		if (k=="BaseClass") then continue end -- wtf?
		local da = math.deg(math.acos(v:DotProduct(cv)/v:Length())); -- The differangle
		if(k == "DIAL" and not multi) then
			if(da < 5) then
				btn = k;
				break;
			end
		else
			if(multi) then
				if(da < multi) then
					table.insert(btn,{button=k,angle=da});
				end
			else
				if(da < 3.1) then
					if(da < lastd) then
						lastd = da;
						btn = k;
					end
				end
			end
		end
	end
	return btn;
end

properties.Add( "Stargate.DHD.SG1.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_01d"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin_delete.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsDHD || !ent.IsDHDSg1 || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("DisRingRotate",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "dhdmodify", ent ) ) then return false end
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

						ent.DisRingRotate = true
						ent:SetNWBool("DisRingRotate",true);
					end

});

properties.Add( "Stargate.DHD.SG1.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_01"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin_add.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsDHD || !ent.IsDHDSg1 || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("DisRingRotate",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "dhdmodify", ent ) ) then return false end
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

						ent.DisRingRotate = false
						ent:SetNWBool("DisRingRotate",false);
					end

});

properties.Add( "Stargate.DHD.Atl.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_02"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin_add.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsDHD || !ent.IsDHDAtl || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("DisRingRotate",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "dhdmodify", ent ) ) then return false end
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

						ent.DisRingRotate = true
						ent:SetNWBool("DisRingRotate",true);
					end

});

properties.Add( "Stargate.DHD.Atl.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_02d"),
	Order		=	-100,
	MenuIcon	=	"icon16/plugin_delete.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsDHD || !ent.IsDHDAtl || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("DisRingRotate",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "dhdmodify", ent ) ) then return false end
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

						ent.DisRingRotate = false
						ent:SetNWBool("DisRingRotate",false);
					end

});

properties.Add( "Stargate.DHD.Glyphs.On",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_18"),
	Order		=	-102,
	MenuIcon	=	"icon16/plugin_add.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsDHD || ent:GetNWBool("GateSpawnerProtected",false) || !ent:GetNWBool("DisGlyphs",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "dhdmodify", ent ) ) then return false end
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

						ent:SetNWBool("DisGlyphs",false);
					end

});

properties.Add( "Stargate.DHD.Glyphs.Off",
{
	MenuLabel	=	SGLanguage.GetMessage("stargate_c_tool_18d"),
	Order		=	-102,
	MenuIcon	=	"icon16/plugin_delete.png",

	Filter		=	function( self, ent, ply )

						if ( !IsValid( ent ) || !IsValid( ply ) || !ent.IsDHD || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("DisGlyphs",false)) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "dhdmodify", ent ) ) then return false end
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

						ent:SetNWBool("DisGlyphs",true);
					end

});