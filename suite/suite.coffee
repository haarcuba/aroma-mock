class Suite
	setup: =>

	teardown: =>

	run: =>
		tests = 0
		for key, value of this
			if key.match /^test_/
				tests += 1
				console.log( key )
				this.setup()
				this[ key ]()
				this.teardown()
		console.log( "finished: #{tests} tests" )

exports.Suite = Suite
