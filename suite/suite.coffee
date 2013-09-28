class Suite
	run: =>
		tests = 0
		for key, value of this
			if key.match /^test_/
				tests += 1
				this[ key ]()
		console.log( "finished: #{tests} tests" )

exports.Suite = Suite
