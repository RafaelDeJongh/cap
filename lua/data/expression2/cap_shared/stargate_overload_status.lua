# Created by AlexALX (c) 2013
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name Stargate Overload status
@inputs SG:wirelink
@outputs Time Percent Overload
@persist
@trigger

interval(500)

Time = SG:stargateOverloadTime()
Percent = SG:stargateOverloadPerc()
Overload = SG:stargateOverload()
