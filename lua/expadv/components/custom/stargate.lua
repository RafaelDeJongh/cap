if !WireLib then 
	print("No WireLib detected.")
	return
end

local Component = EXPADV.AddComponent( "stargate", true )

Component.Author = "E2 source by AlexALX, ported and updated by Kawoosh"
Component.Description = "Adds functions for stargate CAP addon."

--- Add cap fonts to valid render fonts ---
local RenderCom = EXPADV.GetComponent("render")
if RenderCom and RenderCom.ValidFonts then
	local CapFonts={
		["Stargate Address Glyphs SG1"] = true,
		["Stargate Address Glyphs Concept"] = true,
		["Stargate Address Glyphs U"] = true,
		["Stargate Address Glyphs Atl"] = true,
		["Anquietas"] = true,
		["Quiver"] = true
	}
	table.Merge(RenderCom.ValidFonts,CapFonts)
end

Component.LuaTablesToArrayOfTables = function ( Tbl )
	Array = {__type = "t"}
	for _, data in pairs( Tbl ) do
		local Data, Types, Look, Size = {}, {}, {}, 0
			 
		for _, v in pairs(data) do
			local Type
			if isstring(v) then
				Type = "s"
			elseif isbool(v) then
				Type = "b"
			elseif isnumber(v) then
				Type = "n"
			elseif isvector(v) then
				Type = "v"
			elseif isangle(v) then
				Type = "a"
			elseif isentity(v) then
				Type = "e"
			end
				 
			if Type then 
				Types[Size] = Type
				Data[Size] = v
				Look[Size] = Size
				Size = Size + 1
			end
		end
		 
		Array[#Array + 1] = { Data = Data, Types = Types, Look = Look, Size = Size, Count = 0, HasChanged = false }
	end	
	return Array
end

-- [ General Functions ] --

EXPADV.ServerOperators()

Component:AddPreparedFunction( "stargateAddress", "e:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:GetGateAddress() or ""
end
]], "@result" )
Component:AddFunctionHelper( "stargateAddress", "e:", "Returns stargate address." )

Component:AddPreparedFunction( "stargateAddress", "wl:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1:GetGateAddress() or ""
end
]], "@result" )
Component:AddFunctionHelper( "stargateAddress", "wl:", "Returns stargate address." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateSetAddress", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetGateAddress(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetAddress", "e:s", "Sets stargate address." )

Component:AddPreparedFunction( "stargateSetAddress", "wl:s", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetGateAddress(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetAddress", "wl:s", "Sets stargate address." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateGroup", "e:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:GetGateGroup() or "" 
end
]], "@result" )
Component:AddFunctionHelper( "stargateGroup", "e:", "Returns stargate group." )

Component:AddPreparedFunction( "stargateGroup", "wl:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1:GetGateGroup() or "" 
end
]], "@result" )
Component:AddFunctionHelper( "stargateGroup", "wl:", "Returns stargate group." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateSetGroup", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetGateGroup(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetGroup", "e:s", "Sets stargate group." )

Component:AddPreparedFunction( "stargateSetGroup", "wl:s", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetGateGroup(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetGroup", "wl:s", "Sets stargate group." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateName", "e:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:GetGateName() or "" 
end
]], "@result" )
Component:AddFunctionHelper( "stargateName", "e:", "Returns stargate name." )

Component:AddPreparedFunction( "stargateName", "wl:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1:GetGateName() or "" 
end
]], "@result" )
Component:AddFunctionHelper( "stargateName", "wl:", "Returns stargate name." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateSetName", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetGateName(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetName", "e:s", "Sets stargate name." )

