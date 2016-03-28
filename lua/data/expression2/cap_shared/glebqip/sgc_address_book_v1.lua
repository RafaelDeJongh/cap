# Version 1.6
# Author glebqip(RUS)
# Created 30.11.13 Updated 30.12.13
# This is Stargate Address Book from first 2 Stargate-SG1 seasons.
# This chip need a wire_expression2_unlimited 1, wire_egp_max_bytes_per_seconds 13000 and on server.
# Support thread: http://sg-carterpack.com/forums/topic/sgc-dialing-computer-v1-e2/

@name SGC Address Book v1.0
@inputs EGP:wirelink SG:wirelink Key Unlink
@outputs True
@persist RAM Pip Load1 LoadOver Loaded RB Loaded1 STD2:string STD STD1 IDs1
@persist I1:table Day:string Month:string Year:string Hours:string Min:string Sec:string ChrA:string Pos:vector2
@persist AddressN:array AddressG:array AddressB:array AddressO:string AddressList:table AdrPlus Adr
@persist AAA GT:gtable ABt:table DPt:table AddressBook:string KeyDP KeyDPUser:entity DPL Start NewCol ETIDdp ETdp:entity
@trigger
if(~EGP&EGP){reset()}
findByClass("gmod_wire_expression2")
if(AAA!=2)
{
ETdp=findClosest(entity():pos())
ETIDdp=ETdp:id()
}
if(gTable("DPv1_"+ETdp:id())[1,string]!="DPv1"){findExcludeEntity(ETdp)}
if(gTable("DPv1_"+ETdp:id())[1,string]=="DPv1"&!AAA)
{
hint("AB:Founded a Dialing Computer Chip with "+ETdp:id()+" ID by "+ETdp:owner():name()+", press Use to link",10) AAA=1
}
if(changed(owner():keyUse())&gTable("DPv1_"+ETdp:id())[1,string]=="DPv1"&owner():keyUse()&AAA==1)
{
hint("AB:Linked to Dialing Computer Chip with "+ETdp:id()+" ID by "+ETdp:owner():name(),10) AAA=2 findClearBlackEntityList()
}
if(~Unlink&Unlink&AAA==2)
{
AAA=0
hint("AB:Unlinked from Dialing Computer Chip",10)
}
if(!Loaded){timer("update",200)}
if(clk("update")&!Loaded){timer("update",200)}
if(AAA==2&ETdp:id()!=0){DPt=gTable("DPv1_"+ETdp:id())[2,table]} #hint(ETdp:id():toString(),10) #if(AAA==2&ETdp:id()==0){hint("ERROR! Dialing Computer Chip is disappeared! Chip unlinked and shutdowned!",10) Loaded=0 timer("shutdown1",1) BBB=0}
NewCol=DPt["NewCol",number]
DPL=DPt["DPL",number]
Start=DPt["Start",number]
KeyDP=DPt["Key",number]
KeyDPUser=DPt["KeyUser",entity]
if(clk("UpdateAddressList")){
AddressG:clear()
AddressN:clear()
AddressB:clear()
AddressList=SG:stargateAddressList()
for(I=1,AddressList:count()) {
V = AddressList[I-1,array]
Address = V[1,string] # Get address
Name = V[2,string] # Get name
Blocked = V[3,number] # Get blocked
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
if(first()|dupefinished()|clk("shutdown1")){EGP:egpClear() Loaded1=0}
if(((changed(Start)|first()|dupefinished())&Start)&Loaded1==0)
{
if(Start<=1|Start==3){LoadOver=0}
if(Start==2){LoadOver=1}
RingSpeedMode=1
EGP:egpClear()
for(I=0,8){EGP:egpText(1+I,"",vec2(5,10+I*12)) EGP:egpAlign(1+I,0,1) EGP:egpFont(1+I,"Console",15)}
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
if(clk("LD5")&KeyDP==-1){
EGP:egpSetText(5,"Error! Keyboard not detected! Waiting keyboard connect.") if(!Pip){timer("errpip",1) Pip=1} EGP:egpColor(5,vec(255,0,0)) timer("LD5",1000)}
if(clk("LD5")&KeyDP!=-1){EGP:egpSetText(5,"Keyboard... OK!") EGP:egpColor(5,vec(255,255,255)) Pip=0 timer("LD6",randint(800,1300))}
if(egpMaxObjects()<196&changed(KeyDP)&KeyDP==13&IDs1){IDsOverride=1 IDs1=0}
if(clk("LD6")&egpMaxObjects()>=196&!IDsOverride){EGP:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's OK!") EGP:egpColor(6,vec(255,255,255)) timer("LD7",randint(50,300)) Pip=0}
if(clk("LD6")&(egpMaxObjects()<196&IDsOverride)){EGP:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's Override ID's protection!") EGP:egpColor(6,vec(255,255,0)) timer("LD7",randint(50,300)) Pip=0}
if(clk("LD6")&egpMaxObjects()<196&!IDsOverride){IDs1=1 EGP:egpSetText(6,"GPUMemory:"+egpMaxObjects():toString()+" ID's. Need a 196 ID's. Waiting a wire_egp_max_objects 196!") if(!Pip){timer("errpip",1) Pip=1} timer("LD6",150) EGP:egpColor(6,vec(255,0,0))}
if(clk("LD7")&!->SG){if(!Pip){timer("errpip",1) Pip=1} EGP:egpSetText(7,"Can't connect to Address Database!!!") EGP:egpColor(7,vec(255,0,0)) timer("LD7",100)}
if(clk("LD7")&->SG){Pip=0 EGP:egpSetText(7,"Connected to Address Database") EGP:egpColor(7,vec(255,255,255)) timer("LD8",100)}
if(clk("LD8")){Pip=0 Load1=0 EGP:egpSetText(8,"Address Book build 1.241.15 v1 07.12.13 is loading...") EGP:egpColor(8,vec(255,255,255)) timer("LD9",randint(100,1000))}
if(clk("LD9")&Loaded!=1&Load1<100){Load1+=randint(4,12) EGP:egpSetText(8,"Address Book build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD9",randint(100,300))}
if(Load1>=100){EGP:egpSetText(8,"Address Book build 1.241.15 v1 07.12.13 is loading... 100%") if(DPL){timer("Loaded",randint(50,700))}else{timer("LD91",randint(100,300))}}
if(clk("LD91")&!DPL&DPt:count()>0){if(!Pip){timer("errpip",1) Pip=1} EGP:egpSetText(9,"Waiting Dialing Programm...") EGP:egpColor(9,vec(255,255,0)) timer("LD91",100)}
if(clk("LD91")&(DPL|DPt:count()==0)){Pip=0 timer("Loaded",randint(50,700))}}
if(LoadOver){
if(clk("LD1")){soundVolume(12,0) soundStop(12,0.001) Load1=0 EGP:egpSetText(1,"Address Book build 1.241.15 v1 07.12.13 is loading...") EGP:egpColor(1,vec(255,255,255)) timer("LD11",randint(100,1000))}
if(clk("LD11")&Loaded!=1&Load1<100){Load1+=randint(4,12) EGP:egpSetText(1,"Address Book build 1.241.15 v1 07.12.13 is loading... "+Load1+"%") timer("LD11",randint(100,300))}
if(Load1>=100){EGP:egpSetText(1,"Address Book build 1.241.15 v1 07.12.13 is loading... 100%") timer("Loaded",randint(50,700))}}
if(clk("shutdown")){
STD1=randint(30,80)
EGP:egpClear()
STD2=""
STD=0
EGP:egpText(1,"",vec2(5,10)) EGP:egpAlign(1,0,1) EGP:egpFont(1,"Console",15)
timer("STD1",randint(50,500))}
if(clk("STD1")&STD<=STD1){STD2+="." if(STD2:length()>3){STD2=""} EGP:egpSetText(1,"Shutting down"+STD2) STD++ timer("STD1",150)}
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
EGP:egpClear()
EGP:egpDrawTopLeft(1)
#EGP:egpBox(1,vec2(1,0),vec2(510,512))
EGP:egpMaterial(1,"book")
EGP:egpLine(2,vec2(0,100),vec2(510,100))
EGP:egpBox(3,vec2(497,93),vec2(14,8))
EGP:egpLine(4,vec2(0,116),vec2(425,116))
EGP:egpLine(5,vec2(430,116),vec2(499,116))
EGP:egpLine(6,vec2(430,116),vec2(430,336))
EGP:egpBox(7,vec2(497,116),vec2(6,278))
EGP:egpLine(8,vec2(1,336),vec2(494,336))
EGP:egpLine(9,vec2(2,349),vec2(494,349))
EGP:egpLine(10,vec2(2,349),vec2(2,394))
EGP:egpBoxOutline(11,vec2(2,408),vec2(510,10))
for(I=0,7){
EGP:egpLine(12+I,vec2(57+I*56.7,409),vec2(57+I*56.7,417))}
EGP:egpBoxOutline(20,vec2(2,372),vec2(220,22))
for(I=0,5){
EGP:egpLine(21+I,vec2(33+I*31,372),vec2(33+I*31,393))}
EGP:egpBoxOutline(27,vec2(270,372),vec2(220,22))
for(I=0,5){
EGP:egpLine(28+I,vec2(301+I*31,372),vec2(301+I*31,393))}
for(I=0,8){
EGP:egpText(34+I,I1[I+1,string],vec2(29+I*56.7,413))
EGP:egpAlign(34+I,1,1)
EGP:egpFont(34+I,"Marlett",10)
}
EGP:egpText(43,"BILNEAR SEARCH ALGORITHM",vec2(97,356))
EGP:egpAlign(43,1,1)
EGP:egpFont(43,"Marlett",13)
EGP:egpText(44,"STARGATE ARCHIVE/DATA/PARAMETERS/GLYPHS",vec2(111,365))
EGP:egpAlign(44,1,1)
EGP:egpFont(44,"Marlett",8)
EGP:egpText(45,"ACCESSING PENTAGON BACKUP DATA",vec2(411,356))
EGP:egpAlign(45,1,1)
EGP:egpFont(45,"Marlett",8)
EGP:egpText(46,"CLEARANCE LEVEL 1",vec2(449,364))
EGP:egpAlign(46,1,1)
EGP:egpFont(46,"Marlett",8)
EGP:egpText(47,"1",vec2(230,371))
EGP:egpAlign(47,1,1)
EGP:egpFont(47,"Marlett",8)
EGP:egpText(48,"2",vec2(260,393))
EGP:egpAlign(48,1,1)
EGP:egpFont(48,"Marlett",8)
EGP:egpTriangle(49,vec2(227,369),vec2(223,372),vec2(227,375))
EGP:egpTriangle(50,vec2(264,390),vec2(268,393),vec2(264,396))
EGP:egpText(51,"SYSTEM ADMINISTRATOR",vec2(64,95))
EGP:egpAlign(51,1,1)
EGP:egpFont(51,"Marlett",10)
EGP:egpText(54,"MISSION LOG/ARCHIVE/PRIMARY/GATE DATABASE/DETAIL",vec2(143,112))
EGP:egpAlign(54,1,1)
EGP:egpFont(54,"Marlett",10)
for(I=0,6){
EGP:egpBox(55+I,vec2(3,119+I*31),vec2(94,30))
EGP:egpColor(55+I,vec(208,208,144))}
for(I=0,6){
EGP:egpBoxOutline(69+I,vec2(250,131+I*31),vec2(178,19))}
for(I=0,6){
EGP:egpLine(76+I,vec2(276,130+I*31),vec2(276,148+I*31))}
for(I=0,6){
EGP:egpLine(83+I,vec2(301,130+I*31),vec2(301,148+I*31))}
for(I=0,6){
EGP:egpLine(90+I,vec2(326,130+I*31),vec2(326,148+I*31))}
for(I=0,6){
EGP:egpLine(97+I,vec2(351,130+I*31),vec2(351,148+I*31))}
for(I=0,6){
EGP:egpLine(104+I,vec2(376,130+I*31),vec2(376,148+I*31))}
for(I=0,6){
EGP:egpLine(111+I,vec2(401,130+I*31),vec2(401,148+I*31))}
for(I=0,6){
EGP:egpBox(118+I,vec2(414,119+I*31),vec2(14,12)) EGP:egpColor(118+I,vec(75,196,211))}
for(I=0,6){
EGP:egpBoxOutline(62+I,vec2(2,119+I*31),vec2(426,30))}
for(I=0,6){
EGP:egpTriangle(125+I,vec2(424,121+I*31),vec2(417,125+I*31),vec2(424,129+I*31))}
for(I=0,6){EGP:egpText(139+I,AddressG[1+AdrPlus,string][I+1],vec2(265+I*25,140))
EGP:egpAlign(139+I,1,1)
EGP:egpFont(139+I,"Stargate Address Glyphs Concept",15) EGP:egpColor(139+I,vec(255,255-255*AddressB[1+AdrPlus,number],255-255*AddressB[1+AdrPlus,number]))}
for(I=0,6){EGP:egpText(146+I,AddressG[2+AdrPlus,string][I+1],vec2(265+I*25,171))
EGP:egpAlign(146+I,1,1)
EGP:egpFont(146+I,"Stargate Address Glyphs Concept",15) EGP:egpColor(146+I,vec(255,255-255*AddressB[2+AdrPlus,number],255-255*AddressB[2+AdrPlus,number]))}
for(I=0,6){EGP:egpText(153+I,AddressG[3+AdrPlus,string][I+1],vec2(265+I*25,202))
EGP:egpAlign(153+I,1,1)
EGP:egpFont(153+I,"Stargate Address Glyphs Concept",15) EGP:egpColor(153+I,vec(255,255-255*AddressB[3+AdrPlus,number],255-255*AddressB[3+AdrPlus,number]))}
for(I=0,6){EGP:egpText(160+I,AddressG[4+AdrPlus,string][I+1],vec2(265+I*25,233))
EGP:egpAlign(160+I,1,1)
EGP:egpFont(160+I,"Stargate Address Glyphs Concept",15) EGP:egpColor(160+I,vec(255,255-255*AddressB[4+AdrPlus,number],255-255*AddressB[4+AdrPlus,number]))}
for(I=0,6){EGP:egpText(167+I,AddressG[5+AdrPlus,string][I+1],vec2(265+I*25,264))
EGP:egpAlign(167+I,1,1)
EGP:egpFont(167+I,"Stargate Address Glyphs Concept",15) EGP:egpColor(167+I,vec(255,255-255*AddressB[5+AdrPlus,number],255-255*AddressB[5+AdrPlus,number]))}
for(I=0,6){EGP:egpText(174+I,AddressG[6+AdrPlus,string][I+1],vec2(265+I*25,295))
EGP:egpAlign(174+I,1,1)
EGP:egpFont(174+I,"Stargate Address Glyphs Concept",15) EGP:egpColor(174+I,vec(255,255-255*AddressB[6+AdrPlus,number],255-255*AddressB[6+AdrPlus,number]))}
for(I=0,6){EGP:egpText(181+I,AddressG[7+AdrPlus,string][I+1],vec2(265+I*25,326))
EGP:egpAlign(181+I,1,1)
EGP:egpFont(181+I,"Stargate Address Glyphs Concept",15) EGP:egpColor(181+I,vec(255,255-255*AddressB[7+AdrPlus,number],255-255*AddressB[7+AdrPlus,number]))}
for(I=0,6){EGP:egpText(188+I,AddressN[I+1+AdrPlus,string],vec2(99,134+I*31))
EGP:egpAlign(188+I,0,1)
EGP:egpFont(188+I,"Marlett",13) EGP:egpColor(188+I,vec(255,255-255*AddressB[I+1+AdrPlus,number],255-255*AddressB[I+1+AdrPlus,number]))}
EGP:egpBox(195,vec2(431,117),vec2(6,6)) EGP:egpColor(195,vec(75,196,211))
EGP:egpBox(196,vec2(431,330),vec2(6,6)) EGP:egpColor(196,vec(75,196,211))
EGP:egpText(52,".",vec2(390,95))
EGP:egpText(53,":",vec2(454,95))
EGP:egpAlign(52,0,1)
EGP:egpColor(52,vec(26,93,103))
EGP:egpFont(52,"Marlett",10)
EGP:egpAlign(53,0,1)
EGP:egpFont(53,"Marlett",10)
EGP:egpColor(53,vec(26,93,103))
timer("REL",500)
for(I=0,6){
EGP:egpText(132+I,ChrA[randint(1,39)],vec2(18+I*31,384))
EGP:egpAlign(132+I,1,1)
EGP:egpFont(132+I,"Stargate Address Glyphs Concept",19)}
for(I=0,6){(EGP:egpBox(197+I,vec2(2,119+(I)*31),vec2(426,30))) EGP:egpColor(197+I,vec(0,0,0))}
}
if(Loaded){
if(changed(KeyDP)&KeyDP==9&KeyDPUser==owner()){RB++ timer("RBTR",500) if(RB==2){timer("shutdown",1) Loaded=-1 RB=0 }}
if(clk("RBTR")&RB>0){RB=0}
if(~Key&Key){EGP:entity():soundPlay(0,1,"alexalx/glebqip/click"+randint(1,4)+".mp3")}
if(~Key|clk("Loaded")|clk("REL")|changed(NewCol)){
if(AddressG:count()>7){if(AdrPlus>AddressG:count()-7){AdrPlus=AddressG:count()-7}}
if(AddressG:count()<=7){AdrPlus=0}
if(Adr>AddressG:count()&AddressG:count()>0){Adr=AddressG:count()}
if(AddressG:count()>=1){EGP:egpAlpha(197,0)} else {EGP:egpAlpha(197,255)} if(AddressG:count()>=2){EGP:egpAlpha(198,0)} else {EGP:egpAlpha(198,255)} if(AddressG:count()>=3){EGP:egpAlpha(199,0)} else {EGP:egpAlpha(199,255)} if(AddressG:count()>=4){EGP:egpAlpha(200,0)} else {EGP:egpAlpha(200,255)} if(AddressG:count()>=5){EGP:egpAlpha(201,0)} else {EGP:egpAlpha(201,255)} if(AddressG:count()>=6){EGP:egpAlpha(202,0)} else {EGP:egpAlpha(202,255)} if(AddressG:count()>=7){EGP:egpAlpha(203,0)} else {EGP:egpAlpha(203,255)}
AddressO=AddressG:concat()+""+AddressN:concat()+""+AddressB:concat()
for(I=0,6){EGP:egpSetText(139+I,AddressG[1+AdrPlus,string][I+1]) EGP:egpColor(139+I,vec(255,255-255*AddressB[1+AdrPlus,number],255-255*AddressB[1+AdrPlus,number]))}
for(I=0,6){EGP:egpSetText(146+I,AddressG[2+AdrPlus,string][I+1]) EGP:egpColor(146+I,vec(255,255-255*AddressB[2+AdrPlus,number],255-255*AddressB[2+AdrPlus,number]))}
for(I=0,6){EGP:egpSetText(153+I,AddressG[3+AdrPlus,string][I+1]) EGP:egpColor(153+I,vec(255,255-255*AddressB[3+AdrPlus,number],255-255*AddressB[3+AdrPlus,number]))}
for(I=0,6){EGP:egpSetText(160+I,AddressG[4+AdrPlus,string][I+1]) EGP:egpColor(160+I,vec(255,255-255*AddressB[4+AdrPlus,number],255-255*AddressB[4+AdrPlus,number]))}
for(I=0,6){EGP:egpSetText(167+I,AddressG[5+AdrPlus,string][I+1]) EGP:egpColor(167+I,vec(255,255-255*AddressB[5+AdrPlus,number],255-255*AddressB[5+AdrPlus,number]))}
for(I=0,6){EGP:egpSetText(174+I,AddressG[6+AdrPlus,string][I+1]) EGP:egpColor(174+I,vec(255,255-255*AddressB[6+AdrPlus,number],255-255*AddressB[6+AdrPlus,number]))}
for(I=0,6){EGP:egpSetText(181+I,AddressG[7+AdrPlus,string][I+1]) EGP:egpColor(181+I,vec(255,255-255*AddressB[7+AdrPlus,number],255-255*AddressB[7+AdrPlus,number]))}
for(I=0,6){EGP:egpSetText(188+I,AddressN[I+1+AdrPlus,string]) EGP:egpColor(188+I,vec(255,255-255*AddressB[I+1+AdrPlus,number],255-255*AddressB[I+1+AdrPlus,number]))}
local Addr=0
if(Adr==1){EGP:egpColor(62,vec(255,0,0))} else {EGP:egpColor(62,vec(0,153,184-30*NewCol))}
if(Adr==2){EGP:egpColor(63,vec(255,0,0))} else {EGP:egpColor(63,vec(0,153,184-30*NewCol))}
if(Adr==3){EGP:egpColor(64,vec(255,0,0))} else {EGP:egpColor(64,vec(0,153,184-30*NewCol))}
if(Adr==4){EGP:egpColor(65,vec(255,0,0))} else {EGP:egpColor(65,vec(0,153,184-30*NewCol))}
if(Adr==5){EGP:egpColor(66,vec(255,0,0))} else {EGP:egpColor(66,vec(0,153,184-30*NewCol))}
if(Adr==6){EGP:egpColor(67,vec(255,0,0))} else {EGP:egpColor(67,vec(0,153,184-30*NewCol))}
if(Adr==7){EGP:egpColor(68,vec(255,0,0))} else {EGP:egpColor(68,vec(0,153,184-30*NewCol))}
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
EGP:egpSetText(132+I,ChrA[randint(1,39)])}
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
EGP:egpSetText(52,Day+"."+Month+"."+Year)
EGP:egpSetText(53,Hours+":"+Min+":"+Sec)
timer("update",250)
}
if(clk("Loaded")|changed(NewCol)){
for(I=2,131)
{
if(NewCol){
if((I!=3&I!=7&I<43&I!=44&I!=45)|(I>50&I<55)|(I>61&I<118)|(I>124&I<132)){EGP:egpColor(I,vec(0,153,154))}}#vec(26,93,103)
if(!NewCol){
if((I!=3&I!=7&I<43&I!=44&I!=45)|(I>50&I<55)|(I>61&I<118)|(I>124&I<132)){EGP:egpColor(I,vec(0,153,184))}}
if((I>=43&I<=48)){EGP:egpColor(I,vec(215,239,177))}
if(I==3|I==7|(I>48&I<51)){EGP:egpColor(I,vec(75,196,211))}
}
}
}
if(clk("errpip")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip1",200)}
if(clk("errpip1")){soundVolume(12,0) soundStop(12,0) timer("errpip2",200)}
if(clk("errpip2")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip3",200)}
if(clk("errpip3")){soundVolume(12,0) soundStop(12,0) timer("errpip4",200)}
if(clk("errpip4")){soundVolume(12,0.6) soundPlay(12,10,"synth/square_440.wav") timer("errpip5",200)}
if(clk("errpip5")){soundVolume(12,0) soundStop(12,0)}
ABt["AddressBook",string]=AddressBook
GT = gTable("ABv1_"+entity():id())
GT[1,string]="ABv1"
GT[2,table]=ABt