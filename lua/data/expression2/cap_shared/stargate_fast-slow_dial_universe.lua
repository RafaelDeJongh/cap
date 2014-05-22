# Created by AlexALX (c) 2011
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name stargate universe fast-slow dial
@inputs Start Address:string Ring_Symbol:string Chevron Active Inbound
@outputs Close Rotate_Ring Encode_Symbol Symbols_Lock Ring_Speed_Mode
@persist Address:string Stop Dialling
@trigger
if (!Address) {
    Address = "SPAWN0#"
}
interval(10)
Ring_Speed_Mode = 1
Encode_Symbol = 0
Symbols_Lock = 0
I = Chevron+1
if (Start == 1) {
    Dialling = 1
    if (clk("delay")) {
        Encode_Symbol = 1
        timer("delay2", 1050)
    }
    if (clk("delay2")) {
        Stop = 0
    }
    if (clk("delay3")) {
        Symbols_Lock = 1
    }
    if (Stop == 0) {
        Rotate_Ring = 1
    }
    if (I < Address:length() & Ring_Symbol==Address[I] && Stop == 0) {
        Rotate_Ring = 0
        Stop = 1
        timer("delay", 1050)
    } elseif (I == Address:length() & Ring_Symbol==Address[I] && Stop == 0) {
        Rotate_Ring = 0
        Stop = 1
        timer("delay3", 1050)
    }
} elseif (!Start) {
    if (Active & Dialling) {
        Close = 1
    }
    Rotate_Ring = 0
    Stop = 0
    Dialling = 0
    timer("close", 1000)
    if (clk("close")) {
        Close = 0
    }
}
