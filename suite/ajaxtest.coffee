class AjaxTest
	constructor: ( scenario ) ->
		scenario.expect call( '$.ajax', [ new SaveArgument( 'actualAjaxArgs' ) ], null )

	successExpectations: ( successExpectations ) =>

	expect: ( expected ) =>
		@_expectedArguments = expected
		throw '``success" should not be in expectedAjaxArguments' if expected.success?

	returnFromServer: ( data ) =>
		@_dataFromServer = data

	verify: =>
		actualAjaxArgs = SaveArgument.saved( 'actualAjaxArgs' )
		this._verifyAjaxArguments( actualAjaxArgs )
		this.onSuccess()
		actualAjaxArgs.success( @_dataFromServer )

	_verifyAjaxArguments: ( actualAjaxArgs ) =>
		for key, value of @_expectedArguments
			if not Object.equal value, actualAjaxArgs[ key ]
				throw "failed to verify ajax arguments!"

exports.AjaxTest = AjaxTest
