if GetRTManager then return end
------------------------------------------------------------
--  RenderTarget manager, copied from WireMod's WireGPU.  --
--  By Mijyuoon.                                          --
------------------------------------------------------------
local RT_Manager = {}
RT_Manager.__index = RT_Manager

function GetRTManager(prefix, wid, hgt, size)
	if not prefix then return nil end
	local self = setmetatable({}, RT_Manager)
	self:Init(prefix, wid, hgt, size)
	return self
end

-- Handles rendertarget caching
function RT_Manager:Init(prefix, width, height, size)
	self.RT_Prefix = prefix
	self.RT_Width = width or 512
	self.RT_Height = height or 512
	self.RT_CacheSize = size or 32
	self.RT_CacheTbl = {}

	for i = 1, self.RT_CacheSize do
		table.insert(self.RT_CacheTbl, {
			false, -- Is rendertarget in use
			false -- The rendertarget (false if doesn't exist)
		})
	end
end

local function Clear_RT(rt)
	render.PushRenderTarget(rt)
	cam.Start2D()
		render.Clear(0, 0, 0, 255)
	cam.End2D()
	render.PopRenderTarget()
end

-- Returns a render target from the cache pool and marks it as used
function RT_Manager:GetRT()
	for _, RT in pairs(self.RT_CacheTbl) do
		if not RT[1] then -- not used
			local rendertarget = RT[2]
			if rendertarget then
				RT[1] = true -- Mark as used
				Clear_RT(rendertarget)
				return rendertarget
			end
		end
	end

	-- No free rendertargets. Find first non used and create it.
	for i, RT in pairs(self.RT_CacheTbl) do
		if not RT[1] and RT[2] == false then
			local rt_name = self.RT_Prefix.."_RT_"..i
			local rendertarget = GetRenderTarget(rt_name, self.RT_Width, self.RT_Height)
			if rendertarget then
				RT[1] = true -- Mark as used
				RT[2] = rendertarget -- Assign the RT
				Clear_RT(rendertarget)
				return rendertarget
			else
				RT[1] = true -- Mark as used since we couldn't create it
				ErrorNoHalt("Render target "..rt_name.." could not be created!\n")
			end
		end
	end

	ErrorNoHalt("All render targets are in use!\n")
	return nil
end

-- Frees an used RT
function RT_Manager:FreeRT(rt)
	for _, RT in pairs(self.RT_CacheTbl) do
		if RT[2] == rt then
			RT[1] = false
			return
		end
	end

	rt = rt and rt:GetName() or "(nil)"
	ErrorNoHalt("Render target "..rt.." could not be freed!\n")
end
