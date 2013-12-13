# Version 1.0
# Author glebqip(RUS)

@name SGC_Chat
@inputs Iris StartStringDial DialString:string Active Chevron Inbound Open ChevronLocked IDCName:string IDCStatus Overload Close DialingMode
@outputs
@persist Inc Loc IDc1 IDc2
@trigger

if(~Active&Active&!Open&!Inbound&!StartStringDial){timer("USA",50)} if(clk("USA")&Active&!Open&!Inbound&!StartStringDial){concmd("say Unauthorized stargate activation!")}
if(~StartStringDial&StartStringDial&DialingMode==0) {concmd("say Starting dialing sequence to:"+DialString)}
if(~StartStringDial&StartStringDial&DialingMode==1) {concmd("say Starting accelerated dialing sequence to:"+DialString)}
if(~StartStringDial&StartStringDial&DialingMode==2) {concmd("say Nox dial to:"+DialString)}
if (~Inbound&Inbound) {concmd("say INCOMING WORMHOLE! Closing the IRIS") Inc=1}
if(!Inbound&~Close&Close&!Open){concmd("say Aborting the dialing sequence.")}
if(~Close&Close&Open){concmd("say Closing the gate...") timer("CL",3000)}
if(clk("CL")&Open){concmd("say Shutdown sequence incomplete!!!")}
if(~Chevron&Chevron){timer("CHEV",150)}
if(clk("CHEV")){
if(Chevron>0&Chevron<7&!ChevronLocked&!Inbound){concmd("say Chevron "+Chevron:toString()+" encoded.")}
elseif(Chevron>=7&Chevron<9&!ChevronLocked&!Inbound){concmd("say Chevron "+Chevron:toString()+"... is encoding.")}
elseif(Chevron>=0&ChevronLocked&!Inbound){concmd("say Sequence complete! Chevron "+Chevron:toString()+" locked!") Loc=1}
elseif(Chevron<-6&!ChevronLocked&!Inbound){concmd("say Sequence complete! Chevron "+abs(Chevron):toString()+"... will not lock!")}}
if(~Open&Open==1&!Inbound){concmd("say Wormhole established!") Loc=0}
if(~Open&Open==1&Inbound){concmd("say Incoming wormhole established!") timer("IDC1",10000)}
if(clk("IDC1")&!IDc2&Inbound&Open){concmd("say No IDC code for now...") IDc1=1}
if(~Open&!Open&Inc){concmd("say Incoming wormhole disengaged!") Inc=0}
if(~Open&!Open&!Inc){concmd("say Wormhole disengaged!")}
if(~Active&!Active&Loc){concmd("say Gate is occupied!") Loc=0}
if(~Active&!Active){IDc2=0 IDc1=0 Loc=0}
if(~Iris&Iris==1){concmd("say Closing the IRIS")}
if(~Iris&Iris==0){concmd("say Opening the IRIS")}
if(~Open&Open){Loc=0}
if(~IDCStatus&IDCStatus==1&!IDc1){concmd("say Receiving the IDC!") IDc2=1}
if(~IDCStatus&IDCStatus==1&IDc1){concmd("say Ok, we receiving the IDC!")}
if(~IDCStatus&IDCStatus==2){concmd("say Analyzing the IDC!")}
if(~IDCStatus&IDCStatus==3){concmd("say Signal analyzed! This is "+IDCName+", Opening the IRIS!")}
if(~IDCStatus&IDCStatus==4){concmd("say Signal analyzed! This is "+IDCName+", but code is expired!")}
if(~IDCStatus&IDCStatus==5){concmd("say Signal analyzed! Unknown signal!")}
if(~Overload&Overload){timer("over",500)} if(clk("over")){concmd("say Hmm, energy flux is not normal! Gate may explode!")}

