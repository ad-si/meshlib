optimizeModel = require './optimizeModel'
Vector = require './Vector'
Face = require './Face'
geometrySplitter = require './separateGeometry'

NoFacesError = (message) ->
	this.name = 'NoFacesError'
	this.message = message or
		'No faces available. Make sure to generate them first.'
NoFacesError.prototype = new Error

# Abstracts the actual model from the external fluid api
class Model
	constructor: (@mesh, @options) ->
		@mesh ?= {}
		@options ?= {}

	optimize: () =>
		@mesh = optimizeModel @mesh
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
					face.addVertex new Vector 0,0,0
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

	# Checks whether the model is 2-manifold, meaning that each edge is connected
	# to exactly two faces. This also implies that the mesh is a closed body
	# without holes
	isTwoManifold: () ->
		if @_isTwoManifold?
			return @_isTwoManifold

		edges = []
		numEdges = []

		# adds the edge to the edges list. if it already exists in the list,
		# the counter in numEdges is increased
		addEdge = (a, b) ->
			for i in [0..edges.length - 1] by 1
				aeb = (edges[i].a == a and edges[i].b == b)
				bea = (edges[i].a == b and edges[i].b == a)
				if (aeb or bea)
					numEdges[i]++
					if numEdges[i] > 2
						return false
					else
						return true
			edges.push {a: a, b: b}
			numEdges.push 1

		# add all edges for all triangles
		for i in [0..@indices.length - 1] by 3
			a = @indices[i]
			b = @indices[i + 1]
			c = @indices[i + 2]
			r = addEdge a, b
			r = addEdge(b, c) and r
			r = addEdge(c, a) and r

			if not r
				@_isTwoManifold = false
				return @_isTwoManifold

		# check that each edge exists exactly twice
		for num in numEdges
			if num != 2
				@_isTwoManifold = false
				return @_isTwoManifold
		@_isTwoManifold = true
		return @_isTwoManifold

module.exports = Model
