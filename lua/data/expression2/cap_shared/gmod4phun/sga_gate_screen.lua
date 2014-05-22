# Version: 1.2
# Author: Gmod4phun SvK
# Created: December 2013, Updated: 2.January.2014
# INFO: This is a Atlantis Gate Screen. It shows everything the gate has. Animated Glyphs.
# Support thread: http://sg-carterpack.com/forums/topic/stargate-atlantis-egp-pack-2013-release/

@name SGA_2013_Gmod4phun_Gate_Screen
@inputs SG:wirelink EGP:wirelink Active Inbound Open Chevrons:string Active_Glyph ShowAuthor
@outputs Yes
@persist 
@trigger 

#December 2013 . Made by Gmod4phun .#

interval(300)

if (first() | dupefinished()) {

# Background
EGP:egpBox(1,vec2(256,256),vec2(512,512))
EGP:egpColor(1,vec(0,0,40))

EGP:egpBoxOutline(2,vec2(256,256),vec2(500,500))

# Stargate Base Stuff
EGP:egpBox(4,vec2(256,256),vec2(2,460))
EGP:egpAngle(4,5)
EGP:egpBox(5,vec2(256,256),vec2(2,460))
EGP:egpAngle(5,15)
EGP:egpBox(6,vec2(256,256),vec2(2,460))
EGP:egpAngle(6,25)
EGP:egpBox(7,vec2(256,256),vec2(2,460))
EGP:egpAngle(7,35)
EGP:egpBox(8,vec2(256,256),vec2(2,460))
EGP:egpAngle(8,45)
EGP:egpBox(9,vec2(256,256),vec2(2,460))
EGP:egpAngle(9,55)
EGP:egpBox(10,vec2(256,256),vec2(2,460))
EGP:egpAngle(10,65)
EGP:egpBox(11,vec2(256,256),vec2(2,460))
EGP:egpAngle(11,75)
EGP:egpBox(12,vec2(256,256),vec2(2,460))
EGP:egpAngle(12,85)
EGP:egpBox(13,vec2(256,256),vec2(2,460))
EGP:egpAngle(13,95)
EGP:egpBox(14,vec2(256,256),vec2(2,460))
EGP:egpAngle(14,105)
EGP:egpBox(15,vec2(256,256),vec2(2,460))
EGP:egpAngle(15,115)
EGP:egpBox(16,vec2(256,256),vec2(2,460))
EGP:egpAngle(16,125)
EGP:egpBox(17,vec2(256,256),vec2(2,460))
EGP:egpAngle(17,135)
EGP:egpBox(18,vec2(256,256),vec2(2,460))
EGP:egpAngle(18,145)
EGP:egpBox(19,vec2(256,256),vec2(2,460))
EGP:egpAngle(19,155)
EGP:egpBox(20,vec2(256,256),vec2(2,460))
EGP:egpAngle(20,165)
EGP:egpBox(21,vec2(256,256),vec2(2,460))
EGP:egpAngle(21,175)

EGP:egpCircleOutline(22,vec2(256,256),vec2(230))
EGP:egpSize(22,20)
EGP:egpCircleOutline(23,vec2(256,256),vec2(230))
EGP:egpSize(23,20)
EGP:egpAngle(23,45)

EGP:egpCircleOutline(24,vec2(256,256),vec2(180))
EGP:egpSize(24,10)
EGP:egpCircleOutline(25,vec2(256,256),vec2(180))
EGP:egpSize(25,10)
EGP:egpAngle(25,45)

for (GATECOL = 4,25) {EGP:egpColor(GATECOL,vec(70,70,70))}

EGP:egpCircle(26,vec2(256,256),vec2(175,175))
EGP:egpColor(26,vec(0,0,40))

# Glyph Text with Atlantis Font
EGP:egpText(27,"A",vec2(292,56))
EGP:egpText(28,"B",vec2(325,66))
EGP:egpText(29,"C",vec2(356,78))
EGP:egpText(30,"D",vec2(388,100))
EGP:egpText(31,"E",vec2(410,126))
EGP:egpText(32,"F",vec2(430,156))
EGP:egpText(33,"G",vec2(446,190))
EGP:egpText(34,"H",vec2(456,222))
EGP:egpText(35,"I",vec2(458,256))
EGP:egpText(36,"J",vec2(454,292))
EGP:egpText(37,"K",vec2(446,324))
EGP:egpText(38,"L",vec2(432,358))
EGP:egpText(39,"M",vec2(410,384))
EGP:egpText(40,"N",vec2(384,408))
EGP:egpText(41,"O",vec2(356,434))
EGP:egpText(42,"P",vec2(324,446))
EGP:egpText(43,"Q",vec2(292,454))
EGP:egpText(44,"R",vec2(258,458))
EGP:egpText(45,"S",vec2(222,456))
EGP:egpText(46,"T",vec2(188,448))
EGP:egpText(47,"U",vec2(156,434))
EGP:egpText(48,"V",vec2(126,410))
EGP:egpText(49,"X",vec2(100,386))
EGP:egpText(50,"Y",vec2(82,356))
EGP:egpText(51,"Z",vec2(66,324))
EGP:egpText(52,"0",vec2(56,294))
EGP:egpText(53,"1",vec2(52,260))
EGP:egpText(54,"2",vec2(56,224))
EGP:egpText(55,"3",vec2(64,188))
EGP:egpText(56,"4",vec2(80,156))
EGP:egpText(57,"5",vec2(100,128))
EGP:egpText(58,"6",vec2(126,102))
EGP:egpText(59,"7",vec2(154,82))
EGP:egpText(60,"8",vec2(186,66))
EGP:egpText(61,"9",vec2(220,58))
EGP:egpText(62,"#",vec2(256,52))

for (G_STUFF = 27,62) {
    EGP:egpFont(G_STUFF,"Stargate Address Glyphs Atl")
    EGP:egpSize(G_STUFF,25)
    EGP:egpAlign(G_STUFF,1,1)
    EGP:egpColor(G_STUFF,vec(200,250,255))
}

# Chevron Objects 

EGP:egpCircle(63,vec2(256,256),vec2(10,10)) # Chev 1
EGP:egpAngle(63,-40)
EGP:egpCircle(64,vec2(256,256),vec2(10,10)) # Chev 2
EGP:egpAngle(64,-80)
EGP:egpCircle(65,vec2(256,256),vec2(10,10)) # Chev 3
EGP:egpAngle(65,-120)
EGP:egpCircle(66,vec2(256,256),vec2(10,10)) # Chev 4
EGP:egpAngle(66,-240)
EGP:egpCircle(67,vec2(256,256),vec2(10,10)) # Chev 5
EGP:egpAngle(67,-280)
EGP:egpCircle(68,vec2(256,256),vec2(10,10)) # Chev 6
EGP:egpAngle(68,-320)
EGP:egpCircle(69,vec2(256,256),vec2(10,10)) # Chev 8
EGP:egpAngle(69,-160)
EGP:egpCircle(70,vec2(256,256),vec2(10,10)) # Chev 9
EGP:egpAngle(70,-200)
EGP:egpCircle(71,vec2(256,256),vec2(10,10)) # Chev 7
EGP:egpAngle(71,-360)

EGP:egpCircle(72,vec2(0,-230),vec2(22,34))
EGP:egpAngle(72,90)
EGP:egpParent(72,63)

EGP:egpCircle(73,vec2(0,-230),vec2(22,34))
EGP:egpAngle(73,90)
EGP:egpParent(73,64)

EGP:egpCircle(74,vec2(0,-230),vec2(22,34))
EGP:egpAngle(74,90)
EGP:egpParent(74,65)

EGP:egpCircle(75,vec2(0,-230),vec2(22,34))
EGP:egpAngle(75,90)
EGP:egpParent(75,66)

EGP:egpCircle(76,vec2(0,-230),vec2(22,34))
EGP:egpAngle(76,90)
EGP:egpParent(76,67)

EGP:egpCircle(77,vec2(0,-230),vec2(22,34))
EGP:egpAngle(77,90)
EGP:egpParent(77,68)

EGP:egpCircle(78,vec2(0,-230),vec2(22,34))
EGP:egpAngle(78,90)
EGP:egpParent(78,69)

EGP:egpCircle(79,vec2(0,-230),vec2(22,34))
EGP:egpAngle(79,90)
EGP:egpParent(79,70)

EGP:egpCircle(80,vec2(0,-230),vec2(22,34))
EGP:egpAngle(80,90)
EGP:egpParent(80,71)

for (CHEVSTUFF = 72,80) {EGP:egpFidelity(CHEVSTUFF,3)}
for (CMISC = 63,71) {EGP:egpAlpha(CMISC,0)}

# Wormhole and Iris #

EGP:egpCircle(81,vec2(256,256),vec2(175,175))
EGP:egpCircle(82,vec2(256,256),vec2(175,175))
EGP:egpCircle(83,vec2(256,256),vec2(175,175))
EGP:egpAngle(82,40)
EGP:egpAngle(83,-40)
for (WMHOLE = 81,83) {
    EGP:egpMaterial(WMHOLE,"gui/center_gradient") 
    EGP:egpColor(WMHOLE,vec(0,80,170))  
}

###
}# End of if first or dupefinished
##
###

