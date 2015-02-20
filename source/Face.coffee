Vector = require './Vector'
Polygon = require './Polygon'

class Face
	constructor: (@vertices, @normal) ->
		@vertices ?= []
		@normal ?= null

	@fromVertexArray: (array) ->
		return new Face(array)

	addVertex: (vertex) ->
		@vertices.push vertex

module.exports = Face
