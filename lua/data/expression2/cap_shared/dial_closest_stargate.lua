# Created by AlexALX (c) 2014
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name Dial Closest Stargate
@inputs SG:wirelink Button AllowBlocked
@outputs True
@persist AddressList:array

True=1

if (Button & ~Button) {
    AddressList = SG:stargateAddressList()
    Min = -1
    foreach(K,V:array=AddressList) {
        Address = V[1,string] # Get address
        Blocked = V[3,number] # Get blocked
        Distance = SG:stargateGetDistanceFromAddress(Address)
        if (Min > Distance || Min<0) {
            if (Blocked==0 || AllowBlocked==1) {
                Min = Distance
                BestGate = Address
            }
        }
    }
    SG:stargateDial(BestGate, 1)
}