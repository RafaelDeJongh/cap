# Created by AlexALX (c) 2012
# For addon Carter Addon Pack
# http://sg-carterpack.com/
@name Get Gate Info Example
@inputs SG:wirelink
@outputs GateAddress:string GateGroup:string GateName:string GatePrivate GateLocal GateBlocked

interval(5000) # auto-refresh every 5 seconds

GateAddress = SG:stargateAddress()
GateGroup = SG:stargateGroup()
GateName = SG:stargateName()
GatePrivate = SG:stargatePrivate()
GateLocal = SG:stargateLocal()
GateBlocked = SG:stargateBlocked()