# Version: 1.2
# Author: Gmod4phun SvK
# Created: December 2013, Updated: 2.January.2014
# INFO: This is a Atlantis DHD-like Screen. Buttons light up identicaly to the CAP entity one.
# This chip needs wire_expression2_unlimited 1 on server.
# Support thread: http://sg-carterpack.com/forums/topic/stargate-atlantis-egp-pack-2013-release/

@name SGA_2013_Gmod4phun_DHD_Screen
@inputs EGP:wirelink DialingAddress:string Active Inbound Open GlyphColor ShowAuthor
@outputs Orange Yes
@persist 

#if (first() | dupefinished()){ # Experimental stuff, do NOT change anything

EGP:egpBox(1,vec2(256,256),vec2(512,512))
EGP:egpBoxOutline(2,vec2(256,256),vec2(500,500))
EGP:egpColor(1,vec(0,0,40))
EGP:egpColor(2,vec(255,255,255))

for (FID = 3,39) { 
    EGP:egpFidelity(FID,3) 
    EGP:egpSize(FID,2)
}

TriSize = 40

EGP:egpCircleOutline(3,vec2(256,266),vec2(TriSize,TriSize))
EGP:egpAngle(3,90)
EGP:egpCircleOutline(4,vec2(216,246),vec2(TriSize,TriSize))
EGP:egpAngle(4,-90)
EGP:egpCircleOutline(5,vec2(176,266),vec2(TriSize,TriSize))
EGP:egpAngle(5,90)
EGP:egpCircleOutline(6,vec2(136,246),vec2(TriSize,TriSize))
EGP:egpAngle(6,-90)
EGP:egpCircleOutline(7,vec2(96,266),vec2(TriSize,TriSize))
EGP:egpAngle(7,90)
EGP:egpCircleOutline(8,vec2(296,246),vec2(TriSize,TriSize))
EGP:egpAngle(8,-90)
EGP:egpCircleOutline(9,vec2(336,266),vec2(TriSize,TriSize))
EGP:egpAngle(9,90)
EGP:egpCircleOutline(10,vec2(376,246),vec2(TriSize,TriSize))
EGP:egpAngle(10,-90)
EGP:egpCircleOutline(11,vec2(416,266),vec2(TriSize,TriSize))
EGP:egpAngle(11,90)

EGP:egpCircleOutline(12,vec2(256,180),vec2(TriSize,TriSize))
EGP:egpAngle(12,-90)
EGP:egpCircleOutline(13,vec2(216,200),vec2(TriSize,TriSize))
EGP:egpAngle(13,90)
EGP:egpCircleOutline(14,vec2(176,180),vec2(TriSize,TriSize))
EGP:egpAngle(14,-90)
EGP:egpCircleOutline(15,vec2(136,200),vec2(TriSize,TriSize))
EGP:egpAngle(15,90)
EGP:egpCircleOutline(16,vec2(296,200),vec2(TriSize,TriSize))
EGP:egpAngle(16,90)
EGP:egpCircleOutline(17,vec2(336,180),vec2(TriSize,TriSize))
EGP:egpAngle(17,-90)
EGP:egpCircleOutline(18,vec2(376,200),vec2(TriSize,TriSize))
EGP:egpAngle(18,90)

EGP:egpCircleOutline(19,vec2(256,134),vec2(TriSize,TriSize))
EGP:egpAngle(19,90)
EGP:egpCircleOutline(20,vec2(216,114),vec2(TriSize,TriSize))
EGP:egpAngle(20,-90)
EGP:egpCircleOutline(21,vec2(176,134),vec2(TriSize,TriSize))
EGP:egpAngle(21,90)
EGP:egpCircleOutline(22,vec2(296,114),vec2(TriSize,TriSize))
EGP:egpAngle(22,-90)
EGP:egpCircleOutline(23,vec2(336,134),vec2(TriSize,TriSize))
EGP:egpAngle(23,90)

