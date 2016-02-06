ExplicitModel = require '../source/ExplicitModel'

maxCoordinateDelta = 0.00001


module.exports = (chai, utils) ->
	chai.Assertion.addProperty 'explicitModel', () ->
		@assert(
			@_obj instanceof ExplicitModel,
			'expected #{this} to be an explicit Model',
			'expected #{this} to not be an explicit Model'
		)

	chai.Assertion.addProperty 'faceVertexMesh', () ->

		@assert(
			@_obj.mesh.faceVertex.hasOwnProperty 'faceVertexIndices'
			'expected #{this} to have faceVertexIndices',
			'expected #{this} to not have faceVertexIndices'
		)
		@assert(
			@_obj.mesh.faceVertex.hasOwnProperty 'vertexCoordinates'
			'expected #{this} to have vertexCoordinates',
			'expected #{this} to not have vertexCoordinates'
		)
		@assert(
			@_obj.mesh.faceVertex.hasOwnProperty 'vertexNormalCoordinates'
			'expected #{this} to have vertexNormals',
			'expected #{this} to not have vertexNormals'
		)
		@assert(
			@_obj.mesh.faceVertex.hasOwnProperty 'faceNormalCoordinates'
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

		@_obj.vertexCoordinates.every (vertex, vertexIndex) ->
			chai.expect(vertex).to.equalVector(face.vertexCoordinates[vertexIndex])

		chai.expect(@_obj.normal).to.equalVector(face.normal)


	chai.Assertion.addMethod 'equalFaces', (faces) ->

		@_obj.forEach (face, faceIndex) ->
			chai.expect(face).to.equalFace(faces[faceIndex])


	chai.Assertion.addMethod 'equalFaceVertexMesh', (mesh) ->
		@_obj.vertexCoordinates.forEach (coordinate, coordinateIndex) ->
			chai.expect(coordinate)
			.to.be.closeTo(
				mesh.vertexCoordinates[coordinateIndex],
				maxCoordinateDelta
			)

		@_obj.faceVertexIndices.forEach (faceVertexIndex, arrayIndex) ->
			chai.expect(faceVertexIndex)
			.to.equal(mesh.faceVertexIndices[arrayIndex])

		@_obj.faceNormalCoordinates.forEach (coordinate, coordinateIndex) ->
			chai.expect(coordinate)
			.to.be.closeTo(
				mesh.faceNormalCoordinates[coordinateIndex],
				maxCoordinateDelta
			)

		@_obj.vertexNormalCoordinates.forEach (coordinate, coordinateIndex) ->
			chai.expect(coordinate)
			.to.be.closeTo(
				mesh.vertexNormalCoordinates[coordinateIndex],
				maxCoordinateDelta
			)


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