for (G_ALPHA = 27,62) {
    EGP:egpAlpha(G_ALPHA,0)
}

AG = Active_Glyph


# Incoming Wormhole Glyph Animation

if (Inbound == 1 & AG == 1) {
    for (INBG = 27,27) {EGP:egpAlpha(INBG,150)}
}
    
if (Inbound == 1 & AG == 2) {
    for (INBG = 27,28) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 3) {
    for (INBG = 27,29) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 4) {
    for (INBG = 27,30) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 5) {
    for (INBG = 27,31) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 6) {
    for (INBG = 27,32) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 7) {
    for (INBG = 27,33) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 8) {
    for (INBG = 27,34) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 9) {
    for (INBG = 27,35) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 10) {
    for (INBG = 27,36) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 11) {
    for (INBG = 27,37) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 12) {
    for (INBG = 27,38) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 13) {
    for (INBG = 27,39) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 14) {
    for (INBG = 27,40) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 15) {
    for (INBG = 27,41) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 16) {
    for (INBG = 27,42) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 17) {
    for (INBG = 27,43) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 18) {
    for (INBG = 27,44) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 19) {
    for (INBG = 27,45) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 20) {
    for (INBG = 27,46) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 21) {
    for (INBG = 27,47) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 22) {
    for (INBG = 27,48) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 23) {
    for (INBG = 27,49) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 24) {
    for (INBG = 27,50) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 25) {
    for (INBG = 27,51) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 26) {
    for (INBG = 27,52) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 27) {
    for (INBG = 27,53) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 28) {
    for (INBG = 27,54) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 29) {
    for (INBG = 27,55) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 30) {
    for (INBG = 27,56) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 31) {
    for (INBG = 27,57) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 32) {
    for (INBG = 27,58) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 33) {
    for (INBG = 27,59) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 34) {
    for (INBG = 27,60) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 35) {
    for (INBG = 27,61) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & AG == 36) {
    for (INBG = 27,62) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 1 & Open == 1 | (EGP:egpColor(80)==(vec(0,160,200))) ) {
    for (INBG = 27,62) {EGP:egpAlpha(INBG,150)}
}

