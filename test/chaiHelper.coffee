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

	chai.Assertion.addProperty 'optimized', () ->

		@assert(
			@_obj.mesh.hasOwnProperty 'indices'
			'expected #{this} to have indices',
			'expected #{this} to not have indices'
		)
		@assert(
			@_obj.mesh.hasOwnProperty 'positions'
			'expected #{this} to have positions',
			'expected #{this} to not have positions'
		)
		@assert(
			@_obj.mesh.hasOwnProperty 'vertexNormals'
			'expected #{this} to have vertexNormals',
			'expected #{this} to not have vertexNormals'
		)
		@assert(
			@_obj.mesh.hasOwnProperty 'faceNormals'
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

		@_obj.vertices.every (vertex, vertexIndex) =>
			chai.expect(vertex).to.equalVector(face.vertices[vertexIndex])

		chai.expect(@_obj.normal).to.equalVector(face.normal)


	chai.Assertion.addMethod 'equalFaces', (faces) ->

		@_obj.forEach (face, faceIndex) =>
			chai.expect(face).to.equalFace(faces[faceIndex])


	chai.Assertion.addProperty 'correctNormals', () ->

		### TODO

		correctDirection = @_obj.mesh.polygons.every (polygon) ->
			TODO

		@assert(
			correctDirection
			'expected every face-normal to point in the right direction',
			'expected every face-normal to point in the wrong direction',
		)
        ###

		normalizedLength = @_obj.mesh.polygons.every (polygon) ->
			return polygon.normal.length() is 1

		@assert(
			normalizedLength
			'expected every face-normal to have length of 1',
			'expected every face-normal to have a length different from 1',
		)
