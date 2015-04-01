module.exports = (faceVertexMesh) ->

	minX = maxX = faceVertexMesh.vertexCoordinates[0]
	minY = maxY = faceVertexMesh.vertexCoordinates[1]
	minZ = maxZ = faceVertexMesh.vertexCoordinates[2]

	for i in [0..faceVertexMesh.vertexCoordinates.length - 1] by 3
		if faceVertexMesh.vertexCoordinates[i] < minX
			minX = faceVertexMesh.vertexCoordinates[i]

		if faceVertexMesh.vertexCoordinates[i + 1] < minY
			minY = faceVertexMesh.vertexCoordinates[i + 1]

		if faceVertexMesh.vertexCoordinates[i + 2] < minZ
			minZ = faceVertexMesh.vertexCoordinates[i + 2]

		if faceVertexMesh.vertexCoordinates[i] > maxX
			maxX = faceVertexMesh.vertexCoordinates[i]

		if faceVertexMesh.vertexCoordinates[i + 1] > maxY
			maxY = faceVertexMesh.vertexCoordinates[i + 1]

		if faceVertexMesh.vertexCoordinates[i + 2] > maxZ
			maxZ = faceVertexMesh.vertexCoordinates[i + 2]

	return {
	min:
		x: minX
		y: minY
		z: minZ
	max:
		x: maxX
		y: maxY
		z: maxZ
	}