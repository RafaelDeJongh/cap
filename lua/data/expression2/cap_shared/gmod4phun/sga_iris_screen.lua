# Version: 1.2
# Author: Gmod4phun SvK
# Created: December 2013, Updated: 2.January.2014
# INFO: This is Atlantis styled IDC and gate Status Screen. Shows Chevron, Gate and IDC status.
# Support thread: http://sg-carterpack.com/forums/topic/stargate-atlantis-egp-pack-2013-release/

@name SGA_2013_Gmod4phun_Iris_Screen
@inputs EGP:wirelink Inbound CodeDescription:string Chevron Iris DialingAddress:string Open Active ShowAuthor
@outputs Yes

#December 2013 . Made by Gmod4phun .#

interval(1000)

#if (first() | dupefinished()){ # Experimental stuff, do NOT change anything

#Background#

EGP:egpBox(1, vec2(256,256), vec2(510,510))
EGP:egpColor(1, vec(0,0,40))
EGP:egpBoxOutline(2, vec2(256,256), vec2(500,500))

#Boxes#

EGP:egpBoxOutline(3, vec2(70,200), vec2(100,360))
EGP:egpBoxOutline(4, vec2(256,440), vec2(472,100))

#Texts n Stuff#

EGP:egpSize(5, 26)

EGP:egpCircleOutline(6, vec2(40,362), vec2(12,12))
EGP:egpFidelity(6, 8)
EGP:egpAngle(6,22.5)
EGP:egpCircleOutline(7, vec2(40,328), vec2(12,12))
EGP:egpFidelity(7, 8)
EGP:egpAngle(7,22.5)
EGP:egpBox(8, vec2(40,345), vec2(2,12))
EGP:egpBox(9, vec2(70,140), vec2(80,220))
EGP:egpColor(9, vec(0,0,0))
EGP:egpBoxOutline(10, vec2(70,140), vec2(80,220))

EGP:egpBoxOutline(11, vec2(320,160), vec2(344,60))
EGP:egpCircleOutline(12, vec2(134,178), vec2(12,12))
EGP:egpFidelity(12, 8)
EGP:egpAngle(12,22.5)
EGP:egpCircleOutline(13, vec2(134,142), vec2(12,12))
EGP:egpFidelity(13, 8)
EGP:egpAngle(13,22.5)
EGP:egpBox(15, vec2(134,160), vec2(2,12))
EGP:egpAlign(16,1,1)

EGP:egpText(18, "Shield Status:", vec2(30,457))
EGP:egpSize(18, 22)

EGP:egpBoxOutline(20, vec2(310,310), vec2(364,80))
EGP:egpText(21, "Destination Address", vec2(300,284))
EGP:egpSize(21,22)
EGP:egpAlign(21,1,1)
EGP:egpFont(22,"Stargate Address Glyphs Atl")
EGP:egpAlign(22,1,1)
EGP:egpSize(22, 28)
EGP:egpColor(22, vec(0,170,200))

# Other stuff #

EGP:egpText(23, "::", vec2(33,348))
EGP:egpText(24, "::", vec2(33,314))
EGP:egpText(25, "::", vec2(127,127))
EGP:egpText(26, "::", vec2(127,164))
for (MISCDOT = 23,26){
    EGP:egpColor(MISCDOT, vec(0,120,180))
    EGP:egpSize(MISCDOT,24)
}

EGP:egpText(27, "Atlantis City", vec2(300,50))
EGP:egpSize(27, 52)
EGP:egpText(28, "Stargate Shield Control", vec2(300,100))
EGP:egpSize(28, 34)
EGP:egpAlign(27,1,1)
EGP:egpAlign(28,1,1)

EGP:egpText(29,"C1:",vec2(36,40))
EGP:egpText(30,"C2:",vec2(36,52))
EGP:egpText(31,"C3:",vec2(36,64))
EGP:egpText(32,"C4:",vec2(36,76))
EGP:egpText(33,"C5:",vec2(36,88))
EGP:egpText(34,"C6:",vec2(36,100))
EGP:egpText(35,"C7:",vec2(36,112))
EGP:egpText(36,"C8:",vec2(36,124))
EGP:egpText(37,"C9:",vec2(36,136))

EGP:egpText(38,"ENCODED",vec2(57,40))
EGP:egpText(39,"ENCODED",vec2(57,52))
EGP:egpText(40,"ENCODED",vec2(57,64))
EGP:egpText(41,"ENCODED",vec2(57,76))
EGP:egpText(42,"ENCODED",vec2(57,88))
EGP:egpText(43,"ENCODED",vec2(57,100))
EGP:egpText(44,"ENCODED",vec2(57,112))
EGP:egpText(45,"ENCODED",vec2(57,124))
EGP:egpText(46,"ENCODED",vec2(57,136))

for (CHEVNUMS = 29,37) {
    EGP:egpAlign(CHEVNUMS,0,1)
    EGP:egpSize(CHEVNUMS,15)
}

for (CHEVSTAT = 38,46) {
    EGP:egpAlign(CHEVSTAT,0,1)
    EGP:egpSize(CHEVSTAT,12)
}

###
#}# End of if first or dupefinished
##
###

if(Active==1&Inbound==0){
    EGP:egpText(16, "Sequence in Progress", vec2(320,158))
    EGP:egpSize(16,38)
    EGP:egpColor(16, vec(0,120,0))
}

if(Open==1&Inbound==0){
    EGP:egpText(16, "Connection Stable", vec2(320,158))
    EGP:egpSize(16,44)
    EGP:egpColor(16, vec(0,220,0))
}

