if (not StarGate.CheckModule("base")) then return end
------------------------------------------------
--Author Info
------------------------------------------------
SWEP.Author             = "Rothon"
SWEP.Contact            = "steven@facklerfamily.org"
SWEP.Purpose            = "Sends IDC through stargates"
SWEP.Instructions       = "Right click to set, Left click to send"
SWEP.PrintName = Language.GetMessage("weapon_misc_gdo");
SWEP.Category = Language.GetMessage("weapon_misc_cat");
------------------------------------------------

list.Set("CAP.Weapon", SWEP.PrintName, SWEP);
-- First person Model
SWEP.ViewModel = "models/Madman07/GDO/GDO_v.mdl"
SWEP.ViewModelFOV = 80
-- Third Person Model
SWEP.WorldModel = "models/Madman07/GDO/GDO_w.mdl"
-- Weapon Details
SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 3
SWEP.Secondary.Clipsize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.timeClicked = 0

SWEP.gate = nil

local function SendCode(EntTable)
	if(not IsValid(EntTable.Owner)) then return end
	local code = EntTable.Owner:GetInfo("cl_weapon_gdo_iriscode"):gsub("[^1-9]","")
	if (not IsValid(EntTable.gate) or not IsValid(EntTable.gate.Target)) then return end
	local gate_pos = EntTable.gate.Target:GetPos()
	local iris_comp = EntTable:FindEnt(gate_pos, true)
	if iris_comp and (SERVER) then
		local answer = iris_comp:RecieveIrisCode(code)
		if answer == 1 then
			EntTable:SetNetworkedString("gdo_textdisplay", "OPEN");
		elseif answer == 0 then
			EntTable:SetNWString("gdo_textdisplay", "WRONG");
		elseif (answer!=2) then
 			EntTable:SetNWString("gdo_textdisplay", answer);
		else
			EntTable:SetNWString("gdo_textdisplay", "STAND-BY");
			EntTable.Stand = true;
			timer.Create("GDOTimer",0.5,0,function()
				local ent = EntTable;
				if (IsValid(ent) and IsValid(ent.Owner) and ent.Stand and IsValid(ent.gate) and IsValid(ent.gate.Target) and ent.gate.IsOpen) then
					if (not ent.gate.Target:IsBlocked(1,1)) then
						ent:SetNWString("gdo_textdisplay", "OPEN");
						timer.Remove("GDOTimer");
						timer.Simple(5, function() if (IsValid(ent)) then ent:SetNWString("gdo_textdisplay", "GDO"); ent.Stand = false; end end);
					end
				else
					ent:SetNWString("gdo_textdisplay", "GDO");
					ent.Stand = false;
					timer.Remove("GDOTimer");
				end
			end)
		end
	end
end

function SWEP:Reload()
end

function SWEP:Initialize()
	self:SetNWString("gdo_textdisplay", "GDO")
	self.Stand = false
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()
	if(CLIENT || not IsValid(self.Owner) || self:GetNetworkedString("gdo_textdisplay","GDO")!="GDO") then return end
	local pos = self.Owner:GetPos()
	self.gate = self:FindEnt(pos, false)
	if(self.gate and self.gate.IsOpen) then
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay + 1 )
		self.Owner:SetAnimation(ACT_VM_PRIMARYATTACK);
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		timer.Simple(self.Primary.Delay+1, function() if IsValid(self) then SendCode(self) end end)
		timer.Simple(2, function() if IsValid(self) then self:SetNWString("gdo_textdisplay",self.Owner:GetInfo("cl_weapon_gdo_iriscode"):gsub("[^1-9]","")) end end);
		timer.Simple(self.Primary.Delay+5, function() if (IsValid(self) and not self.Stand) then self:SetNWString("gdo_textdisplay", "GDO") end end);
	end
end

function SWEP:SecondaryAttack()
	if(CLIENT) then return end
	umsg.Start("gdo_openpanel", self.Owner)
	umsg.End()
end

function SWEP:FindEnt(pos, find_pc) -- modified from avon's dhd function
	local nearest
	local entDist = 2000 -- max distance to ent
	local foundEnts = {}
	if find_pc then
		for _,v in pairs(ents.FindByClass("iris_computer")) do
			table.insert(foundEnts,v)
		end
	else
		for _,v in pairs(ents.FindByClass("stargate_*")) do
			if (v.IsStargate) then table.insert(foundEnts,v) end
		end
	end

	for _,v in pairs(foundEnts) do
		local foundEnt_dist = (pos - v:GetPos()):Length()
		if entDist >= foundEnt_dist then
			entDist = foundEnt_dist
			nearest = v
		end
	end
	return nearest
end
