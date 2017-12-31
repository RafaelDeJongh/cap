/*
	ZPM MK III Spawn Tool for GarrysMod10
	Copyright (C) 2010 Llapp
*/

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra") or SGLanguage==nil or SGLanguage.GetMessage==nil) then return end
include("weapons/gmod_tool/stargate_base_tool.lua");

TOOL.Category="Tech";
TOOL.Name=SGLanguage.GetMessage("stool_sgcscreen");

TOOL.ClientConVar["conn_sv"] = 1;
TOOL.ClientConVar["conn_sg"] = 1;
TOOL.ClientConVar["conn_ic"] = 1;
TOOL.ClientConVar["conn_nb"] = 1;
TOOL.ClientConVar["autoweld"] = 1;
TOOL.ClientConVar["fps"] = 100;
TOOL.ClientConVar['model'] = "models/props_lab/monitor01a.mdl";
TOOL.ClientConVar["keyboard"] = 0;
TOOL.ClientConVar["keyboard_weld"] = 1;
TOOL.ClientConVar["program"] = 1;
TOOL.ClientConVar["key"] = KEY_LCONTROL;
TOOL.ClientConVar["keyd"] = KEY_F1;
TOOL.Entity.Class = "sgc_monitor";
TOOL.Entity.Keys = {};
TOOL.Entity.Limit = 12;
TOOL.CustomSpawnCode = true;
TOOL.Entity.Limits = {["sgc_server"]=1}
TOOL.Topic["name"] = SGLanguage.GetMessage("stool_sgcscreen_spawner");
TOOL.Topic["desc"] = SGLanguage.GetMessage("stool_sgcscreen_create");
TOOL.Topic[0] = SGLanguage.GetMessage("stool_sgcscreen_desc");
TOOL.Language["Undone"] = SGLanguage.GetMessage("stool_sgcscreen_undone");
TOOL.Language["Cleanup"] = SGLanguage.GetMessage("stool_sgcscreen_cleanup");
TOOL.Language["Cleaned"] = SGLanguage.GetMessage("stool_sgcscreen_cleaned");
TOOL.Language["SBoxLimit"] = SGLanguage.GetMessage("stool_sgcscreen_limit");

function TOOL:LeftClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == self.Entity.Class) then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	if(p:GetCount("CAP_sgc_screens")>=GetConVar("sbox_maxsgc_monitor"):GetInt()) then
		p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_sgcscreen_limit\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end
	
	local e = self:MakeEntity(p, t, "sgc_monitor")
	if (not IsValid(e)) then return false end
	local weld = util.tobool(self:GetClientNumber("autoweld"));
	if(util.tobool(self:GetClientNumber("conn_sv"))) then
		local fent = e:FindNearestClass("sgc_server",t.HitPos)
		if (IsValid(fent)) then
			e.Server = fent
		end
	end
	local keyb = nil
	if(util.tobool(self:GetClientNumber("keyboard"))) then
		local tool = p:GetTool( "wire_keyboard" )
		local ent = tool:LeftClick_Make(t,p)
		if (type(ent)!="boolean" and IsValid(ent)) then
			keyb = ent
			ent:SetAngles(e:GetAngles())
			local dir = ent:GetForward()
			local y = e:OBBMaxs().y
			ent:SetPos(ent:GetPos()+dir*(y+15))
			e.Keyboard = keyb
			e.KeyboardSpawned = true
			if util.tobool(self:GetClientNumber("keyboard_weld")) then
				ent:SetParent(e)
				self:Weld(ent,e,true); -- fix dupe
			end
			local phys = ent:GetPhysicsObject();
			if(phys:IsValid()) then
				phys:EnableMotion(false);
			end
		end
	end
	local c = self:Weld(e,t.Entity,weld);
	local cb = self:Weld(keyb,t.Entity,weld);
	self:AddUndo(p,e,c,keyb,cb);
	self:AddCleanup(p,c,e);
	p:AddCount("CAP_sgc_screens", e)
	return true;
