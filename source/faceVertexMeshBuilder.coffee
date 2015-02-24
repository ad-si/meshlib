OptimizedModel = require './OptimizedModel'
Octree = require './Octree'
Vector = require './Vector'


module.exports = (faces, options = {}) ->
	pointDistanceEpsilon = options.pointDistanceEpsilon || 0.0001

	vertexnormals = []
	facesNormals = []
	facesVerticesList = []

	octreeRoot = new Octree(pointDistanceEpsilon)
	biggestPointIndex = -1

	for face in faces
		# Add vertices if they don't exist, or get index of these vertices
		indices = [-1, -1, -1]

		face.vertices.forEach (vertex, vertexIndex) =>

			vertex = Vector.fromObject vertex

			newPointIndex = octreeRoot.add vertex, face.normal,
				biggestPointIndex

			indices[vertexIndex] = newPointIndex

			if newPointIndex > biggestPointIndex
				biggestPointIndex = newPointIndex

		facesVerticesList = facesVerticesList.concat indices

		facesNormals.push face.normal.x
		facesNormals.push face.normal.y
		facesNormals.push face.normal.z

	# Get a list out of the octree
	vertexPositions = new Array((biggestPointIndex + 1) * 3)
	octreeRoot.forEach (node) ->
		vector = node.vec
		i = node.index * 3
		vertexPositions[i] = vector.x
		vertexPositions[i + 1] = vector.y
		vertexPositions[i + 2] = vector.z

	# Average all vertex-normals
	avgNormals = new Array((biggestPointIndex + 1) * 3)
	octreeRoot.forEach (node) ->
		normalList = node.normalList
		i = node.index * 3
		avg = new Vector(0, 0, 0)
		for normal in normalList
			normal = Vector.fromObject(normal).normalized()
			avg = avg.add normal
		avg = avg.normalized()
		avgNormals[i] = avg.x
		avgNormals[i + 1] = avg.y
		avgNormals[i + 2] = avg.z

	return {
		positions: vertexPositions
		indices: facesVerticesList
		vertexNormals: avgNormals
		faceNormals: facesNormals
	}
