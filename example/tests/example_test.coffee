require 'globals'
example = require 'example/example'

fakeGlobal( '$', [ 'getJSON' ] )
fakeGlobal( 'Point', [] )

class ExampleTest extends Suite
	test_Addition: =>
		tested = new example.Example()
		assertions.equal 5, tested.add( 3, 2 )

	test_Multiplication: =>
		tested = new example.Example()
		assertions.equal 6, tested.mul( 3, 2 )

	test_GetJSONWithJQuery: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( '$.getJSON', [ 'www.google.com', {a:1, b:2}, new SaveArgument( 'doneCallback' ) ], null )

		tested.getSomeJSON()
		scenario.end()

		capturedCallback = SaveArgument.saved( 'doneCallback' )
		capturedCallback()

	test_UseJQueryOnDOM: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( '$', [ "#input_element" ], fakeObject( 'element', ['val'] ) )
		scenario.expect call( 'element.val', [ '123' ], null )
		tested.useJQueryOnDOM( '123' )
		scenario.end()

	test_JQuerySelectorExpectation: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect_$( '#input_element', 'val', [ '456' ], null )
		tested.useJQueryOnDOM( '456' )
		scenario.end()

	test_ExpectArguemntToBeNull: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( '$', [ null ], null )
		tested.callJQueryWithNull()
		scenario.end()

	test_ExpectCallbackToUse_$_With_this: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect_$( '#product', 'on', [ 'change', new SaveArgument( "productChangeCallback" ) ], null )
		scenario.expect_$( THIS, 'val', [], 123 )
		tested.registerCallbackForProductChange()
		callback = SaveArgument.saved( "productChangeCallback" )
		callback.apply( THIS )
		assertions.equal( 123, tested.lastProductChanged() )
		scenario.end()

	test_FakeClass: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( 'Point', [ 5, 4 ], fakeObject( 'aPoint', [ 'show' ] ) )
		scenario.expect call( 'aPoint.show', [], null )
		tested.instantiatePoint()
		scenario.end()
		
test = new ExampleTest()
test.run()
