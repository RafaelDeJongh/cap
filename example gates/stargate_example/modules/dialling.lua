-- This is necessary:
ENT.Sequence = {};

--When you start coding a dialling or whatever sequence, you have to put it into ENT.Sequence. Normal behaviour is applied

-- This is the only function, which is NECESSARY. It needs to return an animation table
function ENT.Sequence:Dial(inbound,fast,fail)
	-- Create our animation table
	local action = self:New();
	-- Adding animation to the animation table
	action:Add({f=function_to_call,v={argument1,argument2,argument3},d=delay_in_seconds});
	action:Add({pause=true,d=delay_in_seconds}); -- A pause!
	
	-- How to call functions of the SENT, aka self:Open()
	action:Add({f=self.Open,v={self},d=0});
	-- Note, the first argument needs to be "self" itself. For more, read the lua documentation what the difference between : and . calling is
	
	-- WHEN YOU ARE GETTING ERRORS like "expected entity, got table instead" use self.Entity as argument
	action:Add({f=self.EmitSound,v={self.Entity,Sound("make_that_kawoosh_sound.mp3")},d=0});
	return action;
end


-- Additional stuff
-- When you want to light up a chevron (currently only for normal gates working), you need to set the special NWInt:
self.Entity:SetNWBool("chevron"..chevron_number,false or true); -- This will enable a light. Usefull for chevron lock functions USE IT in ENT:ActivateChevron(), mentioned in init.lua