Component:AddPreparedFunction( "stargateSetName", "wl:s", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetGateName(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetName", "wl:s", "Sets stargate name." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargatePrivate", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:GetPrivate() and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargatePrivate", "e:", "Returns stargate private state." )

Component:AddPreparedFunction( "stargatePrivate", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1:GetPrivate() and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargatePrivate", "wl:", "Returns stargate private state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateSetPrivate", "e:n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetPrivate(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetPrivate", "e:n", "Sets stargate private state." )

Component:AddPreparedFunction( "stargateSetPrivate", "wl:n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetPrivate(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetPrivate", "wl:n", "Sets stargate private state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateLocal", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:GetLocale() and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateLocal", "e:", "Returns stargate local state." )

Component:AddPreparedFunction( "stargateLocal", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1:GetLocale() and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateLocal", "wl:", "Returns stargate local state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateSetLocal", "e:n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetLocale(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetLocal", "e:n", "Sets stargate local state." )

Component:AddPreparedFunction( "stargateSetLocal", "wl:n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetLocale(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetLocal", "wl:n", "Sets stargate local state." )
-------------------------------------------------------------------------


Component:AddPreparedFunction( "stargateBlocked", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:GetBlocked() and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateBlocked", "e:", "Returns stargate blocked state." )

Component:AddPreparedFunction( "stargateBlocked", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1:GetBlocked() and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateBlocked", "wl:", "Returns stargate blocked state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateSetBlocked", "e:n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetBlocked(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetBlocked", "e:n", "Sets stargate blocked state." )

Component:AddPreparedFunction( "stargateSetBlocked", "wl:n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetBlocked(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetBlocked", "wl:n", "Sets stargate blocked state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateGalaxy", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:GetGalaxy() and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateGalaxy", "e:", "Returns stargate galaxy mode." )

Component:AddPreparedFunction( "stargateGalaxy", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1:GetGalaxy() and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateGalaxy", "wl:", "Returns stargate galaxy mode." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateSetGalaxy", "e:n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetGalaxy(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetGalaxy", "e:n", "Sets stargate galaxy mode." )

Component:AddPreparedFunction( "stargateSetGalaxy", "wl:n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetGalaxy(@value 2)
end
]])
Component:AddFunctionHelper( "stargateSetGalaxy", "wl:n", "Sets stargate galaxy mode." )
-------------------------------------------------------------------------
/*
Component:AddPreparedFunction( "stargateTarget", "e:", "e",
[[@define result = nil
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	if (IsValid(@value 1.Target) and (not @value 1.Target:GetPrivate() or EXPADV.PPCheck(Context,@value 1.Target))) then
		@result	= @value 1.Target
	end
end
]], "@result" )
Component:AddFunctionHelper( "stargateTarget", "e:", "Returns stargate target entity." )

Component:AddPreparedFunction( "stargateTarget", "wl:", "e",
[[@define result = nil
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	if (IsValid(@value 1.Target) and (not @value 1.Target:GetPrivate())) then
		@result	= @value 1.Target
	end
end
]], "@result" )
Component:AddFunctionHelper( "stargateTarget", "wl:", "Returns stargate target gate entity." )
*/
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateOpen", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1.IsOpen and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateOpen", "e:", "Returns stargate open state." )

Component:AddPreparedFunction( "stargateOpen", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1.IsOpen and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateOpen", "wl:", "Returns stargate open state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateInbound", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = (!@value 1.Outbound and @value 1.Active) and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateInbound", "e:", "Returns stargate inbound state." )

Component:AddPreparedFunction( "stargateInbound", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = (!@value 1.Outbound and @value 1.Active) and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateInbound", "wl:", "Returns stargate inbound state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateActive", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1.NewActive and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateActive", "e:", "Returns stargate active state." )

Component:AddPreparedFunction( "stargateActive", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1.NewActive and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateActive", "wl:", "Returns stargate active state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateUnstable", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = (IsValid(@value 1.EventHorizon) and @value 1.EventHorizon.Unstable) and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateUnstable", "e:", "Returns EH unstable state." )

Component:AddPreparedFunction( "stargateUnstable", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = (IsValid(@value 1.EventHorizon) and @value 1.EventHorizon.Unstable) and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateUnstable", "wl:", "Returns EH unstable state." )
-------------------------------------------------------------------------

Component:AddVMFunction( "stargateGetRingAngle", "e:", "n",function( Context, Trace, Entity )
	if not IsValid(Entity) or not Entity.IsStargate or not EXPADV.PPCheck(Context,Entity) then return -1 end
	local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_universe"};
	local class = Entity:GetClass();
	if (not table.HasValue(vg,class)) then return -1 end
	if (class=="stargate_universe") then
		if (IsValid(Entity.Gate)) then
			local angle = tonumber(math.NormalizeAngle(Entity.Gate:GetLocalAngles().r));
			if (angle<0) then angle = angle+360; end;
			return angle;
		end
		return -1;
	else
		if (IsValid(Entity.Ring)) then
			local angle = tonumber(math.NormalizeAngle(Entity.Ring:GetLocalAngles().r));
			if (angle<0) then angle = angle+360; end;
			return angle;
		end
		return -1;
	end
end)
Component:AddFunctionHelper( "stargateGetRingAngle", "e:", "Returns stargate ring angle." )

Component:AddVMFunction( "stargateGetRingAngle", "wl:", "n", function( Context, Trace, Entity )
	if not IsValid(Entity) or not Entity.IsStargate then return -1 end
	local vg = {"stargate_movie","stargate_sg1","stargate_infinity","stargate_universe"};
	local class = Entity:GetClass();
	if (not table.HasValue(vg,class)) then return -1 end
	if (class=="stargate_universe") then
		if (IsValid(Entity.Gate)) then
			local angle = tonumber(math.NormalizeAngle(Entity.Gate:GetLocalAngles().r));
			if (angle<0) then angle = angle+360; end;
			return angle;
		end
		return -1;
	else
		if (IsValid(Entity.Ring)) then
			local angle = tonumber(math.NormalizeAngle(Entity.Ring:GetLocalAngles().r));
			if (angle<0) then angle = angle+360; end;
			return angle;
		end
		return -1;
	end
end)

Component:AddFunctionHelper( "stargateGetRingAngle", "wl:", "Returns stargate ring angle." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateOverload", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1.isOverloading and 2 or (IsValid(@value 1.overloader) and @value 1.overloader.isFiring) and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateOverload", "e:", "Returns stargate overload state." )

Component:AddPreparedFunction( "stargateOverload", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1.isOverloading and 2 or (IsValid(@value 1.overloader) and @value 1.overloader.isFiring) and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateOverload", "wl:", "Returns stargate overload state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateOverloadPerc", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	if (@value 1.excessPower == nil or @value 1.excessPowerLimit == nil) then @result = 0 else
		@result = (@value 1.excessPower/@value 1.excessPowerLimit)*100;
		if (@result > 100) then @result = 100 end
	end
end
]], "@result" )
Component:AddFunctionHelper( "stargateOverloadPerc", "e:", "Returns stargate overload percent." )

Component:AddPreparedFunction( "stargateOverloadPerc", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	if (@value 1.excessPower == nil or @value 1.excessPowerLimit == nil) then @result = 0 else
		@result = (@value 1.excessPower/@value 1.excessPowerLimit)*100;
		if (@result > 100) then @result = 100 end
	end
end
]], "@result" )
Component:AddFunctionHelper( "stargateOverloadPerc", "wl:", "Returns stargate overload percent." )
-------------------------------------------------------------------------

Component:AddVMFunction( "stargateOverloadTime", "e:", "n",function( Context, Trace, Entity )
	if not IsValid(Entity) or not Entity.IsStargate or not EXPADV.PPCheck(Context,Entity) then return -1 end
	if (Entity.excessPower==nil or Entity.excessPowerLimit==nil or not IsValid(Entity.overloader)) then return -1; end
	local energyRequired = Entity.excessPowerLimit - Entity.excessPower;
	local timeLeft = (energyRequired / Entity.overloader.energyPerSecond)
	if(StarGate.IsIrisClosed(Entity)) then
		timeLeft = timeLeft * 2;
	end
	if (Entity.isOverloading) then
		return 0;
	end
	if (Entity.overloader.isFiring) then
		return math.ceil(timeLeft);
	else
		return -1
	end
	return perc;
end)
Component:AddFunctionHelper( "stargateOverloadTime", "e:", "Returns stargate overload time." )

Component:AddVMFunction( "stargateOverloadTime", "wl:", "n", function( Context, Trace, Entity )
	if not IsValid(Entity) or not Entity.IsStargate then return -1 end
	if (Entity.excessPower==nil or Entity.excessPowerLimit==nil or not IsValid(Entity.overloader)) then return -1; end
	local energyRequired = Entity.excessPowerLimit - Entity.excessPower;
	local timeLeft = (energyRequired / Entity.overloader.energyPerSecond)
	if(StarGate.IsIrisClosed(Entity)) then
		timeLeft = timeLeft * 2;
	end
	if (Entity.isOverloading) then
		return 0;
	end
	if (Entity.overloader.isFiring) then
		return math.ceil(timeLeft);
	else
		return -1
	end
	return perc;
end)

Component:AddFunctionHelper( "stargateOverloadTime", "wl:", "Returns stargate overload time." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAsuranBeam", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = (IsValid(@value 1.asuranweapon) and @value 1.asuranweapon.isFiring) and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateAsuranBeam", "e:", "Returns stargate asuran beam firing state." )

Component:AddPreparedFunction( "stargateAsuranBeam", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = (IsValid(@value 1.asuranweapon) and @value 1.asuranweapon.isFiring) and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateAsuranBeam", "wl:", "Returns stargate asuran beam firing state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateDial", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsStargate then
	if EXPADV.PPCheck(Context,@value 1) or @value 1.IsAdmin then 
		@value 1:DialGate(string.upper(@value 2))
	end
end
]])
Component:AddFunctionHelper( "stargateDial", "e:s", "Dials stargate slowly." )

Component:AddPreparedFunction( "stargateDial", "wl:s", "",
[[
if IsValid(@value 1) and @value 1.IsStargate then 
	@value 1:DialGate(string.upper(@value 2))
end
]])
Component:AddFunctionHelper( "stargateDial", "wl:s", "Dials stargate slowly." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateDial", "e:s,n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate then
	if EXPADV.PPCheck(Context,@value 1) or @value 1.IsAdmin then 
		if @value 3 >= 2 then @value 1:NoxDialGate(string.upper(@value 2)) else @value 1:DialGate(string.upper(@value 2),$util.tobool(@value 3)) end
	end
end
]])
Component:AddFunctionHelper( "stargateDial", "e:s,n", "Dials stargate with mode selection." )

Component:AddPreparedFunction( "stargateDial", "wl:s,n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate then 
	if @value 3 >= 2 then @value 1:NoxDialGate(string.upper(@value 2)) else @value 1:DialGate(string.upper(@value 2),$util.tobool(@value 3)) end
end
]])
Component:AddFunctionHelper( "stargateDial", "wl:s,n", "Dials stargate with mode selection." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateClose", "e:", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:AbortDialling()
end
]])
Component:AddFunctionHelper( "stargateClose", "e:", "Closes stargate." )

