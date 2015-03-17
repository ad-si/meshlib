Vector = require './primitives/Vector'
Face = require './primitives/Face'
geometrySplitter = require './helpers/separateGeometry'
faceVertexMeshBuilder = require './helpers/faceVertexMeshBuilder'
testTwoManifoldness = require './helpers/testTwoManifoldness'

NoFacesError = (message) ->
	this.name = 'NoFacesError'
	this.message = message or
		'No faces available. Make sure to generate them first.'
NoFacesError.prototype = new Error

# Abstracts the actual model from the external fluid api
class Model
	constructor: (@mesh, @options) ->
		@mesh ?= {
			faces: [],
			faceVertex: {}
		}
		@options ?= {}


	buildFaceVertexMesh: () =>
		@mesh.faceVertex = faceVertexMeshBuilder @mesh.faces
		return @


	setFaces: (faces) =>
		@mesh.faces = faces
		return @


	fixFaces: () =>
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


	calculateNormals: () =>
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

	getSubmodels: () =>
		return geometrySplitter @mesh


	isTwoManifold: () ->
		@_isTwoManifold ?= testTwoManifoldness @mesh.faceVertex
		return @_isTwoManifold

module.exports = Model
