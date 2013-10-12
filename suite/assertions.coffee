assertionError = ( message ) ->
	throw "AssertionError: #{message}"

equal = ( a, b ) ->
	if not Object.equal( a, b )
		assertionError( "#{a} != #{b}" )

exports.equal = equal
