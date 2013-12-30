# Version 1.6
# Author glebqip(RUS)
# Support thread: http://sg-carterpack.com/forums/topic/sgc-dialing-computer-v1-e2/

@name SGC Chat
@inputs  SG:wirelink Unlink
@outputs
@persist Iris Active Chevron Inbound Open ChevronLocked
@persist DialString:string DialingMode StartStringDial Close
@persist Inc Loc IDc1 IDc2
@persist AAA BBB ETdp:entity ETIDdp DPT:table IDCT:table ETidc:entity ETIDidc Overload IDCName:string IDCStatus
@trigger
interval(100)
findByClass("gmod_wire_expression2")
if(AAA!=2)
{
ETidc=findClosest(entity():pos())
ETIDidc=ETidc:id()
}
if(changed(ETIDidc))
{
if(AAA!=2){AAA=0}
if(BBB!=2){BBB=0}
}
if(gTable("IDCsv1_"+ETidc:id())[1,string]!="IDCsv1"){findExcludeEntity(ETidc)}
if(gTable("IDCsv1_"+ETidc:id())[1,string]=="IDCsv1"&!AAA)
{
hint("Chat:Founded a IDC Chip with "+ETidc:id()+" ID by "+ETidc:owner():name()+", press Use to link",10) AAA=1
}
if(changed(owner():keyUse())&gTable("IDCsv1_"+ETidc:id())[1,string]=="IDCsv1"&owner():keyUse()&AAA==1)
{
hint("Chat:Linked to IDC Chip with "+ETidc:id()+" ID by "+ETidc:owner():name(),10) AAA=2 findClearBlackEntityList()
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
hint("Chat:Founded a Dialing Computer Chip with "+ETdp:id()+" ID by "+ETdp:owner():name()+", press Use to link",10) BBB=1
}
if(changed(owner():keyUse())&gTable("DPv1_"+ETdp:id())[1,string]=="DPv1"&owner():keyUse()&BBB==1)
{
hint("Chat:Linked to Dialing Computer Chip with "+ETdp:id()+" ID by "+ETdp:owner():name(),10) BBB=2 findClearBlackEntityList()
}
}
if(~Unlink&Unlink&AAA==2)
{
AAA=0
hint("Chat:Unlinked from IDC table",10)
}
if(~Unlink&Unlink&BBB==2)
{
BBB=0
hint("Chat:Unlinked from Dialing Computer Chip",10)
}
if(BBB==2&ETdp:id()!=0){DPT=gTable("DPv1_"+ETdp:id())[2,table]}
if(AAA==2&ETidc:id()!=0){IDCT=gTable("IDCsv1_"+ETidc:id())[2,table]}
Iris=SG:stargateIrisActive()
Overload=DPT["Overload",number]
IDCName=IDCT["IDCName",string]
IDCStatus=IDCT["IDCStatus",number]
Active=SG:stargateGetWire("Active")
Chevron=SG:stargateGetWire("Chevron")
Inbound=SG:stargateGetWire("Inbound")
Open=SG:stargateGetWire("Open")
ChevronLocked=SG:stargateGetWire("Chevron Locked")
DialString=SG:stargateGetWireStringInput("Dial String")
DialingMode=SG:stargateGetWireInput("Dial Mode")
StartStringDial=SG:stargateGetWireInput("Start String Dial")
Close=SG:stargateGetWireInput("Close")
if(changed(Active)&Active&!Open&!Inbound&!StartStringDial){timer("USA",50)} if(clk("USA")&Active&!Open&!Inbound&!StartStringDial){concmd("say Unauthorized stargate activation!")}
if(changed(StartStringDial)&StartStringDial&DialingMode==0) {concmd("say Starting dialing sequence to:"+DialString)}
if(changed(StartStringDial)&StartStringDial&DialingMode==1) {concmd("say Starting accelerated dialing sequence to:"+DialString)}
if(changed(StartStringDial)&StartStringDial&DialingMode==2) {concmd("say Nox dial to:"+DialString)}
if(changed(Inbound)&Inbound) {concmd("say INCOMING WORMHOLE! Closing the IRIS") Inc=1}
if(!Inbound&changed(Close)&Close&!Open){concmd("say Aborting the dialing sequence.")}
if(changed(Close)&Close&Open){concmd("say Closing the gate...") timer("CL",3000)}
if(clk("CL")&Open){concmd("say Shutdown sequence incomplete!!!")}
if(changed(Chevron)&Chevron){timer("CHEV",150)}
if(clk("CHEV")){
if(Chevron>0&Chevron<7&!ChevronLocked&!Inbound){concmd("say Chevron "+Chevron:toString()+" encoded.")}
elseif(Chevron>=7&Chevron<9&!ChevronLocked&!Inbound){concmd("say Chevron "+Chevron:toString()+"... is encoding.")}
elseif(Chevron>=0&ChevronLocked&!Inbound){concmd("say Sequence complete! Chevron "+Chevron:toString()+" locked!") Loc=1}
elseif(Chevron<-6&!ChevronLocked&!Inbound){concmd("say Sequence complete! Chevron "+abs(Chevron):toString()+"... will not lock!")}}
if(changed(Open)&Open==1&!Inbound){concmd("say Wormhole established!") Loc=0}
if(changed(Open)&Open==1&Inbound){concmd("say Incoming wormhole established!") timer("IDC1",10000)}
if(clk("IDC1")&!IDc2&Inbound&Open){concmd("say No IDC code for now...") IDc1=1}
if(changed(Open)&!Open&Inc){concmd("say Incoming wormhole disengaged!") Inc=0}
if(changed(Open)&!Open&!Inc){concmd("say Wormhole disengaged!")}
if(changed(Active)&!Active&Loc){concmd("say Gate is occupied!") Loc=0}
if(changed(Active)&!Active){IDc2=0 IDc1=0 Loc=0}
if(changed(Iris)&Iris==1){timer("ciris",500)} if(clk("ciris")){concmd("say Closing the IRIS")}
if(changed(Iris)&Iris==0){timer("oiris",500)} if(clk("oiris")){concmd("say Opening the IRIS")}
if(changed(Open)&Open){Loc=0}
if(changed(IDCStatus)&IDCStatus==1&!IDc1){concmd("say Receiving the IDC!") IDc2=1}
if(changed(IDCStatus)&IDCStatus==1&IDc1){concmd("say Ok, we receiving the IDC!")}
if(changed(IDCStatus)&IDCStatus==2){concmd("say Analyzing the IDC!")}
if(changed(IDCStatus)&IDCStatus==3){concmd("say Signal analyzed! This is "+IDCName+", Opening the IRIS!")}
if(changed(IDCStatus)&IDCStatus==4){concmd("say Signal analyzed! This is "+IDCName+", but code is expired!")}
if(changed(IDCStatus)&IDCStatus==5){concmd("say Signal analyzed! Unknown signal!")}
if(changed(Overload)&Overload==1){timer("over",500)} if(clk("over")){concmd("say Hmm, energy flux is not normal! Gate may explode!")}
if(changed(Overload)&Overload==2){concmd("say Shit, gate will explode after 30 seconds!")}