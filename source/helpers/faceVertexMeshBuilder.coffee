OptimizedModel = require './../OptimizedModel'
Octree = require './../primitives/Octree'
Vector = require './../primitives/Vector'

OctreeHelper = require './OctreeHelper'


module.exports = (faces, options = {}) ->
	pointDistanceEpsilon = options.pointDistanceEpsilon || 0.0001

	faceNormals = []
	faceVertexIndices = []

	octree = new OctreeHelper pointDistanceEpsilon

	for face in faces
		indices = [-1, -1, -1]

		face.vertices.forEach (vertex, i) ->
			index = octree.add vertex, face.normal
			indices[i] = index
		faceVertexIndices = faceVertexIndices.concat indices

		faceNormals.push face.normal.x
		faceNormals.push face.normal.y
		faceNormals.push face.normal.z

	vertexCoordinates = octree.getVertexCoordinateList()
	vertexNormals = octree.getAveragedNormalList()

	return {
		verticesCoordinates: vertexCoordinates
		facesVerticesIndices: faceVertexIndices
		verticesNormals: vertexNormals
		facesNormals: faceNormals
	}
