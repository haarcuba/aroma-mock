class Example
	add: ( x, y ) =>
		x + y

	mul: ( x, y ) =>
		x * y

	getSomeJSON: =>
		$.getJSON 'www.google.com', {a:1,b:2}, this._mycallback

	_mycallback: =>
		console.log( 'my callback called!' )

exports.Example = Example
