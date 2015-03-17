class Octree
	constructor: (@distanceDelta) ->
		@index = -1
		@vec = null
		@normalList = null
		@bxbybz = null # Child that has a _b_igger x,y and z
		@bxbysz = null
		@bxsybz = null
		@bxsysz = null
		@sxbybz = null
		@sxbysz = null
		@sxsybz = null
		@sxbysz = null

	forEach: (callback) ->
		callback @
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
		if not @vec?
			# If the tree is not initialized, set the vector as first element
			@vec = vertex
			@normalList = []
			@normalList.push normal
			@index = biggestUsedIndex + 1
			return @index

		else if (vertex.euclideanDistanceTo @vec) < @distanceDelta
			# If the points are near together, return own index
			@normalList.push normal
			return @index

		else
			# Init the subnode this leaf belongs to
			if vertex.x > @vec.x
				# bx____
				if vertex.y > @vec.y
					# bxby__
					if vertex.z > @vec.z
						if not @bxbybz?
							@bxbybz = new Octree(@distanceDelta)
						return @bxbybz.add vertex, normal, biggestUsedIndex
					else
						if not @bxbysz?
							@bxbysz = new Octree(@distanceDelta)
						return @bxbysz.add vertex, normal, biggestUsedIndex
				else
					# bxsy__
					if vertex.z > @vec.z
						if not @bxsybz?
							@bxsybz = new Octree(@distanceDelta)
						return @bxsybz.add vertex, normal, biggestUsedIndex
					else
						if not @bxsysz?
							@bxsysz = new Octree(@distanceDelta)
						return @bxsysz.add vertex, normal, biggestUsedIndex
			else
				# sx____
				if vertex.y > @vec.y
					# sxby__
					if vertex.z > @vec.z
						if not @sxbybz?
							@sxbybz = new Octree(@distanceDelta)
						return @sxbybz.add vertex, normal, biggestUsedIndex
					else
						if not @sxbysz?
							@sxbysz = new Octree(@distanceDelta)
						return @sxbysz.add vertex, normal, biggestUsedIndex
				else
					# sxsy__
					if vertex.z > @vec.z
						if not @sxsybz?
							@sxsybz = new Octree(@distanceDelta)
						return @sxsybz.add vertex, normal, biggestUsedIndex
					else
						if not @sxsysz?
							@sxsysz = new Octree(@distanceDelta)
						return @sxsysz.add vertex, normal, biggestUsedIndex

module.exports = Octree
