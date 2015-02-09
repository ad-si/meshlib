require('es6-promise').polyfill()

Model = require './Model'
Stl = require './Stl'
stlExport = require './stlExport'
optimizeModel = require './optimizeModel'

importFileBuffer = ''
meshlib = {}
meshData = {}
model = {}


parse = (fileBuffer, options, callback) ->

	options ?= {}
	options.format ?= 'stl'

	if not fileBuffer
		throw new Error 'STL buffer is empty'

	else if typeof fileBuffer isnt 'string'
		fileBuffer = toArrayBuffer fileBuffer

	if options.format is 'stl'
		try
			stl = new Stl fileBuffer
			model = stl.model()
		catch error
			if typeof callback is 'function'
				callback error
				return meshlib
			else
				throw error

	if typeof callback is 'function'
		callback(null, model)

	return meshlib


parseString = (modelString, options) ->

	options ?= {}
	options.format ?= 'stl'
	options.encoding ?= 'utf-8'

	return new Promise (resolve, reject) ->

		if not modelString
			reject new Error 'Model string is empty!'

		if options.format is 'stl'
			try
				stl = new Stl modelString
				model = stl.model()
			catch error
				return reject error

			return resolve(model)

		return reject new Error 'Model string can not be parsed!'



toArrayBuffer = (buffer) ->
	if Buffer && Buffer.isBuffer buffer
		tempArrayBuffer = new ArrayBuffer buffer.length
		view = new Uint8Array tempArrayBuffer

		for i in [0...buffer.length]
			view[i] = buffer[i]

		return tempArrayBuffer

	else
		return buffer


meshlib = (modelData, options) ->

	if typeof modelData is 'string'
		return parseString modelData, options
			.then (model) ->
				return new Model model

	if not model.positions? or not model.indices? or not
	    model.vertexNormals? or not model.faceNormals?
			model = parseBuffer(model, options)

			return new Model model, options


meshlib.meshData = () ->
	return meshData

meshlib.model = (newModel) ->
	model = newModel
	return meshlib

meshlib.optimize = () ->
	# TODO: fix
	model = optimizeModel model

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
