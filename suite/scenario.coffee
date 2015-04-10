class Scenario
    @_current = null
    @current: =>
        if @_current == null
            throw "No Scenario!"
        @_current

    constructor: ( verbose = false ) ->
        @_verbose = verbose
        @_expectations = []
        Scenario._current = this

    resultFor: ( method, args ) =>
        if @_verbose
            console.log "scenario call #{method}(#{args})"
        if @_expectations.length == 0
            throw "unexpected call #{method}(#{args}), expected nothing"
        expectation = @_expectations.shift()
        if not expectation.ok( method, args )
            throw "unexpected call #{method}(#{args}) expected #{expectation}"
        result = expectation.result()
        while  @_expectations.length > 0 and @_expectations[ 0 ].__hook?
            hook = @_expectations.shift()
            hook.execute()
        return result

    expect: ( call ) =>
        @_expectations.push( call )

    expectCascade: ( cascade ) =>
        last = cascade.pop()
        cascade.forEach ( expectation ) =>
            this.expect expectation
            hook = ->
                func = SaveArgument.exposeSaved()[ expectation.name ]
                func.apply( null, expectation.passAlong )
            this.hook( hook )

        this.expect last

    hook: ( call ) =>
        wrapper = { execute: call, __hook: true }
        @_expectations.push( wrapper )

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
