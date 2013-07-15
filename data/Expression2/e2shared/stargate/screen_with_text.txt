# Created by AlexALX (c) 2011
# For addon Stargate with Group System
# http://www.facepunch.com/threads/1163292
@name "Screen with Text"
@inputs Desc:string String:string
@outputs OutString:string

OutString = Desc + "<br>" + String
# <br> - new line
# Desc - wire value "Dialed address:", String - to Dialing Address from stargate. OutString - to screen.