if(Active==0){
    EGP:egpText(16, "Stargate Idle", vec2(320,158))
    EGP:egpSize(16, 40)
    EGP:egpColor(16, vec(0,120,180))
}

if (Inbound == 0){
EGP:egpText(22, "" +DialingAddress, vec2(306,316))
EGP:egpFont(22,"Stargate Address Glyphs Atl")
EGP:egpColor(22, vec(0,170,200))
}
elseif (Inbound == 1){
EGP:egpText(22, "Address Cannot be Provided", vec2(308,316))
EGP:egpFont(22,"Verdana")
EGP:egpColor(22, vec(250,20,20))
}

EGP:egpText(5, "Identification Code:   " +CodeDescription, vec2(30,400))

if(Inbound){    
    EGP:egpText(16, "Incoming Connection", vec2(320,158))
    EGP:egpSize(16, 36)
    EGP:egpColor(16, vec(250,20,20))
}

if(Iris==1){
    EGP:egpText(19, "Shield Online", vec2(160,460))
    EGP:egpColor(19,vec(0,255,0))
}
if(Iris==0){
    EGP:egpText(19, "Shield Offline", vec2(160,460))
    EGP:egpColor(19,vec(255,0,0))
}

# Chevron Indicators

for(CHINDALPHA = 38,46) {EGP:egpAlpha(CHINDALPHA,0)}

if (Chevron == 1){for(CHINDALPHA = 38,38) {EGP:egpAlpha(CHINDALPHA,255) }}
if (Chevron == 2){for(CHINDALPHA = 38,39) {EGP:egpAlpha(CHINDALPHA,255) }}
if (Chevron == 3){for(CHINDALPHA = 38,40) {EGP:egpAlpha(CHINDALPHA,255) }}
if (Chevron == 4){for(CHINDALPHA = 38,41) {EGP:egpAlpha(CHINDALPHA,255) }}
if (Chevron == 5){for(CHINDALPHA = 38,42) {EGP:egpAlpha(CHINDALPHA,255) }}
if (Chevron == 6){for(CHINDALPHA = 38,43) {EGP:egpAlpha(CHINDALPHA,255) }}
if (Open == 0 & Chevron == 7){for(CHINDALPHA = 38,44) {EGP:egpAlpha(CHINDALPHA,255) }}
if (Open == 0 & Chevron == 8){for(CHINDALPHA = 38,45) {EGP:egpAlpha(CHINDALPHA,255) }}
if (Open == 0 & Chevron == 9){for(CHINDALPHA = 38,46) {EGP:egpAlpha(CHINDALPHA,255) }}

if (Open == 0 & Chevron == 7){for(CHINDALPHA = 38,44) {
    EGP:egpAlpha(CHINDALPHA,255) 
    EGP:egpText(44,"ENCODED",vec2(57,112))
}}

if (Open == 1 & Chevron == 7){for(CHINDALPHA = 38,44) {
    EGP:egpAlpha(CHINDALPHA,255) 
    EGP:egpText(44,"LOCKED",vec2(60,112))
}}

if (Open == 0 & Chevron == 8){for(CHINDALPHA = 38,45) {
    EGP:egpAlpha(CHINDALPHA,255) 
    EGP:egpText(44,"ENCODED",vec2(57,112))
    EGP:egpText(45,"ENCODED",vec2(57,124))
}}

if (Open == 1 & Chevron == 8){for(CHINDALPHA = 38,45) {
    EGP:egpAlpha(CHINDALPHA,255) 
    EGP:egpText(44,"ENCODED",vec2(57,112))
    EGP:egpText(45,"LOCKED",vec2(60,124))
}}

if (Open == 0 & Chevron == 9){for(CHINDALPHA = 38,46) {
    EGP:egpAlpha(CHINDALPHA,255) 
    EGP:egpText(44,"ENCODED",vec2(57,112))
    EGP:egpText(45,"ENCODED",vec2(57,124))
    EGP:egpText(46,"ENCODED",vec2(57,136))
}}

if (Open == 1 & Chevron == 9){for(CHINDALPHA = 38,46) {
    EGP:egpAlpha(CHINDALPHA,255) 
    EGP:egpText(44,"ENCODED",vec2(57,112))
    EGP:egpText(45,"ENCODED",vec2(57,124))
    EGP:egpText(46,"LOCKED",vec2(60,136))
}}

if (Inbound == 0){
for (STATCOL = 38,46) {
    EGP:egpColor(STATCOL,vec(0,220,20))
}}
elseif (Inbound == 1){
for (STATCOL = 38,46) {
    EGP:egpColor(STATCOL,vec(220,0,20))
}}

if (Open == 1 & Inbound == 0){
    EGP:egpText(47,"SEQUENCE",vec2(39,145))
    EGP:egpSize(47,16)
    EGP:egpText(48,"COMPLETE",vec2(38,157))
    EGP:egpSize(48,16)
}

if (Open == 1 & Inbound == 1){
    EGP:egpText(47,"INCOMING",vec2(39,150))
    EGP:egpSize(47,16)
    EGP:egpText(48,"",vec2(38,157))
}

if (Open == 0){
    EGP:egpText(47,"",vec2(39,145))
    EGP:egpText(48,"",vec2(38,157))
}

Yes = 1
if (ShowAuthor == 1){
    EGP:egpText(17, "Made by Gmod4phun", vec2(348,488))
}
elseif (ShowAuthor !=1){
    EGP:egpText(17, "", vec2(348,488))
}
