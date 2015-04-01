Vector = require './primitives/Vector'
Face = require './primitives/Face'
geometrySplitter = require './helpers/separateGeometry'
buildFaceVertexMesh = require './helpers/buildFaceVertexMesh'
testTwoManifoldness = require './helpers/testTwoManifoldness'
calculateBoundingBox = require './helpers/calculateBoundingBox'
NoFacesError = require './errors/NoFacesError'

# Abstracts the actual model from the external fluid api
class Model
	constructor: (@mesh, @options) ->
		@mesh ?= {
			faces: [],
			faceVertex: {}
		}
		@options ?= {}
		@fileName = ''
		@name = ''


	buildFaceVertexMesh: =>
		@mesh.faceVertex = buildFaceVertexMesh @mesh.faces
		return @


	setFaces: (faces) =>
		@mesh.faces = faces
		return @


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
		return geometrySplitter @mesh


	isTwoManifold: ->
		@_isTwoManifold ?= testTwoManifoldness @mesh.faceVertex
		return @_isTwoManifold


	getBoundingBox: ->
		if not @_boundingBox
			@_boundingBox = calculateBoundingBox @mesh.faceVertex
		return @_boundingBox


	forEachFace: (callback) ->
		coordinates = @mesh.faceVertex.verticesCoordinates
		indices = @mesh.faceVertex.facesVerticesIndices
		normalCoordinates = @mesh.faceVertex.facesNormals

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


module.exports = Model
