# Created by AlexALX (c) 2011
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name "Screen with Text"
@inputs Desc:string String:string
@outputs OutString:string

OutString = Desc + "<br>" + String
# <br> - new line
# Desc - wire value "Dialed address:", String - to Dialing Address from stargate. OutString - to screen.