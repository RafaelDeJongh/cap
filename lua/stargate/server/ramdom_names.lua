-- This code makes it so gates get random names when they spawn! :D
-- Created by cartman300, edited by AlexALX

local function RandomAddress(max,exclude)
    local chr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ@1234567890"
    local ret = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

local function RandomNumber(max)
    local exclude = ""
    local chr = "0123456789"
    local ret = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

local function RandomString(max)
    local exclude = ""
    local chr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local ret = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

local function RandomAll(max)
    local chr = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local ret = ""
    local exclude = ""
    while(ret:len() < max) do
        local ll = math.random(1,chr:len())
        local r = chr:sub( ll, ll )
        local match = "[^"..ret..exclude.."%z]"
        if !r:match(match) then continue end
        ret = ret .. r
    end
    return ret
end

function StarGate.RandomGateName(ply,ent,count,wire,mode)
	local conv = GetConVar("stargate_random_address")
    if (conv and conv:GetBool() or wire) then
        if (IsValid(ent) and ent.IsStargate and ent:GetClass()!="stargate_orlin") then
        	if (mode==nil or mode<=1) then
	        	local randadr = "";
	        	if (GetConVar("stargate_group_system"):GetBool()) then
					randadr = RandomAddress(6,ent:GetGateGroup())
	            else
					randadr = RandomAddress(6,"@0")
	            end
				local valid = false;
				for k,v in pairs(ents.FindByClass("stargate_*")) do
					if (v.IsStargate) then
						if (v:GetGateGroup()==ent:GetGateGroup() and randadr==v:GetGateAddress()) then
							valid = true; break;
						end
					end
				end
				count = count or 1;
				if valid then
					if (count>5) then return end -- fix infinity loop
					StarGate.RandomGateName(ply,ent,count+1,wire,mode); return
				end
				ent:SetGateAddress(randadr);
			end
			if (mode==nil or mode<=0 or mode>=2) then
	            if (ent:GetClass() == "stargate_atlantis") then
	                ent:SetGateName("M"..RandomNumber(1)..RandomString(1).."-"..RandomNumber(1)..RandomAll(2))
	            elseif (ent:GetClass() == "stargate_supergate") then
	                ent:SetGateName(RandomAll(7))
	            elseif (ent:GetClass() == "stargate_universe") then
	                ent:SetGateName("U-"..RandomNumber(5))
	            else
	                ent:SetGateName("P"..RandomNumber(1)..RandomString(1).."-"..RandomNumber(1)..RandomAll(2))
	            end
            end
        end
    end
end

hook.Add("PlayerSpawnedSENT","RandomGateName",StarGate.RandomGateName)
