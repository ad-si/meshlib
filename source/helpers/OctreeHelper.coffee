Vector = require '../primitives/Vector'
Octree = require '../primitives/Octree'

class OctreeHelper
	constructor: (@joinDistanceEpsilon) ->
		@tree = new Octree @joinDistanceEpsilon
		@lastIndex = 0

	add: (vertex, normal) ->
		vertex = Vector.fromObject vertex
		normal = Vector.fromObject(normal).normalized()
		vertexIndex = @tree.add vertex, normal, @lastIndex
		if vertexIndex > @lastIndex
			@lastIndex = vertexIndex
		return vertexIndex

	getVertexCoordinateList: ->
		vertexList = new Array (@lastIndex + 1) * 3
		@tree.forEach (node) ->
			i = node.index * 3
			vertexList[i] = node.vec.x
			vertexList[i + 1] = node.vec.y
			vertexList[i + 2] = node.vec.z

	getAveragedNormalList: ->
		averagedNormalList = new Array (@lastIndex + 1) * 3
		@tree.forEach (node) ->
			avgNormal = new Vector(0, 0, 0)
			for normal in node.normalList
				avgNormal = avgNormal.add normal
			avgNormal = avgNormal.normalized()

			i = node.index * 3
			averagedNormalList[i] = avgNormal.x
			averagedNormalList[i + 1] = avgNormal.y
			averagedNormalList[i + 2] = avgNormal.z

		return averagedNormalList

module.exports = OctreeHelper