EGP:egpCircleOutline(24,vec2(256,312),vec2(TriSize,TriSize))
EGP:egpAngle(24,-90)
EGP:egpCircleOutline(25,vec2(216,332),vec2(TriSize,TriSize))
EGP:egpAngle(25,90)
EGP:egpCircleOutline(26,vec2(176,312),vec2(TriSize,TriSize))
EGP:egpAngle(26,-90)
EGP:egpCircleOutline(27,vec2(136,332),vec2(TriSize,TriSize))
EGP:egpAngle(27,90)
EGP:egpCircleOutline(28,vec2(96,312),vec2(TriSize,TriSize))
EGP:egpAngle(28,-90)
EGP:egpCircleOutline(29,vec2(296,332),vec2(TriSize,TriSize))
EGP:egpAngle(29,90)
EGP:egpCircleOutline(30,vec2(336,312),vec2(TriSize,TriSize))
EGP:egpAngle(30,-90)
EGP:egpCircleOutline(31,vec2(376,332),vec2(TriSize,TriSize))
EGP:egpAngle(31,90)
EGP:egpCircleOutline(32,vec2(416,312),vec2(TriSize,TriSize))
EGP:egpAngle(32,-90)

EGP:egpCircleOutline(33,vec2(256,398),vec2(TriSize,TriSize))
EGP:egpAngle(33,90)
EGP:egpCircleOutline(34,vec2(216,378),vec2(TriSize,TriSize))
EGP:egpAngle(34,-90)
EGP:egpCircleOutline(35,vec2(176,398),vec2(TriSize,TriSize))
EGP:egpAngle(35,90)
EGP:egpCircleOutline(36,vec2(136,378),vec2(TriSize,TriSize))
EGP:egpAngle(36,-90)
EGP:egpCircleOutline(37,vec2(296,378),vec2(TriSize,TriSize))
EGP:egpAngle(37,-90)
EGP:egpCircleOutline(38,vec2(336,398),vec2(TriSize,TriSize))
EGP:egpAngle(38,90)
EGP:egpCircleOutline(39,vec2(376,378),vec2(TriSize,TriSize))
EGP:egpAngle(39,-90)

for (GSIZ = 40,76) {
    EGP:egpSize(GSIZ, 34)
    EGP:egpFont(GSIZ, "Stargate Address Glyphs Atl")
    EGP:egpAlign(GSIZ,1,1)
}

EGP:egpText(40,"A",vec2(175,135))
EGP:egpText(41,"B",vec2(215,135-14))
EGP:egpText(42,"C",vec2(255,135))
EGP:egpText(43,"D",vec2(295,135-14))
EGP:egpText(44,"E",vec2(335,135))

EGP:egpText(45,"F",vec2(135,200))
EGP:egpText(46,"G",vec2(175,200-14))
EGP:egpText(47,"H",vec2(220,200))
EGP:egpText(48,"I",vec2(255,200-14))
EGP:egpText(49,"J",vec2(295,200))
EGP:egpText(50,"K",vec2(335,200-20))
EGP:egpText(51,"L",vec2(375,200))

EGP:egpText(52,"M",vec2(95,270))
EGP:egpText(53,"N",vec2(135,270-20))
EGP:egpText(54,"O",vec2(175,270))
EGP:egpText(55,"P",vec2(215,270-20))
EGP:egpText(56,"Q",vec2(295,270-20))
EGP:egpText(57,"R",vec2(335,270))
EGP:egpText(58,"S",vec2(375,270-20))
EGP:egpText(59,"T",vec2(415,270))

EGP:egpText(60,"1",vec2(95 ,320-5))
EGP:egpText(61,"2",vec2(135,320+20))
EGP:egpText(62,"3",vec2(175,320-10))
EGP:egpText(63,"4",vec2(215,320+14))
EGP:egpText(64,"5",vec2(255,320-5))
EGP:egpText(65,"6",vec2(295,320+15))
EGP:egpText(66,"7",vec2(335,320-5))
EGP:egpText(67,"8",vec2(380,320+14))
EGP:egpText(68,"9",vec2(415,320-5))

