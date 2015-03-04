Model = require '../source/Model'
Vector = require '../source/Vector'

maxCoordinateDelta = 0.00001


module.exports = (chai, utils) ->
	chai.Assertion.addProperty 'model', () ->
		@assert(
			@_obj instanceof Model,
			'expected #{this} to be a Model',
			'expected #{this} to not be a Model'
		)

	chai.Assertion.addProperty 'faceVertexMesh', () ->

		@assert(
			@_obj.mesh.faceVertex.hasOwnProperty 'facesVerticesIndices'
			'expected #{this} to have facesVerticesIndices',
			'expected #{this} to not have facesVerticesIndices'
		)
		@assert(
			@_obj.mesh.faceVertex.hasOwnProperty 'verticesCoordinates'
			'expected #{this} to have verticesCoordinates',
			'expected #{this} to not have verticesCoordinates'
		)
		@assert(
			@_obj.mesh.faceVertex.hasOwnProperty 'verticesNormals'
			'expected #{this} to have vertexNormals',
			'expected #{this} to not have vertexNormals'
		)
		@assert(
			@_obj.mesh.faceVertex.hasOwnProperty 'facesNormals'
			'expected #{this} to have faceNormals',
			'expected #{this} to not have faceNormals'
		)


	chai.Assertion.addProperty 'triangleMesh', () ->

		allTriangles = @_obj.mesh.polygons.every (polygon) ->
			return polygon.vertices.length is 3

		@assert(
			allTriangles
			'expected mesh #{this} to consist only of triangles',
			'expected mesh #{this} to not consist only of triangles'
		)


	chai.Assertion.addMethod 'equalVector', (vertex) ->

			['x', 'y', 'z'].every (coordinate) =>

				actualCoordinate = @_obj[coordinate]
				expectedCoordinate = vertex[coordinate]

				chai.expect(actualCoordinate).to.be
					.closeTo(expectedCoordinate, maxCoordinateDelta)


	chai.Assertion.addMethod 'equalFace', (face) ->

		@_obj.verticesCoordinates.every (vertex, vertexIndex) =>
			chai.expect(vertex).to.equalVector(face.verticesCoordinates[vertexIndex])

		chai.expect(@_obj.normal).to.equalVector(face.normal)


	chai.Assertion.addMethod 'equalFaces', (faces) ->

		@_obj.forEach (face, faceIndex) =>
			chai.expect(face).to.equalFace(faces[faceIndex])


	chai.Assertion.addProperty 'correctNormals', () ->

		### TODO

		correctDirection = @_obj.mesh.faces.every (face) ->
			TODO

		@assert(
			correctDirection
			'expected every face-normal to point in the right direction',
			'expected every face-normal to point in the wrong direction',
		)
        ###

		normalizedLength = @_obj.mesh.faces.every (face) ->
			return face.normal.length() is 1

		@assert(
			normalizedLength
			'expected every face-normal to have length of 1',
			'expected every face-normal to have a length different from 1',
		)
