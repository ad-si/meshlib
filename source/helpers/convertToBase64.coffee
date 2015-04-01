arrayBufferToBase64 = (buffer) ->
	binary = ''
	bytes = new Uint8Array(buffer)
	len = bytes.byteLength
	for i in [0..len - 1]
		binary += String.fromCharCode(bytes[i])

	if Buffer
		return new Buffer(binary).toString('base64')

	else if window
		return window.btoa binary

	else
		throw new Error 'Can not convert binary to ascii in this environment!'


module.exports = (mesh) ->
	{
	verticesCoordinates,
	facesVerticesIndices,
	verticesNormals,
	facesNormals
	} = mesh

	posA = new Float32Array(verticesCoordinates.length)

	for i in [0..verticesCoordinates.length - 1]
		posA[i] = verticesCoordinates[i]
	indA = new Int32Array(facesVerticesIndices.length)

	for i in [0..facesVerticesIndices.length - 1]
		indA[i] = facesVerticesIndices[i]
	vnA = new Float32Array(verticesNormals.length)

	for i in [0..verticesNormals.length - 1]
		vnA[i] = verticesNormals[i]
	fnA = new Float32Array(facesNormals.length)

	for i in [0..facesNormals.length - 1]
		fnA[i] = facesNormals[i]

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
