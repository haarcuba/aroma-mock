argumentexpectations = require 'argumentexpectations'

class Expectation
	constructor: ( path, argumentExpectations, result ) ->
		@_path = path
		@_argumentExpectations = []
		for expectation in argumentExpectations
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
		index = 0
		for expectation in @_argumentExpectations
			arg = args[ index ]
			if not expectation.ok( arg )
				return false
			index += 1
		return true

	string: =>
		result = "#{@_path}("
		for expectation in @_argumentExpectations
			result += expectation.string() + ", "
		result += ")"
		return result

exports.Expectation = Expectation
