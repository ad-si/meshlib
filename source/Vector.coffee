class Vector
	constructor: (@x, @y, @z) ->
		return

	fromObject: (object) ->
		@x = object.x
		@y = object.y
		@z = object.z
		return @

	fromArray: (array) ->
		@x = array[0]
		@y = array[1]
		@z = array[2]
		return @

	minus: (vec) ->
		return new Vector(@x - vec.x, @y - vec.y, @z - vec.z)

	add: (vec) ->
		return new Vector(@x + vec.x, @y + vec.y, @z + vec.z)

	crossProduct: (vec) ->
		return new Vector(@y * vec.z - @z * vec.y,
			@z * vec.x - @x * vec.z,
			@x * vec.y - @y * vec.x)

	length: () ->
		return Math.sqrt(@x * @x + @y * @y + @z * @z)

	euclideanDistanceTo: (vec) ->
		return (@minus vec).length()

	multiplyScalar: (scalar) ->
		return new Vector(@x * scalar, @y * scalar, @z * scalar)

	normalized: () ->
		return @multiplyScalar (1.0 / @length())

module.exports = Vector
