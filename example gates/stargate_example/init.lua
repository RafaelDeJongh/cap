-- IMPORTANT: Your gate's SENT name HAS TO START with "stargate_"

-- Your gate should start with the common header
-- Includes (necessary)
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");
include("modules/dialling.lua");

-- Defines
-- Sounds need to get added to this table ALWAYS!. Predefined and used Keys: "Open";"Ring","Travel","Close","Chevron","Fail"
-- Please use Sound() to make the sounds precached automatically
ENT.Sounds={MyFirstSound=Sound("path/to/sound.mp3")};
-- Store your models in here please. The gate is autopreachimng them
ENT.Models = {};

-- For more information about these files, look at them

-- How to code your init...
function ENT:Initialize()
	-- Before (or after, I don't care) you do anything in here, you need to call the Initialize from the "stargate_base" SENT
	self.BaseClass.Initialize(self);
	-- Now, our gate is ready to get coded
end

-- ### HOOKS and special functions

-- This function is getting called at the end of ENT:Close() or ENT.Sequence:DialFail. E.g. the atlantis gates uses this to make it's light-ring stop illuminating  (NOT REQUIRED)
function ENT:Shutdown() end
-- Adds the ring to the gate (NOT REQUIRED)
function ENT:AddRing() end
-- Activates the ring of the gate (NOT REQUIRED)
function ENT:ActivateRing() end
-- Adds a chevron to a gate (NOT REQUIRED). When you code this and you want to add a Chevron, put it to self.Chevron[number_ov_chevron]
function ENT:AddChevron() end
-- Activates a chevron (NOT REQUIRED)
function ENT:ActivateChevron() end
-- Plays a chevron sound (NOT REQUIRED).
function ENT:ChevronSound() end

-- Now you can add behaviour and other stuff of this gate down here e.g. like loading chevrons etc
-- The complete dialling part should be done in "modules/dialling.lua"