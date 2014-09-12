/*
	Stargate starfall lib
	Created by AlexALX (c) 2014
*/

assert( SF.Entities )

local ents_lib = SF.Entities.Library
local ents_metatable = SF.Entities.Metatable

local ents_methods = SF.Entities.Methods
local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap
local vunwrap = SF.UnwrapObject
/*
-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege( "stargate.Address", "Stargate Address", "Allow player get stargate address" )
end
*/

--if not SF.Permissions.check( SF.instance.player, this, "stargate.Address" ) then SF.throw( "Insufficient permissions", 2 ) end

local function canModify ( ply, ent )
	return SF.Entities.GetOwner( ent ) == ply or game.SinglePlayer() and ent.GateSpawnerSpawned
end

function ents_methods:stargateAddress()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:GetGateAddress()
end

function ents_methods:stargateSetAddress(address)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( address, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	this:SetGateAddress(address)
end

function ents_methods:stargateGroup()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:GetGateGroup()
end

function ents_methods:stargateSetGroup(group)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( group, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	this:SetGateGroup(group)
end

function ents_methods:stargateName()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:GetGateName()
end

function ents_methods:stargateSetName(name)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( group, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	this:SetGateName(name)
end

function ents_methods:stargatePrivate()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:GetPrivate()
end

function ents_methods:stargateSetPrivate(bool)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( bool, "boolean" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	this:SetPrivate(bool)
end

function ents_methods:stargateLocal()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:GetLocale()
end

function ents_methods:stargateSetLocal(bool)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( bool, "boolean" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	this:SetLocale(bool)
end

function ents_methods:stargateBlocked()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:GetBlocked()
end

function ents_methods:stargateSetBlocked(bool)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( bool, "boolean" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	this:SetBlocked(bool)
end

function ents_methods:stargateGalaxy()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:GetGalaxy()
end

function ents_methods:stargateSetGalaxy(bool)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( bool, "boolean" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	this:SetGalaxy(bool)
end

function ents_methods:stargateUnstable()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	if IsValid(this.EventHorizon) and this.EventHorizon.Unstable then
		return true
	else
		return false
	end
end

function ents_methods:stargateGetRingAngle()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_universe"};
	local class = this:GetClass();
	if (not table.HasValue(vg,class)) then return false, "Stargate should be sg1, movie, infinity or universe class" end
	if (class=="stargate_universe") then
		if (IsValid(this.Gate)) then
			local angle = tonumber(math.NormalizeAngle(this.Gate:GetLocalAngles().r));
			if (angle<0) then angle = angle+360; end;
			return angle;
		end
		return false;
	else
		if (IsValid(this.Ring)) then
			local angle = tonumber(math.NormalizeAngle(this.Ring:GetLocalAngles().r));
			if (angle<0) then angle = angle+360; end;
			return angle;
		end
		return false;
	end
end
/*
function ents_methods:stargateGetWireInput(name)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( name, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.GetWire or not this.CreateWireInputs then return false, "entity is not from carter addon pack" end
	return this:GetWire(name,false);
end*/

function ents_methods:stargateOverload()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	if (this.isOverloading) then
		return 2
	end
	if (IsValid(this.overloader) and this.overloader.isFiring) then
		return 1
	else
		return 0
	end
end

function ents_methods:stargateOverloadPerc()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	if (this.excessPower==nil or this.excessPowerLimit==nil) then return 0; end
	local perc = (this.excessPower/this.excessPowerLimit)*100;
	if (perc>100) then return 100; end
	return perc;
end

function ents_methods:stargateOverloadTime()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	if (this.excessPower==nil or this.excessPowerLimit==nil or not IsValid(this.overloader)) then return false; end
	local energyRequired = this.excessPowerLimit - this.excessPower;
	local timeLeft = (energyRequired / this.overloader.energyPerSecond)
	if(StarGate.IsIrisClosed(this)) then
		timeLeft = timeLeft * 2;
	end
	if (this.isOverloading) then
		return 0;
	end
	if (this.overloader.isFiring) then
		return math.ceil(timeLeft);
	else
		return false
	end
	return perc;
end

function ents_methods:stargateAsuranBeam()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	if (IsValid(this.asuranweapon) and this.asuranweapon.isFiring) then
		return true
	else
		return false
	end
end

function ents_methods:stargateDial(address)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( address, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	this:DialGate(address)
end

function ents_methods:stargateClose()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	this:AbortDialling()
end

function ents_methods:stargateIrisActive()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:IsBlocked(1,1)
end

function ents_methods:stargateIrisToggle()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	this:IrisToggle();
end

function ents_methods:stargateDHDPressButton(char)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( char, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsDHD then return false, "entity is not DHD" end
	this:TriggerInput("Press Button",char:byte())
end

function ents_methods:stargateGetEnergyFromAddress(address)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( address, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:WireGetEnergy(address:upper():sub(1,9));
end

function ents_methods:stargateGetDistanceFromAddress(address)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( address, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:WireGetEnergy(address:upper():sub(1,9),true);
end

function ents_methods:stargateAddressList()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	return this:WireGetAddresses();
end

function ents_methods:stargateRandomAddress(mode)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( mode, "number" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsStargate then return false, "entity is not stargate" end
	StarGate.RandomGateName(nil,this,nil,true,mode);
end

--SF.Stargate = {}

local sg_library, _ = SF.Libraries.Register( "stargate" )

function sg_library.SystemType()
	local ret = GetConVar("stargate_group_system"):GetBool()
	return ret
end

function ents_methods:stargateRingAddress()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsRings then return false, "entity is not ring" end
	return this.Address or "";
end

function ents_methods:stargateRingSetAddress(address)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( address, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsRings then return false, "entity is not ring" end
	this:SetRingAddress(address);
end

function ents_methods:stargateRingDial(address)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( address, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsRings then return false, "entity is not ring" end
	local adr = address:gsub("[^0-9]","");
	if (adr!="") then
		this:Dial(address);
	else
		this:Dial(" "); -- fail
	end
end

function ents_methods:stargateRingDialClosest()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsRings then return false, "entity is not ring" end
	this:Dial("");
end

function ents_methods:stargateAsgardTeleport(origin, dest, all)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( origin, "vector" )
	SF.CheckType( dest, "vector" )
	SF.CheckType( all, "boolean" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if this:GetClass() != "transporter" then return false, "entity is not asgard trasnporter" end
	this.TeleportEverything = all;
	this:Teleport(Vector(origin[1],origin[2],origin[3]), Vector(dest[1],dest[2],dest[3]));
end

function ents_methods:stargateAtlantisTPGetName()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsAtlTP then return false, "entity is not atlantis transporter" end
	return this.TName or "";
end

function ents_methods:stargateAtlantisTPSetName(name)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( name, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsAtlTP then return false, "entity is not atlantis transporter" end
	this:SetAtlName(name,true);
end

function ents_methods:stargateAtlantisTPGetPrivate()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsAtlTP then return false, "entity is not atlantis transporter" end
	return this.TPrivate;
end

function ents_methods:stargateAtlantisTPSetPrivate(bool)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( bool, "boolean" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsAtlTP then return false, "entity is not atlantis transporter" end
	this:SetAtlPrivate(bool);
end

function ents_methods:stargateAtlantisTPTeleport(name)
	SF.CheckType( self, ents_metatable )
	SF.CheckType( name, "string" )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsAtlTP then return false, "entity is not atlantis transporter" end
	this.Destination = name;
	this:Teleport();
end

function ents_methods:stargateAtlantisTPAddressList()
	SF.CheckType( self, ents_metatable )
	local this = unwrap( self )
	if not canModify(SF.instance.player,this) then return false, "Insufficient permissions" end
	if not this.IsAtlTP then return false, "entity is not atlantis transporter" end
	return this:WireGetAddresses();
end