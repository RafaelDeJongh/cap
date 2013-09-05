--[[
	Destiny Console
	Copyright (C) 2010 Madman07
]]--

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
include("shared.lua");

ENT.Sounds = {
	Butt1 = Sound("button/button_press1.wav"),
	Butt2 = Sound("button/button_press2.wav"),
	Butt3 = Sound("button/button_press3.wav"),
	Butt4 = Sound("button/button_press4.wav"),
	Alarm = Sound("alarm/destiny_alarm.wav"),
}

ENT.ButtModels = {

	"models/Iziraider/destiny_dhd/butt_1.mdl",
	"models/Iziraider/destiny_dhd/butt_2.mdl",
	"models/Iziraider/destiny_dhd/butt_3.mdl",
	"models/Iziraider/destiny_dhd/butt_4.mdl",
	"models/Iziraider/destiny_dhd/butt_5.mdl",
	"models/Iziraider/destiny_dhd/butt_6.mdl",
	"models/Iziraider/destiny_dhd/butt_7.mdl",
	"models/Iziraider/destiny_dhd/butt_8.mdl",

	"models/Iziraider/destiny_dhd/butt_A.mdl",
	"models/Iziraider/destiny_dhd/butt_B.mdl",

	"models/Iziraider/destiny_dhd/butt_s1.mdl",
	"models/Iziraider/destiny_dhd/butt_s2.mdl",

	"models/Iziraider/destiny_dhd/butt_k1.mdl",
	"models/Iziraider/destiny_dhd/butt_k2.mdl",
	"models/Iziraider/destiny_dhd/butt_k3.mdl",
	"models/Iziraider/destiny_dhd/butt_k4.mdl",

	"models/Iziraider/destiny_dhd/butt_dhd.mdl",

}

-----------------------------------INIT----------------------------------

util.AddNetworkString("destiny_console");

function ENT:Initialize()
	self.Entity:SetName("Destiny Console");
	self.Entity:SetModel("models/Iziraider/destiny_dhd/body.mdl");
	self.Entity:PhysicsInit(SOLID_VPHYSICS);
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);
	self.Entity:SetSolid(SOLID_VPHYSICS);
	self.Entity:SetUseType(SIMPLE_USE);
	self.Range = StarGate.CFG:Get("mobile_dhd","range",3000);

	local outputs = {
		"1","2","3","4",
		"5","6","7","8",
		"A", "B"
	}

	local inputs = {
		"Alarm [NORMAL]", "A [NORMAL]", "B [NORMAL]", "C [NORMAL]", "D [NORMAL]", "E [NORMAL]", "F [NORMAL]", "G [NORMAL]", "H [NORMAL]",
		"Name A [STRING]","Name B [STRING]","Name C [STRING]","Name D [STRING]","Name E [STRING]","Name F [STRING]","Name G [STRING]","Name H [STRING]"
	}

	if (WireAddon) then
		self.Outputs = WireLib.CreateOutputs( self.Entity, outputs);
		self.Inputs = WireLib.CreateInputs( self.Entity, inputs);
	end

	self.Toggle = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
		[8] = 0,
	}

	self.LetKey = {
		[1] = "A",
		[2] = "B",
	}

	self.Entity:SetNetworkedString("Buttons",string.Implode(",",self.Toggle));

	self.ScreenTextA = "ValueA";
	self.ScreenTextB = "ValueB";
	self.ScreenTextC = "ValueC";
	self.ScreenTextD = "ValueD";
	self.ScreenTextE = "ValueE";
	self.ScreenTextF = "ValueF";
	self.ScreenTextG = "ValueG";
	self.ScreenTextH = "ValueH";

	self.Entity:SetNetworkedString("NameA",self.ScreenTextA);
	self.Entity:SetNetworkedString("NameB",self.ScreenTextB);
	self.Entity:SetNetworkedString("NameC",self.ScreenTextC);
	self.Entity:SetNetworkedString("NameD",self.ScreenTextD);
	self.Entity:SetNetworkedString("NameE",self.ScreenTextE);
	self.Entity:SetNetworkedString("NameF",self.ScreenTextF);
	self.Entity:SetNetworkedString("NameG",self.ScreenTextG);
	self.Entity:SetNetworkedString("NameH",self.ScreenTextH);

	self.Entity:SetNetworkedInt("ValueA",0);
	self.Entity:SetNetworkedInt("ValueB",0);
	self.Entity:SetNetworkedInt("ValueC",0);
	self.Entity:SetNetworkedInt("ValueD",0);
	self.Entity:SetNetworkedInt("ValueE",0);
	self.Entity:SetNetworkedInt("ValueF",0);
	self.Entity:SetNetworkedInt("ValueG",0);
	self.Entity:SetNetworkedInt("ValueH",0);

	self.Light = false;
	self.Busy = false;
	self.WireDisplay = 1;

	self.Entity:SetNetworkedInt("Wire",self.WireDisplay);
	self:SpawnButtons();
	self:SetNetworkedEntity("Screen",self.Screen);
