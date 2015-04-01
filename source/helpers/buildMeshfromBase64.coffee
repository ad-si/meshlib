atob = (str) ->
	if Buffer
		return new Buffer(str, 'base64').toString('binary')
	else if window
		return window.atob str
	else
		throw Error 'Can not convert ascii to binary in this environment!'

base64ByteLength = (base64Length) ->
	return (base64Length / 4) * 3


base64ToArray =  (b64) ->
	numFloats = (base64ByteLength b64.length) / 4
	result = []
	decoded = stringToUint8Array atob b64
	pview = new DataView decoded.buffer
	for i in [0..numFloats - 1]
		result[i] = pview.getFloat32 i * 4, true
	return result

base64ToFloat32Array =  (b64) ->
	numFloats = (base64ByteLength b64.length) / 4
	result = new Float32Array numFloats
	decoded = stringToUint8Array atob b64
	pview = new DataView decoded.buffer
	for i in [0..numFloats - 1]
		result[i] = pview.getFloat32 i * 4, true
	return result

base64ToInt32Array = (b64) ->
	numInts = (base64ByteLength b64.length) / 4
	result = new Int32Array(numInts)
	decoded = stringToUint8Array atob b64
	pview = new DataView decoded.buffer
	for i in [0..numInts - 1]
		result[i] = pview.getInt32 i * 4, true
	return result

stringToUint8Array = (str) ->
	ab = new ArrayBuffer str.length
	uintarray = new Uint8Array ab
	for i in [0..str.length - 1]
		uintarray[i] = str.charCodeAt i
	return uintarray

module.exports = (base64String) ->
	strArray = base64String.split '|'

	return {
	faceVertexMesh:
		vertexCoordinates: base64ToArray strArray[0]
		faceVertexIndices: Array.prototype.slice.call(
			base64ToInt32Array strArray[1]
		)
		vertexNormalCoordinates: base64ToArray strArray[2]
		faceNormalCoordinates: base64ToArray strArray[3]
	name: strArray[4]
	}