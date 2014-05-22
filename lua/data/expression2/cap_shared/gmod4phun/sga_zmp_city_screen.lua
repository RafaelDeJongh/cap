# Version: 1.2
# Author: Gmod4phun SvK
# Created: December 2013, Updated: 2.January.2014
# INFO: This is a Atlantis-styled ZPM Screen. It shows the power percent from a ZPM Hub and changes color.
# Support thread: http://sg-carterpack.com/forums/topic/stargate-atlantis-egp-pack-2013-release/

@name SGA_2013_Gmod4phun_ZPM_City_Screen
@inputs EGP:wirelink ZPM_Hub_Percent ShowAuthor MainTextColor
@outputs Disable_Use_from_ZPM_HUB Yes White
@persist 
@trigger 

#December 2013 . Made by Gmod4phun .#

#Color List

AtlantisDarkBlue = vec(0,0,40)
WhiteColor = vec(255,255,255)
GreenColor = vec(0,255,0)
BlackColor = vec(0,0,0)
GreyColor = vec(80,80,80)
LBlueColor = vec(0,100,180)
LBlue2 = vec(0,200,255)

#Disable using (pressing E on the HUB)

Disable_Use_from_ZPM_HUB = 1

#Main ZPM Stuff + Background

EGP:egpBox(1,vec2(256,256),vec2(512,512))
EGP:egpColor(1,AtlantisDarkBlue)

EGP:egpBoxOutline(2,vec2(256,256),vec2(500,500))
EGP:egpColor(2,WhiteColor)

EGP:egpCircle(3,vec2(256,300),vec2(100,100))
EGP:egpColor(3,BlackColor)


ZPM = round(ZPM_Hub_Percent)
EGP:egpWedge(4,vec2(256,300),vec2(90,90))
EGP:egpColor(4,vec((100-ZPM)*2.55,ZPM*2.55,0))
EGP:egpAngle(4,90)
EGP:egpSize(4,-(ZPM*3.6))

if (ZPM >= 100) {EGP:egpSize(4,360)}
if (ZPM < 1) {EGP:egpSize(4,-0.1)}

EGP:egpCircle(5,vec2(256,300),vec2(76,76))
EGP:egpColor(5,BlackColor)

EGP:egpWedge(6,vec2(256,300),vec2(72,72))
EGP:egpColor(6,WhiteColor)
EGP:egpAngle(6,90)
EGP:egpSize(6,360)
if (ZPM < 1) {EGP:egpColor(6,GreyColor)}

EGP:egpCircle(7,vec2(256,300),vec2(64,64))
EGP:egpColor(7,BlackColor)


# ZPM 12 Lines

EGP:egpBox(8,vec2(256,300),vec2(200,4))
EGP:egpAngle(8,0)

EGP:egpBox(9,vec2(256,300),vec2(200,4))
EGP:egpAngle(9,15)

EGP:egpBox(10,vec2(256,300),vec2(200,4))
EGP:egpAngle(10,30)

EGP:egpBox(11,vec2(256,300),vec2(200,4))
EGP:egpAngle(11,45)

EGP:egpBox(12,vec2(256,300),vec2(200,4))
EGP:egpAngle(12,60)

EGP:egpBox(13,vec2(256,300),vec2(200,4))
EGP:egpAngle(13,75)

EGP:egpBox(14,vec2(256,300),vec2(200,4))
EGP:egpAngle(14,90)

EGP:egpBox(15,vec2(256,300),vec2(200,4))
EGP:egpAngle(15,105)

EGP:egpBox(16,vec2(256,300),vec2(200,4))
EGP:egpAngle(16,120)

EGP:egpBox(17,vec2(256,300),vec2(200,4))
EGP:egpAngle(17,135)

EGP:egpBox(18,vec2(256,300),vec2(200,4))
EGP:egpAngle(18,150)

EGP:egpBox(19,vec2(256,300),vec2(200,4))
EGP:egpAngle(19,165)

for (ZPMLineCol = 8,19) {
    EGP:egpColor(ZPMLineCol,BlackColor)
}

EGP:egpCircleOutline(20,vec2(256,300),vec2(104,104))
EGP:egpCircleOutline(21,vec2(256,300),vec2(104,104))
EGP:egpColor(20,LBlueColor)
EGP:egpColor(21,LBlueColor)
EGP:egpAngle(21,45)
EGP:egpSize(20,8)
EGP:egpSize(21,8)

EGP:egpText(22,""+ZPM+"%",vec2(256,300))
EGP:egpSize(22,36)
EGP:egpAlign(22,1,1)
EGP:egpColor(22,LBlue2)
if (ZPM < 1) {EGP:egpText(22,"0%",vec2(256,300))}

EGP:egpText(23," Zero Point Module ",vec2(256,90))
EGP:egpSize(23,50)
EGP:egpAlign(23,1,1)
EGP:egpColor(23,LBlue2)

EGP:egpText(24,"| Energy Status |",vec2(256,130))
EGP:egpSize(24,40)
EGP:egpAlign(24,1,1)
EGP:egpColor(24,LBlue2)

EGP:egpBoxOutline(25,vec2(256,330),vec2(400,320))
EGP:egpColor(25,LBlueColor)
EGP:egpSize(25,4)

EGP:egpBox(26,vec2(256,184),vec2(4,20))
EGP:egpColor(26,LBlueColor)

EGP:egpBox(27,vec2(104,300),vec2(90,4))
EGP:egpBox(28,vec2(408,300),vec2(90,4))
EGP:egpColor(27,LBlueColor)
EGP:egpColor(28,LBlueColor)

EGP:egpBoxOutline(29,vec2(256,446),vec2(320,60))
EGP:egpColor(29,LBlueColor)
EGP:egpSize(29,4)

EGP:egpBox(30,vec2(256,410),vec2(4,16))
EGP:egpColor(30,LBlueColor)
EGP:egpBox(31,vec2(256,480),vec2(4,16))
EGP:egpColor(31,LBlueColor)

EGP:egpText(32,"ZPM STATUS MESSAGE TEXT",vec2(256,446))
EGP:egpAlign(32,1,1)
EGP:egpSize(32,26)
EGP:egpColor(32,LBlue2)

if (ZPM < 1) {
    EGP:egpText(32,"Zero Point Module Offline",vec2(256,446))
    EGP:egpColor(32,GreyColor)
}

if (ZPM > 0) {
    EGP:egpText(32,"Zero Point Module Online",vec2(256,446))
}
EGP:egpText(33,"Atlantis City",vec2(256,50))
EGP:egpAlign(33,1,1)
EGP:egpSize(33,46)

White = 2
if (MainTextColor != 2){
EGP:egpColor(23,LBlue2)
EGP:egpColor(24,LBlue2)
EGP:egpColor(33,LBlue2)
}
elseif (MainTextColor == 2){
EGP:egpColor(23,WhiteColor)
EGP:egpColor(24,WhiteColor)
EGP:egpColor(33,WhiteColor)
}

Yes = 1
if (ShowAuthor == 1){
    EGP:egpText(34, "Made by Gmod4phun", vec2(348,488))
}
elseif (ShowAuthor !=1){
    EGP:egpText(34, "", vec2(348,488))
}