end

function ENT:SpawnButtons()
	self.Buttons={};
	local pos = self.Entity:GetPos();
	local ang = self.Entity:GetAngles();
	for i=1,table.getn(self.ButtModels) do
		local e = ents.Create("prop_dynamic");
		e:SetModel(self.ButtModels[i]);
		e:SetParent(self.Entity);
		e:SetDerive(self.Entity); -- Derive Material/Color from "Parent"
		e:DrawShadow(false);
		e:SetAngles(ang);
		e:SetPos(pos);
		e:Spawn();
		e:Activate();
		self.Buttons[i] = e;
		e:SetDerive(self.Entity); -- Derive Material/Color from "Parent"
	end

	self.Screen = ents.Create("prop_dynamic");
	self.Screen:SetModel("models/Iziraider/destiny_dhd/screen.mdl");
	self.Screen:SetParent(self.Entity);
	self.Screen:DrawShadow(false);
	self.Screen:SetAngles(ang);
	self.Screen:SetPos(pos+Vector(0,0,0.05));
	self.Screen:Spawn();
	self.Screen:Activate();
	self.Screen:SetSkin(0);
end

-----------------------------------SPAWN----------------------------------

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local PropLimit = GetConVar("CAP_destcon_max"):GetInt()
	if(ply:GetCount("CAP_destcon")+1 > PropLimit) then
		ply:SendLua("GAMEMODE:AddNotify(\"Destiny Console limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return
	end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("destiny_console");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos+Vector(0,0,5));
	ent:Spawn();
	ent:Activate();
	ent.Owner = ply;

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	ply:AddCount("CAPdestcon", ent)
	return ent
end

-----------------------------------WIRE----------------------------------

function ENT:TriggerInput(variable, value)
	if (variable == "Name A") then self.ScreenTextA = value; self.Entity:SetNetworkedString("NameA",value)
	elseif (variable == "Name B") then self.ScreenTextB = value; self.Entity:SetNetworkedString("NameB",value)
	elseif (variable == "Name C") then self.ScreenTextC = value; self.Entity:SetNetworkedString("NameC",value)
	elseif (variable == "Name D") then self.ScreenTextD = value; self.Entity:SetNetworkedString("NameD",value)
	elseif (variable == "Name E") then self.ScreenTextE = value; self.Entity:SetNetworkedString("NameE",value)
	elseif (variable == "Name F") then self.ScreenTextF = value; self.Entity:SetNetworkedString("NameF",value)
	elseif (variable == "Name G") then self.ScreenTextG = value; self.Entity:SetNetworkedString("NameG",value)
	elseif (variable == "Name H") then self.ScreenTextH = value; self.Entity:SetNetworkedString("NameH",value)

	elseif (variable == "A") then self.Entity:SetNetworkedInt("ValueA",value)
	elseif (variable == "B") then self.Entity:SetNetworkedInt("ValueB",value)
	elseif (variable == "C") then self.Entity:SetNetworkedInt("ValueC",value)
	elseif (variable == "D") then self.Entity:SetNetworkedInt("ValueD",value)
	elseif (variable == "E") then self.Entity:SetNetworkedInt("ValueE",value)
	elseif (variable == "F") then self.Entity:SetNetworkedInt("ValueF",value)
	elseif (variable == "G") then self.Entity:SetNetworkedInt("ValueG",value)
	elseif (variable == "H") then self.Entity:SetNetworkedInt("ValueH",value)

	elseif (variable == "Alarm") then
			if (value>0) then
		        self.SNDAlarm = CreateSound(self.Entity, self.Sounds.Alarm);
        		self.SNDAlarm:Play();
				self.SNDAlarm:ChangeVolume(100,0.1);
	    	else
				if (self.SNDAlarm) then
					self.SNDAlarm:Stop();
				end
	    	end
	end
end

-----------------------------------USE----------------------------------

function ENT:FlashButton(btn)
	local button = self.Buttons[btn];
	button:SetSkin(1);
	timer.Create(self.Entity:EntIndex().."Console_Btn"..tostring(btn), 0.5, 1, function()
		if (IsValid(button)) then
			button:SetSkin(0);
		end
	end);
