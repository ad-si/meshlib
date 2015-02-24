Vector = require './Vector'

class Polygon
	constructor: () ->
		@vertices = []
		@normal = new Vector(0, 0, 0)

	setNormal: (@normal) ->
		return

	addVertex: (vertex) ->
		@vertices.push vertex

module.exports = Polygon
