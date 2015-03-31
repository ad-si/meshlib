module.exports = (faceVertexMesh) ->

	minX = maxX = faceVertexMesh.verticesCoordinates[0]
	minY = maxY = faceVertexMesh.verticesCoordinates[1]
	minZ = maxZ = faceVertexMesh.verticesCoordinates[2]

	for i in [0..faceVertexMesh.verticesCoordinates.length - 1] by 3
		if faceVertexMesh.verticesCoordinates[i] < minX
			minX = faceVertexMesh.verticesCoordinates[i]

		if faceVertexMesh.verticesCoordinates[i + 1] < minY
			minY = faceVertexMesh.verticesCoordinates[i + 1]

		if faceVertexMesh.verticesCoordinates[i + 2] < minZ
			minZ = faceVertexMesh.verticesCoordinates[i + 2]

		if faceVertexMesh.verticesCoordinates[i] > maxX
			maxX = faceVertexMesh.verticesCoordinates[i]

		if faceVertexMesh.verticesCoordinates[i + 1] > maxY
			maxY = faceVertexMesh.verticesCoordinates[i + 1]

		if faceVertexMesh.verticesCoordinates[i + 2] > maxZ
			maxZ = faceVertexMesh.verticesCoordinates[i + 2]

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