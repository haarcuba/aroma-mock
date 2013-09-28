class Example
	add: ( x, y ) =>
		x + y

	mul: ( x, y ) =>
		x * y

	getSomeJSON: =>
		$.getJSON 'www.google.com', {a:1,b:2}, this._mycallback

	useJQueryOnDOM: ( text ) =>
		$("#input_element").val( text )

	_mycallback: =>
		console.log( 'my callback called!' )

exports.Example = Example
