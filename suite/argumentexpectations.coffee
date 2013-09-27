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

	string: =>
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
			
class SaveArguement extends ArgumentExpectation
	@_saved = {}
	constructor: ( saveName ) ->
		@_saveName = saveName
		super()

	ok: ( value ) =>
		SaveArguement._saved[ @_saveName ] = value
		return true

	string: =>
		"<SAVE:#{@_saveName}>"

	@saved: ( name ) =>
		SaveArguement._saved[ name ]

exports.Equals = Equals
exports.SaveArguement = SaveArguement
