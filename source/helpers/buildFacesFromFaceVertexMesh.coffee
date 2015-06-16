module.exports = (mesh) ->
	{faceVertexIndices, faceNormalCoordinates, vertexCoordinates} = mesh

	for i in [0...faceVertexIndices.length] by 3
		normal:
			x: faceNormalCoordinates[i]
			y: faceNormalCoordinates[i + 1]
			z: faceNormalCoordinates[i + 2]

		vertices: for j in [0...3]
			x: vertexCoordinates[faceVertexIndices[i + j] * 3]
			y: vertexCoordinates[faceVertexIndices[i + j] * 3 + 1]
			z: vertexCoordinates[faceVertexIndices[i + j] * 3 + 2]