end

function ENT:Use(ply, ...)
	local button = self:GetAimingButton(ply);
	if (button and not self.Busy) then
		if (button == 18) then --settings
			self.Busy = true;
			umsg.Start("DestConsole",ply)
			umsg.Entity(self.Entity);
			local vars = {"A","B","C","D","E","F","G","H"}
			for _,v in pairs(vars) do
				umsg.String(self["ScreenText"..v])
			end
			umsg.End()
		elseif (button == 17) then
			self.Busy = true;
			timer.Create( self.Entity:EntIndex().."Busy", 0.5, 1, function() self.Busy = false; end);
			self:EmitSound(self.Sounds.Butt1,100,math.random(98,102));
			if self.HaveCore then
				local shield = StarGate.FindShield(self.Entity);
				if IsValid(shield) then shield:Use(ply, ...); end
			else
				self.Entity:OpenMenu(ply);
			end
			self.Entity:FlashButton(button);
		elseif (button > 12 and button < 17) then
			self.Busy = true;
			timer.Create( self.Entity:EntIndex().."Busy", 0.5, 1, function() self.Busy = false; end);

			self:EmitSound(self.Sounds.Butt3,100,math.random(98,102));

			local number, KinoEnt = StarGate.FindKino(ply);
			local kino = KinoEnt[button - 12];
			if IsValid(kino) then UpdateRenderTarget(kino) end

			self.WireDisplay = 3;
			self.Entity:SetNetworkedInt("Wire",self.WireDisplay);
			self.Screen:SetSkin(1);
			self.Entity:FlashButton(button);

		elseif (button > 8 and button < 11) then
			self.Busy = true;
			timer.Create( self.Entity:EntIndex().."Busy", 0.5, 1, function() self.Busy = false; end);

			self:EmitSound(self.Sounds.Butt4,100,math.random(98,102));
			Wire_TriggerOutput(self.Entity, self.LetKey[button-8], 1)
			self.Entity:FlashButton(button);

			timer.Create( self.Entity:EntIndex().."Console"..tostring(button), 0.2, 1, function()
				Wire_TriggerOutput(self.Entity, self.LetKey[button-8], 0)
			end )

		elseif (button > 10 and button < 13) then
			self.Busy = true;
			timer.Create( self.Entity:EntIndex().."Busy", 0.5, 1, function() self.Busy = false; end);

			self:EmitSound(self.Sounds.Butt3,100,math.random(98,102));
			self.RT = false;
			self.WireDisplay = button-10;
			self.Entity:SetNetworkedInt("Wire",self.WireDisplay);
			self.Screen:SetSkin(0);
			self.Entity:FlashButton(button);

		else
			self.Busy = true;
			timer.Create( self.Entity:EntIndex().."Busy", 0.5, 1, function() self.Busy = false; end);

			self:EmitSound(self.Sounds.Butt2,100,math.random(98,102));
			self.Toggle[button] = button - self.Toggle[button];
			if (self.Toggle[button] == 0) then
				Wire_TriggerOutput(self.Entity, tostring(button), 0);
				self.Buttons[button]:SetSkin(0);
			else
				Wire_TriggerOutput(self.Entity, tostring(button), 1)
				self.Buttons[button]:SetSkin(1);
			end

		end

		local rand = math.Rand(1,4);
		if (rand == 1) then self.Entity:EmitSound(self.Sounds.Butt1,100,math.random(90,110));
		elseif (rand == 2) then self.Entity:EmitSound(self.Sounds.Butt2,100,math.random(90,110));
		elseif (rand == 3) then self.Entity:EmitSound(self.Sounds.Butt3,100,math.random(90,110));
		elseif (rand == 4) then self.Entity:EmitSound(self.Sounds.Butt4,100,math.random(90,110));
		end

		self.Entity:SetNetworkedString("Buttons",string.Implode(",",self.Toggle));
	end
end

-----------------------------------OTHER CRAP----------------------------------

net.Receive("destiny_console",function(length, player)
	local self = net.ReadEntity()
	if (IsValid(self)) then
		if (util.tobool(net.ReadBit())) then
			local vars = {"A","B","C","D","E","F","G","H"}
			for _,v in pairs(vars) do
				local val = net.ReadString();
				if (val!="") then
					self["ScreenText"..v] = val;
					self.Entity:SetNetworkedString("Name"..v,val);
				end
			end
		end
		self.Busy = false;
	end
end)