Component:AddPreparedFunction( "stargateClose", "wl:", "",
[[
if IsValid(@value 1) and @value 1.IsStargate then 
	@value 1:AbortDialling()
end
]])
Component:AddFunctionHelper( "stargateClose", "wl:", "Closes stargate." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateIrisActive", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:IsBlocked(1,1) and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateIrisActive", "e:", "Returns stargate iris state." )

Component:AddPreparedFunction( "stargateIrisActive", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then
	@result = @value 1:IsBlocked(1,1) and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateIrisActive", "wl:", "Returns stargate iris state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateIrisToggle", "e:", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:IrisToggle()
end
]])
Component:AddFunctionHelper( "stargateIrisToggle", "e:", "Toggles iris." )

Component:AddPreparedFunction( "stargateIrisToggle", "wl:", "",
[[
if IsValid(@value 1) and @value 1.IsStargate then 
	@value 1:IrisToggle()
end
]])
Component:AddFunctionHelper( "stargateIrisToggle", "wl:", "Toggles iris." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateDHDPressButton", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsDHD and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:TriggerInput("Press Button",@value 2:byte())
end
]])
Component:AddFunctionHelper( "stargateDHDPressButton", "e:s", "Pressing button on DHD." )

Component:AddPreparedFunction( "stargateDHDPressButton", "wl:s", "",
[[
if IsValid(@value 1) and @value 1.IsDHD then 
	@value 1:TriggerInput("Press Button",@value 2:byte())
end
]])
Component:AddFunctionHelper( "stargateDHDPressButton", "wl:s", "Pressing button on DHD." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateGetEnergyFromAddress", "e:s", "n",
[[@define result = -2
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:WireGetEnergy(@value 2:upper():sub(1,9))
end
]], "@result" )
Component:AddFunctionHelper( "stargateGetEnergyFromAddress", "e:s", "Get required energy value to dial address." )

