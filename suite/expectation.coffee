argumentexpectations = require './argumentexpectations'

class Call
    constructor: ( path, argumentExpectations, result ) ->
        @_path = path
        @_argumentExpectations = []
        for expectation in argumentExpectations
            if expectation == null
                expectation = new argumentexpectations.Equals( null )
            if expectation[ '__argumentExpection' ]?
                @_argumentExpectations.push( expectation )
            else
                @_argumentExpectations.push( new argumentexpectations.Equals( expectation ) )
        @_result = result

    result: =>
        @_result

    ok: ( method, args ) =>
        if method.path() != @_path
            return false
        if args.length != @_argumentExpectations.length
            return false
        this._verifyArgumentExpectations( args )

    _verifyArgumentExpectations: ( args ) =>
        index = 0
        for expectation in @_argumentExpectations
            arg = args[ index ]
            if not expectation.ok( arg )
                return false
            index += 1
        return true

    toString: =>
        expectationStrings = (e.toString() for e in @_argumentExpectations)
        result = "#{@_path}(#{expectationStrings.join(',')})"

class Cascade extends Call
    @_counter = 0

    constructor: ( path, argumentExpectations, result, passAlong ) ->
        this.name = Cascade._automaticName()
        argumentExpectations.push( new SaveArgument( this.name ) )
        super( path, argumentExpectations, result )
        this.passAlong = passAlong

    @_automaticName: =>
        ++ @_counter
        "AUTONAME_#{@_counter}"


exports.Call = Call
exports.Cascade = Cascade
