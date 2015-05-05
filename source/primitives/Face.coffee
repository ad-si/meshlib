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

	getSurfaceArea: ->
		Δ1X = @vertices[1].x - @vertices[0].x
		Δ1Y = @vertices[1].y - @vertices[0].y
		Δ1Z = @vertices[1].z - @vertices[0].z

		Δ2X = @vertices[2].x - @vertices[0].x
		Δ2Y = @vertices[2].y - @vertices[0].y
		Δ2Z = @vertices[2].z - @vertices[0].z

		x = (Δ1Y * Δ2Z) - (Δ1Z * Δ2Y)
		y = (Δ1Z * Δ2X) - (Δ1X * Δ2Z)
		z = (Δ1X * Δ2Y) - (Δ1Y * Δ2X)

		return 0.5 * Math.sqrt (x * x) + (y * y) + (z * z)


module.exports = Face
