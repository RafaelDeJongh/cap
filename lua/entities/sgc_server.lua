/* Copyright (C) 2016 by glebqip */
if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "SGC Computer server"
ENT.Author = "glebqip / AlexALX"
ENT.Category = "Stargate Carter Addon Pack"

--list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.Spawnable = false
ENT.AdminSpawnable = false

properties.Add( "SGCScreen.CodeMenu",
{
	MenuLabel	=	SGLanguage.GetMessage("stool_sgcscreen_menu"),
	Order		=	-10,
	MenuIcon	=	"icon16/page_key.png",

	Filter		=	function( self, ent, ply )
						if ( !IsValid( ent ) || !IsValid( ply ) || ent:GetClass()!="sgc_server" || ent:GetNWBool("GateSpawnerProtected",false) || ent:GetNWBool("DisMenu",false) || ply!=ent:GetNWEntity("Owner")) then return false end
						if ( !gamemode.Call( "CanProperty", ply, "sgcscreenmodify", ent ) ) then return false end
						return true

					end,

	Action		=	function( self, ent )

						self:MsgStart()
							net.WriteEntity( ent )
						self:MsgEnd()

					end,

	Receive		=	function( self, length, player )

						local ent = net.ReadEntity()
						if ( !self:Filter( ent, player ) ) then return false end

						ent:InitCodes(player,true)
					end

});

if SERVER then

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
AddCSLuaFile();

ENT.ServerVer = 1

ENT.ValidGates = {
	["stargate_sg1"]=true,
	["stargate_infinity"]=true,
	["stargate_movie"]=true,
}

util.AddNetworkString("SGCScreen");

