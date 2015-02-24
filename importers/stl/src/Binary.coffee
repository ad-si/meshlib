# An unoptimized data structure that holds the same content as a stl file

class Binary
	constructor: () ->
		@polygons = []
		@importErrors = []

	addPolygon: (stlPolygon) ->
		@polygons.push(stlPolygon)

	addError: (string) ->
		@importErrors.push string

module.exports = Binary
