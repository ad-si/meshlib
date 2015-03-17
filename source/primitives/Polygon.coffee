Vector = require './Vector'

class Polygon
	constructor: (@vertices, @normal) ->
		@verticesCoordinates = []
		@normal = new Vector(0, 0, 0)

	@fromVertexArray: (array) ->
		return new Polygon(array)

	setNormal: (@normal) ->
		return

	addVertex: (vertex) ->
		@verticesCoordinates.push vertex

module.exports = Polygon
