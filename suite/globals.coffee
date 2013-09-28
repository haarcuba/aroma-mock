argumentexpectations = require 'argumentexpectations'
expectation = require 'expectation'
fakeobject = require 'fakeobject'
scenario = require 'scenario'
suite = require 'suite'

global.Suite = suite.Suite
global.ls = suite.ls
global.Scenario = scenario.Scenario
global.Call = expectation.Call
global.Equals = argumentexpectations.Equals
global.SaveArguement = argumentexpectations.SaveArguement
global.fakeGlobal = ( name, methods ) ->
	global[ name ] = new fakeobject.FakeObject( name, methods )

global.call = ( path, argumentexpectations, result ) -> new expectation.Call( path, argumentexpectations, result )
