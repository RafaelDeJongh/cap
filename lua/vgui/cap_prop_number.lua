
--
-- prop_generic is the base for all other properties.
-- All the business should be done in :Setup using inline functions.
-- So when you derive from this class - you should ideally only override Setup.
--

local PANEL = {}

function PANEL:Setup( vars )

	self:Clear()

	local text = self:Add( "DTextEntry" )
	text:SetUpdateOnType( true )
	text:SetDrawBackground( false )
	text:Dock( FILL )
	text:SetNumeric(true)
	self.TextEntry = text;

	-- Return true if we're editing
	self.IsEditing = function( self )
		return text:IsEditing()
	end

	-- Set the value
	self.SetValue = function( self, val )
		text:SetText( util.TypeToString( val ) )
	end

	-- Alert row that value changed
	text.OnValueChange = function( text, newval )

		self:ValueChanged( newval )

	end

end

derma.DefineControl( "DProperty_CapNumber", "", PANEL, "DProperty_Generic" )