require 'globals'
rewire = require 'rewire'
cascadeModule = rewire '../cascade'

describe 'cascade of callbacks', ->
    beforeEach ->
        cascadeModule.__set__( 'fs', fakeObject( 'fs', [ 'exists', 'mkdir' ] ) )
        cascadeModule.__set__( 'childProcess', fakeObject( 'childProcess', [ 'exec' ] ) )

    it 'should work', ->
        myCallback = fakeObject( 'myCallback' )
        scenario = new Scenario()
        scenario.expectCascade [    cascade( 'fs.exists', [ 'some_path' ], null, [false] ),
                                    cascade( 'fs.mkdir', [ 'some_path' ] ),
                                    cascade( 'childProcess.exec', [ 'some command', {cwd: 'some_path'} ], null, [ null, "output string", "error string" ] ),
                                    call( 'myCallback', [ "output string" ] ) ]

        tested = new cascadeModule.Cascade()

        tested.go( 'some_path', myCallback )
        scenario.end()

    it 'also should work', ->
        myCallback = fakeObject( 'myCallback' )
        scenario = new Scenario()
        scenario.expectCascade [    cascade( 'fs.exists', [ 'some_path' ], null, [true] ),
                                    cascade( 'childProcess.exec', [ 'some command', {cwd: 'some_path'} ], null, [ null, "output string 2", "error string" ] ),
                                    call( 'myCallback', [ "output string 2" ] ) ]

        tested = new cascadeModule.Cascade()

        tested.go( 'some_path', myCallback )
        scenario.end()
