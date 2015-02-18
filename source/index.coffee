require('es6-promise').polyfill()

ModelPromise = require './ModelPromise'
optimizeModel = require './optimizeModel'
converters = require './converters'

importFileBuffer = ''
meshlib = {}
meshData = {}
model = {}


meshlib = (modelData, options) ->

	return new ModelPromise()
		.next (model) ->
			try
				model.setPolygons modelData.polygons
			catch error
				console.error error

			return model


meshlib.meshData = () ->
	return meshData

meshlib.model = (newModel) ->
	model = newModel
	return meshlib

meshlib.export = (options, callback) ->
	options ?= {}
	options.format ?= 'stl'
	options.encoding ?= 'binary'

	if options.format is 'stl'
		if options.encoding is 'ascii'
			stlFile = stlExport.toAsciiStl model
		else
			stlFile = stlExport.toBinaryStl model

		callback(null, stlFile)
	else
		throw new Error options.format + ' is no supported file format!'

	return meshlib


module.exports = meshlib
