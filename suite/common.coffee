join = ( array, separator ) ->
	if array.length == 1
		return "#{array[ 0 ]}"
	if array.length == 0
		return ""
	result = ""
	for i in [0..array.length - 2]
		result += "#{array[ i ]}" + separator

	result += array[ array.length - 1 ]
	result

ls = ( thing ) -> console.log( thing.valueOf() )

exports.join = join
exports.ls = ls