### Normal - Outbound Dialing Glyph Animation

if (Inbound == 0 & AG == 1) {
    EGP:egpAlpha(27,150)
}

if (Inbound == 0 & AG == 2) {
    EGP:egpAlpha(28,150)
}

if (Inbound == 0 & AG == 3) {
    EGP:egpAlpha(29,150)
}

if (Inbound == 0 & AG == 4) {
    EGP:egpAlpha(30,150)
}

if (Inbound == 0 & AG == 5) {
    EGP:egpAlpha(31,150)
}

if (Inbound == 0 & AG == 6) {
    EGP:egpAlpha(32,150)
}

if (Inbound == 0 & AG == 7) {
    EGP:egpAlpha(33,150)
}

if (Inbound == 0 & AG == 8) {
    EGP:egpAlpha(34,150)
}

if (Inbound == 0 & AG == 9) {
    EGP:egpAlpha(35,150)
}

if (Inbound == 0 & AG == 10) {
    EGP:egpAlpha(36,150)
}

if (Inbound == 0 & AG == 11) {
    EGP:egpAlpha(37,150)
}

if (Inbound == 0 & AG == 12) {
    EGP:egpAlpha(38,150)
}

if (Inbound == 0 & AG == 13) {
    EGP:egpAlpha(39,150)
}

if (Inbound == 0 & AG == 14) {
    EGP:egpAlpha(40,150)
}

if (Inbound == 0 & AG == 15) {
    EGP:egpAlpha(41,150)
}

if (Inbound == 0 & AG == 16) {
    EGP:egpAlpha(42,150)
}

