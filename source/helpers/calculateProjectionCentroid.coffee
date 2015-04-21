module.exports = (face, projection = 'xy') ->
	if projection is 'xy' or projection is 'yx'
		return {
		x: (face.vertices[0].x + face.vertices[1].x + face.vertices[2].x) / 3
		y: (face.vertices[0].y + face.vertices[1].y + face.vertices[2].y) / 3
		}
