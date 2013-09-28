scenario = require 'scenario'

class FakeObject
	constructor: ( path, methods ) ->
		@_path = path
		@_methods = methods

	callable:  =>
		self = this
		result = (args...) ->
			return scenario.scenario().resultFor( self, args )
		for method in @_methods
			methodObject = new FakeObject( "#{@_path}.#{method}", [] )
			result[ method ] = methodObject.callable()
		result

	path: =>
		@_path

	string: =>
		@_path

fakeObject = ( path, methods = null ) ->
	if methods == null
		methods = []
	new FakeObject( path, methods ).callable()

exports.fakeObject = fakeObject
