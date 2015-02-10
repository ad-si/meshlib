Vector = require './Vector'

class Polygon
	constructor: () ->
		@points = []
		@normal = new Vector(0, 0, 0)

	setNormal: (@normal) ->
		return

	addPoint: (point) ->
		@points.push point

module.exports = Polygon
