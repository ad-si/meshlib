module.exports.forEachEdge = (faceVertexMesh, callback) ->
	faceVertexIndices = faceVertexMesh.faceVertexIndices

	for index in [0...faceVertexIndices.length] by 3
		v1 = faceVertexIndices[index]
		v2 = faceVertexIndices[index + 1]
		v3 = faceVertexIndices[index + 2]

		callback v1, v2
		callback v2, v3
		callback v3, v1
