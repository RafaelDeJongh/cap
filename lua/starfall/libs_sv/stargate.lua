/*
	Stargate starfall lib
	Created by AlexALX (c) 2014
*/

assert( SF.Entities )

local ents_lib = SF.Entities.Library
local ents_metatable = SF.Entities.Metatable

local ents_methods = SF.Entities.Methods
local ewrap, eunwrap = SF.Entities.Wrap, SF.Entities.Unwrap
local pwrap, punwrap = SF.Players.Wrap, SF.Players.Unwrap
local vunwrap = SF.UnwrapObject

local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local getent = SF.Entities.GetEntity

-- Stargate type functions
SF.Libraries["string"]["TrimExplode"] = StarGate.String.TrimExplode

local function canModify ( ply, ent )
	return SF.Permissions.getOwner( ent ) == ply or game.SinglePlayer() and ent.GateSpawnerSpawned
end

function ents_methods:stargateAddress()
	checktype( self, ents_metatable )
	local ent = getent(self)
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:GetGateAddress()
end

function ents_methods:stargateSetAddress(address)
	checktype( self, ents_metatable )
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsStargate then return false, "entity is not stargate" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetGateAddress(address)
end

function ents_methods:stargateGroup()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:GetGateGroup()
end

function ents_methods:stargateSetGroup(group)
	checktype( self, ents_metatable )
	checkluatype( group, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsStargate then return false, "entity is not stargate" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetGateGroup(group)
end

function ents_methods:stargateName()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:GetGateName()
end

function ents_methods:stargateSetName(name)
	checktype( self, ents_metatable )
	checkluatype( name, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsStargate then return false, "entity is not stargate" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetGateName(name)
end

function ents_methods:stargatePrivate()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:GetPrivate()
end

function ents_methods:stargateSetPrivate(bool)
	checktype( self, ents_metatable )
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsStargate then return false, "entity is not stargate" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetPrivate(bool)
end

function ents_methods:stargateLocal()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:GetLocale()
end

function ents_methods:stargateSetLocal(bool)
	checktype( self, ents_metatable )
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsStargate then return false, "entity is not stargate" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetLocale(bool)
end

function ents_methods:stargateBlocked()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:GetBlocked()
end

function ents_methods:stargateSetBlocked(bool)
	checktype( self, ents_metatable )
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsStargate then return false, "entity is not stargate" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetBlocked(bool)
end

function ents_methods:stargateGalaxy()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:GetGalaxy()
end

function ents_methods:stargateSetGalaxy(bool)
	checktype( self, ents_metatable )
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsStargate then return false, "entity is not stargate" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetGalaxy(bool)
end

function ents_methods:stargateUnstable()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	if IsValid(ent.EventHorizon) and ent.EventHorizon.Unstable then
		return true
	else
		return false
	end
end

function ents_methods:stargateGetRingAngle()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
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
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
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
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	if (ent.excessPower==nil or ent.excessPowerLimit==nil) then return 0 end
	local perc = (ent.excessPower/ent.excessPowerLimit)*100
	if (perc>100) then return 100 end
	return perc
end

function ents_methods:stargateOverloadTime()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
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
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	if (IsValid(ent.asuranweapon) and ent.asuranweapon.isFiring) then
		return true
	else
		return false
	end
end

function ents_methods:stargateDial(address, fast_dial)
	checktype( self, ents_metatable )
	checkluatype( address, TYPE_STRING )
	checkluatype( fast_dial, TYPE_BOOL )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	ent:DialGate(address, fast_dial)
end

function ents_methods:stargateClose()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	ent:AbortDialling()
end

function ents_methods:stargateIrisActive()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:IsBlocked(1,1)
end

function ents_methods:stargateIrisToggle()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	ent:IrisToggle()
end

function ents_methods:stargateDHDPressButton(char)
	checktype( self, ents_metatable )
	checkluatype( char, TYPE_STRING )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsDHD then return false, "entity is not DHD" end
	ent:TriggerInput("Press Button",char:byte())
end

function ents_methods:stargateGetEnergyFromAddress(address)
	checktype( self, ents_metatable )
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:WireGetEnergy(address:upper():sub(1,9))
end

function ents_methods:stargateGetDistanceFromAddress(address)
	checktype( self, ents_metatable )
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:WireGetEnergy(address:upper():sub(1,9),true)
end

function ents_methods:stargateAddressList()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:WireGetAddresses()
end

function ents_methods:stargateRandomAddress(mode)
	checktype( self, ents_metatable )
	checkluatype( mode, TYPE_NUMBER )
	local ent = getent( self )
	if not ent.IsStargate then return false, "entity is not stargate" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	StarGate.RandomGateName(nil,ent,nil,true,mode)
end

function ents_methods:stargateTransferEnergy(value)
	checktype( self, ents_metatable )
	checkluatype( value, TYPE_NUMBER )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:TransferResource("energy",value)
end

function ents_methods:stargateTransferResource(resname, value)
	checktype( self, ents_metatable )
	checkluatype( resname, TYPE_STRING )
	checkluatype( value, TYPE_NUMBER )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	if not ent.IsStargate then return false, "entity is not stargate" end
	return ent:TransferResource(resname,value)
end

local sg_library = SF.RegisterLibrary("stargate")

function sg_library.SystemType()
	local ret = GetConVar("stargate_group_system"):GetBool()
	return ret
end

function sg_library.IsInJamming(from,player)
	checktype( from, SF.Types[ "Vector" ] )
	if (player!=nil) then checktype( player, SF.Types[ "Player" ] ) end
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
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsRings then return false, "entity is not ring" end
	return ent.Address or ""
end

function ents_methods:stargateRingSetAddress(address)
	checktype( self, ents_metatable )
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsRings then return false, "entity is not ring" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetRingAddress(address)
end

function ents_methods:stargateRingDial(address)
	checktype( self, ents_metatable )
	checkluatype( address, TYPE_STRING )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsRings then return false, "entity is not ring" end
	local adr = address:gsub("[^0-9]","")
	if (adr!="") then
		ent:Dial(address)
	else
		ent:Dial(" ") -- fail
	end
end

function ents_methods:stargateRingDialClosest()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsRings then return false, "entity is not ring" end
	ent:Dial("")
end

function ents_methods:stargateAsgardTeleport(origin, dest, all)
	checktype( self, ents_metatable )
	checktype( origin, SF.Types[ "Vector" ] )
	checktype( dest, SF.Types[ "Vector" ] )
	checkluatype( all, TYPE_BOOL )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if ent:GetClass() != "transporter" then return false, "entity is not asgard trasnporter" end
	ent.TeleportEverything = all
	ent:Teleport(Vector(origin[1],origin[2],origin[3]), Vector(dest[1],dest[2],dest[3]))
end

function ents_methods:stargateAtlantisTPGetName()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
	return ent.TName or ""
end

function ents_methods:stargateAtlantisTPSetName(name)
	checktype( self, ents_metatable )
	checkluatype( name, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetAtlName(name)
end

function ents_methods:stargateAtlantisTPGetGroup()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
	return ent.TGroup or ""
end

function ents_methods:stargateAtlantisTPSetGroup(group)
	checktype( self, ents_metatable )
	checkluatype( group, TYPE_STRING )
	local ent = getent( self )
	if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetAtlGrp(group)
end

function ents_methods:stargateAtlantisTPGetPrivate()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
	return ent.TPrivate
end

function ents_methods:stargateAtlantisTPSetPrivate(bool)
	checktype( self, ents_metatable )
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetAtlPrivate(bool)
end

function ents_methods:stargateAtlantisTPGetLocal()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
	return ent.TLocal
end

function ents_methods:stargateAtlantisTPSetLocal(bool)
	checktype( self, ents_metatable )
	checkluatype( bool, TYPE_BOOL )
	local ent = getent( self )
	if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
	if not canModify(SF.instance.player,ent) or not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
	ent:SetAtlLocal(bool)
end

function ents_methods:stargateAtlantisTPTeleport(name)
	checktype( self, ents_metatable )
	checkluatype( name, TYPE_STRING )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
	ent.Destination = name
	ent:Teleport()
end

function ents_methods:stargateAtlantisTPAddressList()
	checktype( self, ents_metatable )
	local ent = getent( self )
	if not canModify(SF.instance.player,ent) then return false, "Insufficient permissions" end
	if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
	return ent:WireGetAddresses()
end

if not WireLib then return end

timer.Create("wait_for_wire", 1, 0, function()
	if SF.Wire == nil then return end
	timer.Stop("wait_for_wire")

	local checkpermission = SF.Permissions.check
	local wirelink_metatable = SF.Wire.WlMetatable
	local wirelink_methods = SF.Wire.WlMethods

	local wlwrap, wlunwrap = SF.Wire.WlWrap, SF.Wire.WlUnwrap
	local vwrap, vunwrap = SF.WrapObject, SF.UnwrapObject

	function wirelink_methods:stargateAddress()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype(self, wirelink_metatable)
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:GetGateAddress()
	end

	function wirelink_methods:stargateSetAddress(address)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( address, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetGateAddress(address)
	end

	function wirelink_methods:stargateGroup()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:GetGateGroup()
	end

	function wirelink_methods:stargateSetGroup(group)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( group, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetGateGroup(group)
	end

	function wirelink_methods:stargateName()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:GetGateName()
	end

	function wirelink_methods:stargateSetName(name)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( name, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetGateName(name)
	end

	function wirelink_methods:stargatePrivate()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:GetPrivate()
	end

	function wirelink_methods:stargateSetPrivate(bool)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( bool, TYPE_BOOL )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetPrivate(bool)
	end

	function wirelink_methods:stargateLocal()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:GetLocale()
	end

	function wirelink_methods:stargateSetLocal(bool)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( bool, TYPE_BOOL )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetLocale(bool)
	end

	function wirelink_methods:stargateBlocked()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:GetBlocked()
	end

	function wirelink_methods:stargateSetBlocked(bool)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( bool, TYPE_BOOL )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetBlocked(bool)
	end

	function wirelink_methods:stargateGalaxy()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:GetGalaxy()
	end

	function wirelink_methods:stargateSetGalaxy(bool)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( bool, TYPE_BOOL )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetGalaxy(bool)
	end

	function wirelink_methods:stargateUnstable()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if IsValid(ent.EventHorizon) and ent.EventHorizon.Unstable then
			return true
		else
			return false
		end
	end

	function wirelink_methods:stargateGetRingAngle()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
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
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
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
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if (ent.excessPower==nil or ent.excessPowerLimit==nil) then return 0 end
		local perc = (ent.excessPower/ent.excessPowerLimit)*100
		if (perc>100) then return 100 end
		return perc
	end

	function wirelink_methods:stargateOverloadTime()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
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
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if (IsValid(ent.asuranweapon) and ent.asuranweapon.isFiring) then
			return true
		else
			return false
		end
	end

	function wirelink_methods:stargateDial(address, fast_dial)
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		checkluatype( address, TYPE_STRING )
		checkluatype( fast_dial, TYPE_BOOL )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		ent:DialGate(address, fast_dial)
	end

	function wirelink_methods:stargateClose()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		ent:AbortDialling()
	end

	function wirelink_methods:stargateIrisActive()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:IsBlocked(1,1)
	end

	function wirelink_methods:stargateIrisToggle()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		ent:IrisToggle()
	end

	function wirelink_methods:stargateDHDPressButton(char)
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		checkluatype( char, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsDHD then return false, "entity is not DHD" end
		ent:TriggerInput("Press Button",char:byte())
	end

	function wirelink_methods:stargateGetEnergyFromAddress(address)
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		checkluatype( address, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:WireGetEnergy(address:upper():sub(1,9))
	end

	function wirelink_methods:stargateGetDistanceFromAddress(address)
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		checkluatype( address, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:WireGetEnergy(address:upper():sub(1,9),true)
	end

	function wirelink_methods:stargateAddressList()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:WireGetAddresses()
	end

	function wirelink_methods:stargateRandomAddress(mode)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( mode, TYPE_NUMBER )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		StarGate.RandomGateName(nil,ent,nil,true,mode)
	end

	function wirelink_methods:stargateTransferEnergy(value)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( value, TYPE_NUMBER )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:TransferResource("energy",value)
	end

	function wirelink_methods:stargateTransferResource(resname, value)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( resname, TYPE_STRING )
		checkluatype( value, TYPE_NUMBER )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		if not ent.IsStargate then return false, "entity is not stargate" end
		return ent:TransferResource(resname,value)
	end

	function wirelink_methods:stargateRingAddress()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsRings then return false, "entity is not ring" end
		return ent.Address or ""
	end

	function wirelink_methods:stargateRingSetAddress(address)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( address, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsRings then return false, "entity is not ring" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetRingAddress(address)
	end

	function wirelink_methods:stargateRingDial(address)
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		checkluatype( address, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsRings then return false, "entity is not ring" end
		local adr = address:gsub("[^0-9]","")
		if (adr!="") then
			ent:Dial(address)
		else
			ent:Dial(" ") -- fail
		end
	end

	function wirelink_methods:stargateRingDialClosest()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsRings then return false, "entity is not ring" end
		ent:Dial("")
	end

	function wirelink_methods:stargateAsgardTeleport(origin, dest, all)
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		checktype( origin, SF.Types[ "Vector" ] )
		checktype( dest, SF.Types[ "Vector" ] )
		checkluatype( all, TYPE_BOOL )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if ent:GetClass() != "transporter" then return false, "entity is not asgard trasnporter" end
		ent.TeleportEverything = all
		ent:Teleport(Vector(origin[1],origin[2],origin[3]), Vector(dest[1],dest[2],dest[3]))
	end

	function wirelink_methods:stargateAtlantisTPGetName()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
		return ent.TName or ""
	end

	function wirelink_methods:stargateAtlantisTPSetName(name)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( name, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetAtlName(name)
	end

	function wirelink_methods:stargateAtlantisTPGetGroup()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
		return ent.TGroup or ""
	end

	function wirelink_methods:stargateAtlantisTPSetGroup(group)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( group, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetAtlGrp(group)
	end

	function wirelink_methods:stargateAtlantisTPGetPrivate()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
		return ent.TPrivate
	end

	function wirelink_methods:stargateAtlantisTPSetPrivate(bool)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( bool, TYPE_BOOL )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetAtlPrivate(bool)
	end

	function wirelink_methods:stargateAtlantisTPGetLocal()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
		return ent.TLocal
	end

	function wirelink_methods:stargateAtlantisTPSetLocal(bool)
		checkpermission(SF.instance, nil, "wire.wirelink.write")
		checktype( self, wirelink_metatable )
		checkluatype( bool, TYPE_BOOL )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
		if not ent:CAP_CanModify(SF.instance.player) then return false, "Insufficient permissions" end
		ent:SetAtlLocal(bool)
	end

	function wirelink_methods:stargateAtlantisTPTeleport(name)
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		checkluatype( name, TYPE_STRING )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
		ent.Destination = name
		ent:Teleport()
	end

	function wirelink_methods:stargateAtlantisTPAddressList()
		checkpermission(SF.instance, nil, "wire.wirelink.read")
		checktype( self, wirelink_metatable )
		local ent = wlunwrap(self)
		if not IsValid(ent) then return false, "invalid entity" end
		if not ent.IsAtlTP then return false, "entity is not atlantis transporter" end
		return ent:WireGetAddresses()
	end
end)