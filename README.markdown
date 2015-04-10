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

Since jQuery expectations are commonplace, we can use the shorthand
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

## The Callback Cascade Pattern

When writing JavaScript code, it often happens that we get a cascade of
callback functions, since almost everything is done asynchronously.  For
example, say we want to check if some directory exists, and if not, create it,
and then run some subprocess in the directory. If the directory already exists,
we don't need to create it.

The callback cascade here is

    fs.exists => fs.mkdir => childProcess.exec

We can use `capture` for this, but it gets ugly really fast. If the callback
argument for each function in our cascade is the *last* one, which is often the
case, e.g.

    fs.exists(path, callback)

We can use the *cascade* pattern:

```coffeescript
rewire = require 'rewire'

describe 'cascade of callbacks', ->
    beforeEach ->
        cascadeModule.__set__( 'fs', fakeObject( 'fs', [ 'exists', 'mkdir' ] ) )
        cascadeModule.__set__( 'childProcess', fakeObject( 'childProcess', [ 'exec' ] ) )

    it 'should work', ->
        myCallback = fakeObject( 'myCallback' )
        scenario.expectCascade [    cascade( 'fs.exists', [ 'some_path' ], null, [false] ),
                                    cascade( 'fs.mkdir', [ 'some_path' ] ),
                                    cascade( 'childProcess.exec', [ 'some command', {cwd: 'some_path'} ], null, [ null, "output string", "error string" ] ),
                                    call( 'myCallback', [ "output string" ] ) ]

        tested = new cascadeModule.Cascade()

        tested.go( 'some_path', myCallback )
        scenario.end()
        
```

NOTE the use of [*rewire*](https://github.com/jhnns/rewire) to mock objects inside the module.

This expresses the expectation that the code will call `fs.exists` - passing it
`some_path`. The `fs.exists` cascade specifies that `fs.exists` will return
`null`, *and then* call its callback with the arguments specified in a list, in
this case `[false]`, so just one argument.

What happens when `fs.exists`'s callback is called? Since the directory does
not exist (we made `fs.exists` pass `false` to its callback, remember?) we
expect it to call `fs.mkdir`, which will the call *its* callback.

We then demand that this callback call `childProcess.exec` and we specify the
output and error strings passed to *its* callback, which should, finally, call
the user's callback.

NOTE the last call in the cascade is a `call`, not a `cascade` - since we don't
want it to automatically call a callback.

The code that passes this test would be:
```coffeescript
fs = require 'fs'
childProcess = require 'child_process'

class Cascade
    go: ( path, callback ) =>
        @callback = callback
        fs.exists path, (exists) =>
            if exists
                this._runChild( path )
            else
                fs.mkdir path, =>
                    this._runChild( path )

    _runChild: ( path ) =>
        childProcess.exec 'some command', { cwd: path }, (err, output, error) =>
            @callback( output )

exports.Cascade = Cascade
```
