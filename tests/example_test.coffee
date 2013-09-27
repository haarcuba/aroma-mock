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

	test_Calls_Jquery: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect( new Expectation( '$.getJSON', [ 'www.google.com', {a:1, b:2}, new SaveArguement( 'doneCallback' ) ], null ) )

		tested.getSomeJSON()
		scenario.end()

		SaveArguement.saved( 'doneCallback' )()

test = new ExampleTest()
test.run()
