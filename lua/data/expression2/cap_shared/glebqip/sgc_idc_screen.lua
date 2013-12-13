# Version 1.0
# Author glebqip(RUS)
# Created 30.11.13 Updated 08.02.13
# This is Stargate IDC Screen from first 2 Stargate-SG1 seasons, called as V1.
# This chip need a wire_expression2_unlimited 1 and wire_egp_max_bytes_per_seconds 13000 on server.
# Support thread: http://sg-carterpack.com/forums/topic/sgc-dialing-computer-v1-e2/

@name SGC IDC Screen
@inputs Start DPL W:wirelink Key NewCol Active Inbound IDC:table RecirvedCode Iris IrisComp
@outputs True IrisControl GDOStatus GDOText:string IDCName:string IDCStatus
@persist RAM Pip Load1 IDsOverride LoadOver Loaded Loaded1 RB STD2:string STD STD1 IDs1
@persist A:table B:table C:table D:table E:table F:table Rand196 Rand1914 A1 A2 E1 A111 A211 Stat RRS:table RRS1:table RSR1:table RSR2:table RSR3:table Alpha1 RI RI2 CodeStat AA Decoding:table EndSymb:string EndSymb2:string RecirvedCode1 Iris1 Irl
@trigger 
function number even(CHET)
{
if(CHET/2==round(CHET/2)){return 1} else {return 0}
}
if(~W&->W){reset()}
if(first()|dupefinished()|clk("shutdown1")){W:egpClear() Loaded1=0}
if(((~Start|first()|dupefinished())&Start)&Loaded1==0)
{
if(Start<=1|Start==3){LoadOver=0} 
if(Start==2){LoadOver=1}
RingSpeedMode=1
W:egpClear()
for(I=0,9){W:egpText(1+I,"",vec2(5,10+I*12)) W:egpAlign(1+I,0,1) W:egpFont(1+I,"Console",15)}
Load1=0
timer("LD01",randint(100,2000))
Loaded=0
Loaded1=1
}
if(clk("LD01")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("STPS",100) timer("LD1",randint(1000,2500))}
if(clk("STPS")){soundVolume(12,0) soundStop(12,0)}
if(!Loaded&!LoadOver){
if(clk("LD1")){
W:egpSetText(1,"Stargate Supercomputer complex") timer("LD2",randint(100,1000))}
if(clk("LD2")){
W:egpSetText(2,"CPU:detecting...") timer("LD21",randint(300,600))}
if(clk("LD21")&maxquota()>80000){Pip=0 W:egpSetText(2,"CPU:"+maxquota():toString()+" OPS OK!") W:egpColor(2,vec(255,255,255)) timer("LD3",randint(150,300))}
if(clk("LD21")&maxquota()<=80000){W:egpSetText(2,"CPU:"+maxquota():toString()+" OPS CPU IS TO SLOW TO WORK! WAIT A wire_expression2_unlimited 1") if(!Pip){timer("errpip",1) Pip=1} W:egpColor(2,vec(255,0,0)) timer("LD12",100)}
if(clk("LD3")&RAM<ceil(egpMaxObjects()/128)*256){
RAM+=randint(128,512)/10*(egpMaxObjects()/420)
W:egpSetText(3,"RAM:"+ceil(RAM)+"MB") timer("LD3",randint(100,200))}
if(clk("LD3")&RAM>=ceil(egpMaxObjects()/128)*256){timer("LD4",1000) W:egpSetText(3,"RAM:"+toString(ceil(egpMaxObjects()/128)*256)+" OK!")}
if(clk("LD4")){RAM=0 W:egpSetText(4,"GPUSpeed:"+egpMaxUmsgPerSecond():toString()+" BPS OK!") timer("LD5",randint(150,300))}
if(clk("LD5")&!->Key){
W:egpSetText(5,"Error! Keyboard not detected! Waiting keyboard connect.") if(!Pip){timer("errpip",1) Pip=1} W:egpColor(5,vec(255,0,0)) timer("LD5",1000)}
if(clk("LD5")&->Key){W:egpSetText(5,"Keyboard... OK!") W:egpColor(5,vec(255,255,255)) Pip=0 timer("LD6",randint(800,1300))}
if(egpMaxObjects()<420&~Key&Key==13&IDs1){IDsOverride=1 IDs1=0}
if(clk("LD6")&egpMaxObjects()>354&!IDsOverride){W:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's OK!") W:egpColor(6,vec(255,255,255)) timer("LD7",randint(50,300)) Pip=0}
if(clk("LD6")&(egpMaxObjects()<354&IDsOverride)){W:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's Override ID's protection!") W:egpColor(6,vec(255,255,0)) timer("LD7",randint(50,300)) Pip=0}
if(clk("LD6")&egpMaxObjects()<354&!IDsOverride){IDs1=1 W:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's. Need a 196 ID's. Waiting a wire_egp_max_objects 196!") if(!Pip){timer("errpip",1) Pip=1} timer("LD6",150) W:egpColor(6,vec(255,0,0))}
if(clk("LD7")&!->IDC){if(!Pip){timer("errpip",1) Pip=1} W:egpSetText(7,"Can't connect to IDC Codes Database!!!") W:egpColor(7,vec(255,0,0)) timer("LD7",100)}
if(clk("LD7")&->IDC){Pip=0 W:egpSetText(7,"Connected to IDC Code Database") W:egpColor(7,vec(255,255,255)) timer("LD8",100)}
if(clk("LD8")&(!->IrisControl|!->GDOStatus|!->GDOText|!->Inbound|!->RecirvedCode|!->Iris))
{W:egpSetText(8,"Not connected correctly!!! Waiting...") W:egpColor(8,vec(255,0,0)) if(!Pip){timer("errpip",1) Pip=1} timer("LD8",500)}
elseif(clk("LD8")){Pip=0 W:egpSetText(8,"Connected correctly!") W:egpColor(8,vec(0,255,0)) timer("LD9",randint(200,700))}
if(clk("LD9")){Load1=0 Pip=0 W:egpSetText(9,"IDC Computer build 1.241.15 v1 07.12.13 is loading...") W:egpColor(9,vec(255,255,255)) timer("LD91",randint(100,1000))}
if(clk("LD91")&Loaded!=1&Load1<100){Load1+=randint(4,12) W:egpSetText(9,"IDC Computer build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD91",randint(100,300))}  
if(Load1>=100){W:egpSetText(9,"IDC Computer build 1.241.15 v1 07.12.13 is loading... 100%") if(DPL){timer("Loaded",randint(50,700))}else{timer("LD92",randint(100,300))}}
if(clk("LD92")&!DPL&->DPL){if(!Pip){timer("errpip",1) Pip=1} W:egpSetText(10,"Waiting Dialing Programm...") W:egpColor(10,vec(255,255,0)) timer("LD92",100)}
if(clk("LD92")&(DPL|!->DPL)){Pip=0 timer("Loaded",randint(50,700))}}
if(!Loaded&LoadOver){
if(clk("LD1")){Load1=0 soundVolume(12,0) soundStop(12,0.001) W:egpSetText(1,"IDC Computer build 1.241.15 v1 07.12.13 is loading...") W:egpColor(1,vec(255,255,255)) timer("LD11",randint(100,1000))}
if(clk("LD11")&Loaded!=1&Load1<100){Load1+=randint(4,12) W:egpSetText(1,"IDC Computer build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD11",randint(100,300))}  
if(Load1>=100){W:egpSetText(1,"IDC Computer build 1.241.15 v1 07.12.13 is loading... 100%") timer("Loaded",randint(50,700))}}
if(clk("shutdown")){
STD1=randint(30,80)
W:egpClear()
STD2=""
STD=0
W:egpText(1,"",vec2(5,10)) W:egpAlign(1,0,1) W:egpFont(1,"Console",15)
timer("STD1",randint(50,500))}
if(clk("STD1")&STD<=STD1){STD2+="." if(STD2:length()>3){STD2=""} W:egpSetText(1,"Shutting down"+STD2) STD++ timer("STD1",150)}
if(clk("STD1")&STD>STD1){Loaded=0 timer("shutdown1",1)}
if(clk("Loaded")){timer("decoding",200) timer("LINE1",250) timer("kvadratiki",150) timer("ircheck",300)
Loaded=1
Rand1914=99999999999999
Rand196=999999
True=1
Load1=0
A[1,string]="ROTATE"
A[2,string]="CONTROL"
A[3,string]="LOG"
B[1,string]="PAUSE"
B[2,string]="DISPLAY"
B[3,string]="LOG"
C[1,string]="GATE INTEGRITY NORMAL"
C[2,string]="WORMHOLE STABILITY NORMAL"
C[3,string]="GATE INTEGRITY WARNING"
C[4,string]="WORMHOLE STABILITY LOW"
C[5,string]="WORMHOLE STABILITY CRITICAL"
D[1,string]="MENU"
D[2,string]="GRAPH"
D[3,string]="SPEC"
D[4,string]="FULL"
for(I=0,19){Decoding[I+1,string]=""}
W:egpClear()
W:egpDrawTopLeft(1)
#W:egpBox(1,vec2(0,81),vec2(512,350)) W:egpMaterial(1,"idc1")
W:egpBoxOutline(2,vec2(1,83),vec2(243,349))
W:egpLine(3,vec2(1,97),vec2(242,97))
W:egpBoxOutline(4,vec2(247,83),vec2(264,191))
W:egpBox(5,vec2(247,84),vec2(72,59))
W:egpBoxOutline(6,vec2(325,97),vec2(178,176))
for(I=0,2){W:egpBoxOutline(7+I,vec2(252,217+I*19),vec2(70,15))}
W:egpBoxOutline(10,vec2(247,277),vec2(264,154))
W:egpBoxOutline(11,vec2(250,280),vec2(258,86))
for(I=0,2){W:egpBoxOutline(12+I,vec2(4,284+I*18),vec2(80,16))}
for(I=0,3){W:egpBoxOutline(15+I,vec2(4+I*60,415),vec2(56,12))}
W:egpBoxOutline(19,vec2(4,337),vec2(80,76))
W:egpLine(20,vec2(6,346),vec2(6,349))
W:egpLine(21,vec2(6,398),vec2(6,401)) 
W:egpLine(22,vec2(81,346),vec2(81,349))
W:egpLine(23,vec2(81,398),vec2(81,401)) 
W:egpLine(24,vec2(22,338),vec2(31,338)) 
W:egpLine(25,vec2(57,338),vec2(66,338)) 
W:egpLine(26,vec2(22,410),vec2(31,410)) 
W:egpLine(27,vec2(57,410),vec2(66,410)) 
W:egpLine(28,vec2(27,338),vec2(27,346)) 
W:egpLine(29,vec2(61,338),vec2(61,346)) 
W:egpLine(30,vec2(27,403),vec2(27,410)) 
W:egpLine(31,vec2(61,403),vec2(61,410)) 
#
W:egpLine(32,vec2(19,346),vec2(34,346)) 
W:egpLine(33,vec2(34,346),vec2(42,354)) 
W:egpLine(34,vec2(42,354),vec2(42,364)) 
W:egpLine(35,vec2(42,364),vec2(34,372)) 
W:egpLine(36,vec2(34,372),vec2(19,372)) 
W:egpLine(37,vec2(19,372),vec2(11,364)) 
W:egpLine(38,vec2(11,364),vec2(11,354)) 
W:egpLine(39,vec2(11,354),vec2(19,346)) 
#
W:egpLine(40,vec2(54,346),vec2(69,346)) 
W:egpLine(41,vec2(69,346),vec2(77,354)) 
W:egpLine(42,vec2(77,354),vec2(77,364)) 
W:egpLine(43,vec2(77,364),vec2(69,372)) 
W:egpLine(44,vec2(69,372),vec2(54,372)) 
W:egpLine(45,vec2(54,372),vec2(46,364)) 
W:egpLine(46,vec2(46,364),vec2(46,354)) 
W:egpLine(47,vec2(46,354),vec2(54,346)) 
#
W:egpLine(48,vec2(19,376),vec2(34,376)) 
W:egpLine(49,vec2(34,376),vec2(42,384)) 
W:egpLine(50,vec2(42,384),vec2(42,394)) 
W:egpLine(51,vec2(42,394),vec2(34,402)) 
W:egpLine(52,vec2(34,402),vec2(19,402)) 
W:egpLine(53,vec2(19,402),vec2(11,394)) 
W:egpLine(54,vec2(11,394),vec2(11,384)) 
W:egpLine(55,vec2(11,384),vec2(19,376)) 
#
W:egpLine(56,vec2(54,376),vec2(69,376)) 
W:egpLine(57,vec2(69,376),vec2(77,384)) 
W:egpLine(58,vec2(77,384),vec2(77,394)) 
W:egpLine(59,vec2(77,394),vec2(69,402)) 
W:egpLine(60,vec2(69,402),vec2(54,402)) 
W:egpLine(61,vec2(54,402),vec2(46,394)) 
W:egpLine(62,vec2(46,394),vec2(46,384)) 
W:egpLine(63,vec2(46,384),vec2(54,376)) 
for(I=0,4){W:egpBox(64+I,vec2(89,360+I*11),vec2(10,8)) W:egpColor(64+I,vec(50+I*51,255-I*51,20))}
W:egpText(69,"GATE INTEGRITY MONITOR",vec2(121,90)) W:egpAlign(69,1,1) W:egpFont(69,"Marlett",20)
for(I=0,2){W:egpText(70+I,A[I+1,string],vec2(43,292+I*18)) W:egpAlign(70+I,1,1) W:egpFont(70+I,"Marlett",11)}
for(I=0,2){W:egpText(73+I,B[I+1,string],vec2(284,224+I*19)) W:egpAlign(73+I,1,1) W:egpFont(73+I,"Marlett",11)}
W:egpText(76,"SIGNAL DATA",vec2(375,90)) W:egpAlign(76,1,1) W:egpFont(76,"Marlett",18)
W:egpText(77,"DECODING",vec2(358,104)) W:egpAlign(77,1,1) W:egpFont(77,"Marlett",11)
for(I=0,4){W:egpText(78+I,C[I+1,string],vec2(102,364+I*11)) W:egpAlign(78+I,0,1) W:egpFont(78+I,"Marlett",8)}
for(I=0,3){W:egpText(83+I,D[I+1,string],vec2(30+I*60,422)) W:egpAlign(83+I,1,1) W:egpFont(83+I,"Marlett",11)}
for(I=0,19){W:egpText(88+I,"",vec2(329,114+I*8)) W:egpAlign(88+I,0,1) W:egpFont(88+I,"Marlett",8) W:egpColor(88+I,vec(175,175,175))}
for(I=0,8){W:egpText(108+I,toString(round(random(1,Rand1914))),vec2(251,146+I*8)) W:egpAlign(108+I,0,1) W:egpFont(108+I,"Marlett",8)}
W:egpText(268,"ANALYSING",vec2(375,384)) W:egpAlign(268,1,1) W:egpFont(268,"Marlett",30)
W:egpText(269,"SIGNAL",vec2(375,412)) W:egpAlign(269,1,1) W:egpFont(269,"Marlett",30)
W:egpBox(271,vec2(328,112),vec2(172,7))
W:egpMaterial(271,"gui/center_gradient")
W:egpColor(271,vec(0,255,0))
#W:egpBox(272,vec2(414,111),vec2(172,6))
##
RRS[1,string]="RECEIVING"
RRS[2,string]="REMOTE"
RRS[3,string]="SIGNAL"
RSR1[1,string]="SIGNAL"
RSR1[2,string]="RECOGNIZED"
RSR2[1,string]="SIGNAL"
RSR2[2,string]="NOT"
RSR2[3,string]="RECOGNIZED"
RSR3[1,string]="SIGNAL"
RSR3[2,string]="EXPIRED"
W:egpBoxOutline(273,vec2(248,82),vec2(264,192)) W:egpSize(273,12) W:egpColor(273,vec(255,255,0))
W:egpBox(274,vec2(260,94),vec2(240,168)) W:egpColor(274,vec(202,235,246))
W:egpText(275,"CAUTION",vec2(380,131)) W:egpColor(275,vec(255,0,0)) W:egpAlign(275,1,1) W:egpFont(275,"Marlett",40)
for(I=0,2){W:egpText(276+I,RRS[I+1,string],vec2(380,167+I*22)) W:egpColor(276+I,vec(62,96,107)) W:egpAlign(276+I,1,1) W:egpFont(276+I,"Marlett",26)}
W:egpTriangleOutline(278,vec2(347,227),vec2(380,177),vec2(413,227)) W:egpColor(278,vec(62,96,107)) W:egpSize(278,3)
W:egpText(280,"877032-333-0",vec2(379,241)) W:egpColor(280,vec(62,96,107)) W:egpAlign(280,1,1) W:egpFont(280,"Marlett",18)
W:egpBox(288,vec2(251,281),vec2(256,84)) W:egpColor(288,vec(0,0,0))
W:egpText(289,"SIGNAL CODE RESPONSE",vec2(343,288)) W:egpColor(289,vec(255,0,0)) W:egpAlign(289,1,1) W:egpFont(289,"Marlett",17)
for(I=0,6){W:egpBoxOutline(290+I,vec2(255+I*36,296),vec2(30,30))}
for(I=0,6){W:egpBoxOutline(297+I,vec2(255+I*36,331),vec2(30,30))}
for(I=0,6){W:egpText(304+I,"",vec2(270+I*36,311)) W:egpAlign(304+I,1,1) W:egpFont(304+I,"Marlett",30) W:egpColor(304+I,vec(0,255,0))}
for(I=0,6){W:egpText(311+I,"",vec2(270+I*36,346)) W:egpAlign(311+I,1,1) W:egpFont(311+I,"Marlett",30) W:egpColor(311+I,vec(0,255,0))}
for(I=0,2){W:egpBox(318+I,vec2(20,353+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(321+I,vec2(26,353+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(324+I,vec2(32,353+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(327+I,vec2(56,353+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(330+I,vec2(62,353+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(333+I,vec2(68,353+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(336+I,vec2(20,383+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(339+I,vec2(26,383+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(342+I,vec2(32,383+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(345+I,vec2(56,383+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(348+I,vec2(62,383+I*6),vec2(3,3))}
for(I=0,2){W:egpBox(351+I,vec2(68,383+I*6),vec2(3,3))}
W:egpBox(354,vec2(258,280),vec2(86,7))
W:egpAngle(354,-90)
W:egpMaterial(354,"gui/center_gradient")
W:egpColor(354,vec(0,255,0))
W:egpBoxOutline(281,vec2(248,82),vec2(264,192)) W:egpSize(281,12) W:egpColor(281,vec(0,200,0))
W:egpBox(282,vec2(260,94),vec2(240,168)) W:egpColor(282,vec(202,235,246))
W:egpText(283,"ACCEPT",vec2(380,121)) W:egpColor(283,vec(0,200,0)) W:egpAlign(283,1,1) W:egpFont(283,"Marlett",63)
for(I=0,1){W:egpText(284+I,RSR1[I+1,string],vec2(380,167+I*24)) W:egpColor(284+I,vec(28,78,83)) W:egpAlign(284+I,1,1) W:egpFont(284+I,"Marlett",26)}
W:egpText(286,IDC[RecirvedCode1,array][2,string],vec2(380,228)) W:egpColor(286,vec(28,78,83)) W:egpAlign(286,1,1) W:egpFont(286,"Marlett",26)
W:egpText(287,"AUTH#   32-333-0",vec2(379,252)) W:egpColor(287,vec(62,96,107)) W:egpAlign(287,1,1) W:egpFont(287,"Marlett",18)
timer("draw",1)
}
if(~NewCol){timer("draw",1)}
if(clk("draw")){
for(I=2,269)
{
if(!NewCol){
if(I<64|(I>68&I<76)|(I>82&I<87)){W:egpColor(I,vec(0,153,184))}
if((I>75&I<83)|(I>267&I<270)|(I>107&I<117)){W:egpColor(I,vec(175,175,175))}}
if(NewCol){
if(I<64|(I>68&I<76)|(I>82&I<87)){W:egpColor(I,vec(0,153,154))}}
if((I>75&I<83)|(I>267&I<270)|(I>107&I<117)){W:egpColor(I,vec(175,175,175))}}
for(I=318,353)
{
if(!NewCol){
W:egpColor(I,vec(255,255,255))}
if(NewCol){
W:egpColor(I,vec(208,208,144))}}
for(I=289,303)
{
if(!NewCol){
W:egpColor(I,vec(0,153,184))}
if(NewCol){
W:egpColor(I,vec(0,153,154))}}}
if(Loaded){
if(~Active&!Active){timer("decoding",200) timer("LINE1",180) timer("kvadratiki",150)}
if(clk("LINE1")&!Active){
W:egpPos(271,vec2(328,112+8*A111))
if(A111==19){A211=1}
if(A111==0){A211=0}
if(!A211){A111++}
if(A211){A111--}
timer("LINE1",180)
}
if(Loaded){
if(~Inbound&Inbound){RecirvedCode1=0 Iris1=1}
if(~Inbound&!Inbound){RecirvedCode1=0 GDOStatus=0 Iris1=0 IDCStatus=0 GDOText=""}
if(~RecirvedCode&RecirvedCode1!=RecirvedCode&(RecirvedCode>0&Inbound)){RecirvedCode1=RecirvedCode}
if(~Key&Key==9){RB++ timer("RBTR",200) if(RB==2){timer("shutdown",1) Loaded=-1 RB=0 }}
if(clk("RBTR")&RB>0){RB=0}
if((~Inbound|~RecirvedCode)&RecirvedCode&Inbound){for(I=0,2){
W:egpText(276+I,RRS[I+1,string],vec2(380,167+I*22)) W:egpColor(276+I,vec(62,96,107)) W:egpAlign(276+I,1,1) W:egpFont(276+I,"Marlett",26)
W:egpColor(273,vec(255,255,0))}  W:egpSize(276,26) W:egpRemove(279)} 

if(~Inbound&!RecirvedCode&Inbound){W:egpText(276,"INCOMMING TRAVELER",vec2(380,167)) W:egpSize(276,21) 
W:egpColor(273,vec(255,0,0)) 
W:egpTriangle(277,vec2(347,227),vec2(380,177),vec2(413,227)) W:egpColor(277,vec(255,255,0))
W:egpTriangleOutline(278,vec2(347,227),vec2(380,177),vec2(413,227)) W:egpColor(278,vec(62,96,107)) W:egpSize(278,3)
W:egpText(279,"!",vec2(380,206)) W:egpAlign(279,1,1) W:egpFont(279,"Marlett",50) W:egpColor(279,vec(62,96,107))}

if(((~Inbound|~RecirvedCode)&(!RecirvedCode&!Inbound)|(~RecirvedCode&RecirvedCode>0))|(clk("Loaded"))){for(I=0,7){AA=0 W:egpAlpha(273+I,0)}} 
if(((~Inbound|~RecirvedCode)&(RecirvedCode|Inbound))){for(I=0,7){W:egpAlpha(273+I,255)}}
if(clk("decoding")&!Active){Decoding:shift() Decoding:insertString(20,randint(1,Rand1914):toString()+randint(1,Rand1914):toString()+randint(1,Rand196):toString()) for(I=0,19){W:egpSetText(88+(19-I),Decoding[I+1,string])} timer("decoding",200)}
if(clk("Loaded")|(~RecirvedCode&!RecirvedCode)){E[1,number]=0 for(I=0,98){ if(even(I)==1){E[2+I,number]=random(0,random(10,40))} if(even(I)==0){E[2+I,number]=random(random(-40,-10),0)}} E[99,number]=0}
if(clk("lines2")&E1==99){IDCStatus=2 W:egpSetText(268,"ANALYZING") W:egpSetText(269,"SIGNAL") W:egpAlpha(354,255)}
if(clk("lines")&E1==1){IDCStatus=1 W:egpSetText(268,"INCOMMING") W:egpSetText(269,"SIGNAL")}
if(~RecirvedCode&RecirvedCode&E1<2){timer("lines",1) GDOText="WAIT" GDOStatus=2 timer("STAT",2000)} if(clk("lines")&E1<99&RecirvedCode){E1++ W:egpLine(117+E1,vec2(251+(E1)*2.5425,321+E[E1,number]),vec2(251+(E1+1)*2.5425,321+E[E1+1,number])) W:egpColor(117+E1,vec(255,100,100)) timer("lines",1)}
#if(clk("STAT")){GDOStatus=-1}
if($E1&E1>=98&E1<=100){timer("lines2",100)}
if(clk("lines2")&E1>=99&E1<199&RecirvedCode){E1++ W:egpPos(354,vec2(258+(E1-99)*2.5425,280)) W:egpColor(117+E1-99,vec(255,0,0)) if(E1==198){W:egpAlpha(354,0) AA=1 W:egpSetText(268,"DECODING") W:egpSetText(269,"SIGNAL")} timer("lines2",1)}
if(~RecirvedCode&!RecirvedCode|clk("Loaded")){for(I=0,99){W:egpRemove(117+I) E1=0}}
if(changed(AA)&AA){for(I=0,99){W:egpRemove(117+I)}}
if($AA&AA){timer("cifri",50) for(I=288,303){W:egpAlpha(I,255)}} if(($AA&!AA)|(clk("Loaded"))|(~Inbound&!Inbound)|(~RecirvedCode&RecirvedCode>0)){W:egpSetText(268,"") W:egpSetText(269,"") W:egpAlpha(354,0) EndSymb="" EndSymb2="" CodeStat=0 for(I=288,303){W:egpAlpha(I,0)} for(I=0,13){W:egpSetText(304+I,"")}}
if($CodeStat&!CodeStat|clk("Loaded")){for(I=0,6){W:egpAlpha(281+I,0)}}
if($CodeStat&CodeStat==1){GDOText="ACCEPT" GDOStatus=-1 Iris1=0 IDCStatus=3 IDCName=IDC[RecirvedCode1,array][2,string]
W:egpAlpha(281,255) W:egpColor(281,vec(0,200,0))
W:egpAlpha(282,255) 
W:egpAlpha(283,255) 
W:egpAlpha(286,255) 
W:egpSetText(283,"ACCEPT") W:egpColor(283,vec(0,200,0)) W:egpSize(283,63)
for(I=0,1){W:egpAlpha(284+I,255) W:egpText(284+I,RSR1[I+1,string],vec2(380,167+I*24))}
W:egpText(286,IDC[RecirvedCode1,array][2,string],vec2(380,228))
W:egpAlpha(287,255)}
if($CodeStat&CodeStat==2){GDOText="DENIED" GDOStatus=-1 Iris1=1 IDCStatus=5
W:egpAlpha(281,255) W:egpColor(281,vec(200,0,0))
W:egpAlpha(282,255) 
W:egpAlpha(283,255) 
W:egpSetText(283,"DENIED") W:egpColor(283,vec(200,0,0)) W:egpSize(283,63)
for(I=0,2){W:egpAlpha(284+I,255) W:egpText(284+I,RSR2[I+1,string],vec2(380,167+I*24))}
W:egpAlpha(287,255)}
if($CodeStat&CodeStat==3){GDOText="EXPIRED" GDOStatus=-1 Iris1=1 IDCStatus=4 IDCName=IDC[RecirvedCode1,array][2,string]
W:egpAlpha(281,255) W:egpColor(281,vec(200,100,0))
W:egpAlpha(282,255) 
W:egpAlpha(283,255) 
W:egpAlpha(286,255) 
W:egpSetText(283,"CAUTION") W:egpColor(283,vec(200,100,0)) W:egpSize(283,60)
for(I=0,1){W:egpAlpha(284+I,255) W:egpText(284+I,RSR3[I+1,string],vec2(380,167+I*24))}
W:egpText(286,IDC[RecirvedCode1,array][2,string],vec2(380,228))
W:egpAlpha(287,255)}
#
if(clk("TEXT")){if(CodeStat==1){GDOText="ACCEPT"} if(CodeStat==2){GDOText="DENIED"} if(CodeStat==3){GDOText="EXPIRED"}}
if(clk("kvadratiki")&!Active){for(I=318,351){if(random()>0.5){Alpha1=255}else{Alpha1=0} W:egpAlpha(I,Alpha1)} timer("kvadratiki",150)}
if(clk("cifri")&AA&EndSymb:length()<52){RI=randint(0,15) if(!EndSymb:find("'"+RI:toString()+";")){EndSymb+="'"+RI:toString()+";" W:egpSetText(304+RI,F[RI+1,string]) timer("cifri",30)}else{timer("cifri",1)}} if(EndSymb&EndSymb:length()>52&AA){W:egpSetText(268,"SIGNAL") W:egpSetText(269,"ANALYZED")}
if(~RecirvedCode&RecirvedCode){for(I=0,13){if(I+1<=RecirvedCode1:toString():length()){F[I+1,string]=RecirvedCode1:toString()[I+1]}else{F[I+1,string]="X"}}}
if($AA&AA&EndSymb:length()>=54){if(IDC:exists(RecirvedCode1)){if(IDC[RecirvedCode1,array][1,number]==1){CodeStat=1}else{CodeStat=3}}else{CodeStat=2}}
#if(clk("cifri")&AA&EndSymb2:length()<8){RI2=randint(0,7) if(!EndSymb2:find(RI2:toString())){EndSymb2+=RI2:toString()  W:egpSetText(311+RI2,F[8+RI2,string])}}
if(clk("ircheck")){
if(Iris&!Iris1&!IrisControl){ IrisControl=1 timer("irtg",100) }
if(!Iris&Iris1&!IrisControl){ IrisControl=1 timer("irtg",100) } timer("ircheck",300)}
if(clk("irtg")){ IrisControl=0 }
if(~IrisComp&IrisComp&Iris1&!Irl){Iris1=0 Irl=1 timer("unl",50)}
if(~IrisComp&IrisComp&!Iris1&!Irl){Iris1=1 Irl=1 timer("unl",50)}
if(clk("unl")){Irl=0}
}}
if(clk("errpip")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip1",200)}
if(clk("errpip1")){soundVolume(12,0) soundStop(12,0) timer("errpip2",200)}
if(clk("errpip2")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip3",200)}
if(clk("errpip3")){soundVolume(12,0) soundStop(12,0) timer("errpip4",200)}
if(clk("errpip4")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip5",200)}
if(clk("errpip5")){soundVolume(12,0) soundStop(12,0)}
