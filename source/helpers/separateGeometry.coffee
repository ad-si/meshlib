# creates an standalone optimized model from an equivalence class and an
# existing optimized model
# TODO needs to be tested
createModelFromEquivalenceClass = (equivalenceClass, faceVertexMesh) ->
	nextPointIndex = 0
	polyTranslationTable = {}

	model = {
		vertexCoordinates: []
		vertexNormalCoordinates: []
		faceNormalCoordinates: []
		faceVertexIndices: []
	}

	# inserts a point into the new model,
	# adjust the id to prevent undefined position entries
	insertPoint = (currentId) ->
		if not polyTranslationTable[currentId]?
			polyTranslationTable[currentId] = nextPointIndex
			nextPointIndex++
			model.vertexCoordinates.push(
				faceVertexMesh.vertexCoordinates[currentId * 3]
			)
			model.vertexCoordinates.push(
				faceVertexMesh.vertexCoordinates[currentId * 3 + 1]
			)
			model.vertexCoordinates.push(
				faceVertexMesh.vertexCoordinates[currentId * 3 + 2]
			)
			model.vertexNormalCoordinates.push(
				faceVertexMesh.vertexNormalCoordinates[currentId * 3]
			)
			model.vertexNormalCoordinates.push(
				faceVertexMesh.vertexNormalCoordinates[currentId * 3 + 1]
			)
			model.vertexNormalCoordinates.push(
				faceVertexMesh.vertexNormalCoordinates[currentId * 3 + 2]
			)

		return polyTranslationTable[currentId]

	equivalenceClass.faces.enumerate (pi) ->
		p0 = faceVertexMesh.faceVertexIndices[pi * 3]
		p1 = faceVertexMesh.faceVertexIndices[pi * 3 + 1]
		p2 = faceVertexMesh.faceVertexIndices[pi * 3 + 2]

		p0n = insertPoint p0
		p1n = insertPoint p1
		p2n = insertPoint p2

		model.faceVertexIndices.push p0n
		model.faceVertexIndices.push p1n
		model.faceVertexIndices.push p2n
		model.faceNormalCoordinates.push faceVertexMesh.faceNormalCoordinates[pi * 3]
		model.faceNormalCoordinates.push faceVertexMesh.faceNormalCoordinates[pi * 3 + 1]
		model.faceNormalCoordinates.push faceVertexMesh.faceNormalCoordinates[pi * 3 + 2]

	return model

# returns an array of equivalence classes. each equivalence class
# represents several faces that share points. if the model has
# several equivalence classes, it contains several geometries
# that are not connected to each other
createEquivalenceClasses = (faceVertexMesh) ->
	equivalenceClasses = []

	for faceIndex in [0..faceVertexMesh.faceVertexIndices.length - 1] by 3
		poly = {
			index: faceIndex / 3
			p0: faceVertexMesh.faceVertexIndices[faceIndex]
			p1: faceVertexMesh.faceVertexIndices[faceIndex + 1]
			p2: faceVertexMesh.faceVertexIndices[faceIndex + 2]
		}

		connectedClasses = []

		for eq in equivalenceClasses
			if eq.points.exists(poly.p0) or
			  eq.points.exists(poly.p1) or eq.points.exists(poly.p2)
				eq.points.push poly.p0
				eq.points.push poly.p1
				eq.points.push poly.p2
				eq.faces.push poly.index
				connectedClasses.push eq

		if connectedClasses.length == 0
			# no connected classes? add an additional
			# equivalence class because this is
			# unconnected geometry
			eq = {
				points: new Hashmap()
				faces: new Hashmap()
			}
			eq.points.push poly.p0
			eq.points.push poly.p1
			eq.points.push poly.p2
			eq.faces.push poly.index
			equivalenceClasses.push eq

		else if connectedClasses.length > 1
			# this face belongs to more than one class. therefore,
			# all of these classes are equal. compact to one class
			# (existing classes are emptied)
			combined = compactClasses connectedClasses
			equivalenceClasses.push combined
			equivalenceClasses = equivalenceClasses.filter (a) ->
				a.points.length > 0

	return equivalenceClasses

# Merge all points and polgons into one equivalence class
compactClasses = (equivalenceClasses) ->
	newClass = {
		points: new Hashmap()
		faces: new Hashmap()
	}

	for eq in equivalenceClasses
		# add points and faces to new class. The hashmap
		# automatically prevents inserting duplicate values
		eq.points.enumerate (point) ->
			newClass.points.push point

		eq.faces.enumerate (face) ->
			newClass.faces.push face

		# clear old class
		eq.points = new Hashmap()
		eq.faces = new Hashmap()

	return newClass


# not really a true hashmap, but something that stores
# numbers and can say whether it contains a certain number very efficiently
class Hashmap
	constructor: ->
		@length = 0
		@_enumarray = []
		@_existsarray = []

	push: (number) =>
		if not @_existsarray[number]
			@length++
			@_existsarray[number] = true
			@_enumarray.push number

	exists: (number) =>
		if @_existsarray[number]?
			return true
		return false

	enumerate: (callback) =>
		for i in [0..@_enumarray.length - 1] by 1
			callback @_enumarray[i]


# Takes an optimized model and looks for connected geometry
# returns a list of optimized models if the original model
# contains several geometries (-> connected faces) that
# have no connection between each other

module.exports = (faceVertexMesh) ->
	models = []
	equivalenceClasses = createEquivalenceClasses faceVertexMesh

	if equivalenceClasses.length is 1
		models.push faceVertexMesh
	else
		for eq in equivalenceClasses
			models.push createModelFromEquivalenceClass eq, faceVertexMesh

	return models
