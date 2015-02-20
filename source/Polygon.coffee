Vector = require './Vector'

class Polygon
	constructor: (@vertices, @normal) ->
		@vertices = []
		@normal = new Vector(0, 0, 0)

	@fromVertexArray: (array) ->
		return new Polygon(array)

	setNormal: (@normal) ->
		return

	addVertex: (vertex) ->
		@vertices.push vertex

module.exports = Polygon
