-- This file should normally only include the "shared.lua"
include("shared.lua");
-- This says the stargate_base, in what color (if wished) it shall draw the chevron's lights (the dynamic light)
-- You can toogle these on and off with self.Entity:SetNWBool("chevron"..chevron_number,true);
ENT.ChevronColor = Color(30,135,180);