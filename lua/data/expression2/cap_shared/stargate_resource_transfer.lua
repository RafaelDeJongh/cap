# Created by AlexALX (c) 2015
# For addon Stargate Carter Addon Pack
# http://sg-carterpack.com/
@name Example Energy Transfer
@inputs ENT:wirelink
@outputs 
@persist Type
@trigger 

interval(1000) # transfer every second

print("Energy " + ENT:stargateTransferEnergy(500))
if (Type==0) {
    Type = 1
    print("Oxygen " + ENT:stargateTransferResource("oxygen",300))
} else {
    Type = 0
    print("Water " + ENT:stargateTransferResource("water",300))
}

# At same time we can transfer only ONE resource and energy.
# By default you can transfer only once at 0.1 second (cycle)
# And max - 80000 energy or 5000 of any resource
# We also can retrieve energy from target gate using negative value