function ENT:Initialize()
	self.LockedGate = false
	self:SetModel("models/props_lab/harddrive02.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(ONOFF_USE)

	self.DialingAddress = ""
	self.DCError = 0
	self.On = false
	self.AutoConn = 0

	self.AddressCheck = CurTime()-7
	self.Addresses = {}

	self.StartTimer = false
	self.StartState = 0
    /*
	self.SelfDestructCodes = {
		{"12345678","Test1"},
		{"98765432","Test2"},
	}
	self.SelfDestructResetCodes = {
		{"12345678","Test1"},
		{"98765432","Test2"},
	}*/
	
    self:CreateWireInputs("Power","Reset","Disable Use")
    self:CreateWireOutputs("On","Self-destruct")
	
	self.SelfDestructCodes = {}
	self.SelfDestructResetCodes = {}
	self.RequireTwoPlayers = true
	
	self.LockedGate = NULL
	self.IDCReceiver = NULL
	self.Bomb = NULL
	
	self.SelfDestructClients = {}
	self.SelfDestruct = false
	self.SelfDestructTimer = CurTime()
	self.Iris = false
	--[[
	self.TeleEnts = {}
	self.Teleported = {}
	self.TeleportedT = {}
]]
	self.OldTime = CurTime()
end
/*
hook.Remove("StarGate.Teleport", "SGC_Computer_v1",function(ent,gate,test,blk)
	if gate:GetClass() == "event_horizon" then gate = gate:GetParent() end
	for k,v in pairs(ents.FindByClass("sgc_server")) do
		if gate == self.LockedGate then
			--table.insert(self.Teleported,ent)
		end
	end
end)   */

function ENT:InitCodes(ply,menu)
	if IsValid(ply) then
		net.Start("SGCScreen")
		net.WriteEntity(self)
		net.WriteBit(menu or false)
		if (menu) then
			net.WriteTable({
				["codes"] = self.SelfDestructCodes,
				["reset_codes"] = self.SelfDestructResetCodes,
				["two_players"] = self.RequireTwoPlayers and 1 or 0,
			})
		end
		net.Send(ply)
	end
end

net.Receive( "SGCScreen", function( len, ply )
	local ent = net.ReadEntity()
	if not IsValid(ent) or ply!=ent.Owner then return end
	local tbl = net.ReadTable()
	ent.SelfDestructCodes = tbl.codes or {}
	ent.SelfDestructResetCodes = tbl.reset_codes or {}
	ent.RequireTwoPlayers = util.tobool(tbl.two_players)
end)                              

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end

	local ang = ply:GetAimVector():Angle()
	ang.p,ang.r = 0,0
	ang.y = (ang.y+180)%360

	local ent = ents.Create("sgc_server")
	ent:SetAngles(ang)
	ent:SetPos(tr.HitPos+Vector(0, 0, 20))
	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

local stargate_group_system = GetConVar("stargate_group_system")
--No, builtin functions are total crap of tables and repeates
function ENT:GetFineAddress(gate,ogate)
	local ogate = ogate or self.LockedGate

	local grouped = stargate_group_system:GetBool()
	local address = gate.GateAddress
	if #address == 0 then return "" end

	local range = (ogate:GetPos() - gate:GetPos()):Length();
	local c_range = ogate:GetNetworkedInt("SGU_FIND_RANDE");
	if grouped then
		local group = gate.GateGroup
		local mgroup = ogate.GateGroup
		if (mgroup != group and (not gate.IsUniverseGate or not ogate.IsUniverseGate) or c_range > 0 and range>c_range and #mgroup==3) then
			if (#group == #mgroup and #group >= 2) then
				address = address..group:sub(1,1)
			else
				address = address..group
			end
		end
		if (#group==2 and #mgroup==3) then
			address = address.."#";
		end
	else
		if (gate:GetClass() == "stargate_universe" and ogate:GetClass() ~= "stargate_universe") or	(gate:GetClass() ~= "stargate_universe" and ogate:GetClass() == "stargate_universe") then
			 address = address.."@!";
		elseif gate:GetClass() == "stargate_atlantis" and ogate:GetClass() == "stargate_atlantis" and #address == 7 and ogate:GetGalaxy() and gate:GetGalaxy() then
		elseif #address == 7 and ogate:GetGalaxy() and gate:GetGalaxy() and ((gate:GetClass() ~= "stargate_atlantis" and ogate:GetClass() ~= "stargate_atlantis") and (gate:GetClass() ~= "stargate_universe" and ogate:GetClass() ~= "stargate_universe")) then
		elseif gate:GetGalaxy() or ogate:GetGalaxy() or gate.IsUniverseGate and ogate.IsUniverseGate and c_range > 0 and range>c_range then
			 address = address.."@";
		end
	end
	return address
end

--This function is fine copy of stargate:WireGetAddresses()
function ENT:FindFineGates(gate)
	local gate = gate or self.LockedGate
	if not gate.IsStargate then return end --If our gate is supergate - do some	it
	local supergate = not gate.IsGroupStargate
	local grouped = stargate_group_system:GetBool()

	local gates = {}
	local gaddress = gate.GateAddress or ""
	local glocale = grouped and gate.GateLocal
	local ggroup = grouped and gate.GateGroup or ""
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		local address = v.GateAddress or ""
		if supergate then
			if #address ~= 0 and v ~= gate and not v.IsGroupStargate and not v.GatePrivat then table.insert(gates,v) end --it's good supergate!
			continue
		end
		local group = grouped and v.GateGroup or "";
		local locale = v.GateLocal;
		if #address == 0 or #group == 0 and grouped then	continue end --if target gate is not setup - ignore it
		if address == gaddress and group == ggroup then continue end --remove self and gate-duplicates
		if grouped then
			--Check, if our gate a priate, local and not in our group
			if v.GatePrivat or (glocale or locale) and (ggroup ~= group and not (gate.IsUniverseGate and v.IsUniverseGate and #group == 3)) then continue end

			local range = (gate:GetPos() - v:GetPos()):Length()
			local c_range = gate:GetNWInt("SGU_FIND_RANDE",-1)
			--remove distant local SGU gates
			if (gate.GateLocal or v.GateLocal) and v.IsUniverseGate and gate.IsUniverseGate and (c_range < range) then continue end
			table.insert(gates,v)
		else
			local address = v.GateAddress
			local locale = v.GateLocal;
			if v.GatePrivat or not v.IsGroupStargate then continue end
			table.insert(gates,v) --insert all nonprivat gates
		end
	end

	return gates
end

function ENT:FindNearestClass(class,pos,dist)
	dist = dist or 2000;
	local ents = ents.FindByClass(class)
	local fent,ldist = nil,dist
	for k,v in pairs(ents) do
		local e_pos = v:GetPos();
		if ((e_pos - pos):Length()<=dist) then
			local dist = (e_pos - pos):Length();
			if (dist<ldist) then
				fent = v
				ldist = dist
			end
		end                                  
	end
	return fent
end

function ENT:FindNearestGate(pos,dist)
	dist = dist or 2000;
	local ents = ents.FindInSphere(pos,dist)
	local gate,ldist = nil,dist
	for k,v in pairs(ents) do
		if (v.IsGroupStargate and self.ValidGates[v:GetClass()]) then
			local e_pos = v:GetPos();
			local dist = (e_pos - pos):Length();
			if (dist<ldist) then
				gate = v
				ldist = dist
			end
		end
	end
	return gate
end

function ENT:AutoConnect()

	if(self.FindGate and not IsValid(self.LockedGate)) then
		local gate = self:FindNearestGate(self:GetPos())
		if (IsValid(gate)) then
			self.LockedGate = gate
			self.LockedGate:TriggerInput("SGC Type",1)
			self:SetNW2Entity("Gate",gate)
			gate.SGCScreen = self
		end
	end
	
	if(self.FindIDC and not IsValid(self.IDCReceiver)) then
		local fent = self:FindNearestClass("iris_computer",self:GetPos())
		if (IsValid(fent)) then
			self.IDCReceiver = fent
			self.IDCReceiver.ManualOpen = true
			fent.SGCScreen = self
		end
	end
	
	if(self.FindBomb and not IsValid(self.Bomb)) then
		local fent = self:FindNearestClass("naquadah_bomb",self:GetPos())
		if (IsValid(fent)) then
			self.Bomb = fent
			fent.SGCScreen = self
		end
	end
	
	self.AutoConn = CurTime()+2

end

function ENT:Think()
	--for i=1,#self.Teleported do
		--self:SetNW2Bool("Tele"..i,true)
		--if not self.TeleportedT[i] then self.TeleportedT = CurTime() end
	--end
	if self.OffTimer and CurTime()-self.OffTimer > 0.8 then
		self.On = false
		self.OffTimer = nil
		self:SetWire("On",self.On)
		--self.OffSound:Play()
	end
	self:SetNW2Bool("On",self.On)
	
	if self.AutoConn<=CurTime() then
		self:AutoConnect()
	end

	--Start emulation
	if self.On and self.State ~= -1 then
		local time = CurTime() - self.StartTimer
		if self.State > 0 and math.random() > 0.95 then self:EmitSound("glebqip/hdd_"..math.random(1,6)..".wav",55,100,0.3) end
		if time > 2 and self.State == 0 then self.State = -2 end
		if time > 3 and self.State == -2 then
			self:EmitSound("glebqip/computer_beep.wav",55)
			self.State = 1
		end
		if time > 4 and self.State == 1 then self.State = 2 end
		if time > 7 and self.State == 2 then self.State = 3 end
		if time > 7.3 and self.State == 3 then self.State = 4 end
		if time > 11 and self.State == 4 then self.State = 5 end
		if time > 15 and self.State == 5 then self.State = 6 end
		if time > 17 and self.State == 6 then
			self.State = -1
			self.Iris = false
		end
	end
	self:SetNW2Int("LoadState",self.State)
	local gate = self.LockedGate
	if (IsValid(gate)) and self.On and self.State == -1 then
		if CurTime()-self.AddressCheck > 10 then

			self.Gates = self:FindFineGates()
			self.AddressCheck = CurTime()
			self:SetNW2Int("AddressCount",#self.Gates)
			local pos = self:GetPos()
			local xmin,xmax,ymin,ymax = pos.x,pos.x,pos.y,pos.y
			for _,gate in ipairs(self.Gates) do --First iteration for find bounding box of all gates
				local pos = gate:GetPos()
				if not xmin or xmin > pos.x then xmin = pos.x end
				if not xmax or xmax < pos.x then xmax = pos.x end
				if not ymin or ymin > pos.y then ymin = pos.y end
				if not ymax or ymax < pos.y then ymax = pos.y end
			end
			local addr = self:GetFineAddress(gate)
			if #addr < 9 and not addr:find("#") then addr = addr.."#" end
			self:SetNW2String("AddressName0",gate.GateName ~= "" and gate.GateName or "N/A")
			self:SetNW2String("Address0",addr)
			self:SetNW2Float("AddressX0",(pos.x-xmin)/(xmax-ymin))
			self:SetNW2Float("AddressY0",(pos.y-ymin)/(ymax-ymin))
			for i,gate in ipairs(self.Gates) do
				local addr = self:GetFineAddress(gate)
				if #addr < 9 and not addr:find("#") then addr = addr.."#" end
				self:SetNW2String("Address"..i,addr)
				self:SetNW2String("AddressName"..i,gate.GateName ~= "" and gate.GateName or "N/A")
				self:SetNW2Bool("AddressBlocked"..i,gate:GetBlocked())
				self:SetNW2Int("AddressDistance"..i,gate:GetPos():Distance(self.LockedGate:GetPos()))
				self:SetNW2Int("AddressGalaxy"..i,gate.GateGroup)
				if gate.IsUniverseGate then
					self:SetNW2Int("AddressType"..i,6)
				elseif gate:GetClass() == "stargate_tollan" then
					self:SetNW2Int("AddressType"..i,5)
				elseif gate:GetClass() == "stargate_atlantis" then
					self:SetNW2Int("AddressType"..i,4)
				elseif gate:GetClass() == "stargate_infinity" then
					self:SetNW2Int("AddressType"..i,3)
				elseif gate:GetClass() == "stargate_movie" then
					self:SetNW2Int("AddressType"..i,2)
				else
					self:SetNW2Int("AddressType"..i,1)
				end
				local pos = gate:GetPos()
				self:SetNW2Int("AddressCRC"..i,util.CRC(addr))
				self:SetNW2Float("AddressX"..i,(pos.x-xmin)/(xmax-ymin))
				self:SetNW2Float("AddressY"..i,(pos.y-ymin)/(ymax-ymin))
				--print(self:FindGateBuAddress(addr))
				--local address = string.Explode("",addr);table.insert(address,"DIAL");
				--print(gate:FindGate(true,address))
				--self:SetNW2Int("AddressX"..i,)
			end
		end

		local enter = 0
		local need = 2
		if not self.RequireTwoPlayers or not self.SelfDestruct and table.Count(self.SelfDestructCodes)==1 or self.SelfDestruct and table.Count(self.SelfDestructResetCodes)==1 then need = 1 end
		for ent in pairs(self.SelfDestructClients) do
			if not IsValid(ent) or ent.Server ~= self or ent:GetNW2Int("SDState",0) == 0 and not self.SelfDestruct or ent:GetNW2Int("SDRState",0) == 0 and self.SelfDestruct then
				self.SelfDestructClients[ent] = nil
			else
				if self.SelfDestruct or ent:IsHoldDKey() then
					enter = enter + 1
				end
			end
		end
		if enter == need and not self.SelfDestruct then
			if IsValid(self.Bomb) then
				self.Bomb:StartDetonation(self.Bomb.detonationCode)
			end
			self.SelfDestruct = true
			self.SelfDestructTimer = CurTime()+120+3
			self:SetWire("Self-destruct",1)
		elseif enter == need and self.SelfDestruct then
			if IsValid(self.Bomb) then self.Bomb:AbortDetonation(self.Bomb.abortCode) end
			self.SelfDestruct = false
			self.SelfDestructTimer = CurTime()
			self:SetWire("Self-destruct",0)
		end
		self:SetNW2Bool("SelfDestruct",self.SelfDestruct)
		self:SetNW2Int("SDTimer",IsValid(self.Bomb) and self.Bomb:GetNWInt("BombOverlayTime",0) or 0)
		if math.random() > 0.99 then
			self:EmitSound("glebqip/hdd_"..math.random(1,6)..".wav",55,100,0.3)
		end
		local active = gate.NewActive
		local open = gate.IsOpen
		local inbound = gate.Active and not gate.Outbound
		local ringrot = gate:GetWire("Ring Rotation", 0, true) ~= 0
		local locked = gate:GetWire("Chevron Locked", 0, true)> 0
		local chevron = gate:GetWire("Chevron", 0, true)
		local dialsymb = gate:GetWire("Dialing Symbol", "", true)
		local dialdsymb = gate:GetWire("Dialed Symbol", "", true)
		local ringsymb = gate:GetWire("Ring Symbol", "", true)
		local dialadd = gate:GetWire("Dialing Address", "", true)

		local targeraddr = gate.DialledAddress
		local arrrsize = #gate.DialledAddress-1
		--Some shit hack
		local last = targeraddr[arrrsize]
		local LastChev = dialsymb == last or dialdsymb == last or self.LastDialSymb == last
		if LastChev and dialsymb == "" and not ringrot and chevron ~= 0 and not locked then
			locked = 1
		end
		-- print(gate.Chevron[7])
		--print(gate.ScrAddress)
		self:SetNW2Int("RingAngle", gate:GetRingAng())
		self:SetNW2Bool("Active", active)
		self:SetNW2Bool("Open", open)
		self:SetNW2Bool("Inbound", inbound)
		--print(gate:GetNW2Bool("ActChevronsL"))
		self:SetNW2Bool("RingRotation", ringrot)
		self:SetNW2Bool("RingDir", gate:GetWire("Ring Rotation", 0, true) == 1)
		self:SetNW2Bool("ChevronLocked", locked)
		self:SetNW2Int("Chevron", chevron)
		self:SetNW2String("Chevrons", gate:GetWire("Chevrons", "", true))
		--self:SetNW2String("DialingAddress", gate:GetWire("Dialing Address", "", true))
		self:SetNW2String("DialingSymbol", dialsymb)
		self:SetNW2String("DialedSymbol", dialdsymb)
		self:SetNW2String("RingSymbol", ringsymb)
		self:SetNW2Bool("Local",gate.GateLocal)
		self:SetNW2Bool("Fast",gate.DialType.Fast)
		self:SetNW2Bool("HaveEnergy",gate:CheckEnergy(true,true))

		--Add trigger to error
		if not inbound and not open and (active or chevron > 0) and LastChev then
			self.DialErr = true
			if locked == true then
				self.LockErr = true
			end
			if not gate:HaveEnergy() then
				self.EnerEerr = true
			end
			if dialsymb ~= "" then
				self.LastDialSymb = dialsymb
			end
			if locked then
				self.ErrorSymb = last
			end
		elseif (self.DialErr or self.LockErr) then
			if not open and not inbound and chevron <= 0 and #self.DialingAddress >= 6 then -- we fail dial
				self.DCError = self.EnerEerr and 5 or self.LockErr and 2 or 1
				self.DCErrorTimer = CurTime()

				if self.ErrorSymb then
					if self.DialingAddress[#self.DialingAddress] == self.LastDialSymb then
						self.DialingAddress = self.DialingAddress:sub(1,-2)
					end
					self.ErrorAnim = true
				else
					self.ErrorAnim = false
				end
			end
			self.DialErr = false
			self.LockErr = false
			self.EnerEerr = false
		end
		--print(gate.Shutingdown)
		--Dial error check
		if chevron == 0 and self.ErrorSymb and self.DCError == 0 then --Reset err symbol if we don't need it
			self.ErrorSymb = nil
		end
		if self.DCError ~= 0 and CurTime()-self.DCErrorTimer > 10 or active and chevron >= 0 then
			self.DCError = 0
		end

		local movie = self.LockedGate:GetClass() == "stargate_movie"
		self:SetNW2Bool("IsMovie",movie)
		--Symbol animation triggers
		local LastSecond = not open and LastChev and locked
		local FirstRight = targeraddr[chevron+1] == ringsymb and (not ringrot or LastChev)
		local SecondRight = (targeraddr[chevron] == dialsymb and not LastChev) or locked
		if movie then
			FirstRight = targeraddr[chevron+1] == ringsymb
		end

		if active and not open and SecondRight and self.SymbolAnim and not self.SymbolAnim2 and (not self.SA2Timer and not movie or LastSecond or self.SA2Timer and CurTime()-self.SA2Timer > 0.9) then
			self.SA2Timer = nil
	--if active and not open and SecondRight and self.SymbolAnim and not self.SymbolAnim2 then
			self.SymbolAnim2 = true
			self.SymbolAnim = false
		elseif active and not open and SecondRight and self.SymbolAnim and not self.SymbolAnim2 and not self.SA2Timer then
			self.SA2Timer = CurTime()
		elseif active and not open and FirstRight and not self.SymbolAnim and not self.SymbolAnim2 then
			self.SymbolAnim = true
		elseif (not active or open or inbound or not FirstRight and not SecondRight) and (self.SymbolAnim or self.SymbolAnim2) then
			self.SymbolAnim2 = false
			self.SymbolAnim = false
		end
		if not self.SymbolAnim and not self.SymbolAnim2 and self.DCError == 0 then
			self.DialingAddress = dialadd
			local smadd = ""
			if active and not open and locked then
				if dialsymb ~= "" then
					smadd = dialsymb
				elseif dialdsymb ~= "" and not open and not gate.DialType.Fast then
					smadd = dialdsymb
				elseif self.LastDialSymb ~= self.DialingAddress[#self.DialingAddress] then
					smadd = self.LastDialSymb or ""
				end
				self.DialingAddress = self.DialingAddress..smadd
			end
		end

		self:SetNW2Bool("LastChev",LastChev)
		self:SetNW2Bool("ChevronFirst",self.SymbolAnim)
		self:SetNW2Int("DCError",self.DCError*(self.ErrorAnim and -1 or 1))
		self:SetNW2Int("DCErrorSymbol",self.ErrorSymb or self.LastDialSymb)
		self:SetNW2Bool("ChevronSecond",self.SymbolAnim2)
		self:SetNW2String("DialingAddress",self.DialingAddress)
		local dadddelta = LastSecond and (dialsymb ~= "" and dialsymb or dialdsymb ~= "" and dialdsymb or self.LastDialSymb) or ""
		if #self.DialingAddress < #dialadd then
			dadddelta = dialadd:sub(#self.DialingAddress+1,#dialadd)
		end
		if movie and self.SymbolAnim2 and not LastSecond then dadddelta = dadddelta..dialdsymb end
		self:SetNW2String("DialingAddress",self.DialingAddress)
		self:SetNW2String("DialingAddressDelta",dadddelta)
		if self.Inbound ~= inbound then
				self.Iris = inbound
				self.Inbound = inbound
			end
		--GDO scripts
		if inbound and IsValid(self.IDCReceiver)/* and self.IDCReceiver.LockedGate ~= self.IDCReceiver.Entity*/ then
			local code = self.IDCReceiver.wireCode
			if (self.IDCReceiver!=self.LastIDC) then
				self.LastIDC = self.IDCReceiver
				self.IDCReceiver.GDOStatus = 3
				self.IDCReceiver.GDOText = "CODE CHECK"
			end
			if self.IDCCode == 0 and code ~= self.IDCCode then
				self.IDCCode = code
				self.IDCReceivedCode = code ~= 0 and tostring(code) or self.IDCReceivedCode
				if code ~= 0 then
					self.IDCState = 1
					self.IDCTimer = CurTime()+0.8
					local desc = self.IDCReceiver.wireDesc
					if not self.IDCReceiver.Codes[code] then
						self.IDCCodeState = 2
					elseif desc[1] == "!" then
						self.IDCCodeState = 1
						self.IDCName = desc:sub(2,-1)
					else
						self.IDCCodeState = 0
						self.IDCName = desc
					end
				end
			end
			if self.IDCState == 1 and CurTime()>self.IDCTimer then
				self.IDCState = 2
				self.IDCTimer = CurTime()+2.2
			end
			if self.IDCState == 2 and CurTime()>self.IDCTimer then
				self.IDCState = 3
				self.IDCShowState = 0
				self.IDCTimer = CurTime()
				self.LinesTimer = CurTime()-0.1
			end
			if self.IDCState == 3 and CurTime()-self.IDCTimer > #self.IDCReceivedCode*0.1+0.1 then
				self.IDCState = 4
				self.IDCTimer = CurTime()+5
				if self.IDCCodeState == 0 then
					self.IDCReceiver.GDOText = "ACCEPT"
				elseif self.IDCCodeState == 1 then
					self.IDCReceiver.GDOText = "EXPIRED"
				else
					self.IDCReceiver.GDOText = "UNKNOWN"
				end
				self.Iris = self.Iris and self.IDCCodeState ~= 0
				if self.IDCCodeState==0 then
					if self.IDCReceiver.donotautoopen and gate:IsBlocked(1,1) then
						self.IDCReceiver.GDOText = "STAND-BY";
						self.IDCTimer = CurTime()+0.5
					else
						self.IDCReceiver.GDOStatus = -1
						self.IDCReceiver:TriggerInput("Iris Control",0)
					end
				else
					self.IDCReceiver.GDOStatus = -1
				end
			end
			if self.IDCState == 4 and CurTime()>self.IDCTimer then
				if self.IDCReceiver.GDOText=="STAND-BY" then
					if gate:IsBlocked(1,1) then
						self.IDCTimer = CurTime()+0.5
						allow = false
					else
						self.IDCTimer = CurTime()+5
						self.IDCReceiver.GDOStatus = -1
						self.IDCReceiver.GDOText = "OPEN"
					end
				else    
					self.IDCState = 6
					self.IDCCode = 0
					self.IDCReceivedCode = ""
					self.IDCCodeState = 0
					self.IDCReceiver.GDOStatus = 3
					self.IDCReceiver.GDOText = "CODE CHECK"
				end
			end			
		else
			self.IDCState = 0
			if IsValid(self.IDCReceiver) then
				self.IDCReceiver.GDOStatus = 3
				self.IDCReceiver.GDOText = "CODE CHECK"
			end
			self.IDCCode = 0
		end
		self:SetNW2Int("IDCShowState",self.IDCShowState)
		self:SetNW2Int("IDCState",self.IDCState)
		self:SetNW2String("IDCCode",self.IDCReceivedCode)
		self:SetNW2String("IDCName",self.IDCName)
		self:SetNW2Int("IDCCodeState",self.IDCCodeState)
		--self.DirBuffer = {}
		--self:SetNWString("SGAddress", gate:GetWire("Dialing Address", "", true))
		--[[
		local event = self.LockedGate.EventHorizon
		local buff = event.Buffer
		if buff then
			local changed = false
			for k,v in pairs(self.TeleEnts) do
				if not buff[v:EntIndex()] or not IsValid(v) then
					table.remove(self.TeleEnts,k)
					changed = true
				end
			end
			for k,v in pairs(self.LockedGate.EventHorizon.Buffer) do
				if not IsValid(v) then continue end
				local find = false
				for k,e in pairs(self.TeleEnts) do
					if e == v then
						find = true
						break
					end
				end
				if not find then
					table.insert(self.TeleEnts,v)
					changed = true
				end
				--print(self.LockedGate.EventHorizon.Buffer[v:EntIndex()])
			end
			if changed then
				self:SetNW2Int("DecCount",#self.TeleEnts)
				for k,v in pairs(self.TeleEnts) do
					self:SetNW2String("DecEnt"..k,v:GetClass())
					self:SetNW2String("DecModel"..k,v:GetModel())
				end
			end
		else
			self:SetNW2Int("DecCount",0)
		end
		]]
	else
		self.Iris = true
	end
	/*
	if IsValid(self.IDCReceiver) and IsValid(self.IDCReceiver.LockedIris) and self.IDCReceiver.LockedIris.Toggle and self.IDCReceiver.LockedIris.IsActivated ~= self.Iris then
		self.IDCReceiver.LockedIris:Toggle()
	end*/
	self:SetNW2Bool("Connected", IsValid(gate))

	self.DeltaTime = CurTime()-self.OldTime
	self.OldTime = CurTime()
	self:NextThink(CurTime()+0.075)
	return true
end

function ENT:ToggleIris()
	if IsValid(self.LockedGate) then
		self.Iris = self.LockedGate:IrisToggle()
	end
end

function ENT:TriggerInput(key, value)
  if (key=="Power") then
    if (value>0) then
		if (self.On) then
			self.On = false
			self.OffTimer = nil
		else
			self.On = true
			self.StartTimer = CurTime()
			self.State = 0
		end
		self:SetWire("On",self.On)
	end
  elseif(key=="Reset" and value > 0) then
	self.StartTimer = CurTime()
	self.State = 0
  elseif(key=="Disable Use") then
    self.DisableUse = util.tobool(value)
  end
end

function ENT:Dial(addr)
	if not IsValid(self.LockedGate) then return end
	self.LockedGate.DialledAddress = {}
	for i=1,#addr do
		table.insert(self.LockedGate.DialledAddress,addr[i]);
	end
	table.insert(self.LockedGate.DialledAddress,"DIAL")
	self.LockedGate:SetDialMode(false,false)
	self.LockedGate:StartDialling()
end

function ENT:Touch(ent)
	if not IsValid(self.LockedGate) and (ent.IsGroupStargate) and not IsValid(ent.SGCServer) and self.ValidGates[ent:GetClass()] then
		self.LockedGate = ent
		self.LockedGate:TriggerInput("SGC Type",1)
		ent.SGCServer = self
		self:SetNW2Entity("Gate",ent)
		local ed = EffectData()
		ed:SetEntity(self)
		util.Effect("propspawn", ed, true, true)
	elseif not IsValid(self.IDCReceiver) and (ent.GDOStatus) and not IsValid(ent.SGCServer) then
		self.IDCReceiver = ent
		ent.SGCServer = self
		ent.ManualOpen = true
		local ed = EffectData()
		ed:SetEntity(self)
		util.Effect("propspawn", ed, true, true)
	elseif not IsValid(self.Bomb) and ent:GetClass() == "naquadah_bomb" and not IsValid(ent.SGCServer) then
		self.Bomb = ent
		ent.SGCServer = self
		local ed = EffectData()
		ed:SetEntity(self)
		util.Effect("propspawn", ed, true, true)
	end
end

function ENT:OnRemove()
	if (IsValid(self.LockedGate)) then
		self.LockedGate.SGCServer = nil
	end
	if (IsValid(self.IDCReceiver)) then
		self.IDCReceiver.SGCServer = nil
		self.IDCReceiver.ManualOpen = false
	end
	if (IsValid(self.Bomb)) then
		self.Bomb.SGCServer = nil
	end
end

function ENT:Use(_,_,val)
	if self.DisableUse then return end
	if val > 0 then
		if self.On then
			self.OffTimer = CurTime()
		else
			self.On = true
			self.StartTimer = CurTime()
			self.State = 0
			self:SetWire("On",self.On)
		end
	else
		if self.OffTimer then self.OffTimer = nil end
	end
end

function ENT:PreEntityCopy()
	local dupeInfo = {};

	dupeInfo.SelfDestructCodes = self.SelfDestructCodes;
	dupeInfo.SelfDestructResetCodes = self.SelfDestructResetCodes;
	dupeInfo.RequireTwoPlayers = self.RequireTwoPlayers;

	dupeInfo.FindGate = self.FindGate;
	dupeInfo.FindIDC = self.FindIDC;
	dupeInfo.FindBomb = self.FindBomb;

	dupeInfo.LockedGate = self.LockedGate:EntIndex();
	dupeInfo.IDCReceiver = self.IDCReceiver:EntIndex();
	dupeInfo.Bomb = self.Bomb:EntIndex();
	
    duplicator.StoreEntityModifier(self, "StarGateSGCServerInfo", dupeInfo)
	StarGate.WireRD.PreEntityCopy(self);
end

function ENT:PostEntityPaste(ply, Ent, CreatedEntities)
	if (StarGate.NotSpawnable("sgc_screen",ply,"tool")) then Ent:Remove(); return end

	if (IsValid(ply)) then
		if(ply:GetCount("CAP_sgc_servers")>=GetConVar("sbox_maxsgc_server"):GetInt()) then
			ply:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_sgcscreen_limit_sv\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
			Ent:Remove();
			return
		end
		ply:AddCount("CAP_sgc_servers", Ent);
	end

	local dupeInfo = Ent.EntityMods.StarGateSGCServerInfo

	if (dupeInfo.SelfDestructCodes) then
		self.SelfDestructCodes = dupeInfo.SelfDestructCodes;
	end
	if (dupeInfo.SelfDestructResetCodes) then
		self.SelfDestructResetCodes = dupeInfo.SelfDestructResetCodes;
	end
	if (dupeInfo.RequireTwoPlayers!=nil) then
		self.RequireTwoPlayers = dupeInfo.RequireTwoPlayers;
	end
	
	if (dupeInfo.FindGate) then
		self.FindGate = dupeInfo.FindGate;
	end
	if (dupeInfo.FindIDC) then
		self.FindIDC = dupeInfo.FindIDC;
	end
	if (dupeInfo.FindBomb) then
		self.FindBomb = dupeInfo.FindBomb;
	end
	
	if (dupeInfo.LockedGate and CreatedEntities[dupeInfo.LockedGate]) then
		self.LockedGate = CreatedEntities[dupeInfo.LockedGate];
		self.LockedGate:TriggerInput("SGC Type",1)
		self:SetNW2Entity("Gate",self.LockedGate)
		self.LockedGate.SGCScreen = Ent;
	end
	if (dupeInfo.IDCReceiver and CreatedEntities[dupeInfo.IDCReceiver]) then
		self.IDCReceiver = CreatedEntities[dupeInfo.IDCReceiver];
		self.IDCReceiver.ManualOpen = true
		CreatedEntities[dupeInfo.IDCReceiver].SGCScreen = Ent;
	end
	if (dupeInfo.Bomb and CreatedEntities[dupeInfo.Bomb]) then
		self.Bomb = CreatedEntities[dupeInfo.Bomb];
		CreatedEntities[dupeInfo.Bomb].SGCScreen = Ent;
	end
	
	if (IsValid(ply)) then
		self.Owner = ply;
		self:SetNWEntity("Owner",ply);
	end

	StarGate.WireRD.PostEntityPaste(self,ply,Ent,CreatedEntities)
end

if (StarGate and StarGate.CAP_GmodDuplicator) then
	duplicator.RegisterEntityClass( "sgc_server", StarGate.CAP_GmodDuplicator, "Data" )
end

--[[
--FUNC CHECK--
print("--START CHECK1--")
local test = Entity(94):WireGetAddresses()
local test2 = ENT:FindFineGates(Entity(94))
for k,gate in pairs(test2) do
	print(ENT:GetFineAddress(gate,Entity(94)),test[k][1])
end
print("--START CHECK2--")
for k,gate in pairs(ents.FindByClass("stargate_*")) do
	if not gate.IsStargate then continue end
	local gates1,gates2 = ENT:FindFineGates(gate),gate:WireGetAddresses()
	if gates1 then
		if #gates1 ~= #gates2 then print("!!!",#gates1,#gates2) end
		for k,v in pairs(gates1) do
			local fine = false
			for k1,v1 in pairs(gates2) do
				if v.GateAddress:find(v1[1]:sub(1,#v.GateAddress)) then fine = true break end
			end
			if not fine then print(1,gate.GateAddress,v.GateAddress) end
		end
		for k1,v1 in pairs(gates2) do
			local fine = false
			for k,v in pairs(gates1) do
				if v1[1]:find(v.GateAddress) then fine = true break end
			end
			if not fine then print(2,gate.GateAddress,v1[1]) end
		end
	else print(v,#gates2) end
end
print("--END CHECK--")
]]

else -- CLIENT

if (SGLanguage ~=nil and SGLanguage.GetMessage ~=nil) then
  ENT.Category = SGLanguage.GetMessage("entity_main_cat")
  ENT.PrintName = SGLanguage.GetMessage("sgc_computer")
end

local sprite = Material("sprites/glow04_noz")
function ENT:Draw()
  self:DrawModel()
  render.SetMaterial(sprite)
  if self:GetNW2Bool("On",false) then
    if not self:GetNW2Bool("Connected",false) then
      render.DrawSprite( self:LocalToWorld(Vector(9.9,2.4,0.4)), 3, 3, Color(200,0,0) )
    end
    render.DrawSprite( self:LocalToWorld(Vector(9.9,2.4,-0.4)), 3, 3, Color(0,200,0) )
  end
  return true
end


function ENT:Initialize()
  self.OnSound = CreateSound(self,"glebqip/computer_loop.wav")
  self.OnSound:SetSoundLevel(55)
end

function ENT:Think()
  if self.On then
    self.OnSound:PlayEx(0.6,100)
  end
  if self.On ~= self:GetNW2Bool("On",false) then
    if self.On then
      self.OnSound:Stop()
      self:EmitSound("glebqip/computer_end.wav",55)
    end
      self.On = self:GetNW2Bool("On",false)
  end
end

function ENT:SolveHook(name,old,new)
  if not self.HookBinds[name] then return end
  for id, tbl in pairs(self.HookBinds[name]) do
    if not IsValid(tbl[2]) then
      --print("Removing hook",name,id)
      self.HookBinds[name][id] = nil
      continue
    end
    tbl[1](self,name,old,new)
  end
end

function ENT:BindNW2Hook(ent,hookname, name, func)
  if not self.HookBinds then
    self.HookBinds = {}
    self.HookCleanups = {}
  end
  if not self.HookBinds[hookname] then
    self:SetNWVarProxy(hookname,self.SolveHook)
    self.HookBinds[hookname] = {} --create table with funcs
  end
  self.HookBinds[hookname][name.."."..ent:EntIndex()] = {func,ent}
  --print(ent,hookname)
end

function ENT:OnRemove()
  self.OnSound:Stop()
  self:EmitSound("glebqip/computer_end.wav",55)
end

local function SGC_Codes_Mgr(otbl,ent)
	/*local tbl = presets.GetTable("SGCScreen") -- this shit not work correct at all.
	if (table.Count(tbl)==0) then -- bug, table is empty after reload gmod
		tbl = LoadPresets()
		if (tbl and tbl.sgcscreen) then tbl = tbl.sgcscreen end  
	end*/
	local tbl = otbl
	if not otbl then
		tbl = util.JSONToTable(file.Read("stargate/sgcscreen.txt",gtbl) or "") or {}
	end
	
	local codes = tbl.codes or {};
	local reset_codes = tbl.reset_codes or {};
	local two_players = tbl.two_players or 1;

	local DermaPanel = vgui.Create( "DFrame" )
   	DermaPanel:SetSize(530, 280)
	DermaPanel:Center()
	--DermaPanel:SetTitle( SGLanguage.GetMessage("iriscomp_title") )
	DermaPanel:SetTitle("")
   	DermaPanel:SetVisible( true )
   	DermaPanel:SetDraggable( false )
   	DermaPanel:ShowCloseButton( true )
   	DermaPanel:MakePopup()
	DermaPanel.Paint = function(self,w,h)
        surface.SetDrawColor( 80, 80, 80, 185 )
        surface.DrawRect( 0, 0, w, h )
    end

	local image = vgui.Create("DImage" , DermaPanel);
    image:SetSize(16, 16);
    image:SetPos(5, 5);
    image:SetImage("gui/cap_logo");

  	local title = vgui.Create( "DLabel", DermaPanel );
 	title:SetText(SGLanguage.GetMessage("sgcscreen_title"));
  	title:SetPos( 25, 0 );
 	title:SetSize( 400, 25 );

	local codeLabel = vgui.Create("DLabel" , DermaPanel )
	codeLabel:SetPos(10,185)
	codeLabel:SetText(SGLanguage.GetMessage("sgcscreen_code"))

	local descLabel = vgui.Create("DLabel" , DermaPanel )
	descLabel:SetPos(100,185)
	descLabel:SetText(SGLanguage.GetMessage("sgcscreen_desc"))

	local code = vgui.Create( "DTextEntry" , DermaPanel )
	code:SetPos(10, 205)
	code:SetSize(80, 20)
	code:SetText("")
 	code.OnTextChanged = function(TextEntry)
 		local pos = TextEntry:GetCaretPos();
 		local len = TextEntry:GetValue():len();
		local letters = TextEntry:GetValue():gsub("[^1-9]",""):sub(1,8);
		TextEntry:SetText(letters);
		TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,letters:len())); -- Reset the caretpos!
	end

	local desc = vgui.Create ("DTextEntry" , DermaPanel )
	desc:SetPos(100, 205)
	desc:SetSize(95, 20)
	desc:SetText("")
	desc:SetAllowNonAsciiCharacters(true)

	local addButton = vgui.Create("DButton" , DermaPanel )
    addButton:SetParent( DermaPanel )
    addButton:SetText("")
	addButton:SetImage("icon16/add.png")
    addButton:SetPos(205, 205)
    addButton:SetSize(25, 20)
	addButton.DoClick = function ( btn1 )

		local found = false
		for k,v in pairs(codes) do
			if k == code:GetValue() or v == desc:GetValue() then
				found = true
			end
		end

		if not found and code:GetValue():gsub("[^1-9]","")!="" and desc:GetValue()!="" then
			codes[code:GetValue():gsub("[^1-9]","")] = desc:GetValue()
			updateCodes()
		end

    end

	local remButton = vgui.Create("DButton" , DermaPanel )
    remButton:SetParent( DermaPanel )
    remButton:SetText("")
	remButton:SetImage("icon16/delete.png")
    remButton:SetPos(235, 205)
    remButton:SetSize(25, 20)
	remButton.DoClick = function ( btn2 )

		local found = false
		for k,v in pairs(codes) do
			if k == code:GetValue() or v == desc:GetValue() then
				found = true
				codes[k] = nil
			end
		end

		if found then
			code:SetText("");
			desc:SetText("");
			updateCodes()
		end

    end

	local codeList = vgui.Create( "DListView", DermaPanel )
	codeList:SetPos(10, 30)
	codeList:SetSize(250, 150)
	codeList:AddColumn(SGLanguage.GetMessage("sgcscreen_dcode"))
	codeList:AddColumn(SGLanguage.GetMessage("sgcscreen_desc"))
	codeList:SortByColumn(1, true)

	function updateCodes()
		codeList:Clear()
		for k,v in pairs(codes) do
			codeList:AddLine(k, v)
		end
	end

	updateCodes()

	function codeList:OnRowSelected(id, selected)
		local codeSs = selected:GetColumnText(1)
		local descSs = selected:GetColumnText(2)
		code:SetText(codeSs)
		desc:SetText(descSs)
	end
	
	---------------------------------------------------------------
	
	local codeLabel = vgui.Create("DLabel" , DermaPanel )
	codeLabel:SetPos(270,185)
	codeLabel:SetText(SGLanguage.GetMessage("sgcscreen_code"))

	local descLabel = vgui.Create("DLabel" , DermaPanel )
	descLabel:SetPos(360,185)
	descLabel:SetText(SGLanguage.GetMessage("sgcscreen_desc"))

	local code = vgui.Create( "DTextEntry" , DermaPanel )
	code:SetPos(270, 205)
	code:SetSize(80, 20)
	code:SetText("")
 	code.OnTextChanged = function(TextEntry)
 		local pos = TextEntry:GetCaretPos();
 		local len = TextEntry:GetValue():len();
		local letters = TextEntry:GetValue():gsub("[^1-9]",""):sub(1,8);
		TextEntry:SetText(letters);
		TextEntry:SetCaretPos(math.Clamp(pos - (len-#letters),0,letters:len())); -- Reset the caretpos!
	end

	local desc = vgui.Create ("DTextEntry" , DermaPanel )
	desc:SetPos(360, 205)
	desc:SetSize(100, 20)
	desc:SetText("")
	desc:SetAllowNonAsciiCharacters(true)

	local addButton = vgui.Create("DButton" , DermaPanel )
    addButton:SetParent( DermaPanel )
    addButton:SetText("")
	addButton:SetImage("icon16/add.png")
    addButton:SetPos(470, 205)
    addButton:SetSize(25, 20)
	addButton.DoClick = function ( btn1 )

		local found = false
		for k,v in pairs(reset_codes) do
			if k == code:GetValue() or v == desc:GetValue() then
				found = true
			end
		end

		if not found and code:GetValue():gsub("[^1-9]","")!="" and desc:GetValue()!="" then
			reset_codes[code:GetValue():gsub("[^1-9]","")] = desc:GetValue()
			updateResetCodes()
		end

    end
	local addButton2 = addButton

	local remButton = vgui.Create("DButton" , DermaPanel )
    remButton:SetParent( DermaPanel )
    remButton:SetText("")
	remButton:SetImage("icon16/delete.png")
    remButton:SetPos(500, 205)
    remButton:SetSize(25, 20)
	remButton.DoClick = function ( btn2 )

		local found = false
		for k,v in pairs(reset_codes) do
			if k == code:GetValue() or v == desc:GetValue() then
				found = true
				reset_codes[k] = nil
			end
		end

		if found then
			code:SetText("");
			desc:SetText("");
			updateResetCodes()
		end

    end

	local codeList = vgui.Create( "DListView", DermaPanel )
	codeList:SetPos(270, 30)
	codeList:SetSize(250, 150)
	codeList:AddColumn(SGLanguage.GetMessage("sgcscreen_rcode"))
	codeList:AddColumn(SGLanguage.GetMessage("sgcscreen_desc"))
	codeList:SortByColumn(1, true)

	function updateResetCodes()
		codeList:Clear()
		for k,v in pairs(reset_codes) do
			codeList:AddLine(k, v)
		end
	end

	updateResetCodes()
	
	function codeList:OnRowSelected(id, selected)
		local codeSs = selected:GetColumnText(1)
		local descSs = selected:GetColumnText(2)
		code:SetText(codeSs)
		desc:SetText(descSs)
	end

	local saveClose = vgui.Create("DButton" , DermaPanel )
    saveClose:SetParent( DermaPanel )
    saveClose:SetText(SGLanguage.GetMessage("sgcscreen_save"))
    saveClose:SetPos(410, 240)
    saveClose:SetSize(110, 25)
	saveClose.DoClick = function ( btn3 )
		saveCodes()
		DermaPanel:Close()
    end
	saveClose:SetImage("icon16/disk.png")

	local cancelButton = vgui.Create("DButton" , DermaPanel )
    cancelButton:SetParent( DermaPanel )
    cancelButton:SetText(SGLanguage.GetMessage("sgcscreen_cancel"))
    cancelButton:SetPos(10, 240)
    cancelButton:SetSize(110, 25)
	cancelButton.DoClick = function ( btn4 )
		DermaPanel:Close()
    end
	cancelButton:SetImage("icon16/database_delete.png")

	local descLabel = vgui.Create("DCheckBoxLabel" , DermaPanel )
	--descLabel:SetPos(140,240)
	descLabel:SetText(SGLanguage.GetMessage("sgcscreen_info"))
	descLabel:SizeToContents()
	descLabel:SetChecked(two_players)
	local x,y = descLabel:GetSize()
	descLabel:SetPos(130,253-(y/2))
	descLabel.OnChange = function(self, val)
		two_players = val and 1 or 0
	end
	
	function saveCodes()
		addButton:DoClick()
		addButton2:DoClick()
		local stbl = {
			["codes"] = codes,
			["reset_codes"] = reset_codes,
			["two_players"] = two_players,
		}
		if otbl then
			net.Start("SGCScreen")
			net.WriteEntity(ent)
			net.WriteTable(stbl)
			net.SendToServer()
		else
			local gtbl = util.TableToJSON(stbl,true)
			file.Write("stargate/sgcscreen.txt",gtbl)
		end
	end

end
concommand.Add("sgc_screen_menu",function() SGC_Codes_Mgr() end);

net.Receive( "SGCScreen", function( len )

	local ent = net.ReadEntity()
	local menu = util.tobool(net.ReadBit())
	if (menu) then
	    SGC_Codes_Mgr(net.ReadTable(),ent)
	else
		net.Start("SGCScreen")
		net.WriteEntity(ent)	
		/*local tbl = presets.GetTable("SGCScreen")  
		if (table.Count(tbl)==0) then -- bug, table is empty after reload gmod
			tbl = LoadPresets()
			if (tbl and tbl.sgcscreen) then tbl = tbl.sgcscreen end  
		end*/
		local tbl = util.JSONToTable(file.Read("stargate/sgcscreen.txt",gtbl) or "") or {}
		
		net.WriteTable(tbl)
		net.SendToServer()
	end
end)

end
