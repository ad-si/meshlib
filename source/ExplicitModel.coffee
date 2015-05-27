clone = require 'clone'
deg2rad = require 'deg2rad'
rad2deg = require 'rad2deg'

Vector = require './primitives/Vector'
Face = require './primitives/Face'
Matrix = require './primitives/Matrix'
geometrySplitter = require './helpers/separateGeometry'
buildFaceVertexMesh = require './helpers/buildFaceVertexMesh'
buildFacesFromFaceVertexMesh = require './helpers/buildFacesFromFaceVertexMesh'
testTwoManifoldness = require './helpers/testTwoManifoldness'
calculateBoundingBox = require './helpers/calculateBoundingBox'
calculateProjectedFaceArea = require './helpers/calculateProjectedFaceArea'
convertToBase64 = require './helpers/convertToBase64'
buildMeshFromBase64 = require './helpers/buildMeshFromBase64'
NoFacesError = require './errors/NoFacesError'
calculateProjectionCentroid = require './helpers/calculateProjectionCentroid'
ModelStream = require './ModelStream'


modulo = (value1, value2) ->
	# Work around javascript modulo bug
	# javascript.about.com/od/problemsolving/a/modulobug.htm
	return ((value1 % value2) + value2) % value2


getRotationMatrix = ({axis, angle} = {}) =>
	axis ?= 'z'

	cos = Math.cos angle
	sin = Math.sin angle

	switch axis
		when 'x'
			return [
				[1, 0, 0, 0]
				[0, cos, -sin, 0]
				[0, sin, cos, 0]
				[0, 0, 0, 1]
			]
		when 'y'
			return [
				[cos, 0, sin, 0]
				[0, 1, 0, 0]
				[-sin, 0, cos, 0]
				[0, 0, 0, 1]
			]
		when 'z'
			return [
				[cos, -sin, 0, 0]
				[sin, cos, 0, 0]
				[0, 0, 1, 0]
				[0, 0, 0, 1]
			]


getExtremes = (array) ->
	return array.reduce(
		(previous, current, index) ->
			unless previous.maximum.value and current?
				previous.maximum = previous.minimum =
					value: current
					index: index

			else if current > previous.maximum.value
				previous.maximum =
					value: current
					index: index

			else if current < previous.minimum.value
				previous.minimum =
					value: current
					index: index

			return previous
		,
		minimum:
			value: null
			index: null
		maximum:
			value: null
			index: null
	)


applyMatrixToPoint = (matrix, point) ->
	newMatrix = Matrix.multiply matrix, [
		[point.x]
		[point.y]
		[point.z]
		[1]
	]
	newPoint = {
		x: newMatrix[0][0]
		y: newMatrix[1][0]
		z: newMatrix[2][0]
	}

	return newPoint


calculateGridAlignRotationAngle = ({faces, rotationAxis, unit} = {}) ->
	unit ?= 'radian'
	rotationAxis ?= 'z'

	angleSurfaceAreaHistogram = faces
	.filter (face) ->
		# Get all faces aligned along the rotationAxis
		return Math.abs(face.normal[rotationAxis]) < 0.01

	.map (face) ->
		face.surfaceArea = Face.calculateSurfaceArea face

		# Get rotation angle
		rotationAngle = switch
			when rotationAxis is 'x'
				Math.atan2 face.normal.z, face.normal.y
			when rotationAxis is 'y'
				Math.atan2 face.normal.x, face.normal.z
			when rotationAxis is 'z'
				Math.atan2 face.normal.y, face.normal.x

		# Calculate rotation angle modulo 90 deg
		angleModulusHalfPi = (rotationAngle + Math.PI) % (Math.PI / 2)

		# Convert to deg and round to nearest integer
		face.nearestAngleInDegrees = Math.round rad2deg angleModulusHalfPi

		return face

	.reduce (histogram, face) ->
		histogram[face.nearestAngleInDegrees] ?= 0
		histogram[face.nearestAngleInDegrees] += face.surfaceArea
		return histogram

	, new Array(90)

	# Return angle with the largest surface area
	angleInDegrees = getExtremes(angleSurfaceAreaHistogram).maximum.index

	if unit is 'degree' or unit is 'deg'
		return angleInDegrees

	return deg2rad angleInDegrees


