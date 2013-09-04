--[[
	~ Fading Door STool ~
	~ Based on Conna's, but this time it works. ~
	~ Lexi ~
--]]

--[[ Tool Related Settings ]]--

--include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Name = "#Janus Door"
TOOL.Category="Tech";
TOOL.Tab = "CAP";

TOOL.AddToMenu = false; -- Tell gmod not to add it. We will do it manually later!
TOOL.Command=nil;
TOOL.ConfigName="";

TOOL.ClientConVar["key"] = "5"
TOOL.ClientConVar["toggle"] = "0"
TOOL.ClientConVar["reversed"] = "0"

local function checkTrace(tr)
	return (tr.Entity and tr.Entity:IsValid() and not (tr.Entity:IsPlayer() or tr.Entity:IsNPC() or tr.Entity:IsVehicle() or tr.HitWorld));
end

if (CLIENT) then
	usermessage.Hook("FadingDoorHurrah!", function()
		GAMEMODE:AddNotify("Janus Door has been created!", NOTIFY_GENERIC, 10);
		surface.PlaySound ("ambient/water/drip" .. math.random(1, 4) .. ".wav");
	end);
	language.Add("Tool_janus_door_name", "Janus Door");
	language.Add("Tool_janus_door_desc", "Makes anything into a Janus Door");
	language.Add("Tool_janus_door_0", "Click on something to make it a Janus Door.");
	language.Add("Undone_fading_door", "Undone Janus Door");

	function TOOL:BuildCPanel()
		self:AddControl("Header",   {Text = "#Tool_janus_door_name", Description = "#Tool_janus_door_desc"});
		self:AddControl("CheckBox", {Label = "Reversed (Starts invisible, becomes solid)", Command = "janus_door_reversed"});
		self:AddControl("CheckBox", {Label = "Toggle Active", Command = "janus_door_toggle"});
		self:AddControl("Numpad",   {Label = "Button", ButtonSize = "22", Command = "janus_door_key"});
	end

	TOOL.LeftClick = checkTrace;

	return;
end
umsg.PoolString("FadingDoorHurrah!");

local function fadeActivate(self)
	self.fadeActive = true;
	self:SetNotSolid(true)
	local phys = self:GetPhysicsObject();
	if (IsValid(phys)) then
		self.fadeMoveable = phys:IsMoveable();
		phys:EnableMotion(false);
	end
	if (WireLib) then
		Wire_TriggerOutput(self,  "FadeActive",  1);
	end
end

local function fadeDeactivate(self)
	self.fadeActive = false;
	self:SetNotSolid(false);
	local phys = self:GetPhysicsObject();
	if (IsValid(phys)) then
		phys:EnableMotion(self.fadeMoveable or false);
	end
	if (WireLib) then
		Wire_TriggerOutput(self,  "FadeActive",  0);
	end
end

local function fadeToggleActive(self)
	if (self.fadeActive) then
		self:fadeDeactivate();
	else
		self:fadeActivate();
	end
end

local function onUp(ply, ent)
	if (not (ent:IsValid() and ent.fadeToggleActive and not ent.fadeToggle)) then
		return;
	end
	ent:fadeToggleActive();
end
numpad.Register("Fading Doors onUp", onUp);

local function onDown(ply, ent)
	if (not (ent:IsValid() and ent.fadeToggleActive)) then
		return;
	end
	ent:fadeToggleActive();
end
numpad.Register("Fading Doors onDown", onDown);

--Fuck you wire.
local function getWireInputs(ent)
	local inputs = ent.Inputs;
	local names, types, descs = {}, {}, {};
	if (inputs) then
		local num;
		for _, data in pairs(inputs) do
			num = data.Num;
			names[num] = data.Name;
			types[num] = data.Type;
			descs[num] = data.Desc;
		end
	end
	return names, types, descs;
end
local function doWireInputs(ent)
	local inputs = ent.Inputs;
	if (not inputs) then
		Wire_CreateInputs(ent, {"Fade"});
		return;
	end
	local names, types, descs = {}, {}, {};
	local num;
	for _, data in pairs(inputs) do
		num = data.Num;
		names[num] = data.Name;
		types[num] = data.Type;
		descs[num] = data.Desc;
	end
	table.insert(names, "Fade");
	WireLib.AdjustSpecialInputs(ent, names, types, descs);
end

local function doWireOutputs(ent)
	local outputs = ent.Outputs;
	if (not outputs) then
		Wire_CreateOutputs(ent, {"FadeActive"});
		return;
	end
	local names, types, descs = {}, {}, {};
	local num;
	for _, data in pairs(outputs) do
		num = data.Num;
		names[num] = data.Name;
		types[num] = data.Type;
		descs[num] = data.Desc;
	end
	table.insert(names, "FadeActive");
	WireLib.AdjustSpecialOutputs(ent, names, types, descs);