function ENT:Think(ply)

	local ply = StarGate.FindPlayer(self.Entity:GetPos(), 400);

	if ply then
		if not self.Light then
			self.Light = true;
			self.Entity:SetSkin(1);
			if self.HaveCore then self.Core:SetSkin(1); end
			self.Entity:SetNetworkedInt("Wire",self.WireDisplay);
		end
	else
		if self.Light then
			self.Light = false;
			self.Entity:SetSkin(0);
			if self.HaveCore then self.Core:SetSkin(0); end
			self.Entity:SetNetworkedInt("Wire",0);
		end
	end

	self.Entity:NextThink(CurTime()+0.5);
	return true
end

function ENT:OpenMenu(p)
	if(not IsValid(p)) then return end;
	local e = StarGate.FindGate(self.Entity, self.Range);
	if(not IsValid(e)) then return end;
	if(hook.Call("StarGate.Player.CanDialGate",GAMEMODE,p,e) == false) then return end;
	umsg.Start("StarGate.OpenDialMenuDHD",p);
	umsg.Entity(e);
	umsg.Entity(self.Entity);
	umsg.End();
end

-----------------------------------DUPLICATOR----------------------------------

function ENT:PreEntityCopy()
	local dupeInfo = {}

	if self.HaveCore then return end // dupe it by clicking on apple core u dumb

	if IsValid(self.Entity) then
		dupeInfo.EntID = self.Entity:EntIndex()
	end
	if WireAddon then
		dupeInfo.WireData = WireLib.BuildDupeInfo( self.Entity )
	end

	dupeInfo.ScreenTextA = self.ScreenTextA;
	dupeInfo.ScreenTextB = self.ScreenTextB;
	dupeInfo.ScreenTextC = self.ScreenTextC;
	dupeInfo.ScreenTextD = self.ScreenTextD;
	dupeInfo.ScreenTextE = self.ScreenTextE;
	dupeInfo.ScreenTextF = self.ScreenTextF;
	dupeInfo.ScreenTextG = self.ScreenTextG;
	dupeInfo.ScreenTextH = self.ScreenTextH;

	duplicator.StoreEntityModifier(self, "DestConDupeInfo", dupeInfo)
end
duplicator.RegisterEntityModifier( "DestConDupeInfo" , function() end)

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable(Ent:GetClass(),ply)) then self.Entity:Remove(); return end
	local PropLimit = GetConVar("CAP_destcon_max"):GetInt();
	if (IsValid(ply)) then
		if(ply:GetCount("CAP_destcon")+1 > PropLimit) then
			ply:SendLua("GAMEMODE:AddNotify(\"Destiny Console limit reached!\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			self.Entity:Remove();
			return
		end
	end

	if not Ent.EntityMods then 	self.Entity:Remove(); return end

	local dupeInfo = Ent.EntityMods.DestConDupeInfo

	if dupeInfo.EntID then
		self.Entity = CreatedEntities[ dupeInfo.EntID ]
	end

	if(Ent.EntityMods and Ent.EntityMods.DestConDupeInfo.WireData) then
		WireLib.ApplyDupeInfo( ply, Ent, Ent.EntityMods.DestConDupeInfo.WireData, function(id) return CreatedEntities[id] end)
	end

	self.ScreenTextA = dupeInfo.ScreenTextA;
	self.ScreenTextB = dupeInfo.ScreenTextB;
	self.ScreenTextC = dupeInfo.ScreenTextC;
	self.ScreenTextD = dupeInfo.ScreenTextD;
	self.ScreenTextE = dupeInfo.ScreenTextE;
	self.ScreenTextF = dupeInfo.ScreenTextF;
	self.ScreenTextG = dupeInfo.ScreenTextG;
	self.ScreenTextH = dupeInfo.ScreenTextH;

	self.Entity:SetNetworkedString("NameA",dupeInfo.ScreenTextA);
	self.Entity:SetNetworkedString("NameB",dupeInfo.ScreenTextB);
	self.Entity:SetNetworkedString("NameC",dupeInfo.ScreenTextC);
	self.Entity:SetNetworkedString("NameD",dupeInfo.ScreenTextD);
	self.Entity:SetNetworkedString("NameE",dupeInfo.ScreenTextE);
	self.Entity:SetNetworkedString("NameF",dupeInfo.ScreenTextF);
	self.Entity:SetNetworkedString("NameG",dupeInfo.ScreenTextG);
	self.Entity:SetNetworkedString("NameH",dupeInfo.ScreenTextH);

	if (IsValid(ply)) then
		self.Owner = ply;
		ply:AddCount("CAP_destcon", self.Entity)
	end

end