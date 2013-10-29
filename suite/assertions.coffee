assertionError = ( message ) ->
	throw "AssertionError: #{message}"

equal = ( expected, actual ) ->
	if not Object.equal( expected, actual )
		assertionError( "#{expected} (expected) != #{actual} (actual)" )

exports.equal = equal
