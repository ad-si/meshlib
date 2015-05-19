stream = require 'stream'


class ModelStream extends stream.Readable
	constructor: (@modelObject, @options = {}) ->
		@options.objectMode ?= false
		super @options

	_read: () ->
		header =
			name: @modelObject.name
			fileName: @modelObject.fileName
			faceCount: @modelObject.faceCount

		if @options.objectMode

			@push header

			@modelObject.mesh.faces
			.forEach (face) =>
				@push face

		else
			@push JSON.stringify(header) + '\n'

			@modelObject.mesh.faces
			.forEach (face) =>
				@push JSON.stringify(face) + '\n'

		@push null

module.exports = ModelStream
