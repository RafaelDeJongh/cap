if !WireLib then 
	print("No WireLib detected.")
	return
end

local Component = EXPADV.AddComponent( "stargatetesting", true )

Component.Author = "E2 source by AlexALX, ported and updated by Kawoosh"
Component.Description = "Adds functions for stargate CAP addon."

EXPADV.ServerOperators()

Component:AddPreparedFunction( "stargateTestDial", "e:s", "",
[[
if IsValid(@value 1) and @value 1.IsStargate then
	if EXPADV.PPCheck(Context,@value 1) or @value 1.player:IsAdmin() then 
		@value 1:DialGate(string.upper(@value 2))
	end
end
]])
Component:AddFunctionHelper( "stargateTestDial", "e:s", "Dials stargate slowly." )

Component:AddPreparedFunction( "stargateTestDial", "e:s,n", "",
[[
if IsValid(@value 1) and @value 1.IsStargate then
	if EXPADV.PPCheck(Context,@value 1) or @value 1.player:IsAdmin() then 
		if @value 3 >= 2 then 
			@value 1:NoxDialGate(string.upper(@value 2)) 
		else 
			@value 1:DialGate(string.upper(@value 2),$util.tobool(@value 3)) 
		end
	end
end
]])
Component:AddFunctionHelper( "stargateTestDial", "e:s,n", "Dials stargate with mode selection." )
