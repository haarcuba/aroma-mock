asyncAjaxScenario = ( scenario, expectedAjaxArguments, ajaxIssuer, dataFromServer, onSuccessScenario ) ->
	throw '``success" should not be in expectedAjaxArguments' if expectedAjaxArguments.success?
	scenario.expect call( '$.ajax', [ new SaveArgument( 'actualAjaxArgs' ) ], null )
	ajaxIssuer()
	actualAjaxArgs = SaveArgument.saved( 'actualAjaxArgs' )
	for key, value of expectedAjaxArguments
		assertions.equal value, actualAjaxArgs[ key ]
	onSuccessScenario( scenario )
	actualAjaxArgs.success( dataFromServer )

exports.asyncAjaxScenario = asyncAjaxScenario