Component:AddPreparedFunction( "stargateGetEnergyFromAddress", "wl:s", "n",
[[@define result = -2
if IsValid(@value 1) and @value 1.IsStargate then
	@result = @value 1:WireGetEnergy(@value 2:upper():sub(1,9))
end
]], "@result" )
Component:AddFunctionHelper( "stargateGetEnergyFromAddress", "wl:s", "Get required energy value to dial address." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateGetDistanceFromAddress", "e:s", "n",
[[@define result = -2
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:WireGetEnergy(@value 2:upper():sub(1,9),true)
end
]], "@result" )
Component:AddFunctionHelper( "stargateGetDistanceFromAddress", "e:s", "Get distance to stargate." )

Component:AddPreparedFunction( "stargateGetDistanceFromAddress", "wl:s", "n",
[[@define result = -2
if IsValid(@value 1) and @value 1.IsStargate then
	@result = @value 1:WireGetEnergy(@value 2:upper():sub(1,9),true)
end
]], "@result" )
Component:AddFunctionHelper( "stargateGetDistanceFromAddress", "wl:s", "Get distance to stargate." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAddressList", "e:", "ar",
[[@define result = {__type = "t"}
--@result.__type="t"
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = EXPADV.Components.stargate.LuaTablesToArrayOfTables(@value 1:WireGetAddresses())
	--@result = @value 1:WireGetAddresses()
end
]], "@result" )
Component:AddFunctionHelper( "stargateAddressList", "e:", "Returns stargate address list." )