calculateGridAlignTranslation = ({faces, translationAxes, gridSize}) ->
	axes = ['x', 'y', 'z']

	gridSize ?= {x: 1, y: 1, z: 1}
	translationAxes ?= ['x', 'y']
	returnObject = {}

	translationAxes.forEach (translationAxis) ->
		invariantAxes = axes.filter (axis) ->
			return translationAxis.indexOf(axis) < 0

		offsetHistogram = faces
		.filter (face) ->
			return Math.abs(face.normal[invariantAxes[0]]) < 0.01 and
					Math.abs(face.normal[invariantAxes[1]]) < 0.01
		.map (face) ->
			face.normal[invariantAxes[0]] =
				modulo face.normal[translationAxis], gridSize[translationAxis]
			return face

		.map (face) ->
			face.surfaceArea = Face.calculateSurfaceArea face
			return face

		.reduce (histogram, currentFace) ->

			# Get offset in percentage of grid-size rounded to 1%

			offsetPercentage = Math.round(
				(modulo(
					currentFace.vertices[0][translationAxis],
					gridSize[translationAxis]
				) / gridSize[translationAxis]) * 100
			)

			histogram[offsetPercentage] ?= 0
			histogram[offsetPercentage] += currentFace.surfaceArea

			return histogram

		, new Array(100)

		returnObject[translationAxis] =
			-(gridSize[translationAxis] *
			getExtremes(offsetHistogram).maximum.index) / 100

	return returnObject

