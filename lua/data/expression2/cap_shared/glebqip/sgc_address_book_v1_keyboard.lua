# Version 1.0
# Author glebqip(RUS)
# Created 30.11.13 Updated 08.02.13
# This is Stargate Address Book from first 2 Stargate-SG1 seasons.
# This chip need a wire_expression2_unlimited 1, wire_egp_max_bytes_per_seconds 13000 and on server.
# Support thread: http://sg-carterpack.com/forums/topic/sgc-dialing-computer-v1-e2/
@name SGC Address Book v1 keyboard
@inputs DPL Start W:wirelink SG:wirelink KeyDP Key NewCol
@outputs AddressBook:string True
@persist RAM Pip Load1 LoadOver Loaded RB Loaded1 STD2:string STD STD1 IDs1
@persist I1:table Day:string Month:string Year:string Hours:string Min:string Sec:string ChrA:string Pos:vector2
@persist AddressN:array AddressG:array AddressB:array AddressO:string AddressList:array AdrPlus Adr NewCol
@trigger
if(~W&W){reset()}
if(clk("UpdateAddressList")){
AddressG:clear()
AddressN:clear()
AddressB:clear()
AddressList=SG:stargateAddressList()
for(I=1,AddressList:count()){
N = 2
Blocked = 0
Array = AddressList[I,string]:explode(" ")
Address = Array[1,string]
if (Address=="1") {
Blocked = 1
Address = Array[2,string]
N = 3
}
Name = ""
for (I=N,Array:count()) {
if (I!=N) { Name = Name + " " }
Name = Name + Array[I,string]
}
#if (Blocked==1) {
if(Address:length()==7){Name=Name+"(8:"+Address[7]+"#)"}
if(Address:length()==9){Name=Name+"(9:"+Address[8]+Address[9]+")"}
if(Address:length()!=9){Address=Address+"#"}
AddressG[I,string]=Address
AddressN[I,string]=Name
AddressB[I,number]=Blocked
#[} else {
AddressG[I,string]=Address
AddressN[I,string]=Name
AddressB[I,number]=0
}]#
}
timer("UpdateAddressList",5000)
if(AddressG:concat()+""+AddressN:concat()+""+AddressB:concat()!=AddressO){timer("REL",100)}
}
if(first()|dupefinished()|clk("shutdown1")){W:egpClear() Loaded1=0}
if(((~Start|first()|dupefinished())&Start)&Loaded1==0)
{
if(Start<=1|Start==3){LoadOver=0}
if(Start==2){LoadOver=1}
RingSpeedMode=1
W:egpClear()
for(I=0,8){W:egpText(1+I,"",vec2(5,10+I*12)) W:egpAlign(1+I,0,1) W:egpFont(1+I,"Console",15)}
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
if(clk("LD5")&!->KeyDP){
W:egpSetText(5,"Error! Keyboard not detected! Waiting keyboard connect.") if(!Pip){timer("errpip",1) Pip=1} W:egpColor(5,vec(255,0,0)) timer("LD5",1000)}
if(clk("LD5")&->KeyDP){W:egpSetText(5,"Keyboard... OK!") W:egpColor(5,vec(255,255,255)) Pip=0 timer("LD6",randint(800,1300))}
if(egpMaxObjects()<196&~KeyDP&KeyDP==13&IDs1){IDsOverride=1 IDs1=0}
if(clk("LD6")&egpMaxObjects()>196&!IDsOverride){W:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's OK!") W:egpColor(6,vec(255,255,255)) timer("LD7",randint(50,300)) Pip=0}
if(clk("LD6")&(egpMaxObjects()<196&IDsOverride)){W:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's Override ID's protection!") W:egpColor(6,vec(255,255,0)) timer("LD7",randint(50,300)) Pip=0}
if(clk("LD6")&egpMaxObjects()<196&!IDsOverride){IDs1=1 W:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's. Need a 196 ID's. Waiting a wire_egp_max_objects 196!") if(!Pip){timer("errpip",1) Pip=1} timer("LD6",150) W:egpColor(6,vec(255,0,0))}
if(clk("LD7")&!->SG){if(!Pip){timer("errpip",1) Pip=1} W:egpSetText(7,"Can't connect to Address Database!!!") W:egpColor(7,vec(255,0,0)) timer("LD7",100)}
if(clk("LD7")&->SG){Pip=0 W:egpSetText(7,"Connected to Address Database") W:egpColor(7,vec(255,255,255)) timer("LD8",100)}
if(clk("LD8")){Pip=0 Load1=0 W:egpSetText(8,"Address Book build 1.241.15 v1 07.12.13 is loading...") W:egpColor(8,vec(255,255,255)) timer("LD9",randint(100,1000))}
if(clk("LD9")&Loaded!=1&Load1<100){Load1+=randint(4,12) W:egpSetText(8,"Address Book build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD9",randint(100,300))}
if(Load1>=100){W:egpSetText(8,"Address Book build 1.241.15 v1 07.12.13 is loading... 100%") if(DPL){timer("Loaded",randint(50,700))}else{timer("LD91",randint(100,300))}}
if(clk("LD91")&!DPL&->DPL){if(!Pip){timer("errpip",1) Pip=1} W:egpSetText(9,"Waiting Dialing Programm...") W:egpColor(9,vec(255,255,0)) timer("LD91",100)}
if(clk("LD91")&(DPL|!->DPL)){Pip=0 timer("Loaded",randint(50,700))}}
if(LoadOver){
if(clk("LD1")){soundVolume(12,0) soundStop(12,0.001) Load1=0 W:egpSetText(1,"Address Book build 1.241.15 v1 07.12.13 is loading...") W:egpColor(1,vec(255,255,255)) timer("LD11",randint(100,1000))}
if(clk("LD11")&Loaded!=1&Load1<100){Load1+=randint(4,12) W:egpSetText(1,"Address Book build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD11",randint(100,300))}
if(Load1>=100){W:egpSetText(1,"Address Book build 1.241.15 v1 07.12.13 is loading... 100%") timer("Loaded",randint(50,700))}}
if(clk("shutdown")){
STD1=randint(30,80)
W:egpClear()
STD2=""
STD=0
W:egpText(1,"",vec2(5,10)) W:egpAlign(1,0,1) W:egpFont(1,"Console",15)
timer("STD1",randint(50,500))}
if(clk("STD1")&STD<=STD1){STD2+="." if(STD2:length()>3){STD2=""} W:egpSetText(1,"Shutting down"+STD2) STD++ timer("STD1",150)}
if(clk("STD1")&STD>STD1){Loaded=0 timer("shutdown1",1)}
if(clk("Loaded")){
Loaded=1
Load1=0
Adr=1
ChrA="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890@#*"
True=1
timer("update",100)
timer("UpdateAddressList",100)
I1[1,string]="PREV"
I1[2,string]="NEXT"
I1[3,string]="FILE"
I1[4,string]="EDIT"
I1[5,string]="VIEW"
I1[6,string]="DETAIL"
I1[7,string]="LOG"
I1[8,string]="HELP"
I1[9,string]="QUIT"
W:egpClear()
W:egpDrawTopLeft(1)
#W:egpBox(1,vec2(1,0),vec2(510,512))
W:egpMaterial(1,"book")
W:egpLine(2,vec2(0,100),vec2(510,100))
W:egpBox(3,vec2(497,93),vec2(14,8))
W:egpLine(4,vec2(0,116),vec2(425,116))
W:egpLine(5,vec2(430,116),vec2(499,116))
W:egpLine(6,vec2(430,116),vec2(430,336))
W:egpBox(7,vec2(497,116),vec2(6,278))
W:egpLine(8,vec2(1,336),vec2(494,336))
W:egpLine(9,vec2(2,349),vec2(494,349))
W:egpLine(10,vec2(2,349),vec2(2,394))
W:egpBoxOutline(11,vec2(2,408),vec2(510,10))
for(I=0,7){
W:egpLine(12+I,vec2(57+I*56.7,409),vec2(57+I*56.7,417))}
W:egpBoxOutline(20,vec2(2,372),vec2(220,22))
for(I=0,5){
W:egpLine(21+I,vec2(33+I*31,372),vec2(33+I*31,393))}
W:egpBoxOutline(27,vec2(270,372),vec2(220,22))
for(I=0,5){
W:egpLine(28+I,vec2(301+I*31,372),vec2(301+I*31,393))}
for(I=0,8){
W:egpText(34+I,I1[I+1,string],vec2(29+I*56.7,413))
W:egpAlign(34+I,1,1)
W:egpFont(34+I,"Marlett",10)
}
W:egpText(43,"BILNEAR SEARCH ALGORITHM",vec2(97,356))
W:egpAlign(43,1,1)
W:egpFont(43,"Marlett",13)
W:egpText(44,"STARGATE ARCHIVE/DATA/PARAMETERS/GLYPHS",vec2(111,365))
W:egpAlign(44,1,1)
W:egpFont(44,"Marlett",8)
W:egpText(45,"ACCESSING PENTAGON BACKUP DATA",vec2(411,356))
W:egpAlign(45,1,1)
W:egpFont(45,"Marlett",8)
W:egpText(46,"CLEARANCE LEVEL 1",vec2(449,364))
W:egpAlign(46,1,1)
W:egpFont(46,"Marlett",8)
W:egpText(47,"1",vec2(230,371))
W:egpAlign(47,1,1)
W:egpFont(47,"Marlett",8)
W:egpText(48,"2",vec2(260,393))
W:egpAlign(48,1,1)
W:egpFont(48,"Marlett",8)
W:egpTriangle(49,vec2(227,369),vec2(223,372),vec2(227,375))
W:egpTriangle(50,vec2(264,390),vec2(268,393),vec2(264,396))
W:egpText(51,"SYSTEM ADMINISTRATOR",vec2(64,95))
W:egpAlign(51,1,1)
W:egpFont(51,"Marlett",10)
W:egpText(54,"MISSION LOG/ARCHIVE/PRIMARY/GATE DATABASE/DETAIL",vec2(143,112))
W:egpAlign(54,1,1)
W:egpFont(54,"Marlett",10)
for(I=0,6){
W:egpBox(55+I,vec2(3,119+I*31),vec2(94,30))
W:egpColor(55+I,vec(208,208,144))}
for(I=0,6){
W:egpBoxOutline(69+I,vec2(250,131+I*31),vec2(178,19))}
for(I=0,6){
W:egpLine(76+I,vec2(276,130+I*31),vec2(276,148+I*31))}
for(I=0,6){
W:egpLine(83+I,vec2(301,130+I*31),vec2(301,148+I*31))}
for(I=0,6){
W:egpLine(90+I,vec2(326,130+I*31),vec2(326,148+I*31))}
for(I=0,6){
W:egpLine(97+I,vec2(351,130+I*31),vec2(351,148+I*31))}
for(I=0,6){
W:egpLine(104+I,vec2(376,130+I*31),vec2(376,148+I*31))}
for(I=0,6){
W:egpLine(111+I,vec2(401,130+I*31),vec2(401,148+I*31))}
for(I=0,6){
W:egpBox(118+I,vec2(414,119+I*31),vec2(14,12)) W:egpColor(118+I,vec(75,196,211))}
for(I=0,6){
W:egpBoxOutline(62+I,vec2(2,119+I*31),vec2(426,30))}
for(I=0,6){
W:egpTriangle(125+I,vec2(424,121+I*31),vec2(417,125+I*31),vec2(424,129+I*31))}
for(I=0,6){W:egpText(139+I,AddressG[1+AdrPlus,string][I+1],vec2(265+I*25,140))
W:egpAlign(139+I,1,1)
W:egpFont(139+I,"Stargate Address Glyphs Concept",15) W:egpColor(139+I,vec(255,255-255*AddressB[1+AdrPlus,number],255-255*AddressB[1+AdrPlus,number]))}
for(I=0,6){W:egpText(146+I,AddressG[2+AdrPlus,string][I+1],vec2(265+I*25,171))
W:egpAlign(146+I,1,1)
W:egpFont(146+I,"Stargate Address Glyphs Concept",15) W:egpColor(146+I,vec(255,255-255*AddressB[2+AdrPlus,number],255-255*AddressB[2+AdrPlus,number]))}
for(I=0,6){W:egpText(153+I,AddressG[3+AdrPlus,string][I+1],vec2(265+I*25,202))
W:egpAlign(153+I,1,1)
W:egpFont(153+I,"Stargate Address Glyphs Concept",15) W:egpColor(153+I,vec(255,255-255*AddressB[3+AdrPlus,number],255-255*AddressB[3+AdrPlus,number]))}
for(I=0,6){W:egpText(160+I,AddressG[4+AdrPlus,string][I+1],vec2(265+I*25,233))
W:egpAlign(160+I,1,1)
W:egpFont(160+I,"Stargate Address Glyphs Concept",15) W:egpColor(160+I,vec(255,255-255*AddressB[4+AdrPlus,number],255-255*AddressB[4+AdrPlus,number]))}
for(I=0,6){W:egpText(167+I,AddressG[5+AdrPlus,string][I+1],vec2(265+I*25,264))
W:egpAlign(167+I,1,1)
W:egpFont(167+I,"Stargate Address Glyphs Concept",15) W:egpColor(167+I,vec(255,255-255*AddressB[5+AdrPlus,number],255-255*AddressB[5+AdrPlus,number]))}
for(I=0,6){W:egpText(174+I,AddressG[6+AdrPlus,string][I+1],vec2(265+I*25,295))
W:egpAlign(174+I,1,1)
W:egpFont(174+I,"Stargate Address Glyphs Concept",15) W:egpColor(174+I,vec(255,255-255*AddressB[6+AdrPlus,number],255-255*AddressB[6+AdrPlus,number]))}
for(I=0,6){W:egpText(181+I,AddressG[7+AdrPlus,string][I+1],vec2(265+I*25,326))
W:egpAlign(181+I,1,1)
W:egpFont(181+I,"Stargate Address Glyphs Concept",15) W:egpColor(181+I,vec(255,255-255*AddressB[7+AdrPlus,number],255-255*AddressB[7+AdrPlus,number]))}
for(I=0,6){W:egpText(188+I,AddressN[I+1+AdrPlus,string],vec2(99,134+I*31))
W:egpAlign(188+I,0,1)
W:egpFont(188+I,"Marlett",13) W:egpColor(188+I,vec(255,255-255*AddressB[I+1+AdrPlus,number],255-255*AddressB[I+1+AdrPlus,number]))}
W:egpBox(195,vec2(431,117),vec2(6,6)) W:egpColor(195,vec(75,196,211))
W:egpBox(196,vec2(431,330),vec2(6,6)) W:egpColor(196,vec(75,196,211))
W:egpText(52,".",vec2(390,95))
W:egpText(53,":",vec2(454,95))
W:egpAlign(52,0,1)
W:egpColor(52,vec(26,93,103))
W:egpFont(52,"Marlett",10)
W:egpAlign(53,0,1)
W:egpFont(53,"Marlett",10)
W:egpColor(53,vec(26,93,103))
timer("REL",500)
for(I=0,6){
W:egpText(132+I,ChrA[randint(1,39)],vec2(18+I*31,384))
W:egpAlign(132+I,1,1)
W:egpFont(132+I,"Stargate Address Glyphs Concept",19)}
for(I=0,6){(W:egpBox(197+I,vec2(2,119+(I)*31),vec2(426,30))) W:egpColor(197+I,vec(0,0,0))}
}
if(Loaded){
if(~KeyDP&KeyDP==9){RB++ timer("RBTR",200) if(RB==2){timer("shutdown",1) Loaded=-1 RB=0 }}
if(clk("RBTR")&RB>0){RB=0}
if(~Key&Key){W:entity():soundPlay(0,1,"alexalx/glebqip/click"+randint(1,4)+".mp3")}
if(~Key|clk("Loaded")|clk("REL")|~NewCol){
if(AddressG:count()>7){if(AdrPlus>AddressG:count()-7){AdrPlus=AddressG:count()-7}}
if(AddressG:count()<=7){AdrPlus=0}
if(Adr>AddressG:count()&AddressG:count()>0){Adr=AddressG:count()}
if(AddressG:count()>=1){W:egpAlpha(197,0)} else {W:egpAlpha(197,255)} if(AddressG:count()>=2){W:egpAlpha(198,0)} else {W:egpAlpha(198,255)} if(AddressG:count()>=3){W:egpAlpha(199,0)} else {W:egpAlpha(199,255)} if(AddressG:count()>=4){W:egpAlpha(200,0)} else {W:egpAlpha(200,255)} if(AddressG:count()>=5){W:egpAlpha(201,0)} else {W:egpAlpha(201,255)} if(AddressG:count()>=6){W:egpAlpha(202,0)} else {W:egpAlpha(202,255)} if(AddressG:count()>=7){W:egpAlpha(203,0)} else {W:egpAlpha(203,255)}
AddressO=AddressG:concat()+""+AddressN:concat()+""+AddressB:concat()
for(I=0,6){W:egpSetText(139+I,AddressG[1+AdrPlus,string][I+1]) W:egpColor(139+I,vec(255,255-255*AddressB[1+AdrPlus,number],255-255*AddressB[1+AdrPlus,number]))}
for(I=0,6){W:egpSetText(146+I,AddressG[2+AdrPlus,string][I+1]) W:egpColor(146+I,vec(255,255-255*AddressB[2+AdrPlus,number],255-255*AddressB[2+AdrPlus,number]))}
for(I=0,6){W:egpSetText(153+I,AddressG[3+AdrPlus,string][I+1]) W:egpColor(153+I,vec(255,255-255*AddressB[3+AdrPlus,number],255-255*AddressB[3+AdrPlus,number]))}
for(I=0,6){W:egpSetText(160+I,AddressG[4+AdrPlus,string][I+1]) W:egpColor(160+I,vec(255,255-255*AddressB[4+AdrPlus,number],255-255*AddressB[4+AdrPlus,number]))}
for(I=0,6){W:egpSetText(167+I,AddressG[5+AdrPlus,string][I+1]) W:egpColor(167+I,vec(255,255-255*AddressB[5+AdrPlus,number],255-255*AddressB[5+AdrPlus,number]))}
for(I=0,6){W:egpSetText(174+I,AddressG[6+AdrPlus,string][I+1]) W:egpColor(174+I,vec(255,255-255*AddressB[6+AdrPlus,number],255-255*AddressB[6+AdrPlus,number]))}
for(I=0,6){W:egpSetText(181+I,AddressG[7+AdrPlus,string][I+1]) W:egpColor(181+I,vec(255,255-255*AddressB[7+AdrPlus,number],255-255*AddressB[7+AdrPlus,number]))}
for(I=0,6){W:egpSetText(188+I,AddressN[I+1+AdrPlus,string]) W:egpColor(188+I,vec(255,255-255*AddressB[I+1+AdrPlus,number],255-255*AddressB[I+1+AdrPlus,number]))}
local Addr=0
if(Adr==1){W:egpColor(62,vec(255,0,0))} else {W:egpColor(62,vec(0,153,184-30*NewCol))}
if(Adr==2){W:egpColor(63,vec(255,0,0))} else {W:egpColor(63,vec(0,153,184-30*NewCol))}
if(Adr==3){W:egpColor(64,vec(255,0,0))} else {W:egpColor(64,vec(0,153,184-30*NewCol))}
if(Adr==4){W:egpColor(65,vec(255,0,0))} else {W:egpColor(65,vec(0,153,184-30*NewCol))}
if(Adr==5){W:egpColor(66,vec(255,0,0))} else {W:egpColor(66,vec(0,153,184-30*NewCol))}
if(Adr==6){W:egpColor(67,vec(255,0,0))} else {W:egpColor(67,vec(0,153,184-30*NewCol))}
if(Adr==7){W:egpColor(68,vec(255,0,0))} else {W:egpColor(68,vec(0,153,184-30*NewCol))}
#if((PosX>431&PosY>117)&(PosX<437&PosY<123)&KeyUse){if(AdrPlus!=0){AdrPlus--}}
#if((PosX>431&PosY>330)&(PosX<437&PosY<336)&KeyUse){if(AddressG:count()>7 & AdrPlus<=AddressG:count()-8){AdrPlus++}}
}
if(AddressG:count()>7){if(~Key&Key==18&Adr<7){Adr++}} if(AddressG:count()<=7){if(~Key&Key==18&Adr<AddressG:count()){Adr++}}
if(~Key&Key==17&Adr>1){Adr--}
if(~Key&Key==20&AdrPlus<AddressG:count()-7){AdrPlus++}
if(~Key&Key==19&AdrPlus>0){AdrPlus--}
if(~Key&Key==13){AddressBook=AddressG[Adr+AdrPlus,string]} if(~Key&Key!=13){AddressBook=""}
if(clk("update")){
#if((PosX>414&PosY>119)&(PosX<428&PosY<131)&KeyUse){Addr=1} elseif((PosX>414&PosY>150)&(PosX<428&PosY<162)&KeyUse){Addr=1} elseif((PosX>414&PosY>181)&(PosX<428&PosY<193)&KeyUse){Addr=1} elseif((PosX>414&PosY>212)&(PosX<428&PosY<224)&KeyUse){Addr=1} elseif((PosX>414&PosY>243)&(PosX<428&PosY<255)&KeyUse){Addr=1} elseif((PosX>414&PosY>274)&(PosX<428&PosY<286)&KeyUse){Addr=1} elseif((PosX>414&PosY>305)&(PosX<428&PosY<317)&KeyUse){Addr=1} else {Addr=0}
#if(Addr){AddressOut=AddressG[Adr+AdrPlus,string]}
for(I=0,6){
W:egpSetText(132+I,ChrA[randint(1,39)])}
Day=toString(time("day"))
Month=toString(time("month"))
Year=toString(time("year"))
Hours=toString(time("hour"))
Min=toString(time("min"))
Sec=toString(time("sec"))
if(Month:length()==1){Month="0"+Month}
if(Hours:length()==1){Hours="0"+Hours}
if(Min:length()==1){Min="0"+Min}
if(Sec:length()==1){Sec="0"+Sec}
W:egpSetText(52,Day+"."+Month+"."+Year)
W:egpSetText(53,Hours+":"+Min+":"+Sec)
timer("update",250)
}
if(clk("Loaded")|~NewCol){
for(I=2,131)
{
if(NewCol){
if((I!=3&I!=7&I<43&I!=44&I!=45)|(I>50&I<55)|(I>61&I<118)|(I>124&I<132)){W:egpColor(I,vec(0,153,154))}}#vec(26,93,103)
if(!NewCol){
if((I!=3&I!=7&I<43&I!=44&I!=45)|(I>50&I<55)|(I>61&I<118)|(I>124&I<132)){W:egpColor(I,vec(0,153,184))}}
if((I>=43&I<=48)){W:egpColor(I,vec(215,239,177))}
if(I==3|I==7|(I>48&I<51)){W:egpColor(I,vec(75,196,211))}
}
}
}
if(clk("errpip")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip1",200)}
if(clk("errpip1")){soundVolume(12,0) soundStop(12,0) timer("errpip2",200)}
if(clk("errpip2")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip3",200)}
if(clk("errpip3")){soundVolume(12,0) soundStop(12,0) timer("errpip4",200)}
if(clk("errpip4")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip5",200)}
if(clk("errpip5")){soundVolume(12,0) soundStop(12,0)}