Component:AddPreparedFunction( "stargateAddressList", "wl:", "ar",
[[@define result = {__type = "t"}
--@result.__type="t"
if IsValid(@value 1) and @value 1.IsStargate then
	@result = EXPADV.Components.stargate.LuaTablesToArrayOfTables(@value 1:WireGetAddresses())
end
]], "@result" )
Component:AddFunctionHelper( "stargateAddressList", "wl:", "Returns stargate address list." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateRandomAddress", "e:n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) and StarGate and StarGate.RandomGateName and EXPADV.PPCheck(Context,@value 1) then 
	$StarGate.RandomGateName(nil,@value 1,nil,true,@value 2)
end
]])
Component:AddFunctionHelper( "stargateRandomAddress", "e:n", "Sets random stargate address." )

Component:AddPreparedFunction( "stargateRandomAddress", "wl:n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate and @value 1:CAP_CanModify(Context.player) and StarGate and StarGate.RandomGateName then
	$StarGate.RandomGateName(nil,@value 1,nil,true,@value 2)
end
]])
Component:AddFunctionHelper( "stargateRandomAddress", "wl:n", "Sets random stargate address." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateTransferEnergy", "e:n", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@@result = @value 1:TransferResource("energy", @value 2)
end
]], "@result" )
Component:AddFunctionHelper( "stargateTransferEnergy", "e:n", "Transfer energy between two connected stargates. Use negative value to retrieve energy. Returns transferred amount of energy if successful." )

Component:AddPreparedFunction( "stargateTransferEnergy", "wl:n", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@@result = @value 1:TransferResource("energy", @value 2)
end
]], "@result" )
Component:AddFunctionHelper( "stargateTransferEnergy", "wl:n", "Transfer energy between two connected stargates. Use negative value to retrieve energy. Returns transferred amount of energy if successful." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateTransferResource", "e:s,n", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@@result = @value 1:TransferResource(@value 2, @value 3)
end
]], "@result" )
Component:AddFunctionHelper( "stargateTransferResource", "e:s,n", "Transfer resource between two connected stargates. Use negative value to retrieve resource. Returns transferred amount of resource if successful." )

Component:AddPreparedFunction( "stargateTransferResource", "wl:s,n", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@@result = @value 1:TransferResource(@value 2, @value 3)
end
]], "@result" )
Component:AddFunctionHelper( "stargateTransferResource", "wl:s,n", "Transfer resource between two connected stargates. Use negative value to retrieve resource. Can transfer only to dialled gate (not from). Returns transferred amount of resource if successful." )
--[[
Component:AddVMFunction( "stargateRandomAddress", "e:n", "", function( Context, Trace, Entity, Bool )
	if IsValid(Entity) and @value 1.IsStargate and Entity:CAP_CanModify(Context.player) and StarGate and StarGate.RandomGateName and EXPADV.PPCheck(Context,Entity) then 
		StagGate.RandomGateName(nil,@value 1,nil,true,Bool)
	end
end)
Component:AddFunctionHelper( "stargateRandomAddress", "e:n", "Sets random stargate address." )

Component:AddVMFunction( "stargateRandomAddress", "wl:n", "", function( Context, Trace, Entity, Bool )
	if IsValid(Entity) and @value 1.IsStargate and Entity:CAP_CanModify(Context.player) and StarGate and StarGate.RandomGateName and EXPADV.PPCheck(Context,Entity) then 
		StagGate.RandomGateName(nil,@value 1,nil,true,Bool)
	end
end)
Component:AddFunctionHelper( "stargateRandomAddress", "wl:n", "Sets random stargate address." )
]]--
-------------------------------------------------------------------------
Component:AddInlineFunction( "stargateSystemType", "", "n","$GetConVar(\"stargate_group_system\"):GetBool() and 1 or 0")
Component:AddFunctionHelper( "stargateSystemType", "", "Returns type of used stargate system." )
-------------------------------------------------------------------------

