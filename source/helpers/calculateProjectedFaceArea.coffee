# Calculate the area of the projection of a face in the xy-plane
# http://stackoverflow.com/questions/16285134

module.exports = (face) ->
	xCoordinates = [
		face.vertices[0].x
		face.vertices[1].x
		face.vertices[2].x
	]
	yCoordinates = [
		face.vertices[0].y
		face.vertices[1].y
		face.vertices[2].y
	]

	area = 0
	j = xCoordinates.length - 1

	for i in [0..yCoordinates.length - 1] by 1
		area += (xCoordinates[j] + xCoordinates[i]) *
			(yCoordinates[j] - yCoordinates[i])
		j = i

	return Math.abs area / 2
