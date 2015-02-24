Vector = require './Vector'
Polygon = require './Polygon'

class Face
	constructor: (@vertices = [], @normal = null) ->
		return

	@fromVertexArray: (array) ->
		return new Face array

	addVertex: (vertex) ->
		@vertices.push vertex

module.exports = Face
