/*
	Stargate Lib for GarrysMod10
	Copyright (C) 2007-2009  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
/*
	Carter's Addon Pack Tab for GarrysMod10
	Copyright (C) 2010  Llapp
*/

--################# Loads the menues #################
--################ Check for visuals (used in effects) @aVoN
function StarGate.VisualsShips(str)
	if(util.tobool(LocalPlayer():GetInfo("cl_stargate_visualsship")) and util.tobool(LocalPlayer():GetInfo(str))) then
		return true;
	end
	return false;
end

function StarGate.VisualsWeapons(str)
	if(util.tobool(LocalPlayer():GetInfo("cl_stargate_visualsweapon")) and util.tobool(LocalPlayer():GetInfo(str))) then
		return true;
	end
	return false;
end

function StarGate.VisualsMisc(str,ignore)
	if((util.tobool(LocalPlayer():GetInfo("cl_stargate_visualsmisc")) or ignore) and util.tobool(LocalPlayer():GetInfo(str))) then
		return true;
	end
	return false;
end

--################ Reset values to 0, if this user just updated to this version @aVoN
-- The reason is, some dynamic lights crash players. So I want to have them disabled by default.
-- But sadly they already have the necessary CVAR set to 1. So I reset it to 0 once.
-- Now if they reset it to 1 it will keep of course at 1.
local ResetDynamicLights = CreateClientConVar("cl_reset_dynamic_lights",0,true,false);
function StarGate.Hook.ResetDynamicLights(_,key)
	if(key ~= "+menu") then return end;
	if(not ResetDynamicLights:GetBool()) then
		local dynlights = {
			"cl_stargate_dynlights",
			"cl_shield_dynlights",
			"cl_harvester_dynlights",
			"cl_supergate_dynlights",
			"cl_applecore_light",
			"cl_jumper_dynlights",
			"cl_chair_dynlights",
			"cl_zat_dynlights",
			"cl_staff_dynlights",
			"cl_staff_dynlights_flight",
			"cl_gate_nuke_dynlights",
			"cl_overloader_dynlights",
			"cl_asuran_dynlights",
			"cl_oribeam_dynlights"
		}

		for _,v in pairs(dynlights) do
			RunConsoleCommand(v,"0");
		end
		RunConsoleCommand("cl_reset_dynamic_lights",1);
	end
	hook.Remove("PlayerBindPress","StarGate.Hook.ResetDynamicLights");
end
hook.Add("PlayerBindPress","StarGate.Hook.ResetDynamicLights",StarGate.Hook.ResetDynamicLights);

spawnmenu.AddContentType( "cap_npc", function( container, obj )

	if ( !obj.material ) then return end
	if ( !obj.nicename ) then return end
	if ( !obj.spawnname ) then return end

	if ( !obj.weapon ) then obj.weapon = gmod_npcweapon:GetString() end

	local icon = vgui.Create( "ContentIcon", container )
		icon:SetContentType( "npc" )
		icon:SetSpawnName( obj.spawnname )
		icon:SetName( obj.nicename )
		icon:SetMaterial( obj.material )
		icon.SetAdminOnly = function(self,admin)
			if (admin) then
				self.imgAdmin = vgui.Create( "DImage", self )
				self.imgAdmin:SetImage( "icon16/shield.png" )
				self.imgAdmin:SetSize(16,16);
				self.imgAdmin:SetPos(self:GetWide()-22,5);
				self.imgAdmin:SetTooltip( "Admin Only" )
			end
		end
		icon:SetAdminOnly( obj.admin )
		icon:SetNPCWeapon( obj.weapon )
		icon:SetColor( Color( 244, 164, 96, 255 ) )
		local Tooltip =  Format( "%s", obj.nicename )
        if ( obj.author ) then Tooltip = Format( "%s\n"..SGLanguage.GetMessage("cap_menu_author")..": %s", Tooltip, obj.author ) end
		icon:SetTooltip(Tooltip);

		icon.DoClick = function()

						local weapon = obj.weapon;
						if ( gmod_npcweapon:GetString() != "" ) then weapon = gmod_npcweapon:GetString(); end

						RunConsoleCommand( "gmod_spawnnpc", obj.spawnname, weapon );
						surface.PlaySound( "ui/buttonclickrelease.wav" )
					end

		icon.OpenMenu = function( icon )

						local menu = DermaMenu()

							local weapon = obj.weapon;
							if ( gmod_npcweapon:GetString() != "" ) then weapon = gmod_npcweapon:GetString(); end

							menu:AddOption( "Copy to Clipboard", function() SetClipboardText( obj.spawnname ) end )
							menu:AddOption( "Spawn Using Toolgun", function() RunConsoleCommand( "gmod_tool", "creator" ); RunConsoleCommand( "creator_type", "2" ); RunConsoleCommand( "creator_name", obj.spawnname ); RunConsoleCommand( "creator_arg", weapon ); end )
						menu:Open()

					end



	if ( IsValid( container ) ) then
		container:Add( icon )
	end

	return icon;

end )

