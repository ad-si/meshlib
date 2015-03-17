class Vector
	constructor: (@x, @y, @z) ->
		return

	@fromObject: (object) ->
		return new Vector object.x, object.y, object.z

	@fromArray: (array) ->
		return new Vector array[0], array[1], array[2]

	add: (vec) ->
		return new Vector @x + vec.x, @y + vec.y, @z + vec.z

	minus: (vec) ->
		return new Vector @x - vec.x, @y - vec.y, @z - vec.z

	length: () ->
		return Math.sqrt @x * @x + @y * @y + @z * @z

	euclideanDistanceTo: (vec) ->
		return @minus(vec).length()

	scale: (scalar) ->
		return new Vector @x * scalar, @y * scalar, @z * scalar

	normalized: () ->
		return @scale 1.0 / @length()

	crossProduct: (vec) ->
		return new Vector(
			@y * vec.z - @z * vec.y
			@z * vec.x - @x * vec.z
			@x * vec.y - @y * vec.x
		)

module.exports = Vector
