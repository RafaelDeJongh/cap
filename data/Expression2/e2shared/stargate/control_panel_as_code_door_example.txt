# Created by AlexALX (c) 2012
# For addon Carter Addon Pack
# http://sg-carterpack.com/
@name Control Panel As Code Door Example
@inputs ButtonPressed Opened
@outputs Valid Str:string
@persist Pass:string
@trigger 

if (Opened==1 && Valid==0) {
    Valid = 1
    timer("delay",2000)      
} elseif (Valid==0) {
    if (ButtonPressed >= 0) {
        Pass = Pass + ButtonPressed   
    }
    if (Pass:length()>=5) {
        if (Pass=="12450") {
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
