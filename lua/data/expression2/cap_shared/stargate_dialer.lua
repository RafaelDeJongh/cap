# Created by AlexALX (c) 2011
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/

# This is old stargate dialer based on "Dial Address" input (not string)
# This input designed mostly for use with wire keyboard
# In e2 much easier use wirelink with function "SG:stargateDial(address, mode)"
@name Stargate Dialer
@inputs Dial Address:string
@outputs Dial_Address
@persist Str:string X Go
@trigger all
if (Address != "") {Str = Address} else {Str = "123456"} #Change "123456" if you want. What it does is, it dials to 123456 if you leave "String" unwired.
if (~Dial & Dial & !Go) {Go = 1}
if (Go) {
    interval(10) #Change this to 600 for use with dhd press button input.
    X++
    Dial_Address = toByte(Str:index(X))
    if (X > Str:length()) {
        Go = 0, X = 0, Dial_Address = 10
    } #10 is for Enter, in old wiremod (pre-2017) Enter key code is 13
}
# ps button should be toggle