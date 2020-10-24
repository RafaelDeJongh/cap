/*
	Stargate starfall lib
	Created by AlexALX (c) 2014
	Ported to StarfallEx by F0x06 - 2019-2020
*/

-- Global to all starfalls
local checkluatype = SF.CheckLuaType

--- Library for interacting with Stargates
-- @name stargate
-- @class library
-- @libtbl stargate_library
SF.RegisterLibrary("stargate")

return function(instance)

local ents_methods = instance.Types.Entity.Methods
local punwrap = instance.Types.PhysObj.Unwrap

local getent
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

-- Stargate type functions
instance.Libraries["string"]["TrimExplode"] = StarGate.String.TrimExplode

local function canModify ( ply, ent )
	return SF.Permissions.getOwner( ent ) == ply or game.SinglePlayer() and ent.GateSpawnerSpawned
end

function ents_methods:stargateAddress()
	local ent = getent(self)
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetGateAddress()
end

function ents_methods:stargateSetAddress(address)
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetGateAddress(address)
end

function ents_methods:stargateGroup()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetGateGroup()
end

function ents_methods:stargateSetGroup(group)
	checkluatype( group, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetGateGroup(group)
end

function ents_methods:stargateName()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetGateName()
end

function ents_methods:stargateSetName(name)
	checkluatype( name, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetGateName(name)
end

function ents_methods:stargatePrivate()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetPrivate()
end

function ents_methods:stargateSetPrivate(bool)
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetPrivate(bool)
end

function ents_methods:stargateLocal()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetLocale()
end

function ents_methods:stargateSetLocal(bool)
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetLocale(bool)
end

function ents_methods:stargateBlocked()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetBlocked()
end

function ents_methods:stargateSetBlocked(bool)
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetBlocked(bool)
end

function ents_methods:stargateGalaxy()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetGalaxy()
end

function ents_methods:stargateSetGalaxy(bool)
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetGalaxy(bool)
end

function ents_methods:stargateUnstable()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if IsValid(ent.EventHorizon) and ent.EventHorizon.Unstable then
		return true
	else
		return false
	end
end

function ents_methods:stargateGetRingAngle()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_universe"}
	local class = ent:GetClass()
	if (not table.HasValue(vg,class)) then return false, "Stargate should be sg1, movie, infinity or universe class" end
	if (class=="stargate_universe") then
		if (IsValid(ent.Gate)) then
			local angle = tonumber(math.NormalizeAngle(ent.Gate:GetLocalAngles().r))
			if (angle<0) then angle = angle+360 end
			return angle
		end
		return false
	else
		if (IsValid(ent.Ring)) then
			local angle = tonumber(math.NormalizeAngle(ent.Ring:GetLocalAngles().r))
			if (angle<0) then angle = angle+360 end
			return angle
		end
		return false
	end
end

function ents_methods:stargateOverload()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if (ent.isOverloading) then
		return 2
	end
	if (IsValid(ent.overloader) and ent.overloader.isFiring) then
		return 1
	else
		return 0
	end
end

function ents_methods:stargateOverloadPerc()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if (ent.excessPower==nil or ent.excessPowerLimit==nil) then return 0 end
	local perc = (ent.excessPower/ent.excessPowerLimit)*100
	if (perc>100) then return 100 end
	return perc
end

function ents_methods:stargateOverloadTime()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if (ent.excessPower==nil or ent.excessPowerLimit==nil or not IsValid(ent.overloader)) then return false end
	local energyRequired = ent.excessPowerLimit - ent.excessPower
	local timeLeft = (energyRequired / ent.overloader.energyPerSecond)
	if(StarGate.IsIrisClosed(ent)) then
		timeLeft = timeLeft * 2
	end
	if (ent.isOverloading) then
		return 0
	end
	if (ent.overloader.isFiring) then
		return math.ceil(timeLeft)
	else
		return false
	end
	return perc
end

function ents_methods:stargateAsuranBeam()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if (IsValid(ent.asuranweapon) and ent.asuranweapon.isFiring) then
		return true
	else
		return false
	end
end

function ents_methods:stargateDial(address, fast_dial)
	checkluatype( address, TYPE_STRING )
	checkluatype( fast_dial, TYPE_BOOL )
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	ent:DialGate(address, fast_dial)
end

function ents_methods:stargateNoxDial(address)
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	ent:NoxDialGate(address)
end

function ents_methods:stargateClose()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	ent:AbortDialling()
end

function ents_methods:stargateIrisActive()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:IsBlocked(1,1)
end

function ents_methods:stargateIrisToggle()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	ent:IrisToggle()
end

function ents_methods:stargateDHDPressButton(char)
	checkluatype( char, TYPE_STRING )
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsDHD then SF.Throw("entity is not a DHD") end
	ent:TriggerInput("Press Button",char:byte())
end

function ents_methods:stargateGetEnergyFromAddress(address)
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:WireGetEnergy(address:upper():sub(1,9))
end

function ents_methods:stargateGetDistanceFromAddress(address)
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:WireGetEnergy(address:upper():sub(1,9),true)
end

function ents_methods:stargateAddressList()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:WireGetAddresses()
end

function ents_methods:stargateRandomAddress(mode)
	checkluatype( mode, TYPE_NUMBER )
	local ent = getent( self )
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	StarGate.RandomGateName(nil,ent,nil,true,mode)
end

function ents_methods:stargateTransferEnergy(value)
	checkluatype( value, TYPE_NUMBER )
	local ent = getent( self )
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:TransferResource("energy",value)
end

function ents_methods:stargateTransferResource(resname, value)
	checkluatype( resname, TYPE_STRING )
	checkluatype( value, TYPE_NUMBER )
	local ent = getent( self )
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:TransferResource(resname,value)
end

local sg_library = instance.Libraries.stargate

function sg_library.SystemType()
	local ret = GetConVar("stargate_group_system"):GetBool()
	return ret
end

function sg_library.IsInJamming(from,player)
	local radius = 1024 -- max range of jamming, we will adjust it later
	local jaiming_online = false
	from = Vector(from[1],from[2],from[3])
	player = punwrap( player )
	if (not IsValid(player)) then return false end
	for _,v in pairs(ents.FindInSphere(from, radius)) do
		if IsValid(v) and v.CapJammingDevice then
			if v.IsEnabled then
				local dist = from:Distance(v:GetPos())
				if (dist < v.Size) then  -- ow jaiming, we cant do anything
					if player==nil or not (v.Immunity and v.Owner == player) then jaiming_online = true end
				end
			end
		end
	end
	return jaiming_online
end

function ents_methods:stargateRingAddress()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsRings then SF.Throw("entity is not a ring") end
	return ent.Address or ""
end

function ents_methods:stargateRingSetAddress(address)
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsRings then SF.Throw("entity is not a ring") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetRingAddress(address)
end

function ents_methods:stargateRingDial(address)
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsRings then SF.Throw("entity is not a ring") end
	local adr = address:gsub("[^0-9]","")
	if (adr!="") then
		ent:Dial(address)
	else
		ent:Dial(" ") -- fail
	end
end

function ents_methods:stargateRingDialClosest()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsRings then SF.Throw("entity is not a ring") end
	ent:Dial("")
end

function ents_methods:stargateAsgardTeleport(origin, dest, all)
	checkluatype( all, TYPE_BOOL )
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if ent:GetClass() != "transporter" then SF.Throw("entity is not an asgard trasnporter") end
	ent.TeleportEverything = all
	ent:Teleport(Vector(origin[1],origin[2],origin[3]), Vector(dest[1],dest[2],dest[3]))
end

function ents_methods:stargateAtlantisTPGetName()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	return ent.TName or ""
end

function ents_methods:stargateAtlantisTPSetName(name)
	checkluatype( name, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetAtlName(name)
end

function ents_methods:stargateAtlantisTPGetGroup()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	return ent.TGroup or ""
end

function ents_methods:stargateAtlantisTPSetGroup(group)
	checkluatype( group, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetAtlGrp(group)
end

function ents_methods:stargateAtlantisTPGetPrivate()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	return ent.TPrivate
end

function ents_methods:stargateAtlantisTPSetPrivate(bool)
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetAtlPrivate(bool)
end

function ents_methods:stargateAtlantisTPGetLocal()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	return ent.TLocal
end

function ents_methods:stargateAtlantisTPSetLocal(bool)
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	if not canModify(instance.player,ent) or not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetAtlLocal(bool)
end

function ents_methods:stargateAtlantisTPTeleport(name)
	checkluatype( name, TYPE_STRING )
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	ent.Destination = name
	ent:Teleport()
end

function ents_methods:stargateAtlantisTPAddressList()
	local ent = getent( self )
	if not canModify(instance.player,ent) then SF.Throw("Insufficient permissions") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	return ent:WireGetAddresses()
end

-- Wirelink integration
if not WireLib then return end

local checkpermission = SF.Permissions.check
local wirelink_methods, wlwrap, wlunwrap = instance.Types.Wirelink.Methods, instance.Types.Wirelink.Wrap, instance.Types.Wirelink.Unwrap

function wirelink_methods:stargateAddress()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetGateAddress()
end

function wirelink_methods:stargateSetAddress(address)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( address, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetGateAddress(address)
end

function wirelink_methods:stargateGroup()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetGateGroup()
end

function wirelink_methods:stargateSetGroup(group)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( group, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetGateGroup(group)
end

function wirelink_methods:stargateName()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetGateName()
end

function wirelink_methods:stargateSetName(name)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( name, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetGateName(name)
end

function wirelink_methods:stargatePrivate()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetPrivate()
end

function wirelink_methods:stargateSetPrivate(bool)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( bool, TYPE_BOOL )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetPrivate(bool)
end

function wirelink_methods:stargateLocal()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetLocale()
end

function wirelink_methods:stargateSetLocal(bool)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( bool, TYPE_BOOL )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetLocale(bool)
end

function wirelink_methods:stargateBlocked()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetBlocked()
end

function wirelink_methods:stargateSetBlocked(bool)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( bool, TYPE_BOOL )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetBlocked(bool)
end

function wirelink_methods:stargateGalaxy()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:GetGalaxy()
end

function wirelink_methods:stargateSetGalaxy(bool)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( bool, TYPE_BOOL )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetGalaxy(bool)
end

function wirelink_methods:stargateUnstable()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if IsValid(ent.EventHorizon) and ent.EventHorizon.Unstable then
		return true
	else
		return false
	end
end

function wirelink_methods:stargateGetRingAngle()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_universe"}
	local class = ent:GetClass()
	if (not table.HasValue(vg,class)) then return false, "Stargate should be sg1, movie, infinity or universe class" end
	if (class=="stargate_universe") then
		if (IsValid(ent.Gate)) then
			local angle = tonumber(math.NormalizeAngle(ent.Gate:GetLocalAngles().r))
			if (angle<0) then angle = angle+360 end
			return angle
		end
		return false
	else
		if (IsValid(ent.Ring)) then
			local angle = tonumber(math.NormalizeAngle(ent.Ring:GetLocalAngles().r))
			if (angle<0) then angle = angle+360 end
			return angle
		end
		return false
	end
end

function wirelink_methods:stargateOverload()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if (ent.isOverloading) then
		return 2
	end
	if (IsValid(ent.overloader) and ent.overloader.isFiring) then
		return 1
	else
		return 0
	end
end

function wirelink_methods:stargateOverloadPerc()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if (ent.excessPower==nil or ent.excessPowerLimit==nil) then return 0 end
	local perc = (ent.excessPower/ent.excessPowerLimit)*100
	if (perc>100) then return 100 end
	return perc
end

function wirelink_methods:stargateOverloadTime()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if (ent.excessPower==nil or ent.excessPowerLimit==nil or not IsValid(ent.overloader)) then return false end
	local energyRequired = ent.excessPowerLimit - ent.excessPower
	local timeLeft = (energyRequired / ent.overloader.energyPerSecond)
	if(StarGate.IsIrisClosed(ent)) then
		timeLeft = timeLeft * 2
	end
	if (ent.isOverloading) then
		return 0
	end
	if (ent.overloader.isFiring) then
		return math.ceil(timeLeft)
	else
		return false
	end
	return perc
end

function wirelink_methods:stargateAsuranBeam()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if (IsValid(ent.asuranweapon) and ent.asuranweapon.isFiring) then
		return true
	else
		return false
	end
end

function wirelink_methods:stargateDial(address, fast_dial)
	checkpermission(instance, nil, "wire.wirelink.read")
	checkluatype( address, TYPE_STRING )
	checkluatype( fast_dial, TYPE_BOOL )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	ent:DialGate(address, fast_dial)
end

function wirelink_methods:stargateNoxDial(address)
	checkpermission(instance, nil, "wire.wirelink.read")
	checkluatype( address, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	ent:NoxDialGate(address)
end

function wirelink_methods:stargateClose()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	ent:AbortDialling()
end

function wirelink_methods:stargateIrisActive()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:IsBlocked(1,1)
end

function wirelink_methods:stargateIrisToggle()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	ent:IrisToggle()
end

function wirelink_methods:stargateDHDPressButton(char)
	checkpermission(instance, nil, "wire.wirelink.read")
	checkluatype( char, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsDHD then SF.Throw("entity is not a DHD") end
	ent:TriggerInput("Press Button",char:byte())
end

function wirelink_methods:stargateGetEnergyFromAddress(address)
	checkpermission(instance, nil, "wire.wirelink.read")
	checkluatype( address, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:WireGetEnergy(address:upper():sub(1,9))
end

function wirelink_methods:stargateGetDistanceFromAddress(address)
	checkpermission(instance, nil, "wire.wirelink.read")
	checkluatype( address, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:WireGetEnergy(address:upper():sub(1,9),true)
end

function wirelink_methods:stargateAddressList()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:WireGetAddresses()
end

function wirelink_methods:stargateRandomAddress(mode)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( mode, TYPE_NUMBER )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	StarGate.RandomGateName(nil,ent,nil,true,mode)
end

function wirelink_methods:stargateTransferEnergy(value)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( value, TYPE_NUMBER )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:TransferResource("energy",value)
end

function wirelink_methods:stargateTransferResource(resname, value)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( resname, TYPE_STRING )
	checkluatype( value, TYPE_NUMBER )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	if not ent.IsStargate then SF.Throw("entity is not a stargate") end
	return ent:TransferResource(resname,value)
end

function wirelink_methods:stargateRingAddress()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsRings then SF.Throw("entity is not a ring") end
	return ent.Address or ""
end

function wirelink_methods:stargateRingSetAddress(address)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( address, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsRings then SF.Throw("entity is not a ring") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetRingAddress(address)
end

function wirelink_methods:stargateRingDial(address)
	checkpermission(instance, nil, "wire.wirelink.read")
	checkluatype( address, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsRings then SF.Throw("entity is not a ring") end
	local adr = address:gsub("[^0-9]","")
	if (adr!="") then
		ent:Dial(address)
	else
		ent:Dial(" ") -- fail
	end
end

function wirelink_methods:stargateRingDialClosest()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsRings then SF.Throw("entity is not a ring") end
	ent:Dial("")
end

function wirelink_methods:stargateAsgardTeleport(origin, dest, all)
	checkpermission(instance, nil, "wire.wirelink.read")
	checkluatype( all, TYPE_BOOL )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if ent:GetClass() != "transporter" then SF.Throw("entity is not an asgard trasnporter") end
	ent.TeleportEverything = all
	ent:Teleport(Vector(origin[1],origin[2],origin[3]), Vector(dest[1],dest[2],dest[3]))
end

function wirelink_methods:stargateAtlantisTPGetName()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	return ent.TName or ""
end

function wirelink_methods:stargateAtlantisTPSetName(name)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( name, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetAtlName(name)
end

function wirelink_methods:stargateAtlantisTPGetGroup()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	return ent.TGroup or ""
end

function wirelink_methods:stargateAtlantisTPSetGroup(group)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( group, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetAtlGrp(group)
end

function wirelink_methods:stargateAtlantisTPGetPrivate()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	return ent.TPrivate
end

function wirelink_methods:stargateAtlantisTPSetPrivate(bool)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( bool, TYPE_BOOL )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetAtlPrivate(bool)
end

function wirelink_methods:stargateAtlantisTPGetLocal()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	return ent.TLocal
end

function wirelink_methods:stargateAtlantisTPSetLocal(bool)
	checkpermission(instance, nil, "wire.wirelink.write")
	checkluatype( bool, TYPE_BOOL )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	if not ent:CAP_CanModify(instance.player) then SF.Throw("Insufficient permissions") end
	ent:SetAtlLocal(bool)
end

function wirelink_methods:stargateAtlantisTPTeleport(name)
	checkpermission(instance, nil, "wire.wirelink.read")
	checkluatype( name, TYPE_STRING )
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	ent.Destination = name
	ent:Teleport()
end

function wirelink_methods:stargateAtlantisTPAddressList()
	checkpermission(instance, nil, "wire.wirelink.read")
	local ent = wlunwrap(self)
	if not IsValid(ent) then SF.Throw("invalid entity") end
	if not ent.IsAtlTP then SF.Throw("entity is not an atlantis transporter") end
	return ent:WireGetAddresses()
end
end