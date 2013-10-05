# Aroma - Unit testing for Coffee Script

Aroma is a Coffee Script unit test suite. It is designed to work directly with CoffeeScript sources, and provides a useful scenario-expectations construct and easy, on the fly mock object generation.

The scenario verifies the exact expected function call sequence including the function arguments. Scenarios are specified before the code is run, making the tests well organized, readable and more explicit. 

Original concepts were carried over from Voodoo-Mock, a C++/Python unit test framework.

## Trivial Example
Here's a trivial test suite, that doens't use any mocking:


```coffeescript
class CalculatorTest extends Suite
	test_Addition: =>
		tested = new calculator.Calculator()
		assertions.equal 5, tested.add( 3, 2 )

new CalculatorTest.run() # don't forget this :)
```

## Interesting Example
Here's a more interesting example test, that mocks the jQuery $ symbol and tests that it is used as expected. 
The `call` expectation: 

	call( '$', [ "#input_element" ], fakeObject( 'element', ['val'] ) )

expresses our expectation that the tested code will call `$` with `"#input_element"` as its first argument. We also arrange that
the return value of this call will be a Mock Object called `element`.
We *then* expect that this `element` object's `val` method will be called with the expectation:

	call( 'element.val', [ '123' ], null )

Since we don't care about the return value from this call, we used `null`.

Since JQuery expectations are commonplace, we can use a the shorthand `expect_$` for this 2-call expectation - this is demonstrated below.
	

I hope this makes the following, complete listing, clear.


```coffeescript
require 'globals' # import the Aroma test suite
example = require 'example/example' # import the tested unit

fakeGlobal( '$', [ 'getJSON' ] ) # make a mock $ accessible in the tested unit 
# we also mock the getJSON method on the $ object, since we will want to use it later for expectations

class ExampleTest extends Suite
	# this test expects the useJQueryOnDOM method to call jQuery with a selector, 
	# and then call the 'val' method on the result, so two expectations overall.
	test_UseJQueryOnDOM: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( '$', [ "#input_element" ], fakeObject( 'element', ['val'] ) )
		scenario.expect call( 'element.val', [ '123' ], null )
		tested.useJQueryOnDOM( '123' )
		scenario.end()

	# this is actually the same test as before, but uses the expect_$ shorthand
	test_JQuerySelectorExpectation: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect_$( '#input_element', 'val', [ '456' ], null )
		tested.useJQueryOnDOM( '456' )
		scenario.end()

	# this tests getJSON, captures the callback passed to it, and then calls it
	test_GetJSONWithJQuery: =>
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( '$.getJSON', [ 'www.google.com', {a:1, b:2}, new SaveArguement( 'doneCallback' ) ], null )

		tested.getSomeJSON()
		scenario.end()

		capturedCallback = SaveArguement.saved( 'doneCallback' )
		capturedCallback()

new ExampleTest.run() # don't forget this :)
```

here's the code that passes this test:
```coffeescript
class Example
	useJQueryOnDOM: ( text ) =>
		$("#input_element").val( text )

	getSomeJSON: =>
		$.getJSON 'www.google.com', {a:1,b:2}, this._mycallback

	_mycallback: =>
		console.log( 'my callback called!' )

exports.Example = Example
```

## Prerequisites
Aroma relies on CoffeeScript and Node.js to be installed on your system.
