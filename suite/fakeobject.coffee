scenario = require 'scenario'

class Method
	constructor: ( fakeObject, name ) ->
		@fakeObject = fakeObject
		@name = name

	callable:  =>
		self = this
		return (args...) ->
			return scenario.scenario().resultFor( self, args )

	path: =>
		return "#{@fakeObject.path}.#{@name}"

	string: =>
		this.path()

class FakeObject
	constructor: ( path, methods ) ->
		@path = path
		for method in methods
			self = this
			methodObject = new Method( this, method )
			this[ method ] = methodObject.callable()

exports.FakeObject = FakeObject
