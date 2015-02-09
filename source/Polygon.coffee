class Polygon
	constructor: () ->
		@points = []
		@normal = new Vec3(0, 0, 0)

	setNormal: (@normal) ->
		return undefined

	addPoint: (point) ->
		@points.push point
