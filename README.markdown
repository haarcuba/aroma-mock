# AromaMock - Mocking Framework for JavaScript and CoffeeScript

Aroma is a CoffeeScript Mock Framework. This of course means that it *can* be
used to test and develop JavaScript, but in this document, I will address
CoffeeScript, because I like it better. It provides a useful
scenario-expectations construct and easy, on the fly mock object generation.

The scenario verifies the exact expected function call sequence including the
function arguments. Scenarios are specified before the code is run, making the
tests well organized, readable and more explicit. 

The scenario abstraction verifies that things happen *exactly* as specified:
i.e. we do not only verify that some mock function was called with specific
paramenter, we verify that it has *not* been called more times that it should
have been, with some other parameters.

Original concepts were carried over from [Voodoo-Mock](http://github.com/shlomimatichin/Voodoo-Mock), a C++/Python unit test
framework.

## Installation

	$ npm install aroma-mock

You will also probably want to

	$ npm install mocha coffee-script

## Running CoffeeScript Tests with Mocha

In the following examples I use [Mocha](http://mochajs.org) for a test runner.
In order for Mocha to work with CoffeeScript you must use it like this:

	$ mocha --compilers coffee:coffee-script/register [tests...]

## Using Aroma-Mock with JavaScript

Aroma-Mock is written in CoffeeScript. It can be used in JavaScript by requiring the `coffee-script/register` in your test code, and then requiring `aroma-mock`:

## Quick Start
Here's an example test, that mocks the jQuery $ symbol and tests that it is
used as expected.  Before reading the entire thing, let's just look at the `call` expectation: 

	call( '$', [ "#input_element" ], fakeObject( 'element', ['val'] ) )

expresses our expectation that the tested code will call `$` with
`"#input_element"` as its first argument. We also arrange that the return value
of this call will be a Mock Object called `element`.  

We *then* expect that this `element` object's `val` method will be called with
one argument, the string `'123'`. This is expressed in the expectation:

	call( 'element.val', [ '123' ] )

Since we don't care about the return value from this call, we leave it unspecified. We can also use `null`

	call( 'element.val', [ '123' ], null )

Since jQuery expectations are commonplace, we can use a the shorthand
`expect_$` for this 2-call expectation - this is demonstrated below.
	
Another thing to note is the use of `capture` and `captured` to test functions
called with callbacks. E.g., if our code calls `fs.mkdir( 'somepath', onCreated
)`, we want to later call this `onCreated` function. We therefore use the
`capture` feature of Aroma-Mock to get at it:

    call( 'fs.mkdir', [ 'somepath', capture( 'onCreatedCallback' ) ] )

and later call it via the `captured` API:

    captured.onCreatedCallback()

I hope this makes the following, complete listing, clear.


```coffeescript
require 'aroma-mock' # import the Aroma-Mock framework
example = require '../example'

fakeGlobal( '$', [ 'getJSON', 'ajax' ] )
fakeGlobal( 'Point', [] )

describe 'example of aroma mocking framework', ->
	it 'should get JSON with jQuery', ->
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( '$.getJSON', [ 'www.google.com', {a:1, b:2}, capture( 'doneCallback' ) ], null )

		tested.getSomeJSON()
		scenario.end()

		captured.doneCallback()

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
		ajaxTest.onSuccessScenario = =>
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

a test that checks the response to an error can also be written


```coffeescript

# we don't use getJSON in this example, but this is how to create a fake object
# with multiple methods.
fakeGlobal( '$', [ 'getJSON', 'ajax' ] )

describe 'example of aroma ajax mocking', ->
	it 'aroma asynchronous AJAX error example', ->
		tested = new example.Example()
		scenario = new Scenario()
		ajaxTest = new AjaxTest( scenario )
		ajaxTest.expect( { url: '/path/to/return_keys.json', data: { a: 1, b: 2 }, type: 'POST' } )
		ajaxTest.errorFromServer( null, 'error text 123', null )
		ajaxTest.onErrorScenario = =>
			scenario.expect_$( "#status", 'val', [ 'error text 123' ], null )
			scenario.expect_$( "#output_element", 'val', [ [] ], null )

		tested.doAsyncAjax( { a: 1, b: 2 } )
		ajaxTest.verify( 'error' )
		scenario.end()
```

This code passes the test, as well as the previous one:

```coffeescript
class Example
	doAsyncAjax: ( data ) =>
		success = (data) =>
			$("#status").val( data.status )
			$("#output_element").val( data.answer )
		error = ( unused, text, unused2 ) =>
			$("#status").val( text )
			$("#output_element").val( [] )
			
		$.ajax { 	url: '/path/to/return_keys.json',\
					data: data,
					type: 'POST',
					success: success,
					error: error }
```