spawnmenu.AddContentType( "cap_entity", function( container, obj )

	if ( !obj.material ) then return end
	if ( !obj.nicename ) then return end
	if ( !obj.spawnname ) then return end

	local icon = vgui.Create( "ContentIcon", container )
		icon:SetContentType( "entity" )
		icon:SetSpawnName( obj.spawnname )
		icon:SetName( obj.nicename )
		icon:SetMaterial( obj.material )
		icon.SetAdminOnly = function(self,admin)
			if (admin) then
				self.imgAdmin = vgui.Create( "DImage", self )
				self.imgAdmin:SetImage( "icon16/shield.png" )
				self.imgAdmin:SetSize(16,16);
				self.imgAdmin:SetPos(self:GetWide()-22,5);
				self.imgAdmin:SetTooltip( "Admin Only" )
			end
		end
		icon:SetAdminOnly( obj.admin )
		local Tooltip =  Format( "%s", obj.nicename )
        if ( obj.author ) then Tooltip = Format( "%s\n"..SGLanguage.GetMessage("cap_menu_author")..": %s", Tooltip, obj.author ) end
        if ( obj.info and obj.info!="" ) then Tooltip = Format( "%s\n\n%s", Tooltip, obj.info ) end
		icon:SetTooltip(Tooltip);
		icon:SetColor( Color( 205, 92, 92, 255 ) )
		icon.DoClick = function()
						RunConsoleCommand( "cap_spawnsent", obj.spawnname );
						surface.PlaySound( "ui/buttonclickrelease.wav" )
					end
		icon.OpenMenu = function( icon )

						local menu = DermaMenu()
							menu:AddOption( "Copy to Clipboard", function() SetClipboardText( obj.spawnname ) end )
							menu:AddOption( "Spawn Using Toolgun", function() RunConsoleCommand( "gmod_tool", "cap_creator" ); RunConsoleCommand( "cap_creator_type", "0" ); RunConsoleCommand( "cap_creator_name", obj.spawnname ) end )
						menu:Open()

					end

	if ( IsValid( container ) ) then
		container:Add( icon )
	end

	return icon;

end )

spawnmenu.AddContentType( "cap_weapon", function( container, obj )

	if ( !obj.material ) then return end
	if ( !obj.nicename ) then return end
	if ( !obj.spawnname ) then return end

	local icon = vgui.Create( "ContentIcon", container )
		icon:SetContentType( "weapon" )
		icon:SetSpawnName( obj.spawnname )
		icon:SetName( obj.nicename )
		icon:SetMaterial( obj.material )
		icon.SetAdminOnly = function(self,admin)
			if (admin) then
				self.imgAdmin = vgui.Create( "DImage", self )
				self.imgAdmin:SetImage( "icon16/shield.png" )
				self.imgAdmin:SetSize(16,16);
				self.imgAdmin:SetPos(self:GetWide()-22,5);
				self.imgAdmin:SetTooltip( "Admin Only" )
			end
		end
		icon:SetAdminOnly( obj.admin )
		local Tooltip =  Format( "%s", obj.nicename )
        if ( obj.author ) then Tooltip = Format( "%s\n"..SGLanguage.GetMessage("cap_menu_author")..": %s", Tooltip, obj.author ) end
        if ( obj.info and obj.info!="" ) then Tooltip = Format( "%s\n\n%s", Tooltip, obj.info ) end
		icon:SetTooltip(Tooltip);
		icon:SetColor( Color( 135, 206, 250, 255 ) )
		icon.DoClick = function()

						RunConsoleCommand( "cap_giveswep", obj.spawnname );
						surface.PlaySound( "ui/buttonclickrelease.wav" )

					end

		icon.DoMiddleClick = function()

						RunConsoleCommand( "cap_spawnswep", obj.spawnname );
						surface.PlaySound( "ui/buttonclickrelease.wav" )

					end


		icon.OpenMenu = function( icon )

						local menu = DermaMenu()
							menu:AddOption( "Copy to Clipboard", function() SetClipboardText( obj.spawnname ) end )
							menu:AddOption( "Spawn Using Toolgun", function() RunConsoleCommand( "gmod_tool", "cap_creator" ); RunConsoleCommand( "cap_creator_type", "3" ); RunConsoleCommand( "cap_creator_name", obj.spawnname ) end )
						menu:Open()

						end


	if ( IsValid( container ) ) then
		container:Add( icon )
	end

	return icon;

end )

