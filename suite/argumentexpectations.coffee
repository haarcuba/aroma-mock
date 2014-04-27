require 'sugar'

class ArgumentExpectation
	constructor: ->
		@__argumentExpection = true

	ok: ( value ) =>
		throw "must override this method"

class Equals extends ArgumentExpectation
	constructor: ( expected ) ->
		@_expected = expected
		super()
	
	ok: ( value ) =>
		Object.equal( @_expected, value )

	toString: =>
		result = "#{@_expected}"
		if result == "[object Object]"
			result = this._listObject( @_expected )
		return result

	_listObject: ( object ) =>
		result = '{'
		for key, value of object
			result += "#{key}: #{value}, "
		result += '}'
		result
			
class SaveArgument extends ArgumentExpectation
	@_saved = {}
	constructor: ( saveName ) ->
		@_saveName = saveName
		super()

	ok: ( value ) =>
		SaveArgument._saved[ @_saveName ] = value
		return true

	toString: =>
		"<SAVE:#{@_saveName}>"

	@saved: ( name ) =>
		SaveArgument._saved[ name ]

class IgnoreArgument extends ArgumentExpectation
	ok: ( value ) =>
		true

	toString: =>
		"|IGNORE|"

exports.ArgumentExpectation = ArgumentExpectation
exports.Equals = Equals
exports.SaveArgument = SaveArgument
exports.IgnoreArgument = IgnoreArgument
