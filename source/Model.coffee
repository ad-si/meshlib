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

	setPolygons: (polygons) =>
		@mesh.polygons = polygons
		return @

module.exports = Model
