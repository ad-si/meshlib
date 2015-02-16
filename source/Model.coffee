optimizeModel = require './optimizeModel'
Vector = require './Vector'

NoFacesError = (message) ->
	this.name = 'NoFacesError'
	this.message = message or
		'No faces available. Make sure to generate them first.'
NoFacesError.prototype = new Error

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

	fixFaces: () =>
		deletedPolygons = []

		if @mesh.polygons
			@mesh.polygons = @mesh.polygons.map (polygon) ->
				if polygon.vertices.length is 3
					return polygon

				else if polygon.vertices.length > 3
					deletedPolygons.push polygon
					polygon.vertices = polygon.vertices.slice(0, 3)
					return polygon

				else if polygon.vertices.length is 2
					polygon.addVertex new Vector 0,0,0
					return polygon

				else if polygon.vertices.length is 1
					polygon.addVertex new Vector 0, 0, 0
					polygon.addVertex new Vector 1, 1, 1
					return polygon

				else
					return null
		else
			throw new NoFacesError
		return @

	calculateNormals: () =>
		newNormals = []

		if @mesh.polygons
			@mesh.polygons = @mesh.polygons.map (polygon) ->
				d1 = polygon.vertices[1].minus polygon.vertices[0]
				d2 = polygon.vertices[2].minus polygon.vertices[0]
				normal = d1.crossProduct d2
				normal = normal.normalized()

				if polygon.normal?
					distance = polygon.normal.euclideanDistanceTo normal
					if distance > 0.001
						newNormals.push normal

				polygon.normal = normal
				return polygon
		else
			throw new NoFacesError

		return @

	setPolygons: (polygons) =>
		@mesh.polygons = polygons
		return @

module.exports = Model
