Vector = require './primitives/Vector'
Face = require './primitives/Face'
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

# Abstracts the actual model from the external fluid api
class ExplicitModel
	constructor: (@mesh, @options) ->
		@mesh ?= {
			faces: [],
			faceVertex: {}
		}
		@options ?= {}
		@name = ''
		@fileName = ''
		@faceCount = ''


	@fromBase64: (base64String) ->
		data = buildMeshFromBase64 base64String

		model = new ExplicitModel {faceVertex: data.faceVertexMesh}
		model.name = data.name

		return model


	translate: (vector) =>
		@mesh.faces.forEach (face) =>
			face.vertices.forEach (vertex) =>
				vertex.x += vector.x || 0
				vertex.y += vector.y || 0
				vertex.z += vector.z || 0


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
				return face
		else
			throw new NoFacesError

		return @

	getSubmodels: =>
		return geometrySplitter @mesh.faceVertex


	isTwoManifold: ->
		@_isTwoManifold ?= testTwoManifoldness @mesh.faceVertex
		return @_isTwoManifold


	getBoundingBox: ->
		if not @_boundingBox
			@_boundingBox = calculateBoundingBox @mesh.faceVertex
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


module.exports = ExplicitModel