end

local function TriggerInput(self, name, value, ...)
	if (name == "Fade") then
		if (value == 0) then
			if (self.fadePrevWireOn) then
				self.fadePrevWireOn = false;
				if (not self.fadeToggle) then
					self:fadeToggleActive();
				end
			end
		else
			if (not self.fadePrevWireOn) then
				self.fadePrevWireOn = true;
				self:fadeToggleActive();
			end
		end
	elseif (self.fadeTriggerInput) then
		return self:fadeTriggerInput(name, value, ...);
	end
end

local function PreEntityCopy(self)
	local info = WireLib.BuildDupeInfo(self)
	if (info) then
		duplicator.StoreEntityModifier(self, "WireDupeInfo", info);
	end
	if (self.fadePreEntityCopy) then
		self:fadePreEntityCopy();
	end
end

local function PostEntityPaste(self, ply, ent, ents)
	if (self.EntityMods and self.EntityMods.WireDupeInfo) then
		WireLib.ApplyDupeInfo(ply, self, self.EntityMods.WireDupeInfo, function(id) return ents[id]; end);
	end
	if (self.fadePostEntityPaste) then
		self:fadePostEntityPaste(ply, ent, ents);
	end
end


local function onRemove(self)
	numpad.Remove(self.fadeUpNum);
	numpad.Remove(self.fadeDownNum);
end

--Fer Duplicator
local function dooEet(ply, ent, stuff)
	if (ent.isFadingDoor) then
		ent:fadeDeactivate();
		onRemove(ent)
	else
		ent.isFadingDoor = true;
		ent.fadeActivate = fadeActivate;
		ent.fadeDeactivate = fadeDeactivate;
		ent.fadeToggleActive = fadeToggleActive;
		ent:CallOnRemove("Fading Doors", onRemove);
		if (WireLib) then
			doWireInputs(ent);
			doWireOutputs(ent);
			ent.fadeTriggerInput = ent.fadeTriggerInput or ent.TriggerInput;
			ent.TriggerInput = TriggerInput;
			if (not ent.IsWire) then -- Dupe Support
				ent.fadePreEntityCopy = ent.PreEntityCopy;
				ent.PreEntityCopy = PreEntityCopy;
				ent.fadePostEntityPaste = ent.PostEntityPaste;
				ent.PostEntityPaste = PostEntityPaste;
			end
		end
	end
	ent.fadeUpNum = numpad.OnUp(ply, stuff.key, "Fading Doors onUp", ent);
	ent.fadeDownNum = numpad.OnDown(ply, stuff.key, "Fading Doors onDown", ent);
	ent.fadeToggle = stuff.toggle;
	if (stuff.reversed) then
		ent:fadeActivate();
	end
	duplicator.StoreEntityModifier(ent, "Fading Door", stuff);
	return true;
end

duplicator.RegisterEntityModifier("Fading Door", dooEet);

if (not FadingDoor) then
	local function legacy(ply, ent, data)
		return dooEet(ply, ent, {
			key      = data.Key;
			toggle   = data.Toggle;
			reversed = data.Inverse;
		});
	end
	duplicator.RegisterEntityModifier("FadingDoor", legacy);
end

local function doUndo(undoData, ent)
	if (IsValid(ent)) then
		onRemove(ent);
		ent:fadeDeactivate();
		ent.isFadingDoor = false;
		if (WireLib) then
			ent.TriggerInput = ent.fadeTriggerInput;
			if (ent.Inputs) then
				Wire_Link_Clear(ent, "Fade");
				ent.Inputs['Fade'] = nil;
				WireLib._SetInputs(ent);
			end if (ent.Outputs) then
				local port = ent.Outputs['FadeActive']
				if (port) then
					for i,inp in ipairs(port.Connected) do -- From WireLib.lua: -- fix by Syranide: unlinks wires of removed outputs
						if (inp.Entity:IsValid()) then
							Wire_Link_Clear(inp.Entity, inp.Name)
						end
					end
				end
				ent.Outputs['FadeActive'] = nil;
				WireLib._SetOutputs(ent);
			end
		end
	end
end

function TOOL:LeftClick(tr)
	if (not checkTrace(tr)) then
		return false;
	end
	local ent = tr.Entity;
	local ply = self:GetOwner();
	dooEet(ply, ent, {
		key      = self:GetClientNumber("key");
		toggle   = self:GetClientNumber("toggle") == 1;
		reversed = self:GetClientNumber("reversed") == 1;
	});
	undo.Create("fading_door");
		undo.AddFunction(doUndo, ent);
		undo.SetPlayer(ply);
	undo.Finish();

	SendUserMessage("FadingDoorHurrah!", ply);
	return true
end

--TOOL:Register();