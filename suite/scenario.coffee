class Scenario
	@_current = null
	@current: =>
		if @_current == null
			throw "No Scenario!"
		@_current

	constructor: ->
		@_expectations = []
		Scenario._current = this

	resultFor: ( method, args ) =>
		if @_expectations.length == 0
			throw "unexpected call #{method.string()}(#{args}), expected nothing"
		expectation = @_expectations.shift()
		if not expectation.ok( method, args )
			throw "unexpected call #{method.string()}(#{args}) expected #{expectation.string()}"
		return expectation.result()

	expect: ( call ) =>
		@_expectations.push( call )

	end: =>
		Scenario._current = null
		if @_expectations.length > 0
			console.log( 'pending expectations:' )
			for e in @_expectations
				console.log( "\t#{e.string()}" )
			throw 'not all expectations were met'

exports.Scenario = Scenario
exports.scenario = -> Scenario.current()