# Abstracts the actual model from the external fluid api
class ExplicitModel
	constructor: (@mesh, @options) ->
		@mesh ?= {
			faces: [],
			faceVertex: {}
		}
		@transformations = []
		@options ?= {}
		@name = ''
		@fileName = ''
		@faceCount = ''


	@fromBase64: (base64String) ->
		data = buildMeshFromBase64 base64String

		model = new ExplicitModel {faceVertex: data.faceVertexMesh}
		model.name = data.name

		return model


	clone: () =>
		modelClone = new ExplicitModel()

		modelClone.mesh = clone @mesh
		modelClone.transformations = clone @transformations
		modelClone.options = clone @options
		modelClone.name = @name
		modelClone.fileName = @fileName
		modelClone.faceCount = @faceCount

		return modelClone


	applyMatrix: (matrix) =>
		@mesh.faces = @mesh.faces.map (face) ->
			face.vertices = face.vertices.map (vertex) ->
				return applyMatrixToPoint matrix, vertex
			return face
		return @


	translate: (vector) =>
		if(Array.isArray(vector))
			vector =
				x: Number(vector[0])
				y: Number(vector[1])
				z: Number(vector[2])

		@mesh.faces.forEach (face) =>
			face.vertices.forEach (vertex) =>
				vertex.x += vector.x || 0
				vertex.y += vector.y || 0
				vertex.z += vector.z || 0

		return @


	rotate: ({angle, axis, unit} = {}) =>
		unless angle
			return @

		unit ?= 'radian'
		axis ?= 'z'

		if unit is 'degree'
			angle = deg2rad angle

		@applyMatrix getRotationMatrix {axis: axis, angle: angle}


	buildFaceVertexMesh: =>
		@mesh.faceVertex = buildFaceVertexMesh @mesh.faces
		return @


	buildFacesFromFaceVertexMesh: =>
		@mesh.faces = buildFacesFromFaceVertexMesh @mesh.faceVertex
		return @


	setFaces: (faces) =>
		@mesh.faces = faces
		return @


	getFaces: (options = {}) =>
		if options.filter and typeof options.filter is 'function'
			return @mesh.faces.filter(options.filter)

		return @mesh.faces


	fixFaces: =>
		deletedFaces = []

		if @mesh.faces
			@mesh.faces = @mesh.faces.map (face) ->
				if face.vertices.length is 3
					return face

				else if face.vertices.length > 3
					deletedFaces.push face
					face.vertices = face.vertices.slice(0, 3)
					return face

				else if face.vertices.length is 2
					face.addVertex new Vector 0, 0, 0
					return face

				else if face.vertices.length is 1
					face.addVertex new Vector 0, 0, 0
					face.addVertex new Vector 1, 1, 1
					return face

				else
					return null
		else
			throw new NoFacesError
		return @


	calculateNormals: =>
		newNormals = []

		if @mesh.faces
			@mesh.faces = @mesh.faces.map (face) ->
				face = Face.fromVertexArray face.vertices

				d1 = Vector.fromObject(face.vertices[1]).minus (
					Vector.fromObject face.vertices[0]
				)
				d2 = Vector.fromObject(face.vertices[2]).minus (
					Vector.fromObject face.vertices[0]
				)
				normal = d1.crossProduct d2
				normal = normal.normalized()

				if face.normal?
					distance = face.normal.euclideanDistanceTo normal
					if distance > 0.001
						newNormals.push normal

				face.normal = normal
				return face.toObject()
		else
			throw new NoFacesError

		return @

	getSubmodels: =>
		return geometrySplitter @mesh.faceVertex


	isTwoManifold: ->
		@_isTwoManifold ?= testTwoManifoldness @mesh.faceVertex
		return @_isTwoManifold


	getBoundingBox: ({recalculate, source} = {}) ->

		recalculate ?= false
		source ?= 'faces'

		if not @_boundingBox or recalculate is true
			if source is 'faceVertexMesh'
				@_boundingBox = calculateBoundingBox.forFaceVertexMesh(
					@mesh.faceVertex
				)
			else if source is 'faces'
				@_boundingBox = calculateBoundingBox.forFaces(
					@mesh.faces
				)

		return @_boundingBox


	getFaceWithLargestProjection: =>
		faceIndex = 0

		@mesh.faces
		.map (face) ->
			return calculateProjectedFaceArea face
		.reduce (previous, current, currentIndex) ->
			if current > previous
				faceIndex = currentIndex
			return current

		return @mesh.faces[faceIndex]


	getModificationInvariantTranslation: =>
		centroid = calculateProjectionCentroid @getFaceWithLargestProjection()

		return {
		x: -centroid.x
		y: -centroid.y
		z: -@getBoundingBox().min.z
		}


	getGridAlignRotationAngle: (options = {}) =>
		options.faces = @mesh.faces
		return calculateGridAlignRotationAngle options


	getGridAlignRotationMatrix: (options = {}) =>
		options.faces = @mesh.faces
		rotationAngle = @getGridAlignRotationAngle options
		return getRotationMatrix {angle: rotationAngle}


	applyGridAlignRotation: (options = {}) =>
		options.faces = @mesh.faces
		@rotate {
			angle: -calculateGridAlignRotationAngle options
		}
		return @


	getCenteringMatrix: () =>
		boundingBox = @getBoundingBox {recalculate: true, source: 'faces'}

		return [
			[1, 0, 0, -(boundingBox.min.x +
			((boundingBox.max.x - boundingBox.min.x) / 2)) ]
			[0, 1, 0, -(boundingBox.min.y +
			((boundingBox.max.y - boundingBox.min.y) / 2)) ]
			[0, 0, 1, -boundingBox.min.z]
			[0, 0, 0, 1]
		]

	center: () =>
		@applyMatrix @getCenteringMatrix()
		return @


	getGridAlignTranslationMatrix: (options = {}) =>
		options.faces = @mesh.faces
		translation = calculateGridAlignTranslation options

		return [
			[1, 0, 0, translation.x]
			[0, 1, 0, translation.y]
			[0, 0, 1, 0]
			[0, 0, 0, 1]
		]


	applyGridAlignTranslation: (options = {}) =>
		options.faces = @mesh.faces
		@translate calculateGridAlignTranslation options
		return @






	forEachFace: (callback) ->
		coordinates = @mesh.faceVertex.vertexCoordinates
		indices = @mesh.faceVertex.faceVertexIndices
		normalCoordinates = @mesh.faceVertex.faceNormalCoordinates

		for index in [0..indices.length - 1] by 3
			callback {
					vertices: [
						{
							x: coordinates[indices[index] * 3]
							y: coordinates[indices[index] * 3 + 1]
							z: coordinates[indices[index] * 3 + 2]
						}
						{
							x: coordinates[indices[index + 1] * 3]
							y: coordinates[indices[index + 1] * 3 + 1]
							z: coordinates[indices[index + 1] * 3 + 2]
						}
						{
							x: coordinates[indices[index + 2] * 3]
							y: coordinates[indices[index + 2] * 3 + 1]
							z: coordinates[indices[index + 2] * 3 + 2]
						}
					]
					normal:
						x: normalCoordinates[index]
						y: normalCoordinates[index + 1]
						z: normalCoordinates[index + 2]
				},
				index / 3

		return @


	getBase64: () ->
		return convertToBase64(@mesh.faceVertex) + '|' + @name


	toObject: () ->
		return {
		name: @name
		fileName: @fileName
		faceCount: @faceCount
		mesh: @mesh
		}

	toJSON: @toObject

	getStream: (options) =>
		return new ModelStream {
			name: @name
			fileName: @fileName
			faceCount: @faceCount
			mesh: @mesh
		}, options


module.exports = ExplicitModel
