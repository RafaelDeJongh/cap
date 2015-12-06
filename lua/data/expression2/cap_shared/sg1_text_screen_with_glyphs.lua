# Created by AlexALX (c) 2011-2014
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name SG1 Text Screen with Glyphs
@inputs Egp:wirelink Stargate:wirelink
@outputs
@persist
@trigger

interval(50)

# get dialing address
Address = Stargate:stargateGetWireString("Dialing Address")

# get point of origin type
IsConcept = Stargate:stargateGetWire("Earth Point Of Origin")

Egp:egpText(1, Address, vec2(46,246))
if (IsConcept==1) { # if used earth point of origin
    Egp:egpFont(1, "Stargate Address Glyphs Concept", 38)
} else {
    Egp:egpFont(1, "Stargate Address Glyphs SG1", 38)
}

#[Font names:
Stargate Address Glyphs SG1 - for sg1 type gates.
Stargate Address Glyphs Concept - for sg1 type gates with earth point of origin.
Stargate Address Glyphs U - for universe gates with universe dhd symbol order.
Stargate Address Glyphs Atl - for atlantis gates.

for enable fonts on egp in singleplayer or your server
you need MANUALY edit file
wire\lua\entities\gmod_wire_egp\lib\egplib\materials.lua
and add after EGP.ValidFonts[10] = "Roboto" this:

EGP.ValidFonts[11] = "Stargate Address Glyphs SG1"
EGP.ValidFonts[12] = "Stargate Address Glyphs Concept"
EGP.ValidFonts[13] = "Stargate Address Glyphs U"
EGP.ValidFonts[14] = "Stargate Address Glyphs Atl"
EGP.ValidFonts[15] = "Anquietas"
EGP.ValidFonts[16] = "Quiver"

if you are using workshop version, then you should download
this file from github separatery and place in
garrysmod\lua\entities\gmod_wire_egp\lib\egplib\
#]