if (Inbound == 0 & AG == 17) {
    EGP:egpAlpha(43,150)
}

if (Inbound == 0 & AG == 18) {
    EGP:egpAlpha(44,150)
}

if (Inbound == 0 & AG == 19) {
    EGP:egpAlpha(45,150)
}

if (Inbound == 0 & AG == 20) {
    EGP:egpAlpha(46,150)
}

if (Inbound == 0 & AG == 21) {
    EGP:egpAlpha(47,150)
}

if (Inbound == 0 & AG == 22) {
    EGP:egpAlpha(48,150)
}

if (Inbound == 0 & AG == 23) {
    EGP:egpAlpha(49,150)
}

if (Inbound == 0 & AG == 24) {
    EGP:egpAlpha(50,150)
}

if (Inbound == 0 & AG == 25) {
    EGP:egpAlpha(51,150)
}

if (Inbound == 0 & AG == 26) {
    EGP:egpAlpha(52,150)
}

if (Inbound == 0 & AG == 27) {
    EGP:egpAlpha(53,150)
}

if (Inbound == 0 & AG == 28) {
    EGP:egpAlpha(54,150)
}

if (Inbound == 0 & AG == 29) {
    EGP:egpAlpha(55,150)
}

if (Inbound == 0 & AG == 30) {
    EGP:egpAlpha(56,150)
}

if (Inbound == 0 & AG == 31) {
    EGP:egpAlpha(57,150)
}

if (Inbound == 0 & AG == 32) {
    EGP:egpAlpha(58,150)
}

if (Inbound == 0 & AG == 33) {
    EGP:egpAlpha(59,150)
}

if (Inbound == 0 & AG == 34) {
    EGP:egpAlpha(60,150)
}

if (Inbound == 0 & AG == 35) {
    EGP:egpAlpha(61,150)
}

if (Inbound == 0 & AG == 36) {
    EGP:egpAlpha(62,150)
}

# Chevron Code 

CS = Chevrons
CHEV_ON_COLOR = vec(0,140,250)
CHEV_OFF_COLOR = vec(50,50,50)

for (CHEVCOL = 72,80) {EGP:egpColor(CHEVCOL,CHEV_OFF_COLOR)}

