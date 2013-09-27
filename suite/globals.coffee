argumentexpectations = require 'argumentexpectations'
expectation = require 'expectation'
fakeobject = require 'fakeobject'
scenario = require 'scenario'
suite = require 'suite'

global.Suite = suite.Suite
global.ls = suite.ls
global.Scenario = scenario.Scenario
global.Expectation = expectation.Expectation
global.Equals = argumentexpectations.Equals
global.SaveArguement = argumentexpectations.SaveArguement
global.fakeGlobal = ( name, methods ) ->
	global[ name ] = new fakeobject.FakeObject( name, methods )
