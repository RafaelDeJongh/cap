# Created by AlexALX (c) 2012
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name Energy from address usage
@inputs Get Address:string SG:wirelink
@outputs Energy Distance
@persist
@trigger

if (!Address) {
    Address = "SPAWN0#"
}

if (Get==1) {
    Energy = SG:stargateGetEnergyFromAddress(Address)
    Distance = SG:stargateGetDistanceFromAddress(Address)
} elseif (Get==0) {
    GetEnergyfromAddress = ""
    Energy = 0
    Distance = 0
}