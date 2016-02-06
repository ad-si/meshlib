chai = require 'chai'
expect = chai.expect

models = require './models/models'
meshlib = require '../source/index'


describe 'Mesh Transformation', ->

	it 'creates a face-vertex mesh from the list of faces of a cube', ->
		cubeFaces = models['cube'].load()
		cubeFaceVertexMesh = models['face-vertex cube'].load()

		modelPromise = meshlib cubeFaces
			.buildFaceVertexMesh()
			.done (model) -> model.mesh.faceVertex

		return expect modelPromise
			.to.eventually.deep.equal cubeFaceVertexMesh


	it 'creates a face-vertex mesh from the list of faces of a tetrahedron', ->
		tetrahedronFaces = models['tetrahedron'].load()
		tetrahedronFaceVertexMesh = models['face-vertex tetrahedron'].load()

		modelPromise = meshlib tetrahedronFaces
			.buildFaceVertexMesh()
			.done (model) -> model.mesh.faceVertex

		return expect modelPromise
			.to.eventually.deep.equal tetrahedronFaceVertexMesh


	it 'creates a face-vertex mesh from the list of faces \
		of an irregular tetrahedron', ->
		tetrahedronFaces = models['irregular tetrahedron'].load()
		tetrahedronFaceVertexMesh = \
			models['face-vertex irregular tetrahedron'].load()

		modelPromise = meshlib tetrahedronFaces
			.buildFaceVertexMesh()
			.done (model) -> model.mesh.faceVertex

		return expect modelPromise
			.to.eventually.deep.equal tetrahedronFaceVertexMesh
