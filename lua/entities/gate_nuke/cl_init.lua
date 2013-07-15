language.Add("gate_nuke", Language.GetMessage("gate_nuke"))

info = {
	Pos = Vector(0,0,0),
	Scale = 100,
}

function ENT:NukeSunBeams() -- All Credits for this goes to Jinto :}) -- Moustache
	if not render.SupportsPixelShaders_2_0() then return end
	if not StarGate.VisualsWeapons("cl_gate_nuke_sunbeams") then return end

	local pos = info.Pos
	local viewdiff = (pos-EyePos())
	local viewdir = viewdiff:GetNormal()
	local viewdist = viewdiff:Length()
	local eyedir = EyeAngles():Forward()

	-- Calculate the dot product of our view.
	local dot = (viewdir:Dot(EyeVector())-0.8)*5

	-- Die percent
	local dp = math.Clamp(2-self.Rel/10, 0, 1)

	-- Multiply
	dot = dot*dp*info.Scale/100

	-- Sun beams
	local screenpos = (EyePos()+viewdir*viewdist*0.5):ToScreen()

	if dot > 0 then

		DrawSunbeams(
		        0.95,
		        0.5*dot,
		        0.075,
		        screenpos.x/ScrW(),
		        screenpos.y/ScrH()
		)
	end
	return true
end

local function NukeSunBeamInfo(Info) -- I could just do this with network varibles but there sent the same way soo... meh.
	local pos = Info:ReadVector()
	local scale = Info:ReadFloat()
	info = {Pos = pos, Scale = scale}
end

usermessage.Hook("NukeSunBeamsInfoXD", NukeSunBeamInfo)

--###################### EVERYTHING BELOW IS TETABONITA'S

local sndWaveBlast = Sound("ambient/levels/streetwar/city_battle11.wav")
local sndWaveIncoming = Sound("ambient/levels/labs/teleport_preblast_suckin1.wav")
local sndSplode = Sound("ambient/explosions/explode_6.wav")
local sndRumble = Sound("ambient/explosions/exp1.wav")
local sndPop = Sound("weapons/pistol/pistol_fire3.wav")

include('shared.lua')

function ENT:Initialize()
	self.SplodeDist = 1000
	self.BlastSpeed = 4000
	self.SplodeDist = 0
	self.Time = CurTime()
	self.Init = self.Time
	self.Rel  = 0
	self.HPIS = false
	self.HPSS = false
	self.HPBS = false

	hook.Add("RenderScreenspaceEffects", "NukeSunBeams", function() self:NukeSunBeams() end)
	surface.PlaySound(sndRumble)
end

function ENT:Think()
	self.Time = CurTime()
	self.Rel = self.Time-self.Init

	if self.Rel > 20  then return end

	self.SplodeDist = self.BlastSpeed*self.Rel

	local EntPos = self.Entity:GetPos()
	local CurDist = (EntPos-LocalPlayer():GetPos()):Length()

	if CurDist < 900 + self.BlastSpeed then
		self.HPIS = true
	end

	if not self.HPSS then
		timer.Simple(CurDist/18e3,function() PlaySplodeSound(7e5/CurDist) end)
		self.HPSS = true
	end

	if self.Rel < 7 then
		if (not self.HPIS) and self.SplodeDist + self.BlastSpeed*1.6 > CurDist then
			surface.PlaySound(sndWaveIncoming)
			self.HPIS = true
		end

		if (not self.HPBS) and self.SplodeDist + self.BlastSpeed*0.2 > CurDist then
			surface.PlaySound(sndWaveBlast)
			self.HPBS = true
		end
	end

end

function PlaySplodeSound(volume)

	if volume > 400 then
		surface.PlaySound(sndSplode)
		return
	end

	if volume < 60 then volume = 60 end

	LocalPlayer():EmitSound(sndSplode,volume,100)
end

function PlayPopSound(ent)
	ent:EmitSound(sndPop,500,100)
end

function ENT:Draw()
end

function ENT:OnRemove()
	hook.Remove("RenderScreenspaceEffects", "NukeSunBeams")
end