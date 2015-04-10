argumentexpectations = require './argumentexpectations'
expectation = require './expectation'
fakeobject = require './fakeobject'
scenario = require './scenario'
ajaxtest = require './ajaxtest'

global.captured = argumentexpectations.SaveArgument.exposeSaved()
global.Scenario = scenario.Scenario
global.Call = expectation.Call
global.Equals = argumentexpectations.Equals
global.SaveArgument = argumentexpectations.SaveArgument
global.IgnoreArgument = argumentexpectations.IgnoreArgument
global.ArgumentExpectation = argumentexpectations.ArgumentExpectation
global.capture = ( name ) ->
    new argumentexpectations.SaveArgument( name )
global.fakeObject = fakeobject.fakeObject
global.fakeGlobal = ( name, methods ) ->
	global[ name ] = fakeobject.fakeObject( name, methods )

global.call = ( path, argumentexpectations, result ) -> new expectation.Call( path, argumentexpectations, result )
global.cascade = ( path, argumentexpectations, result, passAlong ) -> new expectation.Cascade( path, argumentexpectations, result, passAlong )
global.window = global
global.THIS = { fakeThisObject: "#{Math.random().toString()[ 2..5 ]}_this",\
				toString: => "this" }

global.clone = ( obj ) ->
	JSON.parse( JSON.stringify( obj ) )

global.AjaxTest = ajaxtest.AjaxTest
