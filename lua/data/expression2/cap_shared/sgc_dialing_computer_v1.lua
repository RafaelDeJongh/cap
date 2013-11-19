# Version 0.95
# Author glebqip(RUS)
# Created 19.11.13
# This is Stargate Dialing Computer from first 2 Stargate-SG1 seasons, called as V1.
# This chip need a wire_expression2_unlimited 1, wire_egp_max_bytes_per_seconds 13000 and wire_egp_max_objects 420 on server.
# Support thread: http://sg-carterpack.com/forums/topic/sgc-dialing-computer-v1-e2/
@name SGC Dialing Computer v1
@inputs W:wirelink NewCol Key
@outputs True DialString:string StartStringDial Close Iris DialingMode
@persist ANG I1 I2 Min Linked Painted ETO
@inputs Active Open Inbound Chevron ChevronLocked RingRotation DialMode RingSymbol:string DialingAdress:string DialingSymbol:string DialedSymbol:string 
@persist Alpha2 Color DTL Chev2 DialingAdress1:string Chevron1 Alpha3 B1 Chev AN1 Alpha4 Alpha5 G1 G2 G3 G4 G5 G6 G7 G8 G9  Q B C D EnteredAdress:string ChrA:string Correct DSMB Chevr8 Chevr9 DType:table
@trigger 
if(~W&->W){reset()} 
ChrA="qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890@#*"
if((first()|dupefinished())&egpMaxObjects()>=420){
W:egpClear()
DType[0,string]=""
DType[1,string]="DHD DIALING SEQUENCER"
DType[2,string]="NOX DIALING"
print("This chip needs 420 ID's. This server have "+egpMaxObjects()+" ID's")
print("This chip needs more than 13000 BPS. This server have "+egpMaxUmsgPerSecond()+" BPS")
hint("This chip needs 420 ID's. This server have "+egpMaxObjects()+" ID's",10)
hint("This chip needs more than 13000 BPS. This server have "+egpMaxUmsgPerSecond()+" BPS",10)
True=1
DialingMode=0
W:egpDrawTopLeft(1)
#W:egpBox(1,vec2(0,85),vec2(512,335))
#W:egpBox(1,vec2(0,89),vec2(512,327))
W:egpMaterial(1,"np2")
#W:egpBox(2,vec2(58,285),vec2(72,120))
#W:egpMaterial(2,"image0")
W:egpBoxOutline(2,vec2(1,85),vec2(511,334))
W:egpBoxOutline(3,vec2(8,92),vec2(83,178))
W:egpBoxOutline(4,vec2(6,362),vec2(162,50))
4.8
W:egpLine(5,vec2(162,362),vec2(162,412))
for(I=1,9)
{
W:egpLine(5+I,vec2(162,362+I*5),vec2(167,362+I*5))
}
#
W:egpBoxOutline(17,vec2(170,362),vec2(67,50))
W:egpLine(410,vec2(170,378),vec2(236,378))
W:egpLine(411,vec2(170,395),vec2(236,395))
#
for(I=0,8){W:egpBox(18+I,vec2(441,93+I*45),vec2(64,43))}
W:egpBoxOutline(27,vec2(95,92),vec2(323,267))
for(I=0,8)
{
#if(C==1)
#{
if(I<8){W:egpBoxOutline(28+I,vec2(441,89+I*41),vec2(65,38))}
if(I==8){W:egpBoxOutline(28+I,vec2(353,89+7*41),vec2(65,38))}
W:egpAlpha(35)
W:egpAlpha(35)
#}else
#{
#W:egpBoxOutline(28+I,vec2(441,89+I*41.5),vec2(65,38))}
}
W:egpBox(37,vec2(95,92),vec2(14,17))
W:egpBox(38,vec2(402,92),vec2(14,17))
W:egpBox(39,vec2(95,342),vec2(14,17))
W:egpBox(40,vec2(402,342),vec2(14,17))
W:egpLine(41,vec2(95,108),vec2(185,108))
W:egpLine(42,vec2(416,108),vec2(326,108))
W:egpLine(43,vec2(416,341),vec2(326,341))
W:egpLine(44,vec2(95,341),vec2(185,341))
W:egpLine(45,vec2(229,224),vec2(283,224))
W:egpLine(46,vec2(255,196),vec2(255,253))
#
W:egpLine(47,vec2(95,143),vec2(137,143))
W:egpLine(48,vec2(137,143),vec2(158,122))
W:egpLine(49,vec2(158,122),vec2(165,122))
#
W:egpLine(50,vec2(95,200),vec2(125,200))
#
W:egpLine(51,vec2(95,257),vec2(118,257))
W:egpLine(52,vec2(118,257),vec2(130,292))
W:egpLine(53,vec2(130,292),vec2(138,292))
#
W:egpLine(54,vec2(416,143),vec2(374,143))
W:egpLine(55,vec2(374,143),vec2(353,122))
W:egpLine(56,vec2(353,122),vec2(346,122))
#
W:egpLine(57,vec2(416,200),vec2(386,200))
#
W:egpLine(58,vec2(416,257),vec2(393,257))
W:egpLine(59,vec2(393,257),vec2(381,292))
W:egpLine(60,vec2(381,292),vec2(374,292))
W:egpLine(61,vec2(6,275),vec2(6,357))
W:egpLine(62,vec2(90,275),vec2(90,357))
W:egpLine(63,vec2(9,284),vec2(9,290))
W:egpLine(64,vec2(9,341),vec2(9,347))
W:egpLine(65,vec2(84,284),vec2(84,290))
W:egpLine(66,vec2(84,341),vec2(84,347))
W:egpLine(67,vec2(25,275),vec2(36,275))
W:egpLine(68,vec2(59,275),vec2(70,275))
W:egpLine(69,vec2(25,356),vec2(36,356))
W:egpLine(70,vec2(59,356),vec2(70,356))
#
W:egpLine(71,vec2(25,283),vec2(36,283))
W:egpLine(72,vec2(36,283),vec2(45,292))
W:egpLine(73,vec2(45,292),vec2(45,305))
W:egpLine(74,vec2(45,305),vec2(36,314))
W:egpLine(75,vec2(36,314),vec2(25,314))
W:egpLine(76,vec2(25,314),vec2(16,305))
W:egpLine(77,vec2(16,305),vec2(16,292))
W:egpLine(78,vec2(16,292),vec2(25,283))
#
W:egpLine(79,vec2(58,283),vec2(69,283))
W:egpLine(80,vec2(69,283),vec2(78,292))
W:egpLine(81,vec2(78,292),vec2(78,305))
W:egpLine(82,vec2(78,305),vec2(69,314))
W:egpLine(83,vec2(69,314),vec2(58,314))
W:egpLine(84,vec2(58,314),vec2(49,305))
W:egpLine(85,vec2(49,305),vec2(49,292))
W:egpLine(86,vec2(49,292),vec2(58,283))
#
W:egpLine(87,vec2(58,316),vec2(69,316))
W:egpLine(88,vec2(69,316),vec2(78,325))
W:egpLine(89,vec2(78,325),vec2(78,338))
W:egpLine(90,vec2(78,338),vec2(69,347))
W:egpLine(91,vec2(69,347),vec2(58,347))
W:egpLine(92,vec2(58,347),vec2(49,338))
W:egpLine(93,vec2(49,338),vec2(49,325))
W:egpLine(94,vec2(49,325),vec2(58,316))
#
W:egpLine(95,vec2(25,316),vec2(36,316))
W:egpLine(96,vec2(36,316),vec2(45,325))
W:egpLine(97,vec2(45,325),vec2(45,338))
W:egpLine(98,vec2(45,338),vec2(36,347))
W:egpLine(99,vec2(36,347),vec2(25,347))
W:egpLine(100,vec2(25,347),vec2(16,338))
W:egpLine(101,vec2(16,338),vec2(16,325))
W:egpLine(102,vec2(16,325),vec2(25,316))
#
W:egpLine(103,vec2(30,275),vec2(30,283))
W:egpLine(104,vec2(64,275),vec2(64,283))
W:egpLine(105,vec2(30,356),vec2(30,347))
W:egpLine(106,vec2(64,356),vec2(64,347))

W:egpCircleOutline(107,vec2(256,225),vec2(100,100))
#
for(I=0,6)
{
I2=I2+1
W:egpCircleOutline(108+I,vec2(256,225),vec2(123+I/2,123+I/2))
}

#W:egpCircleOutline(108,vec2(256,225),vec2(125,125))
#W:egpCircleOutline(109,vec2(256,225),vec2(125,126))
#W:egpCircleOutline(110,vec2(256,225),vec2(126,127))
#W:egpCircleOutline(111,vec2(256,225),vec2(126,127))
#W:egpCircleOutline(112,vec2(256,225),vec2(127,127))
#W:egpCircleOutline(113,vec2(256,225),vec2(127,128))
#W:egpCircleOutline(114,vec2(256,225),vec2(128,128))
W:egpCircleOutline(115,vec2(256,225),vec2(103,103))
W:egpCircleOutline(116,vec2(256,225),vec2(113,113))
#
for(I=1,40){
W:egpLine(117+I,vec2(sin(180-(360/39)*I),cos(180-(360/39)*I))*100.3,vec2(sin(180-(360/39)*I),cos(180-(360/39)*I))*127)
#W:egpSize(156+I,2)
W:egpParent(117+I,108) } W:egpAngle(108,round(180/39))
for(I=1,40){
W:egpLine(159+I,vec2(sin(180-(360/39)*I),cos(180-(360/39)*I))*104.3,vec2(sin(180-(360/39)*I),cos(180-(360/39)*I))*114.3)
W:egpSize(159+I,1)
if(NewCol){W:egpColor(159+I,vec(208,208,144))} if(!NewCol){W:egpColor(159+I,vec(255,255,255))}
W:egpParent(159+I,116) } W:egpAngle(116,round(180/39)) W:egpAngle(105,round(180/39))
#interval(100)
#ANG++
W:egpAngle(115,ANG)
W:egpAngle(116,ANG)
#chev1
W:egpBox(202,vec2(336,125),vec2(6,6))
W:egpAngle(202,-35)
W:egpTriangle(203,vec2(-3,3),vec2(3,3),vec2(0,7))
W:egpParent(203,202)
W:egpBox(204,vec2(325,139),vec2(5,5))
W:egpAlpha(204,0)
W:egpLine(205,vec2(-3,-19),vec2(-8,4))
W:egpLine(206,vec2(-8,3),vec2(-4,7))
W:egpLine(207,vec2(-4,7),vec2(15,-3))
W:egpLine(208,vec2(15,-3),vec2(11,-7))
W:egpLine(209,vec2(11,-7),vec2(3,-2))
W:egpLine(210,vec2(3,-2),vec2(-1,-5))
W:egpLine(211,vec2(-1,-5),vec2(2,-15))
W:egpLine(212,vec2(2,-15),vec2(-3,-19))
for(I=1,8){W:egpParent(204+I,204)}
#chev2
W:egpBox(213,vec2(382,200),vec2(6,6))
W:egpAngle(213,-75)
W:egpTriangle(214,vec2(-3,3),vec2(3,3),vec2(0,7))
W:egpParent(214,213)
W:egpBox(215,vec2(365,205),vec2(5,5))
W:egpAlpha(215,0)
W:egpLine(216,vec2(-3,-19),vec2(-8,4))
W:egpLine(217,vec2(-8,3),vec2(-4,7))
W:egpLine(218,vec2(-4,7),vec2(15,-3))
W:egpLine(219,vec2(15,-3),vec2(11,-7))
W:egpLine(220,vec2(11,-7),vec2(3,-2))
W:egpLine(221,vec2(3,-2),vec2(-1,-5))
W:egpLine(222,vec2(-1,-5),vec2(2,-15))
W:egpLine(223,vec2(2,-15),vec2(-3,-19))
W:egpAngle(215,-40)
for(I=1,8){W:egpParent(215+I,215)}
#chev3
W:egpBox(224,vec2(368,287),vec2(6,6))
W:egpAngle(224,-110)
W:egpTriangle(225,vec2(-3,3),vec2(3,3),vec2(0,7))
W:egpParent(225,224)
W:egpBox(226,vec2(354,281),vec2(5,5))
W:egpAlpha(226,0)
W:egpLine(227,vec2(-3,-19),vec2(-8,4))
W:egpLine(228,vec2(-8,3),vec2(-4,7))
W:egpLine(229,vec2(-4,7),vec2(15,-3))
W:egpLine(230,vec2(15,-3),vec2(11,-7))
W:egpLine(231,vec2(11,-7),vec2(3,-2))
W:egpLine(232,vec2(3,-2),vec2(-1,-5))
W:egpLine(233,vec2(-1,-5),vec2(2,-15))
W:egpLine(234,vec2(2,-15),vec2(-3,-19))
W:egpAngle(226,-80)
for(I=1,8){W:egpParent(226+I,226)}
#chev4
W:egpBox(235,vec2(146,293),vec2(6,6))
W:egpAngle(235,-240)
W:egpTriangle(236,vec2(-3,3),vec2(3,3),vec2(0,7))
W:egpParent(236,235)
W:egpBox(237,vec2(162,282),vec2(5,5))
W:egpAlpha(237,0)
W:egpLine(238,vec2(-3,-19),vec2(-8,4))
W:egpLine(239,vec2(-8,3),vec2(-4,7))
W:egpLine(240,vec2(-4,7),vec2(15,-3))
W:egpLine(241,vec2(15,-3),vec2(11,-7))
W:egpLine(242,vec2(11,-7),vec2(3,-2))
W:egpLine(243,vec2(3,-2),vec2(-1,-5))
W:egpLine(244,vec2(-1,-5),vec2(2,-15))
W:egpLine(245,vec2(2,-15),vec2(-3,-19))
W:egpAngle(237,-198)
for(I=1,8){W:egpParent(237+I,237)}
#chev5
W:egpBox(246,vec2(130,206),vec2(6,6))
W:egpAngle(246,-280)
W:egpTriangle(247,vec2(-3,3),vec2(3,3),vec2(0,7))
W:egpParent(247,246)
W:egpBox(248,vec2(147,208),vec2(5,5))
W:egpAlpha(248,0)
W:egpLine(249,vec2(-3,-19),vec2(-8,4))
W:egpLine(250,vec2(-8,3),vec2(-4,7))
W:egpLine(251,vec2(-4,7),vec2(15,-3))
W:egpLine(252,vec2(15,-3),vec2(11,-7))
W:egpLine(253,vec2(11,-7),vec2(3,-2))
W:egpLine(254,vec2(3,-2),vec2(-1,-5))
W:egpLine(255,vec2(-1,-5),vec2(2,-15))
W:egpLine(256,vec2(2,-15),vec2(-3,-19))
W:egpAngle(248,-240)
for(I=1,8){W:egpParent(248+I,248)}
#chev6
W:egpBox(257,vec2(172,129),vec2(6,6))
W:egpAngle(257,-320)
W:egpTriangle(258,vec2(-3,3),vec2(3,3),vec2(0,7))
W:egpParent(258,257)
W:egpBox(259,vec2(184,141),vec2(5,5))
W:egpAlpha(259,0)
W:egpLine(260,vec2(-3,-19),vec2(-8,4))
W:egpLine(261,vec2(-8,3),vec2(-4,7))
W:egpLine(262,vec2(-4,7),vec2(15,-3))
W:egpLine(263,vec2(15,-3),vec2(11,-7))
W:egpLine(264,vec2(11,-7),vec2(3,-2))
W:egpLine(265,vec2(3,-2),vec2(-1,-5))
W:egpLine(266,vec2(-1,-5),vec2(2,-15))
W:egpLine(267,vec2(2,-15),vec2(-3,-19))
W:egpAngle(259,-280)
for(I=1,8){W:egpParent(259+I,259)}
#chev7
W:egpBox(268,vec2(253,96),vec2(6,6))
W:egpTriangle(269,vec2(-3,3),vec2(3,3),vec2(0,9))
W:egpParent(269,268)
W:egpLine(270,vec2(260,108),vec2(262,101))
W:egpLine(271,vec2(262,102),vec2(271,102))
W:egpLine(272,vec2(271,102),vec2(264,122))
W:egpLine(273,vec2(264,122),vec2(258,111))
W:egpLine(274,vec2(251,108),vec2(249,101))
W:egpLine(275,vec2(250,102),vec2(239,102))
W:egpLine(276,vec2(239,102),vec2(248,122))
W:egpLine(277,vec2(248,122),vec2(252,111))
#chev8
W:egpBox(278,vec2(303,345),vec2(6,6))
W:egpAngle(278,-160)
W:egpTriangle(279,vec2(-3,3),vec2(3,3),vec2(0,7))
W:egpParent(279,278)
W:egpBox(280,vec2(296,330),vec2(5,5))
W:egpAlpha(280,0)
W:egpLine(281,vec2(-3,-19),vec2(-8,4))
W:egpLine(282,vec2(-8,3),vec2(-4,7))
W:egpLine(283,vec2(-4,7),vec2(15,-3))
W:egpLine(284,vec2(15,-3),vec2(11,-7))
W:egpLine(285,vec2(11,-7),vec2(3,-2))
W:egpLine(286,vec2(3,-2),vec2(-1,-5))
W:egpLine(287,vec2(-1,-5),vec2(2,-15))
W:egpLine(288,vec2(2,-15),vec2(-3,-19))
W:egpAngle(280,-120)
for(I=1,8){W:egpParent(280+I,280)}
#chev9
W:egpBox(289,vec2(214,346),vec2(6,6))
W:egpAngle(289,-200)
W:egpTriangle(290,vec2(-3,3),vec2(3,3),vec2(0,7))
W:egpParent(290,289)
W:egpBox(291,vec2(220,330),vec2(5,5))
W:egpAlpha(291,0)
W:egpLine(292,vec2(-3,-19),vec2(-8,4))
W:egpLine(293,vec2(-8,3),vec2(-4,7))
W:egpLine(294,vec2(-4,7),vec2(15,-3))
W:egpLine(295,vec2(15,-3),vec2(11,-7))
W:egpLine(296,vec2(11,-7),vec2(3,-2))
W:egpLine(297,vec2(3,-2),vec2(-1,-5))
W:egpLine(298,vec2(-1,-5),vec2(2,-15))
W:egpLine(299,vec2(2,-15),vec2(-3,-19))
W:egpAngle(291,-160)
for(I=1,8){W:egpParent(291+I,291)}
for(I=0,2){W:egpBox(300+I,vec2(26,292+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(303+I,vec2(31,292+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(306+I,vec2(36,292+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(309+I,vec2(59,292+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(312+I,vec2(64,292+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(315+I,vec2(69,292+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(318+I,vec2(26,325+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(321+I,vec2(31,325+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(324+I,vec2(36,325+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(327+I,vec2(59,325+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(330+I,vec2(64,325+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(333+I,vec2(69,325+I*6),vec2(3,3))}
for(I=0,7){W:egpBox(343+I,vec2(170+I*8.2,364),vec2(8,15))}
for(I=0,7){W:egpBox(351+I,vec2(170+I*8.2,379),vec2(8,16))}
for(I=0,7){W:egpBox(359+I,vec2(170+I*8.2,397),vec2(8,15))}
for(I=0,6)
{
W:egpLine(336+I,vec2(178+I*8,362),vec2(178+I*8,412))
}
for(I=0,8){
W:egpText(367+I,"#",vec2(473,115+45*I))
W:egpAlign(367+I,1,1)
W:egpFont(367+I,"Stargate Address Glyphs Concept",35)
}
for(I=0,8){
W:egpText(378+I,toString(I+1),vec2(430,120+45*I))
W:egpAlign(378+I,1,1)
W:egpAlpha(378+I,0)
W:egpFont(378+I,"Marlett",30)
}
for(I=0,8){
W:egpBox(394+I,vec2(23+I*17,411),vec2(14,47))
W:egpAngle(394+I,180)
W:egpMaterial(394+I,"gui/gradient_up")
}
}
if((first()|dupefinished()|~NewCol)&egpMaxObjects()>=420){
W:egpColor(35,vec(255,0,0))
W:egpColor(36,vec(255,0,0))
if(!NewCol){
W:egpColor(410,vec(0,153,184))
W:egpColor(411,vec(0,153,184))
for(I=2,402)
{
if(I<=17|(I>26&I<115)|(I>117&I<158)|(I>17&I<28)|(I>34&I<37)|(I>335&I<343)){W:egpColor(I,vec(0,153,184))}
if((I>114&I<117)|(I>160&I<200)|(I>=202&I<336)){W:egpColor(I,vec(255,255,255))}
if((I>17&I<27)){W:egpColor(I,vec(12,96,104))}
if(I>393&I<403){W:egpColor(I,vec(0,153,184))}
}
}
if(NewCol){
W:egpColor(410,vec(0,153,154))
W:egpColor(411,vec(0,153,154))
for(I=2,402)
{
if(I<=17|(I>26&I<115)|(I>117&I<158)|(I>34&I<37)|(I>335&I<343)){W:egpColor(I,vec(0,153,154))}
if((I>114&I<117)|(I>160&I<200)|(I>=202&I<336)){W:egpColor(I,vec(208,208,144))}
if((I>17&I<27)){W:egpColor(I,vec(12,94,76))}
if(I>393&I<403){W:egpColor(I,vec(0,153,154))}
}
}
}
if((first()|dupefinished())&egpMaxObjects()<420){
print("This chip needs 420 ID's. This server have "+egpMaxObjects()+" ID's")
print("This chip needs more than 13000 BPS. This server have "+egpMaxUmsgPerSecond()+" BPS")
hint("This chip needs 420 ID's. This server have "+egpMaxObjects()+" ID's",10)
hint("This chip needs more than 13000 BPS. This server have "+egpMaxUmsgPerSecond()+" BPS",10)
W:egpClear()
W:egpDrawTopLeft(1)
W:egpBox(1,vec2(0,0),vec2(512,512))
W:egpColor(1,vec(255,255,255))
W:egpBoxOutline(2,vec2(0,0),vec2(512,512))
W:egpColor(2,vec(255,0,0))
W:egpSize(2,20)
W:egpText(3,"WARNING!",vec2(256,64))
W:egpAlign(3,1,1)
W:egpFont(3,"Marlett",100)
W:egpColor(3,vec(255,0,0))
W:egpText(4,"SERVER HAVE ONLY "+egpMaxObjects()+" ID's!",vec2(256,112))
W:egpAlign(4,1,1)
W:egpFont(4,"Marlett",35)
W:egpColor(4,vec(255,0,0))
W:egpText(5,"YOU NEED A 420 ID's!",vec2(256,138))
W:egpAlign(5,1,1)
W:egpFont(5,"Marlett",35)
W:egpColor(5,vec(255,0,0))
W:egpText(6,"NEED ENTER A:",vec2(256,168))
W:egpAlign(6,1,1)
W:egpFont(6,"Marlett",35)
W:egpColor(6,vec(255,0,0))
W:egpText(7,"wire_egp_max_objects 420",vec2(256,191))
W:egpAlign(7,1,1)
W:egpFont(7,"Marlett",35)
W:egpColor(7,vec(255,0,0))
W:egpText(8,"IN SERVER OR SINGLEPLAYER",vec2(256,222))
W:egpAlign(8,1,1)
W:egpFont(8,"Marlett",35)
W:egpColor(8,vec(255,0,0))
W:egpText(9,"CONSOLE",vec2(256,248))
W:egpAlign(9,1,1)
W:egpFont(9,"Marlett",35)
W:egpColor(9,vec(255,0,0))
W:egpTriangle(10,vec2(256,320),vec2(160,480),vec2(352,480))
W:egpColor(10,vec(0,0,0))
W:egpText(11,"!",vec2(256,420))
W:egpAlign(11,1,1)
W:egpFont(11,"Marlett",255)
W:egpColor(11,vec(255,0,0))
timer("warning",500)
}
if(clk("warning")){W:egpAlpha(3,0) W:egpAlpha(10,0) W:egpAlpha(11,0) timer("warning2",500)}
if(clk("warning2")){W:egpAlpha(3,255) W:egpAlpha(10,255) W:egpAlpha(11,255)  timer("warning",500)}


if(egpMaxObjects()>=420){
if(~Key&Key&Key!=127){
if(EnteredAdress:length()<9&!Active){
for(I=1,ChrA:length()){ if(toChar(Key)==ChrA[I]){
EnteredAdress+=ChrA[I]:upper()}}}
} if(~Key&Key==127){EnteredAdress=EnteredAdress:left(EnteredAdress:length()-1)}
if(~Key&Key==13&!Correct&EnteredAdress:length()>5&EnteredAdress:length()<9){EnteredAdress=EnteredAdress+"#"}
if(~Key&((Key==13&Correct)|Key==124)){DialString=EnteredAdress}
if(~Key&(Key==13&Correct)|Key==124){EnteredAdress="" timer("SSDT",100)} if(clk("SSDT")){StartStringDial=1 EnteredAdress="" timer("SSDT1",100)}  if(clk("SSDT1")){StartStringDial=0}
#if(Key==13){StartStringDial=1  EnteredAdress=""} if(Active){StartStringDial=0}
if(~Key&Key==92){Close=1} if(~Key&Key!=92){Close=0}
if(~Key&Key==61){Iris=1}else{Iris=0}
if(~Key&Key==129){DialingMode=0}
if(~Key&Key==130){DialingMode=1}
if(~Key&Key==131){DialingMode=2}
if(!Active){for(I=0,8){W:egpText(367+I,EnteredAdress[I+1],vec2(473,115+45*I))}}
if(~Active&Active){EnteredAdress="" for(I=0,8){W:egpText(367+I,EnteredAdress[I+1],vec2(473,115+45*I))}}
#hint(EnteredAdress+toString(Key),2)
#if(first()|dupefinished()){timer("kvadratiki1",200) timer("kvadratiki2",500) timer("alpha",150)}
if(first()|dupefinished()){timer("kvadratiki1",200) timer("kvadratiki2",500)}
for(I=0,8)
{
W:egpBoxOutline(28+I,vec2(441,93+I*45),vec2(65,43))
#if(C==1)
#{
#if(I<8){W:egpBoxOutline(28+I,vec2(441,89+I*41),vec2(65,38))}
#if(I==8){W:egpBoxOutline(28+I,vec2(353,89+7*41),vec2(65,38))}
W:egpAlpha(35,0)
W:egpAlpha(36,0)
#}else
#{
#}
}
#[if((Chevron>=7|Chevron1>=7)&(DialingSymbol!="#"&DialedSymbol!="#"))
{
W:egpAlpha(35,255)
W:egpColor(35,vec(255,0,0))
W:egpColor(385,vec(255,0,0))
#W:egpBoxOutline(2,vec2(1,85),vec2(511,377))
if(I1<43){timer("I1",50)}
if(clk("I1")){I1=I1+5 if(I1<43){timer("I1",50)}}
W:egpBox(200,vec2(441,404),vec2(65,43-I1))
W:egpColor(200,vec(0,0,0))
} if(Chevron<7&Chevron1<7){W:egpRemove(200) W:egpAlpha(35,0) I1=0}
if((Chevron>=7|Chevron1>=7)&(Chevron>=8|Chevron1>=8)&(DialingSymbol!="#"&DialedSymbol!="#"))
{
W:egpAlpha(36,255)
W:egpColor(36,vec(255,0,0))
W:egpColor(386,vec(255,0,0))
W:egpBoxOutline(2,vec2(1,85),vec2(511,420))
if(I2<43){timer("I2",50)}
if(clk("I2")){I2=I2+5 if(I2<43){timer("I2",50)}}
I2++
W:egpBox(201,vec2(441,449),vec2(65,43-I2))
W:egpColor(201,vec(0,0,0))
} if(Chevron<8&Chevron1<8){W:egpRemove(201) W:egpAlpha(36,0) I2=0 if((Chevron>=7|Chevron1>=7)&(DialingSymbol!="#"&DialedSymbol!="#")){W:egpBoxOutline(2,vec2(1,85),vec2(511,377))}else{W:egpBoxOutline(2,vec2(1,85),vec2(511,334))}}]#
if(RingRotation==1){timer("I3-",100)} if(clk("I3+")){ANG=ANG+2}
if(RingRotation==-1){timer("I3+",100)} if(clk("I3-")){ANG=ANG-2}
if(ANG>9){ANG==0}
if(ANG<0){ANG==9}
W:egpAngle(115,ANG)
W:egpAngle(116,ANG)
if(clk("kvadratiki1")){
if(!B1) {Alpha3=Alpha3-60}
if(B1) {Alpha3=Alpha3+60}
if(Alpha3>=240){ B1=0 }
if(Alpha3<=0){ B1=1 }
W:egpAlpha(387,Alpha3)
W:egpAlpha(388,Alpha3)
W:egpAlpha(389,Alpha3)
W:egpAlpha(390,Alpha3)
W:egpAlpha(391,Alpha3)
W:egpAlpha(392,Alpha3)
W:egpAlpha(407,Alpha3)
if(Active){
if(random()>0.3&G1<48){G1=G1+random(13,15)} if(G1>47){G1=0}
if(random()>0.3&G2<48){G2=G2+random(13,15)} if(G2>47){G2=0}
if(random()>0.3&G3<48){G3=G3+random(13,15)} if(G3>47){G3=0}
if(random()>0.3&G4<48){G4=G4+random(13,15)} if(G4>47){G4=0}
if(random()>0.3&G5<48){G5=G5+random(13,15)} if(G5>47){G5=0}
if(random()>0.3&G6<48){G6=G6+random(13,15)} if(G6>47){G6=0}
if(random()>0.3&G7<48){G7=G7+random(13,15)} if(G7>47){G7=0}
if(random()>0.3&G8<48){G8=G8+random(13,15)} if(G8>47){G8=0}
if(random()>0.3&G9<48){G9=G9+random(13,15)} if(G9>47){G9=0}}
else{G1=0 G2=0 G3=0 G4=0 G5=0 G6=0 G7=0 G8=0 G9=0}
W:egpBox(394,vec2(23,411),vec2(14,G1))
W:egpBox(395,vec2(40,411),vec2(14,G2))
W:egpBox(396,vec2(57,411),vec2(14,G3))
W:egpBox(397,vec2(74,411),vec2(14,G4))
W:egpBox(398,vec2(91,411),vec2(14,G5))
W:egpBox(399,vec2(108,411),vec2(14,G6))
W:egpBox(400,vec2(125,411),vec2(14,G7))
W:egpBox(401,vec2(142,411),vec2(14,G8))
W:egpBox(402,vec2(159,411),vec2(14,G9))
for(I=300,335){if(random()>0.5){Alpha1=255}else{Alpha1=0} W:egpAlpha(I,Alpha1)} timer("kvadratiki1",150)}
if(clk("kvadratiki2")){for(I=343,366){if(random()>0.7){Alpha2=255}else{Alpha2=0} W:egpAlpha(I,Alpha2)} timer("kvadratiki2",500)}
#if(~DTL){W:egpDrawTopLeft(DTL)}
if(DialMode==0){
if((RingSymbol!=""&DialingSymbol==RingSymbol&RingRotation==0&Chev<101)|(DialingSymbol=="#"&RingSymbol=="#"&Chev<101)){timer("chev",100) 
if(clk("chev")&!AN1){timer("chev",100)
W:egpAlpha(408,255)
W:egpText(408,RingSymbol,vec2(260,110+Chev*1.06))
W:egpFont(408,"Stargate Address Glyphs Concept",100)
W:egpSize(408,Chev*1.3)
Chev2=0
if(Chev==0&DialingSymbol!="#"){soundPlay(2,1,"alexalx/glebqip/encode.mp3") timer("enc",1500)} 
if(Chev==0&DialingSymbol=="#"){soundPlay(2,1,"alexalx/glebqip/encode.mp3") timer("enc",1100)} 
Chev=Chev+15 
DTL==0
#W:egpBoxOutline(393,vec2(256,118+(Chev-5)*1.06),vec2((Chev-5)*3.23,(Chev-5)*2.68))
W:egpDrawTopLeft(0)
W:egpBoxOutline(393,vec2(-4,20),vec2((Chev-5)*3.23,(Chev-5)*2.67))
W:egpParent(393,408)
W:egpAlpha(393,255)
W:egpDrawTopLeft(1)
DTL==1
#if(Chev>80){timer("chev2",1300)}
}} #if(DialingSymbol!=RingSymbol){Chev=0}
if(clk("enc")){soundPlay(2,1,"alexalx/glebqip/encode.mp3")}
if(RingSymbol!=""&RingSymbol==DialedSymbol&Chev2<90){timer("chev2",100)
#if(Chev2<90){
if(clk("chev2")&AN1<2){timer("chev2",100)
Chev=0
AN1=1
Chev2=Chev2+20
W:egpText(408,RingSymbol,vec2(260+Chev2*2.15,216-Chev2*(1.01-0.45*(Chevron-1))))
#W:egpSize(367,100-Chev2*0.65)
DTL==0
#W:egpBoxOutline(393,vec2(256+Chev2*2.15,224-Chev2*(1.01-0.45*(Chevron-1))),vec2(318-((Chev2-5)*3.23),255-(Chev2-5)*2.68))
W:egpDrawTopLeft(0)
W:egpBoxOutline(393,vec2(-4,0),vec2(307-((Chev2-15)*3.23),254-(Chev2-15)*2.67))
DTL==1
W:egpAlign(393,1,1)
W:egpParent(393,408)
Alpha4=100-Chev2*1.5 if(Alpha4<0){Alpha4=0}
W:egpAlpha(393,Alpha4)
W:egpDrawTopLeft(1)
W:egpSize(408,130-Chev2*0.845)
if(Chev2>=90){soundPlay(1,1,"alexalx/glebqip/change2.mp3") if(DialedSymbol=="#"){timer("compl0",1)} DialingAdress1=DialingAdress1+DialedSymbol AN1=2 Chevron1++ W:egpAlpha(408,0) W:egpAlpha(393,0)}
#W:egpText(368+Chevron,DialingAdress1[Chevron],vec2(473,115+45*(Chevron-1)))
}}}
if(!Active){W:egpAlpha(408,0)}
 #if(RingSymbol!=DialedSymbol){Chev2=0}
if(!Active){Chev2=0 Chev=0 AN1=2 W:egpRemove(393)}
if(RingRotation!=0){AN1=0}
if(!Inbound&DialMode==0&Active){
if(Chevron1==1){for(I=0,10){W:egpColor(202+I,vec(255,0,0))}}
if(Chevron1==2){for(I=0,10){W:egpColor(213+I,vec(255,0,0))}}
if(Chevron1==3){for(I=0,10){W:egpColor(224+I,vec(255,0,0))}}
if(Chevron1==4){for(I=0,10){W:egpColor(235+I,vec(255,0,0))}}
if(Chevron1==5){for(I=0,10){W:egpColor(246+I,vec(255,0,0))}}
if(Chevron1==6){for(I=0,10){W:egpColor(257+I,vec(255,0,0))}}
if(Chevron1==7){for(I=0,9){W:egpColor(268+I,vec(255,0,0))}}
if(Chevron1==8){for(I=0,10){W:egpColor(278+I,vec(255,0,0))}}
if(Chevron1==9){for(I=0,10){W:egpColor(289+I,vec(255,0,0))}}}
if((Inbound|DialMode!=0)&Active){
if(Chevron==1){for(I=0,10){W:egpColor(202+I,vec(255,0,0))}}
if(Chevron==2){for(I=0,10){W:egpColor(213+I,vec(255,0,0))}}
if(Chevron==3){for(I=0,10){W:egpColor(224+I,vec(255,0,0))}}
if(Chevron==4){for(I=0,10){W:egpColor(235+I,vec(255,0,0))}}
if(Chevron==5){for(I=0,10){W:egpColor(246+I,vec(255,0,0))}}
if(Chevron==6){for(I=0,10){W:egpColor(257+I,vec(255,0,0))}}
if(Chevron==7){for(I=0,9){W:egpColor(268+I,vec(255,0,0))}}
if(Chevron==8){for(I=0,10){W:egpColor(278+I,vec(255,0,0))}}
if(Chevron==9){for(I=0,10){W:egpColor(289+I,vec(255,0,0))}}}
if(~Active&!Active){for(I=0,97){if(NewCol){W:egpColor(202+I,vec(208,208,144))} if(!NewCol){W:egpColor(202+I,vec(255,255,255))}}}
W:egpAlign(408,1,1)
if(Chevron>0){if(DialMode==0&!Inbound){W:egpText(367+Chevron-1,DialingAdress1[Chevron],vec2(473,115+45*(Chevron-1)))}
elseif(!Inbound){W:egpText(367+Chevron-1,DialingAdress[Chevron],vec2(473,115+45*(Chevron-1)))}}
if(!Inbound&DialMode==0){W:egpAlpha(378+Chevron1-1,255)}
if(Inbound|DialMode!=0){W:egpAlpha(378+Chevron-1,255)}
if(~Active&Active==0){Chevron1=0 DialingAdress1="" W:egpAlpha(366,0) for(I=0,8){W:egpText(367+I,"",vec2(473,115+45*(Chevron-1))) W:egpAlpha(378+I,0)}}
W:egpFont(367,"Stargate Address Glyphs Concept")
if(!Active){for(I=0,8){W:egpAlpha(378+I,0)}}
if(Chevron>0){W:egpFont(367+Chevron-1,"Stargate Address Glyphs Concept",35)}
if(Chevron>0){W:egpAlign(367+Chevron-1,1,1)}
if(clk("alpha"))
{
if(!B1) {Alpha3=Alpha3-60}
if(B1) {Alpha3=Alpha3+60}
if(Alpha3>=240){ B1=0 }
if(Alpha3<=0){ B1=1 }
W:egpAlpha(387,Alpha3)
W:egpAlpha(388,Alpha3)
W:egpAlpha(389,Alpha3)
W:egpAlpha(390,Alpha3)
W:egpAlpha(391,Alpha3)
W:egpAlpha(392,Alpha3)
W:egpAlpha(407,Alpha3)
timer("alpha",150)
}
W:egpAlign(387,1,1)
W:egpFont(387,"Marlett")
W:egpFont(388,"Marlett")
W:egpAlign(388,1,1)
if(first()|dupefinished()|~Open|~Active|~Inbound|~DialedSymbol){
if(Active==0&Open==0&Inbound==0){
W:egpRemove(388)
W:egpRemove(389)
W:egpRemove(390)
W:egpRemove(391)
W:egpRemove(392)
W:egpText(387,"IDLE",vec2(266,372))
W:egpSize(387,30)
if(NewCol){W:egpColor(387,vec(0,153,154))} if(!NewCol){W:egpColor(387,vec(0,153,184))}
}
if(Active&!Open&!Inbound&DialedSymbol!="#"){
W:egpRemove(389)
W:egpRemove(390)
W:egpRemove(391)
W:egpRemove(392)
W:egpText(387,"SEQUENCE",vec2(330,374))
W:egpText(388,"IN PROGRESS",vec2(330,398))
W:egpSize(387,26)
W:egpSize(388,26)
if(NewCol){W:egpColor(387,vec(0,153,154))} if(!NewCol){W:egpColor(387,vec(0,153,184))}
if(NewCol){W:egpColor(388,vec(0,153,154))} if(!NewCol){W:egpColor(388,vec(0,153,184))}
}
if(Active&!Open&!Inbound&DialedSymbol=="#"){
W:egpRemove(389)
W:egpRemove(390)
W:egpRemove(391)
W:egpRemove(392)
W:egpText(387,"SEQUENCE",vec2(330,374))
W:egpText(388,"COMPLETE",vec2(330,398))
W:egpSize(387,26)
W:egpSize(388,35)
if(NewCol){W:egpColor(387,vec(0,153,154))} if(!NewCol){W:egpColor(387,vec(0,153,184))}
if(NewCol){W:egpColor(388,vec(0,153,154))} if(!NewCol){W:egpColor(388,vec(0,153,184))}
}
if(Active&Open&!Inbound){
W:egpRemove(388)
W:egpText(387,"LOCKED",vec2(328,388))
W:egpBox(389,vec2(243,362),vec2(170,8))
W:egpBox(390,vec2(243,404),vec2(170,8))
W:egpSize(387,50)
W:egpColor(387,vec(255,0,0))
W:egpColor(389,vec(255,0,0))
W:egpColor(390,vec(255,0,0))
}
if(Active&Inbound)
{
W:egpText(387,"OFFWORLD ACTIVATION",vec2(256,227))
W:egpSize(387,30)
W:egpRemove(388)
W:egpBox(389,vec2(98,95),vec2(43,45))
W:egpBox(390,vec2(374,95),vec2(43,45))
W:egpBox(391,vec2(98,312),vec2(43,45))
W:egpBox(392,vec2(374,312),vec2(43,45))
W:egpColor(387,vec(255,0,0))
W:egpColor(389,vec(255,0,0))
W:egpColor(390,vec(255,0,0))
W:egpColor(391,vec(255,0,0))
W:egpColor(392,vec(255,0,0))
}}
if(~Open){
if(!Open){Min=0}
if(Open){Min=1}
#chev1
W:egpPos(202,vec2(336+Min*4,125-Min*4))
W:egpPos(204,vec2(325-Min*3,139+Min*3))
#chev2
W:egpPos(213,vec2(382+Min*4,200-Min*0))
W:egpPos(215,vec2(365-Min*3,205+Min*0))
#chev3
W:egpPos(224,vec2(368+Min*4,287-Min*-1))
W:egpPos(226,vec2(354-Min*4,281+Min*-1))
#chev4
W:egpPos(235,vec2(146-Min*4,293+Min*1))
W:egpPos(237,vec2(162+Min*4,282-Min*1))
#chev5
W:egpPos(246,vec2(130-Min*4,206))
W:egpPos(248,vec2(147+Min*3,208))
#chev6
W:egpPos(257,vec2(172-Min*4,129-Min*4))
W:egpPos(259,vec2(184+Min*3,141+Min*3))
#chev7
W:egpPos(268,vec2(253,96-Min*4))
W:egpLine(270,vec2(260,108+Min*3),vec2(262,101+Min*3))
W:egpLine(271,vec2(262,102+Min*3),vec2(271,102+Min*3))
W:egpLine(272,vec2(271,102+Min*3),vec2(264,122+Min*3))
W:egpLine(273,vec2(264,122+Min*3),vec2(258,111+Min*3))
W:egpLine(274,vec2(251,108+Min*3),vec2(249,101+Min*3))
W:egpLine(275,vec2(250,102+Min*3),vec2(239,102+Min*3))
W:egpLine(276,vec2(239,102+Min*3),vec2(248,122+Min*3))
W:egpLine(277,vec2(248,122+Min*3),vec2(252,111+Min*3))
#8
W:egpPos(278,vec2(303+Min*1,345+Min*3))
W:egpPos(280,vec2(296-Min*1,330-Min*3))
#9
W:egpPos(289,vec2(214-Min*0,346+Min*4))
W:egpPos(291,vec2(220+Min*0,330-Min*3))
}
#W:egpText(385,"COMPLETE",vec2(330,398))
#W:egpFont(385,"Marlett",35)
if((EnteredAdress:length()>=7&EnteredAdress[EnteredAdress:length()]=="#")|EnteredAdress[9]=="T")
{
Correct=1
W:egpBox(403,vec2(124,153),vec2(264,133))
W:egpColor(403,vec(0,0,0))
W:egpBoxOutline(404,vec2(124,153),vec2(264,133))
W:egpText(405,"INPUT",vec2(256,179))
W:egpAlign(405,1,1)
W:egpFont(405,"Marlett",55)
W:egpText(406,"ACCEPTED",vec2(256,223))
W:egpAlign(406,1,1)
W:egpFont(406,"Marlett",53)
W:egpText(407,"CORRECT ENTRY",vec2(256,265))
W:egpAlign(407,1,1)
W:egpFont(407,"Marlett",27)
W:egpColor(407,vec(200,200,200))
if(NewCol){W:egpColor(404,vec(0,153,154)) W:egpColor(405,vec(0,153,154)) W:egpColor(406,vec(0,153,154))}
if(!NewCol){W:egpColor(404,vec(0,153,184)) W:egpColor(405,vec(0,153,184)) W:egpColor(406,vec(0,153,184))}}
else
{
W:egpRemove(403) W:egpRemove(404) W:egpRemove(405) W:egpRemove(406) W:egpRemove(407) Correct=0
}
if(DialMode==0){
if(Chevron1==7&DialedSymbol!="#"){Chevr8=1}
if(Chevron1==7&DialedSymbol=="#"&DialingSymbol!="#"&Chevr8!=1){Chevr8=0}
if(Chevron1==8&DialedSymbol!="#"){Chevr9=1} 
if(Chevron1==8&DialedSymbol=="#"&DialingSymbol!="#"&Chevr9!=1){Chevr9=0}}
if(DialMode!=0){
if(Chevron==7&DialedSymbol!="#"){Chevr8=1} 
if(Chevron==7&DialedSymbol=="#"&DialingSymbol!="#"){Chevr8=0}
if(Chevron==8&DialedSymbol!="#"){Chevr9=1} 
if(Chevron==8&DialedSymbol=="#"&DialingSymbol!="#"){Chevr9=0}}
if(Chevron<7&Chevron1<7){Chevr8=0}
if(Chevron<8&Chevron1<8){Chevr9=0}
if(~DialedSymbol&Active&!Open&!Inbound&DialedSymbol=="#"&DialMode>0){timer("compl0",1)} if(!Active|Inbound){for(I=0,8){W:egpAlpha(18+I,0)}}# soundStop(3,0)}
if(clk("compl0")){for(I=0,Chevron-1){W:egpAlpha(18+I,255)} timer("compl1",200) soundPlay(3,500,"alexalx/glebqip/lock.wav")} #soundPlay(3,500,"SGDP/v1/DP/lock1.wav")}
if(clk("compl1")){for(I=0,Chevron-1){W:egpAlpha(18+I,0)} timer("compl2",200) soundStop(3,0)}
if(clk("compl2")){for(I=0,Chevron-1){W:egpAlpha(18+I,255)} timer("compl3",200) soundPlay(3,500,"alexalx/glebqip/lock.wav")}
if(clk("compl3")){for(I=0,Chevron-1){W:egpAlpha(18+I,0)} timer("compl4",200) soundStop(3,0)}
if(clk("compl4")){for(I=0,Chevron-1){W:egpAlpha(18+I,255)} timer("compl5",200) soundPlay(3,500,"alexalx/glebqip/lock.wav")}
if(clk("compl5")){for(I=0,Chevron-1){W:egpAlpha(18+I,0)} soundStop(3,0)}
if(Chevr8)
{
W:egpAlpha(35,255)
W:egpColor(35,vec(255,0,0))
W:egpColor(385,vec(255,0,0))
#W:egpBoxOutline(2,vec2(1,85),vec2(511,377))
if(I1<43){timer("I1",50)}
if(clk("I1")){I1=I1+5 if(I1<43){timer("I1",50)}}
W:egpBox(200,vec2(441,404),vec2(65,43-I1))
W:egpColor(200,vec(0,0,0))
} if(!Chevr8&!Chevr9){W:egpRemove(200) W:egpAlpha(35,0) I1=0}
if(Chevr9)
{
W:egpAlpha(36,255)
W:egpColor(36,vec(255,0,0))
W:egpColor(386,vec(255,0,0))
W:egpBoxOutline(2,vec2(1,85),vec2(511,420))
if(I2<43){timer("I2",50)}
if(clk("I2")){I2=I2+5 if(I2<43){timer("I2",50)}}
I2++
W:egpBox(201,vec2(441,449),vec2(65,43-I2))
W:egpColor(201,vec(0,0,0))
} if(!Chevr9){W:egpRemove(201) W:egpAlpha(36,0) I2=0 if(Chevr8&!Chevr9){W:egpBoxOutline(2,vec2(1,85),vec2(511,378))} if(!Chevr8&!Chevr9){W:egpBoxOutline(2,vec2(1,85),vec2(511,334))}}
if(!Inbound){W:egpText(409,DType[DialingMode,string],vec2(256,75))}else{W:egpText(409,DType[0,string],vec2(256,75))}
W:egpAlign(409,1,1)
W:egpFont(409,"Marlett",30)
if(NewCol){W:egpColor(409,vec(0,153,154))}
if(!NewCol){W:egpColor(409,vec(0,153,184))}
if(~Key&Key){soundPlay(0,1,"alexalx/glebqip/click"+randint(1,4)+".mp3")}
if(DialMode!=0&!Inbound){if(~Chevron&Chevron>0){soundPlay(1,1,"alexalx/glebqip/change2.mp3") timer("sstop",200)}} if(clk("sstop")){soundStop(1,0)}
if(~Chev&Chev==15){soundPlay(2,1,"alexalx/glebqip/encode.mp3")}
if(~Chev2&Chev2==20){soundPlay(2,1,"alexalx/glebqip/encode.mp3")}
soundVolume(0,1000)
soundVolume(1,1000)
}
