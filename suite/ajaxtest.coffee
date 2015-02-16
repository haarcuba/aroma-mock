class AjaxTest
	constructor: ( scenario ) ->
		scenario.expect call( '$.ajax', [ new SaveArgument( 'actualAjaxArgs' ) ], null )

	successExpectations: ( successExpectations ) =>

	expect: ( expected ) =>
		@_expectedArguments = expected
		throw '``success" should not be in expectedAjaxArguments' if expected.success?
		throw '``error" should not be in expectedAjaxArguments' if expected.error?

	returnFromServer: ( data ) =>
		@_dataFromServer = data

	errorFromServer: ( jqXHR, textStatus, errorThrown ) =>
		@_errorFromServer = [ jqXHR, textStatus, errorThrown ]

	verify: ( result ) =>
		actualAjaxArgs = SaveArgument.saved( 'actualAjaxArgs' )
		this._verifyAjaxArguments( actualAjaxArgs )
		if result == 'success'
			this.onSuccessScenario()
			actualAjaxArgs.success( @_dataFromServer )
		else if result == 'error'
			this.onErrorScenario()
			[ jqXHR, textStatus, errorThrown ] = @_errorFromServer
			actualAjaxArgs.error( jqXHR, textStatus, errorThrown )

	_verifyAjaxArguments: ( actualAjaxArgs ) =>
		for key, value of @_expectedArguments
			if not Object.equal value, actualAjaxArgs[ key ]
				throw "failed to verify ajax arguments!"

exports.AjaxTest = AjaxTest
