Vector = require '@datatypes/vector'
Point = require '@datatypes/point'

calculateLocalitySensitiveHash = (point) ->
	return point.x + point.y + point.z

isCloserThan = (distance, numberA, numberB) ->
	return (numberA - numberB) < distance

module.exports = (faces, options = {}) ->
	maximumMergeDistance = options.maximumMergeDistance || 0.0001

	vertices = []
	currentBucket = []
	vertexCoordinates = []
	faceVertexIndices = []
	faceNormalCoordinates = []
	maximumIndex = 0

	sortedVertices = faces
		.map (face, faceIndex) ->
			faceNormalCoordinates.push(
				face.normal.x,
				face.normal.y,
				face.normal.z
			)

			face.vertices.forEach (vertex, vertexIndex) ->
				vertex.hash = calculateLocalitySensitiveHash vertex
				vertex.originalFaceIndex = faceIndex
				vertex.originalVertexIndex = vertexIndex
			return face

		.reduce (verticesArray, face) ->
				return verticesArray.concat face.vertices
			, []

		# TODO: Insert into Binary tree to get sorted array
		.sort (vertexA, vertexB) -> vertexB.hash - vertexA.hash


	# Iterate over vertices and remove duplicates
	vertexIndex = 0
	while vertexIndex < sortedVertices.length
		currentVertex = sortedVertices[vertexIndex]

		if currentVertex is null
			vertexIndex++
			continue

		if not currentVertex.usedIn?
			currentVertex.usedIn = [{
				face: currentVertex.originalFaceIndex,
				vertex: currentVertex.originalVertexIndex,
			}]
			delete currentVertex.originalFaceIndex
			delete currentVertex.originalVertexIndex

		lookAheadIndex = vertexIndex + 1
		while(
			lookAheadIndex <= sortedVertices.length and
			(sortedVertices[lookAheadIndex] is null or
			isCloserThan(
				2 * maximumMergeDistance,
				currentVertex.hash,
				sortedVertices[lookAheadIndex]?.hash
			))
		)
			if (sortedVertices[lookAheadIndex] is null)
				lookAheadIndex++
				continue

			if (isCloserThan(
					maximumMergeDistance,
					currentVertex.x,
					sortedVertices[lookAheadIndex].x
				) &&
				isCloserThan(
					maximumMergeDistance,
					currentVertex.y,
					sortedVertices[lookAheadIndex].y
				) &&
				isCloserThan(
					maximumMergeDistance,
					currentVertex.z,
					sortedVertices[lookAheadIndex].z
				)
			)
				currentVertex.usedIn.push {
					face: sortedVertices[lookAheadIndex].originalFaceIndex,
					vertex: sortedVertices[lookAheadIndex].originalVertexIndex,
				}
				sortedVertices[lookAheadIndex] = null

			lookAheadIndex++

		vertexIndex++


	cleanedVertices = sortedVertices.filter (vertex) -> vertex?

	vertexCoordinates = cleanedVertices.reduce (array, vertex) ->
			if vertex?
				array.push  vertex.x, vertex.y, vertex.z
			return array
		, []

	faceVertexIndices =
		cleanedVertices.reduce (faceVertexIndices, vertex, vertexIndex) ->
			if vertex?
				vertex.usedIn.forEach (vertexReference) ->
					index = (vertexReference.face * 3) + vertexReference.vertex
					faceVertexIndices[index] = vertexIndex
			return faceVertexIndices
		, []

	return {
		vertexCoordinates # vertexCoordinates
		faceVertexIndices # faceVertexIndices
		faceNormalCoordinates # faceNormals
		vertexNormalCoordinates: [] # TODO: vertexNormals
	}