if (CS == "100000000") { for (CHEVCOL = 72,72) {
    EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpAlpha(30,150)
    
}
if (CS == "110000000") { for (CHEVCOL = 72,73) 
    {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpAlpha(30,150)
    EGP:egpAlpha(34,150)
    
}
if (CS == "111000000") { for (
    CHEVCOL = 72,74) {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpAlpha(30,150)
    EGP:egpAlpha(34,150)
    EGP:egpAlpha(38,150)
    
}
if (CS == "111100000") { for (CHEVCOL = 72,75) 
    {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpAlpha(30,150)
    EGP:egpAlpha(34,150)
    EGP:egpAlpha(38,150)
    EGP:egpAlpha(50,150)
    
}
if (CS == "111110000") { for (CHEVCOL = 72,76) 
    {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)}
    EGP:egpAlpha(30,150)
    EGP:egpAlpha(34,150)
    EGP:egpAlpha(38,150)
    EGP:egpAlpha(50,150) 
    EGP:egpAlpha(54,150) 
    
}
if (CS == "111111000") { for (CHEVCOL = 72,77) 
    {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(50,150) 
    EGP:egpAlpha(54,150) 
    EGP:egpAlpha(58,150) 
    
}

if (CS == "111111010") { for (CHEVCOL = 72,78)
    {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)}
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(42,150) 
    EGP:egpAlpha(50,150)
    EGP:egpAlpha(54,150) 
    EGP:egpAlpha(58,150) 
    
}
if (CS == "111111011") { for (CHEVCOL = 72,79)
    {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(42,150) 
    EGP:egpAlpha(46,150) 
    EGP:egpAlpha(50,150)
    EGP:egpAlpha(54,150) 
    EGP:egpAlpha(58,150)
    
}
if (Inbound == 1 & CS == "111111111") { for (CHEVCOL = 72,80) 
    {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)}
for (INBG = 27,62) {EGP:egpAlpha(INBG,150)}
}
if (Inbound == 0 & CS == "111111111") { for (CHEVCOL = 72,80) 
    {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)}
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(42,150) 
    EGP:egpAlpha(46,150) 
    EGP:egpAlpha(50,150)
    EGP:egpAlpha(54,150) 
    EGP:egpAlpha(58,150)
    EGP:egpAlpha(62,150)
    
}
if (Inbound == 0 & CS == "111111100") { for (CHEVCOL = 72,77) {
    EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpColor(80,CHEV_ON_COLOR)
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(50,150) 
    EGP:egpAlpha(54,150) 
    EGP:egpAlpha(58,150) 
    EGP:egpAlpha(62,150)
}
if (Inbound == 1 & CS == "111111100") { for (CHEVCOL = 72,77) {
    EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpColor(80,CHEV_ON_COLOR)
    for (INBG = 27,62) {EGP:egpAlpha(INBG,150)}
}

if (Inbound == 0 & CS == "111111110") { for (CHEVCOL = 72,77) {
    EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpColor(78,CHEV_ON_COLOR)
    EGP:egpColor(80,CHEV_ON_COLOR)
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(42,150) 
    EGP:egpAlpha(50,150)
    EGP:egpAlpha(54,150) 
    EGP:egpAlpha(58,150)
    EGP:egpAlpha(62,150)
}
if (Inbound == 1 & CS == "111111110") { for (CHEVCOL = 72,77) {
    EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpColor(78,CHEV_ON_COLOR)
    EGP:egpColor(80,CHEV_ON_COLOR)
    for (INBG = 27,62) {EGP:egpAlpha(INBG,150)}
}

if (CS == "111000010") { for (CHEVCOL = 72,74) {
    EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpColor(78,CHEV_ON_COLOR)
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(42,150) 
}

if (CS == "111000011") { for (CHEVCOL = 72,74) {
    EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpColor(78,CHEV_ON_COLOR)
    EGP:egpColor(79,CHEV_ON_COLOR)
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(42,150) 
    EGP:egpAlpha(46,150) 
}

if (CS == "111100011") { for (CHEVCOL = 72,75) {
    EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpColor(78,CHEV_ON_COLOR)
    EGP:egpColor(79,CHEV_ON_COLOR)
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(42,150) 
    EGP:egpAlpha(46,150) 
    EGP:egpAlpha(50,150) 
}

if (CS == "111110011") { for (CHEVCOL = 72,76) {
    EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)} 
    EGP:egpColor(78,CHEV_ON_COLOR)
    EGP:egpColor(79,CHEV_ON_COLOR)
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(42,150) 
    EGP:egpAlpha(46,150) 
    EGP:egpAlpha(50,150) 
    EGP:egpAlpha(54,150)
}
if (CS == "111100010") { for (CHEVCOL = 72,74) 
    {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)}
    EGP:egpColor(75,CHEV_ON_COLOR)
    EGP:egpColor(78,CHEV_ON_COLOR)
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(42,150) 
    EGP:egpAlpha(50,150)
    
}
if (CS == "111110010") { for (CHEVCOL = 72,74) 
    {EGP:egpColor(CHEVCOL,CHEV_ON_COLOR)}
    EGP:egpColor(75,CHEV_ON_COLOR)
    EGP:egpColor(76,CHEV_ON_COLOR)
    EGP:egpColor(78,CHEV_ON_COLOR)
    EGP:egpAlpha(30,150) 
    EGP:egpAlpha(34,150) 
    EGP:egpAlpha(38,150) 
    EGP:egpAlpha(42,150) 
    EGP:egpAlpha(50,150)
    EGP:egpAlpha(54,150) 

}

# End of Chevrons Code #
# Misc Stuff

if (Open == 1) {
    for (WHALPHA = 81,83) {
    EGP:egpAlpha(WHALPHA,60) 
}
}
elseif (Open == 0) {
    for (WHALPHA = 81,83) {
    EGP:egpAlpha(WHALPHA,0) 
}
}
if (SG:stargateUnstable() == 1) {
    for (WHUNSTABLE = 81,83) {
    EGP:egpColor(WHUNSTABLE,vec(90,90,90)) 
}
}
elseif (SG:stargateUnstable() == 0) {
    for (WHUNSTABLE = 81,83) {
    EGP:egpColor(WHUNSTABLE,vec(0,80,170)) 
}
}

Yes = 1
if (ShowAuthor == 1){
    EGP:egpText(300, "Made by Gmod4phun", vec2(348,488))
}
if (ShowAuthor == 0){
    EGP:egpText(300, "", vec2(348,488))
}
