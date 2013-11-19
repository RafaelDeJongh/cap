# Created by AlexALX (c) 2011
# For addon Stargate with Group System
# http://www.facepunch.com/threads/1163292
@name Stargate Dialer
@inputs Dial Address:string
@outputs DialAddress
@persist Str:string X Go
@trigger all
if (Address != "") {Str = Address} else {Str = "123456"} #Change "123456" if you want. What it does is, it dials to 123456 if you leave "String" unwired.
if (~Dial & Dial & !Go) {Go = 1}
if (Go) {
    interval(10) #Change this to 600 for use with dhd press button input.
    X++
    DialAddress = toByte(Str:index(X))
    if (X > Str:length()) {
        Go = 0, X = 0, DialAddress = 13
    } #13 is for Enter
}
# ps button should be toggle