Component:AddVMFunction( "stargateIsInJamming", "v", "n", function( Context, Trace, Vec )
	local radius = 1024; -- max range of jamming, we will adjust it later
	local jaiming_online = 0;
	for _,v in pairs(ents.FindInSphere(Vec,  radius)) do
		if IsValid(v) and v.CapJammingDevice then
			if v.IsEnabled then
				local dist = Vec:Distance(v:GetPos());
				if (dist < v.Size) then  -- ow jaiming, we cant do anything
					jaiming_online = 1
				end
			end
		end
	end
	return jaiming_online;
end)

Component:AddFunctionHelper( "stargateIsInJamming", "v", "Returns position is jammed." )
-------------------------------------------------------------------------

Component:AddVMFunction( "stargateIsInJamming", "v,e", "n", function( Context, Trace, Vec, Ply )
	if (not IsValid(Ply) or not Ply:IsPlayer()) then return -1 end
	local radius = 1024; -- max range of jamming, we will adjust it later
	local jaiming_online = 0;
	for _,v in pairs(ents.FindInSphere(Vec,  radius)) do
		if IsValid(v) and v.CapJammingDevice then
			if v.IsEnabled then
				local dist = Vec:Distance(v:GetPos());
				if (dist < v.Size) then  -- ow jaiming, we cant do anything
					if not (v.Immunity and v.Owner == Ply) then jaiming_online = 1 end
				end
			end
		end
	end
	return jaiming_online;
end)

Component:AddFunctionHelper( "stargateIsInJamming", "v,e", "Returns position is jammed." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateTransmit", "e:s", "n",
[[@define result = -2
if IsValid(@value 1) and @value 1.IsStargate and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1:TriggerInput("Transmit",@value 2)
end
]], "@result" )
Component:AddFunctionHelper( "stargateTransmit", "e:s", "Transmit string to remote SG." )

Component:AddPreparedFunction( "stargateTransmit", "wl:s", "n",
[[@define result = -2
if IsValid(@value 1) and @value 1.IsStargate then
	@result = @value 1:TriggerInput("Transmit",@value 2)
end
]], "@result" )
Component:AddFunctionHelper( "stargateTransmit", "wl:s", "Transmit string to remote SG." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateRingAddress", "e:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsRings and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1.Address or ""
end
]], "@result" )
Component:AddFunctionHelper( "stargateRingAddress", "e:", "Returns ring address." )

Component:AddPreparedFunction( "stargateRingAddress", "wl:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsRings then 
	@result = @value 1.Address or ""
end
]], "@result" )
Component:AddFunctionHelper( "stargateRingAddress", "wl:", "Returns ring address." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateRingSetAddress", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsRings and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetRingAddress(@value 2)
end
]])
Component:AddFunctionHelper( "stargateRingSetAddress", "e:s", "Sets ring address." )

Component:AddPreparedFunction( "stargateRingSetAddress", "wl:s", "",
[[
if IsValid(@value 1) and @value 1.IsRings and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetRingAddress(@value 2)
end
]])
Component:AddFunctionHelper( "stargateRingSetAddress", "wl:s", "Sets ring address." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateRingDial", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsRings and not @value 1.Busy and EXPADV.PPCheck(Context,@value 1) then 
	if (@value 2:gsub("[^0-9]","")!="") then 
		@value 1:Dial(@value 2);
	else
		@value 1:Dial(" "); -- fail
	end
end
]])
Component:AddFunctionHelper( "stargateRingDial", "e:s", "Dials rings." )

Component:AddPreparedFunction( "stargateRingDial", "wl:s", "",
[[
if IsValid(@value 1) and @value 1.IsRings and not @value 1.Busy then 
	if (@value 2:gsub("[^0-9]","")!="") then 
		@value 1:Dial(@value 2);
	else
		@value 1:Dial(" "); -- fail
	end
end
]])
Component:AddFunctionHelper( "stargateRingDial", "wl:s", "Dials rings." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateRingDialClosest", "e:", "",
[[
if IsValid(@value 1) and @value 1.IsRings and not @value 1.Busy and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:Dial("");
end
]])
Component:AddFunctionHelper( "stargateRingDialClosest", "e:", "Dials closest rings." )

