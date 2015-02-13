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

	removeInvalidPolygons = () =>

		deletedPolygons = []

		return @mesh.polygons.map (polygon) ->
			if polygon.points.length is 3
				return polygon
			else
				deletedPolygons.push polygon

	recalculateNormals = () =>

		newNormals = []

		@polygons = @polygons.map (polygon) ->
			d1 = polygon.points[1].minus polygon.points[0]
			d2 = polygon.points[2].minus polygon.points[0]
			normal = d1.crossProduct d2
			normal = normal.normalized()

			if polygon.normal?
				distance = poly.normal.euclideanDistanceTo normal
				if distance > 0.001
					newNormals.push normal

			polygon.normal = normal

		return newNormals

	setPolygons: (polygons) =>
		@mesh.polygons = polygons
		return @

module.exports = Model
