class Octree
	constructor: (@distanceDelta) ->
		@index = -1
		@vec = null
		@normalList = null
		@bxbybz = null #child that has a _b_igger x,y and z
		@bxbysz = null
		@bxsybz = null
		@bxsysz = null
		@sxbybz = null
		@sxbysz = null
		@sxsybz = null
		@sxbysz = null

	forEach: (callback) ->
		callback(@)
		if @bxbybz?
			@bxbybz.forEach callback
		if @bxbysz?
			@bxbysz.forEach callback
		if @bxsybz?
			@bxsybz.forEach callback
		if @bxsysz?
			@bxsysz.forEach callback
		if @sxbybz?
			@sxbybz.forEach callback
		if @sxbysz?
			@sxbysz.forEach callback
		if @sxsybz?
			@sxsybz.forEach callback
		if @sxsysz?
			@sxsysz.forEach callback

	add: (vertex, normal, biggestUsedIndex = 0) ->
		if @vec == null
			#if the tree is not initialized, set the vector as first element
			@vec = vertex
			@normalList = []
			@normalList.push normal
			@index = biggestUsedIndex + 1
			return @index
		else if (vertex.euclideanDistanceTo @vec) < @distanceDelta
			#if the points are near together, return own index
			@normalList.push normal
			return @index
		else
			#init the subnode this leaf belongs to
			if vertex.x > @vec.x
				#bx....
				if vertex.y > @vec.y
					#bxby..
					if vertex.z > @vec.z
						if (!(@bxbybz?))
							@bxbybz = new Octree(@distanceDelta)
						return @bxbybz.add vertex, normal, biggestUsedIndex
					else
						if (!(@bxbysz?))
							@bxbysz = new Octree(@distanceDelta)
						return @bxbysz.add vertex, normal, biggestUsedIndex
				else
					#bxsy..
					if vertex.z > @vec.z
						if (!(@bxsybz?))
							@bxsybz = new Octree(@distanceDelta)
						return @bxsybz.add vertex, normal, biggestUsedIndex
					else
						if (!(@bxsysz?))
							@bxsysz = new Octree(@distanceDelta)
						return @bxsysz.add vertex, normal, biggestUsedIndex
			else
				#sx....
				if vertex.y > @vec.y
					#sxby..
					if vertex.z > @vec.z
						if (!(@sxbybz?))
							@sxbybz = new Octree(@distanceDelta)
						return @sxbybz.add vertex, normal, biggestUsedIndex
					else
						if (!(@sxbysz?))
							@sxbysz = new Octree(@distanceDelta)
						return @sxbysz.add vertex, normal, biggestUsedIndex
				else
					#sxsy..
					if vertex.z > @vec.z
						if (!(@sxsybz?))
							@sxsybz = new Octree(@distanceDelta)
						return @sxsybz.add vertex, normal, biggestUsedIndex
					else
						if (!(@sxsysz?))
							@sxsysz = new Octree(@distanceDelta)
						return @sxsysz.add vertex, normal, biggestUsedIndex

module.exports = Octree
