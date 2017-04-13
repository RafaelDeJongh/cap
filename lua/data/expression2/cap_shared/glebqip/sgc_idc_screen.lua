# Version 1.6
# Author glebqip(RUS)
# Created 30.11.13 Updated 30.12.13
# This is Stargate IDC Screen from first 2 Stargate-SG1 seasons, called as V1.
# This chip need a wire_expression2_unlimited 1 and wire_egp_max_bytes_per_seconds 13000 on server.
# Support thread: http://sg-carterpack.com/forums/topic/sgc-dialing-computer-v1-e2/

@name SGC IDC Screen v1.0
@inputs EGP:wirelink SG:wirelink IC:wirelink ReceivedCode HideCode Unlink
@outputs True IDCName:string IDCStatus
@persist Active Inbound Iris IrisControl GDOText:string GDOStatus
@persist RAM Pip Load1 IDsOverride LoadOver Loaded Loaded1 RB STD2:string STD STD1 IDs1
@persist A:table B:table C:table D:table E:table F:table Rand196 Rand1914 A1 A2 E1 A111 A211 Stat RRS:table RRS1:table RSR1:table RSR2:table RSR3:table Alpha1 RI RI2 CodeStat AA Decoding:table EndSymb:string EndSymb2:string ReceivedCode1 Iris1 Irl
@persist Start DPL Key KeyUser:entity NewCol IrisDP AAA ETca:entity ETIDca BBB ETdp:entity ETIDdp DPT:table IDC:table GT:gtable GTidc:table
@trigger
findByClass("gmod_wire_expression2")
if(AAA!=2)
{
ETca=findClosest(entity():pos())
ETIDca=ETca:id()
}
#if(changed(ETIDca))
#{
#if(AAA!=2){AAA=0}
#if(BBB!=2){BBB=0}
#}
if(gTable("SIca_"+ETca:id())[1,string]!="SIcav1"){findExcludeEntity(ETca)}
if(gTable("SIca_"+ETca:id())[1,string]=="SIcav1"&!AAA)
{
hint("IDC:Founded a code array with "+ETca:id()+" ID by "+ETca:owner():name()+", press Use to link",10) AAA=1
}
if(changed(owner():keyUse())&gTable("SIca_"+ETca:id())[1,string]=="SIcav1"&owner():keyUse()&AAA==1)
{
hint("IDC:Linked to table with "+ETca:id()+" ID by "+ETca:owner():name(),10) AAA=2 findClearBlackEntityList()
}
if(AAA==2)
{
if(BBB!=2)
{
ETdp=findClosest(entity():pos())
ETIDdp=ETdp:id()
}
if(gTable("DPv1_"+ETdp:id())[1,string]!="DPv1"){findExcludeEntity(ETdp)}
if(gTable("DPv1_"+ETdp:id())[1,string]=="DPv1"&!BBB)
{
hint("IDC:Founded a Dialing Computer Chip with "+ETdp:id()+" ID by "+ETdp:owner():name()+", press Use to link",10) BBB=1
}
if(changed(owner():keyUse())&gTable("DPv1_"+ETdp:id())[1,string]=="DPv1"&owner():keyUse()&BBB==1)
{
hint("IDC:Linked to Dialing Computer Chip with "+ETdp:id()+" ID by "+ETdp:owner():name(),10) BBB=2 findClearBlackEntityList()
}
}
if(~Unlink&Unlink&AAA==2)
{
AAA=0
hint("IDC:Unlinked from IDC table",10)
}
if(~Unlink&Unlink&BBB==2)
{
BBB=0
hint("IDC:Unlinked from Dialing Computer Chip",10)
}
if(BBB==2&ETdp:id()!=0){DPT=gTable("DPv1_"+ETdp:id())[2,table]} if(BBB==2&ETdp:id()==0){hint("IDC:ERROR! Dialing Computer Chip is disappeared! Chip unlinked and shutdowned!",10) Loaded=0 timer("shutdown1",1) BBB=0}
if(AAA==2&ETca:id()!=0){IDC=gTable("SIca_"+ETca:id())[2,table]}
function number even(CHET)
{
if(CHET/2==round(CHET/2)){return 1} else {return 0}
}
#interval(50)
IrisDP=DPT["Iris",number]
NewCol=DPT["NewCol",number]
DPL=DPT["DPL",number]
Start=DPT["Start",number]
Key=DPT["Key",number]
KeyUser=DPT["KeyUser",entity]
Active=SG:stargateGetWire("Active")
Inbound=SG:stargateGetWire("Inbound")
#ReceivedCode=IC:stargateGetWire("Received Code")
Iris=SG:stargateIrisActive()
if(first()|dupefinished()|~IC){IC:stargateSetWire("Don't Auto-Open",1) IC:stargateSetWire("Disable Menu Mode",2)}
if(~EGP&->EGP){reset()}
if(first()|dupefinished()|clk("shutdown1")){EGP:egpClear() Loaded1=0 timer("ircheck",300)}
if(((changed(Start)|first()|dupefinished())&Start)&Loaded1==0)
{
if(Start<=1|Start==3){LoadOver=0}
if(Start==2){LoadOver=1}
RingSpeedMode=1
EGP:egpClear()
for(I=0,9){EGP:egpText(1+I,"",vec2(5,10+I*12)) EGP:egpAlign(1+I,0,1) EGP:egpFont(1+I,"Console",15)}
Load1=0
timer("LD01",randint(100,2000))
Loaded=0
Loaded1=1
}
if(clk("LD01")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("STPS",100) timer("LD1",randint(1000,2500))}
if(clk("STPS")){soundVolume(12,0) soundStop(12,0)}
if(!Loaded&!LoadOver){
if(clk("LD1")){
EGP:egpSetText(1,"Stargate Supercomputer complex") timer("LD2",randint(100,1000))}
if(clk("LD2")){
EGP:egpSetText(2,"CPU:detecting...") timer("LD21",randint(300,600))}
if(clk("LD21")&maxquota()>80000){Pip=0 EGP:egpSetText(2,"CPU:"+maxquota():toString()+" OPS OK!") EGP:egpColor(2,vec(255,255,255)) timer("LD3",randint(150,300))}
if(clk("LD21")&maxquota()<=80000){EGP:egpSetText(2,"CPU:"+maxquota():toString()+" OPS CPU IS TO SLOW TO WORK! WAIT A wire_expression2_unlimited 1") if(!Pip){timer("errpip",1) Pip=1} EGP:egpColor(2,vec(255,0,0)) timer("LD12",100)}
if(clk("LD3")&RAM<ceil(egpMaxObjects()/128)*256){
RAM+=randint(128,512)/10*(egpMaxObjects()/420)
EGP:egpSetText(3,"RAM:"+ceil(RAM)+"MB") timer("LD3",randint(100,200))}
if(clk("LD3")&RAM>=ceil(egpMaxObjects()/128)*256){timer("LD4",1000) EGP:egpSetText(3,"RAM:"+toString(ceil(egpMaxObjects()/128)*256)+" OK!")}
if(clk("LD4")){RAM=0 EGP:egpSetText(4,"GPUSpeed:"+egpMaxUmsgPerSecond():toString()+" BPS OK!") timer("LD5",randint(150,300))}
if(clk("LD5")&Key==-1){
EGP:egpSetText(5,"Error! Keyboard not detected! Waiting keyboard connect.") if(!Pip){timer("errpip",1) Pip=1} EGP:egpColor(5,vec(255,0,0)) timer("LD5",1000)}
if(clk("LD5")&Key!=-1){EGP:egpSetText(5,"Keyboard... OK!") EGP:egpColor(5,vec(255,255,255)) Pip=0 timer("LD6",randint(800,1300))}
if(egpMaxObjects()<420&changed(Key)&(Key==13|Key==10)&IDs1){IDsOverride=1 IDs1=0}
if(clk("LD6")&egpMaxObjects()>=354&!IDsOverride){EGP:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's OK!") EGP:egpColor(6,vec(255,255,255)) timer("LD7",randint(50,300)) Pip=0}
if(clk("LD6")&(egpMaxObjects()<354&IDsOverride)){EGP:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's Override ID's protection!") EGP:egpColor(6,vec(255,255,0)) timer("LD7",randint(50,300)) Pip=0}
if(clk("LD6")&egpMaxObjects()<354&!IDsOverride){IDs1=1 EGP:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's. Need a 196 ID's. Waiting a wire_egp_max_objects 196!") if(!Pip){timer("errpip",1) Pip=1} timer("LD6",150) EGP:egpColor(6,vec(255,0,0))}
if(clk("LD7")&!IDC){if(!Pip){timer("errpip",1) Pip=1} EGP:egpSetText(7,"Can't connect to IDC Codes Database!!!") EGP:egpColor(7,vec(255,0,0)) timer("LD7",100)}
if(clk("LD7")&IDC){Pip=0 EGP:egpSetText(7,"Connected to IDC Code Database") EGP:egpColor(7,vec(255,255,255)) timer("LD8",100)}
if(clk("LD8")&(!->SG|!->ReceivedCode|!->IC))
{EGP:egpSetText(8,"Not connected correctly!!! Waiting...") EGP:egpColor(8,vec(255,0,0)) if(!Pip){timer("errpip",1) Pip=1} timer("LD8",500)}
elseif(clk("LD8")){Pip=0 EGP:egpSetText(8,"Connected correctly!") EGP:egpColor(8,vec(0,255,0)) timer("LD9",randint(200,700))}
if(clk("LD9")){Load1=0 Pip=0 EGP:egpSetText(9,"IDC Computer build 1.241.15 v1 07.12.13 is loading...") EGP:egpColor(9,vec(255,255,255)) timer("LD91",randint(100,1000))}
if(clk("LD91")&Loaded!=1&Load1<100){Load1+=randint(4,12) EGP:egpSetText(9,"IDC Computer build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD91",randint(100,300))}
if(Load1>=100){EGP:egpSetText(9,"IDC Computer build 1.241.15 v1 07.12.13 is loading... 100%") if(DPL){timer("Loaded",randint(50,700))}else{timer("LD92",randint(100,300))}}
if(clk("LD92")&!DPL&DPT:count()>0){if(!Pip){timer("errpip",1) Pip=1} EGP:egpSetText(10,"Waiting Dialing Programm...") EGP:egpColor(10,vec(255,255,0)) timer("LD92",100)}
if(clk("LD92")&(DPL|DPT:count()==0)){Pip=0 timer("Loaded",randint(50,700))}}
if(!Loaded&LoadOver){
if(clk("LD1")){Load1=0 soundVolume(12,0) soundStop(12,0.001) EGP:egpSetText(1,"IDC Computer build 1.241.15 v1 07.12.13 is loading...") EGP:egpColor(1,vec(255,255,255)) timer("LD11",randint(100,1000))}
if(clk("LD11")&Loaded!=1&Load1<100){Load1+=randint(4,12) EGP:egpSetText(1,"IDC Computer build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD11",randint(100,300))}
if(Load1>=100){EGP:egpSetText(1,"IDC Computer build 1.241.15 v1 07.12.13 is loading... 100%") timer("Loaded",randint(50,700))}}
if(clk("shutdown")){
STD1=randint(30,80)
EGP:egpClear()
STD2=""
STD=0
EGP:egpText(1,"",vec2(5,10)) EGP:egpAlign(1,0,1) EGP:egpFont(1,"Console",15)
timer("STD1",randint(50,500))}
if(clk("STD1")&STD<=STD1){STD2+="." if(STD2:length()>3){STD2=""} EGP:egpSetText(1,"Shutting down"+STD2) STD++ timer("STD1",150)}
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
EGP:egpClear()
EGP:egpDrawTopLeft(1)
#EGP:egpBox(1,vec2(0,81),vec2(512,350)) EGP:egpMaterial(1,"idc1")
EGP:egpBoxOutline(2,vec2(1,83),vec2(243,349))
EGP:egpLine(3,vec2(1,97),vec2(242,97))
EGP:egpBoxOutline(4,vec2(247,83),vec2(264,191))
EGP:egpBox(5,vec2(247,84),vec2(72,59))
EGP:egpBoxOutline(6,vec2(325,97),vec2(178,176))
for(I=0,2){EGP:egpBoxOutline(7+I,vec2(252,217+I*19),vec2(70,15))}
EGP:egpBoxOutline(10,vec2(247,277),vec2(264,154))
EGP:egpBoxOutline(11,vec2(250,280),vec2(258,86))
for(I=0,2){EGP:egpBoxOutline(12+I,vec2(4,284+I*18),vec2(80,16))}
for(I=0,3){EGP:egpBoxOutline(15+I,vec2(4+I*60,415),vec2(56,12))}
EGP:egpBoxOutline(19,vec2(4,337),vec2(80,76))
EGP:egpLine(20,vec2(6,346),vec2(6,349))
EGP:egpLine(21,vec2(6,398),vec2(6,401))
EGP:egpLine(22,vec2(81,346),vec2(81,349))
EGP:egpLine(23,vec2(81,398),vec2(81,401))
EGP:egpLine(24,vec2(22,338),vec2(31,338))
EGP:egpLine(25,vec2(57,338),vec2(66,338))
EGP:egpLine(26,vec2(22,410),vec2(31,410))
EGP:egpLine(27,vec2(57,410),vec2(66,410))
EGP:egpLine(28,vec2(27,338),vec2(27,346))
EGP:egpLine(29,vec2(61,338),vec2(61,346))
EGP:egpLine(30,vec2(27,403),vec2(27,410))
EGP:egpLine(31,vec2(61,403),vec2(61,410))
#
EGP:egpLine(32,vec2(19,346),vec2(34,346))
EGP:egpLine(33,vec2(34,346),vec2(42,354))
EGP:egpLine(34,vec2(42,354),vec2(42,364))
EGP:egpLine(35,vec2(42,364),vec2(34,372))
EGP:egpLine(36,vec2(34,372),vec2(19,372))
EGP:egpLine(37,vec2(19,372),vec2(11,364))
EGP:egpLine(38,vec2(11,364),vec2(11,354))
EGP:egpLine(39,vec2(11,354),vec2(19,346))
#
EGP:egpLine(40,vec2(54,346),vec2(69,346))
EGP:egpLine(41,vec2(69,346),vec2(77,354))
EGP:egpLine(42,vec2(77,354),vec2(77,364))
EGP:egpLine(43,vec2(77,364),vec2(69,372))
EGP:egpLine(44,vec2(69,372),vec2(54,372))
EGP:egpLine(45,vec2(54,372),vec2(46,364))
EGP:egpLine(46,vec2(46,364),vec2(46,354))
EGP:egpLine(47,vec2(46,354),vec2(54,346))
#
EGP:egpLine(48,vec2(19,376),vec2(34,376))
EGP:egpLine(49,vec2(34,376),vec2(42,384))
EGP:egpLine(50,vec2(42,384),vec2(42,394))
EGP:egpLine(51,vec2(42,394),vec2(34,402))
EGP:egpLine(52,vec2(34,402),vec2(19,402))
EGP:egpLine(53,vec2(19,402),vec2(11,394))
EGP:egpLine(54,vec2(11,394),vec2(11,384))
EGP:egpLine(55,vec2(11,384),vec2(19,376))
#
EGP:egpLine(56,vec2(54,376),vec2(69,376))
EGP:egpLine(57,vec2(69,376),vec2(77,384))
EGP:egpLine(58,vec2(77,384),vec2(77,394))
EGP:egpLine(59,vec2(77,394),vec2(69,402))
EGP:egpLine(60,vec2(69,402),vec2(54,402))
EGP:egpLine(61,vec2(54,402),vec2(46,394))
EGP:egpLine(62,vec2(46,394),vec2(46,384))
EGP:egpLine(63,vec2(46,384),vec2(54,376))
for(I=0,4){EGP:egpBox(64+I,vec2(89,360+I*11),vec2(10,8)) EGP:egpColor(64+I,vec(50+I*51,255-I*51,20))}
EGP:egpText(69,"GATE INTEGRITY MONITOR",vec2(121,90)) EGP:egpAlign(69,1,1) EGP:egpFont(69,"Marlett",20)
for(I=0,2){EGP:egpText(70+I,A[I+1,string],vec2(43,292+I*18)) EGP:egpAlign(70+I,1,1) EGP:egpFont(70+I,"Marlett",11)}
for(I=0,2){EGP:egpText(73+I,B[I+1,string],vec2(284,224+I*19)) EGP:egpAlign(73+I,1,1) EGP:egpFont(73+I,"Marlett",11)}
EGP:egpText(76,"SIGNAL DATA",vec2(375,90)) EGP:egpAlign(76,1,1) EGP:egpFont(76,"Marlett",18)
EGP:egpText(77,"DECODING",vec2(358,104)) EGP:egpAlign(77,1,1) EGP:egpFont(77,"Marlett",11)
for(I=0,4){EGP:egpText(78+I,C[I+1,string],vec2(102,364+I*11)) EGP:egpAlign(78+I,0,1) EGP:egpFont(78+I,"Marlett",8)}
for(I=0,3){EGP:egpText(83+I,D[I+1,string],vec2(30+I*60,422)) EGP:egpAlign(83+I,1,1) EGP:egpFont(83+I,"Marlett",11)}
for(I=0,19){EGP:egpText(88+I,"",vec2(329,114+I*8)) EGP:egpAlign(88+I,0,1) EGP:egpFont(88+I,"Marlett",8) EGP:egpColor(88+I,vec(175,175,175))}
for(I=0,8){EGP:egpText(108+I,toString(round(random(1,Rand1914))),vec2(251,146+I*8)) EGP:egpAlign(108+I,0,1) EGP:egpFont(108+I,"Marlett",8)}
EGP:egpText(268,"ANALYSING",vec2(375,384)) EGP:egpAlign(268,1,1) EGP:egpFont(268,"Marlett",30)
EGP:egpText(269,"SIGNAL",vec2(375,412)) EGP:egpAlign(269,1,1) EGP:egpFont(269,"Marlett",30)
EGP:egpBox(271,vec2(328,112),vec2(172,7))
EGP:egpMaterial(271,"gui/center_gradient")
EGP:egpColor(271,vec(0,255,0))
#EGP:egpBox(272,vec2(414,111),vec2(172,6))
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
EGP:egpBoxOutline(273,vec2(248,82),vec2(264,192)) EGP:egpSize(273,12) EGP:egpColor(273,vec(255,255,0))
EGP:egpBox(274,vec2(260,94),vec2(240,168)) EGP:egpColor(274,vec(202,235,246))
EGP:egpText(275,"CAUTION",vec2(380,131)) EGP:egpColor(275,vec(255,0,0)) EGP:egpAlign(275,1,1) EGP:egpFont(275,"Marlett",40)
for(I=0,2){EGP:egpText(276+I,RRS[I+1,string],vec2(380,167+I*22)) EGP:egpColor(276+I,vec(62,96,107)) EGP:egpAlign(276+I,1,1) EGP:egpFont(276+I,"Marlett",26)}
EGP:egpTriangleOutline(278,vec2(347,227),vec2(380,177),vec2(413,227)) EGP:egpColor(278,vec(62,96,107)) EGP:egpSize(278,3)
EGP:egpText(280,"877032-333-0",vec2(379,241)) EGP:egpColor(280,vec(62,96,107)) EGP:egpAlign(280,1,1) EGP:egpFont(280,"Marlett",18)
EGP:egpBox(288,vec2(251,281),vec2(256,84)) EGP:egpColor(288,vec(0,0,0))
EGP:egpText(289,"SIGNAL CODE RESPONSE",vec2(343,288)) EGP:egpColor(289,vec(255,0,0)) EGP:egpAlign(289,1,1) EGP:egpFont(289,"Marlett",17)
for(I=0,6){EGP:egpBoxOutline(290+I,vec2(255+I*36,296),vec2(30,30))}
for(I=0,6){EGP:egpBoxOutline(297+I,vec2(255+I*36,331),vec2(30,30))}
for(I=0,6){EGP:egpText(304+I,"",vec2(270+I*36,311)) EGP:egpAlign(304+I,1,1) EGP:egpFont(304+I,"Marlett",30) EGP:egpColor(304+I,vec(0,255,0))}
for(I=0,6){EGP:egpText(311+I,"",vec2(270+I*36,346)) EGP:egpAlign(311+I,1,1) EGP:egpFont(311+I,"Marlett",30) EGP:egpColor(311+I,vec(0,255,0))}
for(I=0,2){EGP:egpBox(318+I,vec2(20,353+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(321+I,vec2(26,353+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(324+I,vec2(32,353+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(327+I,vec2(56,353+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(330+I,vec2(62,353+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(333+I,vec2(68,353+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(336+I,vec2(20,383+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(339+I,vec2(26,383+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(342+I,vec2(32,383+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(345+I,vec2(56,383+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(348+I,vec2(62,383+I*6),vec2(3,3))}
for(I=0,2){EGP:egpBox(351+I,vec2(68,383+I*6),vec2(3,3))}
EGP:egpBox(354,vec2(258,280),vec2(86,7))
EGP:egpAngle(354,-90)
EGP:egpMaterial(354,"gui/center_gradient")
EGP:egpColor(354,vec(0,255,0))
EGP:egpBoxOutline(281,vec2(248,82),vec2(264,192)) EGP:egpSize(281,12) EGP:egpColor(281,vec(0,200,0))
EGP:egpBox(282,vec2(260,94),vec2(240,168)) EGP:egpColor(282,vec(202,235,246))
EGP:egpText(283,"ACCEPT",vec2(380,121)) EGP:egpColor(283,vec(0,200,0)) EGP:egpAlign(283,1,1) EGP:egpFont(283,"Marlett",63)
for(I=0,1){EGP:egpText(284+I,RSR1[I+1,string],vec2(380,167+I*24)) EGP:egpColor(284+I,vec(28,78,83)) EGP:egpAlign(284+I,1,1) EGP:egpFont(284+I,"Marlett",26)}
EGP:egpText(286,IDC[ReceivedCode1,array][2,string],vec2(380,228)) EGP:egpColor(286,vec(28,78,83)) EGP:egpAlign(286,1,1) EGP:egpFont(286,"Marlett",26)
EGP:egpText(287,"AUTH#   32-333-0",vec2(379,252)) EGP:egpColor(287,vec(62,96,107)) EGP:egpAlign(287,1,1) EGP:egpFont(287,"Marlett",18)
timer("draw",1)
}
if(changed(NewCol)){timer("draw",1)}
if(clk("draw")){
for(I=2,269)
{
if(!NewCol){
if(I<64|(I>68&I<76)|(I>82&I<87)){EGP:egpColor(I,vec(0,153,184))}
if((I>75&I<83)|(I>267&I<270)|(I>107&I<117)){EGP:egpColor(I,vec(175,175,175))}}
if(NewCol){
if(I<64|(I>68&I<76)|(I>82&I<87)){EGP:egpColor(I,vec(0,153,154))}}
if((I>75&I<83)|(I>267&I<270)|(I>107&I<117)){EGP:egpColor(I,vec(175,175,175))}}
for(I=318,353)
{
if(!NewCol){
EGP:egpColor(I,vec(255,255,255))}
if(NewCol){
EGP:egpColor(I,vec(208,208,144))}}
for(I=289,303)
{
if(!NewCol){
EGP:egpColor(I,vec(0,153,184))}
if(NewCol){
EGP:egpColor(I,vec(0,153,154))}}}
if(Loaded==1){
if($Active&!Active){timer("decoding",200) timer("LINE1",180)}
if(clk("LINE1")&!Active){
EGP:egpPos(271,vec2(328,112+8*A111))
if(A111==19){A211=1}
if(A111==0){A211=0}
if(!A211){A111++}
if(A211){A111--}
timer("LINE1",180)
}
if(Loaded==1){
if($Inbound&Inbound){EGP:entity():soundPlay(122,1,"alexalx/glebqip/idc_incomming.wav") ReceivedCode1=0 Iris1=1}
if(($Inbound&!Inbound)|clk("Loaded")){for(I=288,303){EGP:egpAlpha(I,255)} ReceivedCode1=0 GDOStatus=0 Iris1=0 IDCStatus=0 GDOText=""}
if(~ReceivedCode&ReceivedCode1!=ReceivedCode&(ReceivedCode>0&Inbound)){ReceivedCode1=ReceivedCode}
if(changed(Key)&Key==9&(KeyUser==owner())){RB++ timer("RBTR",500) if(RB==2){timer("shutdown",1) Loaded=-1 RB=0 }}
if(clk("RBTR")&RB>0){RB=0}
if(($Inbound|~ReceivedCode)&ReceivedCode&Inbound){for(I=0,2){
EGP:egpText(276+I,RRS[I+1,string],vec2(380,167+I*22)) EGP:egpColor(276+I,vec(62,96,107)) EGP:egpAlign(276+I,1,1) EGP:egpFont(276+I,"Marlett",26)
EGP:egpColor(273,vec(255,255,0))}  EGP:egpSize(276,26) EGP:egpRemove(279)}

if($Inbound&!ReceivedCode&Inbound){EGP:egpText(276,"INCOMMING TRAVELER",vec2(380,167)) EGP:egpSize(276,21)
EGP:egpColor(273,vec(255,0,0))
EGP:egpTriangle(277,vec2(347,227),vec2(380,177),vec2(413,227)) EGP:egpColor(277,vec(255,255,0))
EGP:egpTriangleOutline(278,vec2(347,227),vec2(380,177),vec2(413,227)) EGP:egpColor(278,vec(62,96,107)) EGP:egpSize(278,3)
EGP:egpText(279,"!",vec2(380,206)) EGP:egpAlign(279,1,1) EGP:egpFont(279,"Marlett",50) EGP:egpColor(279,vec(62,96,107))}

if((($Inbound|~ReceivedCode)&(!ReceivedCode&!Inbound)|(~ReceivedCode&ReceivedCode>0))|(clk("Loaded"))){for(I=0,7){AA=0 EGP:egpAlpha(273+I,0)}}
if((($Inbound|~ReceivedCode)&(ReceivedCode|Inbound))){for(I=0,7){EGP:egpAlpha(273+I,255)}}
if(clk("decoding")&!Active){Decoding:shift() Decoding:insertString(20,randint(1,Rand1914):toString()+randint(1,Rand1914):toString()+randint(1,Rand196):toString()) for(I=0,19){EGP:egpSetText(88+(19-I),Decoding[I+1,string])} timer("decoding",200)}
if(clk("Loaded")|(~ReceivedCode&!ReceivedCode)){E[1,number]=0 for(I=0,98){ if(even(I)==1){E[2+I,number]=random(0,random(10,40))} if(even(I)==0){E[2+I,number]=random(random(-40,-10),0)}} E[99,number]=0}
if(clk("lines2")&E1==99){IDCStatus=2 EGP:entity():soundPlay(122,1,"alexalx/glebqip/idc_start.wav") EGP:egpSetText(268,"ANALYZING") EGP:egpSetText(269,"SIGNAL") EGP:egpAlpha(354,255)}
if(clk("lines")&E1==1){for(I=288,303){EGP:egpAlpha(I,0)} IDCStatus=1 EGP:entity():soundPlay(122,1,"alexalx/glebqip/idc_incomming.wav") EGP:egpSetText(268,"INCOMMING") EGP:egpSetText(269,"SIGNAL")}
if(~ReceivedCode&ReceivedCode&E1<2){timer("lines",1) GDOText="WAIT" GDOStatus=2 timer("STAT",2000)} if(clk("lines")&E1<99&ReceivedCode){E1++ EGP:egpLine(117+E1,vec2(251+(E1)*2.5425,321+E[E1,number]),vec2(251+(E1+1)*2.5425,321+E[E1+1,number])) EGP:egpColor(117+E1,vec(255,100,100)) timer("lines",1)}
#if(clk("STAT")){GDOStatus=-1}
if($E1&E1>=98&E1<=100){timer("lines2",100)}
if(clk("lines2")&E1>=99&E1<199&ReceivedCode){E1++ EGP:egpPos(354,vec2(258+(E1-99)*2.5425,280)) EGP:egpColor(117+E1-99,vec(255,0,0)) if(E1==198){EGP:egpAlpha(354,0) AA=1 EGP:egpSetText(268,"DECODING") EGP:egpSetText(269,"SIGNAL")} timer("lines2",1)}
if(~ReceivedCode&!ReceivedCode|clk("Loaded")){for(I=0,99){EGP:egpRemove(117+I) E1=0}}
if(changed(AA)&AA){for(I=0,99){EGP:egpRemove(117+I)}}
if($AA&AA){timer("cifri",50) for(I=288,303){EGP:egpAlpha(I,255)}} if(($AA&!AA)|(clk("Loaded"))|($Inbound&!Inbound)|(~ReceivedCode&ReceivedCode>0)){EGP:egpSetText(268,"") EGP:egpSetText(269,"") EGP:egpAlpha(354,0) EndSymb="" EndSymb2="" CodeStat=0 for(I=0,13){EGP:egpSetText(304+I,"")}}
if($CodeStat&!CodeStat|clk("Loaded")){for(I=0,6){EGP:egpAlpha(281+I,0)}}
if($CodeStat&CodeStat==1){GDOText="ACCEPT" EGP:entity():soundPlay(122,1,"alexalx/glebqip/idc_accept.wav") GDOStatus=-1 Iris1=0 IDCStatus=3 IDCName=IDC[ReceivedCode1,array][2,string]
EGP:egpAlpha(281,255) EGP:egpColor(281,vec(0,200,0))
EGP:egpAlpha(282,255)
EGP:egpAlpha(283,255)
EGP:egpAlpha(286,255)
EGP:egpSetText(283,"ACCEPT") EGP:egpColor(283,vec(0,200,0)) EGP:egpSize(283,63)
for(I=0,1){EGP:egpAlpha(284+I,255) EGP:egpText(284+I,RSR1[I+1,string],vec2(380,167+I*24))}
EGP:egpText(286,IDC[ReceivedCode1,array][2,string],vec2(380,228))
EGP:egpAlpha(287,255)}
if($CodeStat&CodeStat==2){GDOText="DENIED" EGP:entity():soundPlay(122,1,"alexalx/glebqip/idc_error.wav") GDOStatus=-1 Iris1=1 IDCStatus=5
EGP:egpAlpha(281,255) EGP:egpColor(281,vec(200,0,0))
EGP:egpAlpha(282,255)
EGP:egpAlpha(283,255)
EGP:egpSetText(283,"DENIED") EGP:egpColor(283,vec(200,0,0)) EGP:egpSize(283,63)
for(I=0,2){EGP:egpAlpha(284+I,255) EGP:egpText(284+I,RSR2[I+1,string],vec2(380,167+I*24))}
EGP:egpAlpha(287,255)}
if($CodeStat&CodeStat==3){GDOText="EXPIRED" EGP:entity():soundPlay(122,1,"alexalx/glebqip/idc_error.wav") GDOStatus=-1 Iris1=1 IDCStatus=4 IDCName=IDC[ReceivedCode1,array][2,string]
EGP:egpAlpha(281,255) EGP:egpColor(281,vec(200,100,0))
EGP:egpAlpha(282,255)
EGP:egpAlpha(283,255)
EGP:egpAlpha(286,255)
EGP:egpSetText(283,"WARNING") EGP:egpColor(283,vec(200,100,0)) EGP:egpSize(283,58)
for(I=0,1){EGP:egpAlpha(284+I,255) EGP:egpText(284+I,RSR3[I+1,string],vec2(380,167+I*24))}
EGP:egpText(286,IDC[ReceivedCode1,array][2,string],vec2(380,228))
EGP:egpAlpha(287,255)}
#
if(clk("kvadratiki")){if(!Active){for(I=318,351){if(random()>0.5){Alpha1=255}else{Alpha1=0} EGP:egpAlpha(I,Alpha1)}} timer("kvadratiki",150)}
if(clk("cifri")&AA&EndSymb:length()<52&Inbound){RI=randint(0,15) if(!EndSymb:find("'"+RI:toString()+";")){EndSymb+="'"+RI:toString()+";" EGP:egpSetText(304+RI,F[RI+1,string]) timer("cifri",30)}else{timer("cifri",1)}} if(EndSymb&EndSymb:length()>52&AA){EGP:egpSetText(268,"SIGNAL") EGP:egpSetText(269,"ANALYZED")}
if(~ReceivedCode&ReceivedCode){if(!HideCode){for(I=0,13){if(I+1<=ReceivedCode1:toString():length()){F[I+1,string]=ReceivedCode1:toString()[I+1]}else{F[I+1,string]="X"}}}
if(HideCode){for(I=0,13){F[I+1,string]="X"}}}
if($AA&AA&EndSymb:length()>=54){if(IDC:exists(ReceivedCode1)){if(IDC[ReceivedCode1,array][1,number]==1){CodeStat=1}else{CodeStat=3}}else{CodeStat=2}}
#if(clk("cifri")&AA&EndSymb2:length()<8){RI2=randint(0,7) if(!EndSymb2:find(RI2:toString())){EndSymb2+=RI2:toString()  EGP:egpSetText(311+RI2,F[8+RI2,string])}}
if(clk("ircheck")){
if(Iris&!Iris1){SG:stargateIrisToggle()}
if(!Iris&Iris1){SG:stargateIrisToggle()}
timer("ircheck",150)}
if(clk("irtg")){ IrisControl=0 }
if(changed(IrisDP)&IrisDP&Iris1&!Irl){Iris1=0 Irl=1 timer("unl",50)}
if(changed(IrisDP)&IrisDP&!Iris1&!Irl){Iris1=1 Irl=1 timer("unl",50)}
if(clk("unl")){Irl=0}
}
}
else
{
if(clk("ircheck")){
if(!Iris){SG:stargateIrisToggle()}
timer("ircheck",150)}
GDOText="OFFLINE" GDOStatus=-1
if(clk("irtg")){ IrisControl=0 }}
if(clk("errpip")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip1",200)}
if(clk("errpip1")){soundVolume(12,0) soundStop(12,0) timer("errpip2",200)}
if(clk("errpip2")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip3",200)}
if(clk("errpip3")){soundVolume(12,0) soundStop(12,0) timer("errpip4",200)}
if(clk("errpip4")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip5",200)}
if(clk("errpip5")){soundVolume(12,0) soundStop(12,0)}
IC:stargateSetWire("GDO Status",GDOStatus)
IC:stargateSetWire("GDO Text",GDOText)
GT=gTable("IDCsv1_"+entity():id())
GT[1,string]="IDCsv1"
GTidc["IDCStatus",number]=IDCStatus
GTidc["IDCName",string]=IDCName
GT[2,table]=GTidc
#hint("GDO Status:"+GDOStatus+"/GDO Text:"+GDOText,1)