local function StargateAddTab(Categorised, pnlContent, tree, node)
	--
	-- Add a tree node for each category
	--
	for CategoryName, v in SortedPairs( Categorised ) do
		-- Add a node to the tree
		local icon = "icon16/bricks.png";
		local enttype = v[1].__enttype;
		local adminonly,disabled = "ent_admin_only","cap_disabled_ent";
		if (enttype=="cap_weapon") then icon = "icon16/gun.png"; adminonly,disabled = "swep_admin_only","cap_disabled_swep"; end
		if (enttype=="cap_npc") then icon = "icon16/monkey.png"; adminonly,disabled = "npc_admin_only","cap_disabled_npc"; end
		if (enttype=="cap_npc") then
			-- Add a node to the tree
			local node = tree:AddNode( CategoryName, icon );

			-- When we click on the node - populate it using this function
			node.DoPopulate = function( self )

				-- If we've already populated it - forget it.
				if ( self.PropPanel ) then return end

				-- Create the container panel
				self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
				self.PropPanel:SetVisible( false )
				self.PropPanel:SetTriggerSpawnlistChange( false )

				for name, ent in SortedPairsByMemberValue( v, "Name" ) do

					local weapon = "";
					if ( ent.Weapons ) then
						weapon = ent.Weapons[1];
					end

					spawnmenu.CreateContentIcon( "cap_npc", self.PropPanel,
					{
						nicename	= ent.Name,
						spawnname	= ent.__ClassName,
						material	= "entities/"..ent.__ClassName..".png",
						weapon		= weapon,
						author		= ent.Author,
						admin		= false
					})

				end

			end

			-- If we click on the node populate it and switch to it.
			node.DoClick = function( self )

				self:DoPopulate()
				pnlContent:SwitchPanel( self.PropPanel );

			end
		else
			local node = tree:AddNode( CategoryName, icon );

				-- When we click on the node - populate it using this function
			node.DoPopulate = function( self )

				-- If we've already populated it - forget it.
				if ( self.PropPanel ) then return end

				-- Create the container panel
				self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
				self.PropPanel:SetVisible( false )
				self.PropPanel:SetTriggerSpawnlistChange( false )

				for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do
					if (StarGate.CFG:Get(disabled,ent.ClassName,false)) then continue end
					spawnmenu.CreateContentIcon( enttype, self.PropPanel,
					{
						nicename	= ent.PrintName or ent.__ClassName,
						spawnname	= ent.ClassName,
						material	= "entities/"..ent.ClassName..".png",
						admin		= StarGate.CFG:Get(adminonly,ent.ClassName,false),
						author		= ent.Author,
						info		= ent.Instructions,
					})

				end
			end

			-- If we click on the node populate it and switch to it.
			node.DoClick = function( self )

				self:DoPopulate()
				pnlContent:SwitchPanel( self.PropPanel );

			end
        end

	end
end

