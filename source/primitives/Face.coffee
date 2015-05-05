class Face
	constructor: (@vertices = [], @normal = null) ->
		return

	@fromVertexArray: (array) ->
		return new Face array

	@fromObject: ({vertices, normal}) ->
		normal ?= {x: 0, y: 0, z: 0}
		return new Face vertices, normal

	addVertex: (vertex) ->
		@vertices.push vertex

module.exports = Face