Component:AddPreparedFunction( "stargateRingDialClosest", "wl:", "",
[[
if IsValid(@value 1) and @value 1.IsRings and not @value 1.Busy then 
	@value 1:Dial("");
end
]])
Component:AddFunctionHelper( "stargateRingDialClosest", "wl:", "Dials closest rings." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAsgardTeleport", "e:v,v,n", "",
[[
if IsValid(@value 1) and @value 1:GetClass() == "transporter" and EXPADV.PPCheck(Context,@value 1) then 
	@value 1.TeleportEverything = $util.tobool(@value 4);
	@value 1:Teleport(@value 2, @value 3);
end
]])
Component:AddFunctionHelper( "stargateAsgardTeleport", "e:v,v,n", "Uses asgard teleporter." )

Component:AddPreparedFunction( "stargateAsgardTeleport", "wl:v,v,n", "",
[[
if IsValid(@value 1) and @value 1:GetClass() == "transporter" then 
	@value 1.TeleportEverything = $util.tobool(@value 4);
	@value 1:Teleport(@value 2, @value 3);
end
]])
Component:AddFunctionHelper( "stargateAsgardTeleport", "wl:v,v,n", "Uses asgard teleporter." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAtlantisTPGetName", "e:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsAtlTP and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1.TName or "" 
end
]], "@result" )
Component:AddFunctionHelper( "stargateAtlantisTPGetName", "e:", "Returns atlantis teleport name." )

Component:AddPreparedFunction( "stargateAtlantisTPGetName", "wl:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsAtlTP then 
	@result = @value 1.TName or "" 
end
]], "@result" )
Component:AddFunctionHelper( "stargateAtlantisTPGetName", "wl:", "Returns atlantis teleport name." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAtlantisTPSetName", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsAtlTP and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetAtlName(@value 2,true)
end
]])
Component:AddFunctionHelper( "stargateAtlantisTPSetName", "e:s", "Sets atlantis teleport name." )

Component:AddPreparedFunction( "stargateAtlantisTPSetName", "wl:s", "",
[[
if IsValid(@value 1) and @value 1.IsAtlTP and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetAtlName(@value 2,true)
end
]])
Component:AddFunctionHelper( "stargateAtlantisTPSetName", "wl:s", "Sets atlantis teleport name." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAtlantisTPGetGroup", "e:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsAtlTP and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1.TGroup or "" 
end
]], "@result" )
Component:AddFunctionHelper( "stargateAtlantisTPGetGroup", "e:", "Returns atlantis teleport group." )

Component:AddPreparedFunction( "stargateAtlantisTPGetGroup", "wl:", "s",
[[@define result = ""
if IsValid(@value 1) and @value 1.IsAtlTP then 
	@result = @value 1.TGroup or "" 
end
]], "@result" )
Component:AddFunctionHelper( "stargateAtlantisTPGetGroup", "wl:", "Returns atlantis teleport group." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAtlantisTPSetGroup", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsAtlTP and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetAtlGrp(@value 2,true)
end
]])
Component:AddFunctionHelper( "stargateAtlantisTPSetGroup", "e:s", "Sets atlantis teleport group." )

Component:AddPreparedFunction( "stargateAtlantisTPSetGroup", "wl:s", "",
[[
if IsValid(@value 1) and @value 1.IsAtlTP and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetAtlGrp(@value 2,true)
end
]])
Component:AddFunctionHelper( "stargateAtlantisTPSetGroup", "wl:s", "Sets atlantis teleport group." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAtlantisTPGetPrivate", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsAtlTP and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1.TPrivate and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateAtlantisTPGetPrivate", "e:", "Returns atlantis teleport private state." )

Component:AddPreparedFunction( "stargateAtlantisTPGetPrivate", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsAtlTP then 
	@result = @value 1.TPrivate and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateAtlantisTPGetPrivate", "wl:", "Returns atlantis teleport private state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAtlantisTPSetPrivate", "e:n", "",
[[
if IsValid(@value 1) and @value 1.IsAtlTP and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetAtlPrivate(@value 2)
end
]])
Component:AddFunctionHelper( "stargateAtlantisTPSetPrivate", "e:n", "Sets atlantis teleport private state." )

