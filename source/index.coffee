require('es6-promise').polyfill()

ModelPromise = require './ModelPromise'
Stl = require './Stl'
stlExport = require './stlExport'
optimizeModel = require './optimizeModel'
converters = require './converters'

importFileBuffer = ''
meshlib = {}
meshData = {}
model = {}


parse = (modelData, options = {}) ->

	options.format ?= 'stl'

	return new Promise (fulfill, reject) ->

		if not modelData
			reject new Error 'Model string is empty!'

		if options.format is 'stl'
			try
				polygonModel = new Stl(modelData).model()
			catch error
				return reject error

			return fulfill polygonModel

		reject new Error 'Model string can not be parsed!'


meshlib = (modelData, options) ->

	if typeof modelData isnt 'string'
		modelData = converters.toArrayBuffer modelData

	return new ModelPromise()
		.next (model) ->
			return parse modelData, options
				.then (polygonModel) ->
					try
						model.setPolygons polygonModel.polygons
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


meshlib.parse = parse

meshlib.separateGeometry = require('./separateGeometry')
meshlib.OptimizedModel = require('./OptimizedModel')
meshlib.StlLoader = require('./Stl')
meshlib.Vec3 = require('./Vector')

module.exports = meshlib