hook.Add( "StargateTab", "AddEntityContent", function( pnlContent, tree, node )
	local Categorised = {}

	-- Add this list into the tormoil
	local SpawnableEntities = list.Get( "CAP.Entity" )
	if ( SpawnableEntities ) then
		for k, v in pairs( SpawnableEntities ) do
			v.Category = v.Category or "Other"
			v.__ClassName = k;
			v.__enttype = "cap_entity";
			Categorised[ v.Category ] = Categorised[ v.Category ] or {}
			table.insert( Categorised[ v.Category ], v )
		end
	end

	StargateAddTab(Categorised, pnlContent, tree, node)
	Categorised = {}

	-- Loop through the weapons and add them to the menu
	local Weapons = list.Get( "CAP.Weapon" )

	-- Build into categories
	for k, weapon in pairs( Weapons ) do
		weapon.__ClassName = k;
		weapon.__enttype = "cap_weapon";
		Categorised[ weapon.Category ] = Categorised[ weapon.Category ] or {}
		table.insert( Categorised[ weapon.Category ], weapon )
	end

	StargateAddTab(Categorised, pnlContent, tree, node)
	Categorised = {}

	-- Get a list of available NPCs
	local NPCList = list.Get( "CAP.NPC" )

	-- Categorize them
	for k, v in pairs( NPCList ) do
		local Category = v.Category or "Other"
		local Tab = Categorised[ Category ] or {}
		--Tab[ k ] = v
		v.__enttype = "cap_npc";
		v.__ClassName = k;
		Categorised[ Category ] = Tab
		table.insert( Categorised[ Category ], v )
	end

	StargateAddTab(Categorised, pnlContent, tree, node)

	if (StarGate.CheckModule("misc")) then
	local node = tree:AddNode( SGLanguage.GetMessage("cap_prop_cat"), "icon16/folder.png", true );

	node.DoPopulate = function(self)

		-- If we've already populated it - forget it.
		if ( self.PropPanel ) then return end

		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		--self.PropPanel:SetTriggerSpawnlistChange( false )

		local spl = {"Misc","CapBuild","CatWalkBuild"}; -- for order

		for i=1,3 do
			local spawnlist = StarGate.SpawnList[spl[i]];
			if (spawnlist) then

				local models = node:AddNode( SGLanguage.GetMessage("cap_prop_cat"..i), "icon16/page.png" );
				models.DoPopulate = function(self)

					-- If we've already populated it - forget it.
					if ( self.PropPanel ) then return end

					self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
					self.PropPanel:SetVisible( false )
					--self.PropPanel:SetTriggerSpawnlistChange( false )

					local lines = StarGate.SpawnList[spl[i]];
					for _,l in pairs(lines) do
						if (not l or l=="") then continue; end
						local cp = spawnmenu.GetContentType( "model" );
						if ( cp ) then
							cp( self.PropPanel, { model = l } )
						end
					end

				end
				models.DoClick = function( self )

					self:DoPopulate()
					pnlContent:SwitchPanel( self.PropPanel );

				end
			end
		end
	end

	-- If we click on the node populate it and switch to it.
	node.DoClick = function( self )

		self:DoPopulate()
		--pnlContent:SwitchPanel( self.PropPanel );
		/*local FirstNode = node:GetChildNode( 0 )
		if ( IsValid( FirstNode ) ) then
			FirstNode:InternalDoClick()
		end  */

	end
	end

	-- Select the first node
	local FirstNode = tree:Root():GetChildNode( 0 )
	if ( IsValid( FirstNode ) ) then
		FirstNode:InternalDoClick()
	end

end )

