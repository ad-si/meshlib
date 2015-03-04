Vector = require './Vector'
Face = require './Face'
geometrySplitter = require './separateGeometry'
faceVertexMeshBuilder = require './faceVertexMeshBuilder'

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
		if @_isTwoManifold?
			return @_isTwoManifold

		edgesCountMap = {}

		# Count edge occurrences for all triangles
		for index in [0...@mesh.faceVertex.facesVerticesIndices.length] by 3
			do (index) =>
				x = @mesh.faceVertex.facesVerticesIndices[index]
				y = @mesh.faceVertex.facesVerticesIndices[index + 1]
				z = @mesh.faceVertex.facesVerticesIndices[index + 2]

				[
					String(x).concat y
					String(y).concat x

					String(y).concat z
					String(z).concat y

					String(z).concat x
					String(x).concat z
				]
				.forEach (edge) =>
					if edgesCountMap[edge]
						edgesCountMap[edge]++
					else
						edgesCountMap[edge] = 1

		# Check that each edge exists exactly twice
		for edge, count of edgesCountMap
			if count isnt 2
				@_isTwoManifold = false
				return false

		@_isTwoManifold = true
		return true

module.exports = Model
