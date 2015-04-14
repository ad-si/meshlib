Model = require './Model'
stream = require 'stream'


class ModelBuilder extends stream.Writable
	constructor: (@options = {}) ->
		@options.objectMode ?= true
		@modelObject = {
			mesh: {
				faces: []
			}
		}
		super @options

		@on 'finish', ->
			@.emit(
				'model',
				Model.fromObject @modelObject
			)

	_write: (chunk, encoding, callback) ->
		if chunk.name
			@modelObject.name = chunk.name
			if chunk.faceCount
				@modelObject.faceCount = chunk.faceCount
		else
			@modelObject.mesh.faces.push chunk

		callback()


module.exports = ModelBuilder
