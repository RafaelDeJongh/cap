/*   _
    ( )
   _| |   __   _ __   ___ ___     _ _
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_)

	DNumberWang

*/

local font = {
	font = "Default",
	size = 13,
	weight = 400,
	antialias = true,
	additive = false,
}
surface.CreateFont("OldDefaultSmall", font);

local PANEL = {}

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:Init()

	self.Wang = vgui.Create ( "DNumberWang", self )
	self.Wang.OnValueChanged = function( wang, val ) self:ValueChanged( val ) end

	self.Slider = vgui.Create( "DSlider", self )
	self.Slider:SetLockY( 0.5 )
	self.Slider.TranslateValues = function( slider, x, y ) return self:TranslateSliderValues( x, y ) end
	self.Slider:SetTrapInside( true )
	self.Slider:SetImage( "vgui/slider" )
	Derma_Hook( self.Slider, "Paint", "Paint", "NumSlider" )

	self.Label = vgui.Create ( "DLabel", self )
	self.Label:SetFont("OldDefaultSmall");

	self:SetTall( 35 )

end

/*---------------------------------------------------------
	SetMinMax
---------------------------------------------------------*/
function PANEL:SetMinMax( min, max )
	self.Wang:SetMinMax( min, max )
end

/*---------------------------------------------------------
	SetMin
---------------------------------------------------------*/
function PANEL:SetMin( min )
	self.Wang:SetMin( min )
end

/*---------------------------------------------------------
	SetMax
---------------------------------------------------------*/
function PANEL:SetMax( max )
	self.Wang:SetMax( max )
end

/*---------------------------------------------------------
   Name: SetConVar
---------------------------------------------------------*/
function PANEL:SetValue( val )
	self.Wang:SetValue( val )
end

/*---------------------------------------------------------
   Name: GetValue
---------------------------------------------------------*/
function PANEL:GetValue()
	return self.Wang:GetValue()
end

/*---------------------------------------------------------
   Name: SetDecimals
---------------------------------------------------------*/
function PANEL:SetDecimals( d )
	return self.Wang:SetDecimals( d )
end

/*---------------------------------------------------------
   Name: GetDecimals
---------------------------------------------------------*/
function PANEL:GetDecimals()
	return self.Wang:GetDecimals()
end


/*---------------------------------------------------------
   Name: SetConVar
---------------------------------------------------------*/
function PANEL:SetConVar( cvar )
	self.Wang:SetConVar( cvar )
end

/*---------------------------------------------------------
   Name: SetText
---------------------------------------------------------*/
function PANEL:SetText( text )
	self.Label:SetText( text )
end

/*---------------------------------------------------------
   Name:
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.Wang:SizeToContents()
	self.Wang:SetPos( self:GetWide() - self.Wang:GetWide(), 0 )
	self.Wang:SetTall( 20 )

	self.Label:SetPos( 0, 0 )
	self.Label:SetSize( self:GetWide(), 20 )

	self.Slider:SetPos( 0, 22 )
	self.Slider:SetSize( self:GetWide(), 13 )

	self.Slider:SetSlideX( self.Wang:GetFraction() )

end

/*---------------------------------------------------------
   Name: ValueChanged
---------------------------------------------------------*/
function PANEL:ValueChanged( val )

	self.Slider:SetSlideX( self.Wang:GetFraction( val ) )
	self:OnValueChanged( val )

end

/*---------------------------------------------------------
   Name: OnValueChanged
---------------------------------------------------------*/
function PANEL:OnValueChanged( val )


	// For override

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:TranslateSliderValues( x, y )

	self.Wang:SetFraction( x )

	return self.Wang:GetFraction(), y

end

/*---------------------------------------------------------
   Name: GetTextArea
---------------------------------------------------------*/
function PANEL:GetTextArea()

	return self.Wang:GetTextArea()

end

/*---------------------------------------------------------
   Name: GenerateExample
---------------------------------------------------------*/
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
		ctrl:SetWide( 200 )
		ctrl:SetText( "Example Slider!" )

	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DOldNumSlider", "Menu Option Line", table.Copy(PANEL), "Panel" )


// No example for this fella
PANEL.GenerateExample = nil

/*---------------------------------------------------------
   Name:
---------------------------------------------------------*/
function PANEL:PostMessage( name, _, val )

	if ( name == "SetInteger" ) then
		if ( val == "1" ) then
			self:SetDecimals( 0 )
		else
			self:SetDecimals( 2 )
		end
	end

	if ( name == "SetLower" ) then
		self:SetMin( tonumber(val) )
	end

	if ( name == "SetHigher" ) then
		self:SetMax( tonumber(val) )
	end

	if ( name == "SetValue" ) then
		self:SetValue( tonumber( val ) )
	end

end

/*---------------------------------------------------------
   Name:
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self.Wang:SetVisible( false )
	self.Label:SetVisible( false )

	self.Slider:StretchToParent(0,0,0,0)
	self.Slider:SetSlideX( self.Wang:GetFraction() )

end

/*---------------------------------------------------------
   Name:
---------------------------------------------------------*/
function PANEL:SetActionFunction( func )

	self.OnValueChanged = function( self, val ) func( self, "SliderMoved", val, 0 ) end

end


// Compat
derma.DefineControl( "Slider", "Backwards Compatibility", PANEL, "Panel" )
