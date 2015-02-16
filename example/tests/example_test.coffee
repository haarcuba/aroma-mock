require 'globals'
require 'should'
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

	it 'should handle null argument expectations', ->
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( '$', [ null ], null )
		tested.callJQueryWithNull()
		scenario.end()

	it "expect callback to use $ with `this' ", ->
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect_$( '#product', 'on', [ 'change', new SaveArgument( "productChangeCallback" ) ], null )
		scenario.expect_$( THIS, 'val', [], 123 )
		tested.registerCallbackForProductChange()
		callback = SaveArgument.saved( "productChangeCallback" )
		callback.apply( THIS )
		tested.lastProductChanged().should.equal 123
		scenario.end()

	it 'aroma supports hooks simulating action taken by a mocked object', ->
		tested = new example.Example()
		scenario = new Scenario()
		event = { id: 123, text: 'hi there' }
		fakeScheduler = fakeObject( 'scheduler', [ 'getEvent', 'setEventID', 'updateEvent' ] )
		scenario.expect call( 'scheduler.getEvent', [ 123 ], event )
		scenario.expect call( 'scheduler.setEventID', [ 123, 456 ], event )
		scenario.hook( -> event.id = 456 )
		scenario.expect call( 'scheduler.updateEvent', [ 456 ], null )
		tested.schedulerExample( 123, fakeScheduler )
		scenario.end()

	it 'aroma can moch classes', ->
		tested = new example.Example()
		scenario = new Scenario()
		scenario.expect call( 'Point', [ 5, 4 ], fakeObject( 'aPoint', [ 'show' ] ) )
		scenario.expect call( 'aPoint.show', [], null )
		tested.instantiatePoint()
		scenario.end()

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
		ajaxTest.verify( 'success' )
		scenario.end()

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
