OptimizedModel = require './OptimizedModel.coffee'

# Takes an optimized model and looks for connected geometry
# returns a list of optimized models if the original model
# contains several geometries (-> connected polygons) that
# have no connection between each other
separateGeometry = (optimizedModel) ->
	equivalenceClasses = createEquivalenceClasses optimizedModel

	if equivalenceClasses.length == 1
		return [optimizedModel]

	models = []
	for eq in equivalenceClasses
		models.push createModelFromEquivalenceClass eq, optimizedModel

	return models

# creates an standalone optimized model from an equivalence class and an
# existing optimized model
# TODO needs to be tested
createModelFromEquivalenceClass = (equivalenceClass, optimizedModel) ->
	nextPointIndex = 0
	polyTranslationTable = {}

	model = new OptimizedModel()

	# inserts a point into the new model,
	# adjust the id to prevent undefined position entries
	insertPoint =  (currentId) ->
		if not polyTranslationTable[currentId]?
			polyTranslationTable[currentId] = nextPointIndex
			nextPointIndex++
			model.positions.push optimizedModel.positions[currentId * 3 + 0]
			model.positions.push optimizedModel.positions[currentId * 3 + 1]
			model.positions.push optimizedModel.positions[currentId * 3 + 2]
			model.vertexNormals.push optimizedModel.vertexNormals[currentId * 3 + 0]
			model.vertexNormals.push optimizedModel.vertexNormals[currentId * 3 + 1]
			model.vertexNormals.push optimizedModel.vertexNormals[currentId * 3 + 2]

		return polyTranslationTable[currentId]

	equivalenceClass.polygons.enumerate (pi) ->
		p0 = optimizedModel.indices[pi * 3 + 0]
		p1 = optimizedModel.indices[pi * 3 + 1]
		p2 = optimizedModel.indices[pi * 3 + 2]

		p0n = insertPoint p0
		p1n = insertPoint p1
		p2n = insertPoint p2

		model.indices.push p0n
		model.indices.push p1n
		model.indices.push p2n
		model.faceNormals.push optimizedModel.faceNormals[pi * 3 + 0]
		model.faceNormals.push optimizedModel.faceNormals[pi * 3 + 1]
		model.faceNormals.push optimizedModel.faceNormals[pi * 3 + 2]

	return model

# returns an array of equivalence classes. each equivalence class
# represents several polygons that share points. if the model has
# several equivalence classes, it contains several geometries
# that are not connected to each other
createEquivalenceClasses = (optimizedModel) ->
	equivalenceClasses = []

	for polygonIndex in [0..optimizedModel.indices.length - 1] by 3
		poly = {
			index: polygonIndex / 3
			p0: optimizedModel.indices[polygonIndex]
			p1: optimizedModel.indices[polygonIndex + 1]
			p2: optimizedModel.indices[polygonIndex + 2]
		}

		connectedClasses = []

		for eq in equivalenceClasses
			if eq.points.exists(poly.p0) or
			eq.points.exists(poly.p1) or eq.points.exists(poly.p2)
				eq.points.push poly.p0
				eq.points.push poly.p1
				eq.points.push poly.p2
				eq.polygons.push poly.index
				connectedClasses.push eq

		if connectedClasses.length == 0
			# no connected classes? add an additional
			# equivalence class because this is
			# unconnected geometry
			eq = {
				points: new Hashmap()
				polygons: new Hashmap()
			}
			eq.points.push poly.p0
			eq.points.push poly.p1
			eq.points.push poly.p2
			eq.polygons.push poly.index
			equivalenceClasses.push eq

		else if connectedClasses.length > 1
			# this polygon belongs to more than one class. therefore,
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
		polygons: new Hashmap()
	}

	for eq in equivalenceClasses
		# add points and polygons to new class. The hashmap
		# automatically prevents inserting duplicate values
		eq.points.enumerate (point) ->
			newClass.points.push point

		eq.polygons.enumerate (polygon) ->
			newClass.polygons.push polygon

		# clear old class
		eq.points = new Hashmap()
		eq.polygons = new Hashmap()

	return newClass


module.exports = separateGeometry

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
