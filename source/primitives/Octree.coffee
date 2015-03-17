class Octree
	constructor: (@joinDistanceEpsilon) ->
		@index = -1
		@vec = null
		@normalList = null
		# subtrees are built according to their relative position in x,y,z
		# b ... bigger (closer to +Infinity)
		# s ... smaller (closer to -Infinity) or equal
		@bxbybz = null
		@bxbysz = null
		@bxsybz = null
		@bxsysz = null
		@sxbybz = null
		@sxbysz = null
		@sxsybz = null
		@sxbysz = null

	forEach: (callback) ->
		callback @
		@bxbybz?.forEach callback
		@bxbysz?.forEach callback
		@bxsybz?.forEach callback
		@bxsysz?.forEach callback
		@sxbybz?.forEach callback
		@sxbysz?.forEach callback
		@sxsybz?.forEach callback
		@sxsysz?.forEach callback

	add: (vertex, normal, biggestUsedIndex = 0) ->
		if not @vec?
			return @_setVertex vertex, normal, biggestUsedIndex

		if (vertex.euclideanDistanceTo @vec) < @joinDistanceEpsilon
			return @_joinVertex vertex, normal

		return @_addToSubtree vertex, normal, biggestUsedIndex

	_setVertex: (vertex, normal, biggestUsedIndex) ->
		@vec = vertex
		@normalList = []
		@normalList.push normal
		@index = biggestUsedIndex + 1
		return @index

	_joinVertex: (vertex, normal) ->
		@normalList.push normal
		return @index

	_addToSubtree: (vertex, normal, biggestUsedIndex) ->
		if vertex.x > @vec.x
			# bx____
			if vertex.y > @vec.y
				# bxby__
				if vertex.z > @vec.z
					@bxbybz ?= new Octree @joinDistanceEpsilon
					return @bxbybz.add vertex, normal, biggestUsedIndex
				else
					@bxbysz ?= new Octree @joinDistanceEpsilon
					return @bxbysz.add vertex, normal, biggestUsedIndex
			else
				# bxsy__
				if vertex.z > @vec.z
					@bxsybz ?= new Octree @joinDistanceEpsilon
					return @bxsybz.add vertex, normal, biggestUsedIndex
				else
					@bxsysz ?= new Octree @joinDistanceEpsilon
					return @bxsysz.add vertex, normal, biggestUsedIndex
		else
			# sx____
			if vertex.y > @vec.y
				# sxby__
				if vertex.z > @vec.z
					@sxbybz ?= new Octree @joinDistanceEpsilon
					return @sxbybz.add vertex, normal, biggestUsedIndex
				else
					@sxbysz ?= new Octree @joinDistanceEpsilon
					return @sxbysz.add vertex, normal, biggestUsedIndex
			else
				# sxsy__
				if vertex.z > @vec.z
					@sxsybz ?= new Octree @joinDistanceEpsilon
					return @sxsybz.add vertex, normal, biggestUsedIndex
				else
					@sxsysz ?= new Octree @joinDistanceEpsilon
					return @sxsysz.add vertex, normal, biggestUsedIndex

module.exports = Octree
