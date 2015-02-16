argumentexpectations = require './argumentexpectations'
expectation = require './expectation'
fakeobject = require './fakeobject'
scenario = require './scenario'
ajaxtest = require './ajaxtest'

global.Scenario = scenario.Scenario
global.Call = expectation.Call
global.Equals = argumentexpectations.Equals
global.SaveArgument = argumentexpectations.SaveArgument
global.IgnoreArgument = argumentexpectations.IgnoreArgument
global.ArgumentExpectation = argumentexpectations.ArgumentExpectation
global.fakeObject = fakeobject.fakeObject
global.fakeGlobal = ( name, methods ) ->
	global[ name ] = fakeobject.fakeObject( name, methods )

global.call = ( path, argumentexpectations, result ) -> new expectation.Call( path, argumentexpectations, result )
global.window = global
global.THIS = { fakeThisObject: "#{Math.random().toString()[ 2..5 ]}_this",\
				toString: => "this" }

global.clone = ( obj ) ->
	JSON.parse( JSON.stringify( obj ) )

global.AjaxTest = ajaxtest.AjaxTest
