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
