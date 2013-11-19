# Created by AlexALX (c) 2011
# For addon Stargate with Group System
# http://www.facepunch.com/threads/1163292
@name stargate movie fast-slow dial
@inputs Start Address:string RingSymbol:string RingChev7Symbol:string Chevron Active Inbound
@outputs Close RotateRing ChevronEncode ChevronsLock RingSpeedMode
@persist Address:string Stop Dialling
@trigger
if (!Address) {
    Address = "SPAWN0#"
}
interval(10)
RingSpeedMode = 3
ChevronEncode = 0
ChevronsLock = 0
I = Chevron+1
if (Start == 1) {
    Dialling = 1
    if (clk("delay")) {
        ChevronEncode = 1
        timer("delay2", 2600)
    }
    if (clk("delay2")) {
        Stop = 0
    }
    if (clk("delay3")) {
        ChevronsLock = 1
    }
    if (Stop == 0) {
        RotateRing = 1
    }
    if (I < Address:length() & RingSymbol==Address[I] && Stop == 0) {
        RotateRing = 0
        Stop = 1
        timer("delay", 50)
    } elseif (I == Address:length() & RingChev7Symbol==Address[I] && Stop == 0) {
        RotateRing = 0
        Stop = 1
        timer("delay3", 50)
    }
} elseif (!Start) {
    if (Active & Dialling) {
        Close = 1
    }
    RotateRing = 0
    Stop = 0
    Dialling = 0
    timer("close", 1000)
    if (clk("close")) {
        Close = 0
    }
}
