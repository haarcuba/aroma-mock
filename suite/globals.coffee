argumentexpectations = require 'argumentexpectations'
expectation = require 'expectation'
fakeobject = require 'fakeobject'
scenario = require 'scenario'
suite = require 'suite'
common = require 'common'
global.assertions = require 'assertions'

global.Suite = suite.Suite
global.ls = common.ls
global.Scenario = scenario.Scenario
global.Call = expectation.Call
global.Equals = argumentexpectations.Equals
global.SaveArguement = argumentexpectations.SaveArguement
global.fakeObject = fakeobject.fakeObject
global.fakeGlobal = ( name, methods ) ->
	global[ name ] = fakeobject.fakeObject( name, methods )

global.call = ( path, argumentexpectations, result ) -> new expectation.Call( path, argumentexpectations, result )
global.common = common

global.expectJQuery = ( scenario, selector, method, argumentExpectations, result ) ->
	scenario.expect call( '$', [ selector ], fakeObject( 'selected', [ method ] ) )
	scenario.expect call( "selected.#{method}", argumentExpectations, result )
