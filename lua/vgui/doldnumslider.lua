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

function PANEL:UpdateNotches()

	local range = self:GetRange()
	self.Slider:SetNotches( nil )

	if ( range < self:GetWide() / 4 ) then
		return self.Slider:SetNotches( range )
	else
		self.Slider:SetNotches( self:GetWide() / 4 )
	end

end

function PANEL:GetRange()
	return self:GetMax() - self:GetMin()
end

function PANEL:GetMin()
	return self.Wang:GetMin()
end

function PANEL:GetMax()
	return self.Wang:GetMax()
end

/*---------------------------------------------------------
	SetMinMax
---------------------------------------------------------*/
function PANEL:SetMinMax( min, max )
	self.Wang:SetMinMax( min, max )
	self:UpdateNotches()
end

/*---------------------------------------------------------
	SetMin
---------------------------------------------------------*/
function PANEL:SetMin( min )
	self.Wang:SetMin( min )
	self:UpdateNotches()
end

/*---------------------------------------------------------
	SetMax
---------------------------------------------------------*/
function PANEL:SetMax( max )
	self.Wang:SetMax( max )
	self:UpdateNotches()
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
