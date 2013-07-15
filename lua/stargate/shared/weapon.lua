--[[
	Copyright (C) 2012 Llapp, AlexALX
]]--

if (CLIENT) then
	local function DropBindPress( ply, bind, pressed )
	        if ply:Alive() then
	                if string.find( bind, "impulse 201" )then RunConsoleCommand("Drop_Weapon"); return false end
	        end
	end
	hook.Add("PlayerBindPress", "DropBindPress", DropBindPress)
end

if (SERVER) then

	-- damn man, this should be only server-side, or there is lags in mp.
	local function Drop(ply)
		if (not GetConVar("cap_drop_weapons"):GetBool()) then return end
		if(not ply:GetActiveWeapon():IsValid() or ply:IsTyping())then return end
   		local tr = ply:GetEyeTraceNoCursor();
   		local class = ply:GetActiveWeapon():GetClass();
   		local ent = ents.Create(class);
   		ent:SetPos(tr.StartPos+ply:GetAimVector()-Vector(0,0,5))
   		ent:SetAngles(Angle(0,ply:EyeAngles().y,0))
   		ent:Spawn()
   		ent:Activate()
		ent:PhysicsInit(SOLID_VPHYSICS)
		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:SetSolid(SOLID_VPHYSICS);
		ent.PhysFixEnt = true;
   		local phys = ent:GetPhysicsObject()
   		if (IsValid(phys)) then
   			phys:Wake()
   			phys:AddAngleVelocity(Vector(100,50,100))
   			phys:SetVelocity(ply:GetAimVector()*Vector(250,250,0));
   			ply:StripWeapon(class);
   			-- this is fix for player touch
     		local ent2 = ents.Create(class)
     		ent2:PhysWake();
			ent2:SetPos(tr.StartPos+ply:GetAimVector()-Vector(0,0,5))
	   		ent2:SetAngles(Angle(0,ply:EyeAngles().y,0))
	   		ent2:Spawn()
	   		ent2:Activate()
	   		ent2:SetParent(ent)
	   		ent2:SetColor(Color(0,0,0,0))
	   		ent2:SetRenderMode(RENDERMODE_TRANSALPHA)
	   		ent2.PhysFixEnt = true;
	   		ent.PhysFix = ent2;
	   		timer.Simple(1.0,function() if IsValid(ent) then ent.PhysFixEnt = false end end);
   		else
   			ent:Remove();
			ply:DropWeapon(ply:GetActiveWeapon())
   		end
	end
	concommand.Add("Drop_Weapon", Drop)

	hook.Add("PlayerCanPickupWeapon","StarGate.PlayerCanPickupWeapon.PhysFix",function(ply,wep)
		if (wep.PhysFixEnt) then return false end
		if (IsValid(wep.PhysFix)) then wep.PhysFix:Remove() end
		return
	end)

	-- Instead of loading every second, this can be like hook when player changed weapon
	-- and this should be also server-side only or we have LAGS in mp.

	hook.Add("PlayerSwitchWeapon", "StarGate.WeaponCheck.Changed", function(ply, weapon1, weapon2)
		if (not ply or not IsValid(ply) or not ply:IsPlayer() or not IsValid(weapon1) or not IsValid(weapon2)) then return end
		-- if we changed to weapon atanik_armband
		if (weapon2:GetClass()=="atanik_armband") then
			ply:SetRunSpeed(1000)
		    ply:SetJumpPower(500)
			ply:SetArmor(200)
		-- if we changed from weapon atanik_armband to another
		elseif (weapon1:GetClass()=="atanik_armband") then
		    ply:SetRunSpeed(500)
			ply:SetJumpPower(200)
			ply:SetArmor(0)
		end
		-- PLEASE DO NOT EDIT! it works perfect in sp and mp! Don't touch code!
	end)
end