smalloc = require 'smalloc'

module.exports.toArrayBuffer = (buffer) ->

	if Buffer and Buffer.isBuffer buffer
		tempArrayBuffer = new ArrayBuffer buffer.length
		view = new Uint8Array tempArrayBuffer

		smalloc.copyOnto(buffer, 0, view, 0, buffer.length)

		return tempArrayBuffer

	else if buffer instanceof ArrayBuffer
		return buffer

	else
		throw new Error "Can not convert #{typeof buffer} to ArrayBuffer!"


module.exports.toBuffer = (arrayBuffer) ->

	if Buffer and Buffer.isBuffer arrayBuffer
		return arrayBuffer

	else
		buffer = new Buffer(arrayBuffer.byteLength)
		view = new Uint8Array(arrayBuffer)
		i = 0

		while i < buffer.length
			buffer[i] = view[i]
			++i

		return buffer