EGP:egpText(69,"U",vec2(135,370+14))
EGP:egpText(70,"V",vec2(175,370+26))
EGP:egpText(71,"W",vec2(215,370+8))
EGP:egpText(72,"0",vec2(260,370+30))
EGP:egpText(73,"X",vec2(295,370+8))
EGP:egpText(74,"Y",vec2(335,370+25))
EGP:egpText(75,"Z",vec2(375,370+4))

EGP:egpText(76,"#",vec2(255,270))

###
#}# End of if first or dupefinished
##
###

for (TRICOL = 3,39) { 
    EGP:egpColor(TRICOL,vec(220,220,220))
}

for (GCOL = 40,76) {
    EGP:egpColor(GCOL,vec(200,200,200))
}

DiAd = DialingAddress

Orange = 1

if (GlyphColor == 1){
    GlyphColorActive = vec(255,130,0) #Orange
}
elseif (GlyphColor != 1){
    GlyphColorActive = vec(0,180,255) #Light Blue
}
GCA = GlyphColorActive


if (DiAd:find("A")){
    EGP:egpColor(40,GCA)
    EGP:egpColor(21,GCA)
}
if (DiAd:find("B")){
    EGP:egpColor(41,GCA)
    EGP:egpColor(20,GCA)
}
if (DiAd:find("C")){
    EGP:egpColor(42,GCA)
    EGP:egpColor(19,GCA)
}
if (DiAd:find("D")){
    EGP:egpColor(43,GCA)
    EGP:egpColor(22,GCA)
}
if (DiAd:find("E")){
    EGP:egpColor(44,GCA)
    EGP:egpColor(23,GCA)
}



if (DiAd:find("F")){
    EGP:egpColor(45,GCA)
    EGP:egpColor(15,GCA)
}
if (DiAd:find("G")){
    EGP:egpColor(46,GCA)
    EGP:egpColor(14,GCA)
}
if (DiAd:find("H")){
    EGP:egpColor(47,GCA)
    EGP:egpColor(13,GCA)
}
if (DiAd:find("I")){
    EGP:egpColor(48,GCA)
    EGP:egpColor(12,GCA)
}
if (DiAd:find("J")){
    EGP:egpColor(49,GCA)
    EGP:egpColor(16,GCA)
}
if (DiAd:find("K")){
    EGP:egpColor(50,GCA)
    EGP:egpColor(17,GCA)
}
if (DiAd:find("L")){
    EGP:egpColor(51,GCA)
    EGP:egpColor(18,GCA)
}



if (DiAd:find("M")){
    EGP:egpColor(52,GCA)
    EGP:egpColor(7,GCA)
}
if (DiAd:find("N")){
    EGP:egpColor(53,GCA)
    EGP:egpColor(6,GCA)
}
if (DiAd:find("O")){
    EGP:egpColor(54,GCA)
    EGP:egpColor(5,GCA)
}
if (DiAd:find("P")){
    EGP:egpColor(55,GCA)
    EGP:egpColor(4,GCA)
}
if (DiAd:find("Q")){
    EGP:egpColor(56,GCA)
    EGP:egpColor(8,GCA)
}
if (DiAd:find("R")){
    EGP:egpColor(57,GCA)
    EGP:egpColor(9,GCA)
}
if (DiAd:find("S")){
    EGP:egpColor(58,GCA)
    EGP:egpColor(10,GCA)
}
if (DiAd:find("T")){
    EGP:egpColor(59,GCA)
    EGP:egpColor(11,GCA)
}



