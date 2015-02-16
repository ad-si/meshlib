optimizeModel = require './optimizeModel'


# Abstracts the actual model from the external fluid api
class Model
	constructor: (@mesh, @options) ->
		@mesh ?= {}
		@options ?= {}

	toStl: (options) ->
		options ?= {}
		options.encoding ?= 'binary' # ascii
		options.type ?= 'buffer' # string
		return @

	optimize: () =>
		@mesh = optimizeModel @mesh
		return @

	removeInvalidPolygons: () =>
		deletedPolygons = []

		if @mesh.polygons
			console.log(@mesh.polygons)
			@mesh.polygons = @mesh.polygons.map (polygon) ->
				if polygon.vertices.length is 3
					return polygon
				else
					deletedPolygons.push polygon
					polygon.vertices = polygon.vertices.slice(0, 3)
					return polygon
			console.log(@mesh.polygons)
		else
			throw new Error 'No polygons available.
							Make sure to generate them first.'
		return @

	recalculateNormals: () =>
		newNormals = []

		@polygons = @polygons.map (polygon) ->
			d1 = polygon.vertices[1].minus polygon.vertices[0]
			d2 = polygon.vertices[2].minus polygon.vertices[0]
			normal = d1.crossProduct d2
			normal = normal.normalized()

			if polygon.normal?
				distance = poly.normal.euclideanDistanceTo normal
				if distance > 0.001
					newNormals.push normal

			polygon.normal = normal

		return @

	setPolygons: (polygons) =>
		@mesh.polygons = polygons
		return @

module.exports = Model
