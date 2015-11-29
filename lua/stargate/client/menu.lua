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
	if(LocalPlayer() and LocalPlayer().GetInfo and util.tobool(LocalPlayer():GetInfo("cl_stargate_visualsship")) and util.tobool(LocalPlayer():GetInfo(str))) then
		return true;
	end
	return false;
end

function StarGate.VisualsWeapons(str)
	if(LocalPlayer() and LocalPlayer().GetInfo and util.tobool(LocalPlayer():GetInfo("cl_stargate_visualsweapon")) and util.tobool(LocalPlayer():GetInfo(str))) then
		return true;
	end
	return false;
end

function StarGate.VisualsMisc(str,ignore)
	if(LocalPlayer() and LocalPlayer().GetInfo and (util.tobool(LocalPlayer():GetInfo("cl_stargate_visualsmisc")) or ignore) and util.tobool(LocalPlayer():GetInfo(str))) then
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

	local gmod_npcweapon = GetConVar("gmod_npcweapon") or CreateConVar( "gmod_npcweapon", "", { FCVAR_ARCHIVE } );

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

						RunConsoleCommand( "cap_spawnnpc", obj.spawnname, weapon );
						surface.PlaySound( "ui/buttonclickrelease.wav" )
					end

		icon.OpenMenu = function( icon )

						local menu = DermaMenu()

							local weapon = obj.weapon;
							if ( gmod_npcweapon:GetString() != "" ) then weapon = gmod_npcweapon:GetString(); end

							menu:AddOption( "Copy to Clipboard", function() SetClipboardText( obj.spawnname ) end )
							menu:AddOption( "Spawn Using Toolgun", function() RunConsoleCommand( "gmod_tool", "cap_creator" ); RunConsoleCommand( "cap_creator_type", "2" ); RunConsoleCommand( "cap_creator_name", obj.spawnname ); RunConsoleCommand( "cap_creator_arg", weapon ); end )
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
		local adminonly,disabled = "ent_groups_only","cap_disabled_ent";
		if (enttype=="cap_weapon") then icon = "icon16/gun.png"; adminonly,disabled = "swep_groups_only","cap_disabled_swep"; end
		if (enttype=="cap_npc") then icon = "icon16/monkey.png"; adminonly,disabled = "npc_groups_only","cap_disabled_npc"; end
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
					if (StarGate.CFG:Get(disabled,ent.__ClassName,false)) then continue end
					local adm_only = false;
					local tbl = StarGate.CFG:Get(adminonly,ent.__ClassName,""):TrimExplode(",");
					if (table.HasValue(tbl,"add_shield")) then adm_only = true; end

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
						admin		= adm_only,
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
					local adm_only = false;
					local tbl = StarGate.CFG:Get(adminonly,ent.ClassName,""):TrimExplode(",");
					if (table.HasValue(tbl,"add_shield")) then adm_only = true; end
					spawnmenu.CreateContentIcon( enttype, self.PropPanel,
					{
						nicename	= ent.PrintName or ent.__ClassName,
						spawnname	= ent.ClassName,
						material	= "entities/"..ent.ClassName..".png",
						admin		= adm_only,
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

	--node.DoPopulate = function(self)
  		local self = node;
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
	--end
    /*
	-- If we click on the node populate it and switch to it.
	node.DoClick = function( self )

		self:DoPopulate()
		--pnlContent:SwitchPanel( self.PropPanel );
		local FirstNode = node:GetChildNode( 0 )
		if ( IsValid( FirstNode ) ) then
			FirstNode:InternalDoClick()
		end

	end */
	end

	local node = tree:AddNode( SGLanguage.GetMessage("spawninfo_title"), "icon16/information.png", true );

	local multi_url = SGLanguage.GetMessage("spawninfo_multi_url");
	if (not SGLanguage.ValidMessage("spawninfo_multi_url")) then
		multi_url = StarGate.HTTP.MULTI;
	end
	local cats = {
		{SGLanguage.GetMessage("spawninfo_news"),StarGate.HTTP.NEWS,"icon16/newspaper.png"},
		{SGLanguage.GetMessage("spawninfo_wiki"),StarGate.HTTP.WIKI,"icon16/page_white_text.png"},
		{SGLanguage.GetMessage("spawninfo_forum"),StarGate.HTTP.FORUM,"icon16/group.png"},
		{SGLanguage.GetMessage("spawninfo_multi"),multi_url,"icon16/user_go.png"},
		{SGLanguage.GetMessage("spawninfo_fp"),StarGate.HTTP.FACEPUNCH,"icon16/transmit_blue.png"},
		{SGLanguage.GetMessage("spawninfo_donate"),StarGate.HTTP.DONATE,"icon16/money_add.png"},
	}

	for k,v in pairs(cats) do
		local panel = node:AddNode( v[1], v[3] );
		-- this code is buggy, can't understand why i can't enter data into textbox, so using steam browser instead.
		/*panel.DoPopulate = function(self)
			if ( self.PropPanel ) then return end
			self.PropPanel = vgui.Create("EditablePanel",pnlContent);
			self.PropPanel:Dock(FILL);
			self.PropPanel.Label = vgui.Create("DLabel",self.PropPanel);
			self.PropPanel.Label:SetText(SGLanguage.GetMessage("spawninfo_load"));
			self.PropPanel.Label:SetColor(Color(0,0,0,255));
			self.PropPanel.Label:SizeToContents();
			self.PropPanel.Paint = function(self,w,h)
				draw.RoundedBox(0,0,0,w,h,Color(255,255,255,255));
				self.Label:SetPos(w/2-10,h/2-10);
			end
			self.HTML = vgui.Create("DHTML",self.PropPanel);
			self.HTML:Dock(FILL);
			self.HTML:SetKeyBoardInputEnabled(true);
			self.HTML:SetMouseInputEnabled(true);
		end*/
		panel.DoClick = function( self )
			--self:DoPopulate()
			--self.HTML:OpenURL(v[2]);
			--pnlContent:SwitchPanel( self.PropPanel );
			gui.OpenURL(v[2]);
		end
	end

	-- Select the first node
	local FirstNode = tree:Root():GetChildNode( 0 )
	if ( IsValid( FirstNode ) ) then
		FirstNode:InternalDoClick()
	end

end )

local info_page = [[<html>
	<head>
		<style type='text/css'>
			* {margin: 0; padding: 0;}
			body {background-color: #1a1a1a; font-family: Verdana, Geneva, sans-serif; color: #e5e5e5;}
			a:link {text-decoration: underline; color: #fff;}
			a:visited {text-decoration: underline; color: #e5e5e5;}
			a:active {text-decoration: underline;}
			a:hover {text-decoration: underline; color: #fff;}
			#nav {padding: 8px 0; margin: 0; text-align: center; width: auto; border-top: 2px #fff solid; border-bottom: 2px #fff solid;}
			#nav li {display: inline-block; ist-style-type: none;}
			#nav a {text-decoration: none;}
			#article { margin: 0 auto; margin: 20px;}
			#article h2 {text-align: left; margin: 20px 0 20px 10px;}
			#article p {margin: 10px 10px 20px 20px;}
		</style>
		</head>
		<body>
            <ul id="nav">
                <li><a href="http://sg-carterpack.com/">Home</a> |</li>
                <li><a href="http://sg-carterpack.com/download/">Download</a> |</li>
                <li><a href="http://sg-carterpack.com/category/news/">News</a> |</li>
                <li><a href="http://sg-carterpack.com/wiki/">Wiki</a> |</li>
                <li><a href="http://sg-carterpack.com/forums/forum/support/">Support</a></li>
            </ul>
        <div id="article">
         <h2>Missing Addon: The Stargate Carter Addon Pack</h2>
    <p>
    You're currently playing on a server that makes use of the Carter Addon Pack that you currently do not have installed.<br>
    To play on this server with all the functions made possible by the Carter Addons Pack please continue reading for more information.
    </p>
    	<h2>Download Instructions</h2>
    <p>
    You can download The Stargate Carter Addon Pack directly from the workshop by subscribing to this collection: <a href="http://steamcommunity.com/sharedfiles/filedetails/?id=180077636">http://steamcommunity.com/sharedfiles/filedetails/?id=180077636</a>
    </p>
    <p>
    After subscribing and downloading all the items you should be able to make use of all the functions included in the Carter Addon Pack.
    </p>
    <p>
    For a full explenation on how to install this addon and its requirements please visit the <a href="http://sg-carterpack.com/download/">Download page on sg-carterpack.com</a>. This page will provide all the information required to download CAP completely through the Steam Workshop or Github.
    </p>
    	<h2>What is The Stargate Carter Addon Pack?</h2>
    <p>
    Stargate Carter Pack more commonly known as Carter's Addon Pack or CAP is an addon for Garry's mod that adds new content elements to the game, all based off the Stargate franchise from the 1995 film to the late Stargate Universe. Carter's Addon Pack gives the most impressive array of Stargate elements for Garry's Mod, allowing much more diversity &amp; variations for Stargate gameplay in Garry's Mod.
    </p>
    <p>
    CAP (Carter's Addon Pack) covers many themes found in Stargate, such as Lantean technology, Asgard technology and many others, without forgetting the devices and weapons found and seen in the Stargate shows, which often became deadly threats or powerful assets to the people of Stargate Command, Atlantis and Destiny.
    </p>
    <p>
    From piloting a starship to building bases, the Stargate Carter Pack provides players with great replayability, creativity, &amp; even devices for machines.
    </p>
    <p>
    Updates and news can be found on the CAP Homepage located here:<br><a href="http://sg-carterpack.com">http://sg-carterpack.com</a> <br>
    The Download page can be found with a full installation instruction here:<br><a href="http://sg-carterpack.com/download">http://sg-carterpack.com/download</a><br>
    More information can be found on the CAP WIKI located here:<br><a href="http://sg-carterpack.com/wiki">http://sg-carterpack.com/wiki</a><br>
    Having troubles or want to report a bug then visit our dedicated Forum:<br><a href="http://sg-carterpack.com/forum">http://sg-carterpack.com/forum</a>
    </p>
        </div>
	</body>
</html>]];

--################# Adds the tab to the spawnmenu @aVoN
function StarGate.Hook.AddToolTab()

	if(not StarGate.Installed or not StarGate.InstalledOnClient()) then
		local cat_name = "Stargate";
		spawnmenu.AddCreationTab(cat_name,function()
			local Frame = vgui.Create("EditablePanel");
			--Frame.Paint = function() end

			local HTML = vgui.Create("DHTML",Frame);
			local HTMLControls = vgui.Create("EditablePanel",Frame);
			HTMLControls:Dock(TOP);
			HTMLControls:SetHeight(36);

			local HomeButton = vgui.Create( "DImageButton", HTMLControls )
			HomeButton.HTML = HTML;
			HomeButton:SetSize( 32, 32 )
			HomeButton:SetMaterial( "gui/HTML/home" )
			HomeButton:Dock( LEFT )
			HomeButton:DockMargin( 0, 2, 0, 2 )
			HomeButton.DoClick = function(self) if (self.HTML) then self.HTML:SetHTML(info_page); end end

			HTML:SetKeyBoardInputEnabled(true);
			HTML:SetMouseInputEnabled(true);
			HTML:SetHTML(info_page);
			HTML:Dock(FILL);
			return Frame;
		end, "icon16/cog_delete.png", 60 )

		return
	end
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
		spawnmenu.AddToolMenuOption(cat_name,keys_name,"Daedalus"," "..SGLanguage.GetMessage("stool_key_daedalus"),"","",StarGate.DaedalusSettings);
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

--[[
	Pack Version (packversion.lua)
	Copyright (C) 2011 Madman07
]]--

function StarGate.Update_Check(Panel)
	local LAYOUT = SGLanguage.GetMessage("stargate_credits_01");
	local GREEN = Color(0,255,0,255);
	local ORANGE = Color(255,128,0,255);

	if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		-- VGUI:SetHelp("credits");
		VGUI:SetTopic(SGLanguage.GetMessage("stargate_credits_01"));
		VGUI:SetText(SGLanguage.GetMessage("stargate_credits_01"));
		VGUI:SetImage("icon16/star.png");
		VGUI:SetURL(StarGate.HTTP.CREDITS);
		Panel:AddPanel(VGUI);

		Panel:Help(SGLanguage.GetMessage("stargate_credits_02", StarGate.HTTP.BUGS));
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetTopic(SGLanguage.GetMessage("stargate_credits_13"));
		VGUI:SetText(SGLanguage.GetMessage("stargate_credits_13"));
		VGUI:SetImage("icon16/exclamation.png");
		VGUI:SetURL(StarGate.HTTP.BUGS);
		Panel:AddPanel(VGUI);

		local VGUImg = vgui.Create("DImage",Panel)
		VGUImg:SetSize(210,210);
		VGUImg:SetImage("gui/update_checker/cap");
		Panel:AddPanel(VGUImg);

		if (StarGate.LATEST_VERSION == 0) then
			Panel:Help(SGLanguage.GetMessage("stargate_credits_03")):SetTextColor(ORANGE);
		elseif (StarGate.CURRENT_VERSION == 0) then
			Panel:Help(SGLanguage.GetMessage("stargate_credits_04")):SetTextColor(ORANGE);
		elseif (StarGate.LATEST_VERSION == 0 and StarGate.CURRENT_VERSION == 0) then
			Panel:Help(SGLanguage.GetMessage("stargate_credits_01")):SetTextColor(ORANGE);
			Panel:Help(SGLanguage.GetMessage("stargate_credits_04")):SetTextColor(ORANGE);
		else
			local last_ver = StarGate.LATEST_VERSION;
			if (StarGate.WorkShop) then last_ver = tostring(math.floor(tonumber(last_ver))); end -- display "CAP Outdated" only if main version higher that subversion for workshop clients
			-- yes i know tonumber then tostring is ugly way
			-- Workshop users should NEVER receive "beta" updates from github, so no need to write "CAP Outdated" in this case
			if (not StarGate.CompareVersion(last_ver,StarGate.CURRENT_VERSION)) then
				Panel:Help(SGLanguage.GetMessage("stargate_credits_05").." "..StarGate.CURRENT_VERSION.." :)"):SetTextColor(GREEN);
				VGUImg:SetImage("gui/update_checker/cap_is")
			else
				Panel:Help(SGLanguage.GetMessage("stargate_credits_06", StarGate.CURRENT_VERSION, StarGate.LATEST_VERSION)):SetTextColor(ORANGE);
				Panel:Help(SGLanguage.GetMessage("stargate_credits_07"));
				VGUImg:SetImage("gui/update_checker/cap_not")
			end
		end

		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetText("www.sg-carterpack.com");
		VGUI:SetImage("icon16/star.png");
		VGUI:SetURL(StarGate.HTTP.SITE);
		Panel:AddPanel(VGUI);

		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetText("www.facepunch.com/threads/1162629");
		VGUI:SetImage("icon16/star.png");
		VGUI:SetURL(StarGate.HTTP.FACEPUNCH);
		Panel:AddPanel(VGUI);

	else
		local VGUImg = vgui.Create("DImage",Panel)
		VGUImg:SetSize(210,210);
		VGUImg:SetImage("gui/update_checker/cap");
		Panel:AddPanel(VGUImg);

		Panel:Help(SGLanguage.GetMessage("stargate_credits_08"));
		Panel:CheckBox(SGLanguage.GetMessage("stargate_credits_09"),"cl_has_internet"):SetToolTip(SGLanguage.GetMessage("stargate_credits_10"));
	end
	Panel:Help(SGLanguage.GetMessage("stargate_credits_14"));
	local VGUI = vgui.Create("SHelpButton",Panel);
	VGUI:SetText(SGLanguage.GetMessage("stargate_credits_15"));
	VGUI:SetImage("icon16/money_add.png");
	VGUI:SetURL(StarGate.HTTP.DONATE,true);
	Panel:AddPanel(VGUI);
	Panel:Help(SGLanguage.GetMessage("stargate_credits_11"));
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_credits_12"));
	Panel:Help("Creative Commons Attribution-NonCommercial-NoDerivs");
	Panel:Help("3.0 Unported License.");
end

function CAP_Outdated()
	local addons = GetAddonList(true);
	if (StarGate.HasInternet and StarGate.InstalledOnClient()) then
		local UpdateFrame = vgui.Create("DFrame");
		UpdateFrame:SetPos(ScrW()-540, 100);
		UpdateFrame:SetSize(440,130);
		UpdateFrame:SetTitle(SGLanguage.GetMessage("stargate_updater_01"));
		UpdateFrame:SetVisible(true);
		UpdateFrame:SetDraggable(true);
		UpdateFrame:ShowCloseButton(true);
		UpdateFrame:SetBackgroundBlur(false);
		UpdateFrame:MakePopup();
		UpdateFrame.Paint = function()

			// Thanks Overv, http://www.facepunch.com/threads/1041686-What-are-you-working-on-V4-John-Lua-Edition
			local matBlurScreen = Material( "pp/blurscreen" )

			// Background
			surface.SetMaterial( matBlurScreen )
			surface.SetDrawColor( 255, 255, 255, 255 )

			matBlurScreen:SetFloat( "$blur", 5 )
			render.UpdateScreenEffectTexture()

			surface.DrawTexturedRect( -ScrW()/10, -ScrH()/10, ScrW(), ScrH() )

			surface.SetDrawColor( 100, 100, 100, 150 )
			surface.DrawRect( 0, 0, ScrW(), ScrH() )

			// Border
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawOutlinedRect( 0, 0, UpdateFrame:GetWide(), UpdateFrame:GetTall() )

			draw.DrawText(SGLanguage.GetMessage("stargate_updater_02",StarGate.CURRENT_VERSION,StarGate.LATEST_VERSION).."\n"..SGLanguage.GetMessage("stargate_updater_03"), "ScoreboardText", 220, 30, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER);
		end;

		local close = vgui.Create("DButton", UpdateFrame);
		close:SetText(SGLanguage.GetMessage("stargate_updater_04"));
		close:SetPos(340, 95);
		close:SetSize(80, 25);
		close.DoClick = function (btn)
			UpdateFrame:Close();
		end


	end
end
concommand.Add("CAP_Outdated",CAP_Outdated)

--########################
-- cl_visualssettings.lua
--########################

function StarGate.MiscVisualSettings(Panel)
	local high = SGLanguage.GetMessage("vis_fps_high");
	local medium = SGLanguage.GetMessage("vis_fps_medium");
	local low = SGLanguage.GetMessage("vis_fps_low");

	Panel:ClearControls();
	-- The HELP Button
	/*if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end */
	-- Configuration
	local disable = {}
	local conf = Panel:CheckBox(SGLanguage.GetMessage("vis_title"),"cl_stargate_visualsmisc");
	conf:SetToolTip(SGLanguage.GetMessage("vis_title_desc"));
	conf.OnChange = function(self,val)
		for k,v in pairs(disable) do
			if (val) then
				v:SetDisabled(false);
			else
				v:SetDisabled(true);
			end
		end
	end
	Panel:Help("");
	-- Stargates
	table.insert(disable,Panel:Help(SGLanguage.GetMessage("stool_cat")));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"),"cl_stargate_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	if (file.Exists("materials/zup/stargate/effect_03.vmt","GAME")) then
		table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_ripple"),"cl_stargate_ripple"));
		table.GetLastValue(disable):SetToolTip(medium);
    end
    table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_kawoosh_eff"),"cl_stargate_kenter"));
    table.GetLastValue(disable):SetToolTip(low);
	Panel:CheckBox(SGLanguage.GetMessage("vis_kawoosh_mat"), "cl_kawoosh_material"):SetToolTip(SGLanguage.GetMessage("vis_kawoosh_mat_desc"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_stargate_eff"), "cl_stargate_effects"):SetToolTip(SGLanguage.GetMessage("vis_stargate_eff_desc",medium));
	-- Stargate Universe
	Panel:Help(SGLanguage.GetMessage("stargate_universe"));	
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"),"cl_stargate_un_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	-- SuperGate
	Panel:Help(SGLanguage.GetMessage("stargate_supergate"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_supergate_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	-- Shield
	Panel:Help(SGLanguage.GetMessage("stool_shield"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"),"cl_shield_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_shield_bubble"),"cl_shield_bubble"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_hit_refl"),"cl_shield_hitradius"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_hit_eff"),"cl_shield_hiteffect"));
	table.GetLastValue(disable):SetToolTip(low);
	-- Atl Shield
	Panel:Help(SGLanguage.GetMessage("vis_atl_shield"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_refl"), "cl_shieldcore_refract"));
	table.GetLastValue(disable):SetToolTip(SGLanguage.GetMessage("vis_refl_desc",low));
	-- Harvester
	Panel:Help(SGLanguage.GetMessage("stool_harvester"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"),"cl_harvester_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	-- Cloaking
	Panel:Help(SGLanguage.GetMessage("stool_cloak"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_cloak_pass"),"cl_cloaking_hitshader"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_cloak_eff"),"cl_cloaking_shader"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Apple Core
	Panel:Help(SGLanguage.GetMessage("entity_apple_core"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_applecore_light"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_smoke"), "cl_applecore_smoke"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Huds
	Panel:Help(SGLanguage.GetMessage("vis_hud_title"));
	Panel:CheckBox(SGLanguage.GetMessage("vis_hud_energy"), "cl_draw_huds"):SetToolTip(SGLanguage.GetMessage("vis_hud_energy_desc",low));
	Panel:CheckBox(SGLanguage.GetMessage("vis_dhd_glyphs"), "cl_dhd_letters"):SetToolTip(SGLanguage.GetMessage("vis_dhd_glyphs_desc",low));
end

function StarGate.ShipVisualSettings(Panel)
	local high = SGLanguage.GetMessage("vis_fps_high");
	local medium = SGLanguage.GetMessage("vis_fps_medium");
	local low = SGLanguage.GetMessage("vis_fps_low");

	Panel:ClearControls();
	-- The HELP Button
	/*if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end */
	-- Configuration
	local disable = {}
	local conf = Panel:CheckBox(SGLanguage.GetMessage("vis_title"),"cl_stargate_visualsship");
	conf:SetToolTip(SGLanguage.GetMessage("vis_title_desc"));
	conf.OnChange = function(self,val)
		for k,v in pairs(disable) do
			if (val) then
				v:SetDisabled(false);
			else
				v:SetDisabled(true);
			end
		end
	end
	Panel:Help("");
	-- Jumper
	Panel:Help(SGLanguage.GetMessage("entity_jumper"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_jumper_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_heatwave"), "cl_jumper_heatwave"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_sprites"), "cl_jumper_sprites"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- F302
	Panel:Help(SGLanguage.GetMessage("entity_f302"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_heatwave"), "cl_F302_heatwave"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_sprites"), "cl_F302_sprites"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Shuttle
	Panel:Help(SGLanguage.GetMessage("entity_dest_shuttle"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_heatwave"), "cl_shuttle_heatwave"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_sprites"), "cl_shuttle_sprites"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Wraith Dart
	Panel:Help(SGLanguage.GetMessage("entity_dart"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_heatwave"), "cl_dart_heatwave"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Control Chair
	Panel:Help(SGLanguage.GetMessage("entity_control_chair"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_chair_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
end

function StarGate.WeaponVisualSettings(Panel)
	local high = SGLanguage.GetMessage("vis_fps_high");
	local medium = SGLanguage.GetMessage("vis_fps_medium");
	local low = SGLanguage.GetMessage("vis_fps_low");

	Panel:ClearControls();
	-- The HELP Button
	/*if(StarGate.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("config/visual");
		VGUI:SetTopic("Help:  Visual Settings");
		Panel:AddPanel(VGUI);
	end */
	-- Configuration
	local disable = {}
	local conf = Panel:CheckBox(SGLanguage.GetMessage("vis_title"),"cl_stargate_visualsweapon");
	conf:SetToolTip(SGLanguage.GetMessage("vis_title_desc"));
	conf.OnChange = function(self,val)
		for k,v in pairs(disable) do
			if (val) then
				v:SetDisabled(false);
			else
				v:SetDisabled(true);
			end
		end
	end
	Panel:Help("");
	-- Staff Weapon and Dexgun
	Panel:Help(SGLanguage.GetMessage("vis_weap_title"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_hit_dyn_light"),"cl_staff_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_fly_dyn_light"),"cl_staff_dynlights_flight"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_smoke"),"cl_staff_smoke"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_wall"),"cl_staff_scorch"));
	table.GetLastValue(disable):SetToolTip(low);
	-- Zat'nik'tel
	Panel:Help(SGLanguage.GetMessage("weapon_zat"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"),"cl_zat_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_hit_eff"),"cl_zat_hiteffect"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_diss_eff"),"cl_zat_dissolveeffect"));
	table.GetLastValue(disable):SetToolTip(medium);
	-- Drones
	Panel:Help(SGLanguage.GetMessage("stool_drones"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_glow"),"cl_drone_glow"));
	table.GetLastValue(disable):SetToolTip(low);
	-- Naquadah Bomb
	Panel:Help(SGLanguage.GetMessage("stool_naq_bomb"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_sunbeams"), "cl_gate_nuke_sunbeams"));
	table.GetLastValue(disable):SetToolTip(SGLanguage.GetMessage("vis_sunbeams_desc",high));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_part_rings"), "cl_gate_nuke_rings"));
	table.GetLastValue(disable):SetToolTip(high);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_shield_part"), "cl_gate_nuke_shieldrings"));
	table.GetLastValue(disable):SetToolTip(SGLanguage.GetMessage("vis_shield_part_desc",high));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_plasma"), "cl_gate_nuke_plasma"));
	table.GetLastValue(disable):SetToolTip(SGLanguage.GetMessage("vis_plasma_desc",low));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_plasma_light"), "cl_gate_nuke_dynlights"));
	table.GetLastValue(disable):SetToolTip(SGLanguage.GetMessage("vis_plasma_desc",medium));
	-- Stargate Overloader
	Panel:Help(SGLanguage.GetMessage("entity_overloader"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_refl_rings"), "cl_overloader_refract"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_part_rings"), "cl_overloader_particle"));
	table.GetLastValue(disable):SetToolTip(medium);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_overloader_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	-- Asuran Gun
	Panel:Help(SGLanguage.GetMessage("entity_asuran_weapon"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_sm_laser"), "cl_asuran_laser"));
	table.GetLastValue(disable):SetToolTip(low);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_dyn_light"), "cl_asuran_dynlights"));
	table.GetLastValue(disable):SetToolTip(high);
	-- Dakara Super Weapon
	Panel:Help(SGLanguage.GetMessage("entity_dakara"));
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_charge_up"), "cl_dakara_rings"));
	table.GetLastValue(disable):SetToolTip(low);
	table.insert(disable,Panel:CheckBox(SGLanguage.GetMessage("vis_refl_sphere"), "cl_dakara_refract"));
	table.GetLastValue(disable):SetToolTip(medium);
end

/*
function CAP_NotLegal()
	if StarGate.HasInternet then
		local LegalFrame = vgui.Create("DFrame");
		LegalFrame:SetPos(100, 100);
		LegalFrame:SetSize(400,150);
		LegalFrame:SetTitle("Cap Legality Checker");
		LegalFrame:SetVisible(true);
		LegalFrame:SetDraggable(false);
		LegalFrame:ShowCloseButton(false);
		LegalFrame:SetBackgroundBlur(false);
		LegalFrame:MakePopup();
		LegalFrame.Paint = function()

			// Thanks Overv, http://www.facepunch.com/threads/1041686-What-are-you-working-on-V4-John-Lua-Edition
			local matBlurScreen = Material( "pp/blurscreen" )

			// Background
			surface.SetMaterial( matBlurScreen )
			surface.SetDrawColor( 255, 255, 255, 255 )

			matBlurScreen:SetFloat( "$blur", 5 )
			render.UpdateScreenEffectTexture()

			surface.DrawTexturedRect( -ScrW()/10, -ScrH()/10, ScrW(), ScrH() )

			surface.SetDrawColor( 100, 100, 100, 150 )
			surface.DrawRect( 0, 0, ScrW(), ScrH() )

			// Border
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawOutlinedRect( 0, 0, LegalFrame:GetWide(), LegalFrame:GetTall() )

			draw.DrawText("An error occured. If your Steam profile is private, please\nturn it to Public mode in order to use Carter Addon Pack.\nIf your copy of Garry's Mod is illegal, your Steam ID will be\nreported. Please buy a legal copy of Garry's Mod.", "ScoreboardText", 200, 30, Color(255, 255, 255, 255),TEXT_ALIGN_CENTER);
		end;

		LegalFrame.Count = RealTime()+15;

		local close = vgui.Create("DButton", LegalFrame);
		close:SetText("15");
		close:SetPos(300, 115);
		close:SetSize(80, 25);
		close.DoClick = function (btn)
			local rel = LegalFrame.Count - RealTime();
			if (rel < 0) then LegalFrame:Close(); end
		end

		function LegalFrame:Think()
			local rel = LegalFrame.Count - RealTime();
			if (rel > 0) then close:SetText(Format("Wait %i sec.", rel));
			else close:SetText("Close"); end
		end

	end
end
concommand.Add("CAP_NotLegal",CAP_NotLegal)*/

--##############
-- settings.lua
--##############

/*
	Created by AlexALX (c) 2012
	Small settings tab
	For some functions what come from my addon
*/

function StarGate_Settings(Panel)
	local LAYOUT = "Convars/Limits/Language";
	local GREEN = Color(0,255,0,255);
	local ORANGE = Color(255,128,0,255);
	local RED = Color(255,0,0,255);
	local DGREEN = Color(0,182,0,255);

	if (LocalPlayer():IsAdmin()) then
		local convarsmenu = vgui.Create("DButton", Panel);
	    convarsmenu:SetText(SGLanguage.GetMessage("stargate_settings_01"));
	    convarsmenu:SetSize(150, 25);
	    convarsmenu:SetImage("icon16/wrench.png");
		convarsmenu.DoClick = function ( btn )
			RunConsoleCommand("stargate_settings");
		end
		Panel:AddPanel(convarsmenu);
	end
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_settings_06")):SetTextColor(DGREEN);
	local clientlang = vgui.Create("DMultiChoice",Panel);
	clientlang:SetSize(50,20);
	local lg = SGLanguage.GetLanguageName(SGLanguage.GetClientLanguage());
	if (lg!="Error") then
		clientlang:SetText(lg);
	else
		clientlang:SetText(SGLanguage.GetClientLanguage());
	end
	clientlang.TextEntry:SetTooltip(SGLanguage.GetMessage("stargate_settings_07"));
	clientlang.TextEntry.OnTextChanged = function(TextEntry)
		local pos = TextEntry:GetCaretPos();
		local text = TextEntry:GetValue();
		local len = text:len();
		local letters = text:lower():gsub("[^a-z-]",""); -- Lower, remove invalid chars and split!
		TextEntry:SetText(letters);
		TextEntry:SetCaretPos(math.Clamp(pos - (len-letters:len()),0,text:len())); -- Reset the caretpos!
		timer.Remove("SG.lang_check");
		timer.Create("SG.lang_check",0.4,1,function()
			local lg = SGLanguage.GetLanguageName(letters);
			if (IsValid(TextEntry) and lg!="Error") then
				TextEntry:SetText(lg);
				TextEntry:SetCaretPos(lg:len()); -- Reset the caretpos!
			end
			if (letters!="") then SGLanguage.SetClientLanguage(letters); end
		end)
	end
	clientlang.OnSelect = function(panel,index,value)
		if (value!="") then
			local lg = SGLanguage.GetLanguageFromName(value);
			SGLanguage.SetClientLanguage(lg);
		end
	end
	-- add exists languages
	local _,langs = file.Find("lua/data/language/*","GAME");
	local en_count,en_msgs = SGLanguage.CountMessagesInLanguage("en",true);
	local lng_arr = {}
	for i,lang in pairs(langs) do
		local count,msgs = SGLanguage.CountMessagesInLanguage(lang,true);
		if (lang!="en"/* and (not msgs["global_lang_similar"] or msgs["global_lang_similar"]=="false")*/) then
			for k,v in pairs(msgs) do
				if (not en_msgs[k]/* or v==en_msgs[k]*/) then count = count-1; end -- stop cheating!
			end
		end
		count = math.Round(count*100/en_count);
		lng_arr[lang] = {SGLanguage.GetLanguageName(lang),count};
		clientlang:AddChoice(SGLanguage.GetLanguageName(lang));
	end
	Panel:AddPanel(clientlang);
	Panel:Help(SGLanguage.GetMessage("stargate_settings_07"));
	Panel:Help(SGLanguage.GetMessage("stargate_settings_03")):SetTextColor(DGREEN);
	local VGUI = vgui.Create("DPanel");
	VGUI:SetBackgroundColor(Color(120,120,120));
	local i = 5;
	for k,v in SortedPairs(lng_arr) do
		local count = v[2];
		local col = HSVToColor((count/100)*120,1,0.9);
		local p = vgui.Create("DLabel",VGUI);
		p:SetPos(10,i);
		p:SetText(v[1].." ("..k..") - "..count.."%");
		p:SetSize(150,15);
		p:SetAutoStretchVertical(true);
		p:SetTextColor(col);
		p:SetTall(10);
		p:DockMargin(0,0,0,0);
		i = i+15;
	end
	VGUI:SetSize(150,i+5);
	Panel:AddPanel(VGUI);
	Panel:Help(SGLanguage.GetMessage("stargate_settings_04"));
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_settings_05"));
	local VGUI = vgui.Create("DButton");
	VGUI:SetText(SGLanguage.GetMessage("stargate_settings_02"));
	VGUI:SetImage("icon16/group.png");
	VGUI:SetSize(150, 25);
	VGUI.DoClick = function()
		local help = vgui.Create("SHTMLHelp");
		help:SetURL("http://sg-carterpack.com/wiki/doc/how-to-translate-cap/");
		help:SetText(SGLanguage.GetMessage("stargate_settings_02t"));
		help:SetVisible(true);
	end
	Panel:AddPanel(VGUI);
	Panel:Help("");
	Panel:Help(SGLanguage.GetMessage("stargate_settings_08"));
	Panel:Help(SGLanguage.GetMessage("stargate_settings_09"));

end