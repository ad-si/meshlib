forEachEdge = require('./FaceVertexMeshTraversion').forEachEdge

module.exports = (faceVertexMesh) ->
	edgeCountMap = {}

	forEachEdge faceVertexMesh, (v1, v2) ->
		a = Math.min v1, v2
		b = Math.max v1, v2
		key = a + '-' + b
		edgeCountMap[key] ?= 0
		edgeCountMap[key]++

	for edge, count of edgeCountMap
		return false if count isnt 2

	return true
