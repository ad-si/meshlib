OptimizedModel = require './../OptimizedModel'
Octree = require './../primitives/Octree'
Vector = require './../primitives/Vector'

OctreeHelper = require './OctreeHelper'


module.exports = (faces, options = {}) ->
	pointDistanceEpsilon = options.pointDistanceEpsilon || 0.0001

	facesNormals = []
	facesVerticesIndices = []

	octreeRoot = new OctreeHelper pointDistanceEpsilon

	for face in faces
		# Add vertices if they don't exist, or get index of these vertices
		indices = [-1, -1, -1]

		face.vertices.forEach (vertex, vertexIndex) ->
			index = octreeRoot.add vertex, face.normal
			indices[vertexIndex] = index
		facesVerticesIndices = facesVerticesIndices.concat indices

		facesNormals.push face.normal.x
		facesNormals.push face.normal.y
		facesNormals.push face.normal.z

	# Get a list out of the octree
	vertexCoordinates = octreeRoot.getVertexCoordinateList()
	vertexNormals = octreeRoot.getAveragedNormalList()

	return {
		verticesCoordinates: vertexCoordinates
		facesVerticesIndices: facesVerticesIndices
		verticesNormals: vertexNormals
		facesNormals: facesNormals
	}
