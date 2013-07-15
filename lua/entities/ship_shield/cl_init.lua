include("shared.lua");
language.Add("ship_shield",Language.GetMessage("ship_shield"));
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