end

function TOOL:RightClick(t)
	if(t.Entity and t.Entity:IsPlayer()) then return false end;
	if(t.Entity and t.Entity:GetClass() == "sgc_server") then return false end;
	if(CLIENT) then return true end;
	local p = self:GetOwner();
	if(p:GetCount("CAP_sgc_servers")>=GetConVar("sbox_maxsgc_server"):GetInt()) then
		p:SendLua("GAMEMODE:AddNotify(SGLanguage.GetMessage(\"stool_sgcscreen_limit_sv\"), NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
		return false;
	end
	
	local e = self:MakeEntity(p, t, "sgc_server")
	if (not IsValid(e)) then return false end
	local weld = util.tobool(self:GetClientNumber("autoweld"));
	if(util.tobool(self:GetClientNumber("conn_sg"))) then
		local gate = e:FindNearestGate(t.HitPos)
		if (IsValid(gate)) then
			e.LockedGate = gate
			e.LockedGate:TriggerInput("SGC Type",1)
			e:SetNW2Entity("Gate",gate)
			gate.SGCScreen = e
		else
			e.FindGate = true
		end
	end
	
	if(util.tobool(self:GetClientNumber("conn_sv"))) then
		local pos = t.HitPos;
		local ents = ents.FindInSphere(pos,2000)
		for k,v in pairs(ents) do
			if (v:GetClass()=="sgc_monitor") then
				if not IsValid(v.Server) then
					v.Server = e
				end
			end
		end		
	end
	
	if(util.tobool(self:GetClientNumber("conn_ic"))) then
		local fent = e:FindNearestClass("iris_computer",t.HitPos)
		if (IsValid(fent)) then
			e.IDCReceiver = fent
			fent.SGCScreen = e
		else
			e.FindIDC = true
		end
	end
	
	if(util.tobool(self:GetClientNumber("conn_nb"))) then
		local fent = e:FindNearestClass("naquadah_bomb",t.HitPos)
		if (IsValid(fent)) then
			e.Bomb = fent
			fent.SGCScreen = e
		else
			e.FindBomb = true
		end
	end

	-- has to be delay, or not work in multiplayer
	timer.Simple(0,function() if IsValid(e) then e:InitCodes(p) end end)
	local c = self:Weld(e,t.Entity,weld);
	self:AddUndo(p,e,c);
	self:AddCleanup(p,c,e);
	p:AddCount("CAP_sgc_servers", e)

	return true;
end

if(SERVER) then
    function TOOL:MakeEntity(ply, tr, class)
    	if (IsValid(ply)) then
			if (StarGate_Group and StarGate_Group.Error == true) then StarGate_Group.ShowError(ply); return
			elseif (StarGate_Group==nil or StarGate_Group.Error==nil) then
				Msg("Carter Addon Pack - Unknown Error\n");
				ply:SendLua("Msg(\"Carter Addon Pack - Unknown Error\\n\")");
				ply:SendLua("GAMEMODE:AddNotify(\"Carter Addon Pack: Unknown Error\", NOTIFY_ERROR, 5); surface.PlaySound( \"buttons/button2.wav\" )");
				return;
			end
			if (StarGate.NotSpawnable("sgc_screen",ply,"tool")) then return end
		end

        local entity;
        entity = ents.Create(class)
        entity:SetVar("Owner", ply)
		entity:SetNWEntity("Owner", ply)
		entity.Owner = ply
		entity.Screen = self:GetClientNumber("program")
		entity.Key = self:GetClientNumber("key")
		entity.KeyD = self:GetClientNumber("keyd")
		entity:SetModel(self:GetClientInfo("model"))
        entity:Spawn()
		self:SetPositionAndAngles(entity,tr)
        return entity
    end
end

function TOOL:ControlsPanel(Panel)
	//Panel:NumSlider(SGLanguage.GetMessage("stool_sgcs_fps"),"sgc_screen_fps",1,100,0);
	Panel:Button(SGLanguage.GetMessage("stool_sgcscreen_menu"),"sgc_screen_menu");
	
	Panel:CheckBox(SGLanguage.GetMessage("stool_autoweld"),"sgc_screen_autoweld");
	Panel:CheckBox(SGLanguage.GetMessage("stool_sgcscreen_conn_sv"),"sgc_screen_conn_sv");
	Panel:AddControl("Label", {Text = SGLanguage.GetMessage("stool_sgcscreen_sv")})	
	Panel:CheckBox(SGLanguage.GetMessage("stool_sgcscreen_conn_sg"),"sgc_screen_conn_sg");
	Panel:CheckBox(SGLanguage.GetMessage("stool_sgcscreen_conn_ic"),"sgc_screen_conn_ic");
	Panel:CheckBox(SGLanguage.GetMessage("stool_sgcscreen_conn_nb"),"sgc_screen_conn_nb");
	Panel:AddControl("Label", {Text = SGLanguage.GetMessage("stool_sgcscreen_cl")})
	Panel:CheckBox(SGLanguage.GetMessage("stool_sgcscreen_keyboard"),"sgc_screen_keyboard");
	Panel:CheckBox(SGLanguage.GetMessage("stool_sgcscreen_keyboard_weld"),"sgc_screen_keyboard_weld");
	
	local combo = {}
	combo.Label = SGLanguage.GetMessage("stool_sgcscreen_program")
	combo.MenuButton = 0
	combo.Options = {}

	local screens = {}	
	for x,filename in pairs(file.Find("entities/sgc_monitor/screens/*.lua","LUA")) do
		local SCR = include("entities/sgc_monitor/screens/"..filename)
		if not SCR then continue end
		screens[SCR.ID] = SCR
	end	
	local panel = Panel:AddControl('ComboBox', combo)	
	for k,SCR in SortedPairs(screens) do
		local name = SGLanguage.ValidMessage("stool_sgcscreen_program_"..SCR.ID) and SGLanguage.GetMessage("stool_sgcscreen_program_"..SCR.ID) or SCR.Name
		--combo.Options[name] = {sgc_screen_program = SCR.ID}
		panel:AddOption( name, {sgc_screen_program = SCR.ID} )
	end
	-- fix sorting
	panel.OpenMenu = function( self, pControlOpener )
		if ( pControlOpener && pControlOpener == self.TextEntry ) then
			return
		end  
		-- Don't do anything if there aren't any options..
		if ( #self.Choices == 0 ) then return end
		-- If the menu still exists and hasn't been deleted
		-- then just close it and don't open a new one.
		if ( IsValid( self.Menu ) ) then
			self.Menu:Remove()
			self.Menu = nil
		end
		self.Menu = DermaMenu( false, self )

		for k, v in SortedPairs( self.Choices ) do
			self.Menu:AddOption( v, function() self:ChooseOption( v, k ) end )
		end

		local x, y = self:LocalToScreen( 0, self:GetTall() )
		self.Menu:SetMinimumWidth( self:GetWide() )
		self.Menu:Open( x, y, false, self )
	end
	
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_sgcscreen_key"),
		Command="sgc_screen_key",
	});
	
	Panel:AddControl("Numpad",{
		ButtonSize=22,
		Label=SGLanguage.GetMessage("stool_sgcscreen_keyd"),
		Command="sgc_screen_keyd",
	});
	
	local models = list.Get( "WireScreenModels" )
	models["models/props_lab/monitor01a.mdl"]=true
	for k,v in pairs(models) do
		models[k] = {}
	end
	
	Panel:AddControl("PropSelect",{Label=SGLanguage.GetMessage("stool_model"),ConVar="sgc_screen_model",Category="",Models=models});
	
	Panel:AddControl("Label", {Text = SGLanguage.GetMessage("stool_sgcscreen_fulldesc")})	
	Panel:AddControl("Label", {Text = SGLanguage.GetMessage("stool_sgcscreen_controls")})
end

TOOL:Register();