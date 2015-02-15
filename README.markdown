# Aroma - Mocking Framework for Coffee Script

Aroma is a Coffee Script Mock Framework. It provides a useful scenario-expectations construct and easy, on the fly mock object generation.

The scenario verifies the exact expected function call sequence including the function arguments. Scenarios are specified before the code is run, making the tests well organized, readable and more explicit. 

The scenario abstraction verifies that things happen *exactly* as specified: i.e. we do not only verify that some mock function was called with specific paramenter, we verify that it has *not* been called more times that it should have been, with some other parameters.

Original concepts were carried over from Voodoo-Mock, a C++/Python unit test framework.


## Example
Here's an example test, that mocks the jQuery $ symbol and tests that it is used as expected. 
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
example = require '../example'

fakeGlobal( '$', [ 'getJSON', 'ajax' ] )
fakeGlobal( 'Point', [] )

describe 'example of aroma mocking framework', ->
	it 'should get JSON with jQuery', ->
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( '$.getJSON', [ 'www.google.com', {a:1, b:2}, new SaveArgument( 'doneCallback' ) ], null )

		tested.getSomeJSON()
		scenario.end()

		capturedCallback = SaveArgument.saved( 'doneCallback' )
		capturedCallback()

	it 'should use jQuery on the DOM', ->
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( '$', [ "#input_element" ], fakeObject( 'element', ['val'] ) )
		scenario.expect call( 'element.val', [ '123' ], null )
		tested.useJQueryOnDOM( '123' )
		scenario.end()

	it 'should use jQuery on the DOM: example of expect_$ shorthand notation', ->
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect_$( '#input_element', 'val', [ '456' ], null )
		tested.useJQueryOnDOM( '456' )
		scenario.end()
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

## Asynchronous Ajax JSON Retrieval Example
The `AjaxTest` class allows testing for an asynchronous ajax call. We define
the parameters of the ajax call, the data supposedly returned from the server,
and what we expect should happen on success.

Currently, it is assumed that the call is successful - an option for failure
will be added in the future when I need it :)

Here's an asynchronous ajax test:

```coffeescript

# we don't use getJSON in this example, but this is how to create a fake object
# with multiple methods.
fakeGlobal( '$', [ 'getJSON', 'ajax' ] )

describe 'example of aroma ajax mocking', ->
	it 'aroma can test asynchronous AJAX', ->
		tested = new example.Example()
		scenario = new Scenario()
		ajaxTest = new AjaxTest( scenario )
		ajaxTest.expect( { url: '/path/to/return_keys.json', data: { a: 1, b: 2 }, type: 'POST' } )
		ajaxTest.returnFromServer( { status: 'ok', answer: [ 'a', 'b' ] } )
		ajaxTest.onSuccess = =>
			scenario.expect_$( "#status", 'val', [ 'ok' ], null )
			scenario.expect_$( "#output_element", 'val', [ [ 'a', 'b' ] ], null )

		tested.doAsyncAjax( { a: 1, b: 2 } )
		ajaxTest.verify()
		scenario.end()
```

this is the code that passes it

```coffeescript
class Example
	doAsyncAjax: ( data ) =>
		success = (data) =>
			$("#status").val( data.status )
			$("#output_element").val( data.answer )
		$.ajax { url: '/path/to/return_keys.json', data: data, type: 'POST', success: success }
```