Component:AddPreparedFunction( "stargateAtlantisTPSetPrivate", "wl:n", "",
[[
if IsValid(@value 1) and @value 1.IsAtlTP and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetAtlPrivate(@value 2)
end
]])
Component:AddFunctionHelper( "stargateAtlantisTPSetPrivate", "wl:n", "Sets atlantis teleport private state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAtlantisTPGetLocal", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsAtlTP and EXPADV.PPCheck(Context,@value 1) then 
	@result = @value 1.TLocal and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateAtlantisTPGetLocal", "e:", "Returns atlantis teleport local state." )

Component:AddPreparedFunction( "stargateAtlantisTPGetLocal", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsAtlTP then 
	@result = @value 1.TLocal and 1 or 0
end
]], "@result" )
Component:AddFunctionHelper( "stargateAtlantisTPGetLocal", "wl:", "Returns atlantis teleport local state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAtlantisTPSetLocal", "e:n", "",
[[
if IsValid(@value 1) and @value 1.IsAtlTP and @value 1:CAP_CanModify(Context.player) and EXPADV.PPCheck(Context,@value 1) then 
	@value 1:SetAtlLocal(@value 2)
end
]])
Component:AddFunctionHelper( "stargateAtlantisTPSetLocal", "e:n", "Sets atlantis teleport local state." )

Component:AddPreparedFunction( "stargateAtlantisTPSetLocal", "wl:n", "",
[[
if IsValid(@value 1) and @value 1.IsAtlTP and @value 1:CAP_CanModify(Context.player) then 
	@value 1:SetAtlLocal(@value 2)
end
]])
Component:AddFunctionHelper( "stargateAtlantisTPSetLocal", "wl:n", "Sets atlantis teleport local state." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAtlantisTPTeleport", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsAtlTP and EXPADV.PPCheck(Context,@value 1) then 
	@value 1.Destination = @value 2
	@value 1:Teleport()
end
]])
Component:AddFunctionHelper( "stargateAtlantisTPTeleport", "e:s", "Uses atlantis teleport." )

Component:AddPreparedFunction( "stargateAtlantisTPTeleport", "wl:s", "",
[[
if IsValid(@value 1) and @value 1.IsAtlTP then 
	@value 1.Destination = @value 2
	@value 1:Teleport()
end
]])
Component:AddFunctionHelper( "stargateAtlantisTPTeleport", "wl:s", "Uses atlantis teleport." )
-------------------------------------------------------------------------

Component:AddPreparedFunction( "stargateAtlantisTPAddressList", "e:", "ar",
[[@define result = {}
if IsValid(@value 1) and @value 1.IsAtlTP and EXPADV.PPCheck(Context,@value 1) then 
	@result = EXPADV.Components.stargate.LuaTablesToArrayOfTables(@value 1:WireGetAddresses()) 
end
@result.__type = "s"
]], "@result" )
Component:AddFunctionHelper( "stargateAtlantisTPAddressList", "e:", "Returns atlantis teleports list." )

Component:AddPreparedFunction( "stargateAtlantisTPAddressList", "wl:", "ar",
[[@define result = {}
if IsValid(@value 1) and @value 1.IsAtlTP then 
	@result = EXPADV.Components.stargate.LuaTablesToArrayOfTables(@value 1:WireGetAddresses()) 
end
@result.__type = "s"
]], "@result" )
Component:AddFunctionHelper( "stargateAtlantisTPAddressList", "wl:", "Returns atlantis teleports list." )
-------------------------------------------------------------------------

EXPADV.SharedOperators()
Component:AddPreparedFunction( "stargateGetRingAngle2", "e:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate and (CLIENT or EXPADV.PPCheck(Context,@value 1)) then 
	@result = @value 1.GetRingAng and @value 1:GetRingAng() or -1
end
]], "@result" )
Component:AddFunctionHelper( "stargateGetRingAngle2", "e:", "Returns stargate ring angle. Available both clientside and serverside." )

Component:AddPreparedFunction( "stargateGetRingAngle2", "wl:", "n",
[[@define result = -1
if IsValid(@value 1) and @value 1.IsStargate then 
	@result = @value 1.GetRingAng and @value 1:GetRingAng() or -1
end
]], "@result" )

Component:AddFunctionHelper( "stargateGetRingAngle2", "wl:", "Returns stargate ring angle. Available both clientside and serverside." )
-------------------------------------------------------------------------

