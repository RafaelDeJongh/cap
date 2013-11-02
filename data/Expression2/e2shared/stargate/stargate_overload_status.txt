@name Stargate Overload status
@inputs SG:wirelink
@outputs Time Percent Overload
@persist 
@trigger 

interval(500)

Time = SG:stargateOverloadTime()
Percent = SG:stargateOverloadPerc()
Overload = SG:stargateOverload()