if (DiAd:find("1")){
    EGP:egpColor(60,GCA)
    EGP:egpColor(28,GCA)
}
if (DiAd:find("2")){
    EGP:egpColor(61,GCA)
    EGP:egpColor(27,GCA)
}
if (DiAd:find("3")){
    EGP:egpColor(62,GCA)
    EGP:egpColor(26,GCA)
}
if (DiAd:find("4")){
    EGP:egpColor(63,GCA)
    EGP:egpColor(25,GCA)
}
if (DiAd:find("5")){
    EGP:egpColor(64,GCA)
    EGP:egpColor(24,GCA)
}
if (DiAd:find("6")){
    EGP:egpColor(65,GCA)
    EGP:egpColor(29,GCA)
}
if (DiAd:find("7")){
    EGP:egpColor(66,GCA)
    EGP:egpColor(30,GCA)
}
if (DiAd:find("8")){
    EGP:egpColor(67,GCA)
    EGP:egpColor(31,GCA)
}
if (DiAd:find("9")){
    EGP:egpColor(68,GCA)
    EGP:egpColor(32,GCA)
}



if (DiAd:find("U")){
    EGP:egpColor(69,GCA)
    EGP:egpColor(36,GCA)
}
if (DiAd:find("V")){
    EGP:egpColor(70,GCA)
    EGP:egpColor(35,GCA)
}
if (DiAd:find("W")){
    EGP:egpColor(71,GCA)
    EGP:egpColor(34,GCA)
}
if (DiAd:find("0")){
    EGP:egpColor(72,GCA)
    EGP:egpColor(33,GCA)
}
if (DiAd:find("X")){
    EGP:egpColor(73,GCA)
    EGP:egpColor(37,GCA)
}
if (DiAd:find("Y")){
    EGP:egpColor(74,GCA)
    EGP:egpColor(38,GCA)
}
if (DiAd:find("Z")){
    EGP:egpColor(75,GCA)
    EGP:egpColor(39,GCA)
}

if (DiAd:find("#")){
    EGP:egpColor(76,GCA)
    EGP:egpColor(3,GCA)
}

EGP:egpBoxOutline(77,vec2(256,465),vec2(280,46))
EGP:egpSize(77,2)
EGP:egpText(78,""+DiAd,vec2(256,465))
EGP:egpFont(78,"Stargate Address Glyphs Atl")
EGP:egpColor(78,vec(255,255,255))
EGP:egpSize(78,22)
EGP:egpAlign(78,1,1)

EGP:egpBoxOutline(79,vec2(256,50),vec2(290,60))
EGP:egpSize(79,2)
EGP:egpText(80,"GATE STATUS",vec2(256,50))
EGP:egpFont(80,"Marlett")
EGP:egpSize(80,36)
EGP:egpAlign(80,1,1)

if ( Active == 0 ) {
    EGP:egpText(80,"- IDLE -",vec2(256,50))
    EGP:egpColor(80,vec(255,255,255))
    EGP:egpSize(80,60)
}
if ( Active == 1 & Inbound == 0 & Open == 0 ) {
    EGP:egpText(80,"DIALING",vec2(256,50))
    EGP:egpColor(80,vec(20,200,20))
    EGP:egpSize(80,60)
}
if ( Active == 1 & Inbound == 1 ) {
    EGP:egpText(80,"OFFWORLD ACTIVATION",vec2(256,50))
    EGP:egpColor(80,vec(255,0,0))
    EGP:egpSize(80,28)
}

if ( Active == 1 & Open == 1 & Inbound == 0) {
    EGP:egpText(80,"CONNECTION STABLE",vec2(256,50))
    EGP:egpColor(80,vec(0,180,255))
    EGP:egpSize(80,30)
}

if ( Active == 1 & Open == 1 ) {
    EGP:egpColor(78,vec(0,180,255))
}


Yes = 1
if (ShowAuthor == 1){
    EGP:egpText(81, "Made by Gmod4phun", vec2(348,488))
}
elseif (ShowAuthor !=1){
    EGP:egpText(81, "", vec2(348,488))
}


