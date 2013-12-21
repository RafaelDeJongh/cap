# Version 1.5
# Author glebqip(RUS)
# Created 23.11.13 Updated 20.12.13
# This is Stargate Dialing Computer from first 2 Stargate-SG1 seasons, called as V1.
# This chip need a wire_expression2_unlimited 1, wire_egp_max_bytes_per_seconds 13000 and wire_egp_max_objects 440 on server.
# Support thread: http://sg-carterpack.com/forums/topic/sgc-dialing-computer-v1-e2/

@name SGC Dialing Computer v1.0
@inputs  Start W:wirelink SG:wirelink NewCol AnotherSound Key KeyUser:entity AddressBook:string
@outputs DPL True Iris Overload
@persist ANG I1 I2 Min Linked Painted ETO Time OvMin:string OvSec:string OvPercent
@persist RAM RAMM:string Load1 Pip IDs1 IDsOverride RingDiag RB DiagOver LoadOver RBT Loaded1 STD STD1 STD2:string
@persist DialString:string DialingMode StartStringDial Close RotateRing RingSpeedMode ActivateChevronNumbers:string
@persist Active Open Inbound Chevron ChevronLocked RingSymbol:string RingRotation DialingAdress:string DialMode DialingSymbol:string DialedSymbol:string
@persist RingStopCheck AdrBlock Loaded Unstable Cond Cond2 Alpha2 Color DTL Chev2 DialingAdress1:string Chevron1 Alpha3 B1 Chev AN1 Alpha4 Alpha5 G1 G2 G3 G4 G5 G6 G7 G8 G9  Q B C D EnteredAdress:string ChrA:string Correct DSMB Chevr8 Chevr9 DType:table RandNum:table EAn
@persist CHKRM RingAngle AA1 Text1:table Text2:table Text1pos:table Text2pos:table Text1col:table Text2col:table Text1size:table Text2size:table A112:string Col1:vector
@trigger
if(~W&->W){reset()}
if(first()|dupefinished()|clk("shutdown1")){W:egpClear() Loaded1=0}
if(first()|dupefinished()|~SG){SG:stargateSetWire("SGC Type",1) SG:stargateSetWire("Set Point of Origin",1)}
function number even(CHET)
{
if(CHET%2!=0){return 1} else {return 0}
}
Active=SG:stargateGetWire("Active")
Open=SG:stargateGetWire("Open")
Inbound=SG:stargateGetWire("Inbound")
Chevron=SG:stargateGetWire("Chevron")
ChevronLocked=SG:stargateGetWire("Chevron Locked")
RingSymbol=SG:stargateGetWireString("Ring Symbol")
RingRotation=SG:stargateGetWire("Ring Rotation")
DialingAdress=SG:stargateGetWireString("Dialing Address")
DialingSymbol=SG:stargateGetWireString("Dialing Symbol")
DialedSymbol=SG:stargateGetWireString("Dialed Symbol")
DialMode=SG:stargateGetWire("Dialing Mode")
##Startup simulating
#30000
if(Loaded!=2){
if((($Start|first()|dupefinished())&Start)&Loaded1==0)
{
DPL=0
if(Start<=1&!RBT){DiagOver=0 LoadOver=0}
if(Start==3&!RBT){DiagOver=1 LoadOver=0}
if(Start==2){DiagOver=1 LoadOver=1}
if(RBT&Start!=2){DiagOver=1 LoadOver=0}
RingSpeedMode=1
W:egpClear()
for(I=0,8){W:egpText(1+I,"",vec2(5,10+I*12)) W:egpAlign(1+I,0,1) W:egpFont(1+I,"Console",15)}
timer("LD01",randint(100,2000))
Loaded=0
Loaded1=1
}
if(Loaded==0){
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
RAM+=randint(128,512)/10*(egpMaxObjects()/440)
W:egpSetText(3,"RAM:"+ceil(RAM)+"MB") timer("LD3",randint(100,200))}
if(clk("LD3")&RAM>=ceil(egpMaxObjects()/128)*256){timer("LD4",1000) W:egpSetText(3,"RAM:"+toString(ceil(egpMaxObjects()/128)*256)+" OK!")}
if(clk("LD4")){W:egpSetText(4,"GPUSpeed:"+egpMaxUmsgPerSecond():toString()+" BPS OK!") timer("LD5",randint(150,300))}
if(clk("LD5")&!->Key){
W:egpSetText(5,"Error! Keyboard not detected! Waiting keyboard connect.") if(!Pip){timer("errpip",1) Pip=1} W:egpColor(5,vec(255,0,0)) timer("LD5",1000)}
if(clk("LD5")&->Key){W:egpSetText(5,"Keyboard... OK!") W:egpColor(5,vec(255,255,255)) Pip=0 timer("LD6",randint(800,1300))}
if(egpMaxObjects()<440&~Key&Key==13&IDs1){IDsOverride=1 IDs1=0}
if(clk("LD6")&egpMaxObjects()>=440&!IDsOverride){W:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's OK!") W:egpColor(6,vec(255,255,255)) timer("LD7",randint(150,300)) Pip=0}
if(clk("LD6")&(egpMaxObjects()<440&IDsOverride)){W:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's Override ID's protection!") W:egpColor(6,vec(255,255,0)) timer("LD7",randint(50,300)) Pip=0}
if(clk("LD6")&egpMaxObjects()<440&!IDsOverride){IDs1=1 W:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's. Need a 440 ID's. Waiting a wire_egp_max_objects 440!") if(!Pip){timer("errpip",1) Pip=1} timer("LD6",150) W:egpColor(6,vec(255,0,0))}
if(!DiagOver){
if(clk("LD7")){RAM=0 W:egpSetText(7,"open diagnostic.str") timer("LD8",3000)}
if(clk("LD8")){ W:egpSetText(8,"Diagnostic Programm build 1.241.15 v1 07.12.13 is loading...") timer("LD9",randint(100,300))}
if(clk("LD9")&Load1<100){Load1+=randint(4,12) W:egpSetText(8,"Diagnostic Programm build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD9",randint(50,700))}}
if(Load1>=100){Load1=0 W:egpSetText(8,"Diagnostic Programm build 1.241.15 v1 07.12.13 is loading... 100%") Loaded=1 timer("Loaded1",randint(50,700))}}
if(!Loaded&DiagOver){
if(clk("LD7")){RAM=0 W:egpSetText(7,"open dialingprogramm.str") timer("LD8",3000)}
if(clk("LD8")){ W:egpSetText(8,"Dialing Programm build 1.241.15 v1 07.12.13 is loading...") timer("LD9",randint(100,300))}
if(clk("LD9")&Load1<100){Load1+=randint(4,12) W:egpSetText(8,"Dialing Programm build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD9",randint(50,700))}
if(Load1>=100){Load1=0 W:egpSetText(8,"Dialing Programm build 1.241.15 v1 07.12.13 is loading... 100%") Loaded=2 timer("Loaded",randint(50,700))}}
if(!Loaded&LoadOver){
if(clk("LD1")){W:egpSetText(1,"Dialing Programm build 1.241.15 v1 07.12.13 is loading...") timer("LD11",randint(100,300))}
if(clk("LD11")&Loaded!=2&Load1<100){Load1+=randint(4,12) W:egpSetText(1,"Dialing Programm build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD11",randint(50,700))}
if(Load1>=100){Load1=0 W:egpSetText(1,"Dialing Programm build 1.241.15 v1 07.12.13 is loading... 100%") Loaded=2 timer("Loaded",randint(50,700))}}}
##/startup simulating
##diag
if(Loaded==1){
if(clk("Loaded1")){
W:egpClear()
for(I=0,4){W:egpText(1+I,"",vec2(5,10+I*12)) W:egpAlign(1+I,0,1) W:egpFont(1+I,"Console",15)}
timer("DG1",500)}
if(clk("DG1")){W:egpSetText(1,"Diangonstic...") W:egpColor(1,vec(0,255,0)) timer("DG2",randint(200,600))}
#if(clk("DG2")&(!->ActivateChevronNumbers|!->SG|!->RotateRing|!->DialString|!->StartStringDial|!->Close|!->DialingMode|!->Active|!->Open|!->Inbound|!->Chevron|!->ChevronLocked|!->RingRotation|!->DialMode|!->RingSymbol|!->DialingAdress|!->DialingSymbol|!->DialedSymbol))
#{W:egpSetText(2,"Not connected correctly to stargate!!! Waiting...") W:egpColor(2,vec(255,0,0)) if(!Pip){timer("errpip",1) Pip=1} timer("DG2",500)}
elseif(clk("DG2")){Pip=0 W:egpSetText(2,"Connected to stargate! Starting diagnostic...") W:egpColor(2,vec(0,255,0)) timer("DG3",randint(200,700))}
if(clk("DG3")&RingDiag!=2&RingDiag!=11){W:egpSetText(3,"Ring diagnostic") RotateRing=1 W:egpColor(3,vec(255,255,255)) timer("DG31",10) if(RingRotation){RingDiag=11}else{RingDiag=1} timer("RDG",500)}
if(clk("RDG")&RingDiag!=2&(RingDiag==11|RotateRing)){RingDiag=11 if(Active){RotateRing=0}else{RotateRing=1} timer("RDG",100)}
if(clk("DG31")&!RingRotation&RingDiag!=2&RingDiag!=11){RingDiag=12 W:egpSetText(3,"Ring is blocked! Maybe not enough energy!") if(!Pip){timer("errpip",1) Pip=1 RingDiag=0} RotateRing++ if(RotateRing>=2){RotateRing=0} W:egpColor(3,vec(255,0,0)) timer("DG31",500)}
if(clk("DG31")&RingRotation&RingDiag!=2&RingDiag!=11){timer("DG3",10)}
if(RingDiag==11&RingRotation&RingSymbol=="#"){RingDiag=2 W:egpSetText(3,"Ring diagnostic OK!") W:egpColor(3,vec(0,255,0)) RingDiag=2 RotateRing=0 timer("DG4",randint(500,2500))}
if(clk("DG4")){W:egpSetText(4,"Chevron diagnostic") W:egpColor(4,vec(255,255,255)) ActivateChevronNumbers="" RotateRing=1 timer("DG41",randint(500,2500))}
if(clk("DG41")&RingDiag!=22&ActivateChevronNumbers!="1111111111"){ActivateChevronNumbers=ActivateChevronNumbers+"1" timer("DG41",randint(500,1500))}
if(clk("DG41")&ActivateChevronNumbers=="1111111111"){W:egpSetText(4,"Chevron diagnostic OK!") W:egpColor(4,vec(0,255,0)) ActivateChevronNumbers="" RotateRing=0 timer("DG5",randint(500,2500)) RingDiag=22}
if(clk("DG5")){ W:egpSetText(5,"Dialing Programm build 1.241.15 v1 07.12.13 is loading...") timer("DG51",randint(100,300))}
if(clk("DG51")&Loaded!=2&Load1<100){Load1+=randint(4,12) W:egpSetText(5,"Dialing Programm build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("DG51",randint(50,700))}
if(Load1>=100){Load1=0 W:egpSetText(5,"Dialing Programm build 1.241.15 v1 07.12.13 is loading... 100%") Loaded=2 timer("Loaded",randint(50,700))}}}
if(clk("shutdown")){
STD1=randint(30,80)
W:egpClear()
STD2=""
STD=0
W:egpText(1,"",vec2(5,10)) W:egpAlign(1,0,1) W:egpFont(1,"Console",15)
timer("STD1",randint(50,500))}
if(clk("STD1")&STD<=STD1){STD2+="." if(STD2:length()>3){STD2=""} W:egpSetText(1,"Shutting down"+STD2) STD++ timer("STD1",150)}
if(clk("STD1")&STD>STD1){Loaded=0 timer("shutdown1",1)}
##/diag
if(clk("Loaded")&(egpMaxObjects()>=440|IDsOverride)){
ChrA="qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890@#*"
RBT=0
W:egpClear()
DPL=1
Cond=0.9
DType[0,string]=""
DType[1,string]="DHD DIALING SEQUENCER"
DType[2,string]="NOX DIALING"
Text1["000",string]="IDLE"
Text1["010",string]="SEQUENCE"
Text2["010",string]="IN PROGRESS"
Text1["0101",string]="SEQUENCE"
Text2["0101",string]="COMPLETE"
Text1["110",string]="LOCKED"
Text1["011",string]="OFFWORLD ACTIVATION"
Text1["111",string]="OFFWORLD ACTIVATION"
Text1pos["000",vector2]=vec2(266,372)
Text1pos["010",vector2]=vec2(330,374)
Text2pos["010",vector2]=vec2(330,398)
Text1pos["0101",vector2]=vec2(330,374)
Text2pos["0101",vector2]=vec2(330,398)
Text1pos["110",vector2]=vec2(328,388)
Text1pos["011",vector2]=vec2(256,227)
Text1pos["111",vector2]=vec2(256,227)
Text1col["110",vector]=vec(255,0,0)
Text1col["011",vector]=vec(255,0,0)
Text1col["111",vector]=vec(255,0,0)
Text1size["000",number]=30
Text1size["010",number]=26
Text2size["010",number]=26
Text1size["0101",number]=26
Text2size["0101",number]=35
Text1size["110",number]=50
Text1size["011",number]=30
Text1size["111",number]=30
for(I=0,16){RandNum[I+1,string]=""}
print("This chip needs 440 ID's. This server have "+egpMaxObjects()+" ID's")
print("This chip needs more than 13000 BPS. This server have "+egpMaxUmsgPerSecond()+" BPS")
hint("This chip needs 440 ID's. This server have "+egpMaxObjects()+" ID's",10)
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
#[for(I=0,6)
{
I2=I2+1
W:egpCircleOutline(108+I,vec2(256,225),vec2(123+I/2,123+I/2))
}]#

W:egpCircleOutline(108,vec2(256,225),vec2(126,126))
W:egpSize(108,3)
W:egpFidelity(108,36)
W:egpCircleOutline(109,vec2(256,225),vec2(126,126))
W:egpSize(109,3) W:egpAngle(109,46)
W:egpFidelity(109,36)

#W:egpCircleOutline(108,vec2(256,225),vec2(125,125))
#W:egpCircleOutline(109,vec2(256,225),vec2(125,126))
#W:egpCircleOutline(110,vec2(256,225),vec2(126,127))
#W:egpCircleOutline(111,vec2(256,225),vec2(126,127))
#W:egpCircleOutline(112,vec2(256,225),vec2(127,127))
#W:egpCircleOutline(113,vec2(256,225),vec2(127,128))
#W:egpCircleOutline(114,vec2(256,225),vec2(128,128))
W:egpCircleOutline(110,vec2(256,225),vec2(103,103))
W:egpCircleOutline(111,vec2(256,225),vec2(113,113))
#
for(I=1,40){
W:egpLine(112+I,vec2(sin(180-(360/40)*I),cos(180-(360/40)*I))*100.3,vec2(sin(180-(360/40)*I),cos(180-(360/40)*I))*127)
#W:egpSize(156+I,2)
W:egpParent(112+I,108)} W:egpAngle(108,4.6)
for(I=1,40){
W:egpLine(154+I,vec2(sin(180-(360/40)*I),cos(180-(360/40)*I))*104.3,vec2(sin(180-(360/40)*I),cos(180-(360/40)*I))*114.3)
W:egpSize(154+I,1)
#if(NewCol){W:egpColor(154+I,vec(208,208,144))} if(!NewCol){W:egpColor(154+I,vec(255,255,255))}
W:egpParent(154+I,110)} W:egpAngle(110,4.6) W:egpAngle(111,4.6)
#interval(100)
#ANG++
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
for(I=0,16){
#W:egpText(412+I,toString(RandNum[I,number]),vec2(8,92+45*I))
W:egpText(412+I,RandNum[I+1,string],vec2(86,101+10*I))
W:egpAlign(412+I,2,1)
W:egpFont(412+I,"Marlett",13)
}
W:egpText(408,"",vec2(260,110+1*1.06))
W:egpFont(408,"Stargate Address Glyphs Concept",100)
W:egpAlign(408,1,1)
W:egpBoxOutline(393,vec2(-4,0),vec2(0,0))
W:egpParent(393,408)
W:egpText(387,"",vec2())
W:egpText(388,"",vec2())
W:egpAlign(387,1,1)
W:egpFont(387,"Marlett")
W:egpFont(388,"Marlett")
W:egpAlign(388,1,1)
W:egpBox(389,vec2(98,95),vec2(43,45))
W:egpBox(390,vec2(374,95),vec2(43,45))
W:egpBox(391,vec2(98,312),vec2(43,45))
W:egpBox(392,vec2(374,312),vec2(43,45))
W:egpColor(389,vec(255,0,0))
W:egpColor(390,vec(255,0,0))
W:egpColor(391,vec(255,0,0))
W:egpColor(392,vec(255,0,0))
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
W:egpAlpha(403,0)
W:egpAlpha(404,0)
W:egpAlpha(405,0)
W:egpAlpha(406,0)
W:egpText(409,DType[0,string],vec2(256,75))
W:egpAlign(409,1,1)
W:egpFont(409,"Marlett",30)
timer("draw",100)
}
if(~NewCol){timer("draw",1)}
if(clk("draw")&egpMaxObjects()>=440){
if(NewCol){W:egpColor(409,vec(0,153,154))}
if(!NewCol){W:egpColor(409,vec(0,153,184))}
W:egpColor(35,vec(255,0,0))
W:egpColor(36,vec(255,0,0))
if(!NewCol){
W:egpColor(410,vec(0,153,184))
W:egpColor(411,vec(0,153,184))
for(I=2,428)
{
if(I<=17|(I>26&I<110)|(I>111&I<154)|(I>17&I<28)|(I>34&I<37)|(I>335&I<343)){W:egpColor(I,vec(0,153,184))}
if((I>109&I<112)|(I>153&I<200)|(I>=202&I<336)|(I>411&I<429)){W:egpColor(I,vec(255,255,255))}
if((I>17&I<27)){W:egpColor(I,vec(12,96,104))}
if(I>393&I<403){W:egpColor(I,vec(0,153,184))}
}
}
if(NewCol){
W:egpColor(410,vec(0,153,154))
W:egpColor(411,vec(0,153,154))
for(I=2,428)
{
if(I<=17|(I>26&I<110)|(I>111&I<154)|(I>34&I<37)|(I>335&I<343)|(I>411&I<429)){W:egpColor(I,vec(0,153,154))}
if((I>109&I<112)|(I>153&I<200)|(I>=202&I<336)){W:egpColor(I,vec(208,208,144))}
if((I>17&I<27)){W:egpColor(I,vec(12,94,76))}
if(I>393&I<403){W:egpColor(I,vec(0,153,154))}
}
}
}
if(clk("Loaded")&egpMaxObjects()<440&!IDsOverride){
Loaded=-1
print("This chip needs 440 ID's. This server have "+egpMaxObjects()+" ID's")
print("This chip needs more than 13000 BPS. This server have "+egpMaxUmsgPerSecond()+" BPS")
hint("This chip needs 440 ID's. This server have "+egpMaxObjects()+" ID's",10)
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
W:egpText(5,"YOU NEED A 440 ID's!",vec2(256,138))
W:egpAlign(5,1,1)
W:egpFont(5,"Marlett",35)
W:egpColor(5,vec(255,0,0))
W:egpText(6,"NEED ENTER A:",vec2(256,168))
W:egpAlign(6,1,1)
W:egpFont(6,"Marlett",35)
W:egpColor(6,vec(255,0,0))
W:egpText(7,"wire_egp_max_objects 440",vec2(256,191))
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
if(Loaded==2){
if(($Active|changed(Unstable))&Active&!Unstable){Cond=0.3} if(($Active|changed(Unstable))&!Unstable&!Active|clk("Loaded")){Cond=0.7}
if(($Active|changed(Unstable))&Active&!Unstable){Cond2=0.6} if(($Active|changed(Unstable))&!Unstable&!Active|clk("Loaded")){Cond2=0.9}
if(changed(Time)&Time>0){OvSec=toString( Time % 60)} if(changed(Time)&Time<=0){OvSec="00"}
if(changed(Time)&Time>0){OvMin=toString(floor(Time/60))} if(changed(Time)&Time<=0){OvMin="00"}
if(changed(Time)&OvMin:length()==1){OvMin="0"+OvMin}
if(changed(Time)&OvSec:length()==1){OvSec="0"+OvSec}
if(~Key&Key&Key!=127){
if(EnteredAdress:length()<9&!Active){if((ChrA:find(toChar(Key))&!EnteredAdress:find(toChar(Key):upper())&toChar(Key)!="#"&!EnteredAdress:find("#"))|(ChrA:find(toChar(Key))&toChar(Key)=="#"&EnteredAdress:length()>5&EnteredAdress:length()<9&!EnteredAdress:find("#"))){
EnteredAdress+=toChar(Key):upper()}}
} if(~Key&Key==127&!Active){CHKRM=1 EnteredAdress=EnteredAdress:left(EnteredAdress:length()-1) timer("CHKRM",500)}
if(~Key&Key!=127&!Active){CHKRM=0 stoptimer("CHKRM")}
if(clk("CHKRM")){EnteredAdress=""}
if(~AddressBook&AddressBook:length()>0&!Active&EnteredAdress!=AddressBook){EnteredAdress=AddressBook AdrBlock=1} if(~AddressBook&AddressBook:length()==0|Active){AdrBlock=0}
if(~AddressBook&AddressBook:length()>0&!Active&EnteredAdress==AddressBook&!AdrBlock){DialString=EnteredAdress timer("SSDT",100)}
if(~Key&Key==13&!Correct&EnteredAdress:length()>5&EnteredAdress:length()<9&!EnteredAdress:find("#")){EnteredAdress=EnteredAdress+"#"}
if(~Key&((Key==13&Correct)|Key==124)){DialString=EnteredAdress}
if(~Key&(Key==13&Correct)|Key==124){EnteredAdress="" timer("SSDT",100)} if(clk("SSDT")){StartStringDial=1 EnteredAdress="" timer("SSDT1",100)}  if(clk("SSDT1")){StartStringDial=0}
if(~Key&Key==127&Active){Close=1} if(~Key&Key!=127){Close=0}
if(~Key&Key==61){Iris=1}else{Iris=0}
if(~Key&Key==129){DialingMode=0}
if(~Key&Key==130){DialingMode=1}
if(~Key&Key==131){DialingMode=2}
if(~Key&Key==9&((KeyUser==owner()&->KeyUser)|(!->KeyUser))){RB++ timer("RBTR",200) if(RB==2){timer("shutdown",1) Loaded=-1 RB=0 RBT=1}}
if(clk("RBTR")&RB>0){RB=0}
if((~Key|clk("CHKRM")|clk("Loaded"))&!Active){for(I=0,8){W:egpSetText(367+I,EnteredAdress[I+1])}}
if($Active&Active){EnteredAdress="" for(I=0,8){W:egpSetText(367+I,EnteredAdress[I+1])}}
if(clk("Loaded")){timer("kvadratiki1",200) timer("kvadratiki2",500) timer("RC",50)
for(I=0,8)
{
W:egpBoxOutline(28+I,vec2(441,93+I*45),vec2(65,43))
W:egpAlpha(35,0)
W:egpAlpha(36,0)
}}
if($RingRotation&RingRotation){RingStopCheck=0 timer("RC",50)}
if(clk("RSC")&!RingRotation){RingStopCheck=1}
if(clk("RC")&!RingStopCheck){RingAngle=SG:stargateGetRingAngle()+4.6 W:egpAngle(110,RingAngle) W:egpAngle(111,RingAngle) timer("RC",50) if(RingRotation==0){timer("RSC",1000)}}
#if(RingRotation==1){timer("I3-",100)} if(clk("I3+")){ANG=ANG+2.5 W:egpAngle(115,ANG) W:egpAngle(116,ANG)}
#if(RingRotation==-1){timer("I3+",100)} if(clk("I3-")){ANG=ANG-2.5 W:egpAngle(115,ANG) W:egpAngle(116,ANG)}
if(clk("kvadratiki1")){
Time=SG:stargateOverloadTime()
Unstable=SG:stargateUnstable()
Overload=SG:stargateOverload()
OvPercent=SG:stargateOverloadPerc()
if(Unstable){Cond2=0.7 Cond=0.7}
if(!B1) {Alpha3=Alpha3-60}
if(B1) {Alpha3=Alpha3+60}
if(Alpha3>=240){ B1=0 }
if(Alpha3<=0){ B1=1 }
W:egpAlpha(387,Alpha3)
W:egpAlpha(388,Alpha3)
if($Open&Active&Open&!Inbound){ W:egpAlpha(391,0) W:egpAlpha(392,0)}
if(Active&Open&!Inbound){W:egpAlpha(389,Alpha3) W:egpAlpha(390,Alpha3)
}elseif(Active&Inbound){ W:egpAlpha(389,Alpha3) W:egpAlpha(390,Alpha3) W:egpAlpha(391,Alpha3) W:egpAlpha(392,Alpha3)}
if(($Active|$Open|!Inbound)&!Open&!Inbound){ W:egpAlpha(389,0) W:egpAlpha(390,0) W:egpAlpha(391,0) W:egpAlpha(392,0)}
if(Correct){W:egpAlpha(407,Alpha3)}else{W:egpAlpha(407,0)}
W:egpAlpha(431,Alpha3)
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
W:egpSize(394,vec2(14,G1))
W:egpSize(395,vec2(14,G2))
W:egpSize(396,vec2(14,G3))
W:egpSize(397,vec2(14,G4))
W:egpSize(398,vec2(14,G5))
W:egpSize(399,vec2(14,G6))
W:egpSize(400,vec2(14,G7))
W:egpSize(401,vec2(14,G8))
W:egpSize(402,vec2(14,G9))
for(I=300,335){if(random()>Cond){Alpha1=255}else{Alpha1=0} W:egpAlpha(I,Alpha1)} timer("kvadratiki1",150)}
if(clk("kvadratiki1")){RandNum:shift() if(Active){IStr = "" N = randint(5,11)
for(I=1,N) {IStr += toString(randint(0,9))}
RandNum:insertString(17, IStr)
}else {RandNum:insertString(17,"")}
for(I=0,16){
#W:egpText(412+I,toString(RandNum[I,number]),vec2(8,92+45*I))
W:egpSetText(412+I,RandNum[I+1,string])
}}
if(clk("kvadratiki2")){for(I=343,366){if(random()>Cond2){Alpha2=255}else{Alpha2=0} W:egpAlpha(I,Alpha2)} timer("kvadratiki2",500)}
if(DialMode==0){
if((DialingSymbol==RingSymbol&RingRotation==0&Chev<101&Chevron<8)|
(DialingSymbol=="#"&RingSymbol=="#"&Chevron<8&Chev<101)|
(DialingSymbol==RingSymbol&Chevron>=8&Chev<101)){
if(($RingRotation&!RingRotation)|(DialingSymbol=="#"&RingSymbol=="#"&Chev==0)|(DialingSymbol==RingSymbol&Chevron>=8&Chev==0)){ W:egpSetText(408,"") W:egpSize(393,vec2(0,0)) timer("chev",100) W:egpAlpha(408,255) W:egpAlpha(393,255)}
if(clk("chev")&!AN1){
Chev2=0
W:egpSetText(408,RingSymbol)
W:egpPos(408,vec2(260,110+Chev*1.06))
W:egpSize(408,Chev*1.3)
if(AnotherSound){
if(Chev==0&(DialingSymbol!="#"&Chevron<8)){W:entity():soundPlay(2,1,"alexalx/glebqip/dp_locked.wav") soundVolume(2,0.6) timer("enc",1500)}
if(Chev==0&((DialingSymbol=="#"&Chevron<8)|(Chevron>=8))){W:entity():soundPlay(2,1,"alexalx/glebqip/dp_locked.wav") soundVolume(2,0.6) timer("enc",1100)} }
if(!AnotherSound){
if(Chev==0&(DialingSymbol!="#"&Chevron<8)){W:entity():soundPlay(2,1,"alexalx/glebqip/dp_locking.wav") soundVolume(2,0.6) timer("enc",1500)}
if(Chev==0&((DialingSymbol=="#"&Chevron<8)|(Chevron>=8))){W:entity():soundPlay(2,1,"alexalx/glebqip/dp_locking.wav") soundVolume(2,0.6) timer("enc",1100)} }
Chev+=15
local BoxMin=vec2((Chev-5)*3.23,(Chev-5)*2.67)
W:egpPos(393,vec2(-4,20)-BoxMin/2)
W:egpSize(393,BoxMin)
timer("chev",100)
}}
if(clk("enc")){W:entity():soundPlay(2,1,"alexalx/glebqip/dp_locked.wav") soundVolume(2,0.6)}
if(RingSymbol!=""&RingSymbol==DialedSymbol&Chev2<90){
if(changed(DialedSymbol)&RingSymbol!=""&RingSymbol==DialedSymbol&Chev2<90){timer("chev2",100)}
if(clk("chev2")&AN1<2){
Chev=0
AN1=1
Chev2=Chev2+20
W:egpSetText(408,RingSymbol)
W:egpSize(408,130-Chev2*0.845)
W:egpPos(408,vec2(260+Chev2*2.15,216-Chev2*(1.01-0.45*Chevron1)))
local BoxMin2=vec2(307-((Chev2-15)*3.23),254-(Chev2-15)*2.67)
W:egpPos(393,vec2(0,0)-BoxMin2/2)
W:egpSize(393,BoxMin2)
Alpha4=100-Chev2*1.5 if(Alpha4<0){Alpha4=0}
W:egpAlpha(393,Alpha4)
if(Chev2>=90){W:entity():soundPlay(1,1,"alexalx/glebqip/dp_encoded.wav") soundVolume(1,0.6) if((DialedSymbol=="#"&Chevron<9)|Chevron==9){timer("compl0",1)} W:egpAlpha(393,0) W:egpAlpha(408,0) DialingAdress1=DialingAdress1+DialedSymbol AN1=2 Chevron1++ W:egpAlpha(408,0) W:egpAlpha(393,0)}
timer("chev2",100)
}}}
if($Active&!Active){Chev2=0 Chev=0 AN1=2 W:egpAlpha(393,0) W:egpAlpha(408,0)}
if($RingRotation&RingRotation!=0){AN1=0}
if(!Inbound&DialMode==0&Active){
if(changed(Chevron1)&Chevron1==1){for(I=0,10){W:egpColor(202+I,vec(255,0,0))}}
if(changed(Chevron1)&Chevron1==2){for(I=0,10){W:egpColor(213+I,vec(255,0,0))}}
if(changed(Chevron1)&Chevron1==3){for(I=0,10){W:egpColor(224+I,vec(255,0,0))}}
if(changed(Chevron1)&Chevron1==4){for(I=0,10){W:egpColor(235+I,vec(255,0,0))}}
if(changed(Chevron1)&Chevron1==5){for(I=0,10){W:egpColor(246+I,vec(255,0,0))}}
if(changed(Chevron1)&Chevron1==6){for(I=0,10){W:egpColor(257+I,vec(255,0,0))}}
if(changed(Chevron1)&ChevronLocked){for(I=0,9){W:egpColor(268+I,vec(255,0,0))}}
if(changed(Chevron1)&Chevron1==7&!ChevronLocked){for(I=0,10){W:egpColor(278+I,vec(255,0,0))}}
if(changed(Chevron1)&Chevron1==8&!ChevronLocked){for(I=0,10){W:egpColor(289+I,vec(255,0,0))}}}
if((Inbound|DialMode!=0)&Active){
if($Chevron&Chevron>=1){for(I=0,10){W:egpColor(202+I,vec(255,0,0))}}
if($Chevron&Chevron>=2){for(I=0,10){W:egpColor(213+I,vec(255,0,0))}}
if($Chevron&Chevron>=3){for(I=0,10){W:egpColor(224+I,vec(255,0,0))}}
if($Chevron&Chevron>=4){for(I=0,10){W:egpColor(235+I,vec(255,0,0))}}
if($Chevron&Chevron>=5){for(I=0,10){W:egpColor(246+I,vec(255,0,0))}}
if($Chevron&Chevron>=6){for(I=0,10){W:egpColor(257+I,vec(255,0,0))}}
if($Chevron&ChevronLocked){for(I=0,9){W:egpColor(268+I,vec(255,0,0))}}
if($Chevron&Chevron>=7&!ChevronLocked){for(I=0,10){W:egpColor(278+I,vec(255,0,0))}}
if($Chevron&Chevron>=8&!ChevronLocked){for(I=0,10){W:egpColor(289+I,vec(255,0,0))}}}
if($Active&!Active){for(I=0,97){if(NewCol){W:egpColor(202+I,vec(208,208,144))} if(!NewCol){W:egpColor(202+I,vec(255,255,255))}}}
if(changed(Chevron1)&Chevron1>0){if(DialMode==0&!Inbound){W:egpSetText(367+Chevron-1,DialingAdress1[Chevron])}}
if(changed(DialingAdress)&Chevron>0){if(DialMode!=0&!Inbound){W:egpSetText(367+Chevron-1,DialingAdress[Chevron])}}
if(changed(Chevron1)&!Inbound&DialMode==0&Active){W:egpAlpha(378+Chevron1-1,255)}
if($Chevron&Inbound|DialMode!=0&Active){W:egpAlpha(378+Chevron-1,255)}
if($Active&Active==0){Chevron1=0 DialingAdress1="" W:egpAlpha(366,0) for(I=0,8){W:egpSetText(367+I,"") W:egpAlpha(378+I,0)}}
#if(!Active){for(I=0,8){W:egpAlpha(378+I,0)}}
if(clk("Loaded")|~NewCol){
if(NewCol){Col1=vec(0,153,154)} if(!NewCol){Col1=vec(0,153,184)}
Text1col["000",vector]=Col1
Text2col["000",vector]=Col1
Text1col["010",vector]=Col1
Text2col["010",vector]=Col1
Text1col["0101",vector]=Col1
Text2col["0101",vector]=Col1}
if(clk("Loaded")|$Open|$Active|$Inbound|changed(DialedSymbol)|~NewCol){
if(Active&!Open&!Inbound&(DialedSymbol=="#"|Chevron==9)){A112=toString(Open)+toString(Active)+toString(Inbound)+toString(DialedSymbol=="#"|Chevron==9)}else{A112=toString(Open)+toString(Active)+toString(Inbound)}
W:egpSetText(387,Text1[A112,string])
W:egpPos(387,Text1pos[A112,vector2])
W:egpColor(387,Text1col[A112,vector])
W:egpSetText(388,Text2[A112,string])
W:egpPos(388,Text2pos[A112,vector2])
W:egpColor(388,Text2col[A112,vector])
W:egpSize(387,Text1size[A112,number])
W:egpSize(388,Text2size[A112,number])
if(Active&Open&!Inbound){
W:egpAlpha(389,255)
W:egpAlpha(390,255)
W:egpPos(389,vec2(243,362)) W:egpSize(389,vec2(170,8))
W:egpPos(390,vec2(243,404)) W:egpSize(390,vec2(170,8))
W:egpAlpha(391,0)
W:egpAlpha(392,0)
}elseif(Active&Inbound){
W:egpAlpha(389,255)
W:egpAlpha(390,255)
W:egpAlpha(391,255)
W:egpAlpha(392,255)
W:egpPos(389,vec2(98,95)) W:egpSize(389,vec2(43,43))
W:egpPos(390,vec2(372,95)) W:egpSize(390,vec2(43,45))
W:egpPos(391,vec2(98,311)) W:egpSize(389,vec2(43,45))
W:egpPos(392,vec2(372,311)) W:egpSize(390,vec2(43,45))}else{
W:egpAlpha(389,0) W:egpAlpha(390,0) W:egpAlpha(391,0) W:egpAlpha(392,0)}}
if($Open){
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
if(changed(EnteredAdress)){
if(((EnteredAdress:length()<9&EnteredAdress[EnteredAdress:length()]=="#")|EnteredAdress:length()==9)&!Active)
{
Correct=1
W:egpAlpha(403,255)
W:egpAlpha(404,255)
W:egpAlpha(405,255)
W:egpAlpha(406,255)
if(NewCol){W:egpColor(404,vec(0,153,154)) W:egpColor(405,vec(0,153,154)) W:egpColor(406,vec(0,153,154))}
if(!NewCol){W:egpColor(404,vec(0,153,184)) W:egpColor(405,vec(0,153,184)) W:egpColor(406,vec(0,153,184))}}
else{
W:egpAlpha(403,0) W:egpAlpha(404,0) W:egpAlpha(405,0) W:egpAlpha(406,0) Correct=0
}}
#if(clk("kvadratiki1")){
if(Correct){W:egpAlpha(407,Alpha3)} if(changed(Correct)&!Correct){W:egpAlpha(407,0)}#}
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
if(changed(DialedSymbol)&Active&!Open&!Inbound&((DialedSymbol=="#"&Chevron<9)|Chevron==9)&DialMode>0){timer("compl0",1)} if(!Active|Inbound){for(I=0,8){W:egpAlpha(18+I,0)}}# soundStop(3,0)}
if(clk("compl0")){for(I=0,Chevron-1){W:egpAlpha(18+I,255)} timer("compl1",200) W:entity():soundPlay(3,500,"alexalx/glebqip/dp_lock.wav") soundVolume(3,0.6)} #W:entity():soundPlay(3,500,"SGDP/v1/DP/lock1.wav")}
if(clk("compl1")){for(I=0,Chevron-1){W:egpAlpha(18+I,0)} timer("compl2",200) soundStop(3,0)}
if(clk("compl2")){for(I=0,Chevron-1){W:egpAlpha(18+I,255)} timer("compl3",200) W:entity():soundPlay(3,500,"alexalx/glebqip/dp_lock.wav") soundVolume(3,0.6)}
if(clk("compl3")){for(I=0,Chevron-1){W:egpAlpha(18+I,0)} timer("compl4",200) soundStop(3,0)}
if(clk("compl4")){for(I=0,Chevron-1){W:egpAlpha(18+I,255)} timer("compl5",200) W:entity():soundPlay(3,500,"alexalx/glebqip/dp_lock.wav") soundVolume(3,0.6)}
if(clk("compl5")){for(I=0,Chevron-1){W:egpAlpha(18+I,0)} soundStop(3,0)}
if(Chevr8)
{
AA1=1
W:egpAlpha(35,255)
W:egpColor(35,vec(255,0,0))
W:egpColor(385,vec(255,0,0))
if(I1<43){timer("I1",50)}
if(clk("I1")){I1=I1+5 if(I1<43){timer("I1",50)}}
W:egpBox(200,vec2(441,404),vec2(65,43-I1))
W:egpColor(200,vec(0,0,0))
} if(!Chevr8&!Chevr9){W:egpRemove(200) W:egpAlpha(35,0) I1=0}
if(Chevr9)
{
AA1=1
W:egpAlpha(36,255)
W:egpColor(36,vec(255,0,0))
W:egpColor(386,vec(255,0,0))
W:egpBoxOutline(2,vec2(1,85),vec2(511,420))
if(I2<43){timer("I2",50)}
if(clk("I2")){I2=I2+5 if(I2<43){timer("I2",50)}}
I2++
W:egpBox(201,vec2(441,449),vec2(65,43-I2))
W:egpColor(201,vec(0,0,0))
} if(!Chevr9){W:egpRemove(201) W:egpAlpha(36,0) I2=0 if(Chevr8&!Chevr9){W:egpBoxOutline(2,vec2(1,85),vec2(511,378))} if(!Chevr8&!Chevr9&AA1){W:egpBoxOutline(2,vec2(1,85),vec2(511,334)) AA1=0}
if(($Inbound|changed(DialingMode))&!Inbound){W:egpText(409,DType[DialingMode,string],vec2(256,75))} if($Inbound&Inbound){W:egpText(409,DType[0,string],vec2(256,75))}
if(~Key&Key){W:entity():soundPlay(0,1,"alexalx/glebqip/click"+randint(1,4)+".mp3")}
if(DialMode!=0&!Inbound){if($Chevron&Chevron>0){W:entity():soundPlay(1,1,"alexalx/glebqip/dp_encoded.wav") soundVolume(1,0.6) timer("sstop",200)}} if(clk("sstop")){soundStop(1,0)}
if(changed(Overload)&Overload>0){
W:egpBox(429,vec2(124,125),vec2(264,133))
W:egpColor(429,vec(0,0,0))
W:egpBoxOutline(430,vec2(124,125),vec2(264,133))
W:egpColor(430,vec(255,0,0))
W:egpText(431,"WARNING",vec2(256,151))
W:egpAlign(431,1,1)
W:egpFont(431,"Marlett",55)
W:egpColor(431,vec(255,0,0))
if(Time>240){W:egpText(432,"HIGH LEVEL OF ENERGY FLUX",vec2(256,183))}
if(Time<=240){W:egpText(432,"CRITICAL LEVEL OF ENERGY FLUX",vec2(256,183))}
W:egpAlign(432,1,1)
W:egpFont(432,"Marlett",18)
W:egpColor(432,vec(255,0,0))
W:egpText(433,"STARGATE WILL BE DESTROYED",vec2(256,200))
W:egpAlign(433,1,1)
W:egpFont(433,"Marlett",18)
W:egpColor(433,vec(255,0,0))
W:egpText(434,"AFTER:",vec2(256,218))
W:egpAlign(434,1,1)
W:egpFont(434,"Marlett",18)
W:egpColor(434,vec(255,0,0))
W:egpText(435,OvMin+"M"+OvSec+"S",vec2(250,220))
W:egpAlign(435,1,0)
W:egpFont(435,"Marlett",40)
W:egpColor(435,vec(255,0,0))
W:egpBox(436,vec2(124,258),vec2(264,65))
W:egpColor(436,vec(0,0,0))
W:egpBoxOutline(437,vec2(124,258),vec2(264,65))
W:egpColor(437,vec(255,0,0))
W:egpBox(438,vec2(144+even(floor(OvPercent/100*224)),268),vec2(floor(OvPercent/100*224),45))
W:egpBoxOutline(439,vec2(144,268),vec2(224,45))
W:egpColor(439,vec(255,0,0))
}
if(Overload>0&(changed(Time)|changed(Overload))){
if(Overload==2)
{
W:egpSetText(433,"STARGATE DESTROYING")
W:egpSetText(432,"ENERGY FLUX IS CRITICALLY")
W:egpSetText(434,"WITHIN")
W:egpSetText(435,"00M"+30+"S")
}
if(Overload==1)
{
W:egpSetText(433,"STARGATE WILL BE DESTROYED")
W:egpSetText(434,"AFTER")
if(Time>240){W:egpSetText(432,"HIGH LEVEL OF ENERGY FLUX")}
if(Time<=240){W:egpSetText(432,"CRITICAL LEVEL OF ENERGY FLUX")}
W:egpSetText(435,OvMin+"M"+OvSec+"S")
}
}
if(Overload>0&changed(OvPercent)){
W:egpBoxOutline(437,vec2(124,258),vec2(264,65))
W:egpBox(438,vec2(144+even(floor(OvPercent/100*224)),268),vec2(floor(OvPercent/100*224),45))
W:egpColor(438,vec(OvPercent/100*255,255-OvPercent/100*255,0))}
if((changed(Overload)&!Overload)|(clk("Loaded"))){W:egpRemove(429) W:egpRemove(430) W:egpRemove(431) W:egpRemove(432) W:egpRemove(433) W:egpRemove(434) W:egpRemove(435) W:egpRemove(436) W:egpRemove(437) W:egpRemove(438) W:egpRemove(439)}
}}
else
{
if(first()|dupefinished()|clk("shutdown1")){timer("LCHK",100)}
if(clk("LCHK")){if(Active){Close=1}else{Close=0} timer("LCHK",100)}
}
if(clk("errpip")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip1",200)}
if(clk("errpip1")){soundVolume(12,0) soundStop(12,0) timer("errpip2",200)}
if(clk("errpip2")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip3",200)}
if(clk("errpip3")){soundVolume(12,0) soundStop(12,0) timer("errpip4",200)}
if(clk("errpip4")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip5",200)}
if(clk("errpip5")){soundVolume(12,0) soundStop(12,0)}
if(changed(DialString)){SG:stargateSetWire("Dial String",DialString)}
if(changed(DialingMode)){SG:stargateSetWire("Dial Mode",DialingMode)}
if(changed(StartStringDial)){SG:stargateSetWire("Start String Dial",StartStringDial)}
if(changed(Close)){SG:stargateSetWire("Close",Close)}
if(changed(RotateRing)){SG:stargateSetWire("Rotate Ring",RotateRing)}
if(changed(RingSpeedMode)){SG:stargateSetWire("Ring Speed Mode",RingSpeedMode)}
if(changed(ActivateChevronNumbers)){SG:stargateSetWire("Activate chevron numbers",ActivateChevronNumbers)}