--################# Adds the tab to the spawnmenu @aVoN
function StarGate.Hook.AddToolTab()
	if(not StarGate.Installed or not StarGate.InstalledOnClient()) then return end;
	-- Add Tab
	-- local logo;
	-- if(file.Exists("materials/gui/cap_logo","GAME")) then logo = "gui/cap_logo" end;
	local cat_name = SGLanguage.GetMessage("stool_cat");
	spawnmenu.AddCreationTab(cat_name,function()
		local ctrl = vgui.Create( "SpawnmenuContentPanel" )
		ctrl:CallPopulateHook( "StargateTab" );
		return ctrl
	end, "gui/cap_logo", 60 )
	spawnmenu.AddToolTab(cat_name,cat_name,"gui/cap_logo");

	-- Add Config Category
	local config_name = SGLanguage.GetMessage("stool_cat_config");
	local keys_name = SGLanguage.GetMessage("stool_cat_keys");
	if (StarGate.CheckModule("base")) then spawnmenu.AddToolCategory(cat_name,config_name," "..config_name); end
	if (StarGate.CheckModule("base")) then spawnmenu.AddToolCategory(cat_name,SGLanguage.GetMessage("stool_cat_tech"),SGLanguage.GetMessage("stool_cat_tech")); end
	if (StarGate.CheckModule("energy")) then spawnmenu.AddToolCategory(cat_name,SGLanguage.GetMessage("stool_cat_energy"),SGLanguage.GetMessage("stool_cat_energy")); end
	if (StarGate.CheckModule("entweapon")) then spawnmenu.AddToolCategory(cat_name,SGLanguage.GetMessage("stool_cat_weapons"),SGLanguage.GetMessage("stool_cat_weapons")); end
	if (StarGate.CheckModule("extra")) then spawnmenu.AddToolCategory(cat_name,SGLanguage.GetMessage("stool_cat_ramps"),SGLanguage.GetMessage("stool_cat_ramps")); end
	if (StarGate.CheckModule("base") or StarGate.CheckModule("ships")) then spawnmenu.AddToolCategory(cat_name,keys_name,keys_name); end

	-- Add the entry for config
	spawnmenu.AddToolMenuOption(cat_name,config_name,SGLanguage.GetMessage("stool_credits")," "..SGLanguage.GetMessage("stool_credits"),"","",StarGate.Update_Check);
	spawnmenu.AddToolMenuOption(cat_name,config_name,SGLanguage.GetMessage("stool_settings")," "..SGLanguage.GetMessage("stool_settings"),"","",StarGate_Settings);
	if (StarGate.CheckModule("entweapons") or StarGate.CheckModule("weapons")) then spawnmenu.AddToolMenuOption(cat_name,config_name,SGLanguage.GetMessage("stool_weapvis")," "..SGLanguage.GetMessage("stool_weapvis"),"","",StarGate.WeaponVisualSettings,{SwitchConVar="cl_stargate_visualsweapon"}); end
	spawnmenu.AddToolMenuOption(cat_name,config_name,SGLanguage.GetMessage("stool_miscvis")," "..SGLanguage.GetMessage("stool_miscvis"),"","",StarGate.MiscVisualSettings,{SwitchConVar="cl_stargate_visualsmisc"});
	if (StarGate.CheckModule("ship")) then spawnmenu.AddToolMenuOption(cat_name,config_name,SGLanguage.GetMessage("stool_shipvis")," "..SGLanguage.GetMessage("stool_shipvis"),"","",StarGate.ShipVisualSettings,{SwitchConVar="cl_stargate_visualsship"}); end

	-- Keybinders
	if (StarGate.CheckModule("ships")) then
		spawnmenu.AddToolMenuOption(cat_name,keys_name,"Dart"," "..SGLanguage.GetMessage("stool_key_dart"),"","",StarGate.DartSettings);
		spawnmenu.AddToolMenuOption(cat_name,keys_name,"GateGlider"," "..SGLanguage.GetMessage("stool_key_glider"),"","",StarGate.GateGliderSettings);
		spawnmenu.AddToolMenuOption(cat_name,keys_name,"Death Glider"," "..SGLanguage.GetMessage("stool_key_dglider"),"","",StarGate.DeathGliderSettings);
		spawnmenu.AddToolMenuOption(cat_name,keys_name,"F302"," "..SGLanguage.GetMessage("stool_key_f302"),"","",StarGate.F302Settings);
		spawnmenu.AddToolMenuOption(cat_name,keys_name,"Jumper"," "..SGLanguage.GetMessage("stool_key_jumper"),"","",StarGate.JumperSettings);
	end
	if (StarGate.CheckModule("base")) then
		spawnmenu.AddToolMenuOption(cat_name,keys_name,"MALP"," "..SGLanguage.GetMessage("stool_key_malp"),"","",StarGate.MALPSettings);
	end
	if (StarGate.CheckModule("ships")) then
		spawnmenu.AddToolMenuOption(cat_name,keys_name,"Shuttle"," "..SGLanguage.GetMessage("stool_key_dest"),"","",StarGate.ShuttleSettings);
		spawnmenu.AddToolMenuOption(cat_name,keys_name,"Teltak"," "..SGLanguage.GetMessage("stool_key_teltak"),"","",StarGate.TeltakSettings);
	end

	-- Add our stargate tools to the tab
	local toolgun = weapons.Get("gmod_tool");
	if(toolgun and toolgun.Tool) then
		for k,v in pairs(toolgun.Tool) do
			if(not v.AddToMenu and v.Tab == "Stargate") then
				if (v.Category == "Tech") then v.Category = SGLanguage.GetMessage("stool_cat_tech");
				elseif (v.Category == "Energy") then v.Category = SGLanguage.GetMessage("stool_cat_energy");
				elseif (v.Category == "Weapons") then v.Category = SGLanguage.GetMessage("stool_cat_weapons");
				elseif (v.Category == "Ramps") then v.Category = SGLanguage.GetMessage("stool_cat_ramps");
				end
				spawnmenu.AddToolMenuOption(
					cat_name,
					v.Category or "",
					k,
					v.Name or "#"..k,
					v.Command or "gmod_tool "..k,
					v.ConfigName or k,
					v.BuildCPanel
				);
			end
		end
	end
end
hook.Add("AddToolMenuTabs","StarGate.Hook.AddToolTab",StarGate.Hook.AddToolTab);

--################ This is used in every tool or config to tell the people, that the version of stargate they use is out of date. @aVoN
-- This is called in the BaseTool and where it's necessary (StarGate.ConfigMenu);
function StarGate.HasLatestVersion(Panel)
	if(StarGate.LATEST_VERSION > StarGate.CURRENT_VERSION) then
		local RED = Color(255,0,0,255);
		Panel:Help("");
		Panel:Help(SGLanguage.GetMessage("stool_update_01")):SetTextColor(RED);
		Panel:Help(SGLanguage.GetMessage("stool_update_02").." "..StarGate.LATEST_VERSION):SetTextColor(RED);
		Panel:Help(SGLanguage.GetMessage("stool_update_03"));
	end
end