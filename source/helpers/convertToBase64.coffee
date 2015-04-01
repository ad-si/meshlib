arrayBufferToBase64 = (buffer) ->
	binary = ''
	bytes = new Uint8Array(buffer)
	len = bytes.byteLength
	for i in [0..len - 1]
		binary += String.fromCharCode(bytes[i])

	if Buffer
		return new Buffer(binary, 'binary').toString('base64')

	else if window
		return window.btoa binary

	else
		throw new Error 'Can not convert binary to ascii in this environment!'


module.exports = (mesh) ->
	{
	vertexCoordinates,
	faceVertexIndices,
	vertexNormalCoordinates,
	faceNormalCoordinates
	} = mesh

	posA = new Float32Array(vertexCoordinates.length)

	for i in [0..vertexCoordinates.length - 1]
		posA[i] = vertexCoordinates[i]
	indA = new Int32Array(faceVertexIndices.length)

	for i in [0..faceVertexIndices.length - 1]
		indA[i] = faceVertexIndices[i]
	vnA = new Float32Array(vertexNormalCoordinates.length)

	for i in [0..vertexNormalCoordinates.length - 1]
		vnA[i] = vertexNormalCoordinates[i]
	fnA = new Float32Array(faceNormalCoordinates.length)

	for i in [0..faceNormalCoordinates.length - 1]
		fnA[i] = faceNormalCoordinates[i]

	posBase = arrayBufferToBase64 posA.buffer
	baseString = posBase
	baseString += '|'

	indBase = arrayBufferToBase64 indA.buffer
	baseString += indBase
	baseString += '|'

	vnBase = arrayBufferToBase64 vnA.buffer
	baseString += vnBase
	baseString += '|'

	fnBase = arrayBufferToBase64 fnA.buffer
	baseString += fnBase

	return baseString
