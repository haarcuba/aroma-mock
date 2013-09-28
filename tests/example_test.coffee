require 'globals'
assert = require 'assert'
example = require 'example/example'

fakeGlobal( '$', [ 'getJSON' ] )

class ExampleTest extends Suite
	test_Addition: =>
		tested = new example.Example()
		assert.equal 5, tested.add( 3, 2 )

	test_Multiplication: =>
		tested = new example.Example()
		assert.equal 6, tested.mul( 3, 2 )

	test_GetJSONWithJQuery: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( '$.getJSON', [ 'www.google.com', {a:1, b:2}, new SaveArguement( 'doneCallback' ) ], null )

		tested.getSomeJSON()
		scenario.end()

		SaveArguement.saved( 'doneCallback' )()

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
		expectJQuery scenario, '#input_element', 'val', [ '456' ], null
		tested.useJQueryOnDOM( '456' )
		scenario.end()

test = new ExampleTest()
test.run()
