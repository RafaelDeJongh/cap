# Created by AlexALX (c) 2012
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name Control Panel As Code Door Example
@inputs Button_Pressed Opened Password:string
@outputs Valid Str:string
@persist Pass:string
@trigger

if (Password=="") {    Password = "12450"
}

if (Opened==1 && Valid==0) {
    Valid = 1
    timer("delay",2000)
} elseif (Valid==0) {
    if (Button_Pressed >= 0) {
        Pass = Pass + Button_Pressed
    }
    if (Pass:length()>=Password:length()) {
        if (Pass==Password) {
            Valid = 1
        } else {
            Valid = -1
        }
        timer("delay",2000)
    }
}
if (clk("delay")) {
    Pass = ""
    Valid = 0
}
Str = Pass
