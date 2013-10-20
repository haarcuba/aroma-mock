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
			throw "unexpected call #{method}(#{args}), expected nothing"
		expectation = @_expectations.shift()
		if not expectation.ok( method, args )
			throw "unexpected call #{method}(#{args}) expected #{expectation}"
		return expectation.result()

	expect: ( call ) =>
		@_expectations.push( call )

	expect_$: ( selector, method, argumentExpectations, result ) =>
		idForMiddleMan = "#{Math.random().toString()[ 2..4 ]}_$(#{selector})"
		this.expect call( '$', [ selector ], fakeObject( idForMiddleMan, [ method ] ) )
		this.expect call( "#{idForMiddleMan}.#{method}", argumentExpectations, result )

	end: =>
		Scenario._current = null
		if @_expectations.length > 0
			console.log( 'pending expectations:' )
			for e in @_expectations
				console.log( "\t#{e}" )
			throw 'not all expectations were met'

exports.Scenario = Scenario
exports.scenario = -> Scenario.current()
