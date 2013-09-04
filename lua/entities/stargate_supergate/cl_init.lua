include("shared.lua");

ENT.ChevronColor = Color(50,50,180);
if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("stargate_category");
ENT.PrintName = SGLanguage.GetMessage("stargate_supergate");
end

--################# Think function, to set the gates address @aVoN
function ENT:Think()
	--######### Dynamic Lights, toggleable by the client!
	if(not StarGate.VisualsMisc("cl_supergate_dynlights")) then return end;
	if((self.NextLight or 0) < CurTime()) then
		self.NextLight = CurTime()+0.001;
		for i=1,72 do
			if(self.Entity:GetNetworkedBool("chevron"..i,false)) then
				-- Clientside lights, yeah! Can be toggled by clients this causes much less lag when deactivated. Method below is from Catdaemon's harvester
				local dlight = DynamicLight(self:EntIndex()..i);
				if(dlight) then

					local radius = 2375;
					local pos = self.Entity:GetPos()+Vector(0,0,radius)
					local x = math.sin(math.rad(i*5))*radius;
					local y = math.cos(math.rad(i*5))*radius;

					dlight.Pos = pos + Vector(x,10,y);
					dlight.r = self.ChevronColor.r;
					dlight.g = self.ChevronColor.g;
					dlight.b = self.ChevronColor.b;
					dlight.Brightness = 5;
					dlight.Decay = 1200;
					dlight.Size = 1200;
					dlight.DieTime = CurTime()+1;
				end
			end
		end
	end
end

