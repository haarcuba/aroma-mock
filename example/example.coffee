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
	
	callJQueryWithNull: =>
		$( null )

	registerCallbackForProductChange: =>
		self = this
		$("#product").on 'change', ->
			self._lastProductChanged = $(this).val()

	lastProductChanged: =>
		this._lastProductChanged

	instantiatePoint: =>
		point = new Point( 5, 4 )
		point.show()

	schedulerExample: ( id, scheduler ) =>
		event = scheduler.getEvent( id )
		scheduler.setEventID( id, 456 )
		scheduler.updateEvent( event.id )

exports.Example = Example
