# Created by AlexALX (c) 2011-2012
# For addon Stargate with Group System
# http://www.facepunch.com/threads/1163292
@name Stargate chevron sounds
@inputs Active Chevron ChevronLocked Open Inbound
@outputs
@persist Inc Fail Ch
@trigger

if (Active & !Open) {

if(Chevron==1 & !Inbound & Ch!=Chevron) {
    soundPlay(0,2000,"stargate/walter/c1.mp3")
}
if(Chevron==2 & !Inbound & Ch!=Chevron) {
    soundPlay(0,2000,"stargate/walter/c2.mp3")
}
if(Chevron==3 & !Inbound & Ch!=Chevron) {
    soundPlay(0,2000,"stargate/walter/c3.mp3")
}
if(Chevron==4 & !Inbound & Ch!=Chevron) {
    soundPlay(0,2000,"stargate/walter/c4.mp3")
}
if(Chevron==5 & !Inbound & Ch!=Chevron) {
    soundPlay(0,2000,"stargate/walter/c5.mp3")
}
if(Chevron==6 & !Inbound & Ch!=Chevron) {
    soundPlay(0,2000,"stargate/walter/c6.mp3")
}
if(Chevron==7 & !Inbound & ChevronLocked & Ch!=Chevron) {
    soundPlay(0,2000,"stargate/walter/c7_locked.mp3")
} elseif(Chevron==7 & !Inbound & !ChevronLocked & Ch!=Chevron) {
    #soundPlay(0,2000,"stargate/walter/c7_short.mp3")
    soundPlay(0,2000,"alexalx/stargate/riley/c7_encoded.mp3")
}
if(Chevron==8 & !Inbound & ChevronLocked & Ch!=Chevron) {
    soundPlay(0,2000,"stargate/walter/c8_locked.mp3")
} elseif(Chevron==8 & !Inbound & !ChevronLocked & Ch!=Chevron) {
    #soundPlay(0,2000,"stargate/walter/c8.mp3") - not exists
    soundPlay(0,2000,"alexalx/stargate/riley/c8_encoded.mp3")
}
if(Chevron==9 & !Inbound & ChevronLocked) {
    #soundPlay(0,2000,"stargate/walter/c9_locked.mp3") - not exists
    soundPlay(0,2000,"alexalx/stargate/riley/bad/c9_lock.mp3")
} elseif(Chevron==9 & !Inbound & !ChevronLocked & Ch!=Chevron) {
    #soundPlay(0,2000,"stargate/walter/c8.mp3") - not exists
    soundPlay(0,2000,"alexalx/stargate/riley/c9_encoded.mp3")
}
if(Chevron==-7 & !Inbound & !Fail) {
    soundPlay(0,3000,"stargate/walter/c7_failed.mp3")
    Fail = 1
    Ch = 6
}
if(Chevron==-8 & !Inbound & !Fail) {
    #soundPlay(0,3000,"stargate/walter/c8_failed.mp3") - not exists
    soundPlay(0,3000,"alexalx/stargate/riley/bad/c8_failed.mp3")
    Fail = 1
    Ch = 7
}
if(Chevron==-9 & !Inbound & !Fail) {
    #soundPlay(0,3000,"stargate/walter/c9_failed.mp3") - not exists
    soundPlay(0,3000,"alexalx/stargate/riley/c9_failed.mp3")
    Fail = 1
    Ch = 8
}
if (Inbound & Chevron>0 & !Inc) {
    soundPlay(0,3000,"stargate/walter/unscheduled_offworld_activation.mp3")
    Inc = 1
} elseif (!Inbound & Chevron==0 & Inc) {
    Inc = 0
}

if (Fail & !ChevronLocked & Chevron>=0) {
    Fail = 0
}

# Fix for DHD remove chev
if (Chevron>0 & Chevron<=9 & !ChevronLocked) {
    Ch = Chevron-1
}

} else {
    Inc = 0
    Fail = 0
}
