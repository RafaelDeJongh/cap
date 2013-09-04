include("shared.lua");
include("modules/bullets.lua");
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
language.Add("shield",SGLanguage.GetMessage("stool_shield"));
end
if (StarGate==nil or StarGate.Trace==nil) then return end
-- Register shield SENT to the trace class
StarGate.Trace:Add("shield",
	function(e,values,trace,in_box)
		local depleted = e:GetNetworkedBool("depleted",false);
		local containment = e:GetNWBool("containment",false);
		if(not depleted) then
			if((containment and in_box) or (not containment and not in_box)) then
				return true;
			end
		end
	end
);
function ENT:Draw() end -- Do not draw the shield
--################# Retrieves the shield color @aVoN
function ENT:GetShieldColor()
	local v = self.Entity:GetNWVector("shield_color",Vector(1,1,1));
	return Color(v.x,v.y,v